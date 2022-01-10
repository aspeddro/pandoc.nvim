local M = {}

local types = {
  ["--from"] = "string",
  ["--read"] = "string",
  ["--to"] = "string",
  ["--write"] = "string",
  ["--output"] = "string",
  ["--data-dir"] = "string",
  ["--metadata"] = "string",
  ["--metadata-file"] = "string",
  ["--defaults"] = "string",
  ["--file-scope"] = "flag",
  ["--standalone"] = "flag",
  ["--template"] = "string",
  -- NOTE: variable is not supported
  -- ['--variable'] = 'string',
  ["--wrap"] = { "auto", "none", "preserve" },
  ["--ascii"] = "flag",
  ["--toc"] = "flag",
  ["--toc-depth"] = "number",
  ["--number-sections"] = "flag",
  ["--number-offset"] = "string",
  ["--top-level-division"] = { "section", "chapter", "part" },
  ["--extract-media"] = "string",
  ["--resource-path"] = "string",
  ["--include-in-header"] = "string",
  ["--include-before-body"] = "string",
  ["--include-after-body"] = "string",
  ["--no-highlight"] = "flag",
  ["--highlight-style"] = "string",
  ["--syntax-definition"] = "string",
  ["--dpi"] = "number",
  ["--eol"] = { "crlf", "lf", "native" },
  ["--columns"] = "number",
  ["--preserve-tabs"] = "flag",
  ["--tab-stop"] = "number",
  ["--pdf-engine"] = "string",
  ["--pdf-engine-opt"] = "string",
  ["--reference-doc"] = "string",
  ["--self-contained"] = "flag",
  ["--request-header"] = "string",
  ["--no-check-certificate"] = "flag",
  ["--abbreviations"] = "string",
  ["--indented-code-classes"] = "string",
  ["--default-image-extension"] = "string",
  ["--filter"] = "string",
  ["--lua-filter"] = "string",
  ["--shift-heading-level-by"] = "number",
  ["--base-header-level"] = "number",
  ["--strip-empty-paragraphs"] = "flag",
  ["--track-changes"] = { "accept", "reject", "all" },
  ["--strip-comments"] = "flag",
  ["--reference-links"] = "flag",
  ["--reference-location"] = { "block", "section", "document" },
  ["--atx-headers"] = "flag",
  ["--markdown-headings"] = { "setext", "atx" },
  ["--listings"] = "flag",
  ["--incremental"] = "flag",
  ["--slide-level"] = "number",
  ["--section-divs"] = "flag",
  ["--html-q-tags"] = "flag",
  ["--css"] = "string",
  -- TODO: add more options
  ["--citeproc"] = "flag",
  ["--bibliography"] = "string",
  ["--natbib"] = "flag",
  ["--biblatex"] = "flag",
}
-- NOTE: Update README and docs when change default options
local default_config = {
  commands = {
    -- Enable vim commands
    -- :Pandoc
    -- @type: boolean
    enable = true,
    -- Extended Mode
    -- When enabled the arguments passed by the `:Pandoc` command will be extended with the default arguments
    -- @type: boolean
    extended = true,
  },
  -- The pandoc executable
  -- @type: string
  binary = "pandoc",
  -- Pandoc default options
  default = {
    -- Output file name with extension
    -- @type: string
    output = "%s.pdf",
    -- List of arguments
    -- @type: table
    args = {
      { "--standalone" },
    },
  },
  equation = {
    -- Border style.
    -- 'none', 'single', 'double' or 'rounded'
    -- @type: string
    border = "single",
  },
}

M.default = default_config

M.get = function()
  return default_config
end

M.set = function(option)
  default_config = option
end

M.merge = function(option)
  return vim.tbl_deep_extend("force", {}, default_config, option or {})
end

M.types = types

M.get_type = function(option)
  return types[option]
end

return M
