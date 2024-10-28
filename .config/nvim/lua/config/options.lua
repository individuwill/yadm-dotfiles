-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

-- Will need to setup a dedicated python environment for neovim
--
-- uv venv .local/share/nvim_python
-- . ~/.local/share/nvim_python/bin/activate
-- uv pip install pynvim
vim.g.python3_host_prog = "~/.local/share/nvim_python/bin/python3"
