--More or less a similar functionality of the attachElements function from MTA:SA
--Searchlight cant be attached to a vehicle, so we need to calculate the offset manually
function calculateOffset(baseElement, attachedElement)
    if not isElement(baseElement) or not isElement(attachedElement) then return 0, 0, 0 end
    local bx, by, bz = getElementPosition(baseElement)
    local ax, ay, az = getElementPosition(attachedElement)
    local rx, ry, rz = getElementRotation(baseElement)

    local dx, dy, dz = ax - bx, ay - by, az - bz
    local radX, radY, radZ = math.rad(rx), math.rad(ry), math.rad(rz)

    local cosZ, sinZ = math.cos(-radZ), math.sin(-radZ)
    local cosX, sinX = math.cos(-radX), math.sin(-radX)
    local cosY, sinY = math.cos(-radY), math.sin(-radY)

    local nx, ny = cosZ * dx - sinZ * dy, sinZ * dx + cosZ * dy
    dx, dy = nx, ny

    local nz = cosX * dz - sinX * dy
    dy, dz = cosX * dy + sinX * dz, nz

    nx = cosY * dx + sinY * dz
    dz = cosY * dz - sinY * dx
    dx = nx

    return dx, dy, dz
end

function applyOffset(baseElement, offsetX, offsetY, offsetZ)
    local bx, by, bz = getElementPosition(baseElement)
    local rx, ry, rz = getElementRotation(baseElement)

    local radX, radY, radZ = math.rad(rx), math.rad(ry), math.rad(rz)

    local nx = offsetX * math.cos(radY) - offsetZ * math.sin(radY)
    local nz = offsetX * math.sin(radY) + offsetZ * math.cos(radY)
    offsetX, offsetZ = nx, nz

    nz = offsetZ * math.cos(radX) - offsetY * math.sin(radX)
    offsetY = offsetZ * math.sin(radX) + offsetY * math.cos(radX)
    offsetZ = nz

    nx = offsetX * math.cos(radZ) - offsetY * math.sin(radZ)
    local ny = offsetX * math.sin(radZ) + offsetY * math.cos(radZ)
    offsetX, offsetY = nx, ny

    return bx + offsetX, by + offsetY, bz + offsetZ
end

function readPathFromFile(filePath)
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
            table.insert(flattenedPath, point)
        end
    end

    return flattenedPath
end

local aircraftIDs = {
    592, 577, 520, 553, 476, 519
}

local emergencyVehicles = {
    416, 427, 490, 528, 407, 544, 523, 596, 598, 599, 597
}

local searchlights = {}

function createOccupiedVehicleAndMoveOverPath(marker, pedID, vehicleID, filePath, heightOffset, destroyVehicle, sirenLights, searchlightFollowsPlayer, searchlightOffset, adjustableProperty, adjPropValue, interpolateAdjProp, startValue, endValue, duration)
    --Set default values for optional arguments if not provided
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
    --Read path from file
    local path = readPathFromFile(filePath)
    if not path then
        outputDebugString("Failed to read path from file: " .. filePath)
        return
    end

    if #path == 0 then
        outputDebugString("Path is empty: " .. filePath)
        return
    end

    local offsetX, offsetY, offsetZ
    if type(searchlightOffset) == "table" then
        --Table: offset = {offsetX, offsetY, offsetZ}
        offsetX = searchlightOffset[1] or 0
        offsetY = searchlightOffset[2] or 0
        offsetZ = searchlightOffset[3] or 0
    elseif type(searchlightOffset) == "number" then
        --Single Value: offset only returns offsetZ (Standard for X und Y: 0)
        offsetX, offsetY, offsetZ = 0, 0, searchlightOffset
    else
        error("Invalid offset format. Must be table {x, y, z} or single number.")
    end

    --Function to start movement of vehicle along path every time the marker is hit
    --anything else is also handled inside here
    function startOccupiedVehicleMovement(hitElement)
        if hitElement == localPlayer then
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
            if playerVehicle then

                local instance = {}
                

                local function destroyInstance()
                    if isElement(instance.ped) then destroyElement(instance.ped) end
                    if isElement(instance.vehicle) then destroyElement(instance.vehicle) end
                    if isElement(instance.searchlight) then destroyElement(instance.searchlight) end
                    for i = #searchlights, 1, -1 do
                        if searchlights[i] == instance then
                            table.remove(searchlights, i)
                            outputDebugString("Removed searchlight")
                            break
                        end
                    end
                end

                instance.ped = createPed(pedID, path[1].x, path[1].y, path[1].z)
                setPedControlState(instance.ped, "accelerate", true)

                instance.vehicle = createVehicle(vehicleID, path[1].x, path[1].y, path[1].z, path[1].rx, path[1].ry, path[1].rz + heightOffset)
                setVehicleEngineState(instance.vehicle, true)
                setVehicleOverrideLights(instance.vehicle, 2)
                warpPedIntoVehicle(instance.ped, instance.vehicle)

                --Create searchlight for vehicle
                if searchlightFollowsPlayer then
                    local sx, sy, sz = applyOffset(instance.vehicle, offsetX, offsetY, offsetZ)

                    instance.searchlight = createSearchLight(sx, sy, sz, 0, 0, 0, 0, 15, true)
                    instance.followsPlayer = searchlightFollowsPlayer
                    instance.offset = {calculateOffset(instance.vehicle, instance.searchlight)}
                    table.insert(searchlights, instance)
                end
                
                --Set siren lights on for emergency vehicles
                for i, emergencyVehicle in ipairs(emergencyVehicles) do
                    if vehicleID == emergencyVehicle and sirenLights then
                        setVehicleSirensOn(instance.vehicle, true)
                        break
                    end
                end


                --Set landing gear up for aircraft
                for i, aircraft in ipairs(aircraftIDs) do
                    if vehicleID == aircraft then
                        setVehicleLandingGearDown(instance.vehicle, false)
                        break
                    end
                end

                --Set taxi light on for taxi vehicles
                if (vehicleID == 438 or vehicleID == 420) then
                    setVehicleTaxiLightOn(instance.vehicle, true)
                end

                --Set adjustable property for certain vehicles
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

                --the move function
                local function moveVehicleAlongPath(index)
                    if index > #path then
                        if destroyVehicle then
                            destroyInstance()
                        else
                            setPedControlState(instance.ped, "accelerate", false)
                            setPedControlState(instance.ped, "handbrake", true)
                        end
                        return
                    end
                
                    if path[index] then
                        setElementPosition(instance.vehicle, path[index].x, path[index].y, path[index].z + heightOffset)
                        setElementRotation(instance.vehicle, path[index].rx, path[index].ry, path[index].rz)
                        setTimer(function()
                            moveVehicleAlongPath(index + 1)
                        end, 5, 1)
                    else
                        outputDebugString("Path index out of bounds: " .. tostring(index))
                    end
                end

                moveVehicleAlongPath(2)
            end
        end
    end

    addEventHandler("onClientMarkerHit", marker, startOccupiedVehicleMovement)
end

addEventHandler("onClientPreRender", root, function()
    for i, instance in ipairs(searchlights) do
        if instance.followsPlayer and isElement(instance.searchlight) and isElement(instance.vehicle) then
            local sx, sy, sz = applyOffset(instance.vehicle, unpack(instance.offset))

            setSearchLightStartPosition(instance.searchlight, sx, sy, sz)
            local px, py, pz = getElementPosition(localPlayer)
            setSearchLightEndPosition(instance.searchlight, px, py, pz)
        end
    end
end)