local config = require("pandoc.config")

local M = {}

M.create_output = function(name, template)
  local template_string = template or config.get().default.output

  assert(type(template_string) == "string", "output must be a string")

  return template_string:format(name:gsub(".[^.]+$", ""))
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
  return vim.list_extend(tbl, name)
end

M.validate = function(argument)
  local lhs, rhs = unpack(argument)
  local type_ = config.types[lhs]
  local argument_name = lhs:gsub("^%-+", "")

  -- Assert than argument exist
  assert(type_, argument_name .. " is a invalid argument")

  if type_ == "flag" then
    assert(rhs == nil, argument_name .. " must be a flag")
  end
  if type_ == "string" then
    assert(type(rhs) == "string", argument_name .. " must be a string")
    assert(string.len(rhs) > 0, argument_name .. " is empty")
  end

  if type_ == "number" then
    assert(type(tonumber(rhs)) == "number", argument_name .. " must be a number")
  end

  if type(type_) == "table" then
    assert(vim.tbl_contains(type_, rhs), argument_name .. " must be " .. table.concat(type_, ", "))
  end
  return true
end

M.parse_vim_command = function(arguments)
  return vim.tbl_map(function(argument)
    local lhs, rhs = unpack(vim.split(argument, "=", true))
    return { "--" .. lhs, rhs }
  end, vim.split(arguments, " ", true))
end

M.on_keypress = function(key)
  local binding = config.get().mapping[key:gsub("%[", "<"):gsub("%]", ">")]

  assert(type(binding) == "function", "Mapping bind must be a function")

  binding()
end

local keymap_callback = function(key)
  return string.format('<cmd>lua require"pandoc.utils".on_keypress("%s")<CR>', key:gsub("<", "["):gsub(">", "]"))
end

M.register_key = function(mapping)
  local opts = { noremap = true, silent = true, nowait = true }
  for mode, keymap in pairs(mapping) do
    for key, _ in pairs(keymap) do
      vim.api.nvim_set_keymap(mode, key, keymap_callback(key), opts)
    end
  end
end

return M
