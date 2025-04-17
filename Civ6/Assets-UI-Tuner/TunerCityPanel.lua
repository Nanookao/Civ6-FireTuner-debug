print( "loading TunerCityPanel.lua" );
--return

TunerCity = TunerCity or {}
g_PanelHasFocus = false;

-------------------------------------------------------------------------------
TunerCity.selected = TunerCity.selected or {}
TunerCity.options  = TunerCity.options  or {}

g_PlacementSettings =
{
  Active = false,
  Player = nil,
  CityID = nil,
  DistrictID = nil,
  PlacementHandler = nil,

  EditKey = "",
  EditVal = ""
}

-------------------------------------------------------------------------------
function minmax(value, minimum, maximum)
  if value < minimum then  return minimum  end
  if value > maximum then  return maximum  end
  return value
end

function TunerCity:GetBuildPercent()
  return self.options.buildPercent
end

function TunerCity:SetBuildPercent(buildPercent)
  self.options.buildPercent = minmax(buildPercent, 0, 100)
end



-------------------------------------------------------------------------------
function TunerCity:ListCities(items :table)
  items = items or {}
  for playerID = 0, GameDefines.MAX_PLAYERS-1, 1 do
    local pPlayer = Players[playerID]
    if pPlayer:WasEverAlive() then
      self:ListPlayerCities(pPlayer, items)
    end
  end
  return items
end

function TunerCity:ListPlayerCities(pPlayer :table, items :table)
  items = items or {}
  if not pPlayer then  return items  end

  local playerID = pPlayer:GetID()
  local pPlayerConfig = PlayerConfigurations[playerID]
  local playerLoc = Locale.Lookup( pPlayerConfig:GetCivilizationShortDescription() )
  if playerLoc == "" then  playerLoc = "Player " .. tostring(playerID)  end

  local pCities = pPlayer:GetCities();
  for ii, pCity in pCities:Members() do
    local str = self:FormatCity(pCity)
    table.insert(items, str)

    if playerID == self.selected.PlayerID and pCity:GetID() == self.selected.CityID then
      items.selected = #items;
    end
  end
  return items
end

function TunerCity:FormatCity(pCity :table)
  local playerID = pCity:GetOwner():GetID;

  local origOwner = pCity:GetOriginalOwner();
  local origOwnerLoc = "none";
  if origOwner ~= -1 then
    local origOwnerStr = PlayerConfigurations[origOwner]:GetCivilizationShortDescription();
    origOwnerLoc = Locale.Lookup( origOwnerStr )
    --origOwnerLoc = origOwnerStr:gsub("LOC_CIVILIZATION_", "");
    if origOwnerLoc == "" then  origOwnerLoc = "Player " .. tostring(origOwner)  end
  end

  --local cityName = pCity:GetName():gsub("LOC_CITY_NAME_", "")
  local cityNameLoc = Locale.Lookup( pCity:GetName() )

  local pBuildQueue = pCity:GetBuildQueue()
  local buildingLoc = Locale.Lookup( GetBQCurrentlyBuilding(pBuildQueue) )
  --local progress = GetCityBuildProgress(pCity)

  local str = playerID .. "," .. pCity:GetID()
  .. ";" .. origOwnerLoc
  .. ";" .. playerLoc
  .. ";" .. cityNameLoc
  .. ";" .. pCity:GetX() .. "," .. pCity:GetY()
  .. ";" .. buildingLoc
  return str;
end


function TunerCity:SelectCity(selBuilding: string)
  -- Extract the db key from the line
  local name = string.match(selBuilding, '^[^;]+')
  -- Restore the full BuildingType
  self.selected.BuildingType = name and ("BUILDING_" .. name)
end




-------------------------------------------------------------------------------
function TunerCity:ListCityDistrictsOrBuildings(pCity :table, items :table, category :string)  -- , formatFunc :function
  items = items or {}
  if not pCity then  return items  end

  local dbBuildings = category == 'district' and GameInfo.Districts() or GameInfo.Buildings()
  local pBuildings = category == 'district' and pCity:GetDistricts() or pCity:GetBuildings()
  local addWonders == category == 'wonder'
  local pBuildQueue = pCity:GetBuildQueue();
  for dbBuildingInfo in dbBuildings do
    -- Add wonders only to wonder category, add rest to other category
    local add = (dbBuildingInfo.IsWonder == addWonders)
    local str = add and self:FormatDistrictOrBuilding(pBuildings, pBuildQueue, dbBuildingInfo, options)
    if str then
      local item = { Text = str }
      if self.selected.BuildingType == dbBuildingInfo.BuildingType then  item.Selected = true  end
      table.insert(items, item)
    end
  end
  return items
