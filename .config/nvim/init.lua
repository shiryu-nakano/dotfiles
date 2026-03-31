-- 基本設定 -------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.conceallevel = 2  -- リンクなどのMarkdown記法を隠す
vim.opt.concealcursor = "nc"  -- Normal/Commandモードでもカーソル行をconceal
vim.opt.clipboard = "unnamedplus"  -- システムクリップボードと連携

-- 折りたたみ設定 (nvim-ufo用) --------
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldopen = ""  -- カーソル移動で折りたたみが自動で開くのを防ぐ (jj問題対策)
-------------------------------------------------------

-- lazy.nvim のセットアップ -------------------------
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
------------------------------------------------------


require("lazy").setup({
  -- カラースキーム (TokyoNight) --------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
      -- 太字の代わりに色で強調（CJKフォントのbold問題対策）
      vim.api.nvim_set_hl(0, "@markup.strong", { fg = "#ff9e64", bold = false })
    end,
  },
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown" },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<Space>sm", ":RenderMarkdown toggle<CR>", desc = "Toggle Markdown rendering" },
    },
    opts = {
      -- カーソル行以外は常にレンダリング
      render_modes = true,
      -- 見出し: アイコン非表示、背景幅を文字に合わせる
      heading = {
        width = "block",
        left_pad = 0,
        right_pad = 4,
        icons = {},
      },
      -- コードブロック: 背景幅をコード範囲のみに
      code = {
        width = "block",
      },
      -- チェックボックス: キャンセル状態を追加
      checkbox = {
        checked = { scope_highlight = "@markup.strikethrough" },
        custom = {
          todo = { raw = "", rendered = "", highlight = "" },
          canceled = {
            raw = "[-]",
            rendered = "󱘹 ",
            highlight = "Comment",
            scope_highlight = "@markup.strikethrough",
          },
        },
      },
      -- 不要な機能を無効化（警告を消す）
      html = { enabled = false },
      latex = { enabled = false },
      yaml = { enabled = false },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
  },
  -- LaTeX 統合 (vimtex) --------
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      vim.g.vimtex_view_method = "skim"
      -- texファイルタイプを常にlatexとして扱う
      vim.g.tex_flavor = "latex"
    end,
  },
  -- ウィンドウ選択 (window-picker) --------
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          bo = {
            filetype = { "neo-tree", "neo-tree-popup", "notify" },
            buftype = { "terminal", "quickfix" },
          },
        },
      })
    end,
  },
  -- ファイルツリー (neo-tree) --------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "s1n7ax/nvim-window-picker",
    },
    lazy = false,
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
      { "<leader>r", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
      { "<leader>b", "<cmd>Neotree float buffers<cr>", desc = "Show buffers" },
    },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".git" },
          never_show = { ".git_hidden_message" },
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
  },
  -- LaTeX リンター (chktex) --------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        tex = { "chktex" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
  -- 折りたたみ (nvim-ufo) --------
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "BufReadPost",
    config = function()
      local ufo = require("ufo")
      ufo.setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
        -- 折りたたみ時のプレビュー表示
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = ("  󰁂 %d lines "):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, { suffix, "Comment" })
          return newVirtText
        end,
      })
      -- キーマップ
      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "K", function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = "Peek fold or hover" })
    end,
  },
  -- LaTeX数式グラフィカル表示 (mdmath.nvim) --------
  {
    "Thiago4532/mdmath.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown" },
    opts = {
      foreground = "#c0caf5",  -- 明示的に色を指定（Tokyo Night風）
    },
  },
  -- 画像貼り付け (img-clip.nvim) --------
  {
    "HakonHarnes/img-clip.nvim",
    ft = { "markdown" },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
    },
    opts = {
      default = {
        dir_path = "assets",  -- 画像保存先ディレクトリ
      },
    },
  },
  -- インライン画像表示 (image.nvim) --------
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    opts = {
      backend = "kitty",       -- Ghostty も Kitty protocol 対応
      processor = "magick_cli", -- luarocks不要、ImageMagick CLI使用
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
        },
      },
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = 40,
    },
  },
})



vim.keymap.set('i', 'jj', '<Esc>', { noremap = true, silent = true })

-- Insertモードでのインデント --------
-- 見出し行では折りたたみトグル、それ以外ではインデント
vim.keymap.set('i', '<Tab>', function()
  local line = vim.fn.getline('.')
  if line:match('^#+ ') then
    -- 見出し行: Normalモードに戻って折りたたみトグル
    vim.cmd('stopinsert')
    vim.cmd('normal! za')
  else
    -- 通常行: インデント
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-T>', true, false, true), 'n', false)
  end
end, { noremap = true, silent = true, desc = "Indent or toggle fold on heading" })
vim.keymap.set('i', '<S-Tab>', '<C-D>', { noremap = true, silent = true, desc = "Outdent" })

