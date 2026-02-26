-- Add lazy to runtime
vim.opt.rtp:prepend("/opt/nvim-config/lazy/lazy.nvim")

require("lazy").setup({

  -- 🎨 Colorscheme
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- 🌈 Icons
  { "nvim-tree/nvim-web-devicons" },

  -- 🔍 Telescope (Prettier)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.9,
            height = 0.85,
            preview_width = 0.6,
          },
          border = true,
          winblend = 0,
        },
      })
    end,
  },

  -- 📁 Neo-tree (Cleaner Sidebar)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        window = {
          width = 30,
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
          },
        },
      })
    end,
  },

  -- 🧼 Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },
    {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-t>]],
        direction = "horizontal",
     --   shell = "bash -l -i -c 'source /home/michal/projects/ccs/config/env_setup; exec bash -l -i'",
      })
    end,
  }

})

-- 🔎 Telescope Keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)

-- 📁 Auto open Neo-tree on start
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("neo-tree.command").execute({ toggle = false, dir = vim.loop.cwd() })
  end,
})

vim.keymap.set("n", "<leader>e", ":Neotree toggle left<CR>")

-- ✨ Basic UI improvements
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.signcolumn = "yes"
