# pandoc.nvim

A Neovim plugin for [pandoc](https://pandoc.org)

### Requirements

- Neovim >= 0.7.0

### Installation and setup

[**packer.nvim**](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'aspeddro/pandoc.nvim',
  config = function()
    require'pandoc'.setup()
  end
}
```

### Usage

See `help pandoc`
