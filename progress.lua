66+14=80
22*1.5=33
66+33=80+19

2,196610  40,27  France  Rouen         Temple of Artemis  21 +135
3,131073  63,43  Gaul    Noviodunum    Jebel Barkal        5 +135
3,262147  66,46  Gaul    Ratumacos     Oracle             24 +135

GameEvents.CityConquered(0,2,196610,40,27)
https://sukritact.github.io/Civilization-VI-Modding-Knowledge-Base/GameEvents.CityConquered
https://sukritact.github.io/Civilization-VI-Modding-Knowledge-Base/Events.CityProductionChanged
https://sukritact.github.io/Civilization-VI-Modding-Knowledge-Base/Events.WonderCompleted
https://sukritact.github.io/Civilization-VI-Modding-Knowledge-Base/Events.BuildingBuildProgressChanged
https://pastebin.com/raw/wG6i63cu



TunerCity.selected.pCity:GetDistricts():GetDistrictByType('DISTRICT_HARBOR')
TunerCity.selected.pCity:GetDistricts():GetDistrictByType(4)
TunerCity.selected.pCity:GetDistricts():GetDistrictByIndex(4)
TunerCity.selected.pCity:GetDistricts():GetDistrictLocation(4)
TunerCity.selected.pCity:GetDistricts():GetDistrictLocation('DISTRICT_HARBOR')


function print_table(obj)
	if  type(obj) ~= 'table'  then  print('type ' .. type(obj) .. ':  ' .. tostring(obj));  return  end
	print('Properties of:  ' .. tostring(obj));
	for k, v in pairs(obj) do
		print('  '..k..'= '..tostring(v))
	end
end
p=print_table

-- original:  https://forums.civfanatics.com/threads/lua-objects.601146/post-14523018
function pi(obj)
	if  type(obj) ~= 'table'  then  print('type ' .. type(obj) .. ':  ' .. tostring(obj));  return  end
	local inherited = getmetatable(obj).__index;
	return po( type(inherited) == 'table'  and  getmetatable(obj).__index  or  obj );
end



https://github.com/FiatAccompli/Civ6Mods/tree/master/PlayTheKeyboard_GlobalHotkeys
Toggle quick unit movement (Alt+Q)
Toggle quick unit combat (Ctrl+Alt+Q)
Toggle animated time of day (Alt+A)
Increase/decrease in-game ambient time of day (Ctrl+Home/Ctrl+End)
Increase/decrease in-game length of ambient time of day (Alt+Home/Alt+End)
Increase/decrease minimap size (Shift+Home/Shift+End)
Toggle city banner visibility (Alt+W)
Toggle unit icons (Alt+R)
Toggle heads up display/screenshot mode (Alt+T)


72/21=3.4
14*6=84



UI
--
GetSelectedCity():GetBuildQueue():GetTurnsLeft()
p=print

c = Cities.GetCityInPlot(63,43)  -- Noviodunum
c = Cities.GetCityInPlot(66,46)  -- Ratumacos
c = Cities.GetCityInPlot(40,27)  -- Rouen


[ Lua State = CityPanel ]
print( 'Rouen (France)   - Temple of Artemis' , Game.GetCurrentGameTurn() + Cities.GetCityInPlot(40,27):GetBuildQueue():GetTurnsLeft(),
                                                                            Cities.GetCityInPlot(40,27):GetBuildQueue():GetProductionYield() )
print( 'Paris (France)   - Terracotta Army  ' , Game.GetCurrentGameTurn() + Cities.GetCityInPlot(44,27):GetBuildQueue():GetTurnsLeft(),
                                                                            Cities.GetCityInPlot(44,27):GetBuildQueue():GetProductionYield() )
print( 'Quito (Gran)                        ' , Game.GetCurrentGameTurn() + Cities.GetCityInPlot(45,17):GetBuildQueue():GetTurnsLeft(),
                                                                            Cities.GetCityInPlot(45,17):GetBuildQueue():GetProductionYield() )
print( 'Ratumacos (Gaul) - Oracle           ' , Game.GetCurrentGameTurn() + Cities.GetCityInPlot(66,46):GetBuildQueue():GetTurnsLeft(),
                                                                            Cities.GetCityInPlot(66,46):GetBuildQueue():GetProductionYield() )
print( 'Philadelphia (Am) - Walls           ' , Game.GetCurrentGameTurn() + Cities.GetCityInPlot(36,40):GetBuildQueue():GetTurnsLeft(),
                                                                            Cities.GetCityInPlot(36,40):GetBuildQueue():GetProductionYield() )
print( 'Charleston (Am) - Amphiteater       ' , Game.GetCurrentGameTurn() + Cities.GetCityInPlot(42,45):GetBuildQueue():GetTurnsLeft(),
                                                                            Cities.GetCityInPlot(42,45):GetBuildQueue():GetProductionYield() )

