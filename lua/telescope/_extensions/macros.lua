local telescope = require('telescope')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local macro_actions = require('macro-snippets.actions')
local utils = require('macro-snippets.utils')
local macros_module = require('macro-snippets')

local macros = {}

-- Telescope picker for browsing macros
macros.browse = function(opts)
  opts = opts or {}

  local current_filetype = vim.bo.filetype
  local macro_entries = utils.get_macros_for_filetype(current_filetype)

  pickers.new(opts, {
    prompt_title = "Macros",
    finder = finders.new_table({
      results = macro_entries,
      entry_maker = function(entry)
        return {
          value = entry.value,
          display = entry.display,
          ordinal = entry.display,
          index = entry.index
        }
      end
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      -- Apply macro with <CR>
      actions.select_default:replace(function()
        macro_actions.apply_macro(prompt_bufnr)
      end)

      -- Edit macro with <C-e>
      map('i', '<C-e>', function()
        macro_actions.edit_macro(prompt_bufnr)
      end)

      -- Delete macro with <C-d>
      map('i', '<C-d>', function()
        macro_actions.delete_macro(prompt_bufnr)
      end)

      return true
    end
  }):find()
end

-- Telescope picker for recording a new macro
macros.record = function(opts)
  opts = opts or {}

  -- Prompt for macro details
  local name = vim.fn.input("Macro name: ")
  if name == "" then return end

  local register = vim.fn.input("Register to use (a-z): ")
  if register == "" or not register:match("^[a-z]$") then
    print("Invalid register. Must be a single letter a-z.")
    return
  end

  local description = vim.fn.input("Description (optional): ")
  local filetype = vim.fn.input("Filetype (leave empty for all): ")

  if filetype == "" then filetype = "all" end

  -- Start recording
  vim.cmd("normal! q" .. register)
  print("Recording macro... Press q to stop.")

  -- After recording, the user will press q to stop
  -- We'll use an autocmd to capture when recording stops
  vim.cmd([[
    augroup MacroRecordingComplete
      autocmd!
      autocmd RecordingLeave * lua require('macro-snippets').add_macro("]] ..
    name .. [[", "]] .. register .. [[", "]] .. description .. [[", "]] .. filetype .. [[")
      autocmd RecordingLeave * lua vim.cmd('autocmd! MacroRecordingComplete')
      autocmd RecordingLeave * lua print("Macro ']] .. name .. [[' saved!")
    augroup END
  ]])
end

-- Register the extension
return telescope.register_extension({
  exports = {
    macros = macros.browse,
    record_macro = macros.record
  }
})
