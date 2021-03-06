" Alexandre's vimrc
"
" TODO: Make mappings for formatting
" for example, make a function that calls the relevant format function for the
" current filetype - useful for ClangFormat and gofmt

" Automatic installation {{{
if empty(glob('$XDG_CONFIG_HOME/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if executable('pip')
      silent !pip install --user neovim
    endif
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
" }}}

autocmd FileType vim set foldmethod=marker

" Neovim/Vim settings {{{
if has('nvim')
  runtime! plugin/python_setup.vim
else
  if !isdirectory($XDG_CACHE_HOME . '/vim')
    silent call mkdir($XDG_CACHE_HOME . '/vim', 'p')
  endif
  " Can't share viminfo with Neovim unfortunately.
  set viminfo+=n$XDG_CACHE_HOME/vim/viminfo

  " Directories are automatically created if they do not exist.
  " Set Neovim defaults,as that is ultimately where we're heading.
  if !isdirectory($XDG_DATA_HOME . '/nvim')
    silent call mkdir($XDG_DATA_HOME . '/nvim/swap', 'p')
    silent call mkdir($XDG_DATA_HOME . '/nvim/backup', 'p')
    silent call mkdir($XDG_DATA_HOME . '/nvim/view', 'p')
    silent call mkdir($XDG_DATA_HOME . '/nvim/undo', 'p')
  endif
  set directory=$XDG_DATA_HOME/nvim/swap//
  set backupdir=.,$XDG_DATA_HOME/nvim/backup
  set viewdir=$XDG_DATA_HOME/nvim/view
  set undodir=$XDG_DATA_HOME/nvim/undo
  set runtimepath+=$XDG_CONFIG_HOME/nvim,$XDG_CONFIG_HOME/nvim/after
endif
" }}}
set undofile
" Where we save bookmarks and history.
let g:netrw_home='$XDG_CACHE_HOME/nvim'

let g:bundle_folder='$XDG_CONFIG_HOME/nvim/plugged'
let g:use_glyphs = 0 " Use fancy glyphs?

call plug#begin(g:bundle_folder)

" Defaults everyone can agree on.
" Defined up here so other plugins can benefit from settings
Plug 'tpope/vim-sensible'

" Syntax {{{

" Use ']l' and '[l' to cycle through errors (with vim-unimpaired)
Plug 'benekastah/neomake' " {{{

" Execute linter on save
autocmd! BufWritePost * Neomake

" Have YouCompleteMe handle syntax checking for C-family languages
let g:neomake_c_enabled_makers = []
let g:neomake_cpp_enabled_makers = []
let g:neomake_objc_enabled_makers = []
let g:neomake_objcpp_enabled_makers = []

" Generally have only one linter (otherwise they tend to report the same
" thing)
let g:neomake_python_enabled_makers = ['pylint']

let g:neomake_error_sign = {'text': 'x', 'texthl': 'ErrorMsg'}
let g:neomake_warning_sign = {'text': '!', 'texthl': 'WarningMsg'}
let g:neomake_message_sign = {'text': 'm', 'texthl': 'NeomakeMessageSign'}
let g:neomake_info_sign = {'text': 'i', 'texthl': 'TODO'}

" }}}

" Allows asynchronous execution (great for syntax checkers)
Plug 'Shougo/vimproc.vim', { 'do': 'make -f make_unix.mak' }

" }}}

" Ansible {{{

" Syntax highlighting
Plug 'pearofducks/ansible-vim'

" }}}

" C / C++ {{{

" Syntax highlighting
Plug 'octol/vim-cpp-enhanced-highlight', {'for': ['c', 'cpp']}

" }}}

" CMake {{{
autocmd FileType cmake setlocal commentstring=#\ %s
" }}}

" Colours {{{

Plug 'altercation/vim-colors-solarized'

" Set utf8 as standard encoding and en_US as standard language
set encoding=utf-8
scriptencoding utf-8

" Set unix as standard file type
set fileformats=unix,dos,mac

" }}}

" Completion {{{

" Autocompletion for quotes, parens, etc.
Plug 'raimondi/delimitMate' " {{{
let g:delimitMate_expand_cr = 1
" }}}

" Options
" --clang-completer (C/C++)
" --omnisharp-completer (C#)
" --gocode-completer (Go)
" --tern-completer (Javascript)
" --racer-completer (Rust)
" --system-libclang (Use system libclang instead of downloading other binary)
" --system-boost (Use system boost instead of downloading)
let ycm_options = '--clang-completer ' .
                \ '--tern-completer ' .
                \ '--system-libclang'
Plug 'Valloric/YouCompleteMe', {'do': './install.py ' . ycm_options} " {{{
let g:ycm_always_populate_location_list = 1
let g:ycm_confirm_extra_conf = 0

let g:ycm_error_symbol = 'x'
let g:ycm_warning_symbol = '!'

let g:ycm_semantic_triggers = {'haskell': ['.'], 'r': ['.', '$', 're![_a-zA-Z]+[_\w]*\.']}
" Run ctags --fields=+l and YCM will look at tags files.
let g:ycm_collect_identifiers_from_tags_files = 1
" Set backup ycm extra conf; aims to be generic (though we should still
" generate our own special one).
let g:ycm_global_ycm_extra_conf = $XDG_CONFIG_HOME . '/nvim/global_ycm_extra_conf.py'

 " }}}

" Generate .ycm_extra_conf.py
" IDEA: On git pull, generate one if it doesn't exist (and is supported, e.g.
" CMakeLists exist).
" Run config_gen.py <PROJECT_DIR> or :YcmGenerateConfig
Plug 'rdnetto/YCM-Generator', {'branch': 'stable', 'on': 'YcmGenerateConfig'}

 " Snippets produced along side YouCompleteMe
Plug 'SirVer/UltiSnips' " {{{
let g:UltiSnipsExpandTrigger = '<C-j>'
" }}}

Plug 'honza/vim-snippets'

" End certain strutures automatically.
Plug 'tpope/vim-endwise'

" }}}

" Shell {{{

" Set default shell; plugins may not work if using fish as user-shell.
set shell=/bin/sh

Plug 'dag/vim-fish', {'for': 'fish'}

" }}}

" Docker {{{

" Provides snippets and highlights popular bash commands
Plug 'ekalinin/Dockerfile.vim'

" }}}

" Fortran {{{
" Use free-form input (Don't assume everything is offset by 8 spaces)
let fortran_free_source = 1

" Make syntax colouring more precise (albeit slower)
let fortran_more_precise = 1

" }}}

" Git {{{

" Shows git diff in column - better than mhinz/vim-signify
Plug 'airblade/vim-gitgutter' " {{{
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_modified_removed = '~-'
" }}}

" Git Wrapper.
Plug 'tpope/vim-fugitive'

" Syntax highlighting
Plug 'tpope/vim-git'

" Git commit browser
Plug 'junegunn/gv.vim', {'on': 'GV'}

" Enable spell-check on git commits
autocmd Filetype gitcommit set spell

" }}}

" Go {{{
" Batteries included go support (including completion)
Plug 'fatih/vim-go', {'for': 'go'}
" }}}

" Haskell {{{
" Check out begriffs/haskell-vim-now for configs / haskell packages.

" Syntax highlighting & indentation for Haskell/Cabal
Plug 'neovimhaskell/haskell-vim', {'for': 'haskell'}

" Haskell plugins
" Plug 'dag/vim2hs', {'for': 'haskell'}

" Haskell plugin that can display:
"  - type of sub-expressions (what we chiefly use it for)
"  - warnings/errors
"  - expansion of splices
"  - Insert split function cases
" Needs vimproc.vim and ghc-mod
Plug 'eagletmt/ghcmod-vim', {'on': 'GhcModType'}

" Completion plugin for Haskell using ghc-mod
Plug 'eagletmt/neco-ghc', {'for': 'haskell'} " {{{
let g:necoghc_enable_detailed_browse = 0
autocmd FileType haskell set omnifunc=necoghc#omnifunc " YouCompleteMe/NeoComplete
" }}}

" Hoogle (Haskell query plugin)
Plug 'Twinside/vim-hoogle', {'on': 'Hoogle'}

" }}}

" HTML / CSS {{{
"
" CSS3 Syntax support to built-in CSS syntax
Plug 'hail2u/vim-css3-syntax', { 'for': ['html', 'xhtml', 'css'] }

" HTML5 + inline SVG omnicomplete function, indent and ayntax.
Plug 'othree/html5.vim', { 'for': ['html', 'xhtml'] }

" }}}

" Interface {{{

" Exclude quickfix list from buffer navigation.
augroup qf
  autocmd!
  autocmd FileType qf set nobuflisted
augroup END

" Use Australian spelling if enabled
set spelllang=en_au

" Make searches case-insensitive.
set ignorecase

" Make searches case-senstive with the inclusion of an upper-case character.
set smartcase

" Highlight searches as you type in a pattern.
set incsearch

" Don't highlight previous search results.
set nohlsearch

" When buffer is abandoned it becomes hidden.
set hidden

" Highlight current row
" Works really nicely with TagBar - press p over a function definition and the
" cursor is sent their (so it is highlighted automatically).
set cursorline

" Handles csv files.
Plug 'chrisbra/csv.vim', { 'for' : 'csv' }

" Peek at the Undo tree.
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}

" More options (like diff) when dealing with swp files.
Plug 'chrisbra/Recover.vim'

" Display marks in the gutter
Plug 'kshenoy/vim-signature'

" Automatically format with what's available
Plug 'Chiel92/vim-autoformat', {'on': 'Autoformat'}

" Intelligent number toggling.
Plug 'myusuf3/numbers.vim', " {{{

" Odd things happen without this.
set number
" List of items to exclude from being numbered.
let g:numbers_exclude = ['tagbar', 'undotree']

" }}}

" Listen to ~/.editorconfig to set indenting styles for different languages.
" Also includes trimming whitespace, etc.
Plug 'editorconfig/editorconfig-vim' " {{{

let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'tarfile::.*']

