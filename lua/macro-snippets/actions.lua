local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local macros = require('macro-snippets')

local M = {}

-- Action to apply the selected macro
function M.apply_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry(prompt_bufnr)
  actions.close(prompt_bufnr)

  if selection then
    macros.apply_macro(selection.value)
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
      macros.delete_macro(selection.index)
      actions.close(prompt_bufnr)
      -- Re-open the macro browser to reflect the updated list
      require('telescope').extensions.macros.macros()
    end
  end
end

return M
