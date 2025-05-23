--Cache some functions for better performance
local getElementMatrix = getElementMatrix
local getElementPosition = getElementPosition
local getElementRotation = getElementRotation
local setElementPosition = setElementPosition
local setElementRotation = setElementRotation
local isElement = isElement
local destroyElement = destroyElement
local attachElements = attachElements
local setElementCollisionsEnabled = setElementCollisionsEnabled
local setElementDoubleSided = setElementDoubleSided
local setElementFrozen = setElementFrozen
local setPedControlState = setPedControlState
local setPedAnalogControlState = setPedAnalogControlState
local createPed = createPed
local createVehicle = createVehicle
local createObject = createObject
local createSearchLight = createSearchLight
local setVehicleSirensOn = setVehicleSirensOn
local setVehicleLandingGearDown = setVehicleLandingGearDown
local setVehicleTaxiLightOn = setVehicleTaxiLightOn
local setObjectScale = setObjectScale
local setVehicleAdjustableProperty = setVehicleAdjustableProperty
local setVehicleEngineState = setVehicleEngineState
local setVehicleOverrideLights = setVehicleOverrideLights
local warpPedIntoVehicle = warpPedIntoVehicle
local setTimer = setTimer
local ipairs = ipairs
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove
local rad = math.rad
local sin = math.sin
local cos = math.cos

attachedSearchlights = {}
local attachedEffects = {}
local attachedObjects = {}
local attachedTexts = {}
local searchlights = {}
local activeInstances = {}
local activeInstancesTracker = {}
math.randomseed(getRealTime().timestamp + getTickCount())

local globalInstance = nil
local preRenderHandler = nil

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

local pedIds = {1, 2, 5, 7, 8, 14, 15, 17, 20, 21, 22, 23, 24, 25, 26, 28, 29,
30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 57,
58, 59, 60, 66, 67, 68, 71, 72, 73, 94, 95, 96, 98, 123, 124,
125, 126, 128, 132, 133, 136, 142, 143, 144, 146, 147, 153, 156,
158, 161, 170, 171, 179, 180, 181, 182, 183, 184, 185, 186, 187,
189, 202, 206, 217, 220, 221, 222, 223, 227, 228, 229, 234, 235,
236, 240, 241, 242, 247, 248, 250, 258, 259, 261, 262, 264, 268,
272, 273, 290, 291, 292, 293, 294, 295, 296, 297, 299, 6, 9, 10, 
11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 75,
76, 77, 88, 89, 91, 90, 92, 93, 85, 129, 130, 131, 138, 139, 140,
141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192,
193, 194, 195, 196, 197, 198, 199, 201, 207, 211, 214, 215, 216,
218, 219, 226, 231, 232, 233, 237, 238, 243, 298, 304 }

local vehicleGroups = {
    aircraft = {592, 577, 520, 553, 476, 519},
    emergency = {416, 427, 490, 528, 407, 544, 523, 596, 598, 599, 597},
    streetRacers = {429, 541, 415, 480, 562, 565, 434, 411, 559, 561, 560, 506, 451, 558, 555, 477},
    lowridersAndMuscleCars = {536, 575, 534, 567, 535, 576, 412, 402, 542, 603, 475},
    bikes = {581, 521, 463, 522, 461, 448, 468, 586},
    bicycles = {509, 481, 510},
    default = {429, 541, 415, 480, 562, 565, 434, 411, 559, 561, 560, 506, 451, 558, 555, 477, 536, 575, 534, 567, 535, 576, 412, 402, 603, 475, 496, 533, 545, 517, 580, 467, 507, 445},
    helicopters = {548, 425, 417, 487, 488, 497, 563, 447, 469},
}

local effectNames = {
    "blood_heli","boat_prop","camflash","carwashspray","cement","cloudfast","coke_puff","coke_trail","cigarette_smoke",
    "explosion_barrel","explosion_crate","explosion_door","exhale","explosion_fuel_car","explosion_large","explosion_medium",
    "explosion_molotov","explosion_small","explosion_tiny","extinguisher","flame","fire","fire_med","fire_large","flamethrower",
    "fire_bike","fire_car","gunflash","gunsmoke","insects","heli_dust","jetpack","jetthrust","nitro","molotov_flame",
    "overheat_car","overheat_car_electric","prt_blood","prt_boatsplash","prt_bubble","prt_cardebris","prt_collisionsmoke",
    "prt_glass","prt_gunshell","prt_sand","prt_sand2","prt_smokeII_3_expand","prt_smoke_huge","prt_spark","prt_spark_2",
    "prt_splash","prt_wake","prt_watersplash","prt_wheeldirt","petrolcan","puke","riot_smoke","spraycan","smoke30lit","smoke30m",
    "smoke50lit","shootlight","smoke_flare","tank_fire","teargas","teargasAD","tree_hit_fir","tree_hit_palm","vent","vent2",
    "water_hydrant","water_ripples","water_speed","water_splash","water_splash_big","water_splsh_sml","water_swim","waterfall_end",
    "water_fnt_tme","water_fountain","wallbust","WS_factorysmoke"
}

