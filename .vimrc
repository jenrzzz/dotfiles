" ~/.vimrc
" a mutated mash-up of countless other dotfiles
" by jenrzzz

set nocompatible                " get rid of strict vi compatibility!
set number                      " line numbering on
set autoindent                  " autoindent on
set smartindent                 " smarty
set smarttab
set noerrorbells                " bye bye bells :)
set modeline                    " show what I'm doing
set showmode                    " show the mode on the dedicated line (see above)
set nowrap                      " no wrapping!
set ignorecase                  " search without regards to case
set esckeys                     " Allow cursor keys in insert mode
set backspace=indent,eol,start  " backspace over everything
set encoding=utf-8 nobomb       " Use UTF-8 without byte order marks
set fileformats=unix,dos,mac    " open files from mac/dos
set exrc                        " open local config files
set nojoinspaces                " don't add white space when I don't tell you to
set ruler                       " always show cursor position
set showmatch                   " ensure Dyck language
set incsearch                   " incremental searching
set bs=2                        " fix backspacing in insert mode
set bg=light
set clipboard=unnamed           " Use the OS clipboard by default
set ttyfast                     " Optimize for fast terminal connections

set wildchar=<Tab>
set wildmenu                    " Enhance command-line completion
set wildignore=*.o,*.obj,*~     " ignore this shit when tab completing
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

let mapleader=","               " Change mapleader to comma
set history=100                 " keep 100 lines of command history
set showcmd                     " Show the (partial) command as it's being typed
set noeol                       " Don't add empty newlines at the end of files
set cursorline                  " Highlight the current line

set list                        " Show whitespace
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_ " and use these fancy characters

set scrolloff=3                 " Start scrolling 3 lines before margin
set sidescrolloff=5             " and 5 cols before edge
set sidescroll=1

set nostartofline               " Don't reset cursor to start of line when moving around
set laststatus=2                " Always show status line
set shortmess=atI               " Skip intro message
set title                       " Show filename in titlebar
let &titleold=getcwd()          " Set the xterm title to the cwd on exit

" powerline stuff
let g:Powerline_symbols = 'fancy' " use fancy powerline
let g:Powerline_stl_path_style = 'relative'

" not old sh highlighting
let g:is_bash = 1

" configure when syntastic should run
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['puppet', 'java'] }

" Centralize backups, swapfiles, and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
    set undodir=~/.vim/undo
endif

" Enable all mouse functions if possible
if has('mouse')
    set mouse=a
    set ttymouse=xterm2
endif

" Do sexy folding if we can
" (thanks ryanb)
if has("folding")
    set foldenable
    set foldmethod=syntax
    set foldlevel=1
    set foldnestmax=2
    set foldtext=strpart(getline(v:foldstart),0,50).'\ ...\ '.substitute(getline(v:foldend),'^[\ #]*','','g').'\ '
endif

" Use ack instead of grep if we have it
if executable("ack")
    set grepprg=ack\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
endif

" Default tabbing
set expandtab
set shiftwidth=4
set softtabstop=4

" Show syntax
syntax on

