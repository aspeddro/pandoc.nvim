---@mod pandoc.config Configuration

local M = {}

---@class Commads
---@field enable boolean Enable command. Default is `true`
---@field name string Name of command. Default is `:Pandoc`
---@field extended boolean When enabled the arguments passed by the command will be extended with the default arguments. Default is `true`

---@class Default
---@field output string Template of output with extension. Default is `%s.pdf`
---@field bin string Path to pandoc binary. Default is `'pandoc'`
---@field args (string|string[])[] Arguments to pass pandoc CLI. Default is `{ {'--standalone'} }`

---@class Config
---@field commands Commads
---@field mappings table<string, table<string, function>>. Default is `{}`
---@field default Default
local default_config = {
  commands = {
    enable = true,
    name = "Pandoc",
    extended = true,
  },
  mappings = {},
  default = {
    bin = "pandoc",
    output = "%s.pdf",
    args = {
      { "--standalone" },
    },
  },
}

---Get the default config
---@return Config
M.get = function()
  return default_config
end

---Merge config with default. This function change the default options.
---@private
---@param opts? Config
---@return Config
M.merge = function(opts)
  local merged = vim.tbl_deep_extend("force", {}, default_config, opts or {})
  default_config = merged
  return merged
end

return M