local function getPositionFromElementOffset(element,offX,offY,offZ)
    if not isElement(element) then return false end
    local m = getElementMatrix(element)  -- Get the matrix
    
    if not m then return false end
    
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z  -- Return the transformed point
end

local function getRotationMatrix(element)
    if not isElement(element) then return false end
    local m = getElementMatrix(element)
    if not m then return false end
    
    local rx = math.atan2(m[3][2], m[3][3]) * 180 / math.pi
    local ry = math.atan2(-m[3][1], math.sqrt(m[3][2] * m[3][2] + m[3][3] * m[3][3])) * 180 / math.pi
    local rz = math.atan2(m[2][1], m[1][1]) * 180 / math.pi
    
    return rx, ry, rz
end

local function attachEffect(effect, element, pos, rot)
    if not isElement(effect) or not isElement(element) then
        return false, "Invalid element"
    end
    
    attachedEffects[effect] = { effect = effect, element = element, pos = pos, rot = rot }
    addEventHandler("onClientElementDestroy", effect, function() attachedEffects[effect] = nil end)
    addEventHandler("onClientElementDestroy", element, function() attachedEffects[effect] = nil end)
    return true
end

local function attachSearchlight(searchlight, element, pos)
    if not isElement(searchlight) or not isElement(element) then
        return false, "Invalid element"
    end
    
    attachedSearchlights[searchlight] = { searchlight = searchlight, element = element, pos = pos }
    addEventHandler("onClientElementDestroy", searchlight, function() attachedSearchlights[searchlight] = nil end)
    addEventHandler("onClientElementDestroy", element, function() attachedSearchlights[searchlight] = nil end)
    return true
end

local function renderAttachedEffects()
    for fx, info in pairs(attachedEffects) do
        if isElement(info.element) then
            local x, y, z = getPositionFromElementOffset(info.element, info.pos.x, info.pos.y, info.pos.z)
            if x and y and z then
                setElementPosition(fx, x, y, z)
            end
            if info.rot then
                local baseRx, baseRy, baseRz = getRotationMatrix(info.element)
                if baseRx then
                    local finalRx = (baseRx + info.rot.x) % 360
                    local finalRy = (baseRy + info.rot.y) % 360
                    local finalRz = (baseRz + info.rot.z) % 360
                    setElementRotation(fx, finalRx, finalRy, finalRz)
                end
            end
        end
    end
end

local function processTable(input, defaultVector)
    if type(table) == "table" then
        return Vector3(input[1] or 0, input[2] or 0, input[3] or 0)
    else
        return defaultVector or Vector3(0, 0, 0)
    end
end

function dxDraw3DText(text, x, y, z, scale, font, color, maxDistance, colorCoded)
    if not (x and y and z) then
        outputDebugString("dxDraw3DText: One of the world coordinates is missing", 1);
        return false
    end

    scale = scale or 2
    font = font or "default"
    color = color or tocolor(255, 255, 255, 255)
    maxDistance = maxDistance or 12
    colorCoded = colorCoded or false

    local pX, pY, pZ = getElementPosition(localPlayer)
    local distance = getDistanceBetweenPoints3D(pX, pY, pZ, x, y, z)

    if distance <= maxDistance then
        local screenX, screenY = getScreenFromWorldPosition(x, y, z)
        if screenX and screenY then
            dxDrawText(text, screenX, screenY, _, _, color, scale, font, "center", "center", false, false, false, colorCoded)
            return true
        end
    end
end

function simulateWheelRotation(vehicle, direction, speed)
    if not isElement(vehicle) then return end

    local currentRotation = getVehicleComponentRotation(vehicle, "wheel_rf_dummy") -- just get any tire
    local rotationChange = direction * speed
    local newRotation = currentRotation + rotationChange

    setVehicleWheelsRotation(vehicle, newRotation)
end

