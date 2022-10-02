local utils = require("pandoc.utils")
local config = require("pandoc.config")
local uv = vim.loop

local M = {}

M.spawn = function(opts)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  local file = opts.args[1]
  assert(vim.fn.filereadable(file) == 1, file .. " not readable")

  for _, argument in ipairs(vim.list_slice(opts.args, 2)) do
    utils.validate(argument)
  end

  local binary = config.get().binary

  assert(vim.fn.executable(binary) == 1, binary .. " is not executable")

  local output = utils.get_argument(opts.args, "--output")

  local spawn_opts = {
    args = vim.tbl_flatten(opts.args),
    cwd = opts.cwd or uv.cwd(),
    stdio = { nil, stdout, stderr },
  }

  local result = {}

  local function handler_message(successful)
    local message = vim.trim(table.concat(result, ""))
    if successful then
      if not vim.tbl_isempty(result) then
        vim.notify(("pandoc: %s created. %s"):format(output, message), vim.log.levels.INFO)
        return
      end
      vim.notify(("pandoc: %s created"):format(output), vim.log.levels.INFO)
      return
    end
    vim.notify(
      ("pandoc: Failed to create %s. \narguments: %s.\n%s"):format(output, table.concat(spawn_opts.args, " "), message),
      vim.log.levels.ERROR
    )
  end

  local handle, pid
  handle, pid = uv.spawn(
    binary,
    spawn_opts,
    vim.schedule_wrap(function(exit_code, signal)
      local successful = exit_code == 0 and signal == 0
      stdout:read_stop()
      stderr:read_stop()
      stdout:close()
      stderr:close()
      handle:close()
      handler_message(successful)
    end)
  )

  if handle == nil then
    error(("Failed to spawn process: cmd = %s, error = %s"):format(binary, pid))
  end

  local function on_read(err, data)
    if err then
      error(err)
    end
    if data then
      table.insert(result, data)
    end
  end

  stderr:read_start(on_read)
  stdout:read_start(on_read)
end

return M
