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
      -- Optional: Custom path for storing macros.
      -- To share macros across multiple machines or with a team,
      -- you can set this path to a file within a Git repository.
      -- For example:
      -- macro_store_path = vim.fn.stdpath("config") .. "/nvim-macros/my-shared-macros.json"
      -- or if you have a dotfiles repo:
      -- macro_store_path = vim.fn.expand("$HOME/.dotfiles/nvim/macros/my-macros.json")
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
    require("macro-snippets").setup({
      -- Optional: Custom path for storing macros.
      -- To share macros across multiple machines or with a team,
      -- you can set this path to a file within a Git repository.
      -- For example:
      -- macro_store_path = vim.fn.stdpath("config") .. "/nvim-macros/my-shared-macros.json"
      -- or if you have a dotfiles repo:
      -- macro_store_path = vim.fn.expand("$HOME/.dotfiles/nvim/macros/my-macros.json")
    })
    
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

## Sharing Macros

You can share your macros across multiple machines or with a team by customizing the `macro_store_path` option in the `setup` function.

By default, macros are stored in `vim.fn.stdpath("data") .. "/macro-snippets.json"`. To share them, point `macro_store_path` to a file within a version-controlled directory, such as a Git repository (e.g., your dotfiles).

**Example:**

```lua
require("macro-snippets").setup({
  macro_store_path = vim.fn.expand("$HOME/.dotfiles/nvim/macros/my-macros.json")
  -- or
  -- macro_store_path = vim.fn.stdpath("config") .. "/nvim-macros/shared-macros.json"
})
```

**Recommendations:**

*   Commit the `macro-snippets.json` (or your custom named file) to your repository. This keeps your macros synced and versioned.
*   If sharing with a team, ensure all team members configure their Neovim to use the same `macro_store_path` pointing to the shared JSON file. This could be a file in a shared team dotfiles repository or a dedicated repository for team snippets.

## Future Enhancements

### Animated Macro Previews

A suggestion was made to include animated previews of macro execution. While this is an intriguing idea, implementing it presents significant technical challenges:

*   **Modal Nature of Macros:** Macros often involve mode changes (Normal, Insert, Visual) and rely heavily on the editor's state at the moment of execution. Accurately simulating this for a preview is complex.
*   **Speed and Clarity:** An animation needs to be slow enough to be understandable but fast enough not to be tedious. Finding the right balance is difficult.
*   **Simulating Execution Environment:** A macro might behave differently based on buffer content, cursor position, or existing marks. Replicating a generic yet representative environment for animation is non-trivial.
*   **Visualizing Diverse Commands:** Vim macros can contain a vast range of commands, from simple movements to complex Ex commands or plugin interactions. Visually representing all of these effectively is a major hurdle.
*   **Performance Impact:** Generating animations, even simple ones, could be resource-intensive and might slow down the Telescope picker.

**Potential Conceptual Approaches:**

*   **Controlled Execution:** One idea is to execute the macro in a hidden scratch buffer with timed delays between commands, capturing snapshots or highlighting changes. This would be very challenging to make robust.
*   **Stylized Keystroke Animation:** Another approach could be to parse the macro string and display the sequence of keys with some visual feedback, rather than trying to simulate the full effect on text.

**Conclusion:**

Currently, `macro-snippets.nvim` provides a text-based preview of the macro's content (the actual sequence of commands). This offers a practical way to understand what a macro does before applying it.

Developing a full animated preview feature would require substantial development effort and is considered out of scope for the current version. However, it remains an interesting area for future exploration and contributions from the community.

## License

MIT
