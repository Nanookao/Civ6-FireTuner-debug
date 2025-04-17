print( "loading TunerCityPanel.lua" )
include( "DebugTools.lua" )
--return

TunerCity = TunerCity or {}
TunerCity.ListIDdefault = 'built'
TunerCity.selected = TunerCity.selected or {}
TunerCity.options  = TunerCity.options  or { BuildPercent = 100 }

--[[
include("TunerCityPanel")
p = Map.GetPlotByIndex(l) ; print( string.format("0x%x", l) )
print( p:GetX(), p:GetY() )
TunerCity.selected.pCity
TunerCity.selected.pCity:GetLocation()
TunerCity.selected.pCity:GetDistricts():GetDistrictLocation(0)
TunerCity.selected.pCity:GetDistricts():GetDistrict(0):GetLocation()
TunerCity.selected.pCity:GetBuildings():GetBuildingLocation(2)
a= Map.GetPlot(10,1)
b= a:GetIndex()
CityManager.IsDistrict(50,42)
CityManager.IsDistrict(50,43)
CityManager.IsDistrict( Map.GetPlotIndex(50,43) )
CityManager.IsDistrict( Map.GetPlot(50,43) )
CityManager.GetDistrictAt( CityManager.GetCityAt(50,43) )
Map.GetPlot(40,27)
Map.GetPlot( Map.GetPlot(40,27) ):GetY()
Map.GetPlot(2308)

print(a,b,c)
--]]

-------------------------------------------------------------------------------
function minmax(value, minimum, maximum)
  if value < minimum then  return minimum  end
  if value > maximum then  return maximum  end
  return value
end




-------------------------------------------------------------------------------
function TunerCity:SetFocused(focused)
  self.focused = focused
  self.SetDebugMode[focused]()
end

TunerCity.SetDebugMode = {}
TunerCity.SetDebugMode[true] = LuaEvents.TunerEnterDebugMode
TunerCity.SetDebugMode[false] = LuaEvents.TunerExitDebugMode

function TunerCity.OnUIDebugModeEntered()
  TunerCity.inDebugMode = true;
end

function TunerCity.OnUIDebugModeExited()
  TunerCity.inDebugMode = false;
end




-------------------------------------------------------------------------------
function TunerCity:ListCities(items :table)
  items = items or {}
  -- local numPlayers = PlayerManager.GetWasEverAliveCount()
  -- for playerID = 0, numPlayers-1, 1 do
  for playerID = 0, GameDefines.MAX_PLAYERS-1, 1 do
    local pPlayer = Players[playerID]
    if pPlayer:WasEverAlive() then
      self:ListPlayerCities(items, pPlayer)
    end
  end
  return items
end

function TunerCity:ListPlayerCities(items :table, pPlayer :table)
  items = items or {}
  if not pPlayer then  return items  end

  local playerID = pPlayer:GetID()
  local pPlayerConfig = PlayerConfigurations[playerID]
  local playerLoc = Locale.Lookup( pPlayerConfig:GetCivilizationShortDescription() )
  if playerLoc == "" then  playerLoc = "Player "..tostring(playerID)  end

  local pCities = pPlayer:GetCities();
  for ii, pCity in pCities:Members() do
    local str = self:FormatCity(pCity, playerLoc)
    table.insert(items, str)

    if pCity == self.selected.pCity then
      items.selected = #items;
      local cityLoc = Locale.Lookup( pCity:GetName() )
      -- print("TunerCity:ListPlayerCities()  found selected city #"..items.selected.." "..cityLoc )
    end
  end
  return items
end

function TunerCity:FormatCity(pCity :table, playerLoc :string)
  local playerID = pCity:GetOwner()
  local cityID = pCity:GetID()
  local cityIDStr = string.format("0x%x", cityID)
  local cityIdx = cityID % 0x10000
  -- local cityIdx = cityID & 0xFFFF
  -- local cityIdxUpper = math.floor(cityID / 0x10000)
  -- local cityIDStr = cityIdxUpper..","..cityIdx
  local ID = playerID..","..cityIDStr

  local origOwner = pCity:GetOriginalOwner()
  local origOwnerLoc = ""
  if origOwner ~= playerID then
    origOwnerLoc = "none";
    if origOwner ~= -1 then
      local origOwnerStr = PlayerConfigurations[origOwner]:GetCivilizationShortDescription();
      origOwnerLoc = Locale.Lookup( origOwnerStr )
      --origOwnerLoc = origOwnerStr:gsub("^LOC_CIVILIZATION_", "");
      if origOwnerLoc == "" then  origOwnerLoc = "Player "..tostring(origOwner)  end
    end
    origOwnerLoc = origOwnerLoc.." ->"
  end

  --local cityName = pCity:GetName():gsub("^LOC_CITY_NAME_", "")
  local cityLoc = Locale.Lookup( pCity:GetName() )
  local buildingLoc = self:GetCurrentlyBuildingLoc(pCity)
  --local progress = self:GetCityBuildProgress(pCity)
  local location = pCity:GetX()..","..pCity:GetY()

  local str = "    "..ID
    ..";"..origOwnerLoc
    ..";"..playerLoc
    ..";"..playerID..","..cityIdx
    ..";"..cityLoc
    ..";"..location
    ..";"..buildingLoc
  return str;
