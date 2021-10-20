local config = require'pandoc.config'
local utils = require'pandoc.utils'

local pandoc = {}

-- -complete=buffer
local function vim_commands()
  vim.cmd [[
    command! -bang -nargs=? Pandoc lua require'pandoc'.run_from_command(<q-args>, <q-bang>)
    command! -nargs=? PandocModel lua require'pandoc'.run_model(<f-args>)
  ]]
end


pandoc.setup = function(user_opts)
  pandoc.options = config.merge(user_opts)
  vim_commands()
end

pandoc.run = function (user_opts)
  utils.job(user_opts)
end

pandoc.run_model = function(name)
  local model = pandoc.options.models[name]
  assert(model ~= nil, name .. ' not found. Check your setup')

  local bufname = vim.api.nvim_buf_get_name(0)

  if not utils.has_argument(model, '-o') then
    utils.add_argument(model, {'-o', utils.output_file(bufname)})
  end

  utils.add_argument(model, bufname)

  utils.job(model)

end

pandoc.run_from_command = function(user_opts)
  local bufname = vim.api.nvim_buf_get_name(0)

  -- use current buffer as input
  if string.len(user_opts) == 0 then
    return utils.job{ bufname, config.options.default.args, {'-o', utils.output_file(bufname)} }
  end

  local parsed = utils.parser_vim_command(user_opts)


  if not utils.has_argument(parsed, '-o') then
    utils.add_argument(parsed, {'-o', utils.output_file(bufname)})
  end

  utils.add_argument(parsed, bufname)

  utils.job(parsed)
end





return pandoc
