" base config
set number
set nowrap
set cursorline
set scrolloff=3 sidescrolloff=5
set expandtab shiftwidth=2 softtabstop=2
set list
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set clipboard=unnamedplus
set shortmess=atI
set title
let &titleold=getcwd()
let mapleader=","

set showmatch
set smartindent
set ignorecase smartcase
set incsearch hlsearch
set wildignore=*.o,*.obj,*~,*.pyc,*.map
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

if executable("ag")
  set grepprg=ag\ --vimgrep\ $*
  set grepformat=%f:%l:%c:%m
endif

" plugins
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
lua require("setup")
lua require("lspconfigs")

" after plugins are loaded
runtime functions.vim
filetype on

try
    if !empty($ITERM_PROFILE) && ($ITERM_PROFILE == 'Light')
        set background=light
        colorscheme PaperColor
        let g:airline_theme='papercolor'
    else
      set background=dark
      colorscheme jellybeans
      let g:airline_theme = 'jellybeans'
      let g:jellybeans_use_term_italics = 1
    endif
catch /^Vim\%((\a\+)\)\=:E185/
  set background=dark
  colorscheme elflord
endtry

runtime mappings.vim
runtime highlights.vim

if has("autocmd")
  runtime autocommands.vim
endif
