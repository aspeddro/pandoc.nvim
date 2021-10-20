local config = {}

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
  ['--standlone'] = 'flag',
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
  default = {
    output = '%s.pdf',
    args = {
      {'--standlone'}
    }
  }
}

config.options = default_config

config.get = function(option)
  return default_config[option]
end

config.merge = function(option)
  return vim.tbl_deep_extend('force', {}, default_config, option or {})
end

config.types = types

config.get_type = function(option)
  return types[option]
end

return config
