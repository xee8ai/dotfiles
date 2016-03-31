" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect
set nocompatible

" fire up pathogen
call pathogen#infect()
call pathogen#helptags()

" activate filetype detection
filetype on

" activate internal plugins (e.g. needed for matchit)
filetype plugin on

" redefine leader to comma
" decided not to remap leader => comma is used for backward character
" search
" let mapleader = ","

" status line configuration
set laststatus=2

    " buffer number
    set statusline+=%-3.3n

    " filename (f for filename, F for full path)
    set statusline+=%f
    "set statusline+=%-.100F

    " status flags
    set statusline+=%h%m%r%w

    " filetype
    set statusline+=\ (%Y,

    " encoding
    set statusline+=\ %{strlen(&fenc)?&fenc:'none'},

    " mode
    set statusline+=\ %{&ff})

    " right align remainder
    set statusline+=%=

    " character value
    set statusline+=\ 0x%B

    " position
    set statusline+=\ (%l/%L,%v)\ %p%%

" show relative line numbers in smart mode (current line has absolute
" number); for this behaviour both settings are necessary
set number
set relativenumber

" manual toggle relativenumber
nnoremap <Leader>tn :set relativenumber!<CR>

" in insert mode use only absolute numbers
" commented out: confusing and slow
" autocmd InsertEnter * :set norelativenumber
" autocmd InsertLeave * :set relativenumber

" activate syntax highlighting
syntax on

" hides buffers instead of closing them (can have unwritten changes to a
" file and open a new file using :e , without being forced to write or undo
" your changes first)
set hidden

" tab sizes
set tabstop=4
set softtabstop=4
"set expandtab

" number of spaces for '>>' and '<<'
set shiftwidth=4

" some filetype specific settings (overwrites global ones)
autocmd FileType java set tabstop=4|set shiftwidth=4
autocmd FileType php set tabstop=4|set shiftwidth=4
autocmd FileType python set tabstop=4|set shiftwidth=4|set expandtab
autocmd FileType sh set tabstop=4|set shiftwidth=4
autocmd FileType vim set tabstop=4|set shiftwidth=4|set expandtab

" auto indent depending on filetype
filetype plugin indent on

" temporarily switch to 'paste mode' (in insert) (Vim will switch to paste
" mode, disabling all kinds of smartness and just pasting a whole buffer of
" text.)
set pastetoggle=<F2>

" number of context lines (top and bottom) when scrolling
set scrolloff=3

" emulate behaviour of other editors (right arrow at the end of a line
" sets cursor on next line)
set whichwrap=b,s,<,>,[,]

" search on typing
set incsearch

" highlight all search matches
set hlsearch

" search case insensitive when search term contains only small letters,
" else search case sensitive
set ignorecase
set smartcase

" bash-like tab completion
set wildmode=longest,list
set wildmenu

" fast switches to enable/disable English and German spellchecking
:com DeSpell :exec ":set spell spelllang=de_de"
:com EnSpell :exec ":set spell spelllang=en"
:com NoSpell :exec ":set nospell"

" set folding method
:com Myfold :exec ":set foldmethod=indent"
set foldlevel=2
" if editing python: open file folded; zM closes and zR opens all foldings
autocmd FileType java set foldmethod=indent|set foldlevel=2|set foldnestmax=2|normal zM
autocmd FileType php set foldmethod=indent|set foldlevel=2|set foldnestmax=2|normal zM
autocmd FileType python set foldmethod=indent|set foldlevel=2|set foldnestmax=2|normal zM
autocmd FileType sh set foldmethod=indent|set foldlevel=1|set foldnestmax=1|normal zM
autocmd FileType xml set foldmethod=indent|set foldlevel=4|set foldnestmax=4|normal zM

" add spell checking and automatic wrapping at the recommended 72 columns
" to your git commit messages
autocmd Filetype gitcommit setlocal spell textwidth=72|set colorcolumn=51,52,73,74

