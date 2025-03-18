function getAllResources()

	local resource_array = {}
    local currentResourceName = getResourceName(getThisResource())
	for i,resource in pairs(getResources()) do		
		local name = getResourceName(resource)	
		if name and name ~= currentResourceName then	
		    table.insert(resource_array,name)
        end
	end

	if #resource_array ~= 0 then
		triggerClientEvent("onClientResourcesGet", root, resource_array)
	end

end
addEvent("onServerResourcesGet", true)
addEventHandler("onServerResourcesGet", root, getAllResources)

--Maybe in the future
--[[
local organizationalDir = "resources/[ccmResources]"

function createResource(resourceName)
    if not hasObjectPermissionTo(getThisResource(), "function.createResource") then  
        triggerClientEvent("onClientSaveMessage", source, 0)
        return
    end

    if resourceName then
        local resourceName = tostring(resourceName)
        local resourcePath = organizationalDir .. "/" .. resourceName
        local newResource = createResource(resourcePath)
        if newResource then
            --triggerClientEvent("onClientSaveMessage", source, 1)
            outputDebugString("Resource created: " .. resourceName)
        else
            --triggerClientEvent("onClientSaveMessage", source, 0)
        end
    else
        --triggerClientEvent("onClientSaveMessage", source, 0)
    end
end
addEvent("onCreateResource", true)
addEventHandler("onCreateResource", root, createResource)--]]
    

local utilName = "util.lua"
local scriptName = "ccm.lua"

local isFlushEnabled = false


addEvent("onFlushEnabledChange", true)
addEventHandler("onFlushEnabledChange", root, function(state)
    isFlushEnabled = state
end)

