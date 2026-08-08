-- Language-based supported plugins should add to this file
-- Or 10_lang-plugins.lua file (lang is filetype/language)

-- Schema for json, yaml, etc.
now(function()
  add {
    "https://github.com/b0o/schemastore.nvim",
  }
end)

on_filetype("yaml.ansible", function()
  add {
    "https://github.com/pearofducks/ansible-vim",
  }
end)