" Color the column corresponding the maximum line length (+1)
let g:EditorConfig_max_line_indicator = 'line'

if executable('editorconfig')
  " Requires editor-config-core-c, get it from the AUR or linuxbrew
  let g:EditorConfig_core_mode = 'external_command'
else
  " If unavailable, set to python_external
  let g:EditorConfig_core_mode = 'python_external'
endif

" Don't the current line if it was already longer than the allowed width when
" the user started editing it.
set formatoptions+=l

" }}}

" Sane buffer deletion on :Sayonara
Plug 'mhinz/vim-sayonara', {'on': 'Sayonara'}

" Execute unix shell commands from Vim.
Plug 'tpope/vim-eunuch', {'on': ['Remove', 'Unlink', 'Move', 'Rename', 'Chmod',
                               \ 'Mkdir', 'Find', 'Locate', 'Wall',
                               \ 'SudoWrite', 'SudoEdit']}
" }}}

" JavaScript {{{

" General support
Plug 'pangloss/vim-javascript', { 'for' : 'javascript' }

" }}}

" LaTeX {{{

au BufNewFile,BufRead *.tex set filetype=tex

" Set spellcheck on documents
autocmd FileType tex set spell

" LaTeX Plugin
Plug 'LaTeX-Box-Team/LaTeX-Box', {'for': ['plaintex', 'context', 'latex', 'rnoweb', 'tex']} " {{{
" Quickfix window opened automatically if not empty, cursor stays in current
" window
let g:LatexBox_quickfix = 2