end




-------------------------------------------------------------------------------
function TunerCity:SelectCity(selCity: string)
  -- No split available
  local playerIDStr, cityIDStr = selCity:match("^(%d+),(%w+)");
  print("TunerCity:SelectCity()  selCity, playerIDStr, cityIDStr=", selCity, playerIDStr, cityIDStr)
  local pPlayer = Players[ tonumber(playerIDStr) ];
  -- self.selected.pPlayer = pPlayer;

  local cityID = tonumber(cityIDStr)
  local pCity = cityID and pPlayer and pPlayer:GetCities():FindID(cityID)
  if not pCity then  return pCity  end

  self:SetSelectedCity(pCity)
  -- UI.LookAtPlot( pCity:GetX(), pCity:GetY() )

  --[[
  print('----');
  print('TunerCity:SelectCity("'..selCity..'"):', pCity:GetName());
  print('ContextPtr' , ContextPtr);
  print('city[panel]' , pCity);
  --print( '.GetBuildQueue[panel]' , pCity.GetBuildQueue )
  if  pCity.GetBuildQueue  then
    local pBuildQueue = pCity:GetBuildQueue()
    print( ':GetBuildQueue' , pBuildQueue )
    print( ':CurrentlyBuilding'  , TunerCity:GetCurrentlyBuildingLoc(pCity) )
    print( '.GetTurnsLeft'       , pBuildQueue.GetTurnsLeft )
    print( '.GetProductionYield' , pBuildQueue.GetProductionYield )
  end
  print( 'LuaEvents.PrintCityInfo(pCity):' )
  LuaEvents.PrintCityInfo(pCity);
  print('----');
  --]]

  return pCity;
end



function TunerCity:GetSelectedBuilding(listID :string)
  return self.selected[listID or self.ListIDdefault]
end

TunerCity.typePrefix = {
  district = "DISTRICT_",
  building = "BUILDING_",
  wonder   = "BUILDING_",
}

function TunerCity:SelectBuilding(selBuilding: string, listID :string)
  print( "TunerCity:SelectBuilding()", selBuilding, listID, TunerCity.skipSelect and "skipSelect" )
  if TunerCity.skipSelect and not listID then
    TunerCity.skipSelect = false
    return
  end
  listID = listID or self.ListIDdefault
  local buildingType = selBuilding:match("^([^,]*)")
  local districtIDStr = selBuilding:match(",([^,]*)")
  -- Restore the full buildingType
  local prefix = self.typePrefix[listID] or ""
  buildingType = prefix..buildingType
  local isDistrict = (listID == 'district') or (prefix == "" and selBuilding:match("^DISTRICT_"))

  local dbBuildings = isDistrict and GameInfo.Districts or GameInfo.Buildings
  local dbBuildingInfo = dbBuildings[buildingType]
  self.selected[listID] = dbBuildingInfo

  if listID == self.ListIDdefault then
    -- Select district only in built objects list
    self:SelectDistrictOfBuilding(dbBuildingInfo, districtIDStr)
  end

  return dbBuildingInfo
end


function TunerCity:SelectDistrictOfBuilding(dbBuildingInfo :table, districtIDStr :string)
  if not dbBuildingInfo then  return  end
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local districtID = tonumber(districtIDStr)
  local pDistricts = pCity:GetDistricts()
  local pDistrict
  if dbBuildingInfo.BuildingType then
    local plotID = pCity:GetBuildings():GetBuildingLocation(dbBuildingInfo.Index)
    -- local pDistrict = pCity.DistrictsByPlotID[plotID]
    pDistrict = pDistricts:GetDistrictAtLocation(plotID)
    if not pDistrict then
      -- Not built yet, try the building's associated district
      local dbDistrictInfo = GameInfo.Districts[dbBuildingInfo.PrereqDistrict]
      pDistrict = pDistricts:GetDistrictByIndex(dbDistrictInfo.Index)
    end
  else
    pDistrict = districtID and pDistricts.GetDistrictByID and pDistricts:GetDistrictByID(districtID)
      or pDistricts:GetDistrictByIndex(dbBuildingInfo.Index)
  end

  if not pDistrict then
    print( "TunerCity:SelectDistrictOfBuilding()  district not found:  "
      ..(dbBuildingInfo.DistrictType or dbBuildingInfo.BuildingType).."  "..tostring(districtIDStr) )
  end
  return pDistrict and self:SelectDistrict(pDistrict)
