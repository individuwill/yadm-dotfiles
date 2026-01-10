" =========================
" Basics
" =========================
scriptencoding utf-8
set encoding=utf-8
set nocompatible

filetype plugin indent on
syntax on

let mapleader = ","

" Make Vim feel responsive
set updatetime=200
set timeoutlen=500

" =========================
" UI / look
" =========================
set number
set norelativenumber
set cursorline
set ruler
set showcmd
set laststatus=2
set signcolumn=yes
set colorcolumn=80
set scrolloff=7
set wildmenu
set wildmode=longest:full,full

" Search UX
set incsearch
set hlsearch
set ignorecase
set smartcase

" Turn off highlights quickly
nnoremap <leader>h :nohlsearch<CR>

" Whitespace visibility (toggle with :set list / :set nolist)
set list
set listchars=tab:»·,trail:~,extends:>,precedes:<,eol:¬

" Truecolor inside tmux (works best with tmux-256color + Tc override)
if has("termguicolors")
  set termguicolors
endif


" =========================
" Editing
" =========================
set hidden
set autoread

set backspace=indent,eol,start
set whichwrap+=<,>,h,l

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smartindent

" Better splits (no Alt usage, Aerospace-safe)
set splitbelow
set splitright

" Move between splits with Ctrl-h/j/k/l (matches your old muscle memory)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Keep visual selection when indenting
vnoremap < <gv
vnoremap > >gv

" Explicit system clipboard helpers
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>p "+p
nnoremap <leader>P "+P

" =========================
" Plugin manager: vim-plug
" =========================
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Sane defaults + small QoL
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Fuzzy finder (lightweight; use only when you want)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Linting / fixing (replaces syntastic)
Plug 'dense-analysis/ale'

" Theme
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'

" Better syntax/filetypes for your stack
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'towolf/vim-helm'                 " Helm templates (optional but great)
Plug 'pearofducks/ansible-vim'         " YAML/Ansible (optional)

" Docker / compose / Dockerfile
Plug 'ekalinin/Dockerfile.vim'

" Better YAML indentation/highlighting
Plug 'stephpy/vim-yaml'

" Shell scripts
Plug 'itspriddle/vim-shellcheck'

call plug#end()

" =========================
" Auto-install missing plugins
" =========================
" Auto-install missing plugins
autocmd VimEnter *
  \ if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \ |   PlugInstall --sync | source $MYVIMRC
  \ | endif

" Theme
set background=dark
colorscheme gruvbox

" =========================
" fzf.vim mappings (minimal)
" =========================
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>/ :Rg<CR>

" Requires ripgrep for :Rg
" brew install ripgrep

" YAML indentation (common k8s style)
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Help with huge YAML files (performance)
autocmd FileType yaml setlocal foldmethod=indent foldlevel=99

let g:rustfmt_autosave = 0 " ALE will handle formatting on save

" =========================
" ALE: linting + fixing
" =========================
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1

" Keep messages readable / non-noisy
let g:ale_echo_msg_format = '[%linter%] %s'
let g:ale_virtualtext_cursor = 0
let g:ale_sign_error = "✗"
let g:ale_sign_warning = "!"

" Python: ruff (lint + format)
let g:ale_linters = {
\  'python': ['ruff'],
\  'sh': ['shellcheck'],
\  'bash': ['shellcheck'],
\  'zsh': ['shellcheck'],
\  'yaml': ['yamllint'],
\  'rust': ['cargo'],
\}

let g:ale_fixers = {
\  'python': ['ruff_format', 'ruff'],
\  'rust': ['rustfmt'],
\  'sh': ['shfmt'],
\  'bash': ['shfmt'],
\  'zsh': ['shfmt'],
\  'yaml': ['prettier'],
\  'json': ['prettier'],
\  'toml': ['taplo'],
\}

" Optional: run rust checks with clippy instead of plain cargo
let g:ale_rust_cargo_use_clippy = 1

" =========================
" GitGutter (nice defaults)
" =========================
let g:gitgutter_map_keys = 0

" =========================
" Filetypes
" =========================
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Force Vim to use its own registers (do NOT default to system clipboard)
set clipboard=
