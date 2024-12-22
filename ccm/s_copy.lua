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
    outputDebugString("Flush enabled state changed to: " .. tostring(isFlushEnabled))
end)

addEvent("onImportPaths", true)
addEventHandler("onImportPaths", root, function(memoText, mapName, stringFunction)
    if not hasObjectPermissionTo(getThisResource(), "general.ModifyOtherObjects") then  
        triggerClientEvent(source, "onClientSaveMessage", source, 0)
        return
    end

    local paths = {}
    for line in memoText:gmatch("[^\r\n]+") do
        local filePath = line:match('createOccupiedVehicleAndMoveOverPath%([^,]+, [^,]+, [^,]+, "([^"]+)"')
        if filePath then
            table.insert(paths, filePath)
        end
    end

    for _, filePath in ipairs(paths) do
        local utilFile = ":" .. getResourceName(getThisResource()) .. "/util.lua"
        local utilFilePath = ":" .. mapName .. "/util.lua"
        local fileListPath = ":" .. getResourceName(getThisResource()) .."/".. filePath
        outputDebugString("fileListPath: "..fileListPath)
        local fullPath = ":" .. mapName .. "/" .. filePath

        if not fileExists(fullPath) then
            fileCopy(fileListPath, fullPath)
        else
            fileDelete(fullPath)
            fileCopy(fileListPath, fullPath)
        end

        if not fileExists(utilFilePath) then
            fileCopy(utilFile, utilFilePath)
        end

        local xml = xmlLoadFile(":" .. mapName .. "/meta.xml")

        if xml then
            local metaNodes = xmlNodeGetChildren(xml)
            local fileExistsInMeta = false
            local utilExistsInMeta = false
            local scriptExistsInMeta = false

            for i, node in ipairs(metaNodes) do
                if xmlNodeGetName(node) == "file" and xmlNodeGetAttribute(node, "src") == filePath then
                    fileExistsInMeta = true
                end
                if xmlNodeGetName(node) == "script" and xmlNodeGetAttribute(node, "src") == utilName then
                    utilExistsInMeta = true
                end
                if xmlNodeGetName(node) == "script" and xmlNodeGetAttribute(node, "src") == scriptName then
                    scriptExistsInMeta = true
                end
            end

            if not fileExistsInMeta then
                local newNode = xmlCreateChild(xml, "file")
                xmlNodeSetAttribute(newNode, "src", filePath)
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
            if not eventTriggered then
                triggerClientEvent(source, "onClientSaveMessage", source, 0)
                eventTriggered = true
            end
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
            fileWrite(scriptFile, stringFunction) -- Überschreibe die Datei
        else
            fileWrite(scriptFile, scriptContent .. "\n" .. stringFunction) -- Füge den neuen Inhalt hinzu
        end
        fileClose(scriptFile)
    else
        outputDebugString("Failed to create script file: " .. scriptPath, 1)
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
addEventHandler("onRequestFileCreation", root, function(filePath, argumentValues)
    local client = source
    outputDebugString("Received file creation request from client: " .. tostring(filePath))

    local fullPath = "paths/" .. filePath .. ".json"
    local fileCounts = 1

    while fileExists(fullPath) do
        fileCounts = fileCounts + 1
        fullPath = "paths/" .. filePath .. tostring(fileCounts) .. ".json"
    end
    
    outputDebugString("Using path: " .. fullPath)

    local success = addFileListEntry(fullPath, argumentValues)
    if not success then
        outputDebugString("Failed to add entry to file_list.json", 1)
        return
    end

    local outputFile = fileCreate(fullPath)
    if outputFile then
        activeRecordings[client] = {
            file = outputFile,
            path = fullPath,
            isFirstEntry = true,
            arguments = argumentValues
        }
        triggerClientEvent(client, "onFileCreationSuccess", client, fullPath)
        outputDebugString("File creation successful: " .. fullPath)
    else
        outputDebugString("Failed to create output file: " .. fullPath, 1)
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
        outputDebugString("File list does not exist, creating: 'file_list.json'")
        local newFile = fileCreate(fileListPath)
        if newFile then

            fileWrite(newFile, "[]")
            fileClose(newFile)
        else
            outputDebugString("Failed to create file_list.json", 1)
            triggerClientEvent(client, "onReceiveFileList", client, {})
            return
        end
    end

    local file = fileOpen(fileListPath, true)
    if not file then
        outputDebugString("Failure to open 'file_list.json'", 1)
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
            outputDebugString("Failed to parse JSON content", 1)
        end
    end
    
    outputDebugString("Sending file list to client with " .. #fileList .. " entries")
    triggerClientEvent(client, "onReceiveFileList", client, fileList)
end)

function addFileListEntry(path, arguments)
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

    table.insert(fileList, {
        path = path,
        arguments = arguments or {}
    })

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