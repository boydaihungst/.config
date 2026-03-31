---@type LazySpec
return {
  "echasnovski/mini.snippets",
  optional = true,
  opts = {
    mappings = {
      -- Expand snippet at cursor position. Created globally in Insert mode.
      -- NOTE: Prevent overlapping with blink
      expand = "",
      -- Interact with default `expand.insert` session.
      -- Created for the duration of active session(s)
      jump_next = "",
      jump_prev = "",
      stop = "<C-c>",
    },
  },
}
