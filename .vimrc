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
set lazyredraw

" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=

set wildchar=<Tab>
set wildmenu                    " Enhance command-line completion
set wildmode=longest,list
set wildignore=*.o,*.obj,*~     " ignore this shit when tab completing and in Cmd-T
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif,*.ico
set wildignore+=*.class,*.jar
set wildignore+=*.gz,*.log

let mapleader=","               " Change mapleader to comma
noremap \ ,
set history=100                 " keep 100 lines of command history
set autoread                    " update open files if they change
set showcmd                     " Show the (partial) command as it's being typed
set noeol                       " Don't add empty newlines at the end of files
set cursorline                  " Highlight the current line

set list                        " Show whitespace
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_ " and use these fancy characters

set scrolloff=3                  " Start scrolling 3 lines before margin
set sidescrolloff=5 sidescroll=1 " and 5 cols before edge

set nostartofline               " Don't reset cursor to start of line when moving around
set laststatus=2                " Always show status line
set shortmess=atI               " Skip intro message
set title                       " Show filename in titlebar
let &titleold=getcwd()          " Set the xterm title to the cwd on exit

" Normally, Vim messes with iskeyword when you open a shell file. This can
" leak out, polluting other file types even after a 'set ft=' change. This
" variable prevents the iskeyword change so it can't hurt anyone.
let g:sh_noisk=1

" airline stuff
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" not old sh highlighting
let g:is_bash = 1

" configure when syntastic should run
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['puppet', 'java', 'groovy'] }

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

" Use ack instead of grep if we have it
if executable("ack")
    set grepprg=ack\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
endif

" Default tabbing
set expandtab shiftwidth=2 softtabstop=2

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

" Use ,d to open a diff for the current buffer in a tab
" Use ,D to close it
nnoremap <leader>d :GdiffInTab<cr>
nnoremap <leader>D :tabclose<cr>

" Use C-k or F7 and C-j or F8 to move through buffers and ,n/,m to move through tabs.
map <C-J> :bn <CR>
map <C-K> :bp <CR>
map <F7> :bp <CR>
map <F8> :bn <CR>
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

" Buffer splits and stuff
let i = 1
while i <= 9
    execute 'map <Leader>bs' . i . ' :sb' . i . '<cr>'
    execute 'map <Leader>bvs' . i . ' :vert sb' . i . '<cr>'
    let i = i + 1
endwhile

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MAPS TO JUMP TO SPECIFIC COMMAND-T TARGETS AND FILES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>t :CommandT<cr>
map <leader>gR :call ShowRoutes()<cr>
map <leader>gv :CommandTFlush<cr>\|:CommandT app/views<cr>
map <leader>gc :CommandTFlush<cr>\|:CommandT app/controllers<cr>
map <leader>gm :CommandTFlush<cr>\|:CommandT app/models<cr>
map <leader>gh :CommandTFlush<cr>\|:CommandT app/helpers<cr>
map <leader>gl :CommandTFlush<cr>\|:CommandT lib<cr>
map <leader>gs :CommandTFlush<cr>\|:CommandT spec<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>
map <leader>gt :CommandTFlush<cr>\|:CommandTTag<cr>
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>F :CommandTFlush<cr>\|:CommandT %%<cr>
nmap <silent> <leader>d <Plug>DashSearch

""" BUNDLES
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'
" ------- User bundles go here ---------
Plugin 'bling/vim-airline'
Bundle 'tpope/vim-fugitive'
Bundle 'jgdavey/tslime.vim'
Bundle 'scrooloose/syntastic'
Bundle 'scratch.vim'
Bundle 'tpope/vim-dispatch'
Bundle 'majutsushi/tagbar'

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
Bundle 'ingydotnet/yaml-vim'
Bundle 'chase/vim-ansible-yaml'
Bundle 'mediawiki.vim'
Bundle 'rizzatti/dash.vim'
Bundle 'thoughtbot/vim-rspec'

" colors
Bundle 'jenrzzz/jellybeans.vim'
Bundle 'candy.vim'

if has('ruby')
    Bundle 'wincent/Command-T'
    let g:CommandTMatchWindowAtTop=1 " show window at top
endif

let g:markdown_fenced_languages = ['coffee', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml']
let g:rspec_command = 'Dispatch bundle exec rspec --require="~/.rspec-formatters/vim_formatter.rb" --format VimFormatter --out quickfix.out --format progress {spec}'
let g:dispatch_compilers = { 'bundle exec': '' }

" Automatic commands (if possible)
if has("autocmd")
    " Automatically do language-depending indenting when possible
    filetype plugin indent on

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

    au BufRead,BufNewFile *.txt setfiletype text
    au BufRead,BufNewFile *.re2c setfiletype c
    au BufRead,BufNewFile *.haml setfiletype haml
    au BufRead,BufNewFile *.json setfiletype json syntax=javascript
    au BufRead,BufNewFile *.wiki setfiletype mediawiki

    au BufRead,BufNewFile *.s setlocal noet sw=8 ts=8
    au FileType ruby,coffee,haml,scss,yaml setlocal et sw=2 sts=2
    au FileType text,markdown,mediawiki,html,xhtml,eruby setlocal wrap linebreak nolist sw=2 sts=2
    au FileType markdown,mediawiki,text setlocal tw=78
    au FileType markdown,mediawiki setlocal sw=4 sts=4
    au FileType groovy setlocal sw=4 sts=4
endif

" Set colorscheme last in case a bundle needs to load
set t_Co=256
set bg=dark

try
    colorscheme jellybeans
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme elflord
endtry

" Common typos!
iabbrev attribuet attribute
iabbrev attribuets attributes

