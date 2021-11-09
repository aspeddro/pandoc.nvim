local uv = vim.loop

local M = {}

M.spawn = function(opts)
  local cmd = 'pandoc'
  P(opts)
  local spawn_opts = {
    args = opts.args,
    cwd = opts.cwd or uv.cwd()
  }
  local handle, pid
  handle, pid = uv.spawn(cmd, spawn_opts, function(exit_code, signal)
    local ok = exit_code == 0 and signal == 0
    handle:close()
    if ok then
      print("pandoc: Conversion Done")
    end
  end)
end

return M
