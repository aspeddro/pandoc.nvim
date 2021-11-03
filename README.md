# pandoc.nvim

> WIP

A Neovim plugin for [pandoc](https://pandoc.org)

## Requirements

- `Neovim >= 0.5.0`
- [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim)

## Installation

```lua
use {
  'aspeddro/pandoc.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'jbyuki/nabla.nvim' -- Optional. See Extra Features
  }
}
```

## Configuration

```lua
local opts = {
  -- Pandoc default optios
  default = {
    -- Output template. Create a pdf.
    output = '%s.pdf',
    -- List of arguments
    args = {
      {'--standalone'}
    }
  },
  -- WIP. Table Of Contents Menu
  toc = {
    -- Enable TOC
    enable = true,
    -- Width of TOC
    width = 35,
    -- Side of TOC
    side = 'right',
    -- Keybinding to close TOC
    close = 'q',
    -- Update TOC Content when Buffer Enter
    update_events = {'BufEnter'},
  },
  -- Filetypes to enable TOC
  filetypes = {'markdown', 'pandoc', 'rmd'}
}
require'pandoc'.setup(opts)
```

### Add Models

A named table, where each table is a model

```lua
require'pandoc'.setup{
  models = {
    -- Paper Model
    paper = {
      -- Enable biblatex
      {'--biblatex'}
      -- Produce Table of Content
      {'--toc'}
    },
    -- Beamer slide show
    beamer = {
      {'--to', 'beamer'}
    }
  }
}
```

### Keymappings

```lua
local pandoc = require'pandoc'
pandoc.setup{
  mapping = {
    ['<leader>pr'] = function()
      pandoc.run()
    end,
    ['<leader>ep'] = function()
      -- requires nabla.nvim
      pandoc.equation.show()
    end,
    ['<leader>pt'] = function()
      pandoc.toc.toggle()
    end
  }
}
```

### Extra Features

- LaTeX equation preview with [nabla.nvim](https://github.com/jbyuki/nabla.nvim/)

![image](https://user-images.githubusercontent.com/16160544/140002079-244d1727-488d-4b7c-aab8-1232e85e08c9.png)

## Usage

> Input file is the current buffer. Use `Tab` key for completion

Basic command, use default options:

```
Pandoc
```

Enable `--toc` table-of-contents and `--top-level-division`
```
Pandoc toc citeproc top-level-division=section output=example_pandoc.pdf
```

Use a model:
```
PandocModel
```

### Examples

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

## Lua API

- `pandoc.setup`
- `pandoc.run`
- `pandoc.run_model`
- `pandoc.toc`
- `pandoc.equation`

## Limitations

- `variable` argument is not supported

## TODO

- [ ] Make TOC more stable
