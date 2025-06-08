local telescope = require('telescope')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
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
    previewer = previewers.new_buffer_previewer {
      title = "Macro Content",
      get_buffer_by_name = function(entry)
        -- Use a combination of name and index for uniqueness, though name should be enough
        return "macro_preview_" .. entry.value.name .. "_" .. entry.index
      end,
      define_preview = function(self, entry, status)
        if not entry.value or not entry.value.content then
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"No content to preview."})
          return
        end
        -- Split content by newline for setting buffer lines
        local lines = {}
        for s in string.gmatch(entry.value.content, "[^\r\n]+") do
          table.insert(lines, s)
        end
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        -- Optional: Set filetype for syntax highlighting if macros could benefit from it.
        -- For raw Vim macro strings, 'text' is likely fine.
        -- If macros could be Lua, you might set 'lua'.
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'text')
      end,
    },
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
    vim.notify("Invalid register. Must be a single letter a-z.", vim.log.levels.ERROR)
    return
  end

  local description = vim.fn.input("Description (optional): ")
  local filetype = vim.fn.input("Filetype (leave empty for all): ")

  if filetype == "" then filetype = "all" end

  -- Start recording
  vim.cmd("normal! q" .. register)
  vim.notify("Recording macro '" .. name .. "' into register @" .. register .. ". Press q to stop.", vim.log.levels.INFO)

  -- After recording, the user will press q to stop
  -- We'll use an autocmd to capture when recording stops
  vim.cmd([[
    augroup MacroRecordingComplete
      autocmd!
      autocmd RecordingLeave * lua require('macro-snippets').add_macro("]] ..
    name .. [[", "]] .. register .. [[", "]] .. description .. [[", "]] .. filetype .. [[")
      autocmd RecordingLeave * lua vim.cmd('autocmd! MacroRecordingComplete')
      autocmd RecordingLeave * lua vim.notify("Macro ']] .. name .. [[' saved!", vim.log.levels.INFO)
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
