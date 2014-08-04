
if exists('g:vim_build_loaded')
  finish
endif
let g:vim_build_loaded = 1

let s:plugin_path = escape(expand('<sfile>:p:h'), '\')
let s:fpath = fnameescape(s:plugin_path)

function! ProjectExe(command)
    execute ":! " . s:fpath . "/project-exec.sh \"%\" \"" . a:command . "\""
endfunction

command! Build :call ProjectExe(s:fpath . "/build.sh")
command! Run   :call ProjectExe(s:fpath . "/build.sh r")