" }}}


" }}}

" Mappings {{{

" Align text with 'gaip='
Plug 'junegunn/vim-easy-align', {'on': ['<Plug>EasyAlign', 'EasyAlign']} " {{{
" Start interactive EasyAlign in visual mode.
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for motion/text object.
nmap ga <Plug>(EasyAlign)
" }}}

" Easier way of navigating - s{char}{char}, ; to go to next match.
Plug 'justinmk/vim-sneak' "{{{
" Act like Easy-motion.
let g:sneak#streak = 1
"}}}

" Use gcc to toggle comments.
Plug 'tpope/vim-commentary' ", {'on': '<Plug>Commentary'}

" Better sed with Subvert
" Allows changing of snake, mixed and camel case.
Plug 'tpope/vim-abolish'

" Easily change surroundings (e.g. tags) in pairs.
Plug 'tpope/vim-surround'

" Nicer mappings using ']' and '[' for 'next' and 'previous'
" e.g. ]b for next buffer
Plug 'tpope/vim-unimpaired'

" Rapidly press these keys (instead of Esc) to go Normal mode.
inoremap jk <Esc>
inoremap kj <Esc>

" When wrapping is enabled, move down by row not by line.
nnoremap j gj
nnoremap k gk

" Centre the found match.
nnoremap n nzz

