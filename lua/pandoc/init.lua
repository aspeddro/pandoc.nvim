local config = require("pandoc.config")
local utils = require("pandoc.utils")
local render = require("pandoc.render")

---@brief [[
---*pandoc.txt* Pandoc plugin for Neovim v0.7.0 or higher
---
---Author: Pedro Castro
---Homepage: <https://github.com/aspeddro/pandoc.nvim>
---License: MIT
---@brief ]]

---@toc pandoc.contents

---@mod pandoc.intro Introduction
---@brief [[
---pandoc.nvim is a plugin to provide basic support for Pandoc CLI.
---@brief ]]

local M = {}

---@mod pandoc Setup
---Setup pandoc.nvim. If you want to override default config, just modify the
---option that you want then it will be merged with the default config
---@param opts? Config
---@return Config
---@see pandoc.config
---@usage [[
--- -- Using default configuration
--- require('pandoc').setup()
---
--- -- Custom configuration
--- require('pandoc').setup{
---   commands = {
---     name = 'PandocBuild'
---   },
---   default = {
---     output = '%s_output.pdf'
---   },
---   mappings = {
---     -- normal mode
---     n = {
---       ['<leader>pr'] = function ()
---         require('pandoc.render').init()
---       end
---     }
---   }
--- }
---@usage ]]
M.setup = function(opts)
  opts = config.merge(opts)

  if opts.mappings then
    for mode, keymap in pairs(opts.mappings) do
      for key, fn in pairs(keymap) do
        vim.keymap.set(mode, key, fn)
      end
    end
  end

  if opts.commands.enable then
    vim.api.nvim_create_user_command(opts.commands.name, function(params)
      local arguments = vim.tbl_map(function(arg)
        local start, end_ = string.find(arg, "=")
        local lhs = start and string.sub(arg, 1, end_ - 1) or arg
        local rhs = start
            and string
              .sub(arg, end_ + 1, string.len(arg))
              :gsub("'", "")
              :gsub('"', "")
          or nil
        return { "--" .. lhs, rhs }
      end, params.fargs)
      render.file(arguments)
    end, {
      nargs = "*",
      complete = utils.complete,
      desc = "Pandoc Command",
    })
  end

  return opts
end

return M
