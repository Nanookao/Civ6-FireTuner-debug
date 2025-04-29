--[[
To load:
include( "DebugTools.lua" )
--]]


function printall(...)
  local argn = select('#', ...)
  for i= 1, argn do
    printdetails( select(i, ...) )
  end
end
-- Global
p = print
l = printall


function printdetails(any)
  local paramStr = tostring(any)
  local printed :boolean

  if type(any) == 'table' then
    print("-- "..paramStr .. " - properties:")
    printtable(any)
    printed = true
  end

  local meta = getmetatable(any)
  if meta then
    print("-- "..paramStr .. " - metatable:")
    printtable(meta)
    printed = true
  end
  
  if type(meta) == 'table' and type(meta.__index) == 'table' then
    print("-- "..paramStr .. " - metatable.__index (inherited methods and properties):")
    printtable(meta.__index)
    printed = true
  end

  if not printed then  print("-- "..paramStr)  end
end


function printtable(obj)
  if  type(obj) ~= 'table'  then  print('type(' .. type(obj) .. '):  ' .. tostring(obj));  return  end
  -- if  type(obj) ~= 'table'  then  return print(obj)  end

  for k, v in pairs(obj) do
    print('  '..k..'= '..tostring(v))
  end
end





local BASE_tostring = getmetatable(tostring).BASE_tostring or tostring

function tostring(any)
  local orig = BASE_tostring(any)
  if type(any) == 'table' then
    if type(any.GetID) == 'function' then
      local ok,res = pcall(any.GetID, any)
      if ok then  return orig..': ID="'..res..'"'  end
    end
    if type(any.Name) == 'string' then  return orig..': Name="'..any.Name..'"'  end
  end
  return orig
end

getmetatable(tostring).BASE_tostring = BASE_tostring