" Allow for easier window navigation
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <C-h> <C-w>h

" Change leader to space to allow easier transitioning with spacemacs.
let mapleader=" "

" Press 'q' to close quickfix/location lists, similar to VimFiler/TagBar
autocmd FileType qf map <buffer> q :quit<cr>

" Buffers; alternatively, [b or ]b
nnoremap <Leader>bn :bnext<cr>
nnoremap <Leader>bp :bprevious<cr>
nnoremap <Leader>bd :bdelete<cr>

" Plugin mappings - keybindings are influenced by the first thing I think of
" when trying to use it
nnoremap <Leader>tb :TagbarToggle<cr>
nnoremap <Leader>tggh :GitGutterLineHighlightsToggle<cr>
nnoremap <Leader>gr :Grepper<cr>
nnoremap <Leader>* :Grepper -cword -noprompt<cr>
nnoremap <Leader>ud :UndotreeToggle<cr>
nnoremap <Leader>fe :Vexplore<cr>
nnoremap <Leader>ff :FZF<cr>
nnoremap <Leader>fi :YcmCompleter FixIt<cr>
" Consider nnoremap <buffer> <silent> <C-]> :YcmCompleter GoTo<cr>
nnoremap <Leader>gt :YcmCompleter GoTo<cr>
nnoremap <Leader>q :Sayonara<cr>

" }}}

" Markdown {{{

" Set relevant files with markdown extensions to be MarkDown.
au BufNewFile,BufRead *.md,*.mkd set filetype=markdown

" Spell check markdown files.
autocmd FileType markdown set spell

" Markdown runtime files
" godlygeek/tabular MUST come before this.
Plug 'plasticboy/vim-markdown', { 'for' : 'markdown' }

" }}}

" Python {{{

Plug 'hynek/vim-python-pep8-indent', {'for': 'python'}

" }}}

" Rust {{{
Plug 'rust-lang/rust.vim', {'for': 'rust'}
" }}}

" Searching (& Exploring) {{{

" Augment built-in directory browser; press '~' to go home.
Plug 'tpope/vim-vinegar' " {{{

" Use a tree-style view.
let g:netrw_liststyle = 3

" }}}

" Fuzy searh finder
" Due to its frankly shocking directory layout, we use our package manager to
" download fzf.
Plug 'junegunn/fzf', {'on': 'FZF'}

" Grep things easily, autodetects tools
" Asynchronous support with neovim
Plug 'mhinz/vim-grepper', {'on': 'Grepper'}

" }}}

" Statusline {{{

" Better buffertab
Plug 'ap/vim-buftabline' " {{{
let g:buftabline_show = 2 " Always show buffers (less disjointed on enter)
let g:buftabline_numbers = 1 " Show buffer numbers in label
let g:buftabline_indicators = 1 " Show buffer state in label
" }}}

" Even more lightweight and configurable than airline
" Get bufferline in the tabline
Plug 'itchyny/lightline.vim' " {{{

