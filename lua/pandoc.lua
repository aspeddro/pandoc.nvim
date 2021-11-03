local config = require'pandoc.config'
local utils = require'pandoc.utils'
local toc = require'pandoc.toc'
local equation = require'pandoc.equation'

local M = {}

M._completion_plugin = {
  pandoc = function(lead, _, _)
    local results = vim.tbl_filter(function (arg)
      return vim.startswith(arg:gsub('^-+', ''), lead)
    end, vim.tbl_keys(config.types))

    return vim.tbl_map(function (arg)
      local format = arg:gsub('^-+', '')
      return config.types[arg] == 'flag' and format or format .. '='
    end, results)
  end,
  models = function(lead, _, _)
    return vim.tbl_filter(function (model)
      return vim.startswith(model, lead)
    end, vim.tbl_keys(config.get().models))
  end
}

-- -complete=buffer
local function vim_commands()
  vim.cmd [[
    command! -bang -nargs=* -complete=customlist,v:lua.require'pandoc'._completion_plugin.pandoc Pandoc lua require'pandoc'.run(<q-args>, <q-bang>)
    command! -nargs=? -complete=customlist,v:lua.require'pandoc'._completion_plugin.models PandocModel lua require'pandoc'.run_model(<f-args>)
    command! PandoTOC lua require'pandoc'.toc.toggle()
  ]]
end

local function autocommands()
  vim.cmd('augroup PandocToc')
  vim.cmd('autocmd!')
  vim.cmd('autocmd ' .. table.concat(config.get().toc.update_events, ',') .. ' * lua require"pandoc.toc".handler_new_buffer()')
  vim.cmd('augroup END')
end

M.setup = function(user_opts)
  local opts = config.merge(user_opts)
  config.set(opts)
  utils.register_key(opts.mapping)
  vim_commands()
  autocommands()
end

M.run_model = function(name)
  local model = config.get().models[name]
  assert(model ~= nil, name .. ' not found. Check your setup')

  local bufname = vim.api.nvim_buf_get_name(0)

  if not utils.has_argument(model, '--output') then
    utils.add_argument(model, {'--output', utils.output_file(bufname)})
  end

  utils.add_argument(model, bufname)

  utils.job(model)

end

M.run = function(user_opts)
  local bufname = vim.api.nvim_buf_get_name(0)
  -- use current buffer as input
  if not user_opts or string.len(user_opts) == 0 then
    return utils.job{ bufname, config.options.default.args, {'--output', utils.output_file(bufname)} }
  end

  local parsed = utils.parser_vim_command(user_opts)

  if not utils.has_argument(parsed, '--output') then
    utils.add_argument(parsed, {'--output', utils.output_file(bufname)})
  end

  utils.add_argument(parsed, bufname)

  utils.job(parsed)
end

M.toc = toc
M.equation = equation

return M