end


function TunerCity:SelectDistrict(pDistrict)
  if pDistrict and self:SetSelectedDistrict(pDistrict) then
    -- TODO: UI context
    -- UI.LookAtPlot( pDistrict:GetX(), pDistrict:GetY() )
    return pDistrict
  end
end




-------------------------------------------------------------------------------
function TunerCity:GetSelectedCity()
  return self.selected.pCity
end

function TunerCity:SetSelectedCity(pCity :table)
  local cityLoc = Locale.Lookup( pCity:GetName() )
    .." (at "..pCity:GetX()..","..pCity:GetY()..")"
  print( "TunerCity:SetSelectedCity()  "..cityLoc )

  -- Unselect district if choosing a different city
  local pDistrict = self.selected.pDistrict
  if pDistrict and pDistrict:GetCity() ~= pCity then
    self.selected.pDistrict = nil
  end

  self.selected.pCity = pCity
end

function TunerCity:GetSelectedDistrict()
  return self.selected.pDistrict
end

function TunerCity:SetSelectedDistrict(pDistrict :table)
  local pCity = pDistrict:GetCity()
  local cityLoc = Locale.Lookup( pCity:GetName() )
    .." (at "..pCity:GetX()..","..pCity:GetY()..")"
  local districtIndex = pDistrict:GetType()
  local districtLoc = Locale.Lookup( GameInfo.Districts[districtIndex].Name )
    .." (at "..pDistrict:GetX()..","..pDistrict:GetY()..")"
  print( "TunerCity:SetSelectedDistrict()  "..districtLoc.." of city "..cityLoc )

  -- Selecting a district in another city is an error
  if self.selected.pCity ~= pCity then
    print( "  ERROR: must select district in selected city "..Locale.Lookup( pCity:GetName() ) )
    return
  end

  self.selected.pDistrict = pDistrict
  return pDistrict
end


function TunerCity:GetSelectedCityCenter()
  local pCity = self:GetSelectedCity()
  -- local pPlayer = Players[pCity:GetOwner()]
  -- return pPlayer:GetDistricts():FindID( pCity:GetDistrictID() )  -- pCity:GetDistrictID() is UI context only
  local pDistricts = pCity and pCity:GetDistricts()
  return pDistricts and pDistricts.GetDistrictAtLocation and pDistricts:GetDistrictAtLocation(pCity:GetX(), pCity:GetY())
end

function TunerCity:GetDistrictOfSelectedCity(districtType :string)
  local dbBuildingInfo = GameInfo.Districts[districtType];
  if not dbBuildingInfo then  return  end

  local pCity = self:GetSelectedCity()
  local pDistricts = pCity and pCity:GetDistricts();
  return pDistricts and pDistricts.GetDistrict and pDistricts:GetDistrict(dbBuildingInfo.Index);
end




-------------------------------------------------------------------------------
function TunerCity:ListCityBuildingsBuilt(items :table, showUnbuilt :boolean)  -- , formatFunc :function
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  items = items or {}
  local listID = self.ListIDdefault

  local d = {
    showUnbuilt = true,
    shortID = false,
    columnXY = true,
    columnHealth = true,
  }
  d.pBuildQueue = pCity:GetBuildQueue()
  d.pDistricts = pCity:GetDistricts()
  d.pBuildings = pCity:GetBuildings()

  self:ProcessCityDistricts(pCity, d)

  for i, pDistrict in ipairs(pCity.Districts) do
    local districtIndex = pDistrict:GetType()
    local dbBuildingInfo = GameInfo.Districts[districtIndex]
    local str = self:FormatDistrictOrBuilding(dbBuildingInfo, d, pDistrict)
    if str then
      table.insert(items, str)
      local sel = self.selected[listID]
      if sel and sel.DistrictType and pDistrict == self:GetSelectedDistrict() then
        items.selected = items.selected or #items
      end
      self:ListDistrictBuildings(items, d, pDistrict)
    end
  end
  local pDistrict = pCity.Districts.NoDistrict
  if pDistrict then
    table.insert(items, ";Buildings without district")
    self:ListDistrictBuildings(items, d, pDistrict)
  end
  print( "TunerCity:ListCityBuildingsBuilt()  items.selected=", items.selected )
  return items
end


function TunerCity:ListDistrictBuildings(items :table, d :table, pDistrict :table)
  for i, buildingType in ipairs(pDistrict.BuildingTypes) do
    local dbBuildingInfo = GameInfo.Buildings[buildingType]
    --  .·◦⮡
    local prefix = "⮡    "
    -- local prefix = "·    "
    local str = self:FormatDistrictOrBuilding(dbBuildingInfo, d, nil, prefix)
    if str then
      table.insert(items, str)
      local sel = self.selected[listID]
      if sel and sel.BuildingType == dbBuildingInfo.BuildingType then
        items.selected = items.selected or #items
      end
    end
  end
  return items
