local config = require('pandoc.config')
local utils = require('pandoc.utils')
local process = require('pandoc.process')
local M = {}

M.model = function(name)
  local model = config.get().models[name]
  assert(model, name .. ' not found. Check your setup')

  local bufname = vim.api.nvim_buf_get_name(0)

  if not utils.has_argument(model, '--output') then
    utils.add_argument(model, {
      '--output',
      utils.output_file(bufname, model.output),
    })
  end

  utils.add_argument(model, bufname)

  utils.job(model)
end

M.basic = function(opts)
  local bufname = vim.api.nvim_buf_get_name(0)
  -- use current buffer as input
  if not opts or string.len(opts) == 0 then
    return utils.job({
      bufname,
      config.get().default.args,
      { '--output', utils.output_file(bufname) },
    })
  end

  local parse = utils.parse_vim_command(opts)

  if not utils.has_argument(parse, '--output') then
    utils.add_argument(parse, {
      '--output',
      utils.output_file(bufname),
    })
  end

  utils.add_argument(parse, bufname)

  -- utils.job(parse)
  process.spawn({
    args = vim.tbl_flatten(parse)
  })
end

M.start = function(opts)
  utils.job({
    opts.input,
    opts.args,
    { '--output', opts.output },
  })
end

return M
