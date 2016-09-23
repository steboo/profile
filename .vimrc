" .vimrc
"
" A widely compatible vim 7+ initialization file. Useful if one needs to log
" into a wide variety of machines that might not have all of the features that
" exist on a primary developer machine.
"
" Tested on
"  * VIM 7.0 Tiny Linux
"  * VIM 7.2 Huge Linux
"  * VIM 7.4 Huge Linux
"  * VIM 7.4 Big Win32
"  * GVIM 7.4 Big Win32
"  * GVIM 8.0 Huge Win32

" -----------------
" Editor behavior
" -----------------

" Tabs or whitespace
set expandtab
set smarttab
set shiftwidth=2
set tabstop=2
set textwidth=80

" Indentation
set autoindent
if has('cindent')
    set cindent
elseif has('smartindent')
    set smartindent
endif

" Join comment lines
if v:version > 703 || v:version == 703 && has('patch541')
    set formatoptions+=j
endif

" Do not automatically wrap lines
set nowrap


" ----------
" Encoding
" ----------

" On Windows, encoding will default to latin1 (code page 1252). To support
" Unicode files, we'll want to change this to something in Unicode.
" On Linux, encoding will default to something based on $LANG (typically utf-8)
if has('multi_byte')
    if has('gui_gtk2')
        " The help file recommends setting the encoding for GTK+ 2 to utf-8.
        set encoding=utf-8
    elseif has('gui_running') && has('win32') && &encoding ==# 'latin1'
        " We want vim to support Unicode.
        set encoding=utf-8
    endif

    " Default to no BOM, since most files are UTF-8. Note that this will remove
    " BOMs from open files if you source $MYVIMRC.
    if &encoding ==# 'utf-8'
        set nobomb
    endif
endif


" ---------
" Plugins
" ---------

" Pathogen - https://github.com/tpope/vim-pathogen
if has('win32') && filereadable(expand('~/vimfiles/autoload/pathogen.vim'))
    execute pathogen#infect()
elseif filereadable(expand('~/.vim/autoload/pathogen.vim'))
    execute pathogen#infect()
endif

" Use filetype detection and plugin/indent files
filetype plugin indent on

if has('autocmd')
    augroup filetype_textwidth_exceptions
        autocmd!

        " PEP 8 specifies 79 as the maximum line length in Python
        autocmd FileType python setlocal textwidth=79

        " PSR-2 specifies 120 as the soft limit for line length in PHP
        autocmd FileType php setlocal textwidth=120

        " Scala - many style guides (Kafka, Spark, Twitter) suggest a column
        " limit of 100
        autocmd FileType scala setlocal textwidth=100
    augroup END
endif


" --------------
" Line endings
" --------------

" Default to Unix line endings generally
set fileformats=unix,dos

" Default to Unix line endings even in a new instance on Windows
if has('win32') && (v:version < 704 || v:version == 704 && !has('patch1619'))
    set fileformat=unix
endif

" Use Windows line endings in batch files
if has('autocmd')
    augroup filetype_endings
        autocmd!
        autocmd FileType dosbatch setlocal fileformat=dos
    augroup END
endif

" -----------------
" Search behavior
" -----------------

" Ignore case when searching generally...
set ignorecase

" ...unless using capital letters
set smartcase

if has('extra_search')
    set incsearch
    set hlsearch
endif


" ----------
" Controls
" ----------

" Sane backspace behavior
set backspace=indent,eol,start

" Set nodigraph to avoid entering unexpected characters when pressing
" <char> <BS> <char>. Some systems default digraph to on.
if has('digraphs')
    set nodigraph
endif

" Allow arrow keys to wrap
set whichwrap+=<,>

" Ignore compiled files for tab completion
if has('wildignore')
    set wildignore+=*.o,*~,*.pyc,*.pyo
endif

if has('wildmenu')
    set wildmenu
endif

set wildmode=longest:full


" -----------------
" Visual behavior
" -----------------

" Visually wrap lines
if has('linebreak')
    set linebreak
endif

" Show trailing characters, but don't show anything for non-trailing tabs
" (Hint: to use a Unicode character, vim must be using a Unicode encoding.)
if has('multi_byte') && &encoding ==# 'utf-8'
    set listchars=tab:\ \ ,trail:·
endif

" Trailing characters are distracting while editing the current line.
" Instead, show them if toggled.
map <leader>es :setlocal list!<cr>

" Matching braces
set showmatch
set matchtime=2

" Folding
if has('folding')
    set foldenable
    set foldmethod=indent
    set foldlevelstart=10 " Open folds by default
    set foldnestmax=10
endif

" Misc display
if has('cmdline_info')
    set ruler
endif

