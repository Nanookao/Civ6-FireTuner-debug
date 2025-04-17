print( "loading TunerCityPanel.lua" )
--return

TunerCity = TunerCity or {}
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
function print_table(obj)
	if  type(obj) ~= 'table'  then  print('type ' .. type(obj) .. ':  ' .. tostring(obj));  return  end
	print('Properties of:  ' .. tostring(obj));
	for k, v in pairs(obj) do
		print('  '..k..'= '..tostring(v))
	end
end
p=print_table


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
      print("TunerCity:ListPlayerCities()  found selected city #"..items.selected.." "..cityLoc )
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



TunerCity.typePrefix = {
  district = "DISTRICT_",
  building = "BUILDING_",
  wonder   = "BUILDING_",
}

function TunerCity:SelectBuilding(selBuilding: string, category :string)
  local prefix = self.typePrefix[category] or ""
  -- Restore the full buildingType
  local buildingType = prefix..selBuilding:match("^[^,]*")
  local districtID = selBuilding:match(",[^,]*")
  local isDistrict = (category == 'district') or (prefix == "" and selBuilding:match("^DISTRICT_"))

  local dbBuildings = isDistrict and GameInfo.Districts or GameInfo.Buildings
  local dbBuildingInfo = dbBuildings[buildingType]
  self.selected[category] = dbBuildingInfo

  if not isDistrict then
    self:SelectDistrictOfBuilding(dbBuildingInfo)
  elseif districtID then
    self:SelectDistrictByID(districtID)
  end

  return dbBuildingInfo
end


function TunerCity:SelectDistrictOfBuilding(dbBuildingInfo :table)
  if not dbBuildingInfo then  return  end
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local pDistricts = pCity and pCity:GetDistricts()
  local pDistrict = pDistricts and pDistricts.GetDistrictByID and pDistricts:GetDistrictByID(districtID)
end


function TunerCity:SelectDistrictByID(districtID :string)
  local pDistrict = pDistricts and pDistricts.GetDistrictByID and pDistricts:GetDistrictByID(districtID)
  if pDistrict then
    self:SetSelectedDistrict(pDistrict)
    -- TODO: fix
    -- UI.LookAtPlot( pDistrict:GetX(), pDistrict:GetY() )
  end
  return pDistrict
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
  local districtLoc = Locale.Lookup( GameInfo.Districts[pDistrict:GetType()].Name )
    .." (at "..pDistrict:GetX()..","..pDistrict:GetY()..")"
  print( "TunerCity:SetSelectedDistrict()  "..districtLoc.." of city "..cityLoc )

  -- Selecting a district in another city is an error
  if self.selected.pCity ~= pCity then
    print( "  ERROR: must select district in selected city "..Locale.Lookup( pCity:GetName() ) )
    return
  end

  self.selected.pDistrict = pDistrict
end


function TunerCity:GetSelectedCityCenter()
  local pCity = self:GetSelectedCity()
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
function TunerCity:ListCityBuildingsGrouped(items :table, showUnbuilt :boolean)  -- , formatFunc :function
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  items = items or {}
  local category = 'grouped'

  local d = {
    showUnbuilt = showUnbuilt,
    shortID = false,
    columnXY = true,
    columnHealth = true,
  }
  d.pBuildQueue = pCity:GetBuildQueue()
  d.pDistricts = pCity:GetDistricts()
  d.pBuildings = pCity:GetBuildings()

  local numDistricts = d.pDistricts:GetNumDistricts();
  for i = 0, numDistricts-1, 1 do
    local pDistrict = d.pDistricts:GetDistrictByIndex(i)
    local dbBuildingInfo = GameInfo.Districts[pDistrict:GetType()]

    local str = self:FormatDistrictOrBuilding(dbBuildingInfo, d, pDistrict)
    if str then
      table.insert(items, str)
      if self.selected[category] == dbBuildingInfo then  items.selected = items.selected or #items  end
      self:ListDistrictBuildings(items, d, pDistrict)
    end
  end
  return items
end


