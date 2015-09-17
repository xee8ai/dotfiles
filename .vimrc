" =======================================
" SETTINGS
" =======================================

	" Use Vim settings, rather then Vi settings (much better!).
	" This must be first, because it changes other options as a side effect
	set nocompatible

	" fire up pathogen
	call pathogen#infect()
	call pathogen#helptags()

	" activate filetype detection
	filetype on

	" status line configuration
	set laststatus=2
	set statusline=
	set statusline+=%-3.3n				" buffer number
	set statusline+=%f					" filename
	set statusline+=%h%m%r%w			" status flags
	set statusline+=%=					" right align remainder
	set statusline+=0x%-8B				" character value
	set statusline+=%-14(%l,%c%V%)		" line, character
	set statusline+=%<%P				" file position

	" show relative line numbers in smart mode (current line has absolute
	" number); for this behaviour both settings are necessary
	set number
	set relativenumber

	" in insert mode use only absolute numbers
	autocmd InsertEnter * :set norelativenumber
	autocmd InsertLeave * :set relativenumber

	" activate syntax highlighting
	syntax on

	" for dark background
	set background=dark

	" choose colorscheme (/usr/share/vim/vimcurrent/colors/*.vim)
	" set t_Co=256 => problem on virtual consoles
	colorscheme elflord

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
	autocmd FileType php set tabstop=4|set shiftwidth=4|set expandtab
	autocmd FileType python set tabstop=4|set expandtab

	" auto indent depending on filetype
	filetype plugin indent on

	" temporarily switch to “paste mode” (in insert) (Vim will switch to paste
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

	" set folding method
	:com Myfold :exec ":set foldmethod=indent"
	set foldlevel=2
	" if editing python: open file folded; zM closes and zR opens all foldings
	autocmd FileType python set foldmethod=indent|set foldlevel=2|set foldnestmax=2|normal zM

	" add spell checking and automatic wrapping at the recommended 72 columns
	" to your commit messages
	autocmd Filetype gitcommit setlocal spell textwidth=72

	" highlight cols (as hint for line length)
	highlight ColorColumn ctermbg=232  guibg=darkblue
	"execute "set colorcolumn=" . join(range(81,335), ',')
	set colorcolumn=81,101,102,103

	" map za (alternate between opening and closing a fold) to spacebar
	nnoremap <space> za

	" own extension for syntax highlighting
	au BufReadPost *.ini* set syntax=cfg

	" H toggles marking the current line
	nnoremap H :set cursorline!<CR>

	" show invisible symbols
	:set list
	" and define which ones (e.g. :set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<)
	" trailing space is needed!
	:set listchars=tab:\|\ 

	" show trailing spaces as error (in normal mode only)
	match ErrorMsg '\s\+$'
	autocmd InsertEnter * match none
	autocmd InsertLeave * match ErrorMsg '\s\+$'

	" change windows using tabulator
	map <TAB> <C-w>w

	" change window sizes using alt key and arrows
	map <a-down> <C-w>+
	map <a-up> <C-w>-
	map <a-right> <C-w>>
	map <a-left> <C-w><

	" Use CRTL-N to toggle nerdtree (or more correct: nerdtreetabs)
	map <C-n> :NERDTreeTabsToggle<CR>
