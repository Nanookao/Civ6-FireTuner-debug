print( "loading TunerCityPanel.lua" );
--return

TunerCity = TunerCity or {}
g_PanelHasFocus = false;

-------------------------------------------------------------------------------
TunerCity.selected = TunerCity.selected or {}
TunerCity.options  = TunerCity.options  or {}

g_PlacementSettings =
{
  Player = nil,
  CityID = nil,
  DistrictID = nil,
  PlacementHandler = nil,

  EditKey = "",
  EditVal = ""
}

-------------------------------------------------------------------------------
function TunerCity:MapClickHandler(plot)
  if self:InPlacementMode() then
    TunerCity:FinishPlacement(plot)
    return
  end
  

  local pCity = Cities.GetPlotWorkingCity(plot:GetIndex())
  if not pCity then  return  end

  g_PlacementSettings.Player = pCity:GetOwner();
  g_PlacementSettings.CityID = pCity:GetID();
end


function TunerCity.OnLButtonUp(X,Y)
  return TunerCity:MapClickHandler( Map.GetPlot(X,Y) )
end

LuaEvents.TunerMapLButtonUp.Add( TunerCity.OnLButtonUp )
--LuaEvents.TunerMapRButtonUp.Add( TunerCity.OnRButtonUp );



-------------------------------------------------------------------------------
function TunerCity:SetFocused(focused)
  self.focused = focused
  self.SetDebugMode[focused]()
end

TunerCity.SetDebugMode = {}
TunerCity.SetDebugMode[true] = LuaEvents.TunerEnterDebugMode
TunerCity.SetDebugMode[false] = LuaEvents.TunerExitDebugMode

function OnUIDebugModeEntered()
  TunerCity.inDebugMode = true;
end

function OnUIDebugModeExited()
  TunerCity.inDebugMode = false;
end

LuaEvents.UIDebugModeEntered.Add(OnUIDebugModeEntered);
LuaEvents.UIDebugModeExited.Add(OnUIDebugModeExited);




-------------------------------------------------------------------------------
function TunerCity:ListCities(items :table)
  items = items or {}
  -- local numPlayers = PlayerManager.GetWasEverAliveCount()
  -- for playerID = 0, numPlayers-1, 1 do
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
    local str = self:FormatCity(pCity, playerLoc)
    table.insert(items, str)

    if playerID == self.selected.PlayerID and pCity:GetID() == self.selected.CityID then
      items.selected = #items;
    end
  end
  return items
end

function TunerCity:FormatCity(pCity :table, playerLoc :string)
  local playerID = pCity:GetOwner()
  local cityID = pCity:GetID()
  --local cityIdx = cityID & 0xFFFF
  local cityIdx = cityID % 0x10000
  local cityIdxUpper = math.floor(cityID / 0x10000)
  local cityIDStr = string.format("0x%x", cityID)
  --local cityIDStr = cityIdxUpper .. "," .. cityIdx

  local origOwner = pCity:GetOriginalOwner()
  local origOwnerLoc = ""
  if origOwner ~= playerID then
    origOwnerLoc = "none";
    if origOwner ~= -1 then
      local origOwnerStr = PlayerConfigurations[origOwner]:GetCivilizationShortDescription();
      origOwnerLoc = Locale.Lookup( origOwnerStr )
      --origOwnerLoc = origOwnerStr:gsub("LOC_CIVILIZATION_", "");
      if origOwnerLoc == "" then  origOwnerLoc = "Player " .. tostring(origOwner)  end
    end
    origOwnerLoc = origOwnerLoc .. " ->"
  end

  --local cityName = pCity:GetName():gsub("LOC_CITY_NAME_", "")
  local cityNameLoc = Locale.Lookup( pCity:GetName() )
  local buildingLoc = self:GetCurrentlyBuildingLoc(pCity)
  --local progress = GetCityBuildProgress(pCity)

  local str = "    " .. playerID .. "," .. cityIDStr
  .. ";" .. origOwnerLoc
  .. ";" .. playerLoc
  .. ";" .. playerID .. "," .. cityIdx
  .. ";" .. cityNameLoc
  .. ";" .. pCity:GetX() .. "," .. pCity:GetY()
  .. ";" .. buildingLoc
  return str;
end




