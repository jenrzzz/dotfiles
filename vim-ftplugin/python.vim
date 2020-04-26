set completeopt=menu
nnoremap <Leader>rs :Dispatch bin/test --tb=auto %<cr>

syn match pythonConstant "\<[[:upper:]][_[:alnum:]]*" display
syn keyword sqlaQueryMethod begin_nested count commit delete distinct exists filter_by first flush get join one one_or_none order_by outerjoin rollback scalar slice update yield_per value
" hi link pythonConstant Structure
hi link sqlaQueryMethod pythonBuiltinFunc
