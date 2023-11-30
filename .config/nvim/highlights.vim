hi link typescriptImport Statement

augroup HighlightNOTE
    autocmd!
    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'NOTE', -1)
augroup END
