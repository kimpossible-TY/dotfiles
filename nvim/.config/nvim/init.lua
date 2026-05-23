
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

-- 3. 기본적인 VIM 셋팅
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

if vim.treesitter.language and not vim.treesitter.language.ft_to_lang then
  vim.treesitter.language.ft_to_lang = function(ft)
    return vim.treesitter.language.get_lang(ft) or ft
  end
end

-- 4. 플러그인 목록 및 설정
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

  -- 구문 강조 (Treesitter 0.12.0+ 신규 API)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- [필수] 새 버전은 지연 로딩을 엄격히 금지함
    build = ":TSUpdate", -- 플러그인 업데이트 시 파서도 함께 업데이트
    config = function()
      local ts = require("nvim-treesitter")

      -- 1. 기본 셋업 (기본값 사용 시 생략 가능하지만, 명시적 관리를 위해 유지)
      ts.setup({
        -- 파서 설치 경로를 명시 (선택 사항)
        install_dir = vim.fn.stdpath('data') .. '/site'
      })

      -- 2. 필요한 언어 파서 비동기 설치
      -- 기존의 ensure_installed 역할을 대체함
      ts.install({ "lua", "python","typst", "json", "bash" })

      -- 3. Treesitter 기능 개별 활성화 (Neovim 자동명령 활용)
      -- 플러그인 설정이 아닌 버퍼(파일) 단위로 활성화해야 함
      vim.api.nvim_create_autocmd("FileType", {
        -- 파서를 설치한 언어들을 매칭 패턴에 등록
        pattern = { "lua", "python","typst", "json", "bash" },
        callback = function()
          -- 구문 강조(Highlight) 활성화
          vim.treesitter.start()

          -- 들여쓰기(Indent) 활성화 (실험적 기능)
          -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
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
          accept_word = "<C-j>",
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

