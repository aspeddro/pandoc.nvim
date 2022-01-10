local config = require("pandoc.config")

local M = {}

M.show = function()
  local nabla_available, nabla = pcall(require, "nabla")
  if not nabla_available then
    error("nabla not found")
  end
  nabla.popup(config.get().equation)
end

return M
