" ~/.vimrc
" a mutated mash-up of countless other dotfiles
" by jenrzzz

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
" set lazyredraw
" set regexpengine=1              " engine 0 is slow with syntax highlighting

" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=

set wildchar=<Tab>
set wildignore=*.o,*.obj,*~,*.pyc,*.map     " ignore this shit when tab completing and in Cmd-T
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=vendor/rails/*
set wildignore+=vendor/cache/*
set wildignore+=*.gem
set wildignore+=*/log/*
set wildignore+=*/tmp/*
set wildignore+=*/node_modules/*
set wildignore+=*/dist/*,*/public/*
set wildignore+=*/.ropeproject/*
set wildignore+=*.png,*.jpg,*.gif,*.ico
set wildignore+=*.class,*.jar
set wildignore+=*.gz,*.log
set wildmenu                    " Enhance command-line completion
set wildmode=longest,list

set history=100                 " keep 100 lines of command history
set autoread                    " update open files if they change
set showcmd                     " Show the (partial) command as it's being typed
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

" airline stuff
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" not old sh highlighting
let g:is_bash = 1

" configure when syntastic should run
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['puppet', 'java', 'groovy'] }
let g:syntastic_python_python_exec = '/usr/local/bin/python3'

" Centralize backups, swapfiles, and undo history
set backupdir=~/.vim/backups,~/.tmp,/var/tmp/,/tmp
set directory=~/.vim/swaps,~/.tmp,/var/tmp,/tmp

if exists("&undodir")
    set undodir=~/.vim/undo,~/.tmp,/var/tmp,/tmp
endif

" Enable all mouse functions if possible
if has('mouse')
    set mouse=a
endif

" Use ag instead of grep if we have it
if executable("ag")
  set grepprg=ag\ --vimgrep\ $*
  set grepformat=%f:%l:%c:%m
endif

" Default tabbing
set expandtab shiftwidth=2 softtabstop=2

" Show syntax
syntax on

set backupskip=/tmp/*,/private/tmp/*

" Buffer splits and stuff
let i = 1
while i <= 9
    execute 'map <Leader>bs' . i . ' :sb' . i . '<cr>'
    execute 'map <Leader>bvs' . i . ' :vert sb' . i . '<cr>'
    let i = i + 1
endwhile

" Strip trailing whitespace (,ss) (thanks mathiasbynens)
function StripWhitespace()
        let save_cursor = getpos(".")
        let old_query = getreg('/')
        :%s/\s\+$//e
        call setpos('.', save_cursor)
        call setreg('/', old_query)
endfunction

" Open a URL with `open` (thanks ryanb)
function OpenURL()
    let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:]*')
    echo s:uri
    if s:uri != ""
        exec "!open \"" . s:uri . "\""
    else
        echo "No URI found in line"
    endif
endfunction

" https://github.com/stoeffel/.dotfiles/blob/8b44cedde16037d21aa8fcea7bea3e1a173ccfe8/vim/visual-at.vim
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>
function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction


command! InsertTime :normal a<c-r>=strftime('%F %H:%M:%S.0 %z')<cr>
command! FindConditionals :normal /\<if\>\|\<unless\>\|\<and\>\|\<or\>\|||\|&&<cr>
command! GdiffInTab tabedit %|vsplit|Gdiff

" alternate.vim bindings
command! A Open(alternate#FindAlternate())
command! AS OpenHorizontal(alternate#FindAlternate())
command! AV OpenVertical(alternate#FindAlternate())


""" BUNDLES
set nocompatible
filetype on
filetype off
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Language server
Plugin 'neovim/nvim-lspconfig'
Plugin 'ray-x/guihua.lua'
Plugin 'ray-x/navigator.lua'
Plugin 'nvim-treesitter/nvim-treesitter'
Plugin 'j-hui/fidget.nvim'
Plugin 'nvim-lua/popup.nvim'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'nvim-telescope/telescope.nvim'
Plugin 'MunifTanjim/nui.nvim'
Plugin 'nvim-telescope/telescope-file-browser.nvim'

" interface
Plugin 'bling/vim-airline'                " Fancy statusline and buffer list

" motion, format
Plugin 'easymotion/vim-easymotion'
let g:EasyMotion_do_mapping = 0 " Disable default mappings
" " Jump to anywhere you want with minimal keystrokes, with just one key binding.
" " `s{char}{label}`
" nmap s <Plug>(easymotion-overwin-f)
" " or
" " `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap <Space><Space> <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

Plugin 'goldfeld/vim-seek'                " Seek motion (s); like f but takes two characters to jump to
Plugin 'nelstrom/vim-visual-star-search'  " Search for text selected in visual mode with '*' or '#'
Plugin 'surround.vim'                     " Surrounding text object (e.g. change {} to [] with cs{[ ...)
Plugin 'tComment'                         " // to comment/uncomment line in normal mode
Plugin 'Align'                            " :AlignCtrl and :Align for quickly aligning blocks (e.g. aligning assignments on equal signs)

" extensions
Plugin 'scrooloose/syntastic'             " Fancy syntax checking
Plugin 'jgdavey/tslime.vim'               " Send commands from vim to a running tmux session
Plugin 'Olical/vim-enmasse'               " Edit every line in a quickfix list at the same time
Plugin 'tpope/vim-dispatch'               " Asynchronous build and test dispatcher
Plugin 'tpope/vim-fugitive'               " Fancy git integration
Plugin 'tommcdo/vim-fugitive-blame-ext'   " Add support for showing commit message on statusline in fugitiveblame buffers
Plugin 'gerw/vim-HiLinkTrace'             " Highlighting/syntax debugging with <Leader>hlt
Plugin 'file-line'                        " Enable opening file:line filenames, like `vim index.html:20`
Plugin 'scratch.vim'                      " Create a scratch buffer with :Scratch
Plugin 'compactcode/alternate.vim'        " Find alternate files with alternate#FindAlternate()
Plugin 'compactcode/open.vim'             " Open files that were found by an external command.
Plugin 'rizzatti/dash.vim'                " Search Dash.app for term with <Plug>DashSearch
Plugin 'triglav/vim-visual-increment'     " use CTRL+A/X to create increasing sequence of numbers or letters via visual mode
Plugin 'wincent/Command-T'
Plugin 'dpayne/CodeGPT.nvim'              " :Chat
Plugin 'github/copilot.vim'
Plugin 'farseer90718/vim-taskwarrior'

let g:CommandTPreferredImplementation='ruby'
let g:CommandTMatchWindowAtTop=1 " show window at top

" -- language plugins --
" system
Plugin 'iptables'

" shell
Plugin 'sh.vim'
Plugin 'PProvost/vim-ps1'

" text
Plugin 'tpope/vim-markdown'
Plugin 'mediawiki.vim'

" ruby
let g:ruby_host_prog = '~/.rbenv/versions/3.2.0/bin/neovim-ruby-host'
Plugin 'jenrzzz/vim-ruby'
Plugin 'rake.vim'
Plugin 'thoughtbot/vim-rspec'
Plugin 'ingydotnet/yaml-vim'
Plugin 'tpope/vim-rails'

" python
" Plugin 'python-mode/python-mode'
" Plugin '5long/pytest-vim-compiler'

" javascript
Plugin 'neoclide/vim-jsx-improve'
" Plugin 'rschmukler/pangloss-vim-indent'
Plugin 'nono/vim-handlebars'
Plugin 'kchmck/vim-coffee-script'
" Plugin 'ternjs/tern_for_vim'
" Plugin 'leafgarland/typescript-vim'

" css/html
Plugin 'othree/html5.vim'
Plugin 'tpope/vim-haml'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'groenewege/vim-less'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'closetag.vim'         " Close the most recent SGML tag with <C-_>

" colors
Plugin 'vim-airline/vim-airline-themes'
Plugin 'jenrzzz/jellybeans.vim'
Plugin 'morhetz/gruvbox'
Plugin 'tomasr/molokai'
Plugin 'hzchirs/vim-material'
Plugin 'NLKNguyen/papercolor-theme'

Plugin 'rust-lang/rust.vim'
Plugin 'delphinus/vim-firestore'
Plugin 'prisma/vim-prisma'
Plugin 'hashivim/vim-terraform'

call vundle#end()
lua require'navigator'.setup({transparency = 0, icons = { icons = false }, lsp = { format_on_save = false }})

let g:markdown_fenced_languages = ['coffee', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml']
let g:rspec_command = 'Dispatch bundle exec rspec {spec}'
let g:dispatch_compilers = { 'bundle exec': '', 'bin/test': 'pytest' }
let g:pymode_rope = 1
let g:pymode_python = 'python3'
let g:pymode_rope_lookup_project = 0
let g:pymode_rope_autoimport = 0
let g:pymode_rope_regenerate_on_write = 0
let g:pymode_folding = 0
let g:pymode_options_max_line_length = 119
let g:pymode_doc = 0
let g:pymode_breakpoint = 0

let g:pymode_lint = 1
let g:pymode_lint_ignore = ["E221","E701","E711","E712"]
let g:pymode_lint_options_pep8 =
      \ {'max_line_length': g:pymode_options_max_line_length}

let g:pymode_rope_goto_definition_bind = '<C-]>'

function SaveTmuxWindowTitle()
  if !exists("g:tmux_last_title")
    let g:tmux_last_title = substitute(system("tmux display-message -p '#W'"), '\n\+$', '', '')
  endif
endfunction

function SetTmuxWindowTitle()
  call SaveTmuxWindowTitle()
  call system("tmux rename-window " . strpart(expand("%:t"), 0, 25))
endfunction

function RestoreTmuxWindowTitle()
  try
    echom g:tmux_last_title
    if g:tmux_last_title == "bash"
      call system("tmux setw automatic-rename")
    else
      call system("tmux rename-window " . g:tmux_last_title)
    endif
  catch /.*/
  endtry
