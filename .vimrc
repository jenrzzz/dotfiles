" ~/.vimrc
" a mutated mash-up of countless other dotfiles
" by jenrzzz

set nocompatible                " get rid of strict vi compatibility!
set hidden                      " allow unsaved background buffers and remember marks/undo for them
set number                      " line numbering on
set autoindent                  " autoindent on
set smartindent                 " smarty
set smarttab
set noerrorbells                " bye bye bells :)
set modeline                    " allow modelines
set modelines=3
set showmode                    " show the mode on the dedicated line (see above)
set nowrap                      " no wrapping!
set ignorecase smartcase        " search without regards to case but be smart about it
set esckeys                     " Allow cursor keys in insert mode
set backspace=indent,eol,start  " backspace over everything
set encoding=utf-8 nobomb       " Use UTF-8 without byte order marks
set fileformats=unix,dos,mac    " open files from mac/dos
set exrc                        " open local config files
set nojoinspaces                " don't add white space when I don't tell you to
set ruler                       " always show cursor position
set showmatch                   " ensure Dyck language
set incsearch                   " incremental searching
set hlsearch
set bs=2                        " fix backspacing in insert mode
set clipboard=unnamed           " Use the OS clipboard by default
set ttyfast                     " Optimize for fast terminal connections

" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=

set wildchar=<Tab>
set wildmenu                    " Enhance command-line completion
set wildmode=longest,list
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
set autoread                    " update open files if they change
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

" Normally, Vim messes with iskeyword when you open a shell file. This can
" leak out, polluting other file types even after a 'set ft=' change. This
" variable prevents the iskeyword change so it can't hurt anyone.
let g:sh_noisk=1

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
set backupdir=~/.vim/backups,~/.tmp,/var/tmp/,/tmp
set directory=~/.vim/swaps,~/.tmp,/var/tmp,/tmp

if exists("&undodir")
    set undodir=~/.vim/undo,~/.tmp,/var/tmp,/tmp
endif

" Enable all mouse functions if possible
if has('mouse')
    set mouse=a
    set ttymouse=xterm2
endif

" Do sexy folding if we can
" (thanks ryanb)
" if has("folding")
"     set foldenable
"     set foldmethod=syntax
"     set foldlevel=1
"     set foldnestmax=2
"     set foldtext=strpart(getline(v:foldstart),0,50).'\ ...\ '.substitute(getline(v:foldend),'^[\ #]*','','g').'\ '
" endif
" 
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
map <Leader>go :call OpenURL() <CR>

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

" Insert a hash rocket with <C-l>
imap <C-l> <space>=><space>

" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>

" MiniBufExpl mappings
map <Leader>be :MBEOpen<cr>
map <Leader>bc :MBEClose<cr>
map <Leader>bt :MBEToggle<cr>

" Buffer splits and stuff
let i = 1
while i <= 9
    execute 'map <Leader>bs' . i . ' :sb' . i . '<cr>'
    execute 'map <Leader>bvs' . i . ' :vert sb' . i . '<cr>'
    let i = i + 1
endwhile

" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion. (thanks garybernhardt)
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
" inoremap <tab> <c-r>=InsertTabWrapper()<cr>
" inoremap <s-tab> <c-n>
" 
" Strip trailing whitespace (,ss) (thanks mathiasbynens)
function! StripWhitespace()
        let save_cursor = getpos(".")
        let old_query = getreg('/')
        :%s/\s\+$//e
        call setpos('.', save_cursor)
        call setreg('/', old_query)
endfunction

" Open a URL with `open` (thanks ryanb)
function! OpenURL()
    let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:]*')
    echo s:uri
    if s:uri != ""
        exec "!open \"" . s:uri . "\""
    else
        echo "No URI found in line"
    endif
endfunction

