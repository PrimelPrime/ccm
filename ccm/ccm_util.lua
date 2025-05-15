function getPositionFromElementOffset(element,offX,offY,offZ)
    if not isElement(element) then return false end
    local m = getElementMatrix(element)  -- Get the matrix
    
    if not m then return false end
    
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z  -- Return the transformed point
end

function getRotationMatrix(element)
    if not isElement(element) then return false end
    local m = getElementMatrix(element)
    if not m then return false end
    
    local rx = math.atan2(m[3][2], m[3][3]) * 180 / math.pi
    local ry = math.atan2(-m[3][1], math.sqrt(m[3][2] * m[3][2] + m[3][3] * m[3][3])) * 180 / math.pi
    local rz = math.atan2(m[2][1], m[1][1]) * 180 / math.pi
    
    return rx, ry, rz
end

function attachEffect(effect, element, pos, rot)
    if not isElement(effect) or not isElement(element) then
        return false, "Invalid element"
    end
    
    attachedEffectsPreview[effect] = { effect = effect, element = element, pos = pos, rot = rot }
    addEventHandler("onClientElementDestroy", effect, function() attachedEffectsPreview[effect] = nil end)
    addEventHandler("onClientElementDestroy", element, function() attachedEffectsPreview[effect] = nil end)
    return true
end

function attachSearchlight(searchlight, element, pos)
    if not isElement(searchlight) or not isElement(element) then
        return false, "Invalid element"
    end
    
    attachedSearchlights[searchlight] = { searchlight = searchlight, element = element, pos = pos }
    addEventHandler("onClientElementDestroy", searchlight, function() attachedSearchlights[searchlight] = nil end)
    addEventHandler("onClientElementDestroy", element, function() attachedSearchlights[searchlight] = nil end)
    return true
end

addEventHandler("onClientPreRender", root, function()
    for fx, info in pairs(attachedEffectsPreview) do
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
end)

setAircraftMaxHeight(100000)

-- Magnet Wheels
------------------
-- BY KRZYSZTOF --
------------------

function magnetWheels()
    progress = (getTickCount() - tick)/17
    tick = getTickCount()

    local vehicle = getPedOccupiedVehicle(localPlayer)

    if vehicle then
        local x,y,z = getElementPosition(vehicle)
        local vx,vy,vz = getElementVelocity(vehicle)
        local underx,undery,underz = getPositionFromElementOffset(vehicle,0,0,-1)
        local rayx,rayy,rayz = getPositionFromElementOffset(vehicle,0,0,-3)
        local hit = processLineOfSight ( x, y, z, rayx,rayy,rayz, true,false )

    	setElementHealth(vehicle, 1000)
    	setVehicleGravity(vehicle, 0, 0, 0)
    	setElementVelocity(vehicle, (underx - x)*currentBinds.magnetPower*progress+vx, (undery - y)*currentBinds.magnetPower*progress+vy, (underz - z)*currentBinds.magnetPower*progress+vz)

    	--prevent vehicle flying 
    	if hit then
    		fTick = getTickCount()
    	elseif (getTickCount() - fTick) > currentBinds.magnetFlyTolerance*1000 then  
    	    blowVehicle(vehicle)
    	    stopMagnets()
    	end
    end
end
	
function getPositionFromElementOffset(element,offX,offY,offZ)

    local m = getElementMatrix(element)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    do
    	return x,y,z
    end
end

function onWasted()
    local vehicle = getPedOccupiedVehicle(source)
    if vehicle then
        local gx,gy,gz = getVehicleGravity(vehicle)
        if gx == 0 and gy == 0 and gz == -1 then return end
        stopMagnets()
    end
end
addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), onWasted )

function stopMagnets()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    removeEventHandler("onClientRender", root, magnetWheels)
    setVehicleGravity(vehicle, 0, 0, -1)
    tick = nil
end
addEventHandler("onClientResourceStop", resourceRoot, stopMagnets)

function switchMagnetWheels(key, state)
    if isMTAWindowActive() or DGS:dgsGetInputMode() == "no_binds" or isInGuiEditField then return end

    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        if key == currentBinds.magnetWheels and state then
            if not tick then
                tick = getTickCount()
                fTick = getTickCount()
                addEventHandler("onClientRender", root, magnetWheels)
                outputChatBox("#D7DF01INFO#FFFFFF: Magnet Wheels activated.", 255, 255, 255, true)
            else
                stopMagnets()
                outputChatBox("#D7DF01INFO#FFFFFF: Magnet Wheels deactivated.", 255, 255, 255, true)
            end
        end
    end
end
addEventHandler("onClientKey", root, switchMagnetWheels)