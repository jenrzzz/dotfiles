set completeopt=menu
let g:pymode_python = 'python3'
let g:pymode_folding = 0
let g:pymode_options_max_line_length = 119
let g:pymode_doc = 0
let g:pymode_breakpoint = 0

let g:pymode_lint = 1
let g:pymode_lint_ignore = ["E221","E701","E711","E712"]
let g:pymode_lint_options_pep8 =
      \ {'max_line_length': g:pymode_options_max_line_length}

let g:pymode_rope_goto_definition_bind = '<C-]>'

nnoremap <Leader>rs :Dispatch bin/test --tb=auto %<cr>

syn match pythonConstant "\<[[:upper:]][_[:alnum:]]*" display
syn keyword sqlaQueryMethod begin_nested count commit delete distinct exists filter_by first flush get join one one_or_none order_by outerjoin rollback scalar slice update yield_per value
" hi link pythonConstant Structure
hi link sqlaQueryMethod pythonBuiltinFunc