addEvent("onImportPaths", true)
addEventHandler("onImportPaths", root, function(memoText, mapName, stringFunction)
    if not hasObjectPermissionTo(getThisResource(), "general.ModifyOtherObjects") then  
        triggerClientEvent(source, "onClientSaveMessage", source, 0)
        return
    end

    local filesToDelete = {}
    local paths = {}
    local objectDataPaths = {}
    local effectDataPaths = {}
    local vehicleDataPaths = {}
    local textDataPaths = {}
    local vehicleGroupPaths = {}
    local objectDataPathSet = {}
    local effectDataPathSet = {}
    local vehicleDataPathSet = {}
    local textDataPathSet = {}
    local vehicleGroupPathSet = {}

    for line in memoText:gmatch("[^\r\n]+") do
        local fullLine = line

        if line:find("createOccupiedVehicleAndMoveOverPath") then
            local filePath = line:match('createOccupiedVehicleAndMoveOverPath%([^,]+, [^,]+, [^,]+, "([^"]+)"')
            if filePath then
                table.insert(paths, filePath)
            end

            local parameters = {}
            for param in line:gmatch('"([^"]+)"') do
                table.insert(parameters, param)
            end

            for _, param in ipairs(parameters) do
                if param:match("^objectData/") and not objectDataPathSet[param] then
                    outputDebugString("[CCM]: Found object data path: " .. param, 4, 100, 255, 100)
                    table.insert(objectDataPaths, param)
                    objectDataPathSet[param] = true
                elseif param:match("^effectData/") and not effectDataPathSet[param] then
                    outputDebugString("[CCM]: Found effect data path: " .. param, 4, 100, 255, 100)
                    table.insert(effectDataPaths, param)
                    effectDataPathSet[param] = true
                elseif param:match("^vehicleData/") and not vehicleDataPathSet[param] then
                    outputDebugString("[CCM]: Found vehicle data path: " .. param, 4, 100, 255, 100)
                    table.insert(vehicleDataPaths, param)
                    vehicleDataPathSet[param] = true
                elseif param:match("^textData/") and not textDataPathSet[param] then
                    outputDebugString("[CCM]: Found text data path: " .. param, 4, 100, 255, 100)
                    table.insert(textDataPaths, param)
                    textDataPathSet[param] = true
                elseif param:match("^vehicleGroups/") and not vehicleGroupPathSet[param] then
                    outputDebugString("[CCM]: Found vehicle group path: " .. param, 4, 100, 255, 100)
                    table.insert(vehicleGroupPaths, param)
                    vehicleGroupPathSet[param] = true
                end
            end
        end
    end

    for _, filePath in ipairs(paths) do
        local utilFile = ":" .. getResourceName(getThisResource()) .. "/util.lua"
        local utilFilePath = ":" .. mapName .. "/util.lua"
        local fileListPath = ":" .. getResourceName(getThisResource()) .."/".. filePath
        local fullPath = ":" .. mapName .. "/" .. filePath

        if not fileExists(utilFilePath) then
            fileCopy(utilFile, utilFilePath)
        else
            fileDelete(utilFilePath)
            fileCopy(utilFile, utilFilePath)
        end

        local xml = xmlLoadFile(":" .. mapName .. "/meta.xml")

        if xml then
            local metaNodes = xmlNodeGetChildren(xml)
            if metaNodes then
                if isFlushEnabled then
                    for i, node in ipairs(metaNodes) do
                        if node and xmlNodeGetName(node) == "file" then
                            local src = xmlNodeGetAttribute(node, "src")
                            if src and (src:find("^paths/") or src:find("^objectData/") or src:find("^vehicleGroups/") or src:find("^effectData/") or src:find("^vehicleData/") or src:find("^textData/")) then
                                table.insert(filesToDelete, xmlNodeGetAttribute(node, "src"))
                                xmlDestroyNode(node)
                            end
                        end
                    end
                    for _, file in ipairs(filesToDelete) do
                        local file = ":" .. mapName .. "/" .. file
                        if fileExists(file) then
                            fileDelete(file)
                            outputDebugString("[CCM]: Deleted file: " .. file, 4, 100, 255, 100)
                        end
                    end
                    xmlSaveFile(xml)
                    if not eventTriggered then
                        triggerClientEvent(source, "onClientSaveMessage", source, 2)
                        eventTriggered = true
                    end
                end
                    
                local fileExistsInMeta = {}
                local utilExistsInMeta = false
                local scriptExistsInMeta = false
                
                for _, node in ipairs(metaNodes) do
                    if node and xmlNodeGetName(node) then
                        local nodeName = xmlNodeGetName(node)
                        if nodeName == "file" then
                            local src = xmlNodeGetAttribute(node, "src")
                            if src == filePath then
                                fileExistsInMeta[filePath] = true
                            end
                            for _, objectDataPath in ipairs(objectDataPaths) do
                                if src == objectDataPath then
                                    fileExistsInMeta[objectDataPath] = true
                                end
                            end
                            for _, effectDataPath in ipairs(effectDataPaths) do
                                if src == effectDataPath then
                                    fileExistsInMeta[effectDataPath] = true
                                end
                            end
                            for _, vehicleDataPath in ipairs(vehicleDataPaths) do
                                if src == vehicleDataPath then
                                    fileExistsInMeta[vehicleDataPath] = true
                                end
                            end
                            for _, textDataPath in ipairs(textDataPaths) do
                                if src == textDataPath then
                                    fileExistsInMeta[textDataPath] = true
                                end
                            end
                            for _, vehicleGroupPath in ipairs(vehicleGroupPaths) do
                                if src == vehicleGroupPath then
                                    fileExistsInMeta[vehicleGroupPath] = true
                                end
                            end
                        elseif nodeName == "script" then
                            local src = xmlNodeGetAttribute(node, "src")
                            if src == utilName then
                                utilExistsInMeta = true
                            elseif src == scriptName then
                                scriptExistsInMeta = true
                            end
                        end
                    end
                end
        
                if not fileExistsInMeta[filePath] then
                    local newNode = xmlCreateChild(xml, "file")
                    xmlNodeSetAttribute(newNode, "src", filePath)
                end

                for _, objectDataPath in ipairs(objectDataPaths) do
                    if not fileExistsInMeta[objectDataPath] then
                        local newNode = xmlCreateChild(xml, "file")
                        xmlNodeSetAttribute(newNode, "src", objectDataPath)
                    end
                end

                for _, effectDataPath in ipairs(effectDataPaths) do
                    if not fileExistsInMeta[effectDataPath] then
                        local newNode = xmlCreateChild(xml, "file")
                        xmlNodeSetAttribute(newNode, "src", effectDataPath)
                    end
                end

                for _, vehicleDataPath in ipairs(vehicleDataPaths) do
                    if not fileExistsInMeta[vehicleDataPath] then
                        local newNode = xmlCreateChild(xml, "file")
                        xmlNodeSetAttribute(newNode, "src", vehicleDataPath)
                    end
                end

                for _, textDataPath in ipairs(textDataPaths) do
                    if not fileExistsInMeta[textDataPath] then
                        local newNode = xmlCreateChild(xml, "file")
                        xmlNodeSetAttribute(newNode, "src", textDataPath)
                    end
                end

                for _, vehicleGroupPath in ipairs(vehicleGroupPaths) do
                    if not fileExistsInMeta[vehicleGroupPath] then
                        local newNode = xmlCreateChild(xml, "file")
                        xmlNodeSetAttribute(newNode, "src", vehicleGroupPath)
                    end
                end
        
                if not utilExistsInMeta then
                    local newUtilNode = xmlCreateChild(xml, "script")
                    xmlNodeSetAttribute(newUtilNode, "src", utilName)
                    xmlNodeSetAttribute(newUtilNode, "type", "client")
                end
        
                if not scriptExistsInMeta then
                    local newScriptNode = xmlCreateChild(xml, "script")
                    xmlNodeSetAttribute(newScriptNode, "src", scriptName)
                    xmlNodeSetAttribute(newScriptNode, "type", "client")
                end
                
                xmlSaveFile(xml)
                xmlUnloadFile(xml)
                    
                if not eventTriggered then
                    triggerClientEvent(source, "onClientSaveMessage", source, 1)
                    eventTriggered = true
                end
            else
                outputDebugString("[CCM]: Failed to load meta.xml for map: " .. mapName, 0, 255, 100, 100)
                if not eventTriggered then
                    triggerClientEvent(source, "onClientSaveMessage", source, 0)
                    eventTriggered = true
                end
            end
            if not fileExists(fullPath) then
                fileCopy(fileListPath, fullPath)
            else
                fileDelete(fullPath)
                fileCopy(fileListPath, fullPath)
            end
        end
    end

    for _, objectDataPath in ipairs(objectDataPaths) do
        local objectDataFileListPath = ":" .. getResourceName(getThisResource()) .. "/" .. objectDataPath
        local objectDataFullPath = ":" .. mapName .. "/" .. objectDataPath

        if not fileExists(objectDataFullPath) then
            fileCopy(objectDataFileListPath, objectDataFullPath)
        else
            fileDelete(objectDataFullPath)
            fileCopy(objectDataFileListPath, objectDataFullPath)
        end
    end

    for _, effectDataPath in ipairs(effectDataPaths) do
        local effectDataFileListPath = ":" .. getResourceName(getThisResource()) .. "/" .. effectDataPath
        local effectDataFullPath = ":" .. mapName .. "/" .. effectDataPath

        if not fileExists(effectDataFullPath) then
            fileCopy(effectDataFileListPath, effectDataFullPath)
        else
            fileDelete(effectDataFullPath)
            fileCopy(effectDataFileListPath, effectDataFullPath)
        end
    end

    for _, vehicleDataPath in ipairs(vehicleDataPaths) do
        local vehicleDataFileListPath = ":" .. getResourceName(getThisResource()) .. "/" .. vehicleDataPath
        local vehicleDataFullPath = ":" .. mapName .. "/" .. vehicleDataPath

        if not fileExists(vehicleDataFullPath) then
            fileCopy(vehicleDataFileListPath, vehicleDataFullPath)
        else
            fileDelete(vehicleDataFullPath)
            fileCopy(vehicleDataFileListPath, vehicleDataFullPath)
        end
    end

    for _, textDataPath in ipairs(textDataPaths) do
        local textDataFileListPath = ":" .. getResourceName(getThisResource()) .. "/" .. textDataPath
        local textDataFullPath = ":" .. mapName .. "/" .. textDataPath

        if not fileExists(textDataFullPath) then
            fileCopy(textDataFileListPath, textDataFullPath)
        else
            fileDelete(textDataFullPath)
            fileCopy(textDataFileListPath, textDataFullPath)
        end
    end

    for _, vehicleGroupPath in ipairs(vehicleGroupPaths) do
        local vehicleGroupFileListPath = ":" .. getResourceName(getThisResource()) .. "/" .. vehicleGroupPath
        local vehicleGroupFullPath = ":" .. mapName .. "/" .. vehicleGroupPath

        if not fileExists(vehicleGroupFullPath) then
            fileCopy(vehicleGroupFileListPath, vehicleGroupFullPath)
        else
            fileDelete(vehicleGroupFullPath)
            fileCopy(vehicleGroupFileListPath, vehicleGroupFullPath)
        end
    end

    local scriptPath = ":" .. mapName .. "/" .. scriptName
    local scriptContent = ""

    if fileExists(scriptPath) then
        local scriptFile = fileOpen(scriptPath)
        if scriptFile then
            scriptContent = fileRead(scriptFile, fileGetSize(scriptFile))
            fileClose(scriptFile)
        end
    end

    local scriptFile = fileCreate(scriptPath)
    if scriptFile then
        if isFlushEnabled then
            fileWrite(scriptFile, stringFunction)
        else
            fileWrite(scriptFile, scriptContent .. "\n" .. stringFunction)
        end
        fileClose(scriptFile)
    else
        outputDebugString("[CCM]: Failed to create script file: " .. scriptPath, 0, 255, 100, 100)
    end
    eventTriggered = false
end)

