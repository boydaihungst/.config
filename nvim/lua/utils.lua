local M = {}

function string.to_litteral(str) return str and str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") end

function vim.as_table(value) return type(value) ~= "table" and { value } or value end

function vim.tbl_to_set(array)
  local set = {}
  for _, v in ipairs(array) do
    local _v = tostring(v)
    set[_v] = true
  end
  return set
end

--- Extend string table with another string table, value is unique
---@param base table table to extend
---@param extra table table contain new values
---@return table
function vim.tbl_unique_extend(base, extra)
  local seen = {}
  local result = {}

  -- Mark existing items as seen
  for _, v in ipairs(base) do
    if not seen[v] then
      table.insert(result, v)
      seen[v] = true
    end
  end

  -- Add new items only if not seen
  for _, v in ipairs(extra) do
    if not seen[v] then
      table.insert(result, v)
      seen[v] = true
    end
  end

  return result
end
return M
