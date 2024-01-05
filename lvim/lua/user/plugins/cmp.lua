local luasnip                            = require('luasnip')
local cmp                                = require("cmp")
local lvim_core_cmp                      = require('lvim.core.cmp')
local jumpable                           = lvim_core_cmp.methods.jumpable
local has_words_before                   = lvim_core_cmp.methods.has_words_before

lvim.builtin.cmp.cmdline.enable          = true
-- lvim.builtin.cmp.experimental.ghost_text = true
lvim.builtin.cmp.preselect               = cmp.PreselectMode.None

lvim.builtin.cmp.mapping["<Tab>"]        = cmp.mapping(function(fallback)
  if cmp.visible() then
    local selectBehavior = (
          luasnip.jumpable(-1) or luasnip.jumpable(1) or vim.b.visual_multi) and
        cmp.SelectBehavior.Select or
        cmp.SelectBehavior.Insert
    cmp.select_next_item({ behavior = selectBehavior })
  elseif luasnip.expand_or_locally_jumpable() then
    luasnip.expand_or_jump()
  elseif jumpable(1) then
    luasnip.jump(1)
  elseif has_words_before() then
    -- cmp.complete()
    fallback()
  else
    fallback()
  end
end, { "i", "s" })

lvim.builtin.cmp.mapping["<S-Tab>"]      = cmp.mapping(function(fallback)
  if cmp.visible() then
    local selectBehavior = (
          luasnip.jumpable(-1) or luasnip.jumpable(1) or vim.b.visual_multi) and
        cmp.SelectBehavior.Select or
        cmp.SelectBehavior.Insert
    cmp.select_prev_item({ behavior = selectBehavior })
  elseif luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    fallback()
  end
end, { "i", "s" })
lvim.builtin.cmp.mapping['<CR>']         = cmp.mapping(function(fallback)
  if cmp.visible() and cmp.get_selected_entry() then
    local confirm_opts = vim.deepcopy(lvim.builtin.cmp.confirm_opts) -- avoid mutating the original opts below
    local is_insert_mode = function()
      return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
    end
    if is_insert_mode() then -- prevent overwriting brackets
      confirm_opts.behavior = cmp.ConfirmBehavior.Insert
    end
    if cmp.confirm(confirm_opts) then
      return -- success, exit early
    end
    -- when no selected any entry
  elseif jumpable(1) then
    luasnip.jump(1)
    return
  end
  fallback() -- if not exited early, always fallback
end)
lvim.builtin.cmp.sources                 = cmp.config.sources({
    {
      name = "nvim_lsp",
      entry_filter = function(entry, ctx)
        local kind = require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
        if kind == "Snippet" and ctx.prev_context.filetype == "java" then
          return false
        end
        if kind == "Text" then
          return false
        end
        return true
      end,
    },
    {
      name = "async_path",
      option = {
        trailing_slash = true,
      }
    },
    { name = "luasnip" },
    { name = 'npm',        keyword_length = 3 },
    { name = "cmp_tabnine" },
    { name = "nvim_lua" },
    { name = "calc" },
    { name = "git" },
    {
      name = "emoji",
      trigger_characters = { ":" },
    },
    { name = "treesitter" },
    { name = "crates" },
    { name = "tmux" },
  },
  {
    { name = 'buffer' },
  }
)
lvim.builtin.cmp.formatting.source_names = {
  treesitter = "(TreeSitter)",
  nvim_lsp = "(LSP)",
  emoji = "(Emoji)",
  path = "(Path)",
  calc = "(Calc)",
  cmp_tabnine = "(Tabnine)",
  vsnip = "(Snippet)",
  luasnip = "(Snippet)",
  buffer = "(Buffer)",
  tmux = "(TMUX)",
  git = "(Git)"
}
lvim.builtin.cmp.completion.autocomplete = {
  require("cmp.types").cmp.TriggerEvent.TextChanged,
  require("cmp.types").cmp.TriggerEvent.InsertEnter,
  completeopt = "menu,menuone,noinsert,noselect",
}