--[[addEvent("onServerScriptSave", true)
addEventHandler("onServerScriptSave", root, getMeta)--]]

local activeRecordings = {}

addEvent("onStartRecordingWithArgs", true)
addEventHandler("onStartRecordingWithArgs", root, function(arguments)
    local client = source

    if activeRecordings[client] then
        activeRecordings[client].arguments = arguments
    end
end)

addEvent("onRequestFileCreation", true)
addEventHandler("onRequestFileCreation", root, function(filePath, argumentValues, objectsAttachedToVehicle, effectsAttachedToVehicle, vehicleData, textsAttachedToVehicle)
    local client = source
    outputDebugString("[CCM]: Received file creation request from client: " .. tostring(filePath), 4, 100, 255, 100)

    local basePaths = {
        main = "paths/" .. filePath .. ".json",
        object = "objectData/" .. filePath .. ".json",
        effect = "effectData/" .. filePath .. ".json",
        vehicle = "vehicleData/" .. filePath .. ".json",
        text = "textData/" .. filePath .. ".json"
    }

    local function getUniquePath(basePath)
        local uniquePath = basePath
        local count = 1
        
        while fileExists(uniquePath) do
            count = count + 1
            uniquePath = string.gsub(basePath, "%.json$", tostring(count) .. ".json")
        end
        
        return uniquePath
    end

    local paths = {}
    for key, basePath in pairs(basePaths) do
        paths[key] = getUniquePath(basePath)
    end
    
    outputDebugString("[CCM]: Using path: " .. paths.main, 4, 100, 255, 100)

    local hasObjects = objectsAttachedToVehicle and next(objectsAttachedToVehicle) ~= nil
    local hasEffects = effectsAttachedToVehicle and next(effectsAttachedToVehicle) ~= nil
    local hasVehicleData = vehicleData and next(vehicleData) ~= nil
    local hasTexts = textsAttachedToVehicle and next(textsAttachedToVehicle) ~= nil

    local success = addFileListEntry(
        paths.main, 
        argumentValues, 
        hasObjects and paths.object or nil,
        hasEffects and paths.effect or nil,
        hasVehicleData and paths.vehicle or nil,
        hasTexts and paths.text or nil
    )
    
    if not success then
        outputDebugString("[CCM]: Failed to add entry to file_list.json", 0, 255, 100, 100)
        return
    end

    local outputFile = fileCreate(paths.main)
    if not outputFile then
        outputDebugString("[CCM]: Failed to create output file: " .. paths.main, 0, 255, 100, 100)
        return
    end

    activeRecordings[client] = {
        file = outputFile,
        path = paths.main,
        isFirstEntry = true,
        arguments = argumentValues
    }

    if hasObjects then
        activeRecordings[client].objectPath = paths.object
    end

    if hasEffects then
        activeRecordings[client].effectPath = paths.effect
    end

    if hasVehicleData then
        activeRecordings[client].vehiclePath = paths.vehicle
    end

    if hasTexts then
        activeRecordings[client].textPath = paths.text
    end

    triggerClientEvent(client, "onFileCreationSuccess", client, paths.main)
    outputDebugString("[CCM]: File creation successful: " .. paths.main, 4, 100, 255, 100)

    local function createJSONFile(filePath, jsonData)
        local file = fileCreate(filePath)
        if file then
            fileWrite(file, toJSON(jsonData))
            fileClose(file)
            outputDebugString("[CCM]: File creation successful: " .. filePath, 4, 100, 255, 100)
            return true
        else
            outputDebugString("[CCM]: Failed to create file: " .. filePath, 0, 255, 100, 100)
            return false
        end
    end

    if hasObjects then
        createJSONFile(paths.object, objectsAttachedToVehicle)
    end

    if hasEffects then
        createJSONFile(paths.effect, effectsAttachedToVehicle)
    end

    if hasVehicleData then
        createJSONFile(paths.vehicle, vehicleData)
    end

    if hasTexts then
        createJSONFile(paths.text, textsAttachedToVehicle)
    end
end)

