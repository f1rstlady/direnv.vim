if exists('g:loaded_direnv')
  finish
endif
let g:loaded_direnv = 1

command! -bar -nargs=0 DirenvExport call direnv#export()
command! -bar -nargs=0 EditDirenvrc call direnv#edit#direnvrc()
command! -bar -nargs=0 EditEnvrc    call direnv#edit#envrc()

augroup direnv_rc
  autocmd!
  autocmd VimEnter,DirChanged * DirenvExport
augroup END
