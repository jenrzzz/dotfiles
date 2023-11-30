noremap \ ,

" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>

" Don't need a key for help
nmap <F1> <Esc>

" Command-T but it's fzf now
noremap <leader>t <cmd>lua require("fzf-commands").files()<cr>

" Use C-k or F7 and C-j or F8 to move through buffers
" and C-p/n or F9/F10 to move through quickfix
map <C-J> :bn <CR>
map <C-K> :bp <CR>
map <F7> :bp <CR>
map <F8> :bn <CR>
map <F9> :cp <CR>
map <F10> :cn <CR>
nmap <C-n> :cn<CR>
nmap <C-p> :cp<CR>

" Disable Shift-Up and Shift-Down in insert mode cause I always hit it by accident
inoremap <S-Up> <nop>
inoremap <S-Down> <nop>

"<space>e - open the error window
nmap <space>e :lua vim.diagnostic.open_float()<CR>

"<C-l> - insert a fat arrow
imap <C-l> <space>=><space>

"<C-k> - insert a skinny arrow
imap <C-k> ->

"<leader>on - close all but the active window
map <Leader>on :only <CR>

"<leader>gb - show blame
map <Leader>gb :Git blame <CR>

"<leader>ss - strip trailing whitespace
noremap <leader>ss :call StripWhitespace()<CR>

"<leader>go - go to the URL in a line
map <Leader>go :call OpenURL() <CR>

" Use Ctrl+P in command mode to insert the path of the currently edited file (thanks ryanb)
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

"<leader>cc - highlight current column
nnoremap <leader>cc :call HighlightColumn()<CR>

" https://github.com/stoeffel/.dotfiles/blob/8b44cedde16037d21aa8fcea7bea3e1a173ccfe8/vim/visual-at.vim
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

nnoremap <leader>f :lua require('telescope.builtin').treesitter()<CR>
nnoremap <leader>s :lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>
