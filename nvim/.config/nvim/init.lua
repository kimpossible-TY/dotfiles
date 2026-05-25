
-- lazy.nvim 플러그인 매니저 자동 설치 및 로드
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 시스템 클립보드 사용 설정
vim.opt.clipboard = "unnamedplus"

-- Codespaces(SSH) 등 원격 환경에서 로컬 Windows와 클립보드 연동 (OSC 52)
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

if vim.g.vscode then
  -- [VS Code 모드]
  
  -- Ctrl + J 로 터미널 포커스/토글하기
  vim.keymap.set({'n', 'v', 'i'}, '<C-j>', function()
    require('vscode').call('workbench.action.terminal.toggleTerminal')
  end, { desc = "VS Code 터미널 토글" })

else
  -- [순수 터미널 Neovim 모드]
end

-- 기본적인 VIM 셋팅
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.laststatus = 3
vim.opt.sidescrolloff = 8  -- 커서 좌우에 최소 8글자 여유를 둠

-- 시스템 클립보드 사용 설정
vim.opt.clipboard = "unnamedplus"

if vim.treesitter.language and not vim.treesitter.language.ft_to_lang then
  vim.treesitter.language.ft_to_lang = function(ft)
    return vim.treesitter.language.get_lang(ft) or ft
  end
end

-- 자동 저장 설정: 입력 모드에서 빠져나오거나, 일반 모드에서 텍스트가 변경될 때 저장
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = { "*" },
  command = "silent! write",
})

-- 내장 Treesitter 구문 강조 및 기능
vim.api.nvim_create_autocmd("FileType", {
  -- 구문 강조를 적용할 언어 지정 (또는 모든 언어 적용을 원하면 pattern = { "*" } 사용)
  pattern = { "lua", "python", "typst", "json", "bash" },
  callback = function(args)
    -- 버퍼에 대한 구문 강조(Highlight) 활성화
    pcall(vim.treesitter.start, args.buf)
    
    -- (선택) Treesitter 기반 폴딩(코드 접기) 활성화
    -- vim.wo.foldmethod = 'expr'
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end,
})

-- 플러그인 목록 및 설정
require("lazy").setup({

  -- 테마
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- 자동완성
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        completion = {
          max_item_count = 3,
        },
        -- 1. 키 매핑: 팝업 내 이동(Ctrl-n, Ctrl-p) 및 확정(Enter)
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),

        -- 2. 자동완성 소스: LSP 전용
        sources = cmp.config.sources({
          { name = "nvim_lsp" , max_item_count = 3 },
          { name = "buffer", max_item_count = 1 },
          { name = "path" },
        }),
      })
    end,
  },

  -- LSP (언어 서버 관리)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "tinymist" }
      })
      vim.lsp.config.tinymist = {
        cmd = { "tinymist" },
        filetypes = { "typst" },
        root_markers = { ".git", "main.typ" },
        settings = {
          formatterMode = "typstyle",
          exportPdf = "never"
        }
      }
      vim.lsp.enable("tinymist")
    end,
  },

  -- 하단 상태바
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" }
      })
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      
      local builtin = require("telescope.builtin") 
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = "Telescope Diagnostics (에러 모아보기)" })

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules/.*", "%.git/.*", "dist/.*", "build/.*",
            "target/.*", "%.pdf", "%.csv", "%.dat", "__pycache__/.*"
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob=!{.git/*}"
          },
          layout_strategy = "vertical",
          layout_config = {
            vertical = { preview_height = 0.4, mirror = true },
            width = 0.95, height = 0.9,
          },
          sorting_strategy = "ascending",
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" }
          },
        },
      })

      pcall(telescope.load_extension, "fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "파일 찾기" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "텍스트 검색" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "버퍼 목록" })
      vim.keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "현재 파일 내 검색" })
    end,
  },

  -- Oil.nvim
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "상위 디렉토리 열기" })
    end
  },

  -- Toggleterm
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
      })
    end
  },

  -- Flash.nvim
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "abcdefghijklmnopqrtuvwxyz",
      jump = {
        n_chars = 2,
      },
      search = {
        multi_window = false,
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },

    -- Supermaven (공식 README 기준 무조건 로딩)
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-w>",
        },
        ignore_filetypes = { cpp = true },
        color = {
          suggestion_color = "#808080",
          cterm = 244,
        },
        log_level = "info",
        -- [주의] cmp 메뉴 안에서만 추천을 보고 싶다면 아래 값을 true로 변경해라.
        disable_inline_completion = false, 
        disable_keymaps = false,
      })
    end,
  },
  -- grug-far.nvim
    {
    "MagicDuck/grug-far.nvim",
    opts = { engine = 'ripgrep' },
    config = function()
      require("grug-far").setup()
      vim.keymap.set('n', '<leader>S', '<cmd>GrugFar<CR>', { desc = "Search and Replace (GrugFar)" })
      vim.keymap.set('n', '<leader>sw', '<cmd>lua require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })<CR>', { desc = "Search current word" })
    end
  },
  -- typst preview
  {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  build = function()
    require("typst-preview").update()
  end,
  opts = {
    port = 23625,
    open_cmd = nil,
    debug = true
  },
  }
})

