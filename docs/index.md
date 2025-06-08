# macro-snippets.nvim

**macro-snippets.nvim** is a powerful Neovim macro manager plugin that enhances your workflow by providing a seamless Telescope interface to record, save, browse, and apply macros. Stop losing your valuable macros between sessions! With this plugin, you can persistently store your Lua macros (and any VimL macros) with names, descriptions, and even filetype associations. Effortlessly search and execute your saved command sequences, turning repetitive tasks into single actions. Whether you're looking to record and play macros on the fly, build a library of reusable snippets, or simply want a better way to handle Neovim's macro capabilities, macro-snippets.nvim is the essential tool for efficient text editing.

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

**Important Note on Macro Content:**

The plugin saves the exact sequence of keys present in the specified register after you finish recording (by pressing `q` the second time). If your recorded keystrokes themselves include commands that place very large content (e.g., the entire file) into that *same recording register*, then the macro's definition will become that large content.

For example:
- If you start recording into register `a` (by typing `qa`).
- Then, as part of your recording, you execute `ggVG"ay` (select all text, then yank it specifically into register `a`).
- When you stop recording (by typing `q` again), the content of register `a` will be the entire file's text.
- Consequently, the macro saved by this plugin for "register a" will be the entire file's text.

Please be mindful of this when recording. If you intend to yank text as part of a macro, ensure you are yanking it to the intended register (often the unnamed register `"` if not specified, or a different named register) unless you explicitly want the recording register to contain that yanked text as the macro's definition. A warning will be issued if the recorded content seems excessively large (see next step in plan).

### Browsing and applying macros

:Telescope macros

This will show all macros applicable to the current filetype.

In the Telescope window:
- Press `Enter` on a selected macro:
    - You will be prompted: "Load to register (a-z, leave blank to apply directly): "
    - **If you enter a single lowercase letter (a-z) and press Enter:** The macro's content will be loaded into that register (e.g., `@a`). You can then execute it using Vim's native `@<register>` command (e.g., `@a`). A notification will confirm this.
    - **If you leave the prompt blank and press Enter:** The macro will be applied (executed) directly in the current buffer, similar to the previous behavior.
- Press `<C-e>` to edit the selected macro
- Press `<C-d>` to delete the selected macro

## Example Macro Set

This plugin includes a `sample_macros.json` file in the root of the repository, containing a collection of useful macros for various filetypes to help you get started. These macros are pre-encoded in Base64.

Filetypes covered in the samples include: Markdown, JavaScript, TypeScript, JSX, TSX, YAML, Go, Lua, and Python.

### How to Use the Sample Macros

1.  **Locate your Neovim data directory.** You can find this path by running the command `:echo stdpath('data')` in Neovim. The file where this plugin stores your macros is typically named `macro-snippets.json` inside this data directory.
    *   Example on Linux/macOS: `~/.local/share/nvim/macro-snippets.json`
    *   Example on Windows: `~/AppData/Local/nvim-data/macro-snippets.json`

2.  **IMPORTANT: Back up your existing macros (if any).** If you already have a `macro-snippets.json` file with your own saved macros, copying the sample file will **overwrite your current macros**. Make sure to back up your existing file first if you want to keep it.

3.  **Copy `sample_macros.json`:**
    *   Copy the `sample_macros.json` file from the root of this plugin's directory to your Neovim data directory, renaming it to `macro-snippets.json`.
    *   For example, if the plugin is installed at `~/.config/nvim/plugged/macro-snippets.nvim` and your data path is `~/.local/share/nvim`, you might run:
        ```bash
        cp ~/.config/nvim/plugged/macro-snippets.nvim/sample_macros.json ~/.local/share/nvim/macro-snippets.json
        ```
        *(Adjust paths based on your plugin manager and operating system).*

4.  **Restart Neovim or Reload Macros:** After copying the file, restart Neovim, or if the plugin provides a way to reload macros (currently it loads on setup), that would also work. The sample macros should then be available in the Telescope browser (`:Telescope macros`).

### Merging with Existing Macros (Advanced)

If you want to combine the sample macros with your own existing macros, you'll need to manually edit the JSON files. Both your existing `macro-snippets.json` and the `sample_macros.json` contain a JSON array (`[...]`) of macro objects. You would need to:
1. Open both files in a text editor.
2. Copy the macro objects (the parts enclosed in `{...}`) from one file.
3. Paste them into the array of the other file, ensuring you maintain valid JSON syntax (e.g., add a comma between objects if needed).
4. Save the modified `macro-snippets.json` file.
It's recommended to use a JSON-aware editor or a JSON linting tool to ensure the resulting file is still valid JSON.

## Alternative Ways to Trigger Macros

Besides using the Telescope interface, you can also set up other ways to trigger your saved macros for even quicker access. This requires adding a small helper function to your `init.lua` (or any file sourced by it) that the plugin will provide.

