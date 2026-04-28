local M = {}

vim.o.autochdir = false

local root_markers_lsp_servers_ignored = {}
local root_markers = {}
-- The Smart Root Function
local function set_smart_root()
  if not vim.bo.buflisted then return end
  -- Check active LSP clients for the current buffer
  local clients = vim.lsp.get_clients { bufnr = 0 }
  local cur_buf = vim.api.nvim_buf_get_name(0)

  for _, client in ipairs(clients) do
    -- Only proceed if the LSP isn't ignored AND has a valid root_dir
    if
      not (root_markers_lsp_servers_ignored or {})[client.name]
      and client.root_dir
      and cur_buf
      and vim.fs.relpath(client.root_dir, cur_buf) -- Only change if the root_dir is a parent folder of the current buffer
    then
      return vim.fn.chdir(vim.fn.expand(client.root_dir))
    end
  end

  local minimisc_exist, minimisc = pcall(require, "mini.misc")
  local root = nil
  if minimisc_exist then
    root = minimisc.find_root(0, root_markers or {})
  else
    root = vim.fs.root(0, root_markers or {})
  end
  if root then return vim.fn.chdir(vim.fn.expand(root)) end

  -- fallback to current directory
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path ~= "" then return vim.fn.chdir(vim.fn.fnamemodify(file_path, ":p:h")) end
end

-- Autocmds to trigger the check
vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach" }, {
  callback = function() vim.schedule(set_smart_root) end,
  desc = "Auto change cwd based on lsp and root files/folders",
  group = vim.api.nvim_create_augroup("smart-root-chdir", { clear = true }),
})

-- Change current working directory based on the current file path. It
-- searches up the file tree until the first root marker ('.git' or 'Makefile')
-- and sets their parent directory as a current directory.
-- This is helpful when simultaneously dealing with files from several projects.
-- auto load project-local Plugins and LSP configurations
---@class opts table
---@field root_markers string[]
---@field root_markers_lsp_servers_ignored string[]
M.setup = function(opts)
  root_markers = opts.root_markers or {}
  root_markers_lsp_servers_ignored = opts.root_markers_lsp_servers_ignored or {}
end

return M