addEvent("onStartRecording", true)
addEventHandler("onStartRecording", root, function(initialData)
    local client = source
    if activeRecordings[client] and activeRecordings[client].file then
        fileWrite(activeRecordings[client].file, "[[" .. initialData)
        activeRecordings[client].isFirstEntry = false
    end
end)

addEvent("onRecordData", true)
addEventHandler("onRecordData", root, function(data)
    local client = source
    if activeRecordings[client] and activeRecordings[client].file then
        if not activeRecordings[client].isFirstEntry then
            fileWrite(activeRecordings[client].file, "," .. data)
        end
    end
end)

addEvent("onStopRecording", true)
addEventHandler("onStopRecording", root, function()
    local client = source
    if activeRecordings[client] and activeRecordings[client].file then
        fileWrite(activeRecordings[client].file, "]]")
        fileClose(activeRecordings[client].file)
        activeRecordings[client] = nil
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if activeRecordings[source] then
        if activeRecordings[source].file then
            fileClose(activeRecordings[source].file)
        end
        activeRecordings[source] = nil
    end
end)

addEvent("onRequestFileList", true)
addEventHandler("onRequestFileList", root, function()
    local client = source
    local directory = "paths/"
    local fileListPath = directory .. "file_list.json"
    local fileList = {}

    if not fileExists(fileListPath) then
        outputDebugString("[CCM]: File list does not exist, creating: 'file_list.json'", 4, 100, 255, 100)
        local newFile = fileCreate(fileListPath)
        if newFile then

            fileWrite(newFile, "[]")
            fileClose(newFile)
        else
            outputDebugString("[CCM]: Failed to create file_list.json", 0, 255, 100, 100)
            triggerClientEvent(client, "onReceiveFileList", client, {})
            return
        end
    end

    local file = fileOpen(fileListPath, true)
    if not file then
        outputDebugString("[CCM]: Failure to open 'file_list.json'", 0, 255, 100, 100)
        triggerClientEvent(client, "onReceiveFileList", client, {})
        return
    end

    local fileContent = fileRead(file, fileGetSize(file))
    fileClose(file)

    if fileContent and fileContent ~= "" then
        local success, data = pcall(fromJSON, fileContent)
        if success and type(data) == "table" then
            fileList = data
        else
            outputDebugString("[CCM]: Failed to parse JSON content", 0, 255, 100, 100)
        end
    end
    
    outputDebugString("[CCM]: Sending file list to client with " .. #fileList .. " entries", 4, 100, 255, 100)
    triggerClientEvent(client, "onReceiveFileList", client, fileList)
end)

function addFileListEntry(path, arguments, objectPath, effectPath, vehiclePath, textPath)
    local fileListPath = "paths/file_list.json"

    local file = fileOpen(fileListPath, true)
    if not file then return false end
    
    local content = fileRead(file, fileGetSize(file))
    fileClose(file)
    
    local fileList = {}
    if content and content ~= "" then
        local success, data = pcall(fromJSON, content)
        if success and type(data) == "table" then
            fileList = data
        end
    end

    local entry = {
        path = path,
        arguments = arguments or {}
    }

    if objectPath then
        entry.objectPath = objectPath
    end

    if effectPath then
        entry.effectPath = effectPath
    end
    
    if vehiclePath then
        entry.vehiclePath = vehiclePath
    end

    if textPath then
        entry.textPath = textPath
    end

    table.insert(fileList, entry)

    local file = fileCreate(fileListPath)
    if file then
        fileWrite(file, toJSON(fileList, true))
        fileClose(file)
        return true
    end
    
    return false
end

local markers = {}

function updateMarkersList()
    markers = {}
    local allMarkers = getElementsByType("marker")
    for i, marker in ipairs(allMarkers) do
        if isElement(marker) then
            local x, y, z = getElementPosition(marker)
            local id = getElementID(marker) or "unnamed"

            if id and id ~= "unnamed" and id ~= "" then
                x = math.floor(x * 100) / 100
                y = math.floor(y * 100) / 100
                z = math.floor(z * 100) / 100

                local displayText = string.format("%s (%.2f, %.2f, %.2f)", id, x, y, z)
                table.insert(markers, {
                    id = id,
                    position = {x = x, y = y, z = z},
                    displayText = displayText
                })
            end
        end
    end

    --outputDebugString("Markers to send: " .. toJSON(markers))

    triggerClientEvent("updateMarkersList", root, markers)
end

addEvent("requestMarkersList", true)
addEventHandler("requestMarkersList", root, updateMarkersList)

addEventHandler("onElementCreate", root, function()
    if getElementType(source) == "marker" then
        updateMarkersList()
    end
end)

local destroyingElement = false

addEventHandler("onElementDestroy", root, function()
    if getElementType(source) == "marker" then
        if isElement(source) and not destroyingElement then
            destroyingElement = true
            destroyElement(source)
            updateMarkersList()
            destroyingElement = false
        end
    end
end)

addEventHandler("onElementDataChange", root, function(dataName)
    if dataName == "id" and getElementType(source) == "marker" then
        updateMarkersList()
    end
end)

addEvent("onCreateVehicleGroup", true)
addEventHandler("onCreateVehicleGroup", root, function(groupName, vehicleIDs)
    if groupName and vehicleIDs then
        local groupPath = "vehicleGroups/" .. groupName .. ".json"
        local groupFile = fileCreate(groupPath)
        if groupFile then
            fileWrite(groupFile, toJSON(vehicleIDs))
            fileClose(groupFile)
            outputDebugString("[CCM]: Vehicle group created: " .. groupName, 4, 100, 255, 100)

            -- Update file_list.json
            local fileListPath = "vehicleGroups/file_list.json"
            local fileList = {}

            if fileExists(fileListPath) then
                local file = fileOpen(fileListPath, true)
                if file then
                    local fileContent = fileRead(file, fileGetSize(file))
                    fileClose(file)
                    if fileContent and fileContent ~= "" then
                        local success, data = pcall(fromJSON, fileContent)
                        if success and type(data) == "table" then
                            fileList = data
                        else
                            outputDebugString("[CCM]: Failed to parse JSON content from file_list.json", 0, 255, 100, 100)
                        end
                    end
                end
            end

            table.insert(fileList, groupName)
            local newFile = fileCreate(fileListPath)
            if newFile then
                fileWrite(newFile, toJSON(fileList))
                fileClose(newFile)
                outputDebugString("[CCM]: Updated file_list.json with new vehicle group: " .. groupName, 4, 100, 255, 100)
            else
                outputDebugString("[CCM]: Failed to update file_list.json", 0, 255, 100, 100)
            end
        else
            outputDebugString("[CCM]: Failed to create vehicle group: " .. groupName, 0, 255, 100, 100)
        end
    else
        outputDebugString("[CCM]: Invalid parameters for vehicle group creation", 0, 255, 100, 100)
    end
end)

addEvent("onRequestVehicleGroups", true)
addEventHandler("onRequestVehicleGroups", root, function()
    local client = source
    local directory = "vehicleGroups/"
    local fileListPath = directory .. "file_list.json"
    local fileList = {}

    if not fileExists(fileListPath) then
        outputDebugString("[CCM]: Vehicle group list does not exist, creating: 'file_list.json'", 4, 100, 255, 100)
        local newFile = fileCreate(fileListPath)
        if newFile then
            fileWrite(newFile, "[]")
            fileClose(newFile)
        else
            outputDebugString("[CCM]: Failed to create vehicle group list: 'file_list.json'", 0, 255, 100, 100)
            triggerClientEvent(client, "onReceiveVehicleGroups", client, {})
            return
        end
    end

    local file = fileOpen(fileListPath, true)
    if not file then
        outputDebugString("[CCM]: Failure to open 'file_list.json'", 0, 255, 100, 100)
        triggerClientEvent(client, "onReceiveVehicleGroups", client, {})
        return
    end

    local fileContent = fileRead(file, fileGetSize(file))
    fileClose(file)

    if fileContent and fileContent ~= "" then
        local success, data = pcall(fromJSON, fileContent)
        if success and type(data) == "table" then
            fileList = data
        else
            outputDebugString("[CCM]: Failed to parse JSON content", 0, 255, 100, 100)
        end
    end
    
    outputDebugString("[CCM]: Sending vehicle group list to client with " .. #fileList .. " entries", 4, 100, 255, 100)
    triggerClientEvent(client, "onReceiveVehicleGroups", client, fileList)
end)