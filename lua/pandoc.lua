local api = vim.api
local options = {}
local function output_file(filename)
  return filename:gsub(".[^]+$", "")
end
local function vim_commands()
  return vim.cmd("command! -bang -nargs=? Pandoc lua require'pandoc'.run_from_command(<q-args>, <q-bang>)")
end
local function setup(user_opts)
  options = vim.tbl_deep_extend("force", {}, user_opts)
  return nil
end
local function render(opts)
  if ("table" == type(opts)) then
    return run()
  end
end
return {render = render, setup = setup}