function readPathFromFile(filePath, reverse, mirror, offset, rotation)
    local file = fileOpen(filePath)
    if not file then
        outputDebugString("Failed to open file: " .. filePath)
        return nil
    end

    local content = fileRead(file, fileGetSize(file))
    fileClose(file)

    local path = fromJSON(content)
    if not path then
        outputDebugString("Failed to parse JSON from file: " .. filePath)
        return nil
    end

    --Flatten the path array
    local flattenedPath = {}
    for i, pointArray in ipairs(path) do
        for j, point in ipairs(pointArray) do
            table_insert(flattenedPath, point)
        end
    end

    local newPath = {}
    for i, point in ipairs(flattenedPath) do
        newPath[i] = {
            x = point.x,
            y = point.y,
            z = point.z,
            rx = point.rx,
            ry = point.ry,
            rz = point.rz,
            cl = point.cl,
            cr = point.cr
        }
    end

    -- Reverse the path if the reverse option is true
    if reverse then
        local reversedPath = {}
        for i = #newPath, 1, -1 do
            table_insert(reversedPath, newPath[i])
        end
        newPath = reversedPath
    end
    
    -- Mirror the path if a mirror axis is specified
    if mirror then
        local pOffset = Vector3(newPath[1].x + offset.x, newPath[1].y + offset.y, newPath[1].z + offset.z)
        local rot = Vector3(rotation.x, rotation.y, rotation.z)
        local pivot = Vector3(newPath[1].x, newPath[1].y, newPath[1].z)
        local rad = Vector3(rad(rot.x), rad(rot.y), rad(rot.z))
        
        for i, point in ipairs(newPath) do
            if mirror == "x" then
                point.y = -point.y + 2 * pOffset.y
                point.x = point.x + offset.x
                point.z = point.z + offset.z
                if point.rz then point.rz = (180 - point.rz) % 360 end
                if point.rx then point.rx = (360 - point.rx) % 360 end
            elseif mirror == "y" then
                point.x = -point.x + 2 * pOffset.x
                point.y = point.y + offset.y
                point.z = point.z + offset.z
                if point.rz then point.rz = (360 - point.rz) % 360 end
                if point.ry then point.ry = (360 - point.ry) % 360 end
            elseif mirror == "z" then
                point.z = -point.z + 2 * pOffset.z
                point.x = point.x + offset.x
                point.y = point.y + offset.y
                if point.rx then point.rx = (360 - point.rx) % 360 end
                if point.ry then point.ry = (180 - point.ry) % 360 end
            end

            if rotation then
                local x = point.x - pivot.x
                local y = point.y - pivot.y
                local z = point.z - pivot.z

                if rot.x ~= 0 then
                    x, y, z = x, y * cos(rad.x) - z * sin(rad.x), y * sin(rad.x) + z * cos(rad.x)
                elseif rot.y ~= 0 then
                    x, y, z = x * cos(rad.y) + z * sin(rad.y), y, -x * sin(rad.y) + z * cos(rad.y)
                elseif rot.z ~= 0 then
                    x, y, z = x * cos(rad.z) - y * sin(rad.z), x * sin(rad.z) + y * cos(rad.z), z
                end

                point.x = x + pivot.x
                point.y = y + pivot.y
                point.z = z + pivot.z

                if point.rx then point.rx = (point.rx + rot.x) % 360 end
                if point.ry then point.ry = (point.ry + rot.y) % 360 end
                if point.rz then point.rz = (point.rz + rot.z) % 360 end
            end

            -- Adjust control states if they exist (for steering)
            if point.cl and point.cr then
                local temp = point.cl
                point.cl = point.cr
                point.cr = temp
            end
        end
    end

    return newPath
end

function readDataFromFile(filePath)
    local file = fileOpen(filePath)
    if not file then
        outputDebugString("Failed to open file: " .. filePath)
        return nil
    end
    
    local jsonData = fileRead(file, fileGetSize(file))
    fileClose(file)
    
    local data = fromJSON(jsonData)
    if not data then
        outputDebugString("Failed to parse JSON from file: " .. filePath)
        return nil
    end
    
    return data
end

