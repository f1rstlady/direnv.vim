let s:job_status = { 'running': 0, 'stdout': [], 'stderr': [] }

function! direnv#on_stdout(_, data, ...) abort
  call extend(s:job_status.stdout, a:data)
endfunction

function! direnv#on_stderr(_, data, ...) abort
  call extend(s:job_status.stderr, a:data)
endfunction

function! direnv#on_exit(_, status, ...) abort
  let s:job_status.running = 0

  for msg in filter(s:job_status.stderr, 'v:val !=# ""')
    echomsg msg
  endfor
  execute 'echo '.join(s:job_status.stdout, "\n")
endfunction

let s:job = { 'on_stdout': 'direnv#on_stdout',
            \ 'on_stderr': 'direnv#on_stderr',
            \ 'on_exit': 'direnv#on_exit' }

function! direnv#job_status_reset() abort
  let s:job_status['stdout'] = []
  let s:job_status['stderr'] = []
endfunction

function! direnv#export() abort
  call s:export_debounced.do()
endfunction

function! direnv#export_core() abort
  if !executable('direnv')
    echom 'No Direnv executable, add it to your PATH'
    return
  endif
  call jobstart(['direnv', 'export', 'vim'], s:job)
endfunction

let s:export_debounced = { 'id': 0, 'counter': 0 }

function! s:export_debounced.call(...)
  let self.id = 0
  let self.counter = 0
  call direnv#export_core()
endfunction

function! s:export_debounced.do()
  call timer_stop(self.id)
  if self.counter < get(g:, 'direnv_max_wait', 5)
    let self.counter = self.counter + 1
    let self.id = timer_start(get(g:, 'direnv_interval', 500), self.call)
  else
    call self.call()
  endif
endfunction