-- リスト行の途中で改行したとき、残りを新しいリスト項目にする --------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set('i', '<CR>', function()
      local line = vim.fn.getline('.')
      local col = vim.fn.col('.')

      -- リストパターン: -, *, +, 数字., - [ ], - [x] など
      local indent, marker = line:match('^(%s*)([-*+] %[.%] )')
      if not marker then
        indent, marker = line:match('^(%s*)([-*+] )')
      end
      if not marker then
        indent, marker = line:match('^(%s*)(%d+%. )')
      end

      if marker then
        local marker_end = #indent + #marker
        local text_after_marker = line:sub(marker_end + 1)

        -- 空のリスト項目（マーカーのみ）の場合 → マーカーを削除して空行に
        if text_after_marker:match('^%s*$') then
          vim.fn.setline('.', '')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        -- リスト途中で改行 → 新しいリスト項目を作成
        elseif col > marker_end then
          local after_cursor = line:sub(col)
          local before_cursor = line:sub(1, col - 1)
          vim.fn.setline('.', before_cursor)

          -- チェックボックスの場合は未チェック状態で新規作成
          local new_marker = marker:gsub('%[x%]', '[ ]'):gsub('%[X%]', '[ ]')
          -- 番号付きリストの場合は次の番号に
          local num = marker:match('^(%d+)')
          if num then
            new_marker = tostring(tonumber(num) + 1) .. '. '
          end

          local new_line = indent .. new_marker .. after_cursor
          vim.fn.append('.', new_line)
          vim.fn.cursor(vim.fn.line('.') + 1, #indent + #new_marker + 1)
        else
          -- マーカー内での改行は通常の改行
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end
      else
        -- 通常の改行
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
      end
    end, { buffer = true, noremap = true, silent = true, desc = "Smart list line break" })
  end,
})

-- 折りたたみキーマップ --------
-- Visualモードで Tab: 選択範囲を折りたたむ
vim.keymap.set('v', '<Tab>', 'zf', { noremap = true, silent = true, desc = "Fold selection" })
-- Visualモードで Shift+Tab: 選択範囲の折りたたみを展開
vim.keymap.set('v', '<S-Tab>', 'zd', { noremap = true, silent = true, desc = "Unfold selection" })
-- Normalモードで Tab: 折りたたみをトグル
vim.keymap.set('n', '<Tab>', 'za', { noremap = true, silent = true, desc = "Toggle fold" })
-- Normalモードで Shift+Tab: 全ての折りたたみをトグル
vim.keymap.set('n', '<S-Tab>', 'zA', { noremap = true, silent = true, desc = "Toggle all folds under cursor" })

-- Markdown用の設定 --------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- treesitterハイライトを有効化（パーサーが無い場合はスキップ）
    pcall(vim.treesitter.start)
    -- 折りたたみ設定
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.MarkdownFoldExpr()"
  end,
})

-- Markdownの見出しレベルに基づく折りたたみ関数
function MarkdownFoldExpr()
  local line = vim.fn.getline(vim.v.lnum)
  local next_line = vim.fn.getline(vim.v.lnum + 1)

  -- ATX形式の見出し (# で始まる)
  local level = line:match("^(#+)%s")
  if level then
    return ">" .. #level
  end

  -- Setext形式の見出し (次の行が === または ---)
  if next_line:match("^=+%s*$") then
    return ">1"
  elseif next_line:match("^%-%-+%s*$") then
    return ">2"
  end

  return "="
end

-- nb リンク挿入 (fzf) --------
local function insert_nb_link()
  local tempfile = vim.fn.tempname()
  local script_path = vim.fn.expand('~/.local/bin/nb-link')

  -- フローティングウィンドウでターミナルを開く
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
  })

  -- ターミナルを起動
  vim.fn.termopen(script_path .. ' --output ' .. tempfile, {
    on_exit = function(_, exit_code, _)
      -- ウィンドウが有効なら閉じる
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      -- 結果を読み取って挿入
      vim.schedule(function()
        local f = io.open(tempfile, 'r')
        if f then
          local result = f:read('*a')
          f:close()
          os.remove(tempfile)
          if result and result ~= '' then
            result = result:gsub('\n$', '')
            vim.api.nvim_put({result}, 'c', true, true)
          end
        end
      end)
    end,
  })
  vim.cmd('startinsert')
end

vim.keymap.set('n', '<leader>nl', insert_nb_link, { noremap = true, silent = true, desc = "Insert nb link" })
vim.keymap.set('i', '<C-l>', function()
  vim.cmd('stopinsert')
  insert_nb_link()
end, { noremap = true, silent = true, desc = "Insert nb link" })

-- 背景を透明にしてWezTermの透過設定を反映 -------------------------
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
  end,
})

-- 初回起動時にも適用（ColorSchemeイベントが発火しない場合の対策）
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
-----------------------------------------------------------------------
