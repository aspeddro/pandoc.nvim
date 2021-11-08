local config = require'pandoc.config'

local M = {}

M.State = {
  enabled = false
}

local ns = vim.api.nvim_create_namespace('pandoc')

M.header_position = function(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)

  local start = nil
  local _end = nil


  local function is_valid(str)
    local match = str:match('^%-%-%-') or str:match('^%.%.%.')

    if match then
      if match:len() == 3 then
        return true
      end

      if str:sub(match:len() + 1, str:len()):match('^%s+') then
        return true
      end

      return false

    end

    return false

  end

  local i = 1

  while i <= #lines do
    if lines[i]:match('^%-%-%-') and is_valid(lines[i]) and not start then
      start = i
      i = i + 1
    end
    if is_valid(lines[i]) then
      _end = i
      break
    end
    i = i + 1
  end

  return { start, _end, lines }
end

M.parse_header = function ()
  local start, _end, lines = unpack(M.header_position(0))

  if not start or not _end or (start == _end) then
    return
  end

  if start ~= 1 and lines[start - 1]:len() > 0 then
    return
  end

  local yaml_fields = {}

  table.insert(yaml_fields, {
    field = 'yaml_header_delimiter',
    line = start,
    range = {
      start = 0,
      end_ = lines[start]:len()
    }
  })


  table.insert(yaml_fields, {
    field = 'yaml_header_delimiter',
    line = _end,
    range = {
      start = 0,
      end_ = lines[_end]:len()
    }
  })

  local is_safe = true

  for index, line in ipairs(vim.list_slice(lines, start + 1, _end - 1)) do

    if line:find('^[%w|_|-|%s]+$') then
      is_safe = false
      break
    end

    local field_start, field_end = line:find('(.*):')

    if field_start then

      table.insert(yaml_fields, {
        field = line:sub(field_start, line:len()),
        line = index + start,
        -- content = value,
        range = {
          start = field_start - 1,
          end_ = field_end - 1
        }
      })

    end

  end

  if not is_safe then
    return
  end

  return yaml_fields
end

local function add_hightlight(highlight)
  local opts = config.get().highlight

  local group = highlight.field == 'yaml_header_delimiter' and opts.groups.header.delimiter or opts.groups.header.fields

  vim.api.nvim_buf_add_highlight(0, ns, group, highlight.line - 1, highlight.range.start, highlight.range.end_)

  if highlight.content and highlight.content:len() > 0 then
    vim.api.nvim_buf_add_highlight(0, ns, 'Normal', highlight.line - 1, highlight.field:len(), -1)
  end

end

M.update = function()

end

M.disable = function()
  vim.cmd [[
    autocmd! PandocHighlight
  ]]
  M.clear_namespace()
end

M.clear_namespace = function ()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    M.State.enabled = false
end

M.autocommands = function()
  vim.cmd [[
    augroup PandocHighlight
    autocmd!
    autocmd FileType * lua require'pandoc.highlight'.enable()
    autocmd TextChangedI,TextChanged * lua require'pandoc.highlight'.enable()
    augroup END
  ]]
end

M.enable = function()

  -- M.clear_namespace()

  local async

  async = vim.loop.new_async(vim.schedule_wrap(function ()

    if not vim.tbl_contains(config.get().filetypes, vim.bo.filetype) then
      M.clear_namespace()
      return
    end

    local parsed = M.parse_header()

    if parsed then
      for _, value in ipairs(parsed) do
        add_hightlight(value)
      end
    else
      M.clear_namespace()
    end

    async:close()
  end))

  async:send()

  M.State.enabled = true

  M.autocommands()

end

M.toggle = function()
  if M.State.enabled then
    M.disable()
  else
    M.enable()
  end
end

return M