command! InsertTime :normal a<c-r>=strftime('%F %H:%M:%S.0 %z')<cr>
command! FindConditionals :normal /\<if\>\|\<unless\>\|\<and\>\|\<or\>\|||\|&&<cr>
command! GdiffInTab tabedit %|vsplit|Gdiff
nnoremap <leader>d :GdiffInTab<cr>
nnoremap <leader>D :tabclose<cr>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MAPS TO JUMP TO SPECIFIC COMMAND-T TARGETS AND FILES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>gr :topleft :split config/routes.rb<cr>
function! ShowRoutes()
  " Requires 'scratch' plugin
  :topleft 100 :split __Routes__
  " Make sure Vim doesn't write __Routes__ as a file
  :set buftype=nofile
  " Delete everything
  :normal 1GdG
  " Put routes output in buffer
  :0r! zeus rake -s routes
  " Size window to number of lines (1 plus rake output length)
  :exec ":normal " . line("$") . "_ "
  " Move cursor to bottom
  :normal 1GG
  " Delete empty trailing line
  :normal dd
endfunction
map <leader>t :CommandT<cr>
map <leader>gR :call ShowRoutes()<cr>
map <leader>gv :CommandTFlush<cr>\|:CommandT app/views<cr>
map <leader>gc :CommandTFlush<cr>\|:CommandT app/controllers<cr>
map <leader>gm :CommandTFlush<cr>\|:CommandT app/models<cr>
map <leader>gh :CommandTFlush<cr>\|:CommandT app/helpers<cr>
map <leader>gl :CommandTFlush<cr>\|:CommandT lib<cr>
map <leader>gp :CommandTFlush<cr>\|:CommandT public<cr>
map <leader>gs :CommandTFlush<cr>\|:CommandT public/stylesheets<cr>
map <leader>gf :CommandTFlush<cr>\|:CommandT features<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>
map <leader>gt :CommandTFlush<cr>\|:CommandTTag<cr>
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>F :CommandTFlush<cr>\|:CommandT %%<cr>

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
Bundle 'scratch.vim'
Bundle 'fholgado/minibufexpl.vim'

" motion, format
Bundle 'goldfeld/vim-seek'
Bundle 'nelstrom/vim-visual-star-search'
Bundle 'surround.vim'
Bundle 'Align'
Bundle 'tComment'

" syntax, filetypes
Bundle 'jenrzzz/vim-ruby'
Bundle 'groenewege/vim-less'
Bundle 'AndrewRadev/vim-eco'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-rvm'
Bundle 'tpope/vim-markdown'
Bundle 'yaymukund/vim-rabl'
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
Bundle 'jrk/vim-ocaml'
Bundle 'jQuery'
Bundle 'file-line'
Bundle 'dccmx/vim-lemon-syntax'
Bundle 'evidens/vim-twig'
Bundle 'nono/vim-handlebars'
Bundle 'chase/vim-ansible-yaml'

" colors
Bundle 'jenrzzz/jellybeans.vim'
Bundle 'candy.vim'

if has('ruby')
    Bundle 'wincent/Command-T'
    let g:CommandTMatchWindowAtTop=1 " show window at top
endif

let g:markdown_fenced_languages = ['coffee', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml']

" Automatic commands (if possible)
if has("autocmd")
    " Automatically do language-depending indenting when possible
    filetype plugin indent on

    " Treat .json files as .js
    autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript

    " Set ft=text for .txt
    autocmd BufNewFile,BufRead *.txt setfiletype text

    " Enable soft-wrapping for text files (thanks ryanb)
    autocmd FileType text,markdown,html,xhtml,eruby setlocal wrap linebreak nolist | set shiftwidth=2 | set softtabstop=2
    autocmd FileType text setlocal textwidth=78

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

    au BufRead,BufNewFile *.scss set shiftwidth=2
    au BufRead,BufNewFile *.scss set softtabstop=2
endif

" Set colorscheme last in case a bundle needs to load
set t_Co=256
set bg=dark

try
    colorscheme jellybeans
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme elflord
endtry


" Source extra shortcuts for rails
" source $HOME/.vim/test_runners.vim
" source $HOME/.vim/rails_shortcuts.vim
