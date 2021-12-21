local utils = require('pandoc.utils')
local config = require('pandoc.config')
local uv = vim.loop

vim.fn = setmetatable({}, {
  __index = function(t, key)
    local function _fn(...)
      return vim.api.nvim_call_function(key, { ... })
    end
    t[key] = _fn
    return _fn
  end,
})

local M = {}

M.spawn = function(opts)
  local file = opts.args[1]
  assert(vim.fn.filereadable(file) == 1, file .. ' not readable')

  for _, argument in ipairs(vim.list_slice(opts.args, 2)) do
    utils.validate(argument)
  end

  local command = config.get().command

  assert(vim.fn.executable(command) == 1, command .. ' is not executable')

  local output = utils.get_argument(opts.args, '--output')

  local spawn_opts = {
    args = vim.tbl_flatten(opts.args),
    cwd = opts.cwd or uv.cwd(),
  }

  local handle, pid

  handle, pid = uv.spawn(command, spawn_opts, function(exit_code, signal)
    local ok = exit_code == 0 and signal == 0
    handle:close()
    if ok then
      print(('pandoc: %s created'):format(output))
    else
      print(('pandoc: Failed to create %s'):format(output))
    end
  end)

  if handle == nil then
    error(('Failed to spawn process: cmd = %s, error = %s'):format(command, pid))
  end
end

return M
