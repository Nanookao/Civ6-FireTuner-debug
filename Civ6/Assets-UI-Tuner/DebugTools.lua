--[[
To load:
include( "DebugTools.lua" )
--]]


function printtable(any, ...)
  -- if  type(any) ~= 'table'  then  print('type ' .. type(any) .. ':  ' .. tostring(any));  return  end
  if  type(any) ~= 'table'  then  return print(any, ...)  end
  print('Properties of:  ' .. tostring(any));
  for k, v in pairs(any) do
    print('  '..k..'= '..tostring(v))
  end
end

p = printtable




local BASE_tostring = getmetatable(tostring).BASE_tostring or tostring

function tostring(any)
  local orig = BASE_tostring(any)
  if type(any) == 'table' then
    return
      type(any.GetID) == 'function' and orig..': ID="'..any:GetID()..'"'
      or type(any.Name) == 'string' and orig..': Name="'..any.Name..'"'
      or orig
  end
  return orig
end

getmetatable(tostring).BASE_tostring = BASE_tostring

