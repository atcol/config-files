function! BuildVimProc(info)
    if a:info.status == 'installed' || a:info.force
        if has('windows')
            !tools\\update-dll-mingw
        else
            !make
        endif
    endif
endfunction

if has('windows')
    call plug#begin('~/vimfiles/plugged')
else
    call plug#begin('~/.vim/plugged')
endif
" Plug 'sheerun/vim-wombat-scheme'    "Colorscheme
" Plug 'tomasr/molokai'               "Colorscheme
" Plug 'Shougo/vimfiler.vim'          "Tree file browser
" Plug 'Shougo/unite.vim'             "Search
Plug 'vim-airline/vim-airline'      "Buffer list and bottom bar
Plug 'xolox/vim-session'            "Save and load sessions
Plug 'xolox/vim-misc'
" Plug 'xolox/vim-shell'
Plug 'tpope/vim-fugitive'           "Git
" Plug 'tpope/vim-repeat'
" Plug 'tpope/vim-surround'           "Surround things with characters
" Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/syntastic'
Plug 'majutsushi/tagbar'
" Plug 'jpalardy/vim-slime'
Plug 'kien/ctrlp.vim'               "File/buffer search
Plug 'airblade/vim-gitgutter'       "Git changes column
" Plug 'Shougo/context_filetype.vim'
" Plug 'Shougo/vimproc.vim',  { 'do': function('BuildVimProc') }
" Autocompletion
" if has('nvim')
    " Plug 'Shougo/deoplete.nvim'       "Autocompletion for neovim
" else 
    " Plug 'Shougo/neocomplete.vim'       "Autocompletion - Needs lua
" endif
" Nix
Plug 'LnL7/vim-nix'
" Javascript
" Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
Plug 'pangloss/vim-javascript'
Plug 'maksimr/vim-jsbeautify'
"Plug 'othree/jspc.vim'
" Lisp
Plug 'slimv.vim'
" HTML and HTML templating
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
Plug 'pbrisbin/html-template-syntax'
Plug 'digitaltoad/vim-jade'
Plug 'mustache/vim-mustache-handlebars'
" Haskell
Plug 'raichoo/haskell-vim'
Plug 'eagletmt/ghcmod-vim'
Plug 'eagletmt/neco-ghc'
" Scala
Plug 'derekwyatt/vim-scala'
" Rust
Plug 'rust-lang/rust.vim'
" Ansible
Plug 'pearofducks/ansible-vim'
" Markdown
Plug 'plasticboy/vim-markdown'

call plug#end()
let $GIT_SSL_NO_VERIFY = 'true'

if has('gui_running')
    set guioptions-=L
    set guioptions-=T
    set guioptions-=m
endif

nnoremap <C-K> :bnext<CR>
nnoremap <C-J> :bprev<CR>

command! Bd bp | sp | bn | bd
nnoremap <C-W> :Bd<CR>

"Don't autoload sessions, but autosave on exit and periodically
let g:session_autosave='yes'
let g:session_autosave_periodic=2
let g:session_autoload='no'

"Use filename rather than full path in airline buffer list
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

"Neocomplete
let g:neocomplete#enable_auto_close_preview = 1
"Neocomplete java
let g:EclimCompletionMethod = 'omnifunc'
let g:neocomplete#enable_at_startup = 1
let g:deoplete#enable_at_startup = 1

if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.java = '\%(\h\w*\|)\)\.\w*'
"Neocomplete javascript
let g:neocomplete#force_omni_input_patterns.javascript = '[^. \t]\.\w*'

"ignore same files git ignores in CtrlP
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']

" Vimfiler don't jump to first child
let g:vimfiler_expand_jump_to_first_child = 0

set hidden
set noswapfile

let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python'

set nocompatible
filetype plugin indent on

autocmd! bufwritepost .vimrc source %
set pastetoggle=<F2>
map <F3> :VimFilerCurrentDir -explorer -auto-expand<CR>
set clipboard=unnamed
set number
syntax on
set omnifunc=syntaxcomplete#Complete
set wildmode=longest:list
set wildmenu
set history=1000
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent
set smarttab
set textwidth=0
set ruler
set confirm
set mouse+=a
set visualbell
set backspace=indent,eol,start
set shiftround
set nostartofline
set t_Co=256
set fileformat=unix
set fileformats=unix,dos
let g:neocomplete#enable_at_startup = 1
if has('gui_running')
    colorscheme desert
else
    colorscheme desert
endif
if has('gui_running')
    if has('gui_win32')
        set guifont=ProFontWindows
    endif
