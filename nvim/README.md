# AstroNvim dotfiles

## To achieve project-local Plugins and LSP configurations:

### Use built-in `exrc` variable and `lazy.nvim` plugin

#### Project configuration

1. Enable `exrc` in `astrocore.lua.opts.options.o.exrc = true`
2. Place LSP configs at `.nvim/lsp/*.lua` in your project root.
3. For locally settings:  
   Create `.nvim.lua` in your project root directory with this line at the top:

   ```lua
   vim.opt.rtp:append(".nvim")
   ```

- In `.nvim.lua` inside the project, you can:
  - Tweak an existing config
  - Add new settings
  - Enable the server only for this project

4. For locally plugins:  
   Create `.lazy.lua` in your project root directory.  
   Rememeber to `return {...}` like a normal lazy plugin file

- In `.lazy.lua` inside the project, you can:
  - Do anything .nvim.lua can do (`astrocore`, `astrocommunity`, `astroui`, `astrolsp`, etc)
  - Tweak an existing plugins
  - Add new plugins
  - Enable the plugin only for this project

5. (Optional) Ignore `.nvim.lua`, `.lazy.lua` files and `.nvim` folder from git:

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

#### Strcuture should be like this:

```
myproject/
  .git
    info
      exclude
  .nvim.lua
  .lazy.lua
  .nvim/
    lsp/
      LSP_SERVER_NAME.lua
      pyright.lua
      lua_ls.lua
      sqls.lua
```

#### This method only works if you start Neovim with `nvim /path/to/project` or `nvim /path/to/project/sub/folder/file`

The first time you open Neovim, it will ask you to trust `.nvim.lua` and `.lazy.lua` files. Open them and run command `:trust` to trust them and restart Neovim.

> [!IMPORTANT]
> Keep in mind that every those files are edited, you need to trust them again.