end

function TunerCity:FormatDistrictOrBuilding(pBuildings :table, pBuildQueue :table, dbBuildingInfo :table, options :table)
  local buildingID = dbBuildingInfo.Index
  local built, placed, name

  if dbBuildingInfo.DistrictType then
    built = pBuildings.HasDistrict and pBuildings:HasDistrict(buildingID)
    placed = pBuildQueue.HasDistrictBeenPlaced and pBuildQueue:HasDistrictBeenPlaced(buildingID)
    name = dbBuildingInfo.BuildingType:gsub("DISTRICT_", "")
  else
    built = pBuildings.HasBuilding and pBuildings:HasBuilding(buildingID)
    placed = pBuildQueue.HasBuildingBeenPlaced and pBuildQueue:HasBuildingBeenPlaced(buildingID)
    name = dbBuildingInfo.BuildingType:gsub("BUILDING_", "")
  end

  -- List unbuilt buildings?
  if not built and not options.unbuilt then  return  end

  local nameLoc = Locale.Lookup( dbBuildingInfo.Name )
  local str = name
    .. ";" .. nameLoc

  local pillaged = pBuildings.IsPillaged and pBuildings:IsPillaged(buildingID)

  if options.unbuilt then
    -- List also unbuilt buildings: add a column for build state
    stateStr = built and "✅ built"  -- 🗹🗹☐☑✅🗹
      or placed and "🗹 construction"  -- ☑
      or dbBuildingInfo.RequiresPlacement and "☐ requires placement" or "☐"
    str = str .. ";" .. stateStr
  end

  str = str .. ";" .. (pillaged and "🔥 pillaged" or "")
  str = str .. ";" .. tostring(buildingID)
  return str
end



function TunerCity:SelectDistrict(selBuilding: string)
  -- Extract the db key from the line
  local name = string.match(selBuilding, '^[^;]+')
  if not name then  return  end
  -- Restore the full BuildingType
  self.selected.dbDistrictInfo = GameInfo.Districts[ 'DISTRICT_' .. name ]
end

function TunerCity:SelectBuilding(selBuilding: string)
  -- Extract the db key from the line
  local name = string.match(selBuilding, '^[^;]+')
  if not name then  return  end
  -- Restore the full BuildingType
  self.selected.dbBuildingInfo = GameInfo.Buildings[ 'BUILDING_' .. name ]
end



function TunerCity:BuildBuilding(category :string)
  local dbBuildingInfo = self.selected[category]
  if not dbBuildingInfo then  return  end

  self.selected.build = dbBuildingInfo
  if dbBuildingInfo.RequiresPlacement then
    -- Enter building placement mode.
    self.PlacementHandler = self.PlaceBuilding
    LuaEvents.TunerEnterDebugMode();
  else
    -- Just create it, it will go in its district.
    self:PlaceBuilding()
  end
end

function TunerCity:PlaceBuilding(plot)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local dbBuildingInfo = self.selected.build
  if not dbBuildingInfo then  return  end

  local buildingID = dbBuildingInfo.Index
  local percent = self.options.buildPercent
  local pBuildQueue = pCity:GetBuildQueue();

  if dbBuildingInfo.DistrictType then
    pBuildQueue:CreateIncompleteDistrict(buildingID, plot:GetIndex(), percent);
  elseif plot then
    pBuildQueue:CreateIncompleteBuilding(buildingID, plot:GetIndex(), percent);
  else
    pBuildQueue:CreateIncompleteBuilding(buildingID, percent);
  end
end



function TunerCity:RemoveBuilding(category :string)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local dbBuildingInfo = self.selected[category]
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




-------------------------------------------------------------------------------
function GetSelectedPlayer()
  return g_PlacementSettings.Player and Players[g_PlacementSettings.Player];
end

function GetSelectedCity()
  if not g_PlacementSettings.CityID then  return  end
  local pPlayer = GetSelectedPlayer();
  local cities = pPlayer and pPlayer:GetCities();
  return cities and cities:FindID(g_PlacementSettings.CityID);
end

function GetSelectedCityCenter()
  local pCity = GetSelectedCity();
  local pCityDistricts = pCity and pCity:GetDistricts();
  return pCityDistricts and pCityDistricts.GetDistrictAtLocation and pCityDistricts:GetDistrictAtLocation(pCity:GetX(), pCity:GetY());
end