endfunction

function HighlightColumn()
  let cursor_pos = getpos('.')
  let &colorcolumn=cursor_pos[2]
endfunction

function EnableTypeScriptAlternates()
  let b:alternate_test_token          = ".test"
  let b:alternate_test_token_location = "$"
  let b:alternate_source_dirs = ".."
  let b:alternate_test_dirs  = ".."
  let b:alternate_enabled = 1
endfunction

function EnableTypeScriptReactAlternates()
  let b:alternate_test_token          = ".test"
  let b:alternate_test_token_location = "$"
  let b:alternate_source_dirs = "%:h"
  let b:alternate_test_dirs  = "%:h"
  let b:alternate_enabled = 1
endfunction

function! s:CloseNetrw() abort
  for bufn in range(1, bufnr('$'))
    if bufexists(bufn) && getbufvar(bufn, '&filetype') ==# 'netrw'
      silent! execute 'bwipeout ' . bufn
      if getline(2) =~# '^" Netrw '
        silent! bwipeout
      endif
      return
    endif
  endfor
endfunction

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

    au VimEnter,BufEnter * call SetTmuxWindowTitle()
    au VimLeave * call RestoreTmuxWindowTitle()

    au BufRead,BufNewFile *.txt setfiletype text
    au BufRead,BufNewFile *.re2c setfiletype c
    au BufRead,BufNewFile *.haml setfiletype haml
    au BufRead,BufNewFile *.json setfiletype json syntax=javascript
    au BufRead,BufNewFile *.wiki setfiletype mediawiki
    au BufRead,BufNewFile *.es6 setfiletype javascript
    au BufRead,BufNewFile *.mscss setfiletype scss
    au BufRead,BufNewFile *.mcss setfiletype css
    au BufRead,BufNewFile Procfile* setfiletype yaml
    au BufRead,BufNewFile *.axlsx setfiletype ruby

    au BufRead,BufNewFile *.s setlocal noet sw=8 ts=8
    au FileType ruby,coffee,haml,scss,yaml setlocal et sw=2 sts=2
    au FileType typescript,typescriptreact  setlocal et sw=4 sts=4
    au FileType text,markdown,mediawiki,html,xhtml,eruby setlocal wrap linebreak nolist sw=2 sts=2
    au FileType markdown,mediawiki,text setlocal tw=78
    au FileType markdown,mediawiki setlocal sw=4 sts=4
    au FileType groovy setlocal sw=4 sts=4
    au FileType php setlocal sw=4 sts=4 ts=4

    " au FileType typescript call EnableTypeScriptAlternates()
    " au FileType typescriptreact call EnableTypeScriptReactAlternates()

    autocmd FileType netrw nnoremap <buffer><silent> <Esc> :call <SID>CloseNetrw()<CR>
    autocmd FileType netrw nnoremap <buffer><silent> q     :call <SID>CloseNetrw()<CR>
