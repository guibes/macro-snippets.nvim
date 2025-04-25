# macro-snippets.nvim

A Neovim plugin that provides a Telescope interface for managing, browsing, and applying macros.

## Features

- Store macros with names, descriptions, and filetype associations
- Browse and search macros using Telescope
- Apply macros directly from Telescope
- Edit and delete existing macros
- Persistent storage of macros between sessions

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'guibes/macro-snippets.nvim',
  requires = { 'nvim-telescope/telescope.nvim' }
}