function createOccupiedVehicleAndMoveOverPath(
    marker, 
    pedID, 
    vehicleID, 
    filePath, 
    heightOffset, 
    destroyVehicle, 
    sirenLights, 
    searchlightFollowsPlayer, 
    searchlightOffset, 
    adjustableProperty, 
    adjPropValue, 
    interpolateAdjProp, 
    startValue, 
    endValue, 
    duration, 
    reversePath, 
    endlessVehicles, 
    endlessVehiclesGroup, 
    endlessVehiclesDelay, 
    objectDataPath, 
    effectDataPath, 
    vehicleDataPath,
    textDataPath,
    mirrorPath,
    mirrorOffset,
    endlessVehiclesPeds,
    mirrorRotation
)

    --Set default values for optional arguments if not provided
    marker = marker or nil
    heightOffset = heightOffset or 0 --might be needed for certain vehicles
    destroyVehicle = destroyVehicle or false
    searchlightFollowsPlayer = searchlightFollowsPlayer or false
    sirenLights = sirenLights or false
    searchlightOffset = searchlightOffset or {0, 0, 0}
    adjustableProperty = adjustableProperty or false
    adjPValue = adjPropValue or 0
    interpolateAdjProp = interpolateAdjProp or false
    startValue = startValue or 0
    endValue = endValue or 2500
    duration = duration or 3000
    reversePath = reversePath or false
    endlessVehicles = endlessVehicles or false
    endlessVehiclesGroup = endlessVehiclesGroup or vehicleGroups.default
    endlessVehiclesDelay = endlessVehiclesDelay or 1000
    objectDataPath = objectDataPath or nil
    effectDataPath = effectDataPath or nil
    vehicleDataPath = vehicleDataPath or nil
    textDataPath = textDataPath or nil
    mirrorPath = mirrorPath or nil
    mirrorOffset = mirrorOffset or {0, 0, 0}
    endlessVehiclesPeds = endlessVehiclesPeds or false
    mirrorRotation = mirrorRotation or {0, 0, 0}

    if objectDataPath ~= nil then
        objectData = readDataFromFile(objectDataPath)
    end

    if effectDataPath ~= nil then
        effectData = readDataFromFile(effectDataPath)
    end

    if vehicleDataPath ~= nil then
        vehicleData = readDataFromFile(vehicleDataPath)
    
        for i, data in ipairs(vehicleData) do
            overrideVehicleLights = data.overrideVehicleLights or "nil"
            vRotX, vRotY, vRotZ = data.rotX or 0, data.rotY or 0, data.rotZ or 0
    
            -- Vehicle Wheel States
            if data.wheelStates and data.wheelStates ~= nil then
                if type(data.wheelStates) == "table" then
                    frontLeft = data.wheelStates.frontLeft or 0
                    rearLeft = data.wheelStates.rearLeft or 0
                    frontRight = data.wheelStates.frontRight or 0
                    rearRight = data.wheelStates.rearRight or 0
                else
                    wheelStates = data.wheelStates or 0
                end
            end
    
            -- Vehicle Wheel Size
            if data.wheelSize and data.wheelSize ~= nil then
                if type(data.wheelSize) == "table" then
                    wheelSizeAxle = data.wheelSize.axle or "all_wheels"
                    wheelSizeValue = data.wheelSize.size or 1
                end
            end

            if data.vehicleSmokeTrail then
                vehicleSmokeTrail = data.vehicleSmokeTrail or false
            end
    
            -- Vehicle Alpha
            vehicleAlpha = data.vehicleAlpha or 255
        end
    end

    if textDataPath ~= nil then
        textData = readDataFromFile(textDataPath)
    end

    if mirrorOffset then mirrorOffset = processTable(mirrorOffset, Vector3(0, 0, 0)) end
    if mirrorRotation then mirrorRotation = processTable(mirrorRotation, Vector3(0, 0, 0)) end
    if searchlightOffset then searchlightOffset = processTable(searchlightOffset, Vector3(0, 0, 0)) end

    local path = readPathFromFile(filePath, reversePath, mirrorPath, mirrorOffset, mirrorRotation)
    if not path then
        outputDebugString("Failed to read path from file: " .. filePath)
        return
    end

    if #path == 0 then
        outputDebugString("Path is empty: " .. filePath)
        return
    end

    --Function to start movement of vehicle along path every time the marker is hit
    --anything else is also handled inside here
    local instanceTrackerID = tostring(getTickCount())
    if not activeInstancesTracker then activeInstancesTracker = {} end
    activeInstancesTracker[instanceTrackerID] = {}

    local elements = {}
    function destroyInstance(instance)
        if not instance then return end

        instance.isBeingDestroyed = true
        instance.isMoving = false

        for tableName, tableRef in pairs({searchlights = searchlights, attachedObjects = attachedObjects, attachedEffects = attachedEffects, activeInstances = activeInstances, attachedTexts = attachedTexts}) do
            for i = #tableRef, 1, -1 do
                if tableRef[i] == instance then
                    table_remove(tableRef, i)
                    break
                end
            end
        end

        if activeInstancesTracker[instanceTrackerID] then
            for i = #activeInstancesTracker[instanceTrackerID], 1, -1 do
                if activeInstancesTracker[instanceTrackerID][i] == instance then
                    table_remove(activeInstancesTracker[instanceTrackerID], i)
                    break
                end
            end
        end

        if instance.ped and isElement(instance.ped) then
            table_insert(elements, instance.ped)
        end
        if instance.vehicle and isElement(instance.vehicle) then
            table_insert(elements, instance.vehicle)
        end
        if instance.searchlight and isElement(instance.searchlight) then
            table_insert(elements, instance.searchlight)
        end
        if instance.objects then
            for _, obj in ipairs(instance.objects) do
                if isElement(obj) then
                    table_insert(elements, obj)
                end
            end
        end
        if instance.effects then
            for _, effect in ipairs(instance.effects) do
                if isElement(effect) then
                    table_insert(elements, effect)
                end
            end
        end

        for _, element in ipairs(elements) do
            if isElement(element) then
                destroyElement(element)
            end
        end
    end
    
    local function createElementInstance(path, endlessVehiclesGroup)
        local instance = {}
        instance.isMoving = false

        if not endlessVehicles then
            instance.ped = createPed(pedID, path[1].x, path[1].y, path[1].z)

            instance.vehicle = createVehicle(vehicleID, path[1].x, path[1].y, path[1].z + heightOffset, path[1].rx + (vRotX or 0), path[1].ry + (vRotY or 0), path[1].rz + (vRotZ or 0))
            setVehicleEngineState(instance.vehicle, true)
            setVehicleOverrideLights(instance.vehicle, overrideVehicleLights or 2)
            warpPedIntoVehicle(instance.ped, instance.vehicle)
            
            if wheelStates then
                setVehicleWheelStates(instance.vehicle, wheelStates)
            elseif frontLeft and rearLeft and frontRight and rearRight then
                setVehicleWheelStates(instance.vehicle, frontLeft, rearLeft, frontRight, rearRight)
            end

            if vehicleSmokeTrail then
                setVehicleSmokeTrailEnabled(instance.vehicle, true)
            end

            if vehicleAlpha then
                setElementAlpha(instance.vehicle, vehicleAlpha)
                setElementAlpha(instance.ped, vehicleAlpha)
            end

            setTimer(function()
                setElementFrozen(instance.vehicle, true)
                setElementFrozen(instance.ped, true)
            end, 100, 1)
        else

            if type(endlessVehiclesGroup) == "string" then
                if vehicleGroups[endlessVehiclesGroup] then
                    endlessVehiclesGroup = vehicleGroups[endlessVehiclesGroup]
                elseif endlessVehiclesGroup == "" or endlessVehiclesGroup:sub(-5) == ".json" then
                    endlessVehiclesGroup = readDataFromFile(endlessVehiclesGroup)
                else
                    endlessVehiclesGroup = vehicleGroups.default
                end
            end
            
            vehicleID = endlessVehiclesGroup[math_random(#endlessVehiclesGroup)]
            instance.vehicle = createVehicle(vehicleID, path[1].x, path[1].y, path[1].z + heightOffset, path[1].rx + (vRotX or 0), path[1].ry + (vRotY or 0), path[1].rz + (vRotZ or 0))
            setVehicleEngineState(instance.vehicle, true)
            setVehicleOverrideLights(instance.vehicle, overrideVehicleLights or 2)

            if endlessVehiclesPeds then
                pedID = pedIds[math_random(#pedIds)]
                instance.ped = createPed(pedID, path[1].x, path[1].y, path[1].z)
                warpPedIntoVehicle(instance.ped, instance.vehicle)
            end

            if wheelStates then
                setVehicleWheelStates(instance.vehicle, wheelStates)
            elseif frontLeft and rearLeft and frontRight and rearRight then
                setVehicleWheelStates(instance.vehicle, frontLeft, rearLeft, frontRight, rearRight)
            end

            if vehicleSmokeTrail then
                setVehicleSmokeTrailEnabled(instance.vehicle, true)
            end

            if vehicleAlpha then
                setElementAlpha(instance.vehicle, vehicleAlpha)
                if endlessVehiclesPeds then
                    setElementAlpha(instance.ped, vehicleAlpha)
                end
            end
        end

        --Create searchlight for vehicle
        if searchlightFollowsPlayer then
            instance.searchlight = createSearchLight(path[1].x + searchlightOffset.x, path[1].y + searchlightOffset.y, path[1].z + searchlightOffset.z, 0, 0, 0, 0, 15, true)
            instance.followsPlayer = searchlightFollowsPlayer
            attachSearchlight(instance.searchlight, instance.vehicle, {x = searchlightOffset.x, y = searchlightOffset.y, z = searchlightOffset.z})
            table_insert(searchlights, instance)
        end
        
        for i, emergencyVehicle in ipairs(vehicleGroups.emergency) do
            if vehicleID == emergencyVehicle and sirenLights then
                setVehicleSirensOn(instance.vehicle, true)
                break
            end
        end

        for i, aircraft in ipairs(vehicleGroups.aircraft) do
            if vehicleID == aircraft then
                setVehicleLandingGearDown(instance.vehicle, false)
                break
            end
        end

        if (vehicleID == 590 or vehicleID == 538 or vehicleID == 570 or vehicleID == 569 or vehicleID == 537 or vehicleID == 449) then
            setTrainDerailed(instance.vehicle, true)
        end

        if (vehicleID == 438 or vehicleID == 420) then
            setVehicleTaxiLightOn(instance.vehicle, true)
        end

        if (vehicleID == 520 or vehicleID == 406 or vehicleID == 443 or vehicleID == 530) and adjustableProperty then
            setVehicleAdjustableProperty(instance.vehicle, adjPValue)
            if interpolateAdjProp then
                local function interpolateProperty(vehicle, startValue, endValue, duration)
                    local startTime = getTickCount()
                    local function updateProperty()
                        local currentTime = getTickCount()
                        local elapsedTime = currentTime - startTime
                        local progress = elapsedTime / duration
                        if progress > 1 then progress = 1 end
                        local currentValue = startValue + (endValue - startValue) * progress
                        setVehicleAdjustableProperty(vehicle, currentValue)
                        if progress < 1 then
                            setTimer(updateProperty, 50, 1)
                        end
                    end
                    updateProperty()
                end
                interpolateProperty(instance.vehicle, startValue, endValue, duration)
            end
        end

        if objectData and vehicleID ~= 406 then
            --outputDebugString("Object data: " .. toJSON(objectData))
            instance.objects = {}
            for i, data in ipairs(objectData) do

                local isVehcle = false

                for i, vehicle in ipairs(vehicleIds) do
                    if vehicle == data.objectID then
                        isVehcle = true
                        break
                    end
                end
                --outputDebugString("Data entry: " .. toJSON(data))
                if isVehcle then

                    local attachedVehicle = createVehicle(data.objectID, path[1].x + data.offsetX, path[1].y + data.offsetY, path[1].z + data.offsetZ, 0, 0, 0)
                    setElementCollisionsEnabled(attachedVehicle, false)
                    setVehicleEngineState(attachedVehicle, true)
                    setVehicleOverrideLights(attachedVehicle, overrideVehicleLights or 2)
                    setVehicleLandingGearDown(attachedVehicle, false) -- does not seem to work if you reenter the marker?
                    
                    if endlessVehicles then
                        local pedID = pedIds[math_random(#pedIds)]
                        ped = createPed(pedID, path[1].x + data.offsetX, path[1].y + data.offsetY, path[1].z + data.offsetZ)
                    else
                        ped = createPed(data.PedID or 0, path[1].x + data.offsetX, path[1].y + data.offsetY, path[1].z + data.offsetZ)
                    end

                    warpPedIntoVehicle(ped, attachedVehicle)
                    attachElements(attachedVehicle, instance.vehicle, data.offsetX, data.offsetY, data.offsetZ, data.rotX, data.rotY, data.rotZ)


                    table_insert(instance.objects, attachedVehicle)
                    table_insert(instance.objects, ped)

                else
                    local object = createObject(data.objectID, path[1].x + data.offsetX, path[1].y + data.offsetY, path[1].z + data.offsetZ, 0, 0, 0)
                    setElementCollisionsEnabled(object, false)
                    setElementDoubleSided(object, true)
                    setObjectBreakable(object, false)

                    setObjectScale(object, data.scaleX, data.scaleY, data.scaleZ)
                    attachElements(object, instance.vehicle, data.offsetX, data.offsetY, data.offsetZ, data.rotX, data.rotY, data.rotZ)

                    table_insert(instance.objects, object)
                end
            end
            table_insert(attachedObjects, instance)
        end

        if effectData then
            instance.effects = {}
            for i, data in ipairs(effectData) do

                local effectID = data.effectID
                for j, effectName in ipairs(effectNames) do
                    if j == data.effectID then
                        effectID = effectName
                        break
                    end
                end

                if effectID then
                    local effect = createEffect(effectID, data.offsetX, data.offsetY, data.offsetZ, data.rotX, data.rotZ, 0)
                    setEffectDensity(effect, data.effectDensity)
                    setEffectSpeed(effect, data.effectSpeed)
                    attachEffect(effect, instance.vehicle, {x = data.offsetX, y = data.offsetY, z = data.offsetZ})
                    table_insert(instance.effects, effect)
                end
            end
        end

        if textData then
            for i, data in ipairs(textData) do
                local text = data.text
                local offsetX, offsetY, offsetZ = data.offsetX, data.offsetY, data.offsetZ
                local scale = data.size
                local font = data.font
                local r, g, b, a = data.colorRGBA.r, data.colorRGBA.g, data.colorRGBA.b, data.colorRGBA.a
                local color = tocolor(r, g, b, a)
                local maxDistance = data.distance
                local colorCoded = data.colorCoded

                table_insert(attachedTexts, {text = text, x = offsetX, y = offsetY, z = offsetZ, scale = scale, font = font, color = color, maxDistance = maxDistance, colorCoded = colorCoded})
            end
        end

        table_insert(activeInstances, instance)
        table_insert(activeInstancesTracker[instanceTrackerID], instance)
        return instance
    end

    local function moveVehicleAlongPath(instance, path, index)
        if instance.isBeingDestroyed then return end
        if not isElement(instance.vehicle) then return end
        
        if index > #path then
            if destroyVehicle then
                instance.isBeingDestroyed = true
                destroyInstance(instance)
                if not endlessVehicles then
                    setTimer(function() 
                        if activeInstancesTracker[instanceTrackerID] then
                            local newInstance = createElementInstance(path, endlessVehiclesGroup) 
                        end
                    end, 250, 1)
                end
            else
                if not endlessVehiclesPeds and endlessVehicles then
                    -- Skip ped controls if the vehicle is not occupied
                else
                    setPedControlState(instance.ped, "accelerate", false)
                    setPedControlState(instance.ped, "handbrake", true)
                    setPedAnalogControlState(instance.ped, "vehicle_left", 0)
                    setPedAnalogControlState(instance.ped, "vehicle_right", 0)
                end
                instance.isMoving = false
            end
            return
        end

        if isElementFrozen(instance.vehicle) then
            setElementFrozen(instance.vehicle, false)
            for i, heli in ipairs(vehicleGroups.helicopters) do
                if getElementModel(instance.vehicle) == heli then
                    setHelicopterRotorSpeed(instance.vehicle, 0.2)
                end
            end
        end
        if (isElement(instance.ped) and isElementFrozen(instance.ped)) then
            setElementFrozen(instance.ped, false)
        end
    
        if path[index] then
            setElementPosition(instance.vehicle, path[index].x, path[index].y, path[index].z + heightOffset)
            setElementRotation(instance.vehicle, path[index].rx + (vRotX or 0), path[index].ry + (vRotY or 0), path[index].rz + (vRotZ or 0))
            --outputChatBox("Vehicle position: " .. path[index].x .. ", " .. path[index].y .. ", " .. path[index].z + heightOffset)
            if isElement(instance.ped) then
                if path[index].cl and path[index].cl > 0 then
                    setPedAnalogControlState(instance.ped, "vehicle_left", path[index].cl)
                elseif path[index].cr then
                    setPedAnalogControlState(instance.ped, "vehicle_right", path[index].cr)
                end
            end

            if instance.objects then
                for _, ele in ipairs(instance.objects) do
                    if getElementType(ele) == "ped" then
                        if path[index].cl and path[index].cl > 0 then
                            setPedAnalogControlState(ele, "vehicle_left", path[index].cl)
                        elseif path[index].cr then
                            setPedAnalogControlState(ele, "vehicle_right", path[index].cr)
                        end
                    end
                    if getElementType(ele) == "vehicle" then
                        for i, aircraft in ipairs(vehicleGroups.aircraft) do
                            if getElementModel(ele) == aircraft then
                                setVehicleLandingGearDown(ele, false) --doesn't really work might have something to do with unfreezing the element vehicle
                                break
                            end
                        end
                    end
                end
            end
            
            if not instance.isBeingDestroyed and isElement(instance.vehicle) then
                setTimer(function()
                    moveVehicleAlongPath(instance, path, index + 1)
                end, 5, 1)
            end
        else
            instance.isMoving = false
        end
    end

    if not endlessVehicles then
        createElementInstance(path, endlessVehiclesGroup)
    else
        local function spawnVehicle()
            if activeInstancesTracker[instanceTrackerID] then
                local newInstance = createElementInstance(path, endlessVehiclesGroup)
                newInstance.isMoving = true
                if isElement(newInstance.ped) then
                    if not reversePath then
                        setPedControlState(newInstance.ped, "accelerate", true)
                    else
                        setPedControlState(newInstance.ped, "brake_reverse", true)
                    end
                end
                moveVehicleAlongPath(newInstance, path, 1)
                
                local nextDelay
                if type(endlessVehiclesDelay) == "table" and endlessVehiclesDelay[1] < endlessVehiclesDelay[2] then
                    nextDelay = math_random(endlessVehiclesDelay[1], endlessVehiclesDelay[2])
                elseif type(endlessVehiclesDelay) == "table" and endlessVehiclesDelay[1] > endlessVehiclesDelay[2] then
                    nextDelay = 1000
                else
                    nextDelay = endlessVehiclesDelay
                end
                setTimer(spawnVehicle, nextDelay, 1)
            end
        end

        local initialDelay = type(endlessVehiclesDelay) == "table" and endlessVehiclesDelay[1] or endlessVehiclesDelay
        setTimer(spawnVehicle, initialDelay, 1)
    end

    local function startOccupiedVehicleMovement(hitElement)
        if hitElement == localPlayer then
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
            if playerVehicle then
                if activeInstancesTracker[instanceTrackerID] then
                    for i, instance in ipairs(activeInstancesTracker[instanceTrackerID]) do
                        if not instance.isMoving and not instance.isBeingDestroyed then
                            instance.isMoving = true
                            if not reversePath then
                                if isElement(instance.ped) then
                                    setPedControlState(instance.ped, "accelerate", true)
                                end
                            else
                                if isElement(instance.ped) then
                                    setPedControlState(instance.ped, "brake_reverse", true)
                                end
                            end
                            moveVehicleAlongPath(instance, path, 1)
                            return
                        end
                    end
                end
            end
        end
    end

    if marker ~= nil then
        addEventHandler("onClientMarkerHit", marker, startOccupiedVehicleMovement)
    end
end

function renderAttachedSearchlights()
    for i, info in pairs(attachedSearchlights) do
        local x, y, z = getPositionFromElementOffset(info.element, info.pos.x, info.pos.y, info.pos.z)
        if x and y and z then
            setSearchLightStartPosition(i, x, y, z)
            if isPreviewActive then
                setSearchLightEndPosition(i, x, y, z - 10)
            else
                for j, instance in ipairs(activeInstances) do
                    if instance.followsPlayer and isElement(instance.searchlight) and isElement(instance.vehicle) then
                        local px, py, pz = getElementPosition(localPlayer)
                        setSearchLightEndPosition(i, px, py, pz)
                    end
                end
            end
        end
    end
end

function renderAttachedTexts()
    for i, instance in ipairs(activeInstances) do
        if isElement(instance.vehicle) then
            local x, y, z = getElementPosition(instance.vehicle)
            for j, data in ipairs(attachedTexts) do
                dxDraw3DText(data.text, x + data.x, y + data.y, z + data.z, data.scale, data.font, data.color, data.maxDistance, data.colorCoded)
            end
            if not isElement(instance.ped) then
                local direction = instance.reversePath and -1 or 1
                local speed = 5
                simulateWheelRotation(instance.vehicle, direction, speed)
            end
        end
    end
end

local function startPreRenderHandler()
    if not preRenderHandler then
        preRenderHandler = function()
            renderAttachedEffects()
            renderAttachedSearchlights()
            renderAttachedTexts()
        end
        addEventHandler("onClientPreRender", root, preRenderHandler)
    end
end
addEventHandler("onClientResourceStart", resourceRoot, startPreRenderHandler)

--Cleanup instances
addEventHandler("onClientResourceStop", resourceRoot, function()
    if activeInstancesTracker[instanceTrackerID] then
        for i, instance in ipairs(activeInstancesTracker[instanceTrackerID]) do
            destroyInstance(instance)
        end
        activeInstancesTracker[instanceTrackerID] = nil
    end

    if preRenderHandler then
        removeEventHandler("onClientPreRender", root, preRenderHandler)
        preRenderHandler = nil
    end
    
    attachedEffects = {}
    attachedSearchlights = {}
    attachedObjects = {}
    attachedTexts = {}
    searchlights = {}
    activeInstances = {}
    activeInstancesTracker = {}
end)
