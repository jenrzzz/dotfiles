" pangloss/vim-javascript
syn keyword jsFunction constructor
hi link jsThis          Structure
hi link jsSuper         Statement
hi link jsExportDefault Include
hi link jsObjectKey     Identifier

" mxw/vim-jsx
hi link xmlAttrib   Identifier
hi link xmlEndTag   Function
let g:jsx_ext_required = 0 " Allow JSX in normal JS files

" othree/javascript-libraries-syntax.vim
syn keyword javascriptRPropsLocal props containedin=ALLBUT,javascriptComment,javascriptLineComment,javascriptString,javascriptTemplate,javascriptTemplateSubstitution
syn keyword javascriptReduxConnect connect containedin=ALLBUT,javascriptComment,javascriptLineComment,javascriptString,javascriptTemplate,javascriptTemplateSubstitution
hi link javascriptRProps        Constant
hi link javascriptRPropsLocal   Identifier
hi link javascriptReduxConnect  Constant
hi link javascriptRPropProps    Type
hi link javascript_functions    Statement
hi link javascript_chaining     NONE
let g:used_javascript_libs = 'underscore,react,chai,d3'