" Edit the temp crontab in place when we do crontab -e
au FileType crontab set nobackup nowritebackup
set backupskip=/tmp/*,/private/tmp/*

"" Keymaps
"" -------
" Don't need a key for help
nmap <F1> <Esc>

" Use Ctrl+P in command mode to insert the path of the currently edited file
" (thanks ryanb)
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" For switching between many opened file by using ctrl+l or ctrl+h
map <C-J> :next <CR>
map <C-K> :prev <CR>

" TComment mappings
nnoremap // :TComment<CR>
vnoremap // :TComment<CR>

" Strip trailing whitespace with ,ss
noremap <leader>ss :call StripWhitespace()<CR>

" Go to the URL in a line with ,go
map <Leader>go :OpenURL

" Use ,gb to show blame
map <Leader>gb :Gblame <CR>

" Use ,on to close all but the active window
map <Leader>on :only <CR>

" Use ,<Left> and ,<Right> to use the left (target parent) or
" right (merge parent) in vimdiff
map <Leader><Left> :diffget //2 <bar> diffupdate <CR>
map <Leader><Right> :diffget //3 <bar> diffupdate <CR>

" Use ,<Up> and ,<Down> to move between change hunks in vimdiff mode
map <Leader><Up> [c
map <Leader><Down> ]c

" Hide search highlighting with ,h
map <Leader>h :set invhls <CR>

" Use ,gw to write the current file to the index and working tree
" (and exit vimdiff mode)
map <Leader>gw :Gwrite <CR>

" Use F7/F8 or ,n/,m to move through tabs.
map <F7> :tabp <CR>
map <F8> :tabn <CR>
map <Leader>n :tabp <CR>
map <Leader>m :tabn <CR>

" Spelling toggle via F10 and F11
map <F10> <Esc>setlocal spell spelllang=en_us<CR>
map <F11> <Esc>setlocal nospell<CR>

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Strip trailing whitespace (,ss) (thanks mathiasbynens)
function! StripWhitespace()
        let save_cursor = getpos(".")
        let old_query = getreg('/')
        :%s/\s\+$//e
        call setpos('.', save_cursor)
        call setreg('/', old_query)
endfunction

" Open a URL with `open` (thanks ryanb)
command -bar -nargs=1 OpenURL :!open <args>
function! OpenURL()
    let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:]*')
    echo s:uri
    if s:uri != ""
        exec "!open \"" . s:uri . "\""
    else
        echo "No URI found in line"
    endif
endfunction

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
Bundle 'tpope/vim-fugitive'
Bundle 'jgdavey/tslime.vim'
Bundle 'scrooloose/syntastic'

" motion, format
Bundle 'goldfeld/vim-seek'
Bundle 'nelstrom/vim-visual-star-search'
Bundle 'surround.vim'
Bundle 'Align'
Bundle 'tComment'

" syntax, filetypes
Bundle 'vim-ruby/vim-ruby'
Bundle 'AndrewRadev/vim-eco'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-rvm'
Bundle 'fsouza/go.vim'
Bundle 'wavded/vim-stylus'
Bundle 'iptables'
Bundle 'othree/html5.vim'
Bundle 'kchmck/vim-coffee-script'
Bundle 'closetag.vim'
Bundle 'derekwyatt/vim-scala'
Bundle 'briancollins/vim-jst'
Bundle 'adimit/prolog.vim'
Bundle 'cup.vim'
Bundle 'sh.vim'
Bundle 'rodjek/vim-puppet'
Bundle 'rake.vim'
Bundle 'PProvost/vim-ps1'
Bundle 'Markdown'
Bundle 'jrk/vim-ocaml'
Bundle 'jQuery'
Bundle 'file-line'
Bundle 'dccmx/vim-lemon-syntax'

" colors
Bundle 'nanotech/jellybeans.vim'

if has('ruby')
    Bundle 'wincent/Command-T'
    let g:CommandTMatchWindowAtTop=1 " show window at top
endif

" Automatic commands (if possible)
if has("autocmd")
    " Automatically do language-depending indenting when possible
    filetype plugin indent on

    " Treat .json files as .js
    autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript

    " Set ft=text for .txt
    autocmd BufNewFile,BufRead *.txt setfiletype text

    " Enable soft-wrapping for text files (thanks ryanb)
    autocmd FileType text,markdown,html,xhtml,eruby setlocal wrap linebreak nolist
    autocmd FileType text,markdown,html,xhtml,eruby set shiftwidth=2
    autocmd FileType text,markdown,html,xhtml,eruby set softtabstop=2
    autocmd FileType text setlocal textwidth=78

    " Reload vimrc after save
    autocmd BufWritePost .vimrc source $MYVIMRC

    " Jump to last known cursor position when editing a file (thanks ryanb)
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif

    if exists("&relativenumber")
        set relativenumber
        au BufReadPost * set relativenumber

        " Use relative numbers except in insert mode or when vim loses focus
        au FocusLost * set number
        au InsertEnter * set number
        au FocusGained * set relativenumber
        au InsertLeave * set relativenumber
    endif

    " Do some default formatting for certain files
    au BufRead,BufNewFile *.s set noexpandtab
    au BufRead,BufNewFile *.s set shiftwidth=8
    au BufRead,BufNewFile *.s set tabstop=8

    au BufRead,BufNewFile *.coffee set shiftwidth=2
    au BufRead,BufNewFile *.coffee set softtabstop=2

    au BufRead,BufNewFile *.rb set shiftwidth=2
    au BufRead,BufNewFile *.rb set softtabstop=2

    au BufRead,BufNewFile *.re2c set ft=c
    au BufRead,BufNewFile *.haml set ft=haml
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
