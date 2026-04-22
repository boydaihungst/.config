-- mapping tree-sitter language to filetype (mostly custom filetype in 00_options.lua)
local treesitter_map_lang_with_filetype = {
  scss = { "less", "postcss" },
  bash = "kitty",
  xml = { "msbuild" },
}

local ensure_installed_treesitter = {
  "bash",
  "c",
  "c_sharp",
  "css",
  "dap_repl",
  "diff",
  "fish",
  "git_config",
  "gitignore",
  "graphql",
  "html",
  "hyprlang",
  "java",
  "javascript",
  "json",
  "json5",
  "latex",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "rasi",
  "regex",
  "rust",
  "scss",
  "svelte",
  "tsx",
  "typescript",
  "typst",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
  "xml",
  "sql",
  "jsdoc",
  "astro",
  "cpp",
  "objc",
  "cuda",
  "proto",
  "dockerfile",
  "styled",
  "hyprlang",
  "kotlin",
  "luap",
  "nginx",
  "toml",
  "sql",
  "java",
}

later(function()
  -- Define hook to update tree-sitter parsers after plugin  updated
  vim.pack.on_packchanged("nvim-treesitter", { "update" }, function() vim.cmd "TSUpdate" end, ":TSUpdate")

  add {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    "https://github.com/RRethy/nvim-treesitter-endwise",
    "https://github.com/andersevenrud/nvim_context_vt", -- Shows virtual text of the current context after functions, methods, statements, etc.
  }
  require("nvim-treesitter").install(ensure_installed_treesitter)
  local available_parsers = require("nvim-treesitter").get_available()

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- check if parser exists and load it
    if not vim.treesitter.language.add(language) then return end
    -- enables syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)
    -- enables treesitter based indentation
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
  for lang, filetype in ipairs(treesitter_map_lang_with_filetype) do
    vim.treesitter.language.register(lang, filetype)
  end

  Config.new_autocmd("FileType", "*", function(args)
    local buf, filetype = args.buf, args.match
    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    if Config.is_large(buf) then
      vim.treesitter.stop(args.buf)
      return
    end

    local installed_parsers = require("nvim-treesitter").get_installed "parsers"

    if vim.tbl_contains(installed_parsers, language) then
      -- enable the parser if it is installed
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
      require("nvim-treesitter").install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
      treesitter_try_attach(buf, language)
    end
  end, "Tree-sitter auto install and start parser")

  require("nvim_context_vt").setup {
    prefix = Config.get_custom_icon "ArrowRight",
  }

  -- enable treesitter extra plugins
  require("treesitter-context").setup {
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    multiwindow = false, -- Enable multiwindow support.
    max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 5, -- Maximum number of lines to show for a single context
    trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator  set, the context will only show up when there are at least 2 lines above cursorline.
    separator = "─",
    zindex = 20, -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
  }

  require("nvim-treesitter-textobjects").setup {
    select = { lookahead = true },
  }

  vim.keymap.set("n", "\\T", "<Cmd>TSContext toggle<CR>", { desc = "Toggle treesitter context" })

  -- More text objects mappings
  local ts_select = require "nvim-treesitter-textobjects.select"

  local select_maps = {
    ["ak"] = { "@block.outer", "around block" },
    ["ik"] = { "@block.inner", "inside block" },
    ["ac"] = { "@class.outer", "around class" },
    ["ic"] = { "@class.inner", "inside class" },
    ["a?"] = { "@conditional.outer", "around conditional" },
    ["i?"] = { "@conditional.inner", "inside conditional" },
    ["af"] = { "@function.outer", "around function" },
    ["if"] = { "@function.inner", "inside function" },
    ["ao"] = { "@loop.outer", "around loop" },
    ["io"] = { "@loop.inner", "inside loop" },
    ["aa"] = { "@parameter.outer", "around argument" },
    ["ia"] = { "@parameter.inner", "inside argument" },
  }

  for key, val in pairs(select_maps) do
    vim.keymap.set(
      { "x", "o" },
      key,
      function() ts_select.select_textobject(val[1], "textobjects") end,
      { desc = val[2] }
    )
  end
  local ts_move = require "nvim-treesitter-textobjects.move"

  local move_maps = {
    -- Next Start
    ["]k"] = { ts_move.goto_next_start, "@block.outer", "Next block start" },
    ["]f"] = { ts_move.goto_next_start, "@function.outer", "Next function start" },
    ["]a"] = { ts_move.goto_next_start, "@parameter.inner", "Next argument start" },
    -- Next End
    ["]K"] = { ts_move.goto_next_end, "@block.outer", "Next block end" },
    ["]F"] = { ts_move.goto_next_end, "@function.outer", "Next function end" },
    ["]A"] = { ts_move.goto_next_end, "@parameter.inner", "Next argument end" },
    -- Previous Start
    ["[k"] = { ts_move.goto_previous_start, "@block.outer", "Previous block start" },
    ["[f"] = { ts_move.goto_previous_start, "@function.outer", "Previous function start" },
    ["[a"] = { ts_move.goto_previous_start, "@parameter.inner", "Previous argument start" },
    -- Previous End
    ["[K"] = { ts_move.goto_previous_end, "@block.outer", "Previous block end" },
    ["[F"] = { ts_move.goto_previous_end, "@function.outer", "Previous function end" },
    ["[A"] = { ts_move.goto_previous_end, "@parameter.inner", "Previous argument end" },
  }

  for key, val in pairs(move_maps) do
    vim.keymap.set({ "n", "x", "o" }, key, function() val[1](val[2], "textobjects") end, { desc = val[3] })
  end
  local ts_swap = require "nvim-treesitter-textobjects.swap"

  local swap_maps = {
    -- Swap Next
    [">K"] = { ts_swap.swap_next, "@block.outer", "Swap next block" },
    [">F"] = { ts_swap.swap_next, "@function.outer", "Swap next function" },
    [">A"] = { ts_swap.swap_next, "@parameter.inner", "Swap next argument" },
    -- Swap Previous
    ["<K"] = { ts_swap.swap_previous, "@block.outer", "Swap previous block" },
    ["<F"] = { ts_swap.swap_previous, "@function.outer", "Swap previous function" },
    ["<A"] = { ts_swap.swap_previous, "@parameter.inner", "Swap previous argument" },
  }

  for key, val in pairs(swap_maps) do
    vim.keymap.set("n", key, function() val[1](val[2]) end, { desc = val[3] })
  end
end)
