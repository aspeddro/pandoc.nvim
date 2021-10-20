# pandoc.nvim

A Neovim plugin for [pandoc](https://pandoc.org)

## Requirements

- `Neovim >= 0.5.0`
- [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim)

## Installation

```lua
use {
  'aspeddro/pandoc.nvim',
  requires = { 'nvim-lua/plenary.nvim' }
}
```

## Configuration

```lua
require'pandoc'.setup{
  default = {
    output = '%s.pdf' -- default output
    args = {
      {'--standlone'}
    }
  }
}
```

- `default` (table)
  - `output` (string): file name template with extension
  - `args` (table): table with arguments. Each argument or flag is a table. Argument with values, should be a table with size two `{ '--argument', 'value' }`.
- `models` (table): optional. A named table, where each table is a model
  ```lua
  models = {
    paper = {
      {'--biblatex'}
      {'--toc'}
    },
    -- Beamer slide show
    beamer = {
      {'-t', 'beamer'}
    }
  }
  ```

## Usage

Basic command, use default options:

```
Pandoc
```

Enable `--toc` table-of-contents and `--top-level-division`
```
Pandoc toc citeproc top-level-division=section
```

```
Pandoc output=notes.pdf
```

```
PandocModel NameModel
```

### Examples

1. HTML Fragment
  - `Pandoc output=example.html`
2. Standalone HTML file:
  - `Pandoc standlone output=example2.html`
3. HTML with table of contents, CSS, and custom footer
  - `Pandoc standlone toc css=pandoc.css include-after-body=footer.html output=example3.html`
4. LaTeX
  - `Pandoc standlone output=example4.tex`
5. From LaTeX to markdown:
  - `Pandoc standalone output=example.text`
6. reStructuredText
  - `Pandoc standlone to=rst toc output=example6.text`
7. Rich text format (RTF):
  - `Pandoc standlone output=example7.rtf`
8. Beamer slide show:
  - `Pandoc to=beamer output=example8.pdf`
9. DocBook XML:
  - `Pandoc standlone to=docbook output=example9.db`
10. Man page:
  - `Pandoc standlone to=man output=example10.1`
11. ConTeXt:
  - `Pandoc standlone to=context output=example11.tex`
12. From markdown to PDF:
  - `Pandoc pdf-engine=xelatex output=example12.pdf`
13. PDF with numbered sections and a custom LaTeX template:
  - `pandoc number-sections template=template.tex pdf-engine=xelatex toc output=example13.pdf`

## Lua API

- `pandoc.setup`
- `pandoc.run`
- `pandoc.run_model`

## Limitations

- `variable` argument is not supported

## TODO

- [ ] Support events
- [ ] Model with options
