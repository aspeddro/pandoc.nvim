local config = require('pandoc.config')

local M = {}

local State = {
  bufnr = nil,
  winr = nil,
  source_bufnr = nil,
  source_winr = nil,
  content = nil,
}

local buf_options = {
  { 'swapfile', false },
  { 'buftype', 'nofile' },
  { 'modifiable', false },
  { 'filetype', 'markdown' },
  { 'bufhidden', 'hide' },
}

local is_open = function()
  if State.bufnr == nil then
    return false
  end
  local buf_info = vim.fn.getbufinfo(State.bufnr)
  return #buf_info == 1 and buf_info[1].hidden == 0 or false
end

M.close = function()
  -- if vim.api.nvim_get_current_buf() == State.bufnr then
  --   vim.api.nvim_command('q!')
  -- end
  -- vim.api.nvim_win_close(State.winr, true)
  vim.api.nvim_buf_delete(State.bufnr, { force = true })
  State.bufnr = nil
end

-- local toc_autocommands = function()
--   vim.cmd('augroup PandocTocUpdate')
--   vim.cmd('autocmd!')
--   vim.cmd('autocmd BufEnter,BufWritePost * lua require"pandoc.toc".handler_new_buffer()')
--   vim.cmd('augroup END')
-- end

M.handler_new_buffer = function()
  if not is_open() then
    return
  end

  local new_buffer = vim.api.nvim_get_current_buf()

  if not vim.tbl_contains(config.get().toc.filetypes, vim.bo.filetype) then
    -- M.close()
    return
  end

  if State.bufnr == new_buffer then
    return
  end

  State.source_bufnr = new_buffer
  M.handler_update()
end

M.handler_keypress = function()
  if vim.api.nvim_get_current_buf() ~= State.bufnr then
    return
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  local windows = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_buf(win) == State.source_bufnr
  end, vim.api.nvim_list_wins())

  assert(#windows == 1, 'Window of source not found')

  local winr = windows[1]
  local row = State.content[cursor_line].number

  vim.api.nvim_set_current_win(winr)
  vim.api.nvim_win_set_cursor(winr, { row, 0 })
end

M.handler_update = function()
  if not vim.tbl_contains(config.get().toc.filetypes, vim.bo.filetype) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(State.source_bufnr, 0, -1, true)

  local items = {}

  for number, line in ipairs(lines) do
    if line:match('^#+%s+') then
      table.insert(items, { number = number, content = line })
    end
  end

  State.content = items

  local content = vim.tbl_map(function(n)
    local start, _ = n.content:find('%s+{#sec:[%w_-]+}')
    return n.content:sub(1, start)
  end, items)

  vim.api.nvim_buf_set_option(State.bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_lines(State.bufnr, 0, -1, true, content)
  vim.api.nvim_buf_set_option(State.bufnr, 'modifiable', false)
end

local create_buffer = function()
  for _, bn in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(bn) == 'PandocToc' then
      pcall(vim.api.nvim_buf_delete, bn, { force = true })
    end
  end

  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(bufnr, 'PandocToc')

  for _, option in ipairs(buf_options) do
    vim.api.nvim_buf_set_option(bufnr, option[1], option[2])
  end

  local toc_width = config.get().toc.width

  State.bufnr = bufnr

  vim.api.nvim_command('vsp')

  local move_tbl = {
    left = 'H',
    right = 'L',
    bottom = 'J',
    top = 'K',
  }

  vim.api.nvim_command('wincmd ' .. move_tbl[config.get().toc.side or 'right'])

  vim.api.nvim_command('vertical resize ' .. toc_width)

  local winr = vim.api.nvim_get_current_win()

  local win_options = {
    { 'relativenumber', false },
    { 'number', false },
    { 'list', false },
    { 'winfixwidth', true },
    { 'signcolumn', 'yes' },
    { 'foldcolumn', '0' },
    { 'wrap', false },
  }

  for _, option in ipairs(win_options) do
    vim.api.nvim_win_set_option(winr, option[1], option[2])
  end

  vim.api.nvim_command('buffer ' .. bufnr)
end

M.toggle = function()
  if is_open() then
    M.close()
  else
    M.open()
  end
end

local function autocommands()
  vim.cmd('augroup PandocToc')
  vim.cmd('autocmd!')
  vim.cmd(
    'autocmd ' .. table.concat(config.get().toc.update_events, ',') .. ' * lua require"pandoc.toc".handler_new_buffer()'
  )
  vim.cmd('augroup END')
end

M.open = function()
  local opts = config.get()

  if not opts.toc.enable then
    error('toc disable')
  end

  if #opts.toc.filetypes > 0 and not vim.tbl_contains(opts.toc.filetypes, vim.bo.filetype) then
    error('Not a valid filetype')
  end

  if is_open() then
    return
  end

  State.source_bufnr = vim.api.nvim_get_current_buf()

  create_buffer()

  M.handler_update()

  autocommands()

  vim.api.nvim_set_keymap(
    'n',
    '<CR>',
    '<cmd>lua require"pandoc.toc".handler_keypress()<CR>',
    { noremap = true, silent = true, nowait = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    config.get().toc.close or 'q',
    '<cmd>lua require"pandoc.toc".close()<CR>',
    { noremap = true, silent = true, nowait = true }
  )
end

return M
