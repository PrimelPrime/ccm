DGS = exports.dgs
local screenWidth, screenHeight = guiGetScreenSize()
--Store arguments that are used in the function createOccupiedVehicleAndMoveOverPath
--Define the arguments, tooltips and their types
local arguments = {
    {name = "pedID", toolTip = "The PedID that should be used for the occupied vehicle. It uses the character model by default or 0.\nNote: This is irrelevant if the endless cars are activated.", type = "integer", text = "Choose any ped ID"},
    {name = "vehicleID", toolTip = "The VehicleID that should be used. It gets the current vehicle by default or 411.\nNote: This is irrelevant if the endless cars are activated.", type = "integer", text = "Choose any vehicle ID"},
    {name = "filePath", toolTip = "Filename for the path you will later want to import to your map. \"Path\" by default.", type = "string", text = "Choose any file name"},
    {name = "vehicleSettings", toolTip = "Opens a menu with several settings to adjust the vehicle.", type = "button", text = "Vehicle Settings"},
    {name = "heightOffset", toolTip = "The vehicle height offset that can be set because sometimes certain vehicles don't touch the ground or are too high up. 0 by default.\nNote: It should not occure any longer that a vehicle is too high up or too low, but its there just in case.", type = "float", text = "Height offset"},
    {name = "destroyVehicle", toolTip = "Should the vehicle be destroyed after the path is finished? True by default.", type = "boolean", text = "Destroy vehicle after path has ended?"},
    {name = "sirenLights", toolTip = "Should the siren lights be activated? Works with any emergency vehicle. False by default.", type = "boolean", text = "Activate siren lights?"},
    {name = "searchlightFollowsPlayer", toolTip = "Should a searchlight be following the player? Works with any vehicle. False by default.", type = "boolean", text = "Create searchlight?"},
    {name = "searchlightOffset", toolTip = "The searchlight offset, where should the searchlight start on the given vehicle. 0 by default.\nNote: offsets are calculated to the local position of the vehicle.\nTip: go to {0, 0, 0} in the world place a vehicle and use an object to find the perfect offset.", type = "table"},
    {name = "adjustableProperty", toolTip = "Adjustable properties are used for adjusting the movable parts of a model, for example hydra jets or dump truck tray. ", type = "boolean", text = "Use adjustable property"},
    {name = "adjPropValue", toolTip = "A value from 0 between ? (Set the adjustable value between 0 and N. 0 is the default value. It is possible to force the setting beyond default maximum, for example setting above 5000 on the dump truck (normal max 2500) will cause the tray to be fully vertical).\nDefault maximum values - Packer: 2500, Dumper: 2500, Forklift: 2500, Hydra: 5000, ", type = "float", text = "Set adjustable property value"},
    {name = "interpolateAdjProp", toolTip = "Decide if you want to interpolate between two values for the adjustable property.", type = "boolean", text = "Adjustable property interpolation"},
    {name = "startValue", toolTip = "Start value: see tooltip for adjustable property. 0 by default.", type = "float", text = "Start value"},
    {name = "endValue", toolTip = "End value: see tooltip for adjustable property. 2500 by default.", type = "float", text = "End value"},
    {name = "duration", toolTip = "Duration for the adjustable property set in milliseconds. 3000 by default.", type = "float", text = "Duration"},
    {name = "attachObject", toolTip = "Opens a menu with several settings to attach an object to the vehicle.", type = "button", text = "Attach Object"},
    {name = "attachEffect", toolTip = "Opens a menu with several settings to attach an effect to the vehicle.", type = "button", text = "Attach Effect"},
    {name = "attachText", toolTip = "Opens a menu with several settings to attach a text to the vehicle.", type = "button", text = "Attach Text"},
}

local vehicleArguments = {
    {name = "keepVehiclePreview", toolTip = "Keep the vehicle preview. False by default.\nNote: This will keep each setting that could interfere with the driving capabillites on e.g. the rotation etc., If set to true.", type = "boolean", text = "Keep vehicle preview"},
    {name = "vehicleOverrideLights", toolTip = "Override the vehicle lights to be always on. True by default.", type = "boolean", text = "Override vehicle lights"},
    {name = "vehicleTrailSmoke", toolTip = "This function is used to set planes smoke trail enabled or disabled. True by default.", type = "boolean", text = "Activate trail smoke"},
    {name = "vehicleRotation", toolTip = "Define the rotation of the vehicle. The rotation is a table with 3 float values. {0, 0, 0} by default.", type = "table"},
    {name = "vehicleWheelStates", toolTip = "This function is used to set the wheel states of a vehicle. The wheel states are: -1 - default, 0 - inflated, 1 - flat, 2 - fallen off, 3 - collisionless. ({-1, -1, -1, -1} (frontLeft, rearLeft, frontRight, rearRight) by default.\nNote: Pass multiple vehicle states via the following -> (frontLeft, rearLeft, frontRight, rearRight): \"-1, 1, 1, 1\"\nIf only one integer is given it will set all vehicles states to the given integer.", type = "integer", text = "Set wheel states"},
    {name = "vehicleWheelSize", toolTip = "This function is used to set the wheel size of a vehicle. The wheel size is a float value. 1 by default.\nNote: You can either set all wheels with only one integer as input or choose between each axle with \"1, 2\", where 1 is the front axle and 2 the size. (1 = front axle, 2 = rear axle; second value is always the size which can't be 0) \nDisclaimer: This is turned off for now, can still be used in the preview but won't affect the vehicles in the end.", type = "float", text = "Set wheel size"},
    {name = "vehicleAlpha", toolTip = "This function is used to set the alpha of a vehicle and its ped. 255 by default.", type = "integer", text = "Set vehicle alpha"},
}

local objectArguments = {
    {name = "attachToVehiclePosOffset", toolTip = "The offset for the object that is attached to the vehicle. {0, 0, 0} by default.", type = "table"},
    {name = "attachToVehicleRotOffset", toolTip = "The rotation offset for the object that is attached to the vehicle. {0, 0, 0} by default.", type = "table"},
    {name = "attachToVehicleScale", toolTip = "The scale for the object that is attached to the vehicle. {1, 1, 1} by default.", type = "table"},
    {name = "attachToVehicleAlpha", toolTip = "The alpha for the object that is attached to the vehicle. 255 by default.", type = "integer", text = "Set object alpha"},
    {name = "attachToVehiclePed", toolTip = "Select the ped you want inside the attached vehicle, if a vehicle is chosen.", type = "integer", text = "Choose any ped ID"},
    {name = "addObjectToList", toolTip = "Add the object to the object list.", type = "button", text = "Add object to list"},
    {name = "removeObjectFromList", toolTip = "Remove the object from the object list.", type = "button", text = "Remove object"},
    {name = "clearObjectList", toolTip = "Clear the object list.", type = "button", text = "Clear object list"},
}

local effectArguments = {
    {name = "attachEffectToVehiclePosOffset", toolTip = "The offset for the effect that is attached to the vehicle. {0, 0, 0} by default.", type = "table"},
    {name = "attachEffectToVehicleRotOffset", toolTip = "The rotation offset for the effect that is attached to the vehicle. {0, 0, 0} by default.", type = "table"},
    {name = "setEffectSpeed", toolTip = "The speed for the effect that is attached to the vehicle. 1 by default.", type = "float", text = "Set effect speed"},
    {name = "setEffectDensity", toolTip = "The density for the effect that is attached to the vehicle. 1 by default.\nNote: Upper density limit of this function depends on client FX Quality setting. The limit is 1 for Low, 1.5 for Medium, and 2 for High/Very high.", type = "float", text = "Set effect density"},
    {name = "addEffectToList", toolTip = "Add the effect to the effect list.", type = "button", text = "Add effect"},
    {name = "removeEffectFromList", toolTip = "Remove the effect from the effect list.", type = "button", text = "Remove effect"},
    {name = "clearEffectList", toolTip = "Clear the effect list.", type = "button", text = "Clear effect list"},
}

--dxDraw3DText(text, x, y, z, scale, font, color, maxDistance, colorCoded)
local textArguments = {
    {name = "textDisplay", toolTip = "The text that should be displayed. \"Text\" by default.", type = "string", text = "Set your text/name"},
    {name = "textPosition", toolTip = "The position of the text. {0, 0, 0} by default.", type = "table"},
    {name = "textSize", toolTip = "The size of the font. 2 by default.", type = "float", text = "Set font size"},
    {name = "textFont", toolTip = "The font of the text. \"default-bold\" by default.", type = "selectable", text = "Set font"},
    {name = "textColor", toolTip = "The color of the text. {255, 255, 255, 255} by default. Use: \"255, 255, 255, 255\" or other values to set your color!\nNote: Using just one value e.g. 255, 125 or 75... will set everything else to this value except the alpha which will always remain at 255.", type = "float", text = "Set color (RGBA)"},
    {name = "maxDistance", toolTip = "The maximum distance the text can be seen from. 100 by default.", type = "float", text = "Set max distance"},
    {name = "colorCoded", toolTip = "Should the text be color coded? False by default.\nNote: If set to true you can use colorcodes identical to how you would do it with your name with hex colors e.g. \"#fd9c3c\"", type = "boolean", text = "Color coded text"},
    {name = "addTextToList", toolTip = "Add the text to the text list.", type = "button", text = "Add text"},
    {name = "removeTextFromList", toolTip = "Remove the text from the text list.", type = "button", text = "Remove text"},
    {name = "clearTextList", toolTip = "Clear the text list.", type = "button", text = "Clear text list"},
}

local additionalArguments = {
    {name = "reversePath", toolTip = "Reverses the recorded path. False by default.", type = "boolean", text = "Reverse path"},
    {name = "endlessVehicles", toolTip = "If set to true the vehicles will drive endlessley over the recorded path with a set interval that is chosen below. False by default.\nNote: Settings this to true will also choose peds at random. This also applies to vehicles that have been attached.", type = "boolean", text = "Endless Vehicles"},
    {name = "endlessVehiclesPeds", toolTip = "If set to true the vehicles will be occupied by peds.\nNote: Turn this setting off for performance improvements.", type = "boolean", text = "Endless Peds"},
    {name = "endlessVehiclesGroup", toolTip = "The group of vehicles that should be spawned. default by default: Including most street racers, lowriders, muscle cars and other handpicked vehicles.\nNote: default is generally suited for path recordings that have been done with the Infernus.", type = "selectable", text = "Vehicles group"},
    {name = "endlessVehiclesDelay", toolTip = "The delay between each vehicle spawn in milliseconds. 1000 by default.\nNote: This can handle two integers in the following format \"1000, 2000\" and will spawn vehicles via the math.random method.\nMake sure that the first integer is always smaller than the second integer!", type = "float", text = "Spawn interval"},
    {name = "createVehicleGroup", toolTip = "Creates your own vehicle group that can be used for the endless vehicles.", type = "button", text = "Create Group"},
    --{name = "deleteVehicleGroup", toolTip = "Deletes the selected vehicle group.", type = "button", text = "Delete Group"},
    {name = "mirrorLabel", type = "label", text = "Mirror Path"},
    {name = "mirrorPath", toolTip = "Mirrors the path on the given axis. Default is none.", type = "selectable", text = "Select Axis"},
    {name = "mirrorPathOffset", toolTip = "The offset for the mirrored path. {0, 0, 0} by default.\nNote: Use the same format as in the edit box to set the offset (excluding Off:). E.g. 0, 0, 0 would be x = 0, y = 0, z = 0.", type = "float", text = "Off: 0, 0, 0"},
    {name = "mirrorPathRotation", toolTip = "The rotation for the mirrored path. {0, 0, 0} by default.\nNote: Use the same format as in the edit box to set the rotation (excluding Rot:). E.g. 0, 0, 0 would be rx = 0, ry = 0, rz = 0.", type = "float", text = "Rot: 0, 0, 0"},
}

local keybinds = {}
currentBinds = {
    bind = "n",
    cameraRight = "e",
    cameraLeft = "q",
    cameraUp = "s", 
    cameraDown = "w",
    cameraZoomIn = "r",
    cameraZoomOut = "f",
    magnetWheels = "lshift",
    magnetPower = 0.008,
    magnetFlyTolerance = 5,
}
editFields = {}
switchButtons = {}
selectables = {}
buttons = {}
isFlushEnabled = false

attachedEffectsPreview = {}
objectsAttachedToVehicle = {}
effectsAttachedToVehicle = {}
textsAttachedToVehicle = {}

local fonts = {"default", "default-bold", "clear", "arial", "sans", "pricedown", "bankgothic", "diploma", "beckett", "unifont"}
local axis = {"None", "X", "Y", "Z"}

local vehicleIds = {400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433,
434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451,
452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469,
470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505,
506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541,
542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559,
560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577,
578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595,
596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611
}

-- (when indexing just do a <vehicle model id you want the name of> - 399 to get the name)
local vehicleNames = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perennial", "Sentinel", "Dumper", "Fire_Truck", "Trashmaster", "Stretch", "Manana", 
	"Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", 
	"Mr._Whoopee", "BF_Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", 
	"Trailer_1", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC_Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", 
	"Seasparrow", "Pizzaboy", "Tram", "Trailer_2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", 
	"Berkleys_RC_Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC_Baron", "RC_Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", 
	"Quadbike", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", 
	"Baggage", "Dozer", "Maverick", "News_Chopper", "Rancher", "FBI_Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring_Racer", "Sandking", 
	"Blista_Compact", "Police_Maverick", "Boxville", "Benson", "Mesa", "RC_Goblin", "Hotring_Racer_2", "Hotring_Racer_3", "Bloodring_Banger", 
	"Rancher_Lure", "Super_GT", "Elegant", "Journey", "Bike", "Mountain_Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain", "Nebula", 
	"Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement_Truck", "Towtruck", "Fortune", "Cadrona", "FBI_Truck", 
	"Willard", "Forklift", "Tractor", "Combine_Harvester", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Brown_Streak", "Vortex", "Vincent", 
	"Bullet", "Clover", "Sadler", "Fire_Truck_Ladder", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility_Van", 
	"Nevada", "Yosemite", "Windsor", "Monster_2", "Monster_3", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC_Tiger", "Flash", 
	"Tahoma", "Savanna", "Bandito", "Freight_Train_Flatbed", "Streak_Train_Trailer", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", 
	"AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer_Tanker_Commando", "Emperor", "Wayfarer", "Euros", "Hotdog", 
	"Club", "Box_Freight", "Trailer_3", "Andromada", "Dodo", "RC_Cam", "Launch", "Police_LS", "Police_SF", "Police_LV", "Police_Ranger", 
	"Picador", "S.W.A.T", "Alpha", "Phoenix", "Damaged_Glendale", "Sadler_Damaged", "Baggage_Trailer_Covered", 
	"Baggage_Trailer_Uncovered", "Trailer_Stairs", "Boxville_Mission", "Farm_Trailer", "Street_Clean_Trailer"
}

local mainGroups = {
    "default", "streetRacers", "lowridersAndMuscleCars", "bikes", "bicycles"
}

local aircraftIDs = {
    592, 577, 520, 553, 476, 519
}

local effectNames = {
    "blood_heli", "boat_prop", "camflash", "carwashspray", "cement", "cloudfast", "coke_puff", "coke_trail", "cigarette_smoke",
    "explosion_barrel", "explosion_crate", "explosion_door", "exhale", "explosion_fuel_car", "explosion_large", "explosion_medium",
    "explosion_molotov", "explosion_small", "explosion_tiny", "extinguisher", "flame", "fire", "fire_med", "fire_large", "flamethrower",
    "fire_bike", "fire_car", "gunflash", "gunsmoke", "insects", "heli_dust", "jetpack", "jetthrust", "nitro", "molotov_flame",
    "overheat_car", "overheat_car_electric", "prt_blood", "prt_boatsplash", "prt_bubble", "prt_cardebris", "prt_collisionsmoke",
    "prt_glass", "prt_gunshell", "prt_sand", "prt_sand2", "prt_smokeII_3_expand", "prt_smoke_huge", "prt_spark", "prt_spark_2",
    "prt_splash", "prt_wake", "prt_watersplash", "prt_wheeldirt", "petrolcan", "puke", "riot_smoke", "spraycan", "smoke30lit", "smoke30m",
    "smoke50lit", "shootlight", "smoke_flare", "tank_fire", "teargas", "teargasAD", "tree_hit_fir", "tree_hit_palm", "vent", "vent2",
    "water_hydrant", "water_ripples", "water_speed", "water_splash", "water_splash_big", "water_splsh_sml", "water_swim", "waterfall_end",
    "water_fnt_tme", "water_fountain", "wallbust", "WS_factorysmoke"
}

local wheelSizes = {}
function getAllVehicleWheelSizes()
    for i = 400, 611 do
        local front_axle = getVehicleModelWheelSize(i, "front_axle")
        local rear_axle = getVehicleModelWheelSize(i, "rear_axle")
        wheelSizes[i] = {vehicleID = i, front_axle = front_axle, rear_axle = rear_axle}
    end
    return wheelSizes
end
addEventHandler("onClientResourceStart", resourceRoot, getAllVehicleWheelSizes)

function isEditorRunning()
    return getResourceFromName("editor") and getResourceState(getResourceFromName("editor")) == "running"
end

function addFilesToComboBox()
    DGS:dgsComboBoxClear(pathsComboBox)
    triggerServerEvent("onRequestFileList", localPlayer)
end


addEvent("onReceiveFileList", true)
addEventHandler("onReceiveFileList", localPlayer, function(fileList)
    if fileList then
        for i, fileData in ipairs(fileList) do
            local filePath = fileData.path
            if filePath and filePath:match("%.json$") then
                DGS:dgsComboBoxAddItem(pathsComboBox, filePath)
            end
        end
        outputDebugString("[CCM]: All files have been successfully added to the ComboBox.", 4, 100, 255, 100)
    end
end)

function getMaps(maps)
    local resources = maps

    mapNames = {}

    if resources then
        DGS:dgsGridListClear(mapsGridList)
        if DGS:dgsGridListGetColumnCount(mapsGridList) == 0 then
            DGS:dgsGridListAddColumn(mapsGridList, "Select one of your maps", 1)
        end
        for i, resource in pairs(resources) do
            DGS:dgsGridListAddRow(mapsGridList, resource, resource)
            table.insert(mapNames, resource)
        end
    end
end
addEvent("onClientResourcesGet", true)
addEventHandler("onClientResourcesGet", root, getMaps)

local markers = {}

addEvent("updateMarkersList", true)
addEventHandler("updateMarkersList", root, function(serverMarkers)

    DGS:dgsGridListClear(markerGridList)
    if DGS:dgsGridListGetColumnCount(markerGridList) == 0 then
        DGS:dgsGridListAddColumn(markerGridList, "Select one of your markers", 1)
    end

    if not serverMarkers or #serverMarkers == 0 then
        outputDebugString("[CCM]: No markers received from server.", 0, 255, 100, 100)
        return
    end

    markers = serverMarkers
    for i, markerData in ipairs(markers) do
        if markerData.displayText then
            local row = DGS:dgsGridListAddRow(markerGridList)
            DGS:dgsGridListSetItemText(markerGridList, row, 1, markerData.displayText, false, false)
            --outputDebugString("Row added successfully: " .. markerData.displayText)
        else
            --outputDebugString("Missing displayText for marker: " .. tostring(i))
        end
    end
end)

function addFontsToComboBox()
    DGS:dgsComboBoxClear(selectables[1])
    for i, font in ipairs(fonts) do
        DGS:dgsComboBoxAddItem(selectables[1], font)
    end
end

function addVehicleGroupToComboBox()
    DGS:dgsComboBoxClear(selectables[2])
    triggerServerEvent("onRequestVehicleGroups", localPlayer)
end

function addAxisToComboBox()
    DGS:dgsComboBoxClear(selectables[3])
    for i, axisName in ipairs(axis) do
        DGS:dgsComboBoxAddItem(selectables[3], axisName)
    end
end

