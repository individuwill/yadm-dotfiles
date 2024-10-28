-- ASCII art generator:
-- https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=VIM

return {
  "nvimdev/dashboard-nvim",
  opts = function(_, opts)
    local logo = [[
██╗   ██╗██╗███╗   ███╗
██║   ██║██║████╗ ████║
██║   ██║██║██╔████╔██║
╚██╗ ██╔╝██║██║╚██╔╝██║
 ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═══╝  ╚═╝╚═╝     ╚═╝
    ]]

    logo = string.rep("\n", 8) .. logo .. "\n\n"
    opts.config.header = vim.split(logo, "\n", { trimempty = false })
  end,
}
