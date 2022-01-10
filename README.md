# pandoc.nvim

> WIP

A Neovim plugin for [pandoc](https://pandoc.org)

## Requirements

- `Neovim >= 0.5.0`

## Installation

#### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 'aspeddro/pandoc.nvim' }
```

## Setup

```lua
require'pandoc'.setup()
```

## Configuration (optional)

Following are the default config for the `setup()`. If you want to override, just modify the option that you want then it will be merged with the default config.

```lua
{
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
  binary = 'pandoc',
  -- Pandoc default options
  default = {
    -- Output file name with extension
    -- @type: string
    output = '%s.pdf',
    -- List of arguments
    -- @type: table
    args = {
      { '--standalone' },
    },
  },
  equation = {
    -- Border style.
    -- 'none', 'single', 'double' or 'rounded'
    -- @type: string
    border = 'single',
  },
}
```

### Keymappings

Create your keymappings

```lua
local pandoc = require'pandoc'

pandoc.setup{
  mapping = {
    -- normal mode
    n = {
      ['<leader>pr'] = function()
        pandoc.render.init()
      end,
      ['<leader>ps'] = function()
        -- Make your pandoc command
        local input = vim.api.nvim_get_buf_name(0)
        pandoc.render.build{
          input = input,
          args = {
            {'--standalone'},
            {'--toc'},
            {'--filter', 'pandoc-crossref'},
            {'--pdf-engine', 'xelatex'}
          },
          output = 'pandoc.pdf'
        }
      end,
      ['<leader>ep'] = function()
        -- require nabla.nvim
        pandoc.equation.show()
      end
    }
  }
}
```

### Extra Features

- LaTeX equation preview with [nabla.nvim](https://github.com/jbyuki/nabla.nvim/)

![image](https://user-images.githubusercontent.com/16160544/140002079-244d1727-488d-4b7c-aab8-1232e85e08c9.png)

`nabla.nvim` does not support all LaTeX notations

## Usage

> Input file is the current buffer. Use `Tab` key for completion

Use default options:

```
Pandoc
```

When `output` is passed the path can be specified (e.g: `Pandoc output=out/example.pdf`). When path is not specified the file is created in the same directory of Neovim

```
Pandoc output=example.pdf
```

Enable table of contents (`--toc` flag) and `--top-level-division` argument.

```
Pandoc toc citeproc top-level-division=section
```

### More Examples

1. HTML Fragment
  - `Pandoc output=example.html`
2. Standalone HTML file:
  - `Pandoc output=example2.html`
3. HTML with table of contents, CSS, and custom footer
  - `Pandoc toc css=pandoc.css include-after-body=footer.html output=example3.html`
4. LaTeX
  - `Pandoc output=example4.tex`
5. From LaTeX to markdown:
  - `Pandoc output=example.text`
6. reStructuredText
  - `Pandoc to=rst toc output=example6.text`
7. Rich text format (RTF):
  - `Pandoc output=example7.rtf`
8. Beamer slide show:
  - `Pandoc to=beamer output=example8.pdf`
9. DocBook XML:
  - `Pandoc to=docbook output=example9.db`
10. Man page:
  - `Pandoc to=man output=example10.1`
11. ConTeXt:
  - `Pandoc to=context output=example11.tex`
12. From markdown to PDF:
  - `Pandoc pdf-engine=xelatex output=example12.pdf`
13. PDF with numbered sections and a custom LaTeX template:
  - `Pandoc number-sections template=template.tex pdf-engine=xelatex toc output=example13.pdf`

## Limitations

- Currently `variable` argument is not supported

## TODO

- Create documentation
