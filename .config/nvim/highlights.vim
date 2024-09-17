" set termguicolors
hi link typescriptImport Statement

" Make floating errors readable
hi DiagnosticFloatingError ctermbg=Black
hi NormalFloat ctermbg=Black

augroup HighlightNOTE
    autocmd!
    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'NOTE', -1)
augroup END

highlight! Comment cterm=italic gui=italic
