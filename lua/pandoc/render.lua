local config = require("pandoc.config")
local utils = require("pandoc.utils")
local process = require("pandoc.process")

local M = {}

M.init = function(opts)
  local bufname = vim.api.nvim_buf_get_name(0)

  local arguments = { bufname }

  local output = { "--output", utils.create_output(bufname) }

  local default_args = config.get().default.args

  if not opts or string.len(opts) == 0 then
    utils.add_argument(arguments, default_args)
    utils.add_argument(arguments, { output })

    return process.spawn({ args = arguments })
  end

  local parsed = utils.parse_vim_command(opts)

  if not utils.has_argument(parsed, "--output") then
    utils.add_argument(arguments, { output })
  end

  utils.add_argument(arguments, parsed)

  if config.get().commands.enable and config.get().commands.extended then
    utils.add_argument(arguments, default_args)
  end

  process.spawn({ args = arguments })
end

M.build = function(opts)
  local arguments = { opts.input, { "--output", opts.output } }
  utils.add_argument(arguments, opts.args)
  process.spawn({ args = arguments })
end

return M
