set nocompatible
set title
set number
set cursorline
set ruler
set rulerformat=%l,%v

set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set noexpandtab
set showmatch
set hlsearch
set wrapscan
set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]
set list
set listchars=tab:»\ ,trail:·
set timeoutlen=100

syntax on
colorscheme elflord
highlight LineNr ctermbg=0 ctermfg=7
highlight CursorLineNr cterm=none ctermbg=240 ctermfg=7
highlight CursorLine cterm=none ctermbg=236
highlight SpecialKey ctermfg=245

augroup insert_highlighting
autocmd!
autocmd InsertEnter * highlight CursorLineNr ctermbg=5 ctermfg=0
autocmd InsertLeave * highlight CursorLineNr ctermbg=240 ctermfg=7
autocmd InsertEnter * highlight CursorLine ctermbg=234
autocmd InsertLeave * highlight CursorLine ctermbg=236
augroup END

set fileencodings=utf-8,cp932,euc-jp,latin1