endif
set pdev=pdf
set printoptions=paper:A4,syntax:y,wrap:y,duplex:long
set hlsearch
set nofoldenable
vnoremap > >gv
vnoremap < <gv
"if has("gui_running")
"    set guioptions+=LlRrb
"    set guioptions-=LlRrb
"    set guioptions-=m
"    set guioptions-=T
"endif
" Unbind the cursor keys in insert, normal and visual modes.
for prefix in ['i', 'n', 'v']
    for key in ['<Up>', '<Down>', '<Left>', '<Right>']
        exe prefix . "noremap " . key . " <Nop>"
    endfor
endfor

"nnoremap <esc> :noh<return><esc>

"highlight columns past 80
let &colorcolumn=join(range(81,999),",")
highlight ColorColumn ctermbg=235 guibg=#2c2d27

"Fortran
let fortran_free_source=1

"Vala
autocmd BufRead *.vala,*.vapi set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
au BufRead,BufNewFile *.vala,*.vapi setfiletype vala

"Haskell
let g:necoghc_enable_detailed_browse = 1 "Show types in completion suggestions
nmap <silent> <leader>ht :GhcModType<CR>
nmap <silent> <leader>hT :GhcModTypeInsert<CR>
let g:slime_target = "tmux"
let g:slime_paste_file = tempname()
nmap <F8> :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_type_haskell = {
    \ 'ctagsbin'  : 'hasktags',
    \ 'ctagsargs' : '-x -c -o-',
    \ 'kinds'     : [
        \  'm:modules:0:1',
        \  'd:data: 0:1',
        \  'd_gadt: data gadt:0:1',
        \  't:type names:0:1',
        \  'nt:new types:0:1',
        \  'c:classes:0:1',
        \  'cons:constructors:1:1',
        \  'c_gadt:constructor gadt:1:1',
        \  'c_a:constructor accessors:1:1',
        \  'ft:function types:1:1',
        \  'fi:function implementations:0:1',
        \  'o:others:0:1'
    \ ],
    \ 'sro'        : '.',
    \ 'kind2scope' : {
        \ 'm' : 'module',
        \ 'c' : 'class',
        \ 'd' : 'data',
        \ 't' : 'type'
    \ },
    \ 'scope2kind' : {
        \ 'module' : 'm',
        \ 'class'  : 'c',
        \ 'data'   : 'd',
        \ 'type'   : 't'
    \ }
\ }

"Javascript
"autocmd Filetype javascript setlocal ts=2 sw=2 sts=0 noexpandtab
let g:syntastic_javascript_checkers = ['eslint']

"Organise AMD-style javascript imports
function! AmdImports()
    execute "normal! gg0:%s/'\\_s*\]/'\\r\]\<cr>"
    execute "normal! gg0:%s/define\\s*\(\\s*\\\[\\_s*'/define(\[\\r    '\<cr>"
    execute "normal! \<s-v>/\]\<cr>k"
    execute "normal! :s/'\\_s*,\\_s*'/',\\r    '/g\<cr>"
    execute "normal! /\]\<cr>kA,\<esc>"
    execute "normal! gg0/define\\s*\(\\s*\\\[\\_s*'\<cr>j"
    execute "normal! \<s-v>/\]\<cr>k:sort\<cr>"
    execute "normal! /\]\<cr>kA\<backspace>\<esc>"
    execute "normal! gg0:%s/\]\\_s*,\\_s*function\\_s*\(\\\(\[^)\]\\|\\_s\\\)*\)/\], function\(\\r\)/\<cr>"
    execute "normal! gg0/define\\s*\(\\s*\\\[\\_s*'\<cr>j"
    execute "normal! \<s-v>/\]\<cr>k"
    execute "normal! y/\], function\(\<cr>p"
    execute "normal! \<s-v>/\)\<cr>k:s/'\[a-zA-Z.\\\/_\]*\\\/\\\(\[a-zA-Z_\]*\\\)'/\\1/g\<cr>"
    execute "normal! gg0/\], function\(\<cr>"
    execute "normal! \<s-v>/\)\<cr>k:s/'\[a-zA-Z.\\\/!_\]*\\\/\\\(\[a-zA-Z_\]*\\\).\\\([a-zA-Z\]*\\\)'/\\1\\U\\2/g\<cr>"
endfunction

"ignore same files git ignores in CtrlP
"let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co
"--exclude-standard', 'find %s -type f']
""Search from current directory instead of project root
let g:ctrlp_working_path_mode = 0