function GetDistrictOfSelectedCity(districtType :string)
  local districtEntry = GameInfo.Districts[districtType];
  if not districtEntry then  return  end
  local pCity = GetSelectedCity();
  local pCityDistricts = pCity and pCity:GetDistricts();
  return pCityDistricts and pCityDistricts.GetDistrict and pCityDistricts:GetDistrict(districtEntry.Index);
end

function GetSelectedDistrict()
  if not g_PlacementSettings.DistrictID then  return  end
  local pCity = GetSelectedCity();
  local pCityDistricts = pCity and pCity:GetDistricts();
  return pCityDistricts and pCityDistricts.GetDistrictByID and pCityDistricts:GetDistrictByID(g_PlacementSettings.DistrictID);
end

-------------------------------------------------------------------------------
function SelectCityAt(plot)
  local pCity = Cities.GetPlotWorkingCity(plot:GetIndex())
  if not pCity then  return  end

  g_PlacementSettings.Player = pCity:GetOwner();
  g_PlacementSettings.CityID = pCity:GetID();
end

g_CityPicker = 
{
  Place = SelectCityAt,
  Remove = SelectCityAt,
}

-------------------------------------------------------------------------------
g_DistrictPlacement =
{
  DistrictType = -1,
  DistrictTypeName = "",
}

function g_DistrictPlacement.Place(plot)
  local pCity = GetSelectedCity();
  if not pCity then  return  end

  local pBuildQueue = pCity:GetBuildQueue();
  pBuildQueue:CreateIncompleteDistrict(g_DistrictPlacement.DistrictType, plot:GetIndex(), TunerCity.options.buildPercent);
end

function g_DistrictPlacement.Remove(plot)
  local pDistrict = CityManager.GetDistrictAt(plot);
  if not pDistrict then  return  end

  CityManager.DestroyDistrict(pDistrict);
end

--[[
-------------------------------------------------------------------------------
g_BuildingPlacement =
{
  BuildingType = -1,
  BuildingTypeName = "",
}

function g_BuildingPlacement.Remove(plot)
end
--]]




-------------------------------------------------------------------------------
function OnLButtonUp( plotX, plotY )
  if not g_PanelHasFocus then  return  end
  local plot = Map.GetPlot( plotX, plotY );

  if g_PlacementSettings and g_PlacementSettings.PlacementHandler and g_PlacementSettings.PlacementHandler.Place then
    g_PlacementSettings.PlacementHandler.Place(plot);
  end

  -- LuaEvents.TunerExitDebugMode();
end

LuaEvents.TunerMapLButtonUp.Add(OnLButtonUp);

-------------------------------------------------------------------------------
function OnRButtonDown( plotX, plotY )
  if not g_PanelHasFocus then  return  end
  local plot = Map.GetPlot( plotX, plotY );

  if g_PlacementSettings and g_PlacementSettings.PlacementHandler and g_PlacementSettings.PlacementHandler.Remove then
    g_PlacementSettings.PlacementHandler.Remove(plot);
  end

  -- LuaEvents.TunerExitDebugMode();
end

LuaEvents.TunerMapRButtonDown.Add(OnRButtonDown);

-------------------------------------------------------------------------------
function OnUIDebugModeEntered()
  if not g_PanelHasFocus then  return  end
  g_PlacementSettings.Active = true;
end

LuaEvents.UIDebugModeEntered.Add(OnUIDebugModeEntered);

-------------------------------------------------------------------------------
function OnUIDebugModeExited()
  if not g_PanelHasFocus then  return  end
  g_PlacementSettings.Active = false;
end

LuaEvents.UIDebugModeExited.Add(OnUIDebugModeExited);



-------------------------------------------------------------------------------
function GetCityBuildProgress(pCity)
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
function GetBQCurrentlyBuilding(pBuildQueue :table)
  if pBuildQueue.CurrentlyBuilding then  return pBuildQueue:CurrentlyBuilding()  end
  return "<not accessible>"
end

function SetBuildingPillaged(pCity :table, buildingType :string, isPillaged :boolean)
  if not pCity then  return  end

  -- Change the display name back to the full text key and look for it.
  local building  = GameInfo.Buildings[buildingType];
  if building then
    pCity:GetBuildings():SetPillaged(building.Index, isPillaged);
  end
end



-------------------------------------------------------------------------------
function OnPrintCityInfo(pCity)
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
  print( ':CurrentlyBuilding()'  , GetBQCurrentlyBuilding(pBuildQueue) )
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

LuaEvents.PrintCityInfo.RemoveAll();
LuaEvents.PrintCityInfo.Add(OnPrintCityInfo);