function TunerCity:ListCityBuildingsGrouped1(items :table, showUnbuilt :boolean)  -- , formatFunc :function
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  items = items or {}
  local category = 'grouped'
  local pDistricts = pCity:GetDistricts();
  local numDistricts = pDistricts:GetNumDistricts();

  local d = {
    showUnbuilt = showUnbuilt,
    shortID = false,
    columnXY = true,
    columnHealth = true,
  }
  d.pBuildQueue = pCity:GetBuildQueue()
  d.pDistricts = pCity:GetDistricts()
  d.pBuildings = pCity:GetBuildings()

  for dbBuildingInfo in GameInfo.Districts() do
    if d.pDistricts:HasDistrict(dbBuildingInfo.Index) then
      local prev = nil;
      -- numDistricts= limit iterations as a safeguard against infinite loop
      -- in case GetDistrict()'s 2nd parameter does not work as expected
      for i = 0, numDistricts, 1 do
        local pDistrict = d.pDistricts:GetDistrict(dbBuildingInfo.Index, i);
        if pDistrict == nil or pDistrict == prev then  break  end
        prev = pDistrict

        local str = self:FormatDistrictOrBuilding(dbBuildingInfo, d, pDistrict)
        if str then
          table.insert(items, str)
          if self.selected[category] == dbBuildingInfo then  items.selected = items.selected or #items  end
          self:ListDistrictBuildings(items, d, pDistrict)
        end
      end
    end
  end
  return items
end




function TunerCity:ListDistrictBuildings(items :table, d :table, pDistrict :table)
end




function TunerCity:ListCityDistrictsOrBuildings(items :table, category :string, showUnbuilt :boolean)  -- , formatFunc :function
  local pCity = self:GetSelectedCity()
  if not pCity then  return items  end

  items = items or {}
  local showDistricts = (category == 'district')
  local showWonders = (category == 'wonder')
  local d = {
    showUnbuilt = showUnbuilt,
    shortID = true,
  }
  d.pBuildQueue = pCity:GetBuildQueue()
  d.pDistricts = showDistricts and pCity:GetDistricts()
  d.pBuildings = not showDistricts and pCity:GetBuildings()
  local dbBuildings = showDistricts and GameInfo.Districts or GameInfo.Buildings

  for dbBuildingInfo in dbBuildings() do
    -- Add wonders only to wonder category, add rest to other category
    local add = (dbBuildingInfo.IsWonder == showWonders) or (showWonders and dbBuildingInfo.DistrictType == "DISTRICT_WONDER")
    local str = add and self:FormatDistrictOrBuilding(dbBuildingInfo, d)
    if str then
      table.insert(items, str)
      if self.selected[category] == dbBuildingInfo then  items.selected = items.selected or #items  end
    end
  end
  return items
end




function TunerCity:FormatDistrictOrBuilding(dbBuildingInfo :table, d :table, pDistrict :table)
  local buildingID = dbBuildingInfo.Index
  local ID = dbBuildingInfo.BuildingType or dbBuildingInfo.DistrictType
  local nameLoc = Locale.Lookup( dbBuildingInfo.Name )

  local complete, placed
  local location
  if dbBuildingInfo.DistrictType then
    complete = d.pDistricts.HasDistrict and d.pDistricts:HasDistrict(buildingID)
    placed = d.pBuildQueue.HasDistrictBeenPlaced and d.pBuildQueue:HasDistrictBeenPlaced(buildingID)
    if d.shortID then  ID = ID:gsub("^DISTRICT_", "")  end

    pDistrict = pDistrict or d.pDistricts:GetDistrict(buildingID)
    if pDistrict then
      ID = ID..","..string.format("0x%x", pDistrict:GetID())
      local x,y = pDistrict:GetLocation()
      location = x..","..y
    end
  else
    complete = d.pBuildings.HasBuilding and d.pBuildings:HasBuilding(buildingID)
    placed = d.pBuildQueue.HasBuildingBeenPlaced and d.pBuildQueue:HasBuildingBeenPlaced(buildingID)
    if d.shortID then  ID = ID:gsub("^BUILDING_", "")  end
    local plot = Map.GetPlotByIndex( d.pBuildings:GetBuildingLocation(buildingID) )
    location = plot and plot:GetX()..","..plot:GetY()
  end

  -- List unbuilt buildings?
  if not complete and not placed and not d.showUnbuilt then  return  end

  local str = ID
    ..";"..nameLoc

  if d.columnXY then
    str = str..";"..(location or "")
  end

  -- Build state
  -- 🗹🗹☐☑✅🗹
  -- local shouldBePlaced = not not dbBuildingInfo.DistrictType or dbBuildingInfo.IsWonder
  local stateStr = complete and "✅ complete"
    or placed and "🗹 incomplete"
    or "☐"
  str = str..";"..stateStr

  -- Health state
  if d.columnHealth then
    local pillaged = pDistrict and pDistrict:IsPillaged()
      or d.pBuildings and d.pBuildings.IsPillaged and d.pBuildings:IsPillaged(buildingID)
    --[[
    -- UI context needed for IsContaminated():
    local contaminated = d.pDistricts and d.pDistricts.IsContaminated and d.pDistricts:IsContaminated(buildingID)
    local healthStr = pillaged and contaminated and "☢🔥 contaminated,pillaged"
      or pillaged and "🔥 pillaged"
      or contaminated and "☢"
      or ""
    --]]
    local healthStr = pillaged and "🔥 pillaged" or ""
    str = str..";"..healthStr
  end

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