addEvent("onReceiveVehicleGroups", true)
addEventHandler("onReceiveVehicleGroups", localPlayer, function(vehicleGroups)
    for i, mainGroup in ipairs(mainGroups) do
        DGS:dgsComboBoxAddItem(selectables[2], mainGroup)
    end
    if vehicleGroups then
        for i, vehicleGroup in ipairs(vehicleGroups) do
            DGS:dgsComboBoxAddItem(selectables[2], vehicleGroup)
        end
        outputDebugString("[CCM]: All vehicle groups have been successfully added to the ComboBox.", 4, 100, 255, 100)
    end
end)

function createMainGuiMenu()

    local playerVehicle = getPedOccupiedVehicle(localPlayer)

    ------------------------------------------
    --------- Table for gui settings ---------
    ------------------------------------------

    local declare = {
        sPosX = (screenWidth / 2),
        sPosY = (screenHeight / 2),
        sWidth = 250,
        sHeight = 850,
        width = 200,
        height = 30,
        marginTop = 15,
        marginBottom = 30,
        marginLeft = 25,
        marginRight = 25,
        spacing = 5,
        pathMenuWidth = 600
    }
    
    ------------------------------------------
    -------- Create the main GUI menu --------
    ------------------------------------------

    mainRecordMenu = DGS:dgsCreateWindow(declare.sPosX - (declare.sWidth / 2), declare.sPosY - (declare.sHeight / 2), declare.sWidth, declare.sHeight, "CCM - Record Path - Press N to close", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(mainRecordMenu, false)

    for i, argument in ipairs(arguments) do
        local argumentName = argument.name
        local argumentToolTip = argument.toolTip
        local argumentType = argument.type
        local argumentText = argument.text
        local y = declare.marginTop + (i - 1) * (declare.height + declare.spacing)

        if i >= 5 then
            if i == 5 then
                local optional = DGS:dgsCreateLabel(declare.marginLeft + declare.width / 4, y + 10, declare.width, declare.height, "Optional arguments", false, mainRecordMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, optional, "Optional arguments are not required for the function to work. You can leave them as they are and it will make use of the default value.\nNote: You'd normally provide every argument in order, but you dont have to because we are setting certain conditions to provide default values.")
            end
            y = y + declare.spacing * 8
        end
        
        
        if argumentType == "string" or argumentType == "float" or argumentType == "integer" then

            w = declare.width

            if argumentName == "vehicleID" then
                w = declare.width * 0.85
            end

            local argumentEdit = DGS:dgsCreateEdit(declare.marginLeft, y, w, declare.height, argumentText, false, mainRecordMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentEdit, argumentToolTip)
            table.insert(editFields, argumentEdit)

            if argumentName == "vehicleID" then
                local reloadImagePath = "images/reload.png"
                local reloadImage = dxCreateTexture(reloadImagePath, "argb", true, "clamp")
                local refreshButton = DGS:dgsCreateButton(declare.marginLeft + declare.width * 0.85, y, declare.width * 0.15, declare.height, "", false, mainRecordMenu, 0xFFFFFFFF, 1, 1, reloadImage, nil, nil)
                --local background = DGS:
                DGS:dgsBringToFront(refreshButton)
                DGS:dgsSetLayer(refreshButton, "top")
                addEventHandler("onDgsMouseClick", refreshButton, function(button, state)
                    if button == "left" and state == "down" then
                        local playerVehicle = getPedOccupiedVehicle(localPlayer)
                        setElementModel(playerVehicle, tonumber(DGS:dgsGetText(argumentEdit)))
                    end
                end, false)
            end
        
            -- Set input mode to "no_binds" when the edit field is focused
            addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    if DGS:dgsGetText(argumentEdit) == argumentText then
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end
            end, false)

            addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    DGS:dgsSetText(argumentEdit, "")
                end
            end, false)
        
            -- Set input mode back to "all" when the edit field is unfocused
            addEventHandler("onDgsBlur", argumentEdit, function()
                DGS:dgsSetInputMode("allow_binds")
                local playerVehicle = getPedOccupiedVehicle(localPlayer)
                local empty = DGS:dgsGetText(argumentEdit) == ""
                if argumentName == "pedID" then
                    local pedID = tonumber(DGS:dgsGetText(argumentEdit))
                    local pedModel = getElementModel(localPlayer)
                    if not pedID or pedID > 312 then
                        DGS:dgsSetText(argumentEdit, tostring(getElementModel(localPlayer)))
                    end
                    if pedID and pedID ~= pedModel then
                        setElementModel(localPlayer, pedID)
                    end
                elseif argumentName == "vehicleID" and playerVehicle then
                    local vehicleID = tonumber(DGS:dgsGetText(argumentEdit))
                    if not vehicleID then
                        DGS:dgsSetText(argumentEdit, tostring(getElementModel(playerVehicle)))
                    end
                elseif argumentType == "float" or argumentType == "integer" then
                    local value = tonumber(DGS:dgsGetText(argumentEdit))
                    if not value or empty then
                        DGS:dgsSetText(argumentEdit, argumentText)
                    end
                elseif empty then
                    DGS:dgsSetText(argumentEdit, argumentText)
                else return end
            end, false)
        elseif argumentType == "boolean" then
            y = y + declare.height / 2
            local argumentSwitch = DGS:dgsCreateSwitchButton(declare.marginLeft + declare.width / 4, y, declare.width / 2, declare.height / 2, "True", "False", false, false, mainRecordMenu)
            local argumentSwitchLabel = DGS:dgsCreateLabel(declare.marginLeft, y - ((declare.height / 2) + (declare.spacing / 2)), (declare.width / 3) - declare.spacing / 3, declare.height, argumentText, false, mainRecordMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentSwitch, argumentToolTip)
            table.insert(switchButtons, argumentSwitch)
            if argumentName == "destroyVehicle" then
                DGS:dgsSwitchButtonSetState(argumentSwitch, true)
            end
        elseif argumentType == "table" then
            if argumentName == "attachToVehicleRotOffset" then
                labels = {"rotX", "rotY", "rotZ"}
            else
                labels = {"offsetX", "offsetY", "offsetZ"}
            end
            for j = 0, 2 do
                local label = labels[j + 1]
                local argumentEdit = DGS:dgsCreateEdit((declare.marginLeft) + ((j * declare.width / 3) + (j * declare.spacing / 3)), y, (declare.width / 3) - declare.spacing / 3, declare.height, label, false, mainRecordMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, argumentEdit, argumentToolTip)
                table.insert(editFields, argumentEdit)
        
                -- Set input mode to "no_binds" when the edit field is focused
                addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        if DGS:dgsGetText(argumentEdit) == label then
                            DGS:dgsSetText(argumentEdit, "")
                        end
                    end
                end, false)

                addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end, false)
        
                -- Set input mode back to "all" when the edit field is unfocused
                addEventHandler("onDgsBlur", argumentEdit, function()
                    DGS:dgsSetInputMode("allow_binds")
                    if DGS:dgsGetText(argumentEdit) == "" then
                        DGS:dgsSetText(argumentEdit, label)
                    end
                end, false)
            end
        elseif argumentType == "selectable" then
            local argumentComboBox = DGS:dgsCreateComboBox(declare.marginLeft, y, declare.width, declare.height, argumentText, false, mainRecordMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentComboBox, argumentToolTip)
            table.insert(selectables, argumentComboBox)
        elseif argumentType == "button" then
            local argumentButton = DGS:dgsCreateButton(declare.marginLeft, y, declare.width, declare.height, argumentText, false, mainRecordMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentButton, argumentToolTip)
            table.insert(buttons, argumentButton)
        end
    end

    ------------------------------------------
    ---------- Buttons for main menu ---------
    ------------------------------------------

    local recordButton = DGS:dgsCreateButton(declare.marginLeft, declare.sHeight - declare.height - declare.spacing - declare.marginBottom * 3.5, (declare.width / 2) - declare.spacing / 2, declare.height, "Record", false, mainRecordMenu)
    local recordButtonTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(recordButtonTooltip, recordButton, "Starts recording the path. You can stop the recording by pressing N.\nNote: You need to be in a vehicle to record a path.")
    local closeButton = DGS:dgsCreateButton(declare.marginLeft + declare.width / 2 + declare.spacing / 2, declare.sHeight - declare.height - declare.spacing - declare.marginBottom * 3.5, (declare.width / 2) - declare.spacing / 2, declare.height, "Close", false, mainRecordMenu)
    local importButton = DGS:dgsCreateButton(declare.marginLeft, declare.sHeight - declare.height - declare.marginBottom * 2.5, declare.width, declare.height, "Import", false, mainRecordMenu)
    --Settings
    local settingsButton = DGS:dgsCreateButton(declare.marginLeft, declare.sHeight - declare.height - declare.marginBottom * 1.5 + declare.spacing, declare.width, declare.height, "Settings", false, mainRecordMenu)
    settingsMenu = DGS:dgsCreateWindow(declare.sPosX - declare.sWidth * 1.5, declare.sPosY - (declare.sHeight / 2), declare.sWidth, declare.sHeight * 0.445, "CCM - Settings", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(settingsMenu, false)
    DGS:dgsSetVisible(settingsMenu, false)
    --keybinds
    local function createKeybinds()
        local settingsBindLabel = DGS:dgsCreateLabel(declare.marginLeft, declare.marginTop * 1.5 - declare.spacing * 2, declare.width, declare.height, "Bind key for recording", false, settingsMenu)
        local cameraSettingsBindLabel = DGS:dgsCreateLabel(declare.marginLeft, declare.marginTop * 4.5 - declare.spacing * 2, declare.width, declare.height, "Bind keys for camera movement", false, settingsMenu)
        local defaultKeys = {
            {name = "bind", key = "n"},
            {name = "cameraRight", key = "e"},
            {name = "cameraLeft", key = "q"},
            {name = "cameraUp", key = "s"},
            {name = "cameraDown", key = "w"},
            {name = "cameraZoomIn", key = "r"},
            {name = "cameraZoomOut", key = "f"},
            {name = "magnetWheels", key = "lshift"},
        }
        local friendlyKeyNames = {
            {name = "Record"},
            {name = "Right"},
            {name = "Left"},
            {name = "Up"},
            {name = "Down"},
            {name = "Zoom in"},
            {name = "Zoom out"},
            {name = "Magnet Wheels"},
        }
        
        for i = 1, #defaultKeys do
            local marginLeft = declare.marginLeft
            local width = declare.width
            local adjustment = 0
            if i > 1 then
                marginLeft = declare.marginLeft + declare.width / 2
                width = declare.width / 2
                adjustment = 1
                local keyname = friendlyKeyNames[i].name
                local keylabel = DGS:dgsCreateLabel(declare.marginLeft, declare.marginTop * (2 * i + adjustment + 1) - declare.spacing * 2, width, declare.height, keyname, false, settingsMenu)
            end
            local keybind = DGS:dgsCreateMemo(marginLeft, declare.marginTop * (2 * i + adjustment), width, declare.height * 0.8, defaultKeys[i].key, false, settingsMenu)
            DGS:dgsMemoSetReadOnly(keybind, true)
            table.insert(keybinds, {element = keybind, name = defaultKeys[i].name})
        end

        local magnetPowerLabel = DGS:dgsCreateLabel(declare.marginLeft, declare.marginTop * (2 * 10) - declare.spacing * 2, declare.width / 2, declare.height, "Power", false, settingsMenu)
        local magnetPowerInput = DGS:dgsCreateEdit(declare.marginLeft + declare.width / 2, declare.marginTop * (2 * 9.5), declare.width / 2, declare.height * 0.8, tostring(currentBinds.magnetPower or 0.008), false, settingsMenu)
        local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
        DGS:dgsTooltipApplyTo(tooltip, magnetPowerInput, "Power of the magnet wheels.\nNote: The default value is 0.008.\nBigger value makes the magnet stronger, traction is much better, it's harder to leave an element and pull away from the ground.\nIf the value is too big vehicle's wheels might be smashed and contact with the objects causes many sparks.")
        table.insert(keybinds, {element = magnetPowerInput, name = "magnetPower"})

        local magnetFlyToleranceLabel = DGS:dgsCreateLabel(declare.marginLeft, declare.marginTop * (2 * 11) - declare.spacing * 2, declare.width / 2, declare.height, "Fly Tolerance", false, settingsMenu)
        local magnetFlyToleranceInput = DGS:dgsCreateEdit(declare.marginLeft + declare.width / 2, declare.marginTop * (2 * 10.5), declare.width / 2, declare.height * 0.8, tostring(currentBinds.magnetFlyTolerance or 5), false, settingsMenu)
        local mftooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
        DGS:dgsTooltipApplyTo(mftooltip, magnetFlyToleranceInput, "Max time a vehicle can fly without touching a ground.\nNote: The default value is 5.")
        table.insert(keybinds, {element = magnetFlyToleranceInput, name = "magnetFlyTolerance"})
    end

    createKeybinds()

    addEventHandler("onDgsMouseClick", recordButton, function(key, state)
        if key == "left" and state == "up" then
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
    
            if playerVehicle then
                setElementFrozen(playerVehicle, false)
                setElementVelocity(playerVehicle, vx, vy, vz)
                if keepPreview == false then --restore default settings
                    setVehicleOverrideLights(playerVehicle, 2)
                    setElementRotation(playerVehicle, rx, ry, rz)
                    setVehicleWheelStates(playerVehicle, 0, 0, 0, 0)
                    setElementAlpha(playerVehicle, 255)
                    setElementAlpha(localPlayer, 255)

                    for i = 0, 6 do
                        setVehicleWindowOpen(playerVehicle, i, false)
                    end

                    if playerVehicleModel == 512 or playerVehicleModel == 513 then
                        setVehicleSmokeTrailEnabled(playerVehicle, false)
                    end

                    setVehicleModelWheelSize(playerVehicleModel, "front_axle", currentWheelSizes.front_axle)
                    setVehicleModelWheelSize(playerVehicleModel, "rear_axle", currentWheelSizes.rear_axle)

                end
                setVehicleDamageProof(playerVehicle, true)
                setCameraTarget(localPlayer)
                if isElement(searchlight) then
                    destroyElement(searchlight)
                    killTimer(searchlightTimer)
                end
                toggleTimer()
            else
                DGS:dgsSetVisible(mainRecordMenu, false)
                DGS:dgsSetVisible(pathsMenu, false)
                DGS:dgsSetVisible(mainMemoMenu, false)
                DGS:dgsSetVisible(mainAdditionalMenu, false)
                DGS:dgsSetVisible(objectMenu, false)
                DGS:dgsSetVisible(effectMenu, false)
                DGS:dgsSetVisible(vehicleMenu, false)
                DGS:dgsSetVisible(vehicleGroupMenu, false)
                DGS:dgsSetVisible(settingsMenu, false)
                DGS:dgsSetVisible(textMenu, false)
                showCursor(false)
                outputChatBox("#D7DF01INFO#FFFFFF: You need to be in a vehicle to record a path.", 255, 255, 255, true)
            end
            isMenuOpen = false
        end
    end, false)

    addEventHandler("onDgsMouseClick", closeButton, function(key, state)
        if key == "left" and state == "up" then

            local playerVehicle = getPedOccupiedVehicle(localPlayer)

            DGS:dgsSetVisible(mainRecordMenu, false)
            DGS:dgsSetVisible(pathsMenu, false)
            DGS:dgsSetVisible(mainMemoMenu, false)
            DGS:dgsSetVisible(mainAdditionalMenu, false)
            if DGS:dgsGetVisible(objectMenu) then
                DGS:dgsSetVisible(objectMenu, false)
            end
            if DGS:dgsGetVisible(effectMenu) then
                DGS:dgsSetVisible(effectMenu, false)
            end
            if DGS:dgsGetVisible(vehicleMenu) then
                DGS:dgsSetVisible(vehicleMenu, false)
            end
            if DGS:dgsGetVisible(vehicleGroupMenu) then
                DGS:dgsSetVisible(vehicleGroupMenu, false)
            end
            if DGS:dgsGetVisible(settingsMenu) then
                DGS:dgsSetVisible(settingsMenu, false)
            end
            if DGS:dgsGetVisible(textMenu) then
                DGS:dgsSetVisible(textMenu, false)
            end
            showCursor(false)
            if playerVehicle then

                if isElementFrozen(playerVehicle) then
                    setElementFrozen(playerVehicle, false)
                end

                if isElement(searchlight) then
                    destroyElement(searchlight)
                    killTimer(searchlightTimer)
                end

                setElementVelocity(playerVehicle, vx, vy, vz)
                if keepPreview == false then --restore default settings
                    setVehicleOverrideLights(playerVehicle, 2)
                    setElementRotation(playerVehicle, rx, ry, rz)
                    setVehicleWheelStates(playerVehicle, 0, 0, 0, 0)
                    setElementAlpha(playerVehicle, 255)
                    setElementAlpha(localPlayer, 255)

                    for i = 0, 6 do
                        setVehicleWindowOpen(playerVehicle, i, false)
                    end

                    if playerVehicleModel == 512 or playerVehicleModel == 513 then
                        setVehicleSmokeTrailEnabled(playerVehicle, false)
                    end

                    setVehicleModelWheelSize(playerVehicleModel, "front_axle", currentWheelSizes.front_axle)
                    setVehicleModelWheelSize(playerVehicleModel, "rear_axle", currentWheelSizes.rear_axle)

                end
                setCameraTarget(localPlayer)
                setVehicleDamageProof(playerVehicle, false)

            end
            isMenuOpen = false
        end
    end, false)

    addEventHandler("onDgsMouseClick", importButton, function(key, state)
        if key == "left" and state == "up" then

            if DGS:dgsGetVisible(pathsMenu) then
                DGS:dgsSetVisible(pathsMenu, false)
                DGS:dgsSetVisible(mainMemoMenu, false)
                DGS:dgsSetVisible(mainAdditionalMenu, false)
                isPathsMenuOpen = false
                isMainMemoMenuOpen = false
                isAdditionalMenuOpen = false
            else
                DGS:dgsSetVisible(pathsMenu, true)
                DGS:dgsSetVisible(mainMemoMenu, true)
                DGS:dgsSetVisible(mainAdditionalMenu, true)
                isPathsMenuOpen = true
                isMainMemoMenuOpen = true
                isAdditionalMenuOpen = true
            end
        end
    end, false)

    addEventHandler("onDgsMouseClick", settingsButton, function(key, state)
        if key == "left" and state == "up" then

            if DGS:dgsGetVisible(settingsMenu) then
                DGS:dgsSetVisible(settingsMenu, false)
            else
                DGS:dgsSetVisible(settingsMenu, true)
            end
        end
    end, false)

    local isRecordingKey = false

    if not fileExists("bind.json") then
        local bindFile = fileCreate("bind.json")
        fileWrite(bindFile, toJSON(currentBinds))
        fileClose(bindFile)
    else
        local bindFile = fileOpen("bind.json")
        local bindData = fromJSON(fileRead(bindFile, fileGetSize(bindFile)))
        fileClose(bindFile)

        -- Update the currentBinds with values from the JSON file
        for key, value in pairs(currentBinds) do
            if bindData[key] ~= nil then
                currentBinds[key] = bindData[key]
            end
        end

        -- Update UI elements
        for i, keybind in ipairs(keybinds) do
            if bindData[keybind.name] then
                DGS:dgsSetText(keybind.element, tostring(bindData[keybind.name]))
            end
        end
    end
    
    
    local function setKey(keybind, button, press)
        if button ~= "mouse1" and press then
            if keybind.name == "magnetPower" or keybind.name == "magnetFlyTolerance" then
                local value = tonumber(DGS:dgsGetText(keybind.element))
                if value then
                    currentBinds[keybind.name] = value
                end
            else
                DGS:dgsSetText(keybind.element, button)
                currentBinds[keybind.name] = button
            end

            -- Update the bind.json file
            local bindFile = fileOpen("bind.json")
            local bindData = fromJSON(fileRead(bindFile, fileGetSize(bindFile)))
            bindData[keybind.name] = currentBinds[keybind.name]
            fileClose(bindFile)

            -- Reopen for writing
            local bindFile = fileCreate("bind.json", true)
            fileWrite(bindFile, toJSON(bindData))
            fileClose(bindFile)

            isRecordingKey = false
        end
    end
    
    for i, keybind in ipairs(keybinds) do
        keybind.handler = function(button, press)
            setKey(keybind, button, press)
        end
    
        addEventHandler("onDgsMouseClick", keybind.element, function(button, state)
            if button == "left" and state == "up" then
                if not isRecordingKey then
                    isRecordingKey = true
                    if not (keybind.name == "magnetPower" or keybind.name == "magnetFlyTolerance") then
                        DGS:dgsSetText(keybind.element, "Press any key...")
                    end
    
                    removeEventHandler("onClientKey", root, keybind.handler)
                    addEventHandler("onClientKey", root, keybind.handler)
                end
            end
        end, false)
    end

    DGS:dgsSetVisible(mainRecordMenu, false)

    ------------------------------------------
    --------- Create the object menu ---------
    ------------------------------------------

    objectMenu = DGS:dgsCreateWindow(declare.sPosX + (declare.sWidth / 2), declare.sPosY - declare.sWidth / 2, declare.sWidth * 3, declare.sHeight / 3, "Object settings", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(objectMenu, false)

    objectMenuGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.width + declare.spacing * 2 + declare.width * 1.25, declare.marginTop, declare.width * 1.25, declare.sHeight / 3.85 - declare.marginTop - declare.marginBottom, false, objectMenu)
    DGS:dgsGridListSetSortEnabled(objectMenuGridList, false)
    DGS:dgsGridListAddColumn(objectMenuGridList, "ID", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "Ped", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "offsetX", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "offsetY", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "offsetZ", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "rotX", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "rotY", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "rotZ", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "scaleX", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "scaleY", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "scaleZ", 0.2)
    DGS:dgsGridListAddColumn(objectMenuGridList, "Alpha", 0.2)

    objectMenuSelectGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.width + declare.spacing, declare.marginTop, declare.width * 1.25, declare.sHeight / 3.85 - declare.marginTop - declare.marginBottom, false, objectMenu)
    DGS:dgsGridListSetSortEnabled(objectMenuSelectGridList, false)
    DGS:dgsGridListAddColumn(objectMenuSelectGridList, "ID", 0.3)
    DGS:dgsGridListAddColumn(objectMenuSelectGridList, "Name", 0.75)

    objectMenuSearchBar = DGS:dgsCreateEdit(declare.marginLeft + declare.width + declare.spacing, declare.sHeight / 3.85 - declare.marginBottom, declare.width * 1.25, declare.height, "Search...", false, objectMenu)

    local allObjects = {}

    function processXmlNode(node)
        local nodeName = xmlNodeGetName(node)
        if nodeName == "object" or nodeName == "vehicle" then
            local model = xmlNodeGetAttribute(node, "model")
            local name = xmlNodeGetAttribute(node, "name")
            table.insert(allObjects, {model = model, name = name})
        elseif nodeName == "group" then
            local children = xmlNodeGetChildren(node)
            for _, child in ipairs(children) do
                processXmlNode(child)
            end
        end
    end

    function populateGridList(objects)
        DGS:dgsGridListClear(objectMenuSelectGridList)
        for _, object in ipairs(objects) do
            local row = DGS:dgsGridListAddRow(objectMenuSelectGridList)
            DGS:dgsGridListSetItemText(objectMenuSelectGridList, row, 1, object.model, false, false)
            DGS:dgsGridListSetItemText(objectMenuSelectGridList, row, 2, object.name, false, false)
        end
    end

    function loadXmlFile(filePath)
        local xmlFile = xmlLoadFile(filePath)
        if xmlFile then
            local rootNodes = xmlNodeGetChildren(xmlFile)
            for _, rootNode in ipairs(rootNodes) do
                processXmlNode(rootNode)
            end
            xmlUnloadFile(xmlFile)
        else
            outputDebugString("Failed to load " .. filePath)
        end
    end

    loadXmlFile("objects.xml")
    loadXmlFile("vehicles.xml")
    populateGridList(allObjects)
    
    for i, objectArgument in ipairs(objectArguments) do
        local objectArgumentName = objectArgument.name
        local objectArgumentToolTip = objectArgument.toolTip
        local objectArgumentType = objectArgument.type
        local objectArgumentText = objectArgument.text
        local y = declare.marginTop + (i - 1) * (declare.height + declare.spacing)

        if objectArgumentType == "string" or objectArgumentType == "float" or objectArgumentType == "integer" then
            local argumentEdit = DGS:dgsCreateEdit(declare.marginLeft, y, declare.width, declare.height, objectArgumentText, false, objectMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentEdit, objectArgumentToolTip)
            table.insert(editFields, argumentEdit)

            addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    if DGS:dgsGetText(argumentEdit) == objectArgumentText then
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end
            end, false)

            addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    DGS:dgsSetText(argumentEdit, "")
                end
            end)

            addEventHandler("onDgsBlur", argumentEdit, function()
                DGS:dgsSetInputMode("allow_binds")
                local playerVehicle = getPedOccupiedVehicle(localPlayer)
                local empty = DGS:dgsGetText(argumentEdit) == ""
                if objectArgumentType == "float" or objectArgumentType == "integer" then
                    local value = tonumber(DGS:dgsGetText(argumentEdit))
                    if not value or empty then
                        DGS:dgsSetText(argumentEdit, objectArgumentText)
                    end
                elseif empty then
                    DGS:dgsSetText(argumentEdit, objectArgumentText)
                else return end
            end, false)
        elseif objectArgumentType == "boolean" then
            y = y + declare.height / 2
            local argumentSwitch = DGS:dgsCreateSwitchButton(declare.marginLeft + declare.width / 4, y, declare.width / 2, declare.height / 2, "True", "False", false, false, objectMenu)
            local argumentSwitchLabel = DGS:dgsCreateLabel(declare.marginLeft, y - ((declare.height / 2) + (declare.spacing / 2)), (declare.width / 3) - declare.spacing / 3, declare.height, objectArgumentText, false, objectMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentSwitch, objectArgumentToolTip)
            table.insert(switchButtons, argumentSwitch)
            if objectArgumentName == "destroyVehicle" then
                DGS:dgsSwitchButtonSetState(argumentSwitch, true)
            end
        elseif objectArgumentType == "table" then
            if objectArgumentName == "attachToVehicleRotOffset" then
                labels = {"rotX", "rotY", "rotZ"}
            elseif objectArgumentName == "attachToVehiclePosOffset" then
                labels = {"offsetX", "offsetY", "offsetZ"}
            else
                labels = {"scaleX", "scaleY", "scaleZ"}
            end
            for j = 0, 2 do
                local label = labels[j + 1]
                local argumentEdit = DGS:dgsCreateEdit((declare.marginLeft) + ((j * declare.width / 3) + (j * declare.spacing / 3)), y, (declare.width / 3) - declare.spacing / 3, declare.height, label, false, objectMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, argumentEdit, objectArgumentToolTip)
                table.insert(editFields, argumentEdit)
        
                addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        if DGS:dgsGetText(argumentEdit) == label then
                            DGS:dgsSetText(argumentEdit, "")
                        end
                    end
                end, false)

                addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end, false)
        
                addEventHandler("onDgsBlur", argumentEdit, function()
                    DGS:dgsSetInputMode("allow_binds")
                    if DGS:dgsGetText(argumentEdit) == "" then
                        DGS:dgsSetText(argumentEdit, label)
                    end
                end, false)
            end
        elseif objectArgumentType == "selectable" then
            local argumentComboBox = DGS:dgsCreateComboBox(declare.marginLeft, y, declare.width, declare.height, objectArgumentText, false, objectMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentComboBox, objectArgumentToolTip)
            table.insert(selectables, argumentComboBox)
        elseif objectArgumentType == "button" then
            x = declare.marginLeft
            w = declare.width
            if objectArgumentName == "removeObjectFromList" then
                x = declare.marginLeft + declare.width + declare.spacing * 2 + declare.width * 1.25
                y = (declare.marginTop + 4 * declare.height) + declare.marginTop * 3.7
                w = declare.width / 1.65
            elseif objectArgumentName == "clearObjectList" then
                x = declare.marginLeft + declare.width * 1.65 + declare.spacing * 2 + declare.width * 1.25
                y = (declare.marginTop + 4 * declare.height) + declare.marginTop * 3.7
                w = declare.width / 1.65
            end
            local argumentButton = DGS:dgsCreateButton(x, y, w, declare.height, objectArgumentText, false, objectMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentButton, objectArgumentToolTip)
            table.insert(buttons, argumentButton)
        end
    end

    DGS:dgsSetVisible(objectMenu, false)

    addEventHandler("onDgsMouseClick", buttons[2], function(key, state)
        if key == "left" and state == "up" then
            if DGS:dgsGetVisible(objectMenu) then
                DGS:dgsSetVisible(objectMenu, false)
                isObjectMenuOpen = false
            else
                DGS:dgsSetVisible(objectMenu, true)
                isObjectMenuOpen = true
            end
        end
    end, false)

    addEventHandler("onDgsTextChange", objectMenuSearchBar, function()

        if DGS:dgsGetText(objectMenuSearchBar) == "Search..." or DGS:dgsGetText(objectMenuSearchBar) == "" then return end

        local searchText = DGS:dgsGetText(objectMenuSearchBar):lower()
        local filteredObjects = {}
        for _, object in ipairs(allObjects) do
            if object.name:lower():find(searchText) or object.model:lower():find(searchText) then
                table.insert(filteredObjects, object)
            end
        end
        populateGridList(filteredObjects)
    end)

    addEventHandler("onDgsMouseClick", objectMenuSearchBar, function(button, state)
        if button == "left" and state == "down" then
            DGS:dgsSetInputMode("no_binds")
            if DGS:dgsGetText(objectMenuSearchBar) == "Search..." then
                DGS:dgsSetText(objectMenuSearchBar, "")
            end
        end
    end, false)

    addEventHandler("onDgsBlur", objectMenuSearchBar, function()
        DGS:dgsSetInputMode("allow_binds")
        if DGS:dgsGetText(objectMenuSearchBar) == "" then
            DGS:dgsSetText(objectMenuSearchBar, "Search...")
        end
    end, false)

    ------------------------------------------
    ------------ Object creation -------------
    ------------------------------------------

    local previewObject = nil
    local activeObjects = {}
    local permanentPeds = {}

    function createObjectPreview()
        local objectGridList = DGS:dgsGridListGetSelectedItem(objectMenuSelectGridList)
        local objectRow = DGS:dgsGridListGetSelectedItem(objectMenuGridList)
        if objectGridList ~= -1 then
            attachToVehicle = tonumber(DGS:dgsGridListGetItemText(objectMenuSelectGridList, objectGridList, 1))
        elseif objectGridList == -1 then
            if isElement(previewObject) then
                destroyElement(previewObject)
                previewObject = nil
            end
            if isElement(previewPed) then
                destroyElement(previewPed)
                previewPed = nil
            end
            return
        end
        local playerVehicle = getPedOccupiedVehicle(localPlayer)
        local playerVehicleModel = getElementModel(playerVehicle)
        local x, y, z = getElementPosition(playerVehicle)
        local rx, ry, rz = getElementRotation(playerVehicle)

        if attachToVehicle and playerVehicle and playerVehicleModel ~= 406 then
            local offsetX = tonumber(DGS:dgsGetText(editFields[12])) or 0
            local offsetY = tonumber(DGS:dgsGetText(editFields[13])) or 0
            local offsetZ = tonumber(DGS:dgsGetText(editFields[14])) or 0
            local rotX = tonumber(DGS:dgsGetText(editFields[15])) or 0
            local rotY = tonumber(DGS:dgsGetText(editFields[16])) or 0
            local rotZ = tonumber(DGS:dgsGetText(editFields[17])) or 0
            local scaleX = tonumber(DGS:dgsGetText(editFields[18])) or 1
            local scaleY = tonumber(DGS:dgsGetText(editFields[19])) or 1
            local scaleZ = tonumber(DGS:dgsGetText(editFields[20])) or 1
            local elementAlpha = tonumber(DGS:dgsGetText(editFields[21])) or 255
            local PedID = tonumber(DGS:dgsGetText(editFields[22])) or 0
            
            if not isElement(previewObject) then
                local isVehicle = false
                for i, vehicle in ipairs(vehicleIds) do
                    if vehicle == attachToVehicle then
                        previewObject = createVehicle(attachToVehicle, x, y, z, rx, ry, rz)
                        setVehicleEngineState(previewObject, true)
                        setVehicleOverrideLights(previewObject, 2)
                        previewPed = createPed(PedID, x, y, z)
                        warpPedIntoVehicle(previewPed, previewObject)
                        for i, aircraft in ipairs(aircraftIDs) do
                            if aircraft == attachToVehicle then
                                setVehicleLandingGearDown(previewObject, false)
                                break
                            end
                        end
                        isVehicle = true
                        break
                    end
                end
                if not isVehicle then
                    previewObject = createObject(attachToVehicle, x, y, z, rx, ry, rz)
                end
                setElementDoubleSided(previewObject, true)
                setElementCollisionsEnabled(previewObject, false)
            else
                setElementModel(previewObject, attachToVehicle)
                if isElement(previewPed) then
                    setElementModel(previewPed, PedID)
                end
            end
            
            attachElements(previewObject, playerVehicle, offsetX, offsetY, offsetZ, rotX, rotY, rotZ)
            setObjectScale(previewObject, scaleX, scaleY, scaleZ)
            setElementAlpha(previewObject, elementAlpha)
        elseif isElement(previewObject) then
            destroyElement(previewObject)
            previewObject = nil
            if isElement(previewPed) then
                destroyElement(previewPed)
            end
        end
    end
    for i = 12, 22 do
        addEventHandler("onDgsTextChange", editFields[i], createObjectPreview, false)
    end
    addEventHandler("onDgsGridListSelect", objectMenuSelectGridList, createObjectPreview)

    addEventHandler("onDgsMouseClick", buttons[5], function(key, state)
        if key == "left" and state == "up" then
            local objectGridList = DGS:dgsGridListGetSelectedItem(objectMenuSelectGridList)
            local objectRow = DGS:dgsGridListGetSelectedItem(objectMenuGridList)
            if objectGridList ~= -1 then
                objectID = tonumber(DGS:dgsGridListGetItemText(objectMenuSelectGridList, objectGridList, 1))
            else return end
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
            local playerVehicleModel = getElementModel(playerVehicle)
            local x, y, z = getElementPosition(playerVehicle)
            local rx, ry, rz = getElementRotation(playerVehicle)
            
            if playerVehicle and objectID and playerVehicleModel ~= 406 then
                local newObject = {
                    objectID = objectID,
                    offsetX = tonumber(DGS:dgsGetText(editFields[12])) or 0,
                    offsetY = tonumber(DGS:dgsGetText(editFields[13])) or 0,
                    offsetZ = tonumber(DGS:dgsGetText(editFields[14])) or 0,
                    rotX = tonumber(DGS:dgsGetText(editFields[15])) or 0,
                    rotY = tonumber(DGS:dgsGetText(editFields[16])) or 0,
                    rotZ = tonumber(DGS:dgsGetText(editFields[17])) or 0,
                    scaleX = tonumber(DGS:dgsGetText(editFields[18])) or 1,
                    scaleY = tonumber(DGS:dgsGetText(editFields[19])) or 1,
                    scaleZ = tonumber(DGS:dgsGetText(editFields[20])) or 1,
                    elementAlpha = tonumber(DGS:dgsGetText(editFields[21])) or 255,
                    PedID = tonumber(DGS:dgsGetText(editFields[22])) or 0
                }

                local isVehicle = false
                for i, vehicle in ipairs(vehicleIds) do
                    if vehicle == objectID then
                        permanentObject = createVehicle(objectID, x, y, z, rx, ry, rz)
                        setVehicleEngineState(permanentObject, true)
                        setVehicleOverrideLights(permanentObject, 2)
                        permanentPed = createPed(newObject.PedID, x, y, z)
                        warpPedIntoVehicle(permanentPed, permanentObject)
                        table.insert(permanentPeds, permanentPed)
                        for i, aircraft in ipairs(aircraftIDs) do
                            if aircraft == objectID then
                                setVehicleLandingGearDown(permanentObject, false)
                                break
                            end
                        end
                        isVehicle = true
                        break
                    end
                end
                if not isVehicle then
                    permanentObject = createObject(objectID, 0, 0, 0, 0, 0, 0)
                    setObjectScale(permanentObject, newObject.scaleX, newObject.scaleY, newObject.scaleZ)
                end
                setElementDoubleSided(permanentObject, true)
                setElementCollisionsEnabled(permanentObject, false)
                setElementAlpha(permanentObject, newObject.elementAlpha)
                attachElements(permanentObject, playerVehicle, newObject.offsetX, newObject.offsetY, newObject.offsetZ, newObject.rotX, newObject.rotY, newObject.rotZ)

                table.insert(objectsAttachedToVehicle, newObject)
                activeObjects[#objectsAttachedToVehicle] = permanentObject

                updateObjectList()

                DGS:dgsGridListSetSelectedItem(objectMenuGridList, -1)
            end
        end
    end, false)

    addEventHandler("onDgsMouseClick", buttons[6], function(key, state)
        if key == "left" and state == "up" then
            local selectedRow = DGS:dgsGridListGetSelectedItem(objectMenuGridList)
            if selectedRow ~= -1 then
                local object = objectsAttachedToVehicle[selectedRow]
                if object then
                    local permanentObject = activeObjects[selectedRow]
                    if isElement(permanentObject) then
                        destroyElement(permanentObject)
                    end
                    if isElement(permanentPeds[selectedRow]) then
                        destroyElement(permanentPeds[selectedRow])
                        table.remove(permanentPeds, selectedRow)
                    end
                    table.remove(objectsAttachedToVehicle, selectedRow)
                    table.remove(activeObjects, selectedRow)
                    updateObjectList()
                end
            end
        end
    end, false)

    addEventHandler("onDgsMouseClick", buttons[7], function(key, state)
        if key == "left" and state == "up" then
            for i, object in ipairs(activeObjects) do
                if isElement(object) then
                    destroyElement(object)
                end
            end
            for i, ped in ipairs(permanentPeds) do
                if isElement(ped) then
                    destroyElement(ped)
                end
            end
            objectsAttachedToVehicle = {}
            activeObjects = {}
            permanentPeds = {}
            updateObjectList()
        end
    end, false)
    
    function updateObjectList()
        DGS:dgsGridListClear(objectMenuGridList)
        for i, object in ipairs(objectsAttachedToVehicle) do
            local row = DGS:dgsGridListAddRow(objectMenuGridList)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 1, object.objectID, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 2, object.PedID, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 3, object.offsetX, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 4, object.offsetY, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 5, object.offsetZ, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 6, object.rotX, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 7, object.rotY, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 8, object.rotZ, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 9, object.scaleX, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 10, object.scaleY, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 11, object.scaleZ, false, false)
            DGS:dgsGridListSetItemText(objectMenuGridList, row, 12, object.elementAlpha, false, false)
        end
    end

    ------------------------------------------
    --------- Create the effect menu ---------
    ------------------------------------------

    effectMenu = DGS:dgsCreateWindow(declare.sPosX + (declare.sWidth / 2), declare.sPosY + declare.sWidth * 0.675, declare.sWidth * 3, declare.sHeight / 3.3, "Effect settings", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(effectMenu, false)
    DGS:dgsSetVisible(effectMenu, false)

    effectMenuGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.width + declare.spacing * 2 + declare.width * 1.25, declare.marginTop, declare.width * 1.25, declare.sHeight / 4.65 - declare.marginTop - declare.marginBottom, false, effectMenu)
    DGS:dgsGridListSetSortEnabled(effectMenuGridList, false)
    DGS:dgsGridListAddColumn(effectMenuGridList, "effectID ", 0.2)
    DGS:dgsGridListAddColumn(effectMenuGridList, "offsetX", 0.2)
    DGS:dgsGridListAddColumn(effectMenuGridList, "offsetY", 0.2)
    DGS:dgsGridListAddColumn(effectMenuGridList, "offsetZ", 0.2)
    DGS:dgsGridListAddColumn(effectMenuGridList, "rotX", 0.2)
    DGS:dgsGridListAddColumn(effectMenuGridList, "rotY", 0.2)
    DGS:dgsGridListAddColumn(effectMenuGridList, "rotZ", 0.2)
    DGS:dgsGridListAddColumn(effectMenuGridList, "Effect Speed", 0.2)
    DGS:dgsGridListAddColumn(effectMenuGridList, "Effect Density", 0.2)

    effectMenuSelectGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.width + declare.spacing, declare.marginTop, declare.width * 1.25, declare.sHeight / 4.65 - declare.marginTop - declare.marginBottom, false, effectMenu)
    DGS:dgsGridListSetSortEnabled(effectMenuSelectGridList, false)
    DGS:dgsGridListAddColumn(effectMenuSelectGridList, "Effect Name", 1)
    for i, effect in ipairs(effectNames) do
        local row = DGS:dgsGridListAddRow(effectMenuSelectGridList)
        DGS:dgsGridListSetItemText(effectMenuSelectGridList, row, 1, effect, false, false)
    end

    for i, effectArgument in ipairs(effectArguments) do
        local effectArgumentName = effectArgument.name
        local effectArgumentToolTip = effectArgument.toolTip
        local effectArgumentType = effectArgument.type
        local effectArgumentText = effectArgument.text
        local y = declare.marginTop + (i - 1) * (declare.height + declare.spacing)

        if effectArgumentType == "string" or effectArgumentType == "float" or effectArgumentType == "integer" then
            local argumentEdit = DGS:dgsCreateEdit(declare.marginLeft, y, declare.width, declare.height, effectArgumentText, false, effectMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentEdit, effectArgumentToolTip)
            table.insert(editFields, argumentEdit)

            addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    if DGS:dgsGetText(argumentEdit) == effectArgumentText then
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end
            end, false)

            addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    DGS:dgsSetText(argumentEdit, "")
                end
            end, false)
        
            addEventHandler("onDgsBlur", argumentEdit, function()
                DGS:dgsSetInputMode("allow_binds")
                local playerVehicle = getPedOccupiedVehicle(localPlayer)
                local empty = DGS:dgsGetText(argumentEdit) == ""
                if effectArgumentType == "float" or effectArgumentType == "integer" then
                    local value = tonumber(DGS:dgsGetText(argumentEdit))
                    if not value or empty then
                        DGS:dgsSetText(argumentEdit, effectArgumentText)
                    end
                elseif empty then
                    DGS:dgsSetText(argumentEdit, effectArgumentText)
                else return end
            end, false)
        elseif effectArgumentType == "boolean" then
            y = y + declare.height / 2
            local argumentSwitch = DGS:dgsCreateSwitchButton(declare.marginLeft + declare.width / 4, y, declare.width / 2, declare.height / 2, "True", "False", false, false, effectMenu)
            local argumentSwitchLabel = DGS:dgsCreateLabel(declare.marginLeft, y - ((declare.height / 2) + (declare.spacing / 2)), (declare.width / 3) - declare.spacing / 3, declare.height, effectArgumentText, false, effectMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentSwitch, effectArgumentToolTip)
            table.insert(switchButtons, argumentSwitch)
            if effectArgumentName == "destroyVehicle" then
                DGS:dgsSwitchButtonSetState(argumentSwitch, true)
            end
        elseif effectArgumentType == "table" then
            if effectArgumentName == "attachEffectToVehicleRotOffset" then
                labels = {"rotX", "rotY", "rotZ"}
            else
                labels = {"offsetX", "offsetY", "offsetZ"}
            end
            for j = 0, 2 do
                local label = labels[j + 1]
                local argumentEdit = DGS:dgsCreateEdit((declare.marginLeft) + ((j * declare.width / 3) + (j * declare.spacing / 3)), y, (declare.width / 3) - declare.spacing / 3, declare.height, label, false, effectMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, argumentEdit, effectArgumentToolTip)
                table.insert(editFields, argumentEdit)

                addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        if DGS:dgsGetText(argumentEdit) == label then
                            DGS:dgsSetText(argumentEdit, "")
                        end
                    end
                end, false)

                addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end, false)

                addEventHandler("onDgsBlur", argumentEdit, function()
                    DGS:dgsSetInputMode("allow_binds")
                    if DGS:dgsGetText(argumentEdit) == "" then
                        DGS:dgsSetText(argumentEdit, label)
                    end
                end, false)
            end
        elseif effectArgumentType == "selectable" then
            local argumentComboBox = DGS:dgsCreateComboBox(declare.marginLeft, y, declare.width, declare.height, effectArgumentText, false, effectMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentComboBox, effectArgumentToolTip)
            table.insert(selectables, argumentComboBox)
        elseif effectArgumentType == "button" then
            x = declare.marginLeft
            w = declare.width
            if effectArgumentName == "removeEffectFromList" then
                x = declare.marginLeft + declare.width + declare.spacing * 2 + declare.width * 1.25
                y = (declare.marginTop + 4 * declare.height) + declare.marginTop + 2
                w = declare.width / 1.65
            elseif effectArgumentName == "clearEffectList" then
                x = declare.marginLeft + declare.width * 1.65 + declare.spacing * 2 + declare.width * 1.25
                y = (declare.marginTop + 4 * declare.height) + declare.marginTop + 2
                w = declare.width / 1.65
            end
            local argumentButton = DGS:dgsCreateButton(x, y, w, declare.height, effectArgumentText, false, effectMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentButton, effectArgumentToolTip)
            table.insert(buttons, argumentButton)
        end
    end

    addEventHandler("onDgsMouseClick", buttons[3], function(key, state)
        if key == "left" and state == "up" then
            if DGS:dgsGetVisible(effectMenu) then
                DGS:dgsSetVisible(effectMenu, false)
                isEffectMenuOpen = false
            else
                DGS:dgsSetVisible(effectMenu, true)
                isEffectMenuOpen = true
            end
        end
    end, false)

    local currentEffect = {
        name = nil
    }
    
    function createEffectPreview()
        local effectID = DGS:dgsGridListGetSelectedItem(effectMenuSelectGridList)
        if effectID == -1 then
            if isElement(previewEffect) then
                destroyElement(previewEffect)
                previewEffect = nil
                currentEffect = {
                    name = nil
                }
            end
            return
        end
        local effectName = DGS:dgsGridListGetItemText(effectMenuSelectGridList, effectID, 1)
        local playerVehicle = getPedOccupiedVehicle(localPlayer)
        local x, y, z = getElementPosition(playerVehicle)
        local rx, ry, rz = getElementRotation(playerVehicle)

        local offsetX = tonumber(DGS:dgsGetText(editFields[23])) or 0
        local offsetY = tonumber(DGS:dgsGetText(editFields[24])) or 0
        local offsetZ = tonumber(DGS:dgsGetText(editFields[25])) or 0
        local rotX = tonumber(DGS:dgsGetText(editFields[26])) or 0
        local rotY = tonumber(DGS:dgsGetText(editFields[27])) or 0
        local rotZ = tonumber(DGS:dgsGetText(editFields[28])) or 0
        local effectSpeed = tonumber(DGS:dgsGetText(editFields[29])) or 1
        local effectDensity = tonumber(DGS:dgsGetText(editFields[30])) or 2

        if effectID ~= -1 then
            if isElement(previewEffect) and currentEffect.name ~= effectName then
                destroyElement(previewEffect)
                previewEffect = createEffect(effectName, x, y, z, rotX, rotY, rotZ, 100)
                attachEffect(previewEffect, playerVehicle, {x = offsetX, y = offsetY, z = offsetZ}, {x = rotX, y = rotY, z = rotZ})
                setEffectSpeed(previewEffect, effectSpeed)
                setEffectDensity(previewEffect, effectDensity)
            elseif not isElement(previewEffect) then
                previewEffect = createEffect(effectName, x, y, z, rotX, rotY, rotZ, 100)
                attachEffect(previewEffect, playerVehicle, {x = offsetX, y = offsetY, z = offsetZ}, {x = rotX, y = rotY, z = rotZ})
                setEffectSpeed(previewEffect, effectSpeed)
                setEffectDensity(previewEffect, effectDensity)
            else
                attachEffect(previewEffect, playerVehicle, {x = offsetX, y = offsetY, z = offsetZ}, {x = rotX, y = rotY, z = rotZ})
                setEffectSpeed(previewEffect, effectSpeed)
                setEffectDensity(previewEffect, effectDensity)
            end

            currentEffect = {
                name = effectName
            }
        elseif isElement(previewEffect) then
            destroyElement(previewEffect)
            previewEffect = nil
            currentEffect = {
                name = nil
            }
        end
    end
    for i = 23, 30 do
        addEventHandler("onDgsTextChange", editFields[i], createEffectPreview, false)
    end
    addEventHandler("onDgsGridListSelect", effectMenuSelectGridList, createEffectPreview)

    addEventHandler("onDgsMouseClick", buttons[8], function(key, state)
        if key == "left" and state == "up" then
            local effectID = DGS:dgsGridListGetSelectedItem(effectMenuSelectGridList)
            if effectID == -1 then return end
            local effectName = DGS:dgsGridListGetItemText(effectMenuSelectGridList, effectID, 1)
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
            local x, y, z = getElementPosition(playerVehicle)
            local rx, ry, rz = getElementRotation(playerVehicle)

            if effectID ~= -1 then
                local newEffect = {
                    effectID = effectID,
                    offsetX = tonumber(DGS:dgsGetText(editFields[23])) or 0,
                    offsetY = tonumber(DGS:dgsGetText(editFields[24])) or 0,
                    offsetZ = tonumber(DGS:dgsGetText(editFields[25])) or 0,
                    rotX = tonumber(DGS:dgsGetText(editFields[26])) or 0,
                    rotY = tonumber(DGS:dgsGetText(editFields[27])) or 0,
                    rotZ = tonumber(DGS:dgsGetText(editFields[28])) or 0,
                    effectSpeed = tonumber(DGS:dgsGetText(editFields[29])) or 1,
                    effectDensity = tonumber(DGS:dgsGetText(editFields[30])) or 2
                }

                local effect = createEffect(effectName, x, y, z, newEffect.rotX, newEffect.rotY, newEffect.rotZ, 100)
                setEffectDensity(effect, newEffect.effectDensity)
                setEffectSpeed(effect, newEffect.effectSpeed)
                attachEffect(effect, playerVehicle, {x = newEffect.offsetX, y = newEffect.offsetY, z = newEffect.offsetZ}, {x = newEffect.rotX, y = newEffect.rotY, z = newEffect.rotZ})

                table.insert(effectsAttachedToVehicle, newEffect)

                updateEffectList()

                DGS:dgsGridListSetSelectedItem(effectMenuGridList, -1)
            end
        end
    
    end, false)

    addEventHandler("onDgsMouseClick", buttons[9], function(key, state)
        if key == "left" and state == "up" then
            local selectedRow = DGS:dgsGridListGetSelectedItem(effectMenuGridList)
            if selectedRow ~= -1 then
                local effectData = effectsAttachedToVehicle[selectedRow]

                for effect, info in pairs(attachedEffectsPreview) do
                    if isElement(effect) and 
                       info.pos.x == effectData.offsetX and 
                       info.pos.y == effectData.offsetY and 
                       info.pos.z == effectData.offsetZ then

                        removeEventHandler("onClientElementDestroy", effect, function() attachedEffectsPreview[effect] = nil end)
                        removeEventHandler("onClientElementDestroy", info.element, function() attachedEffectsPreview[effect] = nil end)

                        attachedEffectsPreview[effect] = nil
                        destroyElement(effect)
                        break
                    end
                end
                
                table.remove(effectsAttachedToVehicle, selectedRow)

                updateEffectList()
            end
        end
    end, false)
    
    addEventHandler("onDgsMouseClick", buttons[10], function(key, state)
        if key == "left" and state == "up" then

            for effect, info in pairs(attachedEffectsPreview) do
                if isElement(effect) then
                    removeEventHandler("onClientElementDestroy", effect, function() attachedEffectsPreview[effect] = nil end)
                    removeEventHandler("onClientElementDestroy", info.element, function() attachedEffectsPreview[effect] = nil end)
                    
                    destroyElement(effect)
                end
            end
            
            attachedEffectsPreview = {}
            effectsAttachedToVehicle = {}
            
            updateEffectList()
        end
    end, false)

    function updateEffectList()
        DGS:dgsGridListClear(effectMenuGridList)
        for i, effect in ipairs(effectsAttachedToVehicle) do
            local row = DGS:dgsGridListAddRow(effectMenuGridList)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 1, effect.effectID, false, false)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 2, effect.offsetX, false, false)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 3, effect.offsetY, false, false)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 4, effect.offsetZ, false, false)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 5, effect.rotX, false, false)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 6, effect.rotY, false, false)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 7, effect.rotZ, false, false)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 8, effect.effectSpeed, false, false)
            DGS:dgsGridListSetItemText(effectMenuGridList, row, 9, effect.effectDensity, false, false)
        end
    end

    ------------------------------------------
    --------- Create the vehicle menu --------
    ------------------------------------------

    vehicleMenu = DGS:dgsCreateWindow(declare.sPosX + (declare.sWidth / 2), declare.sPosY - (declare.sHeight / 2), declare.sWidth * 3, declare.sHeight / 2.825, "Vehicle settings", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(vehicleMenu, false)
    DGS:dgsSetVisible(vehicleMenu, false)

    for i, vehicleArgument in ipairs(vehicleArguments) do
        local vehicleArgumentName = vehicleArgument.name
        local vehicleArgumentToolTip = vehicleArgument.toolTip
        local vehicleArgumentType = vehicleArgument.type
        local vehicleArgumentText = vehicleArgument.text
        local y = declare.marginTop + (i - 1) * (declare.height + declare.spacing)

        if vehicleArgumentType == "string" or vehicleArgumentType == "float" or vehicleArgumentType == "integer" then
            local argumentEdit = DGS:dgsCreateEdit(declare.marginLeft, y, declare.width, declare.height, vehicleArgumentText, false, vehicleMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentEdit, vehicleArgumentToolTip)
            table.insert(editFields, argumentEdit)

            addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    if DGS:dgsGetText(argumentEdit) == vehicleArgumentText then
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end
            end, false)

            addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    DGS:dgsSetText(argumentEdit, "")
                end
            end)

            addEventHandler("onDgsBlur", argumentEdit, function()
                DGS:dgsSetInputMode("allow_binds")
                local playerVehicle = getPedOccupiedVehicle(localPlayer)
                local empty = DGS:dgsGetText(argumentEdit) == ""
                if vehicleArgumentName == "vehicleWheelStates" then
                    local value = DGS:dgsGetText(argumentEdit)
                    if value:find(",") then
                        local wheel = split(value, ",")
                        local frontLeft = tonumber(wheel[1]) or -1
                        local rearLeft = tonumber(wheel[2]) or -1
                        local frontRight = tonumber(wheel[3]) or -1 
                        local rearRight = tonumber(wheel[4]) or -1
                        if not frontLeft or not rearLeft or not frontRight or not rearRight then
                            DGS:dgsSetText(argumentEdit, vehicleArgumentText)
                        end
                    elseif not tonumber(value) or empty then
                        DGS:dgsSetText(argumentEdit, vehicleArgumentText)
                    end
                elseif vehicleArgumentName == "vehicleWheelSize" then
                    local value = DGS:dgsGetText(argumentEdit)
                    if value:find(",") then
                        local values = split(value, ",")
                        local axle = tonumber(values[1]) or 1
                        local size = tonumber(values[2]) or 1
                        if axle == 1 then
                            axle = "front_axle"
                        elseif axle == 2 then
                            axle = "rear_axle"
                        else
                            axle = "all_wheels"
                        end
                        if not axle or not size then
                            DGS:dgsSetText(argumentEdit, vehicleArgumentText)
                        end
                    elseif not tonumber(value) or empty then
                        DGS:dgsSetText(argumentEdit, vehicleArgumentText)
                    end
                elseif vehicleArgumentType == "float" or vehicleArgumentType == "integer" then
                    local value = tonumber(DGS:dgsGetText(argumentEdit))
                    if not value or empty then
                        DGS:dgsSetText(argumentEdit, vehicleArgumentText)
                    end
                elseif empty then
                    DGS:dgsSetText(argumentEdit, vehicleArgumentText)
                else return end
            end, false)
        elseif vehicleArgumentType == "boolean" then
            y = y + declare.height / 2
            local argumentSwitch = DGS:dgsCreateSwitchButton(declare.marginLeft + declare.width / 4, y, declare.width / 2, declare.height / 2, "True", "False", false, false, vehicleMenu)
            local argumentSwitchLabel = DGS:dgsCreateLabel(declare.marginLeft, y - ((declare.height / 2) + (declare.spacing / 2)), (declare.width / 3) - declare.spacing / 3, declare.height, vehicleArgumentText, false, vehicleMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentSwitch, vehicleArgumentToolTip)
            table.insert(switchButtons, argumentSwitch)
            if vehicleArgumentName == "vehicleOverrideLights" then
                DGS:dgsSwitchButtonSetState(argumentSwitch, true)
            end
            if vehicleArgumentName == "vehicleTrailSmoke" then
                DGS:dgsSwitchButtonSetState(argumentSwitch, true)
            end
        elseif vehicleArgumentType == "table" then
            if vehicleArgumentName == "vehicleRotation" then
                labels = {"rotX", "rotY", "rotZ"}
            elseif vehicleArgumentName == "attachToVehiclePosOffset" then
                labels = {"offsetX", "offsetY", "offsetZ"}
            else
                labels = {"scaleX", "scaleY", "scaleZ"}
            end
            for j = 0, 2 do
                local label = labels[j + 1]
                local argumentEdit = DGS:dgsCreateEdit((declare.marginLeft) + ((j * declare.width / 3) + (j * declare.spacing / 3)), y, (declare.width / 3) - declare.spacing / 3, declare.height, label, false, vehicleMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, argumentEdit, vehicleArgumentToolTip)
                table.insert(editFields, argumentEdit)
        
                addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        if DGS:dgsGetText(argumentEdit) == label then
                            DGS:dgsSetText(argumentEdit, "")
                        end
                    end
                end, false)

                addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end, false)
        
                addEventHandler("onDgsBlur", argumentEdit, function()
                    DGS:dgsSetInputMode("allow_binds")
                    local empty = DGS:dgsGetText(argumentEdit) == ""
                    local value = tonumber(DGS:dgsGetText(argumentEdit))
                    if empty then
                        DGS:dgsSetText(argumentEdit, label)
                    elseif not value or empty then
                        DGS:dgsSetText(argumentEdit, label)
                    else return end
                end, false)
            end
        elseif vehicleArgumentType == "selectable" then
            local argumentComboBox = DGS:dgsCreateComboBox(declare.marginLeft, y, declare.width, declare.height, vehicleArgumentText, false, vehicleMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentComboBox, vehicleArgumentToolTip)
            table.insert(selectables, argumentComboBox)
        elseif vehicleArgumentType == "button" then
            x = declare.marginLeft
            w = declare.width
            if vehicleArgumentName == "removeObjectFromList" then
                x = declare.marginLeft + declare.width + declare.spacing * 2 + declare.width * 1.25
                y = (declare.marginTop + 4 * declare.height) + declare.marginTop * 3.65
                w = declare.width / 1.65
            elseif vehicleArgumentName == "clearObjectList" then
                x = declare.marginLeft + declare.width * 1.65 + declare.spacing * 2 + declare.width * 1.25
                y = (declare.marginTop + 4 * declare.height) + declare.marginTop * 3.65
                w = declare.width / 1.65
            end
            local argumentButton = DGS:dgsCreateButton(x, y, w, declare.height, vehicleArgumentText, false, vehicleMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentButton, vehicleArgumentToolTip)
            table.insert(buttons, argumentButton)
        end
    end

    addEventHandler("onDgsMouseClick", buttons[1], function(key, state)
        if key == "left" and state == "up" then
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
            if DGS:dgsGetVisible(vehicleMenu) then
                DGS:dgsSetVisible(vehicleMenu, false)
                isVehicleMenuOpen = false
            else
                DGS:dgsSetVisible(vehicleMenu, true)
                isVehicleMenuOpen = true
            end
        end
    end, false)

    ---------------------------------------------
    --------- Create the vehicle preview --------
    ---------------------------------------------

    vehicleComponentGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.width + declare.spacing * 2 + declare.width * 1.25, declare.marginTop, declare.width * 1.25, declare.sHeight / 4.45 - declare.marginTop - declare.marginBottom, false, vehicleMenu)
    DGS:dgsGridListSetSortEnabled(vehicleComponentGridList, false)
    DGS:dgsGridListAddColumn(vehicleComponentGridList, "Component Name", 1)

    vehicleDataGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.width + declare.spacing, declare.marginTop, declare.width * 1.25, declare.sHeight / 4.45 - declare.marginTop - declare.marginBottom, false, vehicleMenu)
    DGS:dgsGridListSetSortEnabled(vehicleDataGridList, false)
    DGS:dgsGridListAddColumn(vehicleDataGridList, "overrideLights", 0.5)
    DGS:dgsGridListAddColumn(vehicleDataGridList, "vehicleSmokeTrail", 0.5)
    DGS:dgsGridListAddColumn(vehicleDataGridList, "rotX", 0.2)
    DGS:dgsGridListAddColumn(vehicleDataGridList, "rotY", 0.2)
    DGS:dgsGridListAddColumn(vehicleDataGridList, "rotZ", 0.2)
    DGS:dgsGridListAddColumn(vehicleDataGridList, "vehicleWheelState", 0.5)
    DGS:dgsGridListAddColumn(vehicleDataGridList, "wheelSize", 0.5)
    DGS:dgsGridListAddColumn(vehicleDataGridList, "vehicleAlpha", 0.5)

    local defaultValues = {
        overrideLights = 2,
        vehicleSmokeTrail = true,
        rotX, rotY, rotZ = 0, 0, 0,
        vehicleWheelState = 0,
        wheelSize = nil,
        vehicleAlpha = 255
    }

    function updateVehicleComponentList()

        local playerVehicle = getPedOccupiedVehicle(localPlayer)
        if not playerVehicle then return end

        DGS:dgsGridListClear(vehicleComponentGridList)
        local vehicleComponents = getVehicleComponents(playerVehicle)
        if playerVehicle then
            for i in pairs (vehicleComponents) do
                local row = DGS:dgsGridListAddRow(vehicleComponentGridList)
                DGS:dgsGridListSetItemText(vehicleComponentGridList, row, 1, i, false, false)
            end
        end
    end
    addEventHandler("onClientElementModelChange", root, updateVehicleComponentList)
    addEventHandler("onClientVehicleEnter", root, updateVehicleComponentList)
    addEventHandler("onClientResourceStart", root, updateVehicleComponentList)

    function updateVehicleDataGridList()
        local playerVehicle = getPedOccupiedVehicle(localPlayer)
        if not playerVehicle then return end
        
        local playerVehicleModel = getElementModel(playerVehicle)
        DGS:dgsGridListClear(vehicleDataGridList)

        if wheelSizes[playerVehicleModel] then
            defaultValues.wheelSize = {
                front_axle = wheelSizes[playerVehicleModel].front_axle,
                rear_axle = wheelSizes[playerVehicleModel].rear_axle
            }
        else
            defaultValues.wheelSize = {
                front_axle = 1,
                rear_axle = 1
            }
        end

        local currentValues = {
            overrideLights = getVehicleOverrideLights(playerVehicle),
            vehicleSmokeTrail = isVehicleSmokeTrailEnabled(playerVehicle),
            protX, protY, protZ = DGS:dgsGetText(editFields[31]), DGS:dgsGetText(editFields[32]), DGS:dgsGetText(editFields[33]),
            vehicleWheelState = {getVehicleWheelStates(playerVehicle)},
            wheelSize = {
                front_axle = getVehicleModelWheelSize(playerVehicleModel, "front_axle"),
                rear_axle = getVehicleModelWheelSize(playerVehicleModel, "rear_axle")
            },
            vehicleAlpha = getElementAlpha(playerVehicle)
        }
        
        local row = DGS:dgsGridListAddRow(vehicleDataGridList)
        DGS:dgsGridListSetItemText(vehicleDataGridList, row, 1, tostring(currentValues.overrideLights), false, false)

        DGS:dgsGridListSetItemText(vehicleDataGridList, row, 2, tostring(currentValues.vehicleSmokeTrail), false, false)

        if DGS:dgsGetText(editFields[31]) == "rotX" then
            DGS:dgsGridListSetItemText(vehicleDataGridList, row, 3, 0, false, false)
        else
            DGS:dgsGridListSetItemText(vehicleDataGridList, row, 3, tostring(DGS:dgsGetText(editFields[31])), false, false)
        end

        if DGS:dgsGetText(editFields[32]) == "rotY" then
            DGS:dgsGridListSetItemText(vehicleDataGridList, row, 4, 0, false, false)
        else
            DGS:dgsGridListSetItemText(vehicleDataGridList, row, 4, tostring(DGS:dgsGetText(editFields[32])), false, false)
        end

        if DGS:dgsGetText(editFields[33]) == "rotZ" then
            DGS:dgsGridListSetItemText(vehicleDataGridList, row, 5, 0, false, false)
        else
            DGS:dgsGridListSetItemText(vehicleDataGridList, row, 5, tostring(DGS:dgsGetText(editFields[33])), false, false)
        end

        DGS:dgsGridListSetItemText(vehicleDataGridList, row, 6, table.concat(currentValues.vehicleWheelState, ","), false, false)
        DGS:dgsGridListSetItemText(vehicleDataGridList, row, 7, string.format("%.2f", currentValues.wheelSize.front_axle) .. ", " .. string.format("%.2f", currentValues.wheelSize.rear_axle), false, false)

        DGS:dgsGridListSetItemText(vehicleDataGridList, row, 8, tostring(currentValues.vehicleAlpha), false, false)
    end

    updateVehicleDataGridList()

    function playerVehiclePreview()
        local playerVehicle = getPedOccupiedVehicle(localPlayer)
        local playerVehicleModel = getElementModel(playerVehicle)
        if playerVehicle then

            keepPreview = DGS:dgsSwitchButtonGetState(switchButtons[6])

            local overrideLights = DGS:dgsSwitchButtonGetState(switchButtons[7])
            if overrideLights then
                overrideLights = 2
            else
                overrideLights = 1
            end
            setVehicleOverrideLights(playerVehicle, overrideLights)

            local vehicleSmokeTrail = DGS:dgsSwitchButtonGetState(switchButtons[8])
            if playerVehicleModel == 512 or playerVehicleModel == 513 then
                setVehicleSmokeTrailEnabled(playerVehicle, vehicleSmokeTrail)
            end

            local rotX, rotY, rotZ = DGS:dgsGetText(editFields[31]), DGS:dgsGetText(editFields[32]), DGS:dgsGetText(editFields[33])
            local vehicleRotation = {x = tonumber(rotX) or 0, y = tonumber(rotY) or 0, z = tonumber(rotZ) or 0}
            setElementRotation(playerVehicle, rx + vehicleRotation.x, ry + vehicleRotation.y, rz + vehicleRotation.z)

            local vehicleWheelStateText = DGS:dgsGetText(editFields[34])
            if vehicleWheelStateText:find(",") then
                local wheel = split(vehicleWheelStateText, ",")
                local frontLeft = tonumber(wheel[1]) or -1
                local rearLeft = tonumber(wheel[2]) or -1
                local frontRight = tonumber(wheel[3]) or -1 
                local rearRight = tonumber(wheel[4]) or -1
                setVehicleWheelStates(playerVehicle, frontLeft, rearLeft, frontRight, rearRight)
            else
                vehicleWheelState = tonumber(vehicleWheelStateText) or -1
                setVehicleWheelStates(playerVehicle, vehicleWheelState, vehicleWheelState, vehicleWheelState, vehicleWheelState)
            end

            local wheelSizeText = DGS:dgsGetText(editFields[35])
            local currentWheelSizes = wheelSizes[playerVehicleModel]
            if wheelSizeText:find(",") then
                local value = split(wheelSizeText, ",")
                local axle = tonumber(value[1]) or 1
                local size = tonumber(value[2]) or 1
                if axle == 1 then
                    axle = "front_axle"
                elseif axle == 2 then
                    axle = "rear_axle"
                else
                    axle = "all_wheels"
                end
                if tonumber(size) > 0 then
                    setVehicleModelWheelSize(playerVehicleModel, axle, size)
                end
            elseif (wheelSizeText == "" or wheelSizeText == "Set wheel size") then
                if currentWheelSizes then
                    setVehicleModelWheelSize(playerVehicleModel, "front_axle", currentWheelSizes.front_axle)
                    setVehicleModelWheelSize(playerVehicleModel, "rear_axle", currentWheelSizes.rear_axle)
                end
            else
                wheelSizeText = tonumber(wheelSizeText) or 1
                if wheelSizeText > 0 then
                    setVehicleModelWheelSize(playerVehicleModel, "all_wheels", wheelSizeText)
                end
            end

            local vehicleAlpha = tonumber(DGS:dgsGetText(editFields[36])) or 255
            setElementAlpha(playerVehicle, vehicleAlpha)
            setElementAlpha(localPlayer, vehicleAlpha)
        end
        updateVehicleDataGridList()
    end
    for i = 31, 36 do
        addEventHandler("onDgsTextChange", editFields[i], playerVehiclePreview, false)
    end
    for i = 6, 8 do
        addEventHandler("onDgsSwitchButtonStateChange", switchButtons[i], playerVehiclePreview, false)
    end

    addEventHandler("onClientElementModelChange", root, function()
        local playerVehicle = getPedOccupiedVehicle(localPlayer)
        local playerVehicleModel = getElementModel(playerVehicle)
        if playerVehicle then
            currentWheelSizes = getVehicleModelWheelSize(playerVehicleModel)
        end
    end)

    addEventHandler ( "onClientPreRender", root, function()
        if isPedInVehicle ( localPlayer ) and getPedOccupiedVehicle ( localPlayer ) then
            local veh = getPedOccupiedVehicle ( localPlayer )
            if veh and DGS:dgsGetVisible(vehicleMenu) then
                for v in pairs ( getVehicleComponents(veh) ) do
                    local x,y,z = getVehicleComponentPosition ( veh, v, "world" )
                    local wx,wy,wz = getScreenFromWorldPosition ( x, y, z )
                    if wx and wy then
                        dxDrawText ( v, wx -1, wy -1, 0 -1, 0 -1, tocolor(0,0,0), 1, "default-bold" )
                        dxDrawText ( v, wx +1, wy -1, 0 +1, 0 -1, tocolor(0,0,0), 1, "default-bold" )
                        dxDrawText ( v, wx -1, wy +1, 0 -1, 0 +1, tocolor(0,0,0), 1, "default-bold" )
                        dxDrawText ( v, wx +1, wy +1, 0 +1, 0 +1, tocolor(0,0,0), 1, "default-bold" )
                        dxDrawText ( v, wx, wy, 0, 0, tocolor(0,255,255), 1, "default-bold" )
                    end
                end
            end
        end
    end)

    ------------------------------------------
    ---------- Create the text menu ----------
    ------------------------------------------
    textMenu = DGS:dgsCreateWindow(declare.sPosX - (declare.sWidth) * 3.5, declare.sPosY - declare.sWidth / 2, declare.sWidth * 3, declare.sHeight / 3, "Text settings", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(textMenu, false)
    DGS:dgsSetVisible(textMenu, false)

    textMenuGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.width + declare.spacing * 2 + declare.width * 1.25, declare.marginTop, declare.width * 1.25, declare.sHeight / 3.85 - declare.marginTop - declare.marginBottom, false, textMenu)
    DGS:dgsGridListSetSortEnabled(textMenuGridList, false)
    DGS:dgsGridListAddColumn(textMenuGridList, "Text", 0.3)
    DGS:dgsGridListAddColumn(textMenuGridList, "offsetX", 0.2)
    DGS:dgsGridListAddColumn(textMenuGridList, "offsetY", 0.2)
    DGS:dgsGridListAddColumn(textMenuGridList, "offsetZ", 0.2)
    DGS:dgsGridListAddColumn(textMenuGridList, "Size", 0.2)
    DGS:dgsGridListAddColumn(textMenuGridList, "Font", 0.5)
    DGS:dgsGridListAddColumn(textMenuGridList, "Color", 0.5)
    DGS:dgsGridListAddColumn(textMenuGridList, "Distance", 0.3)
    DGS:dgsGridListAddColumn(textMenuGridList, "Color Coded", 0.3)

    for i, textArgument in ipairs(textArguments) do
        local textArgumentName = textArgument.name
        local textArgumentToolTip = textArgument.toolTip
        local textArgumentType = textArgument.type
        local textArgumentText = textArgument.text
        local y = declare.marginTop + (i - 1) * (declare.height + declare.spacing)

        if textArgumentType == "string" or textArgumentType == "float" or textArgumentType == "integer" then
            local argumentEdit = DGS:dgsCreateEdit(declare.marginLeft, y, declare.width, declare.height, textArgumentText, false, textMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentEdit, textArgumentToolTip)
            table.insert(editFields, argumentEdit)

            addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    if DGS:dgsGetText(argumentEdit) == textArgumentText then
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end
            end, false)

            addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    DGS:dgsSetText(argumentEdit, "")
                end
            end)

            addEventHandler("onDgsBlur", argumentEdit, function()
                DGS:dgsSetInputMode("allow_binds")
                local empty = DGS:dgsGetText(argumentEdit) == ""
                if textArgumentName == "textColor" then
                    local value = DGS:dgsGetText(argumentEdit)
                    if value:find(",") then
                        local color = split(value, ",")
                        local r = tonumber(color[1]) or 255
                        local g = tonumber(color[2]) or 255
                        local b = tonumber(color[3]) or 255
                        local a = tonumber(color[4]) or 255
                        if not r or not g or not b or not a then
                            DGS:dgsSetText(argumentEdit, textArgumentText)
                        end
                    elseif not tonumber(value) or empty then
                        DGS:dgsSetText(argumentEdit, textArgumentText)
                    end
                elseif textArgumentType == "float" or textArgumentType == "integer" then
                    local value = tonumber(DGS:dgsGetText(argumentEdit))
                    if not value or empty then
                        DGS:dgsSetText(argumentEdit, textArgumentText)
                    end
                elseif empty then
                    DGS:dgsSetText(argumentEdit, textArgumentText)
                else return end
            end, false)
        elseif textArgumentType == "boolean" then
            y = y - (declare.height / 2) * 4
            x = declare.marginLeft + declare.spacing * 2 + declare.width * 1.25 - declare.spacing * 2
            local argumentSwitch = DGS:dgsCreateSwitchButton(x + declare.width / 4, y, declare.width / 2, declare.height / 2, "True", "False", false, false, textMenu)
            local argumentSwitchLabel = DGS:dgsCreateLabel(x, y - ((declare.height / 2) + (declare.spacing / 2)), (declare.width / 3) - declare.spacing / 3, declare.height, textArgumentText, false, textMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentSwitch, textArgumentToolTip)
            table.insert(switchButtons, argumentSwitch)
        elseif textArgumentType == "table" then
            labels = {"offsetX", "offsetY", "offsetZ"}
            for j = 0, 2 do
                local label = labels[j + 1]
                local argumentEdit = DGS:dgsCreateEdit((declare.marginLeft) + ((j * declare.width / 3) + (j * declare.spacing / 3)), y, (declare.width / 3) - declare.spacing / 3, declare.height, label, false, textMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, argumentEdit, textArgumentToolTip)
                table.insert(editFields, argumentEdit)
        
                addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        if DGS:dgsGetText(argumentEdit) == label then
                            DGS:dgsSetText(argumentEdit, "")
                        end
                    end
                end, false)

                addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end, false)
        
                addEventHandler("onDgsBlur", argumentEdit, function()
                    DGS:dgsSetInputMode("allow_binds")
                    if DGS:dgsGetText(argumentEdit) == "" then
                        DGS:dgsSetText(argumentEdit, label)
                    end
                end, false)
            end
        elseif textArgumentType == "selectable" then
            local argumentComboBox = DGS:dgsCreateComboBox(declare.marginLeft, y, declare.width, declare.height, textArgumentText, false, textMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentComboBox, textArgumentToolTip)
            table.insert(selectables, argumentComboBox)
        elseif textArgumentType == "button" then
            x = declare.marginLeft + declare.spacing * 2 + declare.width * 1.25 - declare.spacing * 2
            y = (declare.marginTop + 4 * declare.height) + declare.marginTop * 3.65
            w = declare.width
            if textArgumentName == "removeTextFromList" then
                x = declare.marginLeft + declare.width + declare.spacing * 2 + declare.width * 1.25
                y = (declare.marginTop + 4 * declare.height) + declare.marginTop * 3.65
                w = declare.width / 1.65
            elseif textArgumentName == "clearTextList" then
                x = declare.marginLeft + declare.width * 1.65 + declare.spacing * 2 + declare.width * 1.25
                y = (declare.marginTop + 4 * declare.height) + declare.marginTop * 3.65
                w = declare.width / 1.65
            end
            local argumentButton = DGS:dgsCreateButton(x, y, w, declare.height, textArgumentText, false, textMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentButton, textArgumentToolTip)
            table.insert(buttons, argumentButton)
        end
    end

    addEventHandler("onDgsMouseClick", buttons[4], function(key, state)
        if key == "left" and state == "up" then
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
            if DGS:dgsGetVisible(textMenu) then
                DGS:dgsSetVisible(textMenu, false)
                isTextMenuOpen = false
            else
                DGS:dgsSetVisible(textMenu, true)
                isTextMenuOpen = true
            end
        end
    end, false)

    addFontsToComboBox()

    ------------------------------------------
    -------- Create the text preview ---------
    ------------------------------------------
    local previewTexts = {}
    local isTextPreviewActive = false
    function updateTextPreviewData()

        local text = tostring(DGS:dgsGetText(editFields[37]))
        if text == "" or text == "Set your text/name" then
            previewTexts = {}
            isTextPreviewActive = false
            return
        end

        local offsetX = tonumber(DGS:dgsGetText(editFields[38])) or 0
        local offsetY = tonumber(DGS:dgsGetText(editFields[39])) or 0
        local offsetZ = tonumber(DGS:dgsGetText(editFields[40])) or 0
        local size = tonumber(DGS:dgsGetText(editFields[41])) or 2
        local fontComboBox = DGS:dgsComboBoxGetSelectedItem(selectables[1])
        if fontComboBox == -1 then
            font = "default"
        else
            font = tostring(DGS:dgsComboBoxGetItemText(selectables[1], fontComboBox))
        end 
        local colorText = DGS:dgsGetText(editFields[42])
        if colorText:find(",") then
            local colorText = split(colorText, ",")
            local r = tonumber(colorText[1]) or 255
            local g = tonumber(colorText[2]) or 255
            local b = tonumber(colorText[3]) or 255
            local a = tonumber(colorText[4]) or 255
            color = tocolor(r, g, b, a)
        else
            color = tocolor(255, 255, 255, 255)
        end
        local distance = tonumber(DGS:dgsGetText(editFields[43])) or 20
        local colorCoded = DGS:dgsSwitchButtonGetState(switchButtons[9]) or false

        previewTexts = {}
        
        if text and #text > 0 then
            table.insert(previewTexts, {
                text = text, 
                offsetX = offsetX, 
                offsetY = offsetY, 
                offsetZ = offsetZ, 
                size = size, 
                font = font, 
                color = color, 
                distance = distance, 
                colorCoded = colorCoded
            })
            isTextPreviewActive = true
        else
            isTextPreviewActive = false
        end
    end
    for i = 37, 43 do
        addEventHandler("onDgsTextChange", editFields[i], updateTextPreviewData, false)
    end
    addEventHandler("onDgsSwitchButtonStateChange", switchButtons[9], updateTextPreviewData, false)
    addEventHandler("onDgsComboBoxStateChange", selectables[1], updateTextPreviewData, false)

    function addTextToGridList()
        local text = tostring(DGS:dgsGetText(editFields[37]))
        local offsetX = tonumber(DGS:dgsGetText(editFields[38])) or 0
        local offsetY = tonumber(DGS:dgsGetText(editFields[39])) or 0
        local offsetZ = tonumber(DGS:dgsGetText(editFields[40])) or 0
        local size = tonumber(DGS:dgsGetText(editFields[41])) or 2
        local fontComboBox = DGS:dgsComboBoxGetSelectedItem(selectables[1])
        if fontComboBox == -1 then
            font = "default"
        else
            font = tostring(DGS:dgsComboBoxGetItemText(selectables[1], fontComboBox))
        end 
        local colorText = DGS:dgsGetText(editFields[42])
        if colorText:find(",") then
            local colorText = split(colorText, ",")
            local r = tonumber(colorText[1]) or 255
            local g = tonumber(colorText[2]) or 255
            local b = tonumber(colorText[3]) or 255
            local a = tonumber(colorText[4]) or 255
            color = r..", "..g..", "..b..", "..a
        else
            color = "255, 255, 255, 255"
        end
        local distance = tonumber(DGS:dgsGetText(editFields[43])) or 20
        local colorCoded = tostring(DGS:dgsSwitchButtonGetState(switchButtons[9])) or "false"

        if text and #text > 0 then
            local row = DGS:dgsGridListAddRow(textMenuGridList)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 1, text, false, false)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 2, offsetX, false, false)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 3, offsetY, false, false)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 4, offsetZ, false, false)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 5, size, false, false)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 6, font, false, false)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 7, color, false, false)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 8, distance, false, false)
            DGS:dgsGridListSetItemText(textMenuGridList, row, 9, colorCoded, false, false)
        end
    end

    function removeTextFromGridList()
        local selectedRow = DGS:dgsGridListGetSelectedItem(textMenuGridList)
        if selectedRow ~= -1 then
            DGS:dgsGridListRemoveRow(textMenuGridList, selectedRow)
        end
    end

    addEventHandler("onClientPreRender", root, function()
        if isTextPreviewActive then
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
            if playerVehicle then
                local x, y, z = getElementPosition(playerVehicle)
                
                for i, data in ipairs(previewTexts) do
                    dxDraw3DText(
                        data.text, 
                        x + data.offsetX, 
                        y + data.offsetY, 
                        z + data.offsetZ, 
                        data.size, 
                        data.font, 
                        data.color, 
                        data.distance, 
                        data.colorCoded
                    )
                end
            end
        end
    end)

    addEventHandler("onDgsMouseClick", buttons[11], function(key, state)
        if key == "left" and state == "up" then

            local text = tostring(DGS:dgsGetText(editFields[37]))
            if text == "" or text == "Set your text/name" then
                return
            end

            local offsetX = tonumber(DGS:dgsGetText(editFields[38])) or 0
            local offsetY = tonumber(DGS:dgsGetText(editFields[39])) or 0
            local offsetZ = tonumber(DGS:dgsGetText(editFields[40])) or 0
            local size = tonumber(DGS:dgsGetText(editFields[41])) or 2
            local fontComboBox = DGS:dgsComboBoxGetSelectedItem(selectables[1])
            if fontComboBox == -1 then
                font = "default"
            else
                font = tostring(DGS:dgsComboBoxGetItemText(selectables[1], fontComboBox))
            end 
            local colorText = DGS:dgsGetText(editFields[42])
            if colorText:find(",") then
                local colorText = split(colorText, ",")
                r = tonumber(colorText[1]) or 255
                g = tonumber(colorText[2]) or 255
                b = tonumber(colorText[3]) or 255
                a = tonumber(colorText[4]) or 255
                color = tocolor(r, g, b, a)
            else
                color = tocolor(255, 255, 255, 255)
            end
            local distance = tonumber(DGS:dgsGetText(editFields[43])) or 20
            local colorCoded = DGS:dgsSwitchButtonGetState(switchButtons[9]) or false

            if text and #text > 0 then
                table.insert(textsAttachedToVehicle, {
                    text = text, 
                    offsetX = offsetX, 
                    offsetY = offsetY, 
                    offsetZ = offsetZ, 
                    size = size, 
                    font = font, 
                    color = color,
                    colorRGBA = {r = r, g = g, b = b, a = a}, 
                    distance = distance, 
                    colorCoded = colorCoded
                })
            end
            addTextToGridList()
        end
    end, false)

    addEventHandler("onClientPreRender", root, function()
        local playerVehicle = getPedOccupiedVehicle(localPlayer)
        if playerVehicle then
            local x, y, z = getElementPosition(playerVehicle)
            for i, data in ipairs(textsAttachedToVehicle) do
                dxDraw3DText(
                    data.text, 
                    x + data.offsetX, 
                    y + data.offsetY, 
                    z + data.offsetZ, 
                    data.size, 
                    data.font, 
                    data.color, 
                    data.distance, 
                    data.colorCoded
                )
            end
        end
    end)

    addEventHandler("onDgsMouseClick", buttons[12], function(key, state)
        if key == "left" and state == "up" then
            local selectedRow = DGS:dgsGridListGetSelectedItem(textMenuGridList)
            if selectedRow ~= -1 then
                local row = DGS:dgsGridListGetItemText(textMenuGridList, selectedRow, 1)
                for i, text in ipairs(textsAttachedToVehicle) do
                    if text.text == row then
                        table.remove(textsAttachedToVehicle, i)
                        removeTextFromGridList()
                        break
                    end
                end
            end
        end
    end, false)

    addEventHandler("onDgsMouseClick", buttons[13], function(key, state)
        if key == "left" and state == "up" then
            textsAttachedToVehicle = {}
            DGS:dgsGridListClear(textMenuGridList)
            updateTextPreviewData()
        end
    end, false)

    ------------------------------------------
    --------- Create the import menu ---------
    ------------------------------------------

    --paths menu
    pathsMenu = DGS:dgsCreateWindow(declare.sPosX - (declare.sWidth / 2) - declare.pathMenuWidth - declare.spacing + declare.marginRight * 2, declare.sPosY - (declare.sHeight / 2), declare.pathMenuWidth - declare.marginRight * 2, declare.sHeight / 2, "Path and marker selection", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    pathsComboBox = DGS:dgsCreateComboBox(declare.marginLeft, declare.marginTop * 3 + declare.height * 5 + declare.spacing * 2, declare.width * 1.25, declare.height, "Select one of your paths", false, pathsMenu)

    DGS:dgsWindowSetSizable(pathsMenu, false)
    --marker gridlist and searchbar
    markerGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.width * 1.25 + declare.spacing, declare.marginTop + declare.height + declare.spacing, declare.width * 1.25, declare.height * 5, false, pathsMenu)
    markerSearchBar = DGS:dgsCreateEdit(declare.marginLeft + declare.width * 1.25 + declare.spacing, declare.marginTop, declare.width - declare.spacing - declare.marginRight * 2, declare.height, "Search for your marker", false, pathsMenu)
    refreshButton = DGS:dgsCreateButton(declare.marginLeft + declare.width * 1.25 + declare.spacing, declare.marginTop * 3 + declare.height * 5 + declare.spacing * 2, declare.width - declare.spacing - declare.marginRight * 2, declare.height, "Refresh", false, pathsMenu)
    local refreshTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(refreshTooltip, refreshButton, "Refreshes the marker, map and path lists.")

    --maps gridlist and searchbar
    mapsGridList = DGS:dgsCreateGridList(declare.marginLeft, declare.marginTop + declare.height + declare.spacing, declare.width * 1.25, declare.height * 5, false, pathsMenu)
    searchBar = DGS:dgsCreateEdit(declare.marginLeft, declare.marginTop, declare.width - declare.spacing - declare.marginRight * 2, declare.height, "Search for your map", false, pathsMenu)
    saveButton = DGS:dgsCreateButton(declare.marginLeft, declare.marginTop * 3 + declare.height * 7 + declare.spacing * 4, (declare.width * 1.25), declare.height, "Save to map/resource", false, pathsMenu)
    local saveButtonTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(saveButtonTooltip, saveButton, "Saves the current memo content to the selected map. You need to select a map before you can save.\nNote: This will create everything necessary inside your map folder. One click and you are done!\nDisclaimer: this might take a lot longer on slower servers!")

    --create button for file_list.json
    addButton = DGS:dgsCreateButton(declare.marginLeft, declare.marginTop * 3 + declare.height * 6 + declare.spacing * 3, ((declare.width * 1.25) - declare.spacing) / 2, declare.height, "Add path/s to memo", false, pathsMenu)
    local addButtonTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(addButtonTooltip, addButton, "Adds the selected path to the memo. You can add multiple paths to the memo before you decide to save.\nNote: You need to select a marker and a path before you can add it to the memo.\nInfo: You can use one marker for multiple paths by selecting the marker that has already been added.")

    --delete button for file_list.json
    delButton = DGS:dgsCreateButton(declare.marginLeft + (declare.width * 1.25) / 2, declare.marginTop * 3 + declare.height * 6 + declare.spacing * 3, (declare.width * 1.25) / 2, declare.height, "Delete path", false, pathsMenu)
    local delButtonTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(delButtonTooltip, delButton, "Deletes the selected path from the file list (ComboBox). You need to select a path before you can delete it.")

    --[[create resource button
    resourceButton = DGS:dgsCreateButton(declare.marginLeft + (declare.width * 1.25) / 2 + declare.spacing / 2, declare.marginTop * 3 + declare.height * 7 + declare.spacing * 4, (declare.width * 1.25) / 2 - declare.spacing / 2, declare.height, "Create a resource", false, pathsMenu)
    local resourceButtonTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(resourceButtonTooltip, resourceButton, "Creates a resource with the selected path and marker. You need to have something present in the memo to create a resource.")--]]
    
    --create checkbox for flushEnabled
    flushEnabledCheckBox = DGS:dgsCreateCheckBox(declare.marginLeft + declare.width * 1.25 + declare.spacing, declare.marginTop * 3 + declare.height * 6 + declare.spacing * 3.5, declare.width - declare.spacing - declare.marginRight * 2, declare.height, "Override existing files", false, false, pathsMenu)
    local flushEnabledCheckBoxTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(flushEnabledCheckBoxTooltip, flushEnabledCheckBox, "Choose if you want to override the existing files or not. Default is off.\nNote: deletes all files in the paths folder in the current resource/map if checked!")
    
    --create checkbox for memo set read only
    readOnlyCheckBox = DGS:dgsCreateCheckBox(declare.marginLeft + declare.width * 1.25 + declare.spacing, declare.marginTop * 3 + declare.height * 7 + declare.spacing * 4.5, declare.width - declare.spacing - declare.marginRight * 2, declare.height, "Set memo read only", false, false, pathsMenu)
    local readOnlyCheckBoxTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(readOnlyCheckBoxTooltip, readOnlyCheckBox, "Choose if you want to set the memo to read only. Default is off.")
    
    --resource creation menu
    --[[
    createResourceMenu = DGS:dgsCreateWindow(declare.sPosX - (declare.sWidth / 2), (declare.sHeight / 2), declare.sWidth, declare.sHeight / 4, "Resource creation", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(createResourceMenu, false)
    DGS:dgsSetVisible(createResourceMenu, false)

    createResourceEdit = DGS:dgsCreateEdit(declare.marginLeft, declare.marginTop * 2, declare.width, declare.height, "Resource name", false, createResourceMenu)
    createResourceButton = DGS:dgsCreateButton(declare.marginLeft, declare.marginTop * 4 + declare.spacing, declare.width, declare.height, "Confirm", false, createResourceMenu)
    --]]
    --add saved files from file_list.json to the combobox
    addFilesToComboBox()

    ---------------------------------------
    -------- Path menu search bars --------
    ---------------------------------------

    --Search bar for maps
    addEventHandler("onDgsTextChange", searchBar, function()

        if DGS:dgsGetText(searchBar) == "Search for your map" then return end

        local searchText = DGS:dgsGetText(searchBar):lower()
        DGS:dgsGridListClear(mapsGridList)


        for i, name in ipairs(mapNames) do
            if searchText == "" or name:lower():find(searchText) then
                local row = DGS:dgsGridListAddRow(mapsGridList)
                DGS:dgsGridListSetItemText(mapsGridList, row, 1, name, false, false)
            end
        end
    end)

    addEventHandler("onDgsMouseClick", searchBar, function(button, state)
        if button == "left" and state == "down" then
            DGS:dgsSetInputMode("no_binds")
            DGS:dgsSetText(searchBar, "")
        end
    end, false)

    addEventHandler("onDgsBlur", searchBar, function()
        DGS:dgsSetInputMode("allow_binds")
        if DGS:dgsGetText(searchBar) == "" then
            DGS:dgsSetText(searchBar, "Search for your map")
        end
    end, false)
    

    --Search bar for markers
    addEventHandler("onDgsTextChange", markerSearchBar, function()

        if DGS:dgsGetText(markerSearchBar) == "Search for your marker" then return end

        local searchText = DGS:dgsGetText(markerSearchBar):lower()
        DGS:dgsGridListClear(markerGridList)


        for i, markerData in ipairs(markers) do
            if markerData.displayText:lower():find(searchText) then
                local row = DGS:dgsGridListAddRow(markerGridList)
                DGS:dgsGridListSetItemText(markerGridList, row, 1, markerData.displayText, false, false)
            end
        end
    end)

    addEventHandler("onDgsMouseClick", markerSearchBar, function(button, state)
        if button == "left" and state == "down" then
            DGS:dgsSetInputMode("no_binds")
            DGS:dgsSetText(markerSearchBar, "")
        end
    end, false)

    addEventHandler("onDgsBlur", markerSearchBar, function()
        DGS:dgsSetInputMode("allow_binds")
        if DGS:dgsGetText(markerSearchBar) == "" then
            DGS:dgsSetText(markerSearchBar, "Search for your marker")
        end
    end, false)

    --Add button for adding files to the main memo

    -- Handle received file list from server
    addEvent("onReceiveFileList", true)
    addEventHandler("onReceiveFileList", localPlayer, function(fileList)
        local selectedPath = DGS:dgsComboBoxGetSelectedItem(pathsComboBox)
        local selectedMarker = DGS:dgsGridListGetSelectedItem(markerGridList)

        if selectedMarker == -1 and DGS:dgsSwitchButtonGetState(switchButtons[11]) == true then
            selectedPath = DGS:dgsComboBoxGetSelectedItem(pathsComboBox)
        elseif selectedMarker == -1 or selectedPath == -1 and DGS:dgsSwitchButtonGetState(switchButtons[11]) == false then
            return
        end

        local path = DGS:dgsComboBoxGetItemText(pathsComboBox, selectedPath)
        if selectedMarker ~= -1 then
            marker = DGS:dgsGridListGetItemText(markerGridList, selectedMarker, 1)
        end
        local currentText = DGS:dgsGetText(mainMemo)
        
        local markerValue = "nil"
        local markerString = ""
        for _, m in ipairs(markers) do
            if m.displayText == marker then
                markerString = string.format(
                    'local %s = createMarker(%.2f, %.2f, %.2f, "corona", 10, 0, 0, 0, 0)',
                    m.id:gsub("[%s%(%)]", ""),
                    m.position.x,
                    m.position.y,
                    m.position.z
                )
                if not currentText:find(markerString, 1, true) and DGS:dgsSwitchButtonGetState(switchButtons[11]) == false then
                    markerValue = m.id
                elseif DGS:dgsSwitchButtonGetState(switchButtons[11]) == true then
                    markerValue = "nil"
                    markerString = "nil"
                elseif DGS:dgsSwitchButtonGetState(switchButtons[11]) == false then
                    markerString = ""
                    markerValue = m.id
                end
                break
            else
                markerValue = "nil"
            end
        end
        

        for i, entry in ipairs(fileList) do
            if entry.path == path then
                local arguments = entry.arguments
                --outputDebugString("Arguments for path: " .. toJSON(arguments))

                local pedID = tonumber(arguments.pedID) or "0"
                local vehicleID = tonumber(arguments.vehicleID) or "411"
                local heightOffset = tonumber(arguments.heightOffset) or "0"
                local destroyVehicle = (arguments.destroyVehicle == true or arguments.destroyVehicle == false) and arguments.destroyVehicle or false
                local sirenLights = (arguments.sirenLights == true or arguments.sirenLights == false) and arguments.sirenLights or false
                local searchlightFollowsPlayer = (arguments.searchlightFollowsPlayer == true or arguments.searchlightFollowsPlayer == false) and arguments.searchlightFollowsPlayer or false
                local searchlightOffset = type(arguments.searchlightOffset) == "table" and arguments.searchlightOffset or {"0", "0", "0"}
                local adjustableProperty = (arguments.adjustableProperty == true or arguments.adjustableProperty == false) and arguments.adjustableProperty or false
                local adjPropValue = tonumber(arguments.adjPropValue) or "0"
                local interpolateAdjProp = (arguments.interpolateAdjProp == true or arguments.interpolateAdjProp == false) and arguments.interpolateAdjProp or false
                local startValue = tonumber(arguments.startValue) or "0"
                local endValue = tonumber(arguments.endValue) or "2500"
                local duration = tonumber(arguments.duration) or "3000"
                local reversePath = DGS:dgsSwitchButtonGetState(switchButtons[10])
                local endlessVehicles = DGS:dgsSwitchButtonGetState(switchButtons[11])
                local endlessVehiclesGroup = DGS:dgsComboBoxGetSelectedItem(selectables[2])
                if endlessVehiclesGroup == -1 then
                    endlessVehiclesGroup = "\"default\""
                else
                    local isMainGroup = false
                    for i, mainGroup in ipairs(mainGroups) do
                        if mainGroup == DGS:dgsComboBoxGetItemText(selectables[2], endlessVehiclesGroup) then
                            endlessVehiclesGroup = "\"" .. DGS:dgsComboBoxGetItemText(selectables[2], endlessVehiclesGroup) .. "\""
                            isMainGroup = true
                            break
                        end
                    end
                    if not isMainGroup then
                        endlessVehiclesGroup = "\"vehicleGroups/" .. DGS:dgsComboBoxGetItemText(selectables[2], endlessVehiclesGroup) .. ".json\""
                    end
                end
                local endlessVehiclesDelayText = DGS:dgsGetText(editFields[44])
                if endlessVehiclesDelayText:find(",") then
                    local delayRange = split(endlessVehiclesDelayText, ",")
                    local minDelay = tonumber(delayRange[1])
                    local maxDelay = tonumber(delayRange[2])
                    if minDelay and maxDelay and maxDelay > minDelay then
                        endlessVehiclesDelay = string.format("{%d, %d}", minDelay, maxDelay)
                    else
                        endlessVehiclesDelay = 1000 
                    end
                else
                    endlessVehiclesDelay = tonumber(endlessVehiclesDelayText) or 1000
                end

                local objectPath = entry.objectPath
                if objectPath then
                    objectPathString = string.format('"%s"', objectPath)
                else
                    objectPathString = "nil"
                end

                local effectPath = entry.effectPath
                if effectPath then
                    effectPathString = string.format('"%s"', effectPath)
                else
                    effectPathString = "nil"
                end

                local vehiclePath = entry.vehiclePath
                if vehiclePath then
                    vehiclePathString = string.format('"%s"', vehiclePath)
                else
                    vehiclePathString = "nil"
                end

                local textPath = entry.textPath
                if textPath then
                    textPathString = string.format('"%s"', textPath)
                else
                    textPathString = "nil"
                end

                local mirrorPath = DGS:dgsComboBoxGetSelectedItem(selectables[3])
                if mirrorPath == -1 then
                    mirrorPath = "nil"
                else
                    mirrorPath = "\"" .. DGS:dgsComboBoxGetItemText(selectables[3], mirrorPath):lower() .. "\""
                end

                local mirrorOffsetText = DGS:dgsGetText(editFields[45])
                if mirrorOffsetText:find(",") then
                    local offsetValues = split(mirrorOffsetText, ",")
                    local mx = tonumber(offsetValues[1]) or 0
                    local my = tonumber(offsetValues[2]) or 0
                    local mz = tonumber(offsetValues[3]) or 0
                    mirrorOffset = string.format("{%d, %d, %d}", mx, my, mz)
                else
                    mirrorOffset = "{0, 0, 0}"
                end

                local endlessVehiclesPeds = DGS:dgsSwitchButtonGetState(switchButtons[12])

                local mirrorRotationText = DGS:dgsGetText(editFields[46])
                if mirrorRotationText:find(",") then
                    local rotationValues = split(mirrorRotationText, ",")
                    local rx = tonumber(rotationValues[1]) or 0
                    local ry = tonumber(rotationValues[2]) or 0
                    local rz = tonumber(rotationValues[3]) or 0
                    mirrorRotation = string.format("{%d, %d, %d}", rx, ry, rz)
                else
                    mirrorRotation = "{0, 0, 0}"
                end


                --local

                if type(searchlightOffset) ~= "table" then
                    searchlightOffset = {"0", "0", "0"}
                end

                local formattedString = string.format(
                    "createOccupiedVehicleAndMoveOverPath(%s, %s, %s, \"%s\", %s, %s, %s, %s, {%s, %s, %s}, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    markerValue:gsub("[%s%(%)]", ""),
                    arguments.pedID or "0",
                    arguments.vehicleID or "411",
                    path,
                    heightOffset,
                    tostring(destroyVehicle),
                    tostring(sirenLights),
                    tostring(searchlightFollowsPlayer),
                    tonumber(searchlightOffset[1]) or 0,
                    tonumber(searchlightOffset[2]) or 0,
                    tonumber(searchlightOffset[3]) or 0,
                    tostring(adjustableProperty),
                    adjPropValue,
                    tostring(interpolateAdjProp),
                    startValue,
                    endValue,
                    duration,
                    tostring(reversePath),
                    tostring(endlessVehicles),
                    endlessVehiclesGroup,
                    endlessVehiclesDelay,
                    objectPathString,
                    effectPathString,
                    vehiclePathString,
                    textPathString,
                    mirrorPath,
                    mirrorOffset,
                    tostring(endlessVehiclesPeds),
                    mirrorRotation
                )

                local currentText = DGS:dgsGetText(mainMemo)
                if markerString == "" or DGS:dgsSwitchButtonGetState(switchButtons[11]) == true then
                    DGS:dgsMemoAppendText(mainMemo, formattedString .. "\n")
                else
                    DGS:dgsMemoAppendText(mainMemo, markerString .. "\n" .. formattedString .. "\n")
                end
                break
            end
        end
    end)

    -- Add button for adding files to the main memo
    addEventHandler("onDgsMouseClick", addButton, function(key, state)
        if key == "left" and state == "up" then

            local selectedPath = DGS:dgsComboBoxGetSelectedItem(pathsComboBox)
            local selectedMarker = DGS:dgsGridListGetSelectedItem(markerGridList)
            
            if selectedMarker == -1 and DGS:dgsSwitchButtonGetState(switchButtons[11]) == true then
                selectedPath = 1
            elseif selectedMarker == -1 or selectedPath == -1 then
                outputChatBox("#D7DF01INFO#FFFFFF: Please select a path and a marker.", 255, 255, 255, true)
                return
            end

            DGS:dgsComboBoxClear(pathsComboBox)
            triggerServerEvent("onRequestFileList", localPlayer)
            saveMemoScriptToFile()
        end
    end, false)

    -- Delete button to removing files from the path comboBox
    addEventHandler("onDgsMouseClick", delButton, function(key, state)
        if key == "left" and state == "up" then
            local selectedPath = DGS:dgsComboBoxGetSelectedItem(pathsComboBox)
            if selectedPath == -1 then
                outputChatBox("#D7DF01INFO#FFFFFF: Please select a path to delete.", 255, 255, 255, true)
                return
            end
            local path = DGS:dgsComboBoxGetItemText(pathsComboBox, selectedPath)
    
            local confirmWindow = DGS:dgsCreateWindow(screenWidth / 2 - 150, screenHeight / 2 - 75, 300, 150, "Are you sure?", false)
            DGS:dgsWindowSetSizable(confirmWindow, false)
    
            local confirmLabel = DGS:dgsCreateLabel(10, 40, 280, 30, "Do you really want to delete this path?", false, confirmWindow)
            DGS:dgsLabelSetHorizontalAlign(confirmLabel, "center", false)
    
            local yesButton = DGS:dgsCreateButton(50, 90, 80, 30, "Yes", false, confirmWindow)
            local noButton = DGS:dgsCreateButton(170, 90, 80, 30, "No", false, confirmWindow)
    
            addEventHandler("onDgsMouseClick", yesButton, function(button, state)
                if button == "left" and state == "up" then
                    DGS:dgsComboBoxClear(pathsComboBox)
                    triggerServerEvent("onRequestFileListDelete", localPlayer, path)
                    DGS:dgsComboBoxSetSelectedItem(pathsComboBox, -1)
                    DGS:dgsCloseWindow(confirmWindow)
                end
            end, false)
    
            addEventHandler("onDgsMouseClick", noButton, function(button, state)
                if button == "left" and state == "up" then
                    DGS:dgsCloseWindow(confirmWindow)
                end
            end, false)
        end
    end, false)

    addEvent("onFileListDeleteSuccess", true)
    addEventHandler("onFileListDeleteSuccess", localPlayer, function(path)
        outputChatBox("#D7DF01INFO#FFFFFF: Successfully deleted path: " .. path, 255, 255, 255, true)
        DGS:dgsComboBoxClear(pathsComboBox)
        triggerServerEvent("onRequestFileList", localPlayer)
    end)

    -----------------------------------------
    --------- create resource menu ----------
    -----------------------------------------
    --TODO: Fix and make it work in the future
    --[[
    addEventHandler("onDgsMouseClick", resourceButton, function(key, state)
        if key == "left" and state == "up" then
            if DGS:dgsGetVisible(createResourceMenu) then
                DGS:dgsSetVisible(createResourceMenu, false)
            else
                DGS:dgsSetVisible(createResourceMenu, true)
                DGS:dgsBringToFront(createResourceMenu)
            end
        end
    end, false)

    addEventHandler("onDgsFocus", createResourceEdit, function()
        DGS:dgsSetInputMode("no_binds")
        DGS:dgsSetText(createResourceEdit, "")
    end, false)

    addEventHandler("onDgsBlur", createResourceEdit, function()
        DGS:dgsSetInputMode("allow_binds")
        if DGS:dgsGetText(createResourceEdit) == "" then
            DGS:dgsSetText(createResourceEdit, "Resource name")
        end
    end, false)

    addEventHandler("onDgsMouseClick", createResourceButton, function(key, state)
        if key == "left" and state == "up" then
            local resourceName = DGS:dgsGetText(createResourceEdit)

            if resourceName == "Resource name" or resourceName == "" then
                outputChatBox("#D7DF01INFO#FFFFFF: Please enter a resource name.", 255, 255, 255, true)
                return
            end

            if memoText == "" then
                outputChatBox("#D7DF01INFO#FFFFFF: Please add some paths to the memo before creating a resource.", 255, 255, 255, true)
                return
            end

            triggerServerEvent("onCreateResource", root, resourceName)

            DGS:dgsSetVisible(createResourceMenu, false)
            --importPaths()
        end
    end, false)--]]

    -----------------------------------------
    --------- Path menu save button ---------
    -----------------------------------------

    addEventHandler("onDgsMouseClick", saveButton, function(key, state)
        if key == "left" and state == "up" then
            local selectedMap = DGS:dgsGridListGetSelectedItem(mapsGridList)
            
            if selectedMap == -1 then
                outputChatBox("#D7DF01INFO: #FFFFFFYou need to select a map in order to save.", 255, 255, 255, true)
                return
            end
            importPaths()
        end
    end, false)


    --------------------------------------------
    --------- Path menu refresh button ---------
    --------------------------------------------

    addEventHandler("onDgsMouseClick", refreshButton, function(key, state)
        if key == "left" and state == "up" then
            triggerServerEvent("requestMarkersList", root)
            triggerServerEvent("onServerResourcesGet", root)
            addFilesToComboBox()
        end
    end, false)

    DGS:dgsSetVisible(pathsMenu, false)

    --------------------------------------------
    ----------- Path menu checkboxes -----------
    --------------------------------------------

    addEventHandler("onDgsCheckBoxChange", flushEnabledCheckBox, function(state)
        if state then
            isFlushEnabled = true
        else
            isFlushEnabled = false
        end
        triggerServerEvent("onFlushEnabledChange", localPlayer, isFlushEnabled)
    end)

    addEventHandler("onDgsCheckBoxChange", readOnlyCheckBox, function(state)
        if state then
            DGS:dgsMemoSetReadOnly(mainMemo, true)
        else
            DGS:dgsMemoSetReadOnly(mainMemo, false)
        end
    end)

    ------------------------------------------
    --------- Create the main memo -----------
    ------------------------------------------

    mainMemoMenu = DGS:dgsCreateWindow(declare.sPosX - (declare.sWidth / 2) - declare.pathMenuWidth - declare.spacing + declare.marginRight * 2, declare.sPosY + declare.spacing, (declare.pathMenuWidth * 0.75) - declare.marginRight * 2, declare.sHeight / 2 - declare.spacing, "Memo paths script", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(mainMemoMenu, false)
    
    local memoWidth = declare.pathMenuWidth - declare.marginRight * 2 - declare.marginLeft
    local memoHeight = declare.sHeight / 2 - declare.spacing - declare.marginTop - declare.marginBottom
    local memoX = (declare.pathMenuWidth - memoWidth) / 2 - declare.marginRight
    local memoY = (declare.sHeight / 2 - memoHeight) / 2 - declare.spacing * 3
    
    mainMemo = DGS:dgsCreateMemo((declare.pathMenuWidth - memoWidth) / 2 - declare.marginRight, (declare.sHeight / 2 - memoHeight) / 2 - declare.spacing * 3, (declare.pathMenuWidth * 0.75) - declare.marginRight * 2 - declare.marginLeft, declare.sHeight / 2 - declare.spacing - declare.marginTop - declare.marginBottom, "", false, mainMemoMenu)
    
    addEventHandler("onDgsMouseClick", mainMemo, function(button, state)
        if button == "left" and state == "down" then
            DGS:dgsSetInputMode("no_binds")
        end
    end, false)

    addEventHandler("onDgsBlur", mainMemo, function()
        DGS:dgsSetInputMode("allow_binds")
    end, false)

    DGS:dgsSetVisible(mainMemoMenu, false)

    ------------------------------------------
    ---------- additional options ------------
    ------------------------------------------

    mainAdditionalMenu = DGS:dgsCreateWindow(declare.sPosX - (declare.pathMenuWidth * 0.525) - declare.spacing * 2 + declare.marginRight * 2, declare.sPosY + declare.spacing, (declare.pathMenuWidth * 0.325) - declare.marginRight * 2, declare.sHeight / 2 - declare.spacing, "Additional options", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(mainAdditionalMenu, false)

    for i, additionalArgument in ipairs(additionalArguments) do
        local argumentName = additionalArgument.name
        local argumentToolTip = additionalArgument.toolTip
        local argumentType = additionalArgument.type
        local argumentText = additionalArgument.text
        local y = declare.marginTop + (i - 1) * (declare.height + declare.spacing)

        if argumentType == "string" or argumentType == "float" or argumentType == "integer" then
            local argumentEdit = DGS:dgsCreateEdit(declare.marginLeft / 2, y, declare.width / 1.65, declare.height, argumentText, false, mainAdditionalMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentEdit, argumentToolTip)
            table.insert(editFields, argumentEdit)
        
            addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    if DGS:dgsGetText(argumentEdit) == argumentText then
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end
            end, false)

            addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    DGS:dgsSetText(argumentEdit, "")
                end
            end, false)
        
            addEventHandler("onDgsBlur", argumentEdit, function()
                DGS:dgsSetInputMode("allow_binds")
                local playerVehicle = getPedOccupiedVehicle(localPlayer)
                local empty = DGS:dgsGetText(argumentEdit) == ""
                if argumentName == "endlessVehiclesDelay" then
                    local value = DGS:dgsGetText(argumentEdit)
                    if value:find(",") then
                        local delayRange = split(value, ",")
                        local minDelay = tonumber(delayRange[1])
                        local maxDelay = tonumber(delayRange[2])
                        if not minDelay or not maxDelay then
                            DGS:dgsSetText(argumentEdit, argumentText)
                        end
                    elseif not tonumber(value) then
                        DGS:dgsSetText(argumentEdit, argumentText)
                    end
                elseif argumentName == "mirrorPathOffset" or argumentName == "mirrorPathRotation" then
                    local value = DGS:dgsGetText(argumentEdit)
                    if value:find(",") then
                        local offsetRange = split(value, ",")
                        local x = tonumber(offsetRange[1])
                        local y = tonumber(offsetRange[2])
                        local z = tonumber(offsetRange[3])
                        if #offsetRange > 3 then
                            DGS:dgsSetText(argumentEdit, argumentText)
                        end
                    elseif not tonumber(value) then
                        DGS:dgsSetText(argumentEdit, argumentText)
                    end
                elseif argumentType == "float" or argumentType == "integer" then
                    local value = tonumber(DGS:dgsGetText(argumentEdit))
                    if not value or empty then
                        DGS:dgsSetText(argumentEdit, argumentText)
                    end
                elseif empty then
                    DGS:dgsSetText(argumentEdit, argumentText)
                else return end
            end, false)
        elseif argumentType == "boolean" then
            y = y + declare.height / 2
            local argumentSwitch = DGS:dgsCreateSwitchButton(declare.marginLeft, y, declare.width / 2, declare.height / 2, "True", "False", false, false, mainAdditionalMenu)
            local argumentSwitchLabel = DGS:dgsCreateLabel(declare.marginLeft / 2, y - ((declare.height / 2) + (declare.spacing / 2)), (declare.width / 3) - declare.spacing / 3, declare.height, argumentText, false, mainAdditionalMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentSwitch, argumentToolTip)
            table.insert(switchButtons, argumentSwitch)
            if argumentName == "endlessVehiclesPeds" then
                DGS:dgsSwitchButtonSetState(argumentSwitch, true)
            end
        elseif argumentType == "table" then
            local labels = {"offsetX", "offsetY", "offsetZ"}
            for j = 0, 2 do
                local label = labels[j + 1]
                local argumentEdit = DGS:dgsCreateEdit((declare.marginLeft / 2) + ((j * declare.width / 3) + (j * declare.spacing / 3)), y, (declare.width / 3) - declare.spacing / 3, declare.height, label, false, mainAdditionalMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, argumentEdit, argumentToolTip)
                table.insert(editFields, argumentEdit)
        
                addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        if DGS:dgsGetText(argumentEdit) == label then
                            DGS:dgsSetText(argumentEdit, "")
                        end
                    end
                end, false)

                addEventHandler("onDgsMouseDoubleClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end, false)
        
                addEventHandler("onDgsBlur", argumentEdit, function()
                    DGS:dgsSetInputMode("allow_binds")
                    if DGS:dgsGetText(argumentEdit) == "" then
                        DGS:dgsSetText(argumentEdit, "offset" .. labels[j + 1])
                    end
                end, false)
            end
        elseif argumentType == "selectable" then
            local argumentComboBox = DGS:dgsCreateComboBox(declare.marginLeft / 2, y, declare.width / 1.65, declare.height, argumentText, false, mainAdditionalMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentComboBox, argumentToolTip)
            table.insert(selectables, argumentComboBox)
        elseif argumentType == "button" then
            local argumentButton = DGS:dgsCreateButton(declare.marginLeft / 2, y, declare.width / 1.65, declare.height, argumentText, false, mainAdditionalMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentButton, argumentToolTip)
            table.insert(buttons, argumentButton)
        elseif argumentType == "label" then
            local argumentLabel = DGS:dgsCreateLabel(declare.marginLeft / 2, y + declare.height / 2, declare.width / 1.65, declare.height, argumentText, false, mainAdditionalMenu)
        end
    end

    vehicleGroupMenu = DGS:dgsCreateWindow(declare.sPosX - (declare.sWidth * 3.7/ 2), declare.sPosY - (declare.sHeight / 2), declare.sWidth * 3.7, declare.sHeight, "Create your own vehicle group", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(vehicleGroupMenu, false)
    DGS:dgsSetVisible(vehicleGroupMenu, false)

    local vehicleGroupGridListMain = DGS:dgsCreateGridList(declare.marginLeft, declare.marginTop, declare.sWidth * 1.75, declare.sHeight / 1.25, false, vehicleGroupMenu)
    DGS:dgsGridListAddColumn(vehicleGroupGridListMain, "ID", 0.25)
    DGS:dgsGridListAddColumn(vehicleGroupGridListMain, "Name", 0.4)
    DGS:dgsGridListAddColumn(vehicleGroupGridListMain, "", 0.5)
    DGS:dgsSetProperty(vehicleGroupGridListMain, "rowHeight", 50)
    DGS:dgsGridListSetSortEnabled(vehicleGroupGridListMain, false)

    local vehicleGroupGridList = DGS:dgsCreateGridList(declare.marginLeft + declare.sWidth * 1.75 + declare.spacing, declare.marginTop, declare.sWidth * 1.75, declare.sHeight / 1.25, false, vehicleGroupMenu)
    DGS:dgsGridListAddColumn(vehicleGroupGridList, "ID", 0.25)
    DGS:dgsGridListAddColumn(vehicleGroupGridList, "Name", 0.4)
    DGS:dgsGridListAddColumn(vehicleGroupGridList, "", 0.5)
    DGS:dgsSetProperty(vehicleGroupGridList, "rowHeight", 50)
    DGS:dgsGridListSetSortEnabled(vehicleGroupGridList, false)
    
    local vehicleGroupSearchBar = DGS:dgsCreateEdit(declare.marginLeft, declare.marginTop + declare.sHeight / 1.25 + declare.spacing, declare.width, declare.height, "Search for any vehicle", false, vehicleGroupMenu)
    local closeVehicleGroup = DGS:dgsCreateButton(declare.marginLeft, declare.marginTop + declare.sHeight / 1.25 + declare.height + declare.spacing * 2, declare.width, declare.height, "Close", false, vehicleGroupMenu)
    
    local vehicleGroupName = DGS:dgsCreateEdit(declare.marginLeft + declare.sWidth * 1.75 + declare.spacing, declare.marginTop + declare.sHeight / 1.25 + declare.spacing, declare.width, declare.height, "New group name", false, vehicleGroupMenu)
    local vehicleGroupClear = DGS:dgsCreateButton(declare.marginLeft + declare.sWidth * 1.75 + declare.spacing * 2 + declare.width, declare.marginTop + declare.sHeight / 1.25 + declare.height + declare.spacing * 2, declare.width, declare.height, "Clear vehicle group list", false, vehicleGroupMenu)
    local vehicleGroupAdd = DGS:dgsCreateButton(declare.marginLeft + declare.sWidth * 1.75 + declare.spacing, declare.marginTop + declare.sHeight / 1.25 + declare.height + declare.spacing * 2, declare.width, declare.height, "Add vehicle group", false, vehicleGroupMenu)


    addEventHandler("onDgsMouseClick", buttons[14], function(key, state)
        if key == "left" and state == "up" then
            if DGS:dgsGetVisible(vehicleGroupMenu) then
                DGS:dgsSetVisible(vehicleGroupMenu, false)
            else
                DGS:dgsSetVisible(vehicleGroupMenu, true)
                DGS:dgsBringToFront(vehicleGroupMenu)
            end
        end
    end, false)

    for i, vehicle in ipairs(vehicleIds) do
        local vehicleName = vehicleNames[i]
        local row = DGS:dgsGridListAddRow(vehicleGroupGridListMain)
        local texture = dxCreateTexture("images/" .. vehicleName .. ".png")
        DGS:dgsGridListSetItemText(vehicleGroupGridListMain, row, 1, vehicle, false, false)
        DGS:dgsGridListSetItemText(vehicleGroupGridListMain, row, 2, getVehicleNameFromModel(vehicle), false, false)
        DGS:dgsGridListSetItemImage(vehicleGroupGridListMain, row, 3, texture, tocolor(255,255,255,255), 10, 20, 60, 20, false)
    end

    addEventHandler("onDgsGridListItemDoubleClick", vehicleGroupGridListMain, function(button, state, row, column)
        if button == "left" and state == "up" then
            local vehicleID = DGS:dgsGridListGetItemText(vehicleGroupGridListMain, row, 1)
            local vehicleName = DGS:dgsGridListGetItemText(vehicleGroupGridListMain, row, 2)
            local vehicleImage = DGS:dgsGridListGetItemImage(vehicleGroupGridListMain, row, 3)
            
            local newRow = DGS:dgsGridListAddRow(vehicleGroupGridList)
            DGS:dgsGridListSetItemText(vehicleGroupGridList, newRow, 1, vehicleID, false, false)
            DGS:dgsGridListSetItemText(vehicleGroupGridList, newRow, 2, vehicleName, false, false)
            DGS:dgsGridListSetItemImage(vehicleGroupGridList, newRow, 3, vehicleImage, tocolor(255,255,255,255),10,20,60,20,false)
        end
    end, false)

    addEventHandler("onDgsGridListItemDoubleClick", vehicleGroupGridList, function(button, state, row, column)
        if button == "left" and state == "up" then
            DGS:dgsGridListRemoveRow(vehicleGroupGridList, row)
        end
    end, false)

    addEventHandler("onDgsFocus", vehicleGroupSearchBar, function()
        DGS:dgsSetInputMode("no_binds")
        DGS:dgsSetText(vehicleGroupSearchBar, "")
    end, false)

    addEventHandler("onDgsBlur", vehicleGroupSearchBar, function()
        DGS:dgsSetInputMode("allow_binds")
        if DGS:dgsGetText(vehicleGroupSearchBar) == "" then
            DGS:dgsSetText(vehicleGroupSearchBar, "Search for any vehicle")
        end
    end, false)

    addEventHandler("onDgsTextChange", vehicleGroupSearchBar, function()
        if DGS:dgsGetText(vehicleGroupSearchBar) == "Search for any vehicle" then return end
    
        local searchText = DGS:dgsGetText(vehicleGroupSearchBar):lower()
        DGS:dgsGridListClear(vehicleGroupGridListMain)
    
        for i, vehicle in ipairs(vehicleIds) do
            local vehicleName = vehicleNames[i]
            if searchText == "" or vehicleName:lower():find(searchText) then
                local row = DGS:dgsGridListAddRow(vehicleGroupGridListMain)
                DGS:dgsGridListSetItemText(vehicleGroupGridListMain, row, 1, vehicle, false, false)
                DGS:dgsGridListSetItemText(vehicleGroupGridListMain, row, 2, getVehicleNameFromModel(vehicle), false, false)
                local texture = dxCreateTexture("images/" .. vehicleName .. ".png")
                DGS:dgsGridListSetItemImage(vehicleGroupGridListMain, row, 3, texture, tocolor(255,255,255,255), 10, 20, 60, 20, false)
            end
        end
    end)

    addEventHandler("onDgsMouseClick", vehicleGroupAdd, function(key, state)
        if key == "left" and state == "up" then
            local vehicleGroupName = DGS:dgsGetText(vehicleGroupName)

            if vehicleGroupName == "New group name" or vehicleGroupName == "" then
                outputChatBox("#D7DF01INFO#FFFFFF: Please enter a vehicle group name.", 255, 255, 255, true)
                return
            end

            local vehicleGroup = {}
            for i = 1, DGS:dgsGridListGetRowCount(vehicleGroupGridList) do
                local vehicleID = tonumber(DGS:dgsGridListGetItemText(vehicleGroupGridList, i, 1))
                table.insert(vehicleGroup, vehicleID)
            end

            triggerServerEvent("onCreateVehicleGroup", root, vehicleGroupName, vehicleGroup)

            DGS:dgsComboBoxAddItem(selectables[2], vehicleGroupName)
        end
    end, false)

    addEventHandler("onDgsMouseClick", vehicleGroupClear, function(key, state)
        if key == "left" and state == "up" then
            DGS:dgsGridListClear(vehicleGroupGridList)
        end
    end, false)

    addEventHandler("onDgsMouseClick", closeVehicleGroup, function(key, state)
        if key == "left" and state == "up" then
            DGS:dgsSetVisible(vehicleGroupMenu, false)
        end
    end, false)

    addEventHandler("onDgsFocus", vehicleGroupName, function()
        DGS:dgsSetInputMode("no_binds")
        DGS:dgsSetText(vehicleGroupName, "")
    end, false)

    addEventHandler("onDgsBlur", vehicleGroupName, function()
        DGS:dgsSetInputMode("allow_binds")
        if DGS:dgsGetText(vehicleGroupName) == "" then
            DGS:dgsSetText(vehicleGroupName, "New group name")
        end
    end, false)

    addVehicleGroupToComboBox()
    addAxisToComboBox()

    DGS:dgsSetVisible(mainAdditionalMenu, false)
    ------------------------------------------
    --------- Searchlight creation -----------
    ------------------------------------------
    
    addEventHandler("onDgsSwitchButtonStateChange", switchButtons[3], function(state)
        if state == true and not isTimer(timer) then
            searchlightTimer = setTimer(function()
                if not isPreviewActive then
                    isPreviewActive = true
                end
                if isElement(searchlight) then
                    destroyElement(searchlight)
                end
            
                local playerVehicle = getPedOccupiedVehicle(localPlayer)
                if playerVehicle then
                    local offsetX, offsetY, offsetZ = tonumber(DGS:dgsGetText(editFields[5])) or 0, tonumber(DGS:dgsGetText(editFields[6])) or 0, tonumber(DGS:dgsGetText(editFields[7])) or 0
                    local sx, sy, sz = getElementPosition(playerVehicle)
                    searchlight = createSearchLight(sx, sy, sz, 0, 0, 0, 0, 15, true)
                    setSearchLightEndPosition(searchlight, sx, sy, -10)
                    attachSearchlight(searchlight, playerVehicle, {x = offsetX, y = offsetY, z = offsetZ})
                end
            end, 50, 0)
        else
            if isElement(searchlight) then
                destroyElement(searchlight)
                killTimer(searchlightTimer)
                isPreviewActive = false
            end
        end
    end)

    ------------------------------------------
    --------- Core window movement -----------
    ------------------------------------------
    
    local lastMainPos = {
        x = declare.sPosX - (declare.sWidth / 2),
        y = declare.sPosY - (declare.sHeight / 2)
    }
    
    local lastPathsPos = {
        x = declare.sPosX - (declare.sWidth / 2) - declare.pathMenuWidth - declare.spacing + declare.marginRight * 2,
        y = declare.sPosY - (declare.sHeight / 2)
    }
    
    local lastMemoPos = {
        x = declare.sPosX - (declare.sWidth / 2) - declare.pathMenuWidth - declare.spacing + declare.marginRight * 2,
        y = declare.sPosY + declare.spacing
    }

    local lastAdditionalPos = {
        x = declare.sPosX - (declare.pathMenuWidth * 0.525) - declare.spacing * 2 + declare.marginRight * 2, 
        y = declare.sPosY + declare.spacing
    }

    addEventHandler("onDgsPositionChange", mainRecordMenu, function()
        local mainX, mainY = DGS:dgsGetPosition(mainRecordMenu, false)
        local deltaX = mainX - lastMainPos.x
        local deltaY = mainY - lastMainPos.y

        local currentPathsX, currentPathsY = DGS:dgsGetPosition(pathsMenu, false)
        local currentMemoX, currentMemoY = DGS:dgsGetPosition(mainMemoMenu, false)
        local currentAdditionalPosX, currentAdditionalPosY = DGS:dgsGetPosition(mainAdditionalMenu, false)
        
        DGS:dgsSetPosition(pathsMenu, currentPathsX + deltaX, currentPathsY + deltaY, false)
        DGS:dgsSetPosition(mainMemoMenu, currentMemoX + deltaX, currentMemoY + deltaY, false)
        DGS:dgsSetPosition(mainAdditionalMenu, currentAdditionalPosX + deltaX, currentAdditionalPosY + deltaY, false)

        lastMainPos.x = mainX
        lastMainPos.y = mainY
        lastPathsPos.x = currentPathsX + deltaX
        lastPathsPos.y = currentPathsY + deltaY
        lastMemoPos.x = currentMemoX + deltaX
        lastMemoPos.y = currentMemoY + deltaY
        lastAdditionalPos.x = currentAdditionalPosX + deltaX
        lastAdditionalPos.y = currentAdditionalPosY + deltaY
    end, false)

    --Call server side events to get resources/maps and markers
    triggerServerEvent("onServerResourcesGet", root)
    triggerServerEvent("requestMarkersList", root)
end
addEventHandler("onClientResourceStart", resourceRoot, createMainGuiMenu)

function saveMemoScriptToFile()
    local content = DGS:dgsGetText(mainMemo)
    local file = fileCreate("scriptmemo.json")
    if file then
        fileWrite(file, toJSON(content))
        fileClose(file)
    else
        outputDebugString("[CCM]: Failed to save scriptmemo.json", 0, 255, 100, 100)
    end
end
addEventHandler("onClientResourceStop", resourceRoot, saveMemoScriptToFile)
addEventHandler("onClientPlayerQuit", root, saveMemoScriptToFile)

function loadMemoScriptFromFile()
    if fileExists("scriptmemo.json") then
        local file = fileOpen("scriptmemo.json")
        if file then
            local content = fileRead(file, fileGetSize(file))
            DGS:dgsSetText(mainMemo, fromJSON(content))
            fileClose(file)
            outputDebugString("[CCM]: scriptmemo.json loaded.", 4, 100, 255, 100)
        else
            outputDebugString("[CCM]: Failed to load scriptmemo.json", 0, 255, 100, 100)
        end
    end
end
addEventHandler("onClientPlayerJoin", root, saveMemoScriptToFile)
addEventHandler("onClientResourceStart", resourceRoot, loadMemoScriptFromFile)

function importPaths()
    eventTriggered = false
    local memoText = DGS:dgsGetText(mainMemo)
    local selectedMap = DGS:dgsGridListGetSelectedItem(mapsGridList)
    local mapName = DGS:dgsGridListGetItemText(mapsGridList, selectedMap, 1)
    local stringFunction = DGS:dgsGetText(mainMemo)
    
    triggerServerEvent("onImportPaths", localPlayer, memoText, mapName, stringFunction)
end

function saveMessage(message)

    local selectedMap = DGS:dgsGridListGetSelectedItem(mapsGridList)
    local mapName = DGS:dgsGridListGetItemText(mapsGridList, selectedMap, 1)

    if message == 0 then
        outputChatBox("#FF0000ERROR#FFFFFF: I have no permission to edit files. Add admin rights to this resource.", 255, 255, 255, true)
    elseif message == 1 then
        local cleanedFilePath = string.gsub(filePath, "^paths/", "")
        cleanedFilePath = string.gsub(cleanedFilePath, "%.json$", "")
        outputChatBox("#D7DF01INFO#FFFFFF: You saved the path/s successfully to your map: " .. mapName, 255, 255, 255, true)
    elseif message == 2 then
        outputChatBox("#D7DF01INFO#FFFFFF: The existing files have been deleted succesfully!", 255, 255, 255, true)
        outputChatBox("#D7DF01INFO#FFFFFF: You saved the new path/s successfully to your map: " .. mapName, 255, 255, 255, true)
    else
        outputChatBox("#FF0000ERROR#FFFFFF: Unable to get meta. Make sure meta exists in given map or resource folder.", 255, 255, 255, true)
    end
end
addEvent("onClientSaveMessage", true)
addEventHandler("onClientSaveMessage", root, saveMessage)


isMenuOpen = false


function blockClientEvents()
    local clientEvents = {
        "doSelectElement",
        "onClientElementSelect",
        "onClientElementDrop",
        "onClientElementDoubleClick",
        "onClientWorldClick",
        "onFreecamMode",
        "onCursorMode"
    }
    
    for _, eventName in ipairs(clientEvents) do
        addEventHandler(eventName, root, function()
            if isMenuOpen or isMemoMenuOpen then
                cancelEvent()
                return false
            end
        end, true, "high+10")
    end
end

function blockServerEvents()
    local serverEvents = {
        "onElementSelect",
        "doLockElement",
        "doUnlockElement",
        "syncProperty",
        "syncProperties"
    }
    
    for _, eventName in ipairs(serverEvents) do
        addEventHandler(eventName, root, function()
            if isMenuOpen or isMemoMenuOpen then
                cancelEvent()
                return false
            end
        end, true, "high+10")
    end
end

function toggleMainGuiMenu(key, state)
    if isMTAWindowActive() or DGS:dgsGetInputMode() == "no_binds" or isInGuiEditField then return end

    for i, keybind in ipairs(keybinds) do
        if keybind.name == "bind" then
            keyBindMemo = keybind.element
        end
    end
    local keyBind = DGS:dgsGetText(keyBindMemo) or "n"
    
    local playerVehicle = getPedOccupiedVehicle(localPlayer)
    if playerVehicle then
        playerVehicleModel = getElementModel(playerVehicle)
        currentWheelSizes = getVehicleModelWheelSize(playerVehicleModel)
    end
    
    if key == keyBind and state then
        if timer then
            stopRecording()
            if isVehicleDamageProof(playerVehicle) then
                setVehicleDamageProof(playerVehicle, false)
            end
            return
        elseif DGS:dgsGetVisible(mainRecordMenu) then

            DGS:dgsSetVisible(mainRecordMenu, false)
            if DGS:dgsGetVisible(pathsMenu) then
                DGS:dgsSetVisible(pathsMenu, false)
            end
            if DGS:dgsGetVisible(mainMemoMenu) then
                DGS:dgsSetVisible(mainMemoMenu, false)
            end
            if DGS:dgsGetVisible(mainAdditionalMenu) then
                DGS:dgsSetVisible(mainAdditionalMenu, false)
            end
            if DGS:dgsGetVisible(vehicleGroupMenu) then
                DGS:dgsSetVisible(vehicleGroupMenu, false)
            end
            if DGS:dgsGetVisible(objectMenu) then
                DGS:dgsSetVisible(objectMenu, false)
                isObjectMenuOpen = true
            end
            if DGS:dgsGetVisible(effectMenu) then
                DGS:dgsSetVisible(effectMenu, false)
                isEffectMenuOpen = true
            end
            if DGS:dgsGetVisible(settingsMenu) then
                DGS:dgsSetVisible(settingsMenu, false)
            end
            if DGS:dgsGetVisible(textMenu) then
                DGS:dgsSetVisible(textMenu, false)
                isTextMenuOpen = true
            end
            if DGS:dgsGetVisible(vehicleMenu) then
                DGS:dgsSetVisible(vehicleMenu, false)
                isVehicleMenuOpen = true
            end
            if isElement(searchlight) then
                destroyElement(searchlight)
                killTimer(searchlightTimer)
            end
            showCursor(false)
            isMenuOpen = false
            
            local isEditorActive = isEditorRunning()
            if isEditorActive then
                triggerServerEvent("onElementDrop", localPlayer)
            end
            
            if playerVehicle then
                setElementFrozen(playerVehicle, false)
                setElementVelocity(playerVehicle, vx, vy, vz)
                if keepPreview == false then --restore default settings
                    setVehicleOverrideLights(playerVehicle, 2)
                    setElementRotation(playerVehicle, rx, ry, rz)
                    setVehicleWheelStates(playerVehicle, 0, 0, 0, 0)
                    setElementAlpha(playerVehicle, 255)
                    setElementAlpha(localPlayer, 255)

                    for i = 0, 6 do
                        setVehicleWindowOpen(playerVehicle, i, false)
                    end

                    if playerVehicleModel == 512 or playerVehicleModel == 513 then
                        setVehicleSmokeTrailEnabled(playerVehicle, false)
                    end

                    setVehicleModelWheelSize(playerVehicleModel, "front_axle", currentWheelSizes.front_axle)
                    setVehicleModelWheelSize(playerVehicleModel, "rear_axle", currentWheelSizes.rear_axle)

                end
                setVehicleDamageProof(playerVehicle, false)
                setCameraTarget(localPlayer)
            end
        else
            if playerVehicle then
                for i, argument in ipairs(arguments) do
                    local argumentName = argument.name
                    local argumentType = argument.type
                    local argumentEdit = editFields[i]
                    if argumentType == "integer" then
                        if argumentName == "vehicleID" then
                            DGS:dgsSetText(argumentEdit, tostring(getElementModel(playerVehicle)))
                        elseif argumentName == "pedID" then
                            DGS:dgsSetText(argumentEdit, tostring(getElementModel(localPlayer)))
                        end
                    end
                end

                if DGS:dgsSwitchButtonGetState(switchButtons[3]) and not isTimer(timer) then
                    if isElement(searchlight) then
                        destroyElement(searchlight)
                        killTimer(searchlightTimer)
                        isPreviewActive = false
                        return
                    end
                    searchlightTimer = setTimer(function()
                        if not isPreviewActive then
                            isPreviewActive = true
                        end
                        if isElement(searchlight) then
                            destroyElement(searchlight)
                        end
                    
                        local playerVehicle = getPedOccupiedVehicle(localPlayer)
                        if playerVehicle then
                            local offsetX, offsetY, offsetZ = tonumber(DGS:dgsGetText(editFields[5])) or 0, tonumber(DGS:dgsGetText(editFields[6])) or 0, tonumber(DGS:dgsGetText(editFields[7])) or 0
                            local sx, sy, sz = getElementPosition(playerVehicle)
                            searchlight = createSearchLight(sx, sy, sz, 0, 0, 0, 0, 15, true)
                            setSearchLightEndPosition(searchlight, sx, sy, -10)
                            attachSearchlight(searchlight, playerVehicle, {x = offsetX, y = offsetY, z = offsetZ})
                        end
                    end, 50, 0)
                end
                
                calculateInitialAngles()
                vx, vy, vz = getElementVelocity(playerVehicle)
                rx, ry, rz = getElementRotation(playerVehicle)
                setElementFrozen(playerVehicle, true)
                setVehicleDamageProof(playerVehicle, true)
                fixVehicle(playerVehicle)
            end
            
            if isPathsMenuOpen then
                DGS:dgsSetVisible(pathsMenu, true)
            end
            if isMainMemoMenuOpen then
                DGS:dgsSetVisible(mainMemoMenu, true)
            end
            if isAdditionalMenuOpen then
                DGS:dgsSetVisible(mainAdditionalMenu, true)
            end
            if isObjectMenuOpen then
                DGS:dgsSetVisible(objectMenu, true)
            end
            if isEffectMenuOpen then
                DGS:dgsSetVisible(effectMenu, true)
            end
            if isTextMenuOpen then
                DGS:dgsSetVisible(textMenu, true)
            end
            if isVehicleMenuOpen then
                DGS:dgsSetVisible(vehicleMenu, true)
            end
            

            DGS:dgsSetVisible(mainRecordMenu, true)
            showCursor(true)
            isMenuOpen = true

            local isEditorActive = isEditorRunning()
            if isEditorActive then
                triggerServerEvent("onElementDrop", localPlayer)
            end
        end
    end
end

function onGuiFocus()
    isInGuiEditField = true
end
addEventHandler("onClientGUIFocus", root, onGuiFocus)

function onGuiBlur()
    isInGuiEditField = false
end
addEventHandler("onClientGUIBlur", root, onGuiBlur)

function onDgsFocus()
    isInEditField = true
end
addEventHandler("onDgsFocus", root, onDgsFocus)

function onDgsBlur()
    isInEditField = false
end
addEventHandler("onDgsBlur", root, onDgsBlur)

addEventHandler("onClientKey", root, toggleMainGuiMenu)
addEventHandler("onClientResourceStart", resourceRoot, function()
    blockClientEvents()
    blockServerEvents()
end)

function onElementSelectHandler(element)
    local client = client
    if client and getElementData(client, "menuOpen") then
        cancelEvent()
        return false
    end
end
addEventHandler("onElementSelect", root, onElementSelectHandler, true, "high+10")
addEventHandler("doLockElement", root, onElementSelectHandler, true, "high+10")
addEventHandler("doUnlockElement", root, onElementSelectHandler, true, "high+10")