end




function TunerCity:ProcessCityDistricts(pCity :table, d :table)
  pCity.Districts = {}
  -- pCity.Districts.NoDistrict = nil
  -- pCity.DistrictsByPlotID = {}
  local numDistricts = d.pDistricts:GetNumDistricts()
  for i = 1, numDistricts, 1 do
    local pDistrict = d.pDistricts:GetDistrictByIndex(i-1)  -- indexing in C is 0-based vs in Lua 1-based
    local districtIndex = pDistrict:GetType()
    local dbBuildingInfo = GameInfo.Districts[districtIndex]

    pCity.Districts[i] = pDistrict
    pCity.Districts[dbBuildingInfo.DistrictType] = pDistrict
    local plotID = Map.GetPlotIndex( pDistrict:GetLocation() )
    -- pCity.DistrictsByPlotID[plotID] = pDistrict
    pDistrict.BuildingTypes = {}
  end
  self:ProcessCityBuildings(pCity, d)
end

-- TODO: keep?
function TunerCity:ProcessCityDistricts2(pCity :table, d :table)
  pCity.Districts = {}
  local numDistricts = d.pDistricts:GetNumDistricts()
  for dbBuildingInfo in GameInfo.Districts() do
    if d.pDistricts:HasDistrict(dbBuildingInfo.Index) then
      local prev = nil;
      -- numDistricts= limit iterations as a safeguard against infinite loop
      -- in case GetDistrict()'s 2nd parameter does not work as expected
      for i = 0, numDistricts, 1 do
        local pDistrict = d.pDistricts:GetDistrict(dbBuildingInfo.Index, i);
        if pDistrict == nil or pDistrict == prev then  break  end
        prev = pDistrict

        pCity.Districts[i] = pDistrict
        pCity.Districts[dbBuildingInfo.DistrictType] = pDistrict
        local plotID = Map.GetPlotIndex( pDistrict.GetLocation() )
        -- pCity.DistrictsByPlotID[plotID] = pDistrict
        pDistrict.BuildingTypes = {}
      end
    end
  end
  self:ProcessCityBuildings(pCity, d)
end


function TunerCity:ProcessCityBuildings(pCity :table, d :table)
  for dbBuildingInfo in GameInfo.Buildings() do
    local buildingIndex = dbBuildingInfo.Index
    local plotID = d.pBuildings:GetBuildingLocation(buildingIndex)
    local complete = d.pBuildings.HasBuilding and d.pBuildings:HasBuilding(buildingIndex)
    local placed = d.pBuildQueue.HasBuildingBeenPlaced and d.pBuildQueue:HasBuildingBeenPlaced(buildingIndex)
    -- local pDistrict = pCity.DistrictsByPlotID[plotID]
    local pDistrict = d.pDistricts:GetDistrictAtLocation(plotID)
      or dbBuildingInfo.IsWonder and pCity.Districts.DISTRICT_WONDER
      or pCity.Districts[dbBuildingInfo.PrereqDistrict]

    if complete or placed then
      if not pDistrict then
        pDistrict = pCity.Districts.NoDistrict or { BuildingTypes = {} }
        pCity.Districts.NoDistrict = pDistrict
      end

      local buildings = pDistrict.BuildingTypes
      table.insert(buildings, dbBuildingInfo.BuildingType)
    end
  end
end




function TunerCity:ListCityDistrictsOrBuildings(items :table, listID :string, showUnbuilt :boolean)  -- , formatFunc :function
  local pCity = self:GetSelectedCity()
  if not pCity then  return items  end

  items = items or {}
  local showDistricts = (listID == 'district')
  local showWonders = (listID == 'wonder')
  local d = {
    showUnbuilt = showUnbuilt,
    shortID = true,
  }
  d.pBuildQueue = pCity:GetBuildQueue()
  d.pDistricts = showDistricts and pCity:GetDistricts()
  d.pBuildings = not showDistricts and pCity:GetBuildings()
  local dbBuildings = showDistricts and GameInfo.Districts or GameInfo.Buildings

  for dbBuildingInfo in dbBuildings() do
    -- Add wonders only to wonder list, add rest to other lists
    local add = (not not dbBuildingInfo.IsWonder == showWonders) or (showWonders and dbBuildingInfo.DistrictType == "DISTRICT_WONDER")
    local str = add and self:FormatDistrictOrBuilding(dbBuildingInfo, d)
    if str then
      table.insert(items, str)
      if self.selected[listID] == dbBuildingInfo then  items.selected = items.selected or #items  end
    end
  end
  return items
end




