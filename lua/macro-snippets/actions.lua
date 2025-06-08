local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local core_macros_module = require('macro-snippets') -- Renamed for clarity

local M = {}

-- Action to apply the selected macro or load it into a register
function M.apply_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry(prompt_bufnr)

  if not selection then
    actions.close(prompt_bufnr) -- Close if no selection somehow
    return
  end

  -- Get selection details first, as closing the prompt might invalidate state for input
  local macro_to_process = selection.value -- This is the macro object {name, content, ...}

  actions.close(prompt_bufnr) -- Close Telescope prompt

  local chosen_reg = vim.fn.input("Load to register (a-z, leave blank to apply directly): ")

  if chosen_reg and chosen_reg ~= "" then
    if not string.match(chosen_reg, "^[a-z]$") then
      vim.notify("Error: Invalid register. Must be a single lowercase letter (a-z).", vim.log.levels.ERROR)
      return
    end

    -- Ensure content exists before setting register
    if macro_to_process and macro_to_process.content then
      vim.fn.setreg(chosen_reg, macro_to_process.content, 'c')
      vim.notify("Macro '" .. macro_to_process.name .. "' loaded into register @" .. chosen_reg, vim.log.levels.INFO)
    else
      vim.notify("Error: Selected macro has no content to load.", vim.log.levels.ERROR)
    end
  else
    -- User left it blank, apply directly using the function from init.lua
    core_macros_module.apply_macro(macro_to_process)
  end
end

-- Action to edit a macro
function M.edit_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry(prompt_bufnr)
  actions.close(prompt_bufnr)

  if selection then
    -- Create a temporary buffer for editing
    vim.cmd('new')
    local buf = vim.api.nvim_get_current_buf()

    -- Set buffer content to the macro
    local lines = {}
    if selection.value.content and selection.value.content ~= "" then
      for s in string.gmatch(selection.value.content, "[^\r\n]+") do
        table.insert(lines, s)
      end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_name(buf, "Edit Macro: " .. selection.value.name)

    -- Set up autocmd to save the macro when writing the buffer
    vim.cmd(string.format([[
      augroup MacroEdit
        autocmd!
        autocmd BufWriteCmd <buffer> lua require('macro-snippets').macros[%d].content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'); require('macro-snippets').save_macros(); vim.cmd('bd!')
      augroup END
    ]], selection.index))
  end
end

-- Action to delete a macro
function M.delete_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry(prompt_bufnr)

  if selection then
    local confirm = vim.fn.input("Delete macro '" .. selection.value.name .. "'? (y/n): ")
    if confirm:lower() == 'y' then
      core_macros_module.delete_macro(selection.index) -- Use renamed module
      actions.close(prompt_bufnr)
      -- Re-open the macro browser to reflect the updated list
      require('telescope').extensions.macros.macros()
    end
  end
end

return M
