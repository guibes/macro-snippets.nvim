local M = {}

-- Store for macros
M.macros = {}
M.macro_store_path = vim.fn.stdpath("data") .. "/macro-snippets.json"

-- Base64 encoding/decoding functions
local function encode_base64(str)
  if not str then return nil end
  return vim.fn.system("echo -n " .. vim.fn.shellescape(str) .. " | base64"):gsub("\n", "")
end

local function decode_base64(b64)
  if not b64 then return nil end
  return vim.fn.system("echo -n " .. vim.fn.shellescape(b64) .. " | base64 --decode")
end

-- Load macros from file
function M.load_macros()
  local file = io.open(M.macro_store_path, "r")
  if file then
    local content = file:read("*all")
    file:close()

    if content and content ~= "" then
      local encoded_macros = vim.fn.json_decode(content)

      -- Decode the macro content
      M.macros = {}
      for _, macro in ipairs(encoded_macros) do
        if macro.encoded_content then
          macro.content = decode_base64(macro.encoded_content)
          macro.encoded_content = nil
        end
        table.insert(M.macros, macro)
      end
    end
  end
end

-- Save macros to file
function M.save_macros()
  -- Create a copy with encoded content
  local encoded_macros = {}
  for _, macro in ipairs(M.macros) do
    local encoded_macro = vim.deepcopy(macro)
    encoded_macro.encoded_content = encode_base64(macro.content)
    encoded_macro.content = nil
    table.insert(encoded_macros, encoded_macro)
  end

  local file = io.open(M.macro_store_path, "w")
  if file then
    file:write(vim.fn.json_encode(encoded_macros))
    file:close()
  end
end

-- Add a new macro
function M.add_macro(name, register, description, filetype)
  local macro_content = vim.fn.getreg(register)

  -- Validate macro content before adding
  if not macro_content or macro_content == "" then
    print("Error: Empty macro content")
    return false
  end

  table.insert(M.macros, {
    name = name,
    content = macro_content,
    description = description,
    register = register,
    filetype = filetype or "all",
    created_at = os.time()
  })

  M.save_macros()
  return true
end

-- Apply a macro
function M.apply_macro(macro)
  -- Store the current register state
  local old_reg_content = vim.fn.getreg('"')
  local old_reg_type = vim.fn.getregtype('"')

  -- Set the register with the macro content
  vim.fn.setreg('"', macro.content)

  -- Execute the macro
  vim.cmd('normal @"')

  -- Restore the register
  vim.fn.setreg('"', old_reg_content, old_reg_type)
end

-- Delete a macro
function M.delete_macro(index)
  table.remove(M.macros, index)
  M.save_macros()
end

-- Set up the plugin
function M.setup(opts)
  opts = opts or {}

  -- Override default options
  if opts.macro_store_path then
    M.macro_store_path = opts.macro_store_path
  end

  -- Load existing macros
  M.load_macros()

  -- Register the Telescope extension
  require('telescope').load_extension('macros')
end

return M