function TunerCity:FormatDistrictOrBuilding(dbBuildingInfo :table, d :table, pDistrict :table, namePrefix :string)
  local buildingIndex = dbBuildingInfo.Index
  local ID = dbBuildingInfo.BuildingType or dbBuildingInfo.DistrictType
  local nameLoc = Locale.Lookup( dbBuildingInfo.Name )
  namePrefix = namePrefix or ""

  local complete, placed, pillaged
  local location
  if dbBuildingInfo.DistrictType then
    pDistrict = pDistrict or d.pDistricts:GetDistrict(buildingIndex)
    complete = pDistrict and pDistrict:IsComplete()
    placed = d.pBuildQueue.HasDistrictBeenPlaced and d.pBuildQueue:HasDistrictBeenPlaced(buildingIndex)
    if d.shortID then  ID = ID:gsub("^DISTRICT_", "")  end

    if pDistrict then
      ID = ID..","..string.format("0x%x", pDistrict:GetID())
      location = pDistrict:GetX()..","..pDistrict:GetY()
      pillaged = pDistrict:IsPillaged()
    end
  else
    complete = d.pBuildings.HasBuilding and d.pBuildings:HasBuilding(buildingIndex)
    placed = d.pBuildQueue.HasBuildingBeenPlaced and d.pBuildQueue:HasBuildingBeenPlaced(buildingIndex)
    pillaged = d.pBuildings:IsPillaged(buildingIndex)
    if d.shortID then  ID = ID:gsub("^BUILDING_", "")  end
    local plot = Map.GetPlotByIndex( d.pBuildings:GetBuildingLocation(buildingIndex) )
    location = plot and plot:GetX()..","..plot:GetY()
  end

  -- List unbuilt buildings?
  local built = complete or placed
  if not built and not d.showUnbuilt then  return  end

  local str = ID
    ..";"..buildingIndex
    ..";"..namePrefix..nameLoc

  if d.columnXY then
    str = str..";"..(location or "")
  end

  -- Building state  🗹🗹☐☑✅🗹
  local stateStr = not built and ""
    or pillaged and "✅ pillaged 🔥"
    or complete and "✅ complete"
    or "🗹 incomplete"
  str = str..";"..stateStr

  --[[
  -- local shouldBePlaced = not not dbBuildingInfo.DistrictType or dbBuildingInfo.IsWonder
  -- Health state
  if d.columnHealth then
      or d.pBuildings and d.pBuildings.IsPillaged and d.pBuildings:IsPillaged(buildingIndex)
    -- IsContaminated() is UI context only
    local contaminated = d.pDistricts and d.pDistricts.IsContaminated and d.pDistricts:IsContaminated(buildingIndex)
    local healthStr = pillaged and contaminated and "☢🔥 contaminated,pillaged"
      or pillaged and "🔥 pillaged"
      or contaminated and "☢"
      or ""
    local healthStr = pillaged and "🔥 pillaged" or ""
    str = str..";"..healthStr
  end
  --]]

  return str
end




-------------------------------------------------------------------------------
function TunerCity:ListCityBuildingsPillage(items :table)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local items = {};
  local pBuildings = pCity:GetBuildings();
  local i = 1;
  for buildingInfo in GameInfo.Buildings() do
    local item = {};
    --local nameLoc = Locale.Lookup( buildingInfo.Name );
    -- Remove prefix from BuildingType
    local ID = buildingInfo.BuildingType:gsub("^BUILDING_", "");
    if pBuildings:HasBuilding(buildingInfo.Index) then
      item.Text = ID;
      --item.Text = ID..";;;;"..buildingInfo.BuildingType;
      item.Selected =  pBuildings:IsPillaged(buildingInfo.Index)
      items[i] = item;
      i = i + 1;
    end
  end

  return items;
end


function TunerCity:TogglePillaged()
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end
  local dbBuildingInfo = self:GetSelectedBuilding()
  -- if not dbBuildingInfo then  return  end

  if dbBuildingInfo.DistrictType then
    local pDistrict = self:GetSelectedDistrict()
    if not pDistrict then  return  end
    pDistrict:SetPillaged( not pDistrict:IsPillaged() )
  else
    local pBuildings = pCity:GetBuildings()
    local buildingIndex = dbBuildingInfo.Index
    pBuildings:SetPillaged(buildingIndex, not pBuildings:IsPillaged(buildingIndex) )
  end

  TunerCity.skipSelect = true
  print( "TunerCity:TogglePillaged()  DONE" )
end




-------------------------------------------------------------------------------
function TunerCity:SetPlacementMode(listID :string, start :boolean)
  if start then
    return self:StartPlacementMode(listID)
  else
    return self:CancelPlacementMode()
  end
end

