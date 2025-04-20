print( "loading TunerGreatWorksPanel.lua" );

g_PanelHasFocus = false;
g_hideEmptyGreatWorkSlots = false;


function ListAllGreatWorkSlots()
  local showEmpty = true
  local items = {}

  local i;
  for i = 0, GameDefines.MAX_PLAYERS-1, 1 do
    local pPlayer = Players[i]
    local pPlayerConfig = PlayerConfigurations[i]

    if pPlayer:WasEverAlive()  then
      local playerLoc = Locale.Lookup( pPlayerConfig:GetCivilizationShortDescription() )
      if playerLoc == "" then  playerLoc = "Player " .. tostring(i)  end

      local pCities = pPlayer:GetCities()
      for ii, pCity in pCities:Members() do
        -- local cityName = pCity:GetName():gsub("LOC_CITY_NAME_", "")
        local cityNameLoc = Locale.Lookup( pCity:GetName() )

        local prefix = pPlayer:GetID() .. "," .. pCity:GetID()
          .. ";" .. pCity:GetX() .. "," .. pCity:GetY()
          .. ";" .. playerLoc
          .. ";" .. cityNameLoc
          .. ";"
        AppendCityGreatWorkSlots( pCity:GetBuildings(), prefix, items )
      end
    end
  end
  return items
end


function AppendCityGreatWorkSlots(pCityBldgs :table, prefix :string, items :table)
  for buildingInfo in GameInfo.Buildings() do
    local buildingIndex:number = buildingInfo.Index
    if pCityBldgs:HasBuilding(buildingIndex) then
      local numSlots:number = pCityBldgs:GetNumGreatWorkSlots(buildingIndex)
      if (numSlots and numSlots > 0) then
        for slotIndex:number=0, numSlots - 1 do
          local bldgNameLoc = Locale.Lookup(buildingInfo.Name)
          local slotStr = prefix .. bldgNameLoc
          if 1<numSlots then  slotStr = slotStr .. " #" .. tostring(slotIndex+1)  end
          local gwIndex:number = pCityBldgs:GetGreatWorkInSlot(buildingIndex, slotIndex)
          if gwIndex ~= -1 then
            local gwType = pCityBldgs:GetGreatWorkTypeFromIndex(gwIndex)
            local gwInfo = GameInfo.GreatWorks[gwType]
            local name = Locale.Lookup( gwInfo.Name )
            local objType = gwInfo.GreatWorkObjectType
            local objTypeName = GameInfo.GreatWorkObjectTypes[objType].Name
            local objTypeNameLoc = Locale.Lookup( objTypeName )
            local str = slotStr .. ";" .. objTypeNameLoc .. ";" .. name
            table.insert(items, str)
          elseif not m_hideEmptyGreatWorkSlots then
            local slotType = pCityBldgs:GetGreatWorkSlotType(buildingIndex, slotIndex)
            local slotTypeStr = GameInfo.GreatWorkSlotTypes[slotType].GreatWorkSlotType
            local slotTypeStrLoc = slotTypeStr:gsub("GREATWORKSLOT_", ""):gsub("PALACE", "ANY"):lower()
            --local slotTypeStrLoc = Locale.Lookup( slotTypeStr:gsub("GREATWORKSLOT_", "LOC_TYPE_TRAIT_GREAT_WORKS_") .. "_SLOTS", numSlots )
            local str = slotStr .. ";" .. slotTypeStrLoc .. ";-"
            table.insert(items, str)
          end
        end
      end
    end
  end
end


