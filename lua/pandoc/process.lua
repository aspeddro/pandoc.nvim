local uv = vim.loop

local M = {}

M.spawn = function(bin, args, callback)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  local spawn_opts = {
    args = args,
    cwd = uv.cwd(),
    stdio = { nil, stdout, stderr },
  }

  local result = {}

  local handle, pid
  handle, pid = uv.spawn(
    bin,
    spawn_opts,
    vim.schedule_wrap(function(exit_code, signal)
      stdout:read_stop()
      stderr:read_stop()
      stdout:close()
      stderr:close()
      handle:close()
      callback(result, exit_code, signal)
    end)
  )

  if handle == nil then
    error(("Failed to spawn process: cmd = %s, error = %s"):format(bin, pid))
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
