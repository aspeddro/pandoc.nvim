local M = {}

M.show = function(overrides)
  local nabla_available, nabla = pcall(require, 'nabla')
  if not nabla_available then
    error "nabla not found"
  end
  nabla.popup(overrides)
end

return M
