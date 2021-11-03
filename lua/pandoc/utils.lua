local Job = require'plenary.job'
local config = require'pandoc.config'

local utils = {}

local function convert(value, target)

  if target == 'string' then
    return tostring(value)
  end

  if target == 'number' then
    return tonumber(value)
  end

  if target == 'boolean' then
    if value == 'true' then
      return true
    else
      return false
    end
  end

end

utils.output_file = function(str)
 local r, _ = string.gsub(str, '.[^.]+$', '')
 return config.get().default.output:format(r)
end

utils.has_argument = function(tbl, name)
  for _, value in ipairs(tbl) do
    if value[1] == name then
      return true
    end
  end
  return false
end

utils.add_argument = function(tbl, name)
  if type(name) ~= 'table' then
    return table.insert(tbl, 1, { name })
  end
  return table.insert(tbl, name)
end

-- Remove dash from argument (string)
local function friendly_argument(s)
  return string.gsub(s, '^-+', '')
end

local function is_valid_argument(argument)
  local type_info = config.get_type(argument[1])
  local argument_name = friendly_argument(argument[1])

  -- Assert than argument exist
  assert(type_info ~= nil, argument[1] .. ' is a invalid argument')

  -- Assert than if is not a flag should be a value ie ~= nil
  -- assert(type_info ~= 'flag' and argument[2] ~= nil, argument_name .. ' is empty')

  -- Assert than type is valid
  if type_info == 'flag' then
    assert(argument[2] == nil, argument_name .. ' should be a flag')
  end
  if type_info == 'string' then
    assert(type(argument[2]) == 'string', argument_name .. ' should be a string')
    assert(string.len(argument[2]) > 0, argument_name .. ' is empty')
  end

  if type(type_info) == 'table' then
    assert(vim.tbl_contains(type_info, argument[2]), argument_name .. ' should be ' .. table.concat(type_info, ', '))
  end
  return true
end

utils.validate = function (tbl)
  for _, argument in pairs(tbl) do
    is_valid_argument(argument)
  end
end

local function parse_arg(s)
  local split = vim.split(s, '=', true)

  local pandoc_arg = vim.tbl_filter(function (arg)
    return split[1] == string.gsub(arg, '^-+', '')
  end, vim.tbl_keys(config.types))[1]

  assert(pandoc_arg ~= nil, split[1] .. ' is not a valid argument')

  local result = #split == 2 and { pandoc_arg, split[2] } or { pandoc_arg }

  return result

end

utils.parser_vim_command = function (s)
  return vim.tbl_map(parse_arg, vim.split(string.gsub(s, '\"', ''), ' ', true))
end

utils.job = function(tbl)
  local pandoc_bin = 'pandoc'
  local cwd = vim.loop.cwd()

  assert(vim.fn.executable(pandoc_bin) == 1, 'pandoc binary not found')

  Job:new{
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
        print("pandoc: Done")
      else
        print("pandoc: Failed")
      end
    end
  }:start()

end

utils.on_keypress = function(key)
  local binding = config.get().mapping[key:gsub("%[", "<"):gsub("%]", ">")]

  assert(type(binding) == 'function', 'Mapping bind should be a function')

  binding()
end

local keymap_callback = function(key)
  return string.format('<cmd>lua require"pandoc.utils".on_keypress("%s")<CR>', key:gsub("<", "["):gsub(">", "]"))
end

utils.register_key = function(mapping)
  local opts = { noremap = true, silent = true, nowait = true }
	for key, _ in pairs(mapping) do
    vim.api.nvim_set_keymap(
      'n',
      key,
      keymap_callback(key),
      opts
    )
	end
end

return utils
