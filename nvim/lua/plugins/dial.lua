---@type LazySpec
return {
  "monaqa/dial.nvim",
  lazy = true,
  event = "VeryLazy",
  desc = "Increment and decrement numbers, dates, and more",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          v = {
            ["<C-a>"] = {
              function() return require("dial.map").manipulate("increment", "visual") end,
              desc = "Increment",
            },
            ["<C-x>"] = {
              function() return require("dial.map").manipulate("decrement", "visual") end,
              desc = "Decrement",
            },
          },
          x = {
            ["g<C-a>"] = {
              function() return require("dial.map").manipulate("increment", "gvisual") end,
              desc = "Increment",
            },
            ["g<C-x>"] = {
              function() return require("dial.map").manipulate("decrement", "gvisual") end,
              desc = "Decrement",
            },
          },
          n = {
            ["<C-a>"] = {
              function() return require("dial.map").manipulate("increment", "normal") end,
              desc = "Increment",
            },
            ["<C-x>"] = {
              function() return require("dial.map").manipulate("decrement", "normal") end,
              desc = "Decrement",
            },
            ["g<C-a>"] = {
              function() return require("dial.map").manipulate("increment", "gnormal") end,
              desc = "Increment",
            },
            ["g<C-x>"] = {
              function() return require("dial.map").manipulate("decrement", "gnormal") end,
              desc = "Decrement",
            },
          },
        },
      },
    },
  },
  opts = function()
    local augend = require "dial.augend"

    local logical_alias = augend.constant.new {
      elements = { "&&", "||" },
      word = true,
      cyclic = true,
    }

    local and_or = augend.constant.new {
      elements = {
        "and",
        "or",
      },
      word = true,
      cyclic = true,
    }

    local ordinal_numbers = augend.constant.new {
      -- elements through which we cycle. When we increment, we go down
      -- On decrement we go up
      elements = {
        "first",
        "second",
        "third",
        "fourth",
        "fifth",
        "sixth",
        "seventh",
        "eighth",
        "ninth",
        "tenth",
      },
      -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
      word = false,
      -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
      -- Otherwise nothing will happen when there are no further values
      cyclic = true,
    }

    local weekdays = augend.constant.new {
      elements = {
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      },
      word = true,
      cyclic = true,
    }

    local months = augend.constant.new {
      elements = {
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      },
      word = true,
      cyclic = true,
    }

    local capitalized_boolean = augend.constant.new {
      elements = {
        "True",
        "False",
      },
      word = true,
      cyclic = true,
    }

    local import_export = augend.constant.new {
      elements = {
        "import",
        "export",
      },
      word = true,
      cyclic = true,
    }
    local yes_no = augend.constant.new {
      elements = {
        "yes",
        "no",
      },
      word = true,
      cyclic = true,
    }

    return {
      groups = {
        default = {
          augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
          augend.integer.alias.decimal_int, -- nonnegative and negative decimal number
          augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
          augend.date.alias["%Y/%m/%d"], -- date (2022/02/18, etc.)
          ordinal_numbers,
          weekdays,
          months,
          capitalized_boolean,
          augend.constant.alias.bool, -- boolean value (true <-> false)
          logical_alias,
          and_or,
          yes_no,
        },
        ssa = {
          augend.constant.new {
            elements = {
              "640",
              "1920",
            },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "360",
              "1080",
            },
            word = true,
            cyclic = true,
          },
        },
        vue = {
          augend.constant.new { elements = { "let", "const" } },
          import_export,
          augend.hexcolor.new { case = "lower" },
          augend.hexcolor.new { case = "upper" },
          augend.constant.new {
            elements = {
              "|",
              "&",
            },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "!=",
              "==",
            },
            word = false,
            cyclic = true,
          },
        },
        typescript = {
          augend.constant.new { elements = { "let", "const" } },
          import_export,
        },
        css = {
          augend.hexcolor.new {
            case = "lower",
          },
          augend.hexcolor.new {
            case = "upper",
          },
        },
        markdown = {
          augend.constant.new {
            elements = { "[ ]", "[x]" },
            word = false,
            cyclic = true,
          },
          augend.misc.alias.markdown_header,
        },
        json = {
          augend.semver.alias.semver, -- versioning (v1.1.2)
        },
        lua = {
          augend.constant.new {
            elements = { "~=", "==" },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "if",
              "else",
              "elseif",
            },
            word = false,
            cyclic = true,
          },
        },
        python = {
          import_export,
          augend.constant.new {
            elements = {
              "if",
              "else",
              "elif",
            },
            word = false,
            cyclic = true,
          },
        },
      },
    }
  end,
  config = function(_, opts)
    local dial_config = require "dial.config"
    -- copy defaults to each group
    for name, group in pairs(opts.groups) do
      if name ~= "default" then vim.list_extend(group, opts.groups.default) end
    end
    dial_config.augends:register_group(opts.groups)
    dial_config.augends:on_filetype(opts.groups)
  end,
}
