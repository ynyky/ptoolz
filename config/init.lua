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

  -- 🔍 Telescope
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
        },
      })
    end,
  },

  -- 📁 Neo-tree (NO ICONS)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        enable_git_status = false,
        enable_diagnostics = false,
        window = {
          width = 30,
        },
        default_component_configs = {
          icon = {
            enabled = false,
          },
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
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          section_separators = "",
          component_separators = "",
          icons_enabled = false,
        },
      })
    end,
  },

  -- 🖥 Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-t>]],
        direction = "horizontal",
        shell = "bash -l -i",
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
