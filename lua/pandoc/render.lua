---@mod pandoc.render Pandoc Render
local config = require("pandoc.config")
local utils = require("pandoc.utils")
local process = require("pandoc.process")

local M = {}

---Build The Current File
---@param args? string[] Arguments to pass CLI
---@return nil
---@usage [[
----- Build the current file
---require('pandoc.render').init()
----- With custom arguments
---require('pandoc.render').init{
---   {'--toc'},
---   {'--output', 'path/to/output.pdf'}
---}
---@usage ]]
M.file = function(args)
  local bufname = vim.api.nvim_buf_get_name(0)

  local option = config.get()

  if not args or vim.tbl_isempty(args) then
    args = vim.deepcopy(option.default.args)
  end

  if not utils.has_value(args, "--output") then
    vim.list_extend(args, { { "--output", utils.create_output(bufname) } })
  end

  -- Append default arguments
  if option.commands.enable and option.commands.extended then
    for _, argument in ipairs(option.default.args) do
      if not utils.has_value(args, argument[1]) then
        vim.list_extend(args, { argument })
      end
    end
  end

  -- Append input at first position
  table.insert(args, 1, { bufname })

  M.build(option.default.bin, args)
end

---Pandoc Build
---@param bin string Path to Pandoc binary
---@param args string[] Arguments to pass CLI
---@return nil
---@usage [[
---require('pandoc.render').build(
---   'pandoc',
---   {
---     { 'path/to/input.md' },
---     { '--toc' },
---     { '--output', 'path/to/output.pdf' }
---   }
---)
---@usage ]]
M.build = function(bin, args)
  local output = utils.get_rhs_value(args, "--output")

  for _, argument in pairs(vim.list_slice(args, 2)) do
    utils.validate(argument)
  end

  args = vim.tbl_flatten(args)

  process.spawn(bin, args, function(result, exit_code, signal)
    local message = vim.trim(table.concat(result, ""))
    local successful = exit_code == 0 and signal == 0
    if successful then
      if not vim.tbl_isempty(result) then
        vim.notify(
          ("Pandoc: %s created. %s"):format(output, message),
          vim.log.levels.INFO
        )
        return
      end
      vim.notify(("Pandoc: %s created"):format(output), vim.log.levels.WARN)
      return
    end
    vim.notify(
      ("Pandoc: Failed to create %s. %s.\nCommand: %s %s"):format(
        output,
        message,
        bin,
        table.concat(args, " ")
      ),
      vim.log.levels.ERROR
    )
  end)
end

return M
