g_PanelHasFocus = false;

-------------------------------------------------------------------------------
g_PlacementSettings =
{
	Active = false,
	Player = nil,
	CityID = nil,
	DistrictID = nil,
	PlacementConstruction = 100,
	PlacementHandler = nil,

	EditKey = "",
	EditVal = ""
}

-------------------------------------------------------------------------------
function GetSelectedCity()
	if (g_PlacementSettings.Player and g_PlacementSettings.CityID) then
		local pPlayer = Players[g_PlacementSettings.Player];
		if pPlayer ~= nil then
			local cities = pPlayer:GetCities();
			if ( cities ~= nil ) then
				return cities:FindID(g_PlacementSettings.CityID);
			end
		end
	end
	return nil;
end

-------------------------------------------------------------------------------
function GetCityBuildProgress(pCity)
  --local pCity = GetSelectedCity();
  if (not pCity) then  return "<select city>";  end
  local pCityBuildQueue = pCity:GetBuildQueue();
  local current = pCityBuildQueue:GetAt(0);
  local prodType = pCityBuildQueue:GetCurrentProductionTypeHash();
  if (prodType == 0) then  return "<not building>";  end
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
    d1 and pCityBuildQueue:GetBuildingProgress(d1) / pCityBuildQueue:GetBuildingCost(d1) or
    d2 and pCityBuildQueue:GetDistrictProgress(d2) / pCityBuildQueue:GetDistrictCost(d2) or
    d3 and pCityBuildQueue:GetUnitProgress(d3)     / pCityBuildQueue:GetUnitCost(d3)     or
    d4 and pCityBuildQueue:GetProjectProgress(d4)  / pCityBuildQueue:GetProjectCost(d4)

  return progress or "<unknown>";
end

-------------------------------------------------------------------------------
function GetSelectedDistrict()
	local pCity = GetSelectedCity();
	if pCity ~= nil and g_PlacementSettings.DistrictID then
		local pCityDistricts = pCity:GetDistricts();
		if pCityDistricts ~= nil then
			return pCityDistricts:GetDistrictByID(g_PlacementSettings.DistrictID);
		end
	end
	return nil;
end

-------------------------------------------------------------------------------
function GetSelectedPlayer()
	if (g_PlacementSettings.Player >= 0) then
		local pPlayer = Players[g_PlacementSettings.Player];
		return pPlayer;
	end
	return nil;
end

-------------------------------------------------------------------------------
function GetCityAt(plot)
	local city = Cities.GetPlotWorkingCity(plot:GetIndex())
	if ( city == nil ) then return end

	g_PlacementSettings.Player = city:GetOwner();
	g_PlacementSettings.CityID = city:GetID();
end

g_CityPicker = 
{
	Place = GetCityAt,
	Remove = GetCityAt
}

-------------------------------------------------------------------------------
g_DistrictPlacement =
{
	DistrictType = -1,
	DistrictTypeName = "",

	Place =
	function(plot)
		local city = GetSelectedCity();
		if (city ~= nil) then
			local pBuildQueue = city:GetBuildQueue();
			pBuildQueue:CreateIncompleteDistrict(g_DistrictPlacement.DistrictType, plot:GetIndex(), 
				g_PlacementSettings.PlacementConstruction);
		end
	end,
	
	Remove =
	function(plot)
		local pDistrict = CityManager.GetDistrictAt(plot);
		if (pDistrict ~= nil) then
			CityManager.DestroyDistrict(pDistrict);
		end
	end
}

-------------------------------------------------------------------------------
g_BuildingPlacement =
{
	BuildingType = -1,
	BuildingTypeName = "",
	
	Place =
	function(plot)
		local city = GetSelectedCity();
		if (city ~= nil) then
			local pBuildQueue = city:GetBuildQueue();
			pBuildQueue:CreateIncompleteBuilding(g_BuildingPlacement.BuildingType, plot:GetIndex(), 
				g_PlacementSettings.PlacementConstruction);
		end
	end,
	
	Remove =
	function(plot)

	end
}

-------------------------------------------------------------------------------
function OnLButtonUp( plotX, plotY )
	if (g_PanelHasFocus == true) then
		local plot = Map.GetPlot( plotX, plotY );

		if (g_PlacementSettings ~= nil and
				g_PlacementSettings.PlacementHandler ~= nil and
				g_PlacementSettings.PlacementHandler.Place ~= nil) then

			g_PlacementSettings.PlacementHandler.Place(plot);
		end
	
		-- LuaEvents.TunerExitDebugMode();
	end
	return;
end

LuaEvents.TunerMapLButtonUp.Add(OnLButtonUp);

-------------------------------------------------------------------------------
function OnRButtonDown( plotX, plotY )
	if (g_PanelHasFocus == true) then
		local plot = Map.GetPlot( plotX, plotY );
		
		if (g_PlacementSettings ~= nil and
				g_PlacementSettings.PlacementHandler ~= nil and
				g_PlacementSettings.PlacementHandler.Remove ~= nil) then

			g_PlacementSettings.PlacementHandler.Remove(plot);
		end
	
		-- LuaEvents.TunerExitDebugMode();
	end
	return;
end

LuaEvents.TunerMapRButtonDown.Add(OnRButtonDown);

-------------------------------------------------------------------------------
function OnUIDebugModeEntered()
	if (g_PanelHasFocus == true) then
		g_PlacementSettings.Active = true;
	end
end

LuaEvents.UIDebugModeEntered.Add(OnUIDebugModeEntered);

-------------------------------------------------------------------------------
function OnUIDebugModeExited()
	if (g_PanelHasFocus == true) then
		g_PlacementSettings.Active = false;
	end
end

LuaEvents.UIDebugModeExited.Add(OnUIDebugModeExited);