function TunerCity:StartPlacementMode(listID :string)
  --if self:InPlacementMode() then  return  end
  local dbBuildingInfo = self.selected[listID]
  if not dbBuildingInfo then  return  end

  -- Enter building placement mode
  self.options.placementMode = listID

  if not dbBuildingInfo.RequiresPlacement then
    -- Create it in its district, no need for placement
    self:FinishPlacement()
  end
end

function TunerCity:FinishPlacement(plot)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local dbBuildingInfo = self:GetPlacementModeBuilding()
  if not dbBuildingInfo then  return  end

  local buildingIndex = dbBuildingInfo.Index
  local percent = self.options.BuildPercent
  local pBuildQueue = pCity:GetBuildQueue();

  if dbBuildingInfo.DistrictType then
    pBuildQueue:CreateIncompleteDistrict(buildingIndex, plot:GetIndex(), percent);
  elseif plot then
    pBuildQueue:CreateIncompleteBuilding(buildingIndex, plot:GetIndex(), percent);
  else
    pBuildQueue:CreateIncompleteBuilding(buildingIndex, percent);
  end

  -- Exit building placement mode
  self:CancelPlacementMode()
  return true
end


function TunerCity:CancelPlacementMode()
  self.options.placementMode = nil
end


function TunerCity:InPlacementMode(listID :string)
  if listID then  return listID == self.options.placementMode  end
  return self.options.placementMode ~= nil
end


function TunerCity:GetPlacementModeBuilding()
  return self:GetSelectedBuilding(self.options.placementMode)
end



function TunerCity:RemoveBuilding(listID :string)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local dbBuildingInfo = self:GetSelectedBuilding(listID)
  if not dbBuildingInfo then  return  end

  local buildingIndex = dbBuildingInfo.Index
  if dbBuildingInfo.DistrictType then
    pCity:GetDistricts():RemoveDistrict(buildingIndex);
    pCity:GetBuildQueue():RemoveDistrict(buildingIndex);
  else
    pCity:GetBuildings():RemoveBuilding(buildingIndex);
    pCity:GetBuildQueue():RemoveBuilding(buildingIndex);
  end
end


function TunerCity:RemoveDistrict()
  local pDistrict = self:GetSelectedDistrict()
  if pDistrict then  return CityManager.DestroyDistrict(pDistrict)  end
  return TunerCity:RemoveBuilding('district')
end




-------------------------------------------------------------------------------
function TunerCity:GetCityBuildProgress(pCity)
  --local pCity = GetSelectedCity();
  if not pCity then  return "<select city>"  end
  local pBuildQueue = pCity:GetBuildQueue();
  local current = 0 -- pBuildQueue:GetAt(0);
  local prodType = 0 -- pBuildQueue:GetCurrentProductionTypeHash();
  if  prodType == 0  then  return "<not building>"  end
--[[
  local d1 = current.BuildingType;
  local d2 = current.DistrictType;
  local d3 = current.UnitType;
  local d4 = current.ProjectType;
--]]
--[
  local d1 = GameInfo.Buildings[prodType];
  local d2 = GameInfo.Districts[prodType];
  local d3 = GameInfo.Units[prodType];
  local d4 = GameInfo.Projects[prodType];
--]]

  local progress =
    d1 and pBuildQueue:GetBuildingProgress(d1) / pBuildQueue:GetBuildingCost(d1) or
    d2 and pBuildQueue:GetDistrictProgress(d2) / pBuildQueue:GetDistrictCost(d2) or
    d3 and pBuildQueue:GetUnitProgress(d3)     / pBuildQueue:GetUnitCost(d3)     or
    d4 and pBuildQueue:GetProjectProgress(d4)  / pBuildQueue:GetProjectCost(d4)

  return progress or "<unknown type>";
end




-------------------------------------------------------------------------------
function TunerCity:GetCurrentlyBuildingLoc(pCity :table)
  local prodType = self:GetCurrentlyBuilding(pCity)
  local dbBuildingInfo = GameInfo.Buildings[prodType]
    or GameInfo.Districts[prodType]
    or GameInfo.Units[prodType]
    or GameInfo.Projects[prodType]
  return dbBuildingInfo and Locale.Lookup( dbBuildingInfo.Name ) or prodType
end

function TunerCity:GetCurrentlyBuilding(pCity :table)
  pCity = pCity or self:GetSelectedCity()
  if not pCity then  return ""  end

  local pBuildQueue = pCity:GetBuildQueue()
  if pBuildQueue.CurrentlyBuilding then  return pBuildQueue:CurrentlyBuilding()  end
  return "<not accessible>"
end




-------------------------------------------------------------------------------
function TunerCity:GetBuildPercent()
  return self.options.BuildPercent
end

function TunerCity:SetBuildPercent(BuildPercent)
  self.options.BuildPercent = minmax(BuildPercent, 0, 100)
end




