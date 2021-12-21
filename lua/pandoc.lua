local config = require('pandoc.config')
local utils = require('pandoc.utils')
local render = require('pandoc.render')
local toc = require('pandoc.toc')
local equation = require('pandoc.equation')

local M = {}

M.__completion_plugin = {
  pandoc = function(lead, _, _)
    local results = vim.tbl_filter(function(arg)
      return vim.startswith(arg:gsub('^%-+', ''), lead)
    end, vim.tbl_keys(
      config.types
    ))

    return vim.tbl_map(function(arg)
      local format = arg:gsub('^-+', '')
      return config.types[arg] == 'flag' and format or format .. '='
    end, results)
  end,
}

local function make_commands()
  vim.cmd([[
    command! -bang -nargs=* -complete=customlist,v:lua.require'pandoc'.__completion_plugin.pandoc Pandoc lua require'pandoc'.render.init(<q-args>, <q-bang>)
    command! PandoTOC lua require'pandoc'.toc.toggle()
  ]])
end

M.setup = function(opts)
  config.set(config.merge(opts))

  local config_applied = config.get()

  if config_applied.mapping then
    utils.register_key(config_applied.mapping)
  end
  if config_applied.commands then
    make_commands()
  end
end

M.toc = toc
M.equation = equation
M.render = render

return M
