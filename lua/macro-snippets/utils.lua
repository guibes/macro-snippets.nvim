local M = {}

-- Format the macro display for Telescope
function M.format_macro(macro)
  local display = macro.name

  if macro.filetype and macro.filetype ~= "all" then
    display = display .. " [" .. macro.filetype .. "]"
  end

  if macro.description and macro.description ~= "" then
    display = display .. " - " .. macro.description
  end

  return display
end

-- Get macros filtered by filetype
function M.get_macros_for_filetype(filetype)
  local macros_module = require('macro-snippets')
  local filtered = {}

  for i, macro in ipairs(macros_module.macros) do
    if macro.filetype == "all" or macro.filetype == filetype then
      table.insert(filtered, {
        value = macro,
        display = M.format_macro(macro),
        index = i
      })
    end
  end

  return filtered
end

return M
