" ~/.vimrc
" a mutated mash-up of Lisa McKutcheon and mathiasbynens' dotfiles
" by jenrzzz
" **************************************
" * VARIABLES
" **************************************
set nocompatible                " get rid of strict vi compatibility!
set nu                          " line numbering on
set autoindent                  " autoindent on
set noerrorbells                " bye bye bells :)
set modeline                    " show what I'm doing
set showmode                    " show the mode on the dedicated line (see above)
set nowrap                      " no wrapping!
set ignorecase                  " search without regards to case
set esckeys                     " Allow cursor keys in insert mode
set backspace=indent,eol,start  " backspace over everything
set fileformats=unix,dos,mac    " open files from mac/dos
set exrc                        " open local config files
set nojoinspaces                " don't add white space when I don't tell you to
set ruler                       " which line am I on?
set showmatch                   " ensure Dyck language
set incsearch                   " incremental searching
set bs=2                        " fix backspacing in insert mode
set bg=light
set smarttab
set clipboard=unnamed           " Use the OS clipboard by default
set wildmenu                    " Enhance command-line completion
set ttyfast                     " Optimize for fast terminal connections
set encoding=utf-8 nobomb       " Use UTF-8 without byte order marks

let mapleader=","               " Change mapleader to comma
set binary
set noeol                       " Don't add empty newlines at the end of files
set cursorline                  " Highlight the current line

" Show whitespace
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

set scrolloff=3                 " Start scrolling 3 lines before border
set nostartofline               " Don't reset cursor to start of line when moving around
set laststatus=2                " Always show status line
set shortmess=atI               " Skip intro message
set title                       " Show filename in titlebar
set showcmd                     " Show the (partial) command as it's being typed
let &titleold=getcwd()          " Set the xterm title to the cwd on exit

" powerline stuff
let g:Powerline_symbols = 'fancy' " use fancy powerline
let g:Powerline_stl_path_style = 'relative'

" Centralize backups, swapfiles, and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
    set undodir=~/.vim/undo
endif

if exists("&relativenumber")
    set relativenumber
    au BufReadPost * set relativenumber

    " Use relative numbers except in insert mode or when vim loses focus
    au FocusLost * set number
    au InsertEnter * set number
    au FocusGained * set relativenumber
    au InsertLeave * set relativenumber
endif

if has('mouse')
    set mouse=a
    set ttymouse=xterm2
endif

" Default tabbing
set expandtab
set shiftwidth=4
set softtabstop=4

" Show syntax
syntax on

" Do not expand tabs in assembly file.  Make them 8 chars wide.
au BufRead,BufNewFile *.s set noexpandtab
au BufRead,BufNewFile *.s set shiftwidth=8
au BufRead,BufNewFile *.s set tabstop=8

au BufRead,BufNewFile *.coffee set shiftwidth=2
au BufRead,BufNewFile *.coffee set softtabstop=2

au BufRead,BufNewFile *.rb set shiftwidth=2
au BufRead,BufNewFile *.rb set softtabstop=2

" Edit the temp crontab in place when we do crontab -e
au FileType crontab set nobackup nowritebackup
set backupskip=/tmp/*,/private/tmp/*

" For switching between many opened file by using ctrl+l or ctrl+h
map <C-J> :next <CR>
map <C-K> :prev <CR>

" Use F7/F8 or ,n/,m to move through tabs.
map <F7> :tabp <CR>
map <F8> :tabn <CR>
map <Leader>n :tabp <CR>
map <Leader>m :tabn <CR>

" Spelling toggle via F10 and F11
map <F10> <Esc>setlocal spell spelllang=en_us<CR>
map <F11> <Esc>setlocal nospell<CR>

" setlocal textwidth=80         " used for text wrapping

" Highlight lines that are over 80 characters long in red
" highlight OverLength ctermbg=red ctermfg=white guibg=#ff0808
" match OverLength /\%81v.\+/

" Strip trailing whitespace (,ss)
function! StripWhitespace()
        let save_cursor = getpos(".")
        let old_query = getreg('/')
        :%s/\s\+$//e
        call setpos('.', save_cursor)
        call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

""" BUNDLES
filetype off
set rtp+=~/.vim/bundle/vundle/
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim/

call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'
" ------- User bundles go here ---------
Bundle 'Lokaltog/powerline'
Bundle 'jgdavey/tslime.vim'
Bundle 'scrooloose/nerdtree'

" motion
Bundle 'goldfeld/vim-seek'
Bundle 'surround.vim'

" syntax/filetype/tags
Bundle 'scrooloose/syntastic'
Bundle 'vim-ruby/vim-ruby'
Bundle 'AndrewRadev/vim-eco'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-rvm'
Bundle 'kchmck/vim-coffee-script'
Bundle 'derekwyatt/vim-scala'
Bundle 'briancollins/vim-jst'
Bundle 'adimit/prolog.vim'
Bundle 'rodjek/vim-puppet'
Bundle 'rake.vim'
Bundle 'PProvost/vim-ps1'
Bundle 'Markdown'
Bundle 'Align'
Bundle 'jrk/vim-ocaml'
Bundle 'jQuery'
Bundle 'file-line'
Bundle 'tComment'
Bundle 'closetag.vim'

nnoremap // :TComment<CR>
vnoremap // :TComment<CR>

" colors
Bundle 'nanotech/jellybeans.vim'

if has('ruby')
    Bundle 'wincent/Command-T'
    let g:CommandTMatchWindowAtTop=1 " show window at top
endif

filetype plugin indent on

" Automatic commands
if has("autocmd")
" Treat .json files as .js
    autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
endif

" Set colorscheme last in case a bundle needs to load
try
    colorscheme jellybeans
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme elflord
endtry

" Source extra shortcuts for rails
source $HOME/.vim/test_runners.vim
source $HOME/.vim/rails_shortcuts.vim
