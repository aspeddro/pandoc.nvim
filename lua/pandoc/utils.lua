local Job = require('plenary.job')
local config = require('pandoc.config')

local M = {}

M.output_file = function(name, template)
  local template_string = template or config.get().default.output

  assert(type(template_string) == 'string', 'output must be a string')

  return template_string:format(name:gsub('.[^.]+$', ''))
end

M.has_argument = function(tbl, name)
  for _, value in ipairs(tbl) do
    if value[1] == name then
      return true
    end
  end
  return false
end

M.get_argument = function(tbl, name)
  for _, value in ipairs(tbl) do
    if value[1] == name then
      return value[2]
    end
  end
end

M.add_argument = function(tbl, name)
  if type(name) ~= 'table' then
    return table.insert(tbl, 1, { name })
  end
  return table.insert(tbl, name)
end

local function is_valid_argument(argument)
  local lhs, rhs = unpack(argument)
  local type_ = config.types['--' .. lhs]
  local argument_name = lhs:gsub('^%-+', '')

  -- Assert than argument exist
  assert(type_, lhs .. ' is a invalid argument')

  if type_ == 'flag' then
    assert(rhs == nil, argument_name .. ' must be a flag')
  end
  if type_ == 'string' then
    assert(type(rhs) == 'string', argument_name .. ' must be a string')
    assert(string.len(rhs) > 0, argument_name .. ' is empty')
  end

  if type_ == 'number' then
    assert(type(tonumber(rhs)) == 'number', argument_name .. ' must be a number')
  end

  if type(type_) == 'table' then
    assert(vim.tbl_contains(type_, rhs), argument_name .. ' must be ' .. table.concat(type_, ', '))
  end
  return true
end

M.parse_vim_command = function(arguments)
  return vim.tbl_map(function(argument)
    local lhs, rhs = unpack(vim.split(argument, '=', true))
    is_valid_argument({ lhs, rhs })
    return { '--' .. lhs, rhs }
  end, vim.split(
    arguments,
    ' ',
    true
  ))
end

M.job = function(tbl)
  local pandoc_bin = 'pandoc'
  local cwd = vim.loop.cwd()

  assert(vim.fn.executable(pandoc_bin) == 1, 'pandoc binary not found')

  Job
    :new({
      command = pandoc_bin,
      cwd = cwd,
      args = vim.tbl_flatten(tbl),
      on_stdout = function(_, data)
        print(data)
      end,
      on_stderr = function(_, data)
        print(data)
      end,
      on_exit = function(_, return_val)
        if return_val == 0 then
          print('pandoc: Done')
        else
          print('pandoc: Failed')
        end
      end,
    })
    :start()
end

M.on_keypress = function(key)
  local binding = config.get().mapping[key:gsub('%[', '<'):gsub('%]', '>')]

  assert(type(binding) == 'function', 'Mapping bind must be a function')

  binding()
end

local keymap_callback = function(key)
  return string.format('<cmd>lua require"pandoc.utils".on_keypress("%s")<CR>', key:gsub('<', '['):gsub('>', ']'))
end

M.register_key = function(mapping)
  local opts = { noremap = true, silent = true, nowait = true }
  for key, _ in pairs(mapping) do
    vim.api.nvim_set_keymap('n', key, keymap_callback(key), opts)
  end
end

return M
