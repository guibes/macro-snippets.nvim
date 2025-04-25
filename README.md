# macro-snippets.nvim

A Neovim plugin that provides a Telescope interface for managing, browsing, and applying macros.

## Features

- Store macros with names, descriptions, and filetype associations
- Browse and search macros using Telescope
- Apply macros directly from Telescope
- Edit and delete existing macros
- Persistent storage of macros between sessions

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```
{
  "guibes/macro-snippets.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("macro-snippets").setup({
      -- Optional: Custom path for storing macros
      -- macro_store_path = vim.fn.stdpath("data") .. "/custom-macros.json"
    })
    
    -- Optional: Set up keymaps
    vim.keymap.set('n', '<leader>mr', '<cmd>Telescope macros record_macro<CR>', 
      { desc = 'Record Macro' })
    vim.keymap.set('n', '<leader>mm', '<cmd>Telescope macros<CR>', 
      { desc = 'Browse Macros' })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```
use {
  'guibes/macro-snippets.nvim',
  requires = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require("macro-snippets").setup({})
    
    -- Optional: Set up keymaps
    vim.keymap.set('n', '<leader>mr', '<cmd>Telescope macros record_macro<CR>', 
      { desc = 'Record Macro' })
    vim.keymap.set('n', '<leader>mm', '<cmd>Telescope macros<CR>', 
      { desc = 'Browse Macros' })
  end
}
```
## Usage

### Recording a new macro

:Telescope macros record_macro

This will:
1. Prompt for a name, register, description, and filetype
2. Start recording a macro in the specified register
3. Save the macro when you finish recording (by pressing `q`)

### Browsing and applying macros

:Telescope macros

This will show all macros applicable to the current filetype.

In the Telescope window:
- Press `Enter` to apply the selected macro
- Press `<C-e>` to edit the selected macro
- Press `<C-d>` to delete the selected macro

## License

MIT