print('ContextPtr[console]' , ContextPtr);
print( 'GetName' , c:GetName() )
print( 'GetYield', c:GetYield() )
b = c:GetBuildQueue()
print( 'CurrentlyBuilding'  , b.CurrentlyBuilding and b:CurrentlyBuilding() )
print( 'GetTurnsLeft'       , b.GetTurnsLeft and b:GetTurnsLeft() )
print( 'GetProductionYield' , b.GetProductionYield and b:GetProductionYield() )
h = b.GetCurrentProductionTypeHash and b:GetCurrentProductionTypeHash()
print( 'ProductionTypeHash' , h )
print( 'GetBuildingProgress', b:GetBuildingProgress(GameInfo.Buildings[h]) )
print( 'GetDistrictProgress', b:GetDistrictProgress(GameInfo.Districts[h]) )

print( Cities.GetCityInPlot(40,27):GetName() )
print( c:GetYieldTooltip() )

ABRButton: table: 000000023B111410
table: 000000023FC70000

LuaEvents.SetCityCiv(40,27, 0);
AssetPreview.SpoofCityCivAt(40,27, 0);
print( AssetPreview.SpoofCityCivAt );




 ABRButton: GetName	LOC_CITY_NAME_ROUEN
 ABRButton: GetYield	15
 ABRButton: GetTurnsLeft	-1
 ABRButton: GetProductionYield	6
 ABRButton: ProductionTypeHash	0
 ABRButton: GetBuildingProgress	0
 ABRButton: GetDistrictProgress	0

 CityPanel: GetName	LOC_CITY_NAME_ROUEN
 CityPanel: GetYield	15
 CityPanel: GetTurnsLeft	21 +135
 CityPanel: GetProductionYield	6
 CityPanel: ProductionTypeHash	-1423681175
 CityPanel: GetBuildingProgress	0
 CityPanel: GetDistrictProgress	0

 CityPanel: GetName	LOC_CITY_NAME_NOVIODUNUM
 CityPanel: GetYield	9
 CityPanel: GetTurnsLeft	5 +135
 CityPanel: GetProductionYield	18
 CityPanel: ProductionTypeHash	-512325035
 CityPanel: GetBuildingProgress	0
 CityPanel: GetDistrictProgress	0

 CityPanel: GetName	LOC_CITY_NAME_RATUMACOS
 CityPanel: GetYield	6
 CityPanel: GetTurnsLeft	24 +135
 CityPanel: GetProductionYield	6
 CityPanel: ProductionTypeHash	-1242520629
 CityPanel: GetBuildingProgress	0
 CityPanel: GetDistrictProgress	0



-- Example: Using events for different contexts
-- Gameplay context
Events.PlayerTurnStarted.Add(function(playerID)
    -- Gameplay logic here
    print("Gameplay context: Player turn started")
end)

-- UI context
ContextPtr:SetInitHandler(function()
    -- UI initialization logic here
    print("UI context: Initialization")
end)



-- Example: Global function for shared logic
local function updateGameState()
    -- Shared logic that can be called from both contexts
    print("Updating game state")
end

-- In gameplay context
Events.PlayerTurnStarted.Add(function(playerID)
    updateGameState()
end)

-- In UI context
ContextPtr:SetInputHandler(function()
    updateGameState()
end)



-- Example: Communicating between contexts using events
-- In UI context
local function requestGameplayAction()
    -- Signal a request to the gameplay context
    Events.RequestGameplayAction()
end

-- In gameplay context
Events.RequestGameplayAction.Add(function()
    -- Handle the request from the UI context
    print("Handling gameplay action request")
end)




MODIFIER_PLAYER_ADJUST_EMBARKED_MOVEMENT

		<Replace Name="MOVEMENT_EMBARK_COST" Value="2" />
		
		<Replace Name="MOVEMENT_RIVER_COST" Value="2" />
		
		<Replace Name="MOVEMENT_WHILE_EMBARKED_BASE" Value="2" />
		
		<Row Type="MODIFIER_PLAYER_ADJUST_EMBARKED_MOVEMENT" Kind="KIND_MODIFIER"/>

		<Row Type="ABILITY_GREAT_LIGHTHOUSE_MOVEMENT" Tag="CLASS_NAVAL_MELEE"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_MOVEMENT" Tag="CLASS_NAVAL_RANGED"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_MOVEMENT" Tag="CLASS_NAVAL_RAIDER"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_MOVEMENT" Tag="CLASS_NAVAL_CARRIER"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_RECON"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_MELEE"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_RANGED"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_ANTI_CAVALRY"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_LIGHT_CAVALRY"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_HEAVY_CAVALRY"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_SIEGE"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_LANDCIVILIAN"/>
		<Row Type="ABILITY_GREAT_LIGHTHOUSE_EMBARKED_MOVEMENT" Tag="CLASS_RELIGIOUS"/>



	local unitReference = GameInfo.Units[unitType];
string.find(unitReference.UnitType, "UNIT_HERO")
pBuildQueue:GetUnitProgress( unitReference.Index );

				local buildQueue = pCity:GetBuildQueue()
				local settlerType = GameInfo.Units["UNIT_SWORDSMAN"].Index
				local settlerProgress = buildQueue:GetUnitProgress(settlerType)

function()
	local pCity = GetSelectedCity();
	if (pCity == nil) then  return ""  end
	local unitIndex = GameInfo.Units["UNIT_SWORDSMAN"].Index;
	local buildQueue = pCity:GetBuildQueue();
	local progress = buildQueue:GetUnitProgress(unitIndex);
	return progress;
end



