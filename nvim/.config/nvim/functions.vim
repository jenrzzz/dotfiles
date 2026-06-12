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
function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
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

function HighlightColumn()
  let cursor_pos = getpos('.')
  let &colorcolumn=cursor_pos[2]
endfunction


command! InsertTime :normal a<c-r>=strftime('%F %H:%M:%S.0 %z')<cr>
command! FindConditionals :normal /\<if\>\|\<unless\>\|\<and\>\|\<or\>\|||\|&&<cr>
command! GdiffInTab tabedit %|vsplit|Gdiff