endif

" Set colorscheme last in case a bundle needs to load
set t_Co=256

try
    if !empty($ITERM_PROFILE) && ($ITERM_PROFILE == 'Light')
        set background=light
        colorscheme PaperColor
        let g:airline_theme='papercolor'
    else
      set background=dark
      colorscheme jellybeans
      let g:airline_theme = 'jellybeans'
    endif
catch /^Vim\%((\a\+)\)\=:E185/
  set background=dark
  colorscheme elflord
endtry

" Common typos!
iabbrev attribuet attribute
iabbrev attribuets attributes

let mapleader=","               " Change mapleader to comma
noremap \ ,

"" Keymaps
"" -------
" Don't need a key for help
nmap <F1> <Esc>

" Use Ctrl+P in command mode to insert the path of the currently edited file
" (thanks ryanb)
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" TComment mappings
nnoremap // :TComment<CR>
vnoremap // :TComment<CR>

" Strip trailing whitespace with ,ss
noremap <leader>ss :call StripWhitespace()<CR>

" Go to the URL in a line with ,go
map <Leader>go :call OpenURL() <CR>

" Use ,gb to show blame
map <Leader>gb :Git blame <CR>

" Use ,on to close all but the active window
map <Leader>on :only <CR>

" Use ,<Left> and ,<Right> to use the left (target parent) or
" right (merge parent) in vimdiff
map <Leader><Left> :diffget //2 <bar> diffupdate <CR>
map <Leader><Right> :diffget //3 <bar> diffupdate <CR>

