now(function()
  add { "https://github.com/folke/snacks.nvim" }
  local snacks = require "snacks"

  local get_icon = Config.get_custom_icon
  ---@type snacks.Config
  local opts = {
    bigfile = {
      notify = true, -- show notification when big file detected
      size = Config.default_large_buf_opts.size,
      line_length = Config.default_large_buf_opts.line_length, -- average line length (useful for minified files)
      -- Enable or disable features when big file detected
      ---@param ctx {buf: number, ft:string}
      setup = function(ctx)
        if vim.fn.exists ":NoMatchParen" ~= 0 then vim.cmd [[NoMatchParen]] end
        snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
        vim.bo.undofile = false
        vim.bo.swapfile = false
        vim.b.completion = false
        vim.b.minianimate_disable = true
        vim.b.minihipatterns_disable = true
        vim.b.minimap_disable = true
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then vim.bo[ctx.buf].syntax = ctx.ft end
        end)
      end,
    },
    statuscolumn = {
      left = { "fold", "mark" }, -- priority of signs on the left (high to low)
      right = { "sign", "git" }, -- priority of signs on the right (high to low)
      folds = {
        open = true, -- show open fold icons
        git_hl = false, -- use Git Signs hl for fold icons
      },
      git = {
        -- patterns to match Git signs
        patterns = { "GitSign", "MiniDiffSign" },
      },
      refresh = 50, -- refresh at most every 50ms
    },
    dashboard = {
      enabled = false,
    },
    -- configure `vim.ui.input`
    input = {},
    -- render image support
    image = {
      force = true,
      doc = { enabled = true },
      formats = {
        "png",
        "jpg",
        "jpeg",
        "gif",
        "bmp",
        "webp",
        "tiff",
        "heic",
        "avif",
        "mp4",
        "mov",
        "avi",
        "mkv",
        "webm",
        "pdf",
        "svg",
      },
      img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },

      -- Support 3 types.
      -- img_src_maps = { ["^@assets"] = { "src/assets", "src/assets2" } },
      -- This use string:gsub(src_map), so make sure to escape if you need litteral string.
      img_src_maps = { ["^@assets"] = "src/assets" },
      -- img_src_maps = function(buf_path, img_src) end

      -- The 3rd type can return 2 types above or string. If return string = "XXX" -> img_src = "XXX".
      -- img_src  relative source of the image.
      -- In the example of vue above img_src  src attribute in <img> tag = "@assets/logo.svg"

      -- img_src_maps = function(buf_path, img_src) return { ["^@assets"] = "src/assets" } end,
      -- img_src_maps = function(buf_path, img_src) return "src/assets/logo.svg" end,
      env = {
        placeholders = true,
      },
      ---@param buf_path string
      ---@param img_src string
      resolve = function(buf_path, img_src)
        local Snacks = require "snacks"
        if not img_src:find "^%w%w+://" then
          local img_src_maps = Snacks.image.config.img_src_maps
          local cwd = vim.uv.cwd() or "."
          local checks = { [img_src] = true }
          local srcs = { img_src }

          if type(Snacks.image.config.img_src_maps) == "function" then
            img_src_maps = Snacks.image.config.img_src_maps(buf_path, img_src)
            if type(img_src_maps) == "string" then
              img_src = img_src_maps
              checks[img_src] = true
            end
          end
          if type(img_src_maps) == "table" then
            for pattern, replacement in pairs(img_src_maps) do
              if type(replacement) == "string" then
                srcs[#srcs + 1] = img_src:gsub(pattern, replacement)
                checks[srcs[#srcs]] = true
              elseif type(replacement) == "table" then
                for _, r in ipairs(replacement) do
                  srcs[#srcs + 1] = img_src:gsub(pattern, r)
                  checks[srcs[#srcs]] = true
                end
              end
            end
          end

          for _, root in ipairs { cwd, vim.fs.dirname(buf_path) } do
            for _, new_src in ipairs(srcs) do
              checks[root .. "/" .. new_src] = true
              for _, dir in ipairs(Snacks.image.config.img_dirs) do
                dir = root .. "/" .. dir
                if Snacks.image.doc.is_dir(dir) then checks[dir .. "/" .. new_src] = true end
              end
            end
          end
          for f in pairs(checks) do
            if vim.fn.filereadable(f) == 1 then
              img_src = vim.uv.fs_realpath(f) or f
              break
            end
          end
        end
        img_src = vim.fs.normalize(img_src)
        return img_src
      end,
      max_height = 20,
    },
    -- configure `vim.notify`
    notifier = {
      icons = {
        debug = get_icon "Debugger",
        error = get_icon "DiagnosticError",
        info = get_icon "DiagnosticInfo",
        trace = get_icon "DiagnosticHint",
        warn = get_icon "DiagnosticWarn",
      },
    },
    -- Load file as quickly as possible if run `nvim somefile`
    quickfile = {},
    -- configure picker and `vim.ui.select`
    picker = {
      ui_select = true,
      win = {
        input = {
          keys = {
            -- Scroll list window.
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
            -- Select multiple result items
            ["<M-j>"] = { "select_and_next", mode = { "i", "n" } },
            ["<M-k>"] = { "select_and_prev", mode = { "i", "n" } },
            -- Scroll preview window. Use <M-w> to switch focus between preview, list and input window
            ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
          },
        },
      },
    },
    -- indent line
    indent = {
      indent = { char = "▏" },
      filter = function(bufnr)
        return Config.is_valid_buf(bufnr)
          and not Config.is_large(bufnr)
          and vim.g.snacks_indent ~= false
          and vim.b[bufnr].snacks_indent ~= false
      end,
      animate = {
        enabled = true,
        style = "out",
        easing = "linear",
        duration = {
          step = 20, -- ms per step
          total = 200, -- maximum duration
        },
      },
      ---@class snacks.indent.Scope.Config: snacks.scope.Config
      scope = {
        enabled = true, -- enable highlighting the current scope
        priority = 200,
        char = "▏",
        underline = false, -- underline the start of the scope
        only_current = false, -- only show scope in the current window
        hl = "SnacksIndentScope", ---@type string|string[] hl group for scopes
      },
      chunk = {
        -- when enabled, scopes will be rendered as chunks, except for the
        -- top-level scope which will be rendered as a scope.
        enabled = true,
        -- only show chunk scopes in the current window
        only_current = false,
        priority = 200,
        hl = "SnacksIndentChunk", ---@type string|string[] hl group for chunk scopes
        char = {
          corner_top = "┌",
          corner_bottom = "└",
          -- corner_top = "╭",
          -- corner_bottom = "╰",
          horizontal = "─",
          vertical = "│",
          arrow = ">",
        },
      },
    },
    scope = {
      filter = function(bufnr)
        return Config.is_valid_buf(bufnr)
          and not Config.is_large(bufnr)
          and vim.g.snacks_scope ~= false
          and vim.b[bufnr].snacks_scope ~= false
      end,
    },
    words = {
      enabled = true,
      filter = function(bufnr)
        return Config.is_valid_buf(bufnr)
          and not Config.is_large(bufnr)
          and vim.g.snacks_words ~= false
          and vim.b[bufnr].snacks_words ~= false
      end,
    },
  }

  snacks.setup(opts)

  if vim.tbl_get(opts, "indent", "enabled") ~= false then
    vim.keymap.set("n", "\\i", function() snacks.toggle.indent():toggle() end, { desc = "Toggle indent" })
  end

  if vim.tbl_get(opts, "notifier", "enabled") ~= false then
    vim.keymap.set("n", "\\n", function() snacks.notifier.hide() end, { desc = "Dismiss notifications" })
  end
  -- Snacks.gitbrowse
  if vim.tbl_get(opts, "gitbrowse", "enabled") ~= false and vim.fn.executable "git" == 1 then
    vim.keymap.set({ "n", "x" }, "<Leader>go", function() snacks.gitbrowse() end, { desc = "Git browse (open)" })
  end
  if vim.tbl_get(opts, "picker", "enabled") ~= false then
    -- Git Pickers
    if vim.fn.executable "git" == 1 then
      vim.keymap.set("n", "<Leader>gb", function() snacks.picker.git_branches() end, { desc = "Git branches" })
      vim.keymap.set("n", "<Leader>gc", function() snacks.picker.git_log() end, { desc = "Git commits (repository)" })
      vim.keymap.set(
        "n",
        "<Leader>gC",
        function() snacks.picker.git_log { current_file = true, follow = true } end,
        { desc = "Git commits (current file)" }
      )
      vim.keymap.set("n", "<Leader>gt", function() snacks.picker.git_status() end, { desc = "Git status" })
      vim.keymap.set("n", "<Leader>gT", function() snacks.picker.git_stash() end, { desc = "Git stash" })
      vim.keymap.set("n", "<Leader>gh", function() snacks.picker.git_diff() end, { desc = "Git hunks" })
      vim.keymap.set("n", "<Leader>fg", function() snacks.picker.git_files() end, { desc = "Find git files" })
    end
    -- General Pickers
    vim.keymap.set("n", "<Leader>f<Cr>", function() snacks.picker.resume() end, { desc = "Resume previous search" })
    vim.keymap.set("n", "<Leader>f/", function() snacks.picker.search_history() end, { desc = "Search history" })
    vim.keymap.set("n", "<Leader>f'", function() snacks.picker.marks() end, { desc = "Find marks" })
    vim.keymap.set("n", "<Leader>fL", function()
      snacks.picker.lsp_config {
        confirm = function(picker, item)
          picker:close()
          vim.notify(vim.inspect(item))
        end,
      }
    end, { desc = "Find default lsp configs" })
    vim.keymap.set("n", "<Leader>fl", function()
      local filetypes = {}
      for _, ft in ipairs(vim.fn.getcompletion("", "filetype")) do
        table.insert(filetypes, { text = ft, name = ft })
      end

      require("snacks").picker {
        items = filetypes,
        source = "filetypes",
        layout = {
          layout = {
            backdrop = false,
            row = 1,
            width = 0.4,
            min_width = 30,
            height = 0.9,
            border = "none",
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            { win = "list", border = "rounded" },
          },
        },
        format = function(item)
          local icon, icon_hl = require("snacks.util").icon(item.text, "filetype")
          return {
            { icon .. " ", icon_hl },
            { item.text },
          }
        end,
        confirm = function(picker, item)
          picker:close()
          vim.cmd.set("ft=" .. item.text)
          local icon, _ = require("snacks.util").icon(item.text, "filetype")
          require("snacks").notify(("Set filetype to `%s %s`"):format(icon, item.text), { title = "Snacks Picker" })
        end,
      }
    end, { desc = "Find & Set language (filetype)" })
    vim.keymap.set(
      "n",
      "<Leader>fa",
      function() snacks.picker.files { dirs = { vim.fn.stdpath "config" }, desc = "Config Files" } end,
      { desc = "Find config files" }
    )
    vim.keymap.set("n", "<Leader>fb", function() snacks.picker.buffers() end, { desc = "Find buffers" })
    vim.keymap.set("n", "<Leader>fc", function() snacks.picker.grep_word() end, { desc = "Find word under cursor" })
    vim.keymap.set("n", "<Leader>fC", function() snacks.picker.commands() end, { desc = "Find commands" })
    vim.keymap.set(
      "n",
      "<Leader>ff",
      function()
        snacks.picker.files {
          hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
        }
      end,
      { desc = "Find files" }
    )
    vim.keymap.set(
      "n",
      "<Leader>fF",
      function() snacks.picker.files { hidden = true, ignored = true } end,
      { desc = "Find all files" }
    )
    vim.keymap.set("n", "<Leader>fh", function()
      require("snacks").picker.help {
        confirm = function(picker, item) require("snacks").picker.actions.help(picker, item, { cmd = "vsplit" }) end,
      }
    end, { desc = "Find help" })
    vim.keymap.set("n", "<Leader>fH", function()
      require("snacks").picker.highlights {
        confirm = function(picker, item)
          vim.fn.setreg("+", item.hl_group)
          require("snacks").notify(
            ("Yanked to register `%s`:\n`%s`"):format("+", item.hl_group),
            { title = "Snacks Picker" }
          )
          picker:close()
        end,
      }
    end, { desc = "Find highlight colors" })
    vim.keymap.set("n", "<Leader>fk", function()
      require("snacks").picker.keymaps {
        layout = {
          layout = {
            backdrop = false,
            row = 1,
            width = 0,
            min_width = 30,
            height = 0.9,
            border = "none",
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            { win = "list", height = 0.8, border = "rounded" },
            { win = "preview", height = 0.2, border = "rounded" },
          },
        },
        confirm = function(picker, item)
          picker:close()
          if item.info and item.info.linedefined then
            vim.api.nvim_command("edit +" .. item.info.linedefined .. " " .. item.file)
          elseif item.item and item.item.rhs then
            vim.fn.setreg("+", item.item.rhs)
            require("snacks").notify(
              ("Yanked to register `%s`:\n`%s`"):format("+", item.item.rhs),
              { title = "Snacks Picker" }
            )
          end
        end,
      }
    end, { desc = "Find keymaps" })
    vim.keymap.set("n", "<Leader>fm", function() snacks.picker.man() end, { desc = "Find man" })
    vim.keymap.set("n", "<Leader>fn", function()
      require("snacks").picker.notifications {
        confirm = function(picker, item)
          vim.fn.setreg("+", item.item.msg)
          require("snacks").notify(("Yanked to register `%s`"):format "+", { title = "Snacks Picker" })
          picker:close()
        end,
      }
    end, { desc = "Find notifications" })
    vim.keymap.set(
      "n",
      "<Leader>fi",
      function()
        require("snacks").picker.icons {
          icon_sources = { "nerd_fonts", "emoji" },
          finder = "icons",
          format = "icon",
          layout = {
            layout = {
              backdrop = false,
              row = 1,
              width = 0.4,
              min_width = 30,
              height = 0.9,
              border = "none",
              box = "vertical",
              {
                win = "input",
                height = 1,
                border = "rounded",
                title = "{title} {live} {flags}",
                title_pos = "center",
              },
              { win = "list", border = "rounded" },
            },
          },
          confirm = { "copy", "close" },
        }
      end,
      { desc = "Find icons" }
    )
    vim.keymap.set("n", "<Leader>fI", function()
      local icons = {}
      for kind, icon in pairs(Config.icons.icons) do
        if type(icon) == "string" then table.insert(icons, { text = kind, glyph = icon, cat = "Custom" }) end
      end
      if MiniIcons then
        local function add_cat(categories)
          for _, cat in ipairs(categories) do
            for _, kind in ipairs(MiniIcons.list(cat)) do
              table.insert(icons, { text = kind, cat = cat, is_mini_icon = true })
            end
          end
        end
        add_cat { "directory", "extension", "file", "filetype", "lsp", "os" }
      end

      require("snacks").picker {
        items = icons,
        source = "All Icons",
        layout = {
          layout = {
            backdrop = false,
            row = 1,
            width = 0.4,
            min_width = 30,
            height = 0.9,
            border = "none",
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            { win = "list", border = "rounded" },
          },
        },
        format = function(item)
          local icon, icon_hl
          local text_hl = "SnacksPickerIconName"
          if item.is_mini_icon then
            icon, icon_hl = require("snacks.util").icon(item.text, item.cat)
            text_hl = icon_hl or "SnacksPickerIconName"
          else
            icon, icon_hl = item.glyph, "SnacksPickerIcon"
          end
          local a = require("snacks").picker.util.align
          local ret = {} ---@type snacks.picker.Highlight[]
          ret[#ret + 1] = { a(icon, 2), icon_hl }
          ret[#ret + 1] = { " " }
          ret[#ret + 1] = { a(item.text, 30), text_hl }
          ret[#ret + 1] = { " " }
          ret[#ret + 1] = { a(item.cat, 20), "SnacksPickerIconCategory" }
          return ret
        end,
        -- Paste selected icon to cursor and icon + icon text to clipboard
        confirm = {
          "copy",
          function(picker, item)
            -- Copy icon
            local icon = item.glyph
            if item.is_mini_icon then
              icon, _ = snacks.util.icon(item.text, item.cat)
            end
            vim.fn.setreg("+", icon)
            local buf = item.buf or vim.api.nvim_win_get_buf(picker.main)
            local ft = vim.bo[buf].filetype
            snacks.notify(
              ("Yanked to register `%s`:\n```%s\n%s\n```"):format("+", ft, icon),
              { title = "Snacks Picker" }
            )
          end,
          "close",
        },
      }
    end, { desc = "Find custom icons" })
    vim.keymap.set("n", "<Leader>fo", function()
      require("snacks").picker.recent {
        -- filter = { cwd = false },
        sort_lastused = true,
        matcher = {
          cwd_bonus = false, -- boost cwd matches
          frecency = true, -- use frecency boosting
          history_bonus = true,
        },
      }
      -- require("snacks").picker.smart {
      --   multi = { "buffers", "recent" },
      --   format = "file", -- use `file` format for all sources
      --   matcher = {
      --     cwd_bonus = false, -- boost cwd matches
      --     frecency = false, -- use frecency boosting
      --     sort_empty = false, -- sort even when the filter is empty
      --     history_bonus = false,
      --   },
      --   transform = "unique_file",
      --   sort_lastused = true,
      -- }
    end, { desc = "Find old files" })
    vim.keymap.set("n", "<Leader>fO", function()
      require("snacks").picker.smart {
        multi = { "buffers", "recent", "files" },
        format = "file", -- use `file` format for all sources
        matcher = {
          cwd_bonus = true, -- boost cwd matches
          frecency = true, -- use frecency boosting
          sort_empty = false, -- sort even when the filter is empty
          history_bonus = true,
        },
        transform = "unique_file",
        sort_lastused = true,
        filter = {
          cwd = true,
        },
      }
    end, { desc = "Find old files (cwd)" })
    vim.keymap.set(
      "n",
      "<Leader>fp",
      function()
        snacks.picker.projects {
          dev = { "~/dev", "~/projects", "~/code", "~/workspace", "~/git" },
        }
      end,
      { desc = "Find projects" }
    )
    vim.keymap.set("n", "<Leader>fr", function() snacks.picker.registers() end, { desc = "Find registers" })
    vim.keymap.set("n", "<Leader>fs", function() snacks.picker.smart() end, { desc = "Find buffers/recent/files" })
    vim.keymap.set("n", "<Leader>ft", function() snacks.picker.colorschemes() end, { desc = "Find themes" })
    vim.keymap.set("n", "<Leader>fu", function() snacks.picker.undo() end, { desc = "Find undo history" })
  end
  -- Grep (requires ripgrep)
  if vim.fn.executable "rg" == 1 then
    vim.keymap.set("n", "<Leader>fw", function() snacks.picker.grep() end, { desc = "Find words" })
    vim.keymap.set(
      "n",
      "<Leader>fW",
      function() snacks.picker.grep { hidden = true, ignored = true } end,
      { desc = "Find words in all files" }
    )
  end

  -- LSP Pickers
  vim.keymap.set("n", "<Leader>lD", function() snacks.picker.diagnostics() end, { desc = "Search diagnostics" })
  vim.keymap.set("n", "<Leader>ls", function()
    local aerial_avail, aerial = pcall(require, "aerial")
    if aerial_avail and aerial.snacks_picker then
      aerial.snacks_picker()
    else
      snacks.picker.lsp_symbols()
    end
  end, { desc = "Search symbols" })

  if vim.tbl_get(opts, "words", "enabled") ~= false then
    vim.keymap.set("n", "\\w", function() snacks.toggle.words():toggle() end, { desc = "Toggle cursor word highlight" })
    vim.keymap.set("n", "]r", function() snacks.words.jump(vim.v.count1) end, { desc = "Next reference" })
    vim.keymap.set("n", "[r", function() snacks.words.jump(-vim.v.count1) end, { desc = "Previous reference" })
  end
end)