" highlight cols (as hint for line length)
" highlight ColorColumn ctermbg=232  guibg=darkblue
"execute "set colorcolumn=" . join(range(81,335), ',')
set colorcolumn=81,101,102,103

" map za (alternate between opening and closing a fold) to spacebar
nnoremap <space> za

" shortcut for _r_emoving _t_railing _w_hitespaces
nnoremap <Leader>rtw :%s/\s\+$//e<CR>

" shortcut for _tabs_ _t_o _s_paces
" don't use substitution because this can move columns
nnoremap <Leader>tts :set expandtab<CR>:retab<CR>

" own extension for syntax highlighting
au BufNewFile,BufFilePre,BufRead *.ini* set filetype=cfg

" interpret .md as markdown (rather than modula2)
" au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" H toggles marking the current line
nnoremap H :set cursorline!<CR> :set cursorcolumn!<cr>

" enable by default
:set cursorline
:set cursorcolumn

" show invisible symbols
:set list

" and define which ones (e.g. :set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<)
" :set listchars=tab:\|\ ,
:set listchars=tab:\ \ ,
" :hi SpecialKey ctermfg=66 guifg=#5f8787

" show trailing spaces as error (in normal mode only)
match ErrorMsg '\s\+$'
autocmd InsertEnter * match none
autocmd InsertLeave * match ErrorMsg '\s\+$'

" a more natural behavior of :split and :vsplit
set splitbelow
set splitright

" change splitted windows using tabulator
map <TAB> <C-w>w

" change splitted window sizes using alt key and arrows
map <a-down> <C-w>+
map <a-up> <C-w>-
map <a-right> <C-w>>
map <a-left> <C-w><

" use CTRL-b to open tagbar and autofocus on it
map <C-b> :TagbarToggle<cr>

" set focus on newly opened tagbar
let g:tagbar_autofocus=1

" redefine fold toggling to space (as it is in global vim)
let tagbar_map_togglefold= "<space>"

" Use CTRL-n to toggle nerdtree (or more correct: nerdtreetabs)
map <C-n> :NERDTreeTabsToggle<CR>

" don't autoopen nerdtree in gvim
let g:nerdtree_tabs_open_on_gui_startup=0

" redefine emmet leader key
let g:user_emmet_leader_key='<C-H>'

" https://github.com/scrooloose/syntastic/issues/703
let g:syntastic_python_checkers = ['pyflakes3']

" prevent autocompiling java files on every save (which makes :w incredibly slow!)
" https://stackoverflow.com/questions/15937042/syntastic-disable-automatic-compilation-of-java
" This is something of a hack, but you can trick Syntastic into not loading
" the javac checker by pretending it's already loaded
let g:loaded_syntastic_java_javac_checker = 1

" start matchit
runtime macros/matchit.vim

" use dark background
set background=dark

" choose colorscheme (/usr/share/vim/vimcurrent/colors/*.vim)
" colorscheme elflord

" use solarized as colorscheme instead of the default ones
" if you are going to use solarized theme on KDE konsole: choose colorscheme
" Solarisiert or Solarisiert Licht in your konsole profile
" if not available: check https://github.com/phiggins/konsole-colors-solarized
colorscheme solarized

" use F5 to toggle solarized background between light and dark
call togglebg#map("<F5>")

" windows related stuff: here we use gvim because powershell integration of
" vim is bad (especially the colors) and not useful (there are no tabs in
" powershell)
if has("win32")

    " set environment
    set encoding=utf-8
    set guifont=Consolas:h9

    " Windows-specific backspace problem
    set backspace=2

    " default cursor line is really ugly
    " highlight CursorLine gui=underline guibg=NONE

    " Open gvim maximized
    au GUIEnter * simalt ~x

    " set path to window's ctags binary
    " download via http://prdownloads.sourceforge.net/ctags/ctags58.zip
    let g:tagbar_ctags_bin='w:\\_ctags\\ctags.exe'

endif
