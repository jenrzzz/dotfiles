set completeopt=menu
let g:pymode_folding = 0
let g:pymode_options_max_line_length = 119
let g:pymode_doc = 0
let g:pymode_breakpoint = 0

let g:pymode_python = 'python3'
let g:pymode_lint_ignore = "E221,E701,E711"
let g:pymode_lint_options_pep8 =
      \ {'max_line_length': g:pymode_options_max_line_length}

nnoremap <Leader>rs :Dispatch vagrant ssh -c "cd /vagrant && py.test --tb=short -q"<cr>