-------------------------------------------------------------------------------
function TunerCity:SelectCity(selCity: string)
  -- No split available
  local playerIDStr, cityIDStr = selCity:match("^(%d+),(0x%x+)");
  --print("TunerCity:SelectCity()  selCity, playerIDStr, cityIDStr=", selCity, playerIDStr, cityIDStr)
  local pPlayer = Players[ tonumber(playerIDStr) ];
  self.selected.pPlayer = pPlayer;

  local cityID = tonumber(cityIDStr)
  local pCity = cityID and pPlayer and pPlayer:GetCities():FindID(cityID);
  self.selected.pCity = pCity;
  if not pCity then  return pCity  end

  --[[
  print('----');
  print('TunerCity:SelectCity("' .. selCity .. '"):', pCity:GetName());
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



function TunerCity:GetBuildingType(selBuilding: string, district :boolean)
  print("TunerCity:GetBuildingType()  selBuilding=", selBuilding)
  -- Extract the db key from the line
  local name = string.match(selBuilding, '^[^;]+')
  if not name then  return  end

  -- Restore the full BuildingType
  return district and ('DISTRICT_' .. name) or ('BUILDING_' .. name)
end


function TunerCity:SelectBuilding(selBuilding: string, category :string)
  local district = (category == 'district')
  local dbBuildings = district and GameInfo.Districts() or GameInfo.Buildings()
  local buildingType = self:GetBuildingType(selBuilding, district)
  local dbBuildingInfo = dbBuildings[buildingType]
  self.selected[category] = dbBuildingInfo
  return dbBuildingInfo
end


function TunerCity:SelectDistrictByID(selDistrictState: string)
  local districtIDStr = string.match(selDistrictState, "%d+")
  local districtID = tonumber(districtIDStr)

  local pCity = self:GetSelectedCity()
  local pDistricts = pCity and pCity:GetDistricts()
  local pDistrict = pDistricts and pDistricts.GetDistrictByID and pDistricts:GetDistrictByID(districtID)
  self.selected.pDistrict = pDistrict
  return pDistrict
end


function TunerCity:SelectDistrictAt(plot: table)
  local pDistrict = CityManager.GetDistrictAt(plot)
  self.selected.pDistrict = pDistrict
  return pDistrict
end




-------------------------------------------------------------------------------
function TunerCity:GetSelectedCity()
  return self.selected.pCity
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

function TunerCity:GetSelectedDistrict()
  return self.selected.pDistrict
end




-------------------------------------------------------------------------------
function TunerCity:ListCityDistrictsOrBuildings(items :table, category :string, unbuilt :boolean)  -- , formatFunc :function
  items = items or {}
  local pCity = self:GetSelectedCity()
  if true or not pCity then  return items  end

  local district = (category == 'district')
  local dbBuildings = district and GameInfo.Districts() or GameInfo.Buildings()
  local pBuildings = district and pCity:GetDistricts() or pCity:GetBuildings()
  local wonder = (category == 'wonder')
  local pBuildQueue = pCity:GetBuildQueue();
  for dbBuildingInfo in dbBuildings do
    -- Add wonders only to wonder category, add rest to other category
    local add = (dbBuildingInfo.IsWonder == wonder)
    local str = add and self:FormatDistrictOrBuilding(pBuildings, pBuildQueue, dbBuildingInfo, unbuilt)
    if str then
      local item = { Text = str }
      if self.selected.BuildingType == dbBuildingInfo.BuildingType then  item.Selected = true  end
      table.insert(items, item)
      break
    end
  end
  return items
end

function TunerCity:FormatDistrictOrBuilding(pBuildings :table, pBuildQueue :table, dbBuildingInfo :table, unbuilt :boolean)
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
  if not built and not unbuilt then  return  end

  local nameLoc = Locale.Lookup( dbBuildingInfo.Name )
  local str = name
    .. ";" .. nameLoc

  local pillaged = pBuildings.IsPillaged and pBuildings:IsPillaged(buildingID)

  if unbuilt then
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




-------------------------------------------------------------------------------
function TunerCity:ListCityBuildingsDetailed(items :table, unbuilt :boolean)  -- , formatFunc :function
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local items = {};
  local pDistricts = pCity:GetDistricts();
  local numDistricts = pDistricts:GetNumDistricts();
  for dbBuildingInfo in GameInfo.Districts() do
    if pDistricts:HasDistrict(dbBuildingInfo.Index) then
      local name = dbBuildingInfo.DistrictType:gsub("DISTRICT_", "");
      local nameLoc = Locale.Lookup( dbBuildingInfo.Name );
      local prev = nil;
      -- numDistricts= max iterations as a safeguard against infinite loop
      for i = 0, numDistricts, 1 do
        local pDistrict = pDistricts:GetDistrict(dbBuildingInfo.Index, i);
        if pDistrict == nil or pDistrict == prev then  break  end
        prev = pDistrict
        local str = name
          .. ";" .. nameLoc
          .. ";" .. pDistrict:GetX() .. "," .. pDistrict:GetY()
          .. ";" .. tostring(pDistrict:IsComplete())
          .. ";" .. tostring(pDistrict:IsPillaged())
          .. ";" .. pDistrict:GetID()
        table.insert(items, str)
      end
    end
  end
  return items;
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
    local name = Locale.Lookup( buildingInfo.Name );
    local name = buildingInfo.BuildingType:gsub("BUILDING_", "");
    if pBuildings:HasBuilding(buildingInfo.Index) then
      item.Text = name;
      --item.Text = name .. ";;;;" .. buildingInfo.BuildingType;
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

  -- Change the display name back to the full text key and look for it.
  local buildingType = self:GetBuildingType(selBuilding)
  local dbBuildingInfo = GameInfo.Buildings[buildingType];
  if dbBuildingInfo then
    pCity:GetBuildings():SetPillaged(dbBuildingInfo.Index, isPillaged);
  end
end




-------------------------------------------------------------------------------
function TunerCity:SetPlacementMode(start :boolean, category :string)
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

  self.selected.placeBuilding = dbBuildingInfo
  if dbBuildingInfo.RequiresPlacement then
    -- Enter building placement mode.
    self.PlacementHandler = self.FinishPlacement
    LuaEvents.TunerEnterDebugMode();
  else
    -- Just create it, it will go in its district.
    self:FinishPlacement()
  end
end

function TunerCity:FinishPlacement(plot)
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local dbBuildingInfo = self.selected.placeBuilding
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

  self.selected.placeBuilding = nil
end


function TunerCity:CancelPlacementMode()
  self.selected.placeBuilding = nil
end


function TunerCity:InPlacementMode()
  return self.selected.placeBuilding
end


function TunerCity:GetPlacementBuilding(category :string)
  local district = (category == 'district')
  local dbBuildingInfo = self.selected.placeBuilding
  return dbBuildingInfo and (district == not dbBuildingInfo.BuildingType) and dbBuildingInfo
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
function TunerCity:GetCurrentlyBuildingLoc(pCity :table)
  local buildingType = self:GetCurrentlyBuilding(pCity)
  local dbBuildingInfo = GameInfo.Buildings[buildingType]
    or GameInfo.Districts[buildingType]
    or GameInfo.Units[buildingType]
    or GameInfo.Projects[buildingType]
  return dbBuildingInfo and Locale.Lookup( dbBuildingInfo.Name ) or buildingType
end

function TunerCity:GetCurrentlyBuilding(pCity :table)
  pCity = pCity or self:GetSelectedCity()
  if not pCity then  return ""  end

  local pBuildQueue = pCity:GetBuildQueue()
  if pBuildQueue.CurrentlyBuilding then  return pBuildQueue:CurrentlyBuilding()  end
  return "<not accessible>"
end




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
function TunerCity:ListCityStat()
  local items = {}
  items[0] = "-0;Population;"
  items[1] = "-1;Housing;"
  items[2] = "-2;Food Surplus;"
  -- items[3] = "-3;Gold Yield Modifier;"
  -- items[4] = "-4;Remaining Attacks;"

  local pCity = self:GetSelectedCity()
  if not pCity then  return items  end

  items[0] = items[0] .. pCity:GetPopulation()
  items[1] = items[1] .. pCity:GetGrowth():GetHousing()
  items[2] = items[2] .. pCity:GetGrowth():GetFoodSurplus()
  -- items[3] = items[3] .. pCity:GetGoldYieldModifier()
  -- items[4] = items[4] .. pCity:GetRemainingAttacks()
  return items;
end




-------------------------------------------------------------------------------
function TunerCity:ListCityProperty()
  local pCity = self:GetSelectedCity()
  if not pCity then  return  end

  local props = pCity:GetProperties();
  local items = {};
  for k,v in pairs(props) do
    local line = k .. ";" .. tostring(v);
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
        local str = properCivName .. ";" .. pPlayerConfig:GetNickName();
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
        .. Locale.Lookup( pCity:GetName() )
        ..' -> '..i..' '..selSpoofToCiv
      print( 'LuaEvents.SetCityCiv("' .. selSpoofToCiv .. '"):  x,y,city,playerID,player= ' .. str )
      LuaEvents.SetCityCiv(x, y, i)
      print('----');
      break;
    end
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

LuaEvents.PrintCityInfo.RemoveAll();
LuaEvents.PrintCityInfo.Add(OnPrintCityInfo);


