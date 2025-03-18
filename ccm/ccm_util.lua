
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