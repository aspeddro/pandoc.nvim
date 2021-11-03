local M = {}

local types = {
  ['--from'] = 'string',
  ['--read'] = 'string',
  ['--to'] = 'string',
  ['--write'] = 'string',
  ['--output'] = 'string',
  ['--data-dir'] = 'string',
  ['--metadata'] = 'string',
  ['--metadata-file'] = 'string',
  ['--defaults'] = 'string',
  ['--file-scope'] = 'flag',
  ['--standalone'] = 'flag',
  ['--template'] = 'string',
  -- NOTE: variable is not supported
  -- ['--variable'] = 'string',
  ['--wrap'] = {'auto', 'none', 'preserve'},
  ['--ascii'] = 'flag',
  ['--toc'] = 'flag',
  ['--toc-depth'] = 'number',
  ['--number-sections'] = 'flag',
  ['--number-offset'] = 'string',
  ['--top-level-division'] = {'section', 'chapter', 'part'},
  ['--extract-media'] = 'string',
  ['--resource-path'] = 'string',
  ['--include-in-header'] = 'string',
  ['--include-before-body'] = 'string',
  ['--include-after-body'] = 'string',
  ['--no-highlight'] = 'flag',
  ['--highlight-style'] = 'string',
  ['--syntax-definition'] = 'string',
  ['--dpi'] = 'number',
  ['--eol'] = { 'crlf', 'lf', 'native' },
  ['--columns'] = 'number',
  ['--preserve-tabs'] = 'flag',
  ['--tab-stop'] = 'number',
  ['--pdf-engine'] = 'string',
  ['--pdf-engine-opt'] = 'string',
  ['--reference-doc'] = 'string',
  ['--self-contained'] = 'flag',
  ['--request-header'] = 'string',
  ['--no-check-certificate'] = 'flag',
  ['--abbreviations'] = 'string',
  ['--indented-code-classes'] = 'string',
  ['--default-image-extension'] = 'string',
  ['--filter'] = 'string',
  ['--lua-filter'] = 'string',
  ['--shift-heading-level-by'] = 'number',
  ['--base-header-level'] = 'number',
  ['--strip-empty-paragraphs'] = 'flag',
  ['--track-changes'] = { 'accept', 'reject', 'all' },
  ['--strip-comments'] = 'flag',
  ['--reference-links'] = 'flag',
  ['--reference-location'] = { 'block', 'section', 'document' },
  ['--atx-headers'] = 'flag',
  ['--markdown-headings'] = { 'setext', 'atx' },
  ['--listings'] = 'flag',
  ['--incremental'] = 'flag',
  ['--slide-level'] = 'number',
  ['--section-divs'] = 'flag',
  ['--html-q-tags'] = 'flag',
  ['--css'] = 'string',
  -- TODO: add more options
  ['--citeproc'] = 'flag',
  ['--bibliography'] = 'string',
  ['--natbib'] = 'flag',
  ['--biblatex'] = 'flag'
}

local default_config = {
  -- Pandoc default options
  default = {
    -- Output template
    -- @type: string
    output = '%s.pdf',
    -- List of arguments
    -- @type: table
    args = {
      {'--standalone'}
    }
  },
  -- Table Of Content (WIP: unstable)
  toc = {
    -- Enable TOC
    -- @type: boolean
    enable = true,
    -- Width of TOC
    -- @type: number
    width = 35,
    -- Side of TOC
    -- 'left', 'right', 'top' or 'bottom'
    -- @type: string
    side = 'right',
    -- Keybinding to close TOC
    -- @type: string
    close = 'q',
    -- Evetns to update TOC content
    -- @type: table of string
    update_events = {'BufEnter'},
  },
  equation = {
    -- Border style.
    -- 'none', 'single', 'double' or 'rounded'
    -- @type: string
    border = 'single'
  },
  -- Filetypes to enable TOC
  -- 'markdown', 'pandoc' and 'rmd' (RMarkdown)
  -- @type: table of string
  filetypes = {'markdown', 'pandoc', 'rmd'}
}

M.options = default_config

M.get = function()
  return default_config
end

M.set = function(option)
  default_config = option
end

M.merge = function(option)
  return vim.tbl_deep_extend('force', {}, default_config, option or {})
end

M.types = types

M.get_type = function(option)
  return types[option]
end

return M