-------------------------------------------------------------------------------
function TunerCity:ListCityStat()
  local items = {}
  items[0] = "-0;Population;"
  items[1] = "-1;Housing;"
  items[2] = "-2;Food Surplus;"
  -- items[3] = "-3;Gold Yield Modifier;"
  -- items[4] = "-4;Remaining Attacks;"

  local pCity = self:GetSelectedCity()
  if not pCity then  return items  end

  items[0] = items[0]..pCity:GetPopulation()
  items[1] = items[1]..pCity:GetGrowth():GetHousing()
  items[2] = items[2]..pCity:GetGrowth():GetFoodSurplus()
  -- items[3] = items[3]..pCity:GetGoldYieldModifier()
  -- items[4] = items[4]..pCity:GetRemainingAttacks()
  return items;
end




-------------------------------------------------------------------------------
function TunerCity:ListCityProperty()
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local props = pCity:GetProperties();
  local items = {};
  for k,v in pairs(props) do
    local line = k..";"..tostring(v);
    table.insert(items, line);
    if ( k == TunerCity.options.PropertyKey ) then
      items.selected = #items;
    end
  end

  return items;
end




-------------------------------------------------------------------------------
function TunerCity:ListRevealedToCiv()
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local items = {};
  if pCity ~= nil then
    for i = 0, GameDefines.MAX_PLAYERS-1, 1 do
      local pPlayer = Players[i];
      if pPlayer:WasEverAlive() and PlayersVisibility[i]:IsRevealed(pCity:GetX(), pCity:GetY()) then
        local pPlayerConfig = PlayerConfigurations[i];
        local properCivName = Locale.Lookup( pPlayerConfig:GetCivilizationShortDescription() );
        local str = properCivName..";"..pPlayerConfig:GetNickName();
        table.insert( items, str );
      end
    end
  end

  return items;
end




-------------------------------------------------------------------------------
function TunerCity:ListSpoofToCiv()
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local ownerIdx = pCity:GetOwner();
  local ownerCivName = PlayerConfigurations[ownerIdx]:GetCivilizationShortDescription();
  local items = {}
  -- local numPlayers = PlayerManager.GetWasEverAliveCount()
  -- for playerID = 0, numPlayers-1, 1 do
  --for civ, i in GameInfo.Civilizations() do
  for i = 0, GameDefines.MAX_PLAYERS-1, 1 do
      -- if true then return end
    local pPlayer = Players[i];
    if pPlayer:WasEverAlive() then
      local spoofCivName = PlayerConfigurations[i]:GetCivilizationShortDescription()
      local str = Locale.Lookup( spoofCivName )
      table.insert( items, str );
      if spoofCivName == ownerCivName then
        items.selected = #items;
      end
    end
  end

  return items;
end


function TunerCity:SelectSpoofToCiv(selSpoofToCiv)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  for i = 0, GameDefines.MAX_PLAYERS-1, 1 do
    local pPlayer = Players[i];
    local spoofCivName = pPlayer:WasEverAlive() and PlayerConfigurations[i]:GetCivilizationShortDescription()
    if spoofCivName and Locale.Lookup( spoofCivName ) == selSpoofToCiv then
      local x, y = pCity:GetX(), pCity:GetY()
      print('----');
      print('ContextPtr' , ContextPtr);
      local str = x..','..y..' '
        ..Locale.Lookup( pCity:GetName() )
        ..' -> '..i..' '..selSpoofToCiv
      print( 'LuaEvents.SetCityCiv("'..selSpoofToCiv..'"):  x,y,city,playerID,player= '..str )
      LuaEvents.SetCityCiv(x, y, i)
      print('----');
      break;
    end
  end
end




-------------------------------------------------------------------------------
function TunerCity.OnPrintCityInfo(pCity)
  --pCity = pCity or Cities.GetCityInPlot(40,27)  -- Rouen       Temple of Artemis
  --pCity = pCity or Cities.GetCityInPlot(63,43)  -- Noviodunum  Jebel Barkal
  --pCity = pCity or Cities.GetCityInPlot(66,46)  -- Ratumacos   Oracle
  print('-- event OnPrintCityInfo(pCity)', pCity:GetName());
  print('ContextPtr[event]' , ContextPtr);
  --[[
  local x, y = pCity:GetX(), pCity:GetY();
  print( 'Cities.GetCityInPlot('..x..','..y..')' , Cities.GetCityInPlot(x, y) )
  --]]

  print( 'pCity[event]' , pCity )
  print( ':GetYield()', pCity:GetYield() )
  print( '.GetBuildQueue[event]' , pCity.GetBuildQueue )

  local pBuildQueue = pCity:GetBuildQueue()
  print( ':GetBuildQueue()' , pBuildQueue )
  print( ':CurrentlyBuilding()'  , TunerCity:GetCurrentlyBuildingLoc(pCity) )
  print( '.GetTurnsLeft'         , pBuildQueue.GetTurnsLeft )
  print( '.GetProductionYield'   , pBuildQueue.GetProductionYield )
  --print( ':GetTurnsLeft()'       , pBuildQueue:GetTurnsLeft() )
  --print( ':GetProductionYield()' , pBuildQueue:GetProductionYield() )
  print( '.GetCurrentProductionTypeHash' , pBuildQueue.GetCurrentProductionTypeHash )
  if  pBuildQueue.GetCurrentProductionTypeHash  then
    --[[
    local hash = pBuildQueue:GetCurrentProductionTypeHash()
    print( ':ProductionTypeHash()' , hash )
    print( ':GetBuildingProgress(hash)', pBuildQueue:GetBuildingProgress(GameInfo.Buildings[hash]) )
    print( ':GetDistrictProgress(hash)', pBuildQueue:GetDistrictProgress(GameInfo.Districts[hash]) )
    --]]
  end
  print('-- /event OnPrintCityInfo');
