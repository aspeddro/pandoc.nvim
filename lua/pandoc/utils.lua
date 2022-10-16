---@mod pandoc.utils Pandoc Utils

local config = require("pandoc.config")
local types = require("pandoc.types")

local M = {}

---Create output template path
---@private
---@param name string Name of file
---@param template? string Tempale string. Example "%s.output.pdf". Default is `config.default.output`
---@return string
M.create_output = function(name, template)
  local template_string = template or config.get().default.output

  return template_string:format(name:gsub(".[^.]+$", ""))
end

---Check if a table has a key
---@private
---@param tbl string[]
---@param name string
---@return boolean
M.has_value = function(tbl, name)
  for _, value in ipairs(tbl) do
    if value[1] == name then
      return true
    end
  end
  return false
end

---Get value of argument
---@private
---@param tbl table
---@param name string
---@return string|nil
M.get_rhs_value = function(tbl, name)
  for _, value in ipairs(tbl) do
    if value[1] == name then
      return value[2]
    end
  end
end

---Validate arguments
---@private
---@param argument table<string, string|string[]>
---@return true|nil
M.validate = function(argument)
  local lhs, rhs = unpack(argument)
  local type_ = types[lhs]
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
    assert(
      type(tonumber(rhs)) == "number",
      argument_name .. " must be a number"
    )
  end

  if type(type_) == "table" then
    assert(
      vim.tbl_contains(type_, rhs),
      argument_name .. " must be " .. table.concat(type_, ", ")
    )
  end
  return true
end

---Completion Pandoc CLI arguments
---@return string[]
---@usage [[
---vim.api.nvim_create_user_command('PandocBuild', function()
---  require('pandoc.render').init()
---end, {
---   nargs = "*",
---   complete = require('pandoc.utils').complete,
---})
---@usage ]]
M.complete = function(arg_lead)
  local results = vim.tbl_filter(function(arg)
    return vim.startswith(arg:gsub("^%-+", ""), arg_lead)
  end, vim.tbl_keys(types))

  return vim.tbl_map(function(arg)
    local format = arg:gsub("^%-+", "")
    return types[arg] == "flag" and format or format .. "="
  end, results)
end

return M
