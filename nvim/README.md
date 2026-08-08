# Nvim dotfiles

This config borrows heavily from [AstroNvim](https://github.com/AstroNvim/AstroNvim) and [MiniMax](https://nvim-mini.org/MiniMax/).  
Only works with Nvim v0.12+

<!-- toc -->

- [To achieve project-local Plugins and LSP configurations:](#to-achieve-project-local-plugins-and-lsp-configurations)
  - [Use custom plugin/module `project-local-loader`](#use-custom-pluginmodule-project-local-loader)
  - [Use built-in `exrc` method and start nvim with `nvim /path/to/project-root` or `nvim /path/to/project-root/sub/folder/file`](#use-built-in-exrc-method-and-start-nvim-with-nvim-pathtoproject-root-or-nvim-pathtoproject-rootsubfolderfile)
  - [Structure should be like this:](#structure-should-be-like-this)
  - [This method only works if you start Neovim with `nvim /path/to/project-root` or `nvim /path/to/project-root/sub/folder/file`](#this-method-only-works-if-you-start-neovim-with-nvim-pathtoproject-root-or-nvim-pathtoproject-rootsubfolderfile)
- [Explain about init.lua and plugin/ folder](#explain-about-initlua-and-plugin-folder)
  - [./init.lua](#initlua)
  - [./plugin/ folder](#plugin-folder)
- [Alot of things need to be done manually](#alot-of-things-need-to-be-done-manually)
  - [To generate TOC (Table of Contents) in markdown files:](#to-generate-toc-table-of-contents-in-markdown-files)

<!-- tocstop -->

### To achieve project-local Plugins and LSP configurations:

We have 2 methods:

#### Use custom plugin/module `project-local-loader`

- Module is here: [./lua/project-local-loader.lua](./lua/project-local-loader.lua)
- Don't have to start nvim with path.
- This module will auto load project-local config files (like `.nvim.lua`)
  when cwd is changed (check [./init.lua > Config.auto_chdir_root](./init.lua)).
- This will auto trust `.nvim.lua` when you save it.
- But all settings in `.nvim.lua` have to be buffer-local.
- Check [./new-project-templete/.nvim.lua](./new-project-templete/.nvim.lua) for example.
- Disable via [./init.lua > Config.enable_project_local_loader](./init.lua)

#### Use built-in `exrc` method and start nvim with `nvim /path/to/project-root` or `nvim /path/to/project-root/sub/folder/file`

1. Set `exrc = true` in [./plugin/00_options.lua](./plugin/00_options.lua)
2. Place LSP config files at `project-root/.nvim/lsp/*.lua` in your project root (replace \* with the name of the LSP server, same as in [./after/lsp/](./after/lsp/))
3. For locally nvim settings:  
   Create a `project-root/.nvim.lua` file and add the line below at the top:

   ```lua
   vim.opt.rtp:append(".nvim")
   -- Other nvim settings here or in project-root/.nvim/init.lua file.
   ```

   - In that `project-root/.nvim.lua` file, you can:
     - Tweak an existing config
     - Add new nvim settings
     - Enable/Disable any lsp server only for that project
     - Add new plugins using `vim.pack.add` same way as in [./plugin/](./plugins/)

4. (Optional) Ignore `.nvim.lua` files and `.nvim` folder from git:
   So it won't upload to your git repo.

   ```gitignore
   # In your project root add these lines to this file `project-root/.git/info/exclude`.
   # Create it if not exists.

   # Or use `~/.config/git/ignore` instead to ignore files globally.
   # This path depends on your OS. Ask AI for help.
   .nvim.lua
   .nvimrc
   .exrc
   .nvim/*
   .nvim
   ```

5. Content of `project-root/.nvim/lsp/*.lua` is vary according to the lsp server:

For example:

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

```text
project-root/
  .git/
    info/
      exclude      # Keep this file if you use global .gitignore above

  .nvim/           # Local nvim config, any file or subfolder under this folder is optional
    lsp/           # lsp configs
      LSP_SERVER_NAME.lua
      pyright.lua
      lua_ls.lua
      sqls.lua

    ftplugin/      # Filetype configs. Load before /after/ftplugin
      FILETYPE.lua
      vue.lua      # Example of vue filetype config.

    snippets/      # Snippets. Load before /after/snippets
      FILETYPE.json
      vue.json     # Example of vue snippets.

    plugin/        # Project-specific plugins
      any-name.lua # Example of plugin.

    after/         # Folder under this is loaded latest
      ftplugin/    # Filetype configs
      lsp/         # LSP configs
      snippets/    # Snippets
      queries/
      syntax/

    lua/           # Extra Lua modules. Which won't load if not require("module-name")
    colors/        # Local colorschemes
    spell/         # Local spellfiles
    init.lua       # Local nvim config. Load second after ../.nvim.lua

  .nvim.lua        # This file is loaded by nvim first

```

#### This method only works if you start Neovim with `nvim /path/to/project-root` or `nvim /path/to/project-root/sub/folder/file`

The first time you open Neovim, it will ask you to trust `project-root/.nvim.lua` file. Open them and type/run command `:trust` to trust them and restart Neovim.

> [!IMPORTANT]
> Keep in mind that every time that file is edited, you need to trust them again.

### Explain about init.lua and plugin/ folder

#### ./init.lua

- This file is loaded by nvim first
- It contains some configurations about diagnostics, enabled lsp features, custom icons use in plugins, keymaps, etc.
- Some generic functions are defined here, most useful are lazy-loading plugin functions:
  - `add`: add plugin to `vim.pack.add`
  - `now`: execute immediately. Use for what must be executed during startup
    (a plugin only use to setup `vim.lsp.config` like `sqls` in `10_lang-plugins`, theme, starery, etc.)
  - `later`: execute a bit later. Use for things not needed during startup.
  - `now_if_args`: execute immediately if start like `nvim -- path/to/file`,  
    otherwise execute a bit later.
  - `on_event`: execute once on a first matched event.
    - Like "delay until:
      - first Insert mode enter" (no pattern):
        - `on_event('InsertEnter,BufEnter', function() ... end)`
      - first BufEnter with pattern (with pattern):
        - `on_event('BufEnter~package.json', function() ... end)`
      - first BufEnter or BufReadPre with pattern (multiple events with multiple pattern):
        - `on_event({'BufEnter', 'BufReadPre'}, {"package.json", "*.lua"}, function() ... end)`
        - `on_event('BufReadPre,BufEnter~package.json,*.lua', function() ... end)`
  - `on_filetype`: execute once on a first matched filetype.
    - A table of filetype or a string with each filetype separated by comma.
      `on_filetype({"lua","python"}, function() ... end)`
      `on_filetype('lua,python', function() ... end)`

#### ./plugin/ folder

- Files in this folder load by alphabetical order automatically by nvim.
- `00_` should be files that don't need any dependencies or libs for other files under them.
- Files without number prefix are files that load after all number prefixed files.
- Custom filetype should be added in [./plugin/00_options.lua](./plugin/00_options.lua)
- Whenever you want to add new language pack (like in `astrocommunity/pack/language`),  
  you can add it in `05_` (tress-sitter, lsp servers, formatter, linter, debugger, etc.)
- `10_` file should contain plugins that need to be loaded for specific filetype/language.
- By default, any lsp server installed via mason will be enable (vim.lsp.enable)  
  at start up and after install/update.
- For any lsp server that need to enable manually (like `jdtls` after `jdtls` plugin initalization),
  you can add it in `05_lsp-servers.lua` > `manually_start_lsp_servers` file.  
  This will prevent it from being enable at start up.  
  Then after you install + config related plugin, you can enable it manually via  
  `vim.lsp.enable("jdtls")` command or via plugin like `nvim-jdtls`.  
  Check `10_java-plugins.lua > jdtls plugins` for more examples.
- If you use other theme, disable `mini.base16` in [./plugin/01_mini.lua](./plugin/01_mini.lua)

### Alot of things need to be done manually

- Make sure to delete unused plugins via `<Leader>pp` after removed its `add` function.
- Use `<Esc><Esc>` to escape snippet mode.
- Activate AI supermaven to get inlay hint suggestion. Accept suggestion with `<C-l>`.
- You can also use copilot-lsp, install via mason (check [./plugin/01_packages-installer.lua](./plugin/01_packages-installer.lua)), Accept suggestion with `<C-l>`, next suggestion with `<C-]>`, previous suggestion with `<C-[>`.
- VectorCode require uv installed. It won't install/enable if uv is not installed.
- Codecompanion use google-cli by default.
- i18n.nvim is heavy, so enable it only when you need it.
- gitsigns.nvim use gh cli by default. gh is installed via mason if not exists.
- Install yazi if you want to use it. My config is [here](../yazi/)
- Update plugins changelogs need to save to apply changes.

#### To generate TOC (Table of Contents) in markdown files:

Disable marksman > [code_action] > toc.enable. Check [../marksman/config.toml](../marksman/config.toml)
Add the content of [./after/snippets/markdown.json > setup > body](./after/snippets/markdown.json) to your markdown file.
And then whenever you save the markdown file, TOC will be generated.