function TunerCity:SetBuildingPillaged(selBuilding :string, isPillaged :boolean)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  -- Restore the display name back to the buildingType
  local buildingType = "BUILDING_"..selBuilding
  local dbBuildingInfo = GameInfo.Buildings[buildingType];
  if dbBuildingInfo then
    pCity:GetBuildings():SetPillaged(dbBuildingInfo.Index, isPillaged);
  end
end




-------------------------------------------------------------------------------
function TunerCity:SetPlacementMode(category :string, start :boolean)
  if start then
    return self:StartPlacementMode(category)
  else
    return self:CancelPlacementMode()
  end
end

function TunerCity:StartPlacementMode(category :string)
  --if self:InPlacementMode() then  return  end
  local dbBuildingInfo = self.selected[category]
  if not dbBuildingInfo then  return  end

  -- Enter building placement mode
  self.options.placementMode = category

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

  local buildingID = dbBuildingInfo.Index
  local percent = self.options.BuildPercent
  local pBuildQueue = pCity:GetBuildQueue();

  if dbBuildingInfo.DistrictType then
    pBuildQueue:CreateIncompleteDistrict(buildingID, plot:GetIndex(), percent);
  elseif plot then
    pBuildQueue:CreateIncompleteBuilding(buildingID, plot:GetIndex(), percent);
  else
    pBuildQueue:CreateIncompleteBuilding(buildingID, percent);
  end

  -- Exit building placement mode
  self:CancelPlacementMode()
  return true
end


function TunerCity:CancelPlacementMode()
  self.options.placementMode = nil
end


function TunerCity:InPlacementMode(category :string)
  if category then  return category == self.options.placementMode  end
  return self.options.placementMode ~= nil
end


function TunerCity:GetPlacementModeBuilding()
  return self.selected[ self.options.placementMode ]
end



function TunerCity:RemoveBuilding(category :string)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local dbBuildingInfo = self.selected[category or 'building']
  if not dbBuildingInfo then  return  end

  local buildingID = dbBuildingInfo.Index
  if category == 'district' then
    pCity:GetDistricts():RemoveDistrict(buildingID);
    pCity:GetBuildQueue():RemoveDistrict(buildingID);
  else
    pCity:GetBuildings():RemoveBuilding(buildingID);
    pCity:GetBuildQueue():RemoveBuilding(buildingID);
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
  local districtLoc = pDistrict and Locale.Lookup( GameInfo.Districts[pDistrict:GetType()].Name )
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

-- Called by City.ltp <ExitAction>
function TunerCity:Shutdown()
  LuaEvents.UIDebugModeEntered.Remove( TunerCity.OnUIDebugModeEntered );
  LuaEvents.UIDebugModeExited.Remove( TunerCity.OnUIDebugModeExited );
  LuaEvents.TunerMapLButtonUp.Remove( TunerCity.OnLButtonUp )
  Events.CitySelectionChanged.Remove( TunerCity.OnCitySelectionChanged )
  --LuaEvents.TunerMapRButtonUp.Remove( TunerCity.OnRButtonUp );
  LuaEvents.PrintCityInfo.Remove( TunerCity.OnPrintCityInfo )
end


TunerCity:Initialize()

