local uv = vim.uv or vim.loop

---@type LazySpec
return {
  "folke/snacks.nvim",
  optional = true,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      optional = true,
      opts = function(_, opts)
        if opts.ensure_installed ~= "all" then
          opts.ensure_installed =
            require("astrocore").list_insert_unique(opts.ensure_installed, { "markdown", "markdown_inline" })
        end
      end,
    },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>fH"] = {
          function()
            require("snacks").picker.highlights {
              confirm = function(picker, item)
                vim.fn.setreg("+", item.hl_group)
                local buf = item.buf or vim.api.nvim_win_get_buf(picker.main)
                local ft = vim.bo[buf].filetype
                require("snacks").notify(
                  ("Yanked to register `%s`:\n```%s\n%s\n```"):format("+", ft, item.hl_group),
                  { title = "Snacks Picker" }
                )
                picker:close()
              end,
            }
          end,
          desc = "Find highlight colors",
        }

        -- Snacks.dashboard mappins
        maps.n["<F2>"] = {
          function()
            if vim.bo.filetype == "snacks_dashboard" then
              require("astrocore.buffer").close()
            else
              require("snacks").dashboard()
            end
          end,
          desc = "Home Screen",
        }
        maps.n["<Leader>fl"] = {
          function()
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
                require("snacks").notify(
                  ("Set filetype to `%s %s`"):format(icon, item.text),
                  { title = "Snacks Picker" }
                )
              end,
            }
          end,
          desc = "Find & Set language (filetype)",
        }
        maps.n["<Leader>fn"] = {
          function()
            require("snacks").picker.notifications {
              confirm = function(picker, item)
                vim.fn.setreg("+", item.item.msg)
                local buf = item.buf or vim.api.nvim_win_get_buf(picker.main)
                local ft = vim.bo[buf].filetype
                require("snacks").notify(
                  ("Yanked to register `%s`:\n```%s\n%s\n```"):format("+", ft, item.item.msg),
                  { title = "Snacks Picker" }
                )
                picker:close()
              end,
            }
          end,
          desc = "Find notifications",
        }
        maps.n["<Leader>fi"] = {
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
          desc = "Find icons",
        }
        maps.n["<Leader>fI"] = {
          function()
            local icons = {}
            for kind, icon in pairs(require("astroui").config["icons"]) do
              if type(icon) == "string" then table.insert(icons, { text = kind, glyph = icon, cat = "Astro_UI" }) end
            end
            if require("astrocore").is_available "mini.icons" then
              local function add_cat(categories)
                for _, cat in ipairs(categories) do
                  for _, kind in ipairs(require("mini.icons").list(cat)) do
                    table.insert(icons, { text = kind, cat = cat, is_mini_icon = true })
                  end
                end
              end
              add_cat { "directory", "extension", "file", "filetype", "lsp", "os" }
            end

            require("snacks").picker {
              items = icons,
              source = "Astro_UI_Icons",
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
                    icon, _ = require("snacks.util").icon(item.text, item.cat)
                  end
                  vim.fn.setreg("+", icon)
                  local buf = item.buf or vim.api.nvim_win_get_buf(picker.main)
                  local ft = vim.bo[buf].filetype
                  require("snacks").notify(
                    ("Yanked to register `%s`:\n```%s\n%s\n```"):format("+", ft, icon),
                    { title = "Snacks Picker" }
                  )
                end,
                "close",
              },
            }
          end,
          desc = "Find Nvim icons",
        }
        maps.n["<Leader>fo"] = {
          function()
            require("snacks").picker.smart {
              multi = { "recent" },
              format = "file", -- use `file` format for all sources
              matcher = {
                cwd_bonus = false, -- boost cwd matches
                frecency = true, -- use frecency boosting
                sort_empty = false, -- sort even when the filter is empty
                history_bonus = true,
              },
              transform = "unique_file",
              sort_lastused = true,
            }
          end,
          desc = "Find old files",
        }
        maps.n["<Leader>fO"] = {
          function()
            require("snacks").picker.recent {
              filter = {
                cwd = true,
              },
            }
          end,
          desc = "Find old files (cwd)",
        }
        maps.n["<Leader>fh"] = {
          function()
            require("snacks").picker.help {
              confirm = function(picker, item) require("snacks").picker.actions.help(picker, item, { cmd = "vsplit" }) end,
            }
          end,
          desc = "Find help",
        }
      end,
    },
  },
  opts = {
    dashboard = {
      sections = {
        -- BUG: https://github.com/folke/snacks.nvim/pull/1643
        {
          section = "terminal",
          cmd = "fortune -s | cowsay",
          hl = "header",
          padding = 1,
          indent = 10,
          height = 12,
        },
        { section = "keys", indent = 0, padding = 1, gap = 1 },
        {
          icon = "",
          title = "Recent Files",
          section = "recent_files",
          limit = 5,
          indent = 3,
          padding = 1,
        },
        { icon = "", title = "Projects", section = "projects", limit = 5, indent = 3, padding = 1 },
        -- { section = "startup" },
      },
    },
    image = {
      force = true,
      doc = {
        enabled = true,
      },
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
      -- img_src_maps = { ["^@assets"] = { "src/assets", "src/assets2" } },  -- Use string:gsub, so make sure to escape if you need litteral string.
      img_src_maps = { ["^@assets"] = "src/assets" },
      -- img_src_maps = function(buf_path, img_src) end

      -- The 3rd type can return 2 types above or string. If return string = "XXX" -> img_src = "XXX".
      -- img_src is relative source of the image.
      -- In the example of vue above img_src is src attribute in <img> tag = "@assets/logo.svg"

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
          local cwd = uv.cwd() or "."
          local checks = { [img_src] = true }
          local srcs = { img_src }

          if type(Snacks.image.config.img_src_maps) == "function" then
            img_src_maps = Snacks.image.config.img_src_maps(buf_path, img_src)
            if type(img_src_maps) == "string" then img_src = img_src_maps end
          end
          if type(img_src_maps) == "table" then
            for pattern, replacement in pairs(img_src_maps) do
              if type(replacement) == "string" then
                srcs[#srcs + 1] = img_src:gsub(pattern, replacement)
              elseif type(replacement) == "table" then
                for _, r in ipairs(replacement) do
                  srcs[#srcs + 1] = img_src:gsub(pattern, r)
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
          vim.notify(vim.inspect(checks))
          for f in pairs(checks) do
            if vim.fn.filereadable(f) == 1 then
              img_src = uv.fs_realpath(f) or f
              break
            end
          end
        end
        img_src = vim.fs.normalize(img_src)
        return img_src
      end,
      max_height = 20,
    },
    quickfile = {},
    lazygit = {},
    ---@type snacks.picker.Config
    picker = {
      win = {
        input = {
          keys = {
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
            ["<c-j>"] = { "select_and_next", mode = { "i", "n" } },
            ["<c-k>"] = { "select_and_prev", mode = { "i", "n" } },
          },
        },
      },
    },
  },
}
