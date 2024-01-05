lvim.builtin.nvimtree.setup.view.adaptive_size              = true
lvim.builtin.nvimtree.setup.view.side                       = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git         = false
lvim.builtin.nvimtree.setup.renderer.full_name              = false
lvim.builtin.nvimtree.setup.view.number                     = true
lvim.builtin.nvimtree.setup.view.relativenumber             = true
lvim.builtin.nvimtree.setup.renderer.indent_markers.enable  = true
lvim.builtin.nvimtree.setup.hijack_netrw                    = false
lvim.builtin.nvimtree.setup.disable_netrw                   = false
lvim.builtin.nvimtree.setup.update_focused_file.update_root = true
lvim.builtin.nvimtree.setup.filters.custom                  = {}
lvim.builtin.nvimtree.setup.live_filter.always_show_folders = false
lvim.builtin.nvimtree.setup.actions.change_dir.global       = true
-- Remove with the next lvim release
lvim.builtin.nvimtree.setup.view.hide_root_folder           = nil
lvim.builtin.nvimtree.setup.on_attach                       = function(bufnr)
  local api = require "nvim-tree.api"

  local function telescope_find_files(_)
    require("lvim.core.nvimtree").start_telescope "find_files"
  end

  local function telescope_live_grep(_)
    require("lvim.core.nvimtree").start_telescope "live_grep"
  end

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  local useful_keys = {
    ["l"] = { api.node.open.edit, opts "Open" },
    ["o"] = { api.node.open.edit, opts "Open" },
    ["<CR>"] = { api.node.open.edit, opts "Open" },
    ["v"] = { api.node.open.vertical, opts "Open: Vertical Split" },
    ["h"] = { api.node.navigate.parent_close, opts "Close Directory" },
    ["C"] = { api.tree.change_root_to_node, opts "CD" },
    ["gtg"] = { telescope_live_grep, opts "Telescope Live Grep" },
    ["gtf"] = { telescope_find_files, opts "Telescope Find File" },
    ['d'] = { api.fs.trash, opts 'Trash' }
  }

  require("lvim.keymappings").load_mode("n", useful_keys)
end