First, ensure this function is available in your Neovim setup by adding the following to your `init.lua` (or a relevant Lua file that's loaded, like `lua/utils.lua` in your config):

_(This function will be added to the plugin itself in a future update. For now, you can define it manually)_

```lua
-- Place this in your personal Neovim Lua configuration
-- e.g., in your init.lua or a lua/utils.lua file

-- (Assuming your macro-snippets plugin is loaded and M.macros is populated)
-- NOTE: This is a placeholder for a function that will ideally be exposed by the plugin directly.
-- For now, this example shows how such a function would work.
-- You would call `require('macro-snippets').apply_macro_by_name("YourMacroName")`
-- if the plugin exposed this function.

-- If you want to implement this manually for now:
-- Make sure 'macro-snippets' is already required and setup.
-- local macros_module = require('macro-snippets') -- if not already available

-- _Placeholder: The actual `apply_macro_by_name` will be part of the plugin's API._
-- _The examples below assume such a function exists or you've defined a similar helper._
```

_(The subtask will add the actual `apply_macro_by_name` function to `lua/macro-snippets/init.lua` as part of the implementation step for these triggers, so the README will eventually point to that directly. For now, the README will describe the *concept* and how users would use such a function)._

### 1. Direct Key Mappings

You can map specific macros to keybindings in your Neovim configuration. This is useful for macros you use very frequently.

**Example:**

Assuming the plugin exposes `require('macro-snippets').apply_macro_by_name(name)`:

```lua
-- In your init.lua or keymappings.lua
vim.keymap.set('n', '<leader>m1', function()
  require('macro-snippets').apply_macro_by_name("NameOfYourFirstMacro")
end, { desc = "Apply 'NameOfYourFirstMacro'" })

vim.keymap.set('n', '<leader>m2', function()
  require('macro-snippets').apply_macro_by_name("AnotherFrequentlyUsedMacro")
end, { desc = "Apply 'AnotherFrequentlyUsedMacro'" })
```
Replace `"NameOfYourFirstMacro"` with the actual name of your saved macro.

### 2. Using a User Command

You can define a user command to apply macros by name. This allows you to run them from the command line (e.g., `:MacroApply MyMacroName`) and also makes them searchable in Telescope's built-in command finder (`:Telescope commands`).

**Example:**

Assuming the plugin exposes `require('macro-snippets').apply_macro_by_name(name)` which is then used by the command:

The plugin will aim to provide a command like `:MacroApply <macro_name>`.

If you were to set this up manually using the helper:
```lua
-- In your init.lua or commands.lua
-- (Requires the apply_macro_by_name function mentioned above)
vim.api.nvim_create_user_command(
  'MyApplyMacro', -- Choose your command name
  function(opts)
    if opts.args == "" then
      vim.notify("Error: Macro name required for :MyApplyMacro", vim.log.levels.ERROR)
      return
    end
    -- This would internally call the function to find and apply the macro by name
    -- For example: YourGlobalHelper.apply_macro_by_name(opts.args)
    -- Or eventually: require('macro-snippets').apply_macro_by_name(opts.args)
    vim.notify("Applying macro: " .. opts.args .. " (if found)", vim.log.levels.INFO)
  end,
  {
    nargs = 1,
    -- Example for completion (if you build a list of macro names):
    -- complete = function(arglead, cmdline, cursorpos)
    --   local names = { "Macro1", "Macro2", "FixTypo" } -- fetch your macro names
    --   return vim.tbl_filter(function(name)
    --     return vim.startswith(name, arglead)
    --   end, names)
    -- end,
    desc = "Apply a macro-snippet by name"
  }
)
```
You would then run `:MyApplyMacro NameOfYourMacro`. The plugin aims to provide a built-in `:MacroApply` command with completion in the future.

### 3. Snippet-like Expansion (Advanced)

For very advanced use cases, you might consider setting up snippet-like expansions where typing a short keyword automatically triggers a macro. This is more complex and can have performance implications or conflicts if not carefully designed.

**Example Idea (Insert Mode Mapping):**
```lua
-- Caution: Simple insert mode mappings like this can sometimes have unintended side effects.
-- This assumes an apply_macro_by_name function is available.
vim.keymap.set('i', '!fix', '<Esc>:<C-u>lua require("macro-snippets").apply_macro_by_name("FixCommonTypo")<CR>a',
  { desc = "Fix common typo with macro" })
```
This example maps `!fix` in insert mode to escape, run the Lua command to apply a macro named "FixCommonTypo", and then re-enter insert mode. More robust solutions would involve `TextChangedI` autocommands or integration with snippet engines, which is beyond the scope of simple setup.

### 4. Contextual Triggers (Conceptual)

Further enhancements could involve contextual triggers, where macros are suggested or become easier to access based on the current filetype, project, or even buffer content. This is an area for future exploration.

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

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](../CONTRIBUTING.md) for more information on how to report bugs, suggest features, and submit pull requests.

All interactions in this project are subject to our [Code of Conduct](../CODE_OF_CONDUCT.md).

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. Please read the [Code of Conduct](../CODE_OF_CONDUCT.md) for details.

## License

MIT
