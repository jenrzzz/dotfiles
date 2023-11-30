" Jump to last known cursor position when editing a file (thanks ryanb)
autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

if exists("&relativenumber")
  set relativenumber
  au BufReadPost * set rnu

  " Use relative numbers except in insert mode or when vim loses focus
  au FocusLost,InsertEnter * set nu | set nornu
  au FocusGained,InsertLeave * set rnu
endif

autocmd FileType netrw nnoremap <buffer><silent> <Esc> :call <SID>CloseNetrw()<CR>
autocmd FileType netrw nnoremap <buffer><silent> q     :call <SID>CloseNetrw()<CR>

" if argc() == 0
"   file foo.ts
"   set filetype=typescript
"   autocmd VimEnter /Users/jenner/Source/flux/app/* lua vim.lsp.buf.add_workspace_folder("/Users/jenner/Source/flux/app")
" endif
