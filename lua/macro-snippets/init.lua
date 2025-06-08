local M = {}

-- Store for macros
M.macros = {}
M.macro_store_path = vim.fn.stdpath("data") .. "/macro-snippets.json"

-- Base64 encoding/decoding functions
local extract = _G.bit32 and _G.bit32.extract -- Lua 5.2/Lua 5.3 in compatibility mode
if not extract then
        if _G.bit then -- LuaJIT
                local shl, shr, band = _G.bit.lshift, _G.bit.rshift, _G.bit.band
                extract = function( v, from, width )
                        return band( shr( v, from ), shl( 1, width ) - 1 )
                end
        elseif _G._VERSION == "Lua 5.1" then
                extract = function( v, from, width )
                        local w = 0
                        local flag = 2^from
                        for i = 0, width-1 do
                                local flag2 = flag + flag
                                if v % flag2 >= flag then
                                        w = w + 2^i
                                end
                                flag = flag2
                        end
                        return w
                end
        else -- Lua 5.3+
                extract = load[[return function( v, from, width )
                        return ( v >> from ) & ((1 << width) - 1)
                end]]()
        end
end

local base64_chars_map = {}
for b64code, char_val in pairs({[0]='A','B','C','D','E','F','G','H','I','J',
                'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
                'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
                'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
                '3','4','5','6','7','8','9','+','/','='}) do
                base64_chars_map[b64code] = char_val:byte()
end

local base64_decode_map = {}
for b64code, charcode_val in pairs(base64_chars_map) do
                base64_decode_map[charcode_val] = b64code
end

local char_fn, concat_fn = string.char, table.concat

local function lua_encode_base64(str)
  if not str then return nil end
  local t, k, n = {}, 1, #str
  local lastn = n % 3
  for i = 1, n-lastn, 3 do
          local a, b, c = str:byte( i, i+2 )
          local v = a*0x10000 + b*0x100 + c
          local s = char_fn(base64_chars_map[extract(v,18,6)], base64_chars_map[extract(v,12,6)], base64_chars_map[extract(v,6,6)], base64_chars_map[extract(v,0,6)])
          t[k] = s
          k = k + 1
  end
  if lastn == 2 then
          local a, b = str:byte( n-1, n )
          local v = a*0x10000 + b*0x100
          t[k] = char_fn(base64_chars_map[extract(v,18,6)], base64_chars_map[extract(v,12,6)], base64_chars_map[extract(v,6,6)], base64_chars_map[64])
  elseif lastn == 1 then
          local v = str:byte( n )*0x10000
          t[k] = char_fn(base64_chars_map[extract(v,18,6)], base64_chars_map[extract(v,12,6)], base64_chars_map[64], base64_chars_map[64])
  end
  return concat_fn( t )
end

local function lua_decode_base64(b64)
  if not b64 then return nil end
  b64 = b64:gsub('[^%w%+%/%=]', '') -- Remove non-base64 characters
  local t, k = {}, 1
  local n = #b64
  local padding = b64:sub(-2) == '==' and 2 or b64:sub(-1) == '=' and 1 or 0
  for i = 1, padding > 0 and n-4 or n, 4 do
          local a, b, c, d = b64:byte( i, i+3 )
          local v = base64_decode_map[a]*0x40000 + base64_decode_map[b]*0x1000 + base64_decode_map[c]*0x40 + base64_decode_map[d]
          local s = char_fn( extract(v,16,8), extract(v,8,8), extract(v,0,8))
          t[k] = s
          k = k + 1
  end
  if padding == 1 then
          local a, b, c = b64:byte( n-3, n-1 )
          local v = base64_decode_map[a]*0x40000 + base64_decode_map[b]*0x1000 + base64_decode_map[c]*0x40
          t[k] = char_fn( extract(v,16,8), extract(v,8,8))
  elseif padding == 2 then
          local a, b = b64:byte( n-3, n-2 )
          local v = base64_decode_map[a]*0x40000 + base64_decode_map[b]*0x1000
          t[k] = char_fn( extract(v,16,8))
  end
  return concat_fn( t )
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
          macro.content = lua_decode_base64(macro.encoded_content)
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
    encoded_macro.encoded_content = lua_encode_base64(macro.content)
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
    vim.notify("Error: Empty macro content. Macro not saved.", vim.log.levels.ERROR)
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
  if not macro or type(macro.content) ~= "string" then
    vim.notify("Error: Cannot apply macro. Content is invalid or missing.", vim.log.levels.ERROR)
    return
  end

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
  if type(index) ~= "number" then
    vim.notify("Error: Invalid index type for deleting macro. Expected a number.", vim.log.levels.ERROR)
    return false
  end

  if #M.macros == 0 then
    vim.notify("Error: No macros to delete.", vim.log.levels.ERROR)
    return false
  end

  if index < 1 or index > #M.macros then
    vim.notify("Error: Macro index (" .. tostring(index) .. ") out of bounds. Valid range is 1 to " .. tostring(#M.macros) .. ".", vim.log.levels.ERROR)
    return false
  end

  table.remove(M.macros, index)
  M.save_macros()
  vim.notify("Macro deleted successfully.", vim.log.levels.INFO)
  return true
end

function M.apply_macro_by_name(macro_name)
  if type(macro_name) ~= "string" or macro_name == "" then
    vim.notify("Error: Macro name must be a string and cannot be empty.", vim.log.levels.ERROR)
    return false
  end

  local found_macro = nil
  for _, macro_obj in ipairs(M.macros) do
    if macro_obj.name == macro_name then
      found_macro = macro_obj
      break
    end
  end

  if found_macro then
    M.apply_macro(found_macro) -- M.apply_macro already exists and handles its own notifications/errors
    return true
  else
    vim.notify("Error: Macro with name '" .. macro_name .. "' not found.", vim.log.levels.ERROR)
    return false
  end
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