end



-------------------------------------------------------------------------------
function TunerCity:MapClickHandler(plot)
  if self:InPlacementMode() then
    return self:FinishPlacement(plot)
  end

  local pDistrict = CityManager.GetDistrictAt(plot)
  local pCity = pDistrict and pDistrict:GetCity()
  -- CityManager.GetCityAt , Cities.GetCityInPlot , Cities.GetPlotPurchaseCity , Cities.GetPlotWorkingCity
  -- pCity = pCity or CityManager.GetCityAt(plot)
  -- pCity = pCity or Cities.GetCityInPlot(plot)
  -- pCity = pCity or Cities.GetPlotPurchaseCity(plot)
  pCity = pCity or Cities.GetPlotWorkingCity(plot)

  local cityLoc = pCity and Locale.Lookup( pCity:GetName() )
    .." (at "..pCity:GetX()..","..pCity:GetY()..")"
  local districtIndex = pDistrict:GetType()
  local districtLoc = pDistrict and Locale.Lookup( GameInfo.Districts[districtIndex].Name )
  local msg = "TunerCity:MapClickHandler()  x,y= "..plot:GetX()..","..plot:GetY().."  "
  if pDistrict then  print( msg..districtLoc.." of city "..cityLoc )
  elseif pCity then  print( msg.."plot of city "..cityLoc )
  else  print( msg.."plot not owned by any city" )
  end

  if pCity then  self:SetSelectedCity(pCity)  end
  if pDistrict then  self:SetSelectedDistrict(pDistrict)  end
  return pCity ~= nil
end


function TunerCity.OnLButtonUp(X,Y)
  return TunerCity:MapClickHandler( Map.GetPlot(X,Y) )
end


function TunerCity.OnCitySelectionChanged(playerID :number, cityID :number, x :number, y :number, k :number, isSelected :boolean, isEditable :boolean)
  if not isSelected then  return  end
  local pCity = CityManager.GetCity(playerID, cityID)
  local cityLoc = pCity and Locale.Lookup( pCity:GetName() )
  print( "TunerCity.OnCitySelectionChanged()  x,y= "..x..","..y.."  "..cityLoc )
  TunerCity:SetSelectedCity(pCity)
end




-------------------------------------------------------------------------------
function TunerCity:Initialize()
  -- TODO: remove before hot reload
  LuaEvents.UIDebugModeEntered.Add( TunerCity.OnUIDebugModeEntered );
  LuaEvents.UIDebugModeExited.Add( TunerCity.OnUIDebugModeExited );
  LuaEvents.TunerMapLButtonUp.RemoveAll()
  LuaEvents.TunerMapLButtonUp.Add( TunerCity.OnLButtonUp )
  Events.CitySelectionChanged.Add( TunerCity.OnCitySelectionChanged )
  --LuaEvents.TunerMapRButtonUp.Add( TunerCity.OnRButtonUp );
  LuaEvents.PrintCityInfo.RemoveAll();
  LuaEvents.PrintCityInfo.Add( TunerCity.OnPrintCityInfo );
end

-- Called by City.ltp ExitAction or EnterAction
function TunerCity:Shutdown()
  LuaEvents.UIDebugModeEntered.Remove( TunerCity.OnUIDebugModeEntered );
  LuaEvents.UIDebugModeExited.Remove( TunerCity.OnUIDebugModeExited );
  LuaEvents.TunerMapLButtonUp.Remove( TunerCity.OnLButtonUp )
  Events.CitySelectionChanged.Remove( TunerCity.OnCitySelectionChanged )
  --LuaEvents.TunerMapRButtonUp.Remove( TunerCity.OnRButtonUp );
  LuaEvents.PrintCityInfo.Remove( TunerCity.OnPrintCityInfo )
end


TunerCity:Initialize()