" Use ,<Up> and ,<Down> to move between change hunks in vimdiff mode
map <Leader><Up> [c
map <Leader><Down> ]c

" Disable Shift-Up and Shift-Down in insert mode cause I always hit it by accident
inoremap <S-Up> <nop>
inoremap <S-Down> <nop>

" Use C-k or F7 and C-j or F8 to move through buffers and ,n/,m to move through tabs.
" and F8/F9 to move through quickfix
map <C-J> :bn <CR>
map <C-K> :bp <CR>
map <F7> :bp <CR>
map <F8> :bn <CR>
map <F9> :cp <CR>
map <F10> :cn <CR>
map <Leader>n :tabp <CR>
map <Leader>m :tabn <CR>

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Insert a hash rocket with <C-l>
imap <C-l> <space>=><space>

" Insert arrow with <C-k>
imap <C-k> ->

" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>

" Search for term in Dash with ,ds
nmap <silent> <leader>ds <Plug>DashSearch
nmap <C-n> :cn<CR>
nmap <C-p> :cp<CR>

" Highlight current column with ,cc
nnoremap <leader>cc :call HighlightColumn()<CR>

" Make floating errors readable
highlight DiagnosticFloatingError guibg='Black'
nmap <space>e :lua vim.diagnostic.open_float()<CR>

" telescope
lua require("guihua.listview").opts = { transparency = nil }
lua require("telescope").load_extension "file_browser"
nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>fs :Telescope treesitter<CR>
nnoremap <leader>g :Telescope live_grep<CR>
nnoremap <leader>h :Telescope git_bcommits<CR>

map <leader>t :CommandT<cr>
lua vim.highlight.priorities.semantic_tokens = 5

augroup HighlightNOTE
    autocmd!
    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'NOTE', -1)
augroup END