set laststatus=2 " Consistent status bar
set number " Line numbers
set visualbell
set history=1000
set cursorline
set scrolloff=3

" Syntax color
if has('syntax') && !exists('g:syntax_on')
    syntax enable
endif

" Let vim figure out the correct value of t_Co
" (Hint: check value of $TERM if there are less colors than expected)

if &t_Co < 256 && !has('gui_running')
    " Use a basic color scheme for terminals lacking in colors
    try
        colorscheme pablo
    catch /^Vim\%((\a\+)\)\=:E185/
    endtry

    " cursorline looks terrible with low colors
    set nocursorline
    set laststatus=1
else
    if &t_Co == 256
        " The README for solarized recommends that this should be set for those
        " who don't change their terminal colors.
        let g:solarized_termcolors=256
    endif

    " Don't try to set the colors again if are running the GUI
    if !has('gui_running') || !exists('g:colors_name')
      " Colors need to be in ~/.vim/colors (or %HOME%\vimfiles\colors)
      " Fall back to something built-in if it's missing
      try
          " solarized dark does not have high enough contrast for me
          "colorscheme solarized

          " molokai and badwolf use bold fonts which do not display nicely in
          " PuTTY with Consolas + ClearType. (Note: PuTTY can be patched, see
          " http://stackoverflow.com/a/2581889/25295)
          "colorscheme molokai
          "colorscheme badwolf

          "colorscheme Tomorrow-Night
          colorscheme railscasts
      catch /^Vim\%((\a\+)\)\=:E185/
          try
              colorscheme pablo
          catch /^Vim\%((\a\+)\)\=:E185/
          endtry

          set nocursorline
          set laststatus=1
      endtry
    endif
endif


" -------
" Mouse
" -------

if has('mouse')
    " Allow mouse in all modes except insert if it's supported
    " (Hold down shift to copy)
    set mouse=nvc
    set mousehide

    " Resize buffers with mouse in tmux/screen
    if has('mouse_xterm') && &term ==# 'screen-256color'
        set ttymouse=xterm2
    endif
endif


" ----------------
" Shell commands
" ----------------

" Use PowerShell for commands on Windows
if has('win32')
    set shell=$WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe\ -NoLogo
    set shellcmdflag=-Command
    set shellquote=\"
    set shellxquote=
endif

" Use ag, rg, pt, or ack for grep command if available
if executable('rg')
    " ripgrep
    set grepprg=rg\ --no-heading\ --vimgrep
    set grepformat=%f:%l:%c:%m
elseif executable('ag')
    " The Silver Searcher
    set grepprg=ag\ --vimgrep
    set grepformat=%f:%l:%c:%m
elseif executable('pt')
    " The Platinum Searcher
    set grepprg=pt\ --nocolor\ --nogroup\ --column
    set grepformat=%f:%l:%c:%m
elseif executable('ack')
    set grepprg=ack\ -H\ --nocolor\ --nogroup
    set grepformat=%f:%l:%c:%m
endif


" ---------------
" Miscellaneous
" ---------------

" Don't recognize octal for CTRL-A and CTRL-X
set nrformats-=octal

" Prefer stronger encryption
if v:version > 704 || v:version == 704 && has('patch237') && has('patch401')
    set cryptmethod=blowfish2
elseif v:version >= 703
    " vim's original 'blowfish' is not secure, but might still be better than
    " the default of 'zip'
    set cryptmethod=blowfish
endif

" Backup the file only during writing
set nobackup

if has('writebackup')
    set writebackup
endif

set swapfile
" Put swap files somewhere else to avoid cluttering the current directory
" A trailing slash for the location makes vim use the full path name in the
" file name.
if has('win32')
    set directory=~/vimfiles/swap//,.
else
    set directory=~/.vim/swap//,.
endif

" Allow undo even if file is closed and reopened
if has("persistent_undo")
    set undofile

    if has('win32')
        set undodir=~/vimfiles/undo/
    else
        set undodir=~/.vim/undo/
    endif
endif

" Shortcut for setting paste mode
map <leader>pp :setlocal paste!<cr>

" Avoid accidentally opening up a help window
map <F1> <nop>
imap <F1> <nop>

" Avoid accidentally opening Ex mode
map Q <Nop>

" Quicker escape
imap kj <Esc>

" Hide swap files and backups from the file explorer
let g:netrw_list_hide='.*\.swp$,\~$'

" Load machine-specific settings
if filereadable(expand('~/.vimrc.local'))
    source $HOME/.vimrc.local
elseif has('win32') && filereadable(expand('~/vimfiles/vimrc.local'))
    source $HOME/vimfiles/vimrc.local
elseif filereadable(expand('~/.vim/vimrc.local'))
    source $HOME/.vim/vimrc.local
endif

set secure

" vim:set et sw=4:
