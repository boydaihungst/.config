# AstroNvim dotfiles

Only works with Nvim v0.12+

<!-- toc -->

- [To achieve project-local Plugins and LSP configurations:](#to-achieve-project-local-plugins-and-lsp-configurations)
- [Project configuration](#project-configuration)
  - [Structure should be like this:](#structure-should-be-like-this)
  - [This method only works if you start Neovim with `nvim /path/to/project` or `nvim /path/to/project/sub/folder/file`](#this-method-only-works-if-you-start-neovim-with-nvim-pathtoproject-or-nvim-pathtoprojectsubfolderfile)
- [Alot of things need to be done manually](#alot-of-things-need-to-be-done-manually)
  - [To generate TOC (Table of Contents) in markdown files:](#to-generate-toc-table-of-contents-in-markdown-files)

<!-- tocstop -->

### To achieve project-local Plugins and LSP configurations:

Use built-in `exrc` variable and `lazy.nvim` plugin

### Project configuration

1. Set `exrc = true` in astrocore.lua > opts > options > o > exrc = true
2. Place LSP config files at `.nvim/lsp/*.lua` in your project root (replace \* with the name of the LSP server)
3. For locally nvim settings:  
   Create a `.nvim.lua` file in your project root directory and add this line below at the top:

   ```lua
   vim.opt.rtp:append(".nvim")
   -- Other nvim settings here or in .nvim/init.lua
   ```

   - In that `.nvim.lua` file, you can:
     - Tweak an existing config
     - Add new nvim settings
     - Enable the server only for that project

4. For project-local plugins:  
   Create `.lazy.lua` in your project root directory. This will have the same syntax as a lazy plugin file.  
   Check [lua/plugins](lua/plugins) for an example.
   - In `.lazy.lua` inside your project, you can:
     - Do anything `.nvim.lua` can do (like modify existing plugins: `astrocore`, `astrocommunity`, `astroui`, `astrolsp`, etc)
     - Add new plugin
     - Enable/Disable any plugin

5. (Optional) Ignore `.nvim.lua`, `.lazy.lua` files and `.nvim` folder from git:
   So it won't show up in git status.

   ```gitignore
   # In your project root edit this file `PROJECT_ROOT/.git/info/exclude`
   # Or use `.config/git/ignore` instead to ignore files globally
   .nvim.lua
   .nvimrc
   .exrc
   .lazy.lua
   .nvim/*
   .nvim
   ```

6. Content of `.nvim/lsp/*.lua` is vary according to the lsp server:

   ```lua
   -- .nvim/lsp/sqls.lua
    return {
      cmd = { "sqls" },
      filetypes = { "sql", "mysql" },
      single_file_support = true,
       settings = {
   	    sqls = {
   		    filetypes = { "sql", "mysql" },
   		    -- https://github.com/sqls-server/sqls?tab=readme-ov-file#db-configuration
   		    connections = {
   			    {
   				    alias = "postgres mydb",
   				    driver = "postgresql",
   				    dataSourceName = "postgresql://USER_HERE:PASSWORD_HERE@localhost:5432/mydb",
   			    },
   		    },
   	    },
       },
      -- ...
    }
   ```

#### Structure should be like this:

```
myproject/
  .git/
    info/
      exclude

  .nvim/       # Local nvim config, any file or subfolder is optional
    lsp/
      LSP_SERVER_NAME.lua
      pyright.lua
      lua_ls.lua
      sqls.lua
    plugin/     # Project-specific plugins
    after/      # Overrides
    ftplugin/   # Filetype configs
    lua/        # Lua modules
    colors/     # Local colorschemes
    spell/      # Local spellfiles
    init.lua    # Local nvim config

  .nvim.lua
  .lazy.lua

```

#### This method only works if you start Neovim with `nvim /path/to/project` or `nvim /path/to/project/sub/folder/file`

The first time you open Neovim, it will ask you to trust `.nvim.lua` and `.lazy.lua` files. Open them and run command `:trust` to trust them and restart Neovim.

> [!IMPORTANT]
> Keep in mind that every time one of those files is edited, you need to trust them again.

### Alot of things need to be done manually

- Activate AI supermaven to get inlay hint suggestion. Accept suggestion with `<C-l>`.
- You can also use copilot-lsp, install via mason (space fm -> copilot), Accept suggestion with `<C-l>`, next suggestion with `<C-]>`, previous suggestion with `<C-[>`.
- Some plugins in plugins folder are disabled.
  You need to activate them, set enabled = true in the their config file.
- VectorCode require uv installed. Disable it if you don't need it.
- Codecompanion use google-cli by default.
- i18n.nvim is heavy, so enable it only when you need it.
- gitsigns.nvim use gh cli by default.
- Install yazi if you want to use it.

> [!IMPORTANT]
> To prevent Error "loop in gettable" with too many child specs
> https://github.com/folke/lazy.nvim/issues/2150
> If you override a plugin in community.lua via a .lua file in plugins folder, and that plugin has astrocore as a spec/dependency,
> then you need to remove it from community.lua, and clone the whole config of that plugin in astrocommunity repo to your plugins, then modify it their.
> If the plugin doesn't have astrocore as a spec/dependency, then you can keep both in community.lua and plugins folder.
> Check community.lua for examples.

#### To generate TOC (Table of Contents) in markdown files:

Disable marksman > [code_action] > toc.enable. Check [../marksman/config.toml](../marksman/config.toml)
Add the content of [snippets/markdown.json > setup > body](snippets/markdown.json) to your markdown file.
And then whenever you save the file, TOC will be generated.