" Don't use tagbar for now; it's slow and I can't justify using it.
" Don't set colorscheme here; set it with the actual colorscheme down below
" to facilitate switching.
let g:lightline = {
    \ 'enable': {
    \   'tabline': 0
    \ },
    \ 'active': {
    \   'left': [
    \     ['mode', 'paste', 'readonly'],
    \     ['fugitive', 'gitgutter', 'filename']
    \   ],
    \   'right': [
    \     ['neomake', 'ycm', 'lineinfo'],
    \     ['percent'],
    \     ['fileformat', 'fileencoding', 'filetype'],
    \   ]
    \ },
    \ 'component': {
    \   'lineinfo': '%3l:%-2c',
    \   'readonly': '%{&readonly ? "RO" : ""}',
    \   'fileencoding': '%{strlen(&fenc) ? &fenc : &enc}',
    \   'filename': '%{expand("%:p:.")}',
    \   'filetype': '%{strlen(&ft) ? &ft : "no ft"}',
    \   'tagbar': '%{exists("*tagbar#currenttag") ? tagbar#currenttag("%s", "", "f") : ""}',
    \ },
    \ 'component_function': {
    \   'mode': 'MyMode',
    \   'fugitive': 'MyFugitive',
    \   'gitgutter': 'MyGitGutter',
    \   'neomake': 'MyNeomake',
    \   'ycm': 'MyYCM',
    \ },
    \ 'component_type': {
    \   'neomake': 'error',
    \   'ycm': 'error',
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '|', 'right': '|' }
    \ }

" Lightline functions {{{
function! MyFugitive()
  if expand('%:t') !~? 'Tagbar' && &ft !~? 'vimfiler' && exists('*fugitive#head')
    let head = fugitive#head()
    return strlen(head) ? head : ''
  endif
  return ''
endfunction

function! MyGitGutter()
  if exists('*GitGutterGetHunkSummary')
    let hunks = GitGutterGetHunkSummary()
    if hunks != [0, 0, 0]
      return g:gitgutter_sign_added . hunks[0] .
      \ ' ' . g:gitgutter_sign_modified . hunks[1] .
      \ ' ' . g:gitgutter_sign_removed . hunks[2]
    else
      return ''
    endif
  else
    return ''
  endif
endfunction

function! MyMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
       \ lightline#mode() == 'COMMAND' ? 'C' :
       \ lightline#mode() == 'INSERT' ? 'I' :
       \ lightline#mode() == 'NORMAL' ? 'N' :
       \ lightline#mode() == 'REPLACE' ? 'R' :
       \ lightline#mode() == 'SELECT' ? 'S' :
       \ lightline#mode() == 'S-BLOCK' ? 'S' :
       \ lightline#mode() == 'S-LINE' ? 'S' :
       \ lightline#mode() == 'TERMINAL' ? 'T' :
       \ lightline#mode() == 'VISUAL' ? 'V' :
       \ lightline#mode() == 'V-BLOCK' ? 'V' :
       \ lightline#mode() == 'V-LINE' ? 'V' :
       \ lightline#mode()
endfunction

function! MyNeomake()
  let counts = neomake#statusline#LoclistCounts()
  let warning = get(counts, 'W', 0)
  let error = get(counts, 'E', 0)
  if [warning, error] != [0, 0]
    return 'W:' . error . ' E:' . warning
  else
    return ''
  endif
endfunction

function! MyYCM()
  let warning = youcompleteme#GetWarningCount()
  let error = youcompleteme#GetErrorCount()
  if [warning, error] != [0, 0]
    return 'W:' . error . ' E:' . warning
  else
    return ''
  endif
endfunction
" }}}

" }}}

" Show statusline on all windows - done by sensible
set laststatus=2

" }}}

" Systemd {{{

au BufNewFile,BufRead *.service set filetype=cfg

au BufNewFile,BufRead *.socket set filetype=cfg

" }}}

" Tags {{{

" Easily browse tags of source files (generated on the fly).
" Reguires ctags and vim >= 7.0
Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}

" Haskell (requires hasktags) {{{
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

" }}}

" }}}

" Tmux {{{

" Send make commands to Tmux pane
Plug 'tpope/vim-dispatch', {'on': ['Make', 'Dispatch', 'Start'] }

" Syntax highlighting
Plug 'Keithbsmiley/tmux.vim'

" }}}

call plug#end()

" Colorscheme {{{

" HAS to be set after t_Co and background - weird things happen otherwise.

" Use 256 to enable 256-Colour mode
" Use 16 to use Terminal's colours.
set t_Co=256
set background=dark
silent! colorscheme solarized
let g:lightline.colorscheme = 'solarized'

" }}}
