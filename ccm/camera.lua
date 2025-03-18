local keyStates = {}
local rotationSpeed = 2
local zoomSpeed = 0.5
local minCameraDistance = 3
local maxCameraDistance = 50

function onCameraKey(key, state)
    if isMenuOpen and not isInEditField then
        for bindName, bindKey in pairs(currentBinds) do
            if key == bindKey then
                keyStates[bindKey] = state
            end
        end
    end
end
addEventHandler("onClientKey", root, onCameraKey)

function calculateInitialAngles()
    local playerVehicle = getPedOccupiedVehicle(localPlayer)
    if not playerVehicle then return end
    
    local tx, ty, tz = getElementPosition(playerVehicle)
    local cx, cy, cz = getCameraMatrix()
    
    local dx = cx - tx
    local dy = cy - ty
    local dz = cz - tz
    
    cameraDistance = math.sqrt(dx^2 + dy^2 + dz^2)
    
    cameraAngleX = math.deg(math.atan2(dx, dy))
    if cameraAngleX < 0 then
        cameraAngleX = cameraAngleX + 360
    end

    local groundDist = math.sqrt(dx^2 + dy^2)
    cameraAngleY = math.deg(math.atan2(dz, groundDist))
end

function updateCamera()
    local playerVehicle = getPedOccupiedVehicle(localPlayer)
    if not playerVehicle then return end
    if isMenuOpen then
        if keyStates[currentBinds.cameraLeft] then
            cameraAngleX = cameraAngleX - rotationSpeed
        end
        if keyStates[currentBinds.cameraRight] then
            cameraAngleX = cameraAngleX + rotationSpeed
        end
        if keyStates[currentBinds.cameraDown] then
            cameraAngleY = cameraAngleY - rotationSpeed
        end
        if keyStates[currentBinds.cameraUp] then
            cameraAngleY = cameraAngleY + rotationSpeed
        end
        if keyStates[currentBinds.cameraZoomIn] then
            cameraDistance = math.max(minCameraDistance, cameraDistance - zoomSpeed)
        end
        if keyStates[currentBinds.cameraZoomOut] then
            cameraDistance = math.min(maxCameraDistance, cameraDistance + zoomSpeed)
        end

        cameraAngleY = math.max(-89, math.min(89, cameraAngleY))
        cameraAngleX = cameraAngleX % 360

        local vehicle = getPedOccupiedVehicle(localPlayer)
        if not vehicle then return end
        
        local px, py, pz = getElementPosition(vehicle)
        local radX = math.rad(cameraAngleX)
        local radY = math.rad(cameraAngleY)
        
        local offsetX = cameraDistance * math.cos(radY) * math.sin(radX)
        local offsetY = cameraDistance * math.cos(radY) * math.cos(radX)
        local offsetZ = cameraDistance * math.sin(radY)
        
        local cameraX = px + offsetX
        local cameraY = py + offsetY
        local cameraZ = pz + offsetZ
        
        setCameraMatrix(cameraX, cameraY, cameraZ, px, py, pz)
    end
end
addEventHandler("onClientPreRender", root, updateCamera)