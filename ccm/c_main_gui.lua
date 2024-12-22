--createOccupiedVehicleAndMoveOverPath(marker, pedID, vehicleID, filePath, heightOffset, searchlightFollowsPlayer, searchlightOffset, adjustableProperty, adjPropValue, interpolateAdjProp, startValue, endValue, duration)
DGS = exports.dgs
local screenWidth, screenHeight = guiGetScreenSize()
--Store arguments that are used in the function createOccupiedVehicleAndMoveOverPath
--Define the arguments, tooltips and their types
arguments = {

    {name = "pedID", toolTip = "The PedID that should be used for the occupied vehicle. It uses the character model by default or 0.", type = "integer", text = "Choose a ped ID"},
    {name = "vehicleID", toolTip = "The VehicleID that should be used. It gets the current vehicle by default or 411.", type = "integer", text = "Choose a vehicle ID"},
    {name = "filePath", toolTip = "Filename for the path you will later want to import to your map. \"Path\" by default.", type = "string", text = "Choose a file name"},
    {name = "heightOffset", toolTip = "The vehicle height offset that can be set because sometimes certain vehicles dont touch the ground or are too high up (e.g Infernus, Forklift). 0 by default.", type = "float", text = "Height offset"},
    {name = "destroyVehicle", toolTip = "Should the vehicle be destroyed after the path is finished? True by default.", type = "boolean", text = "Destroy vehicle after path has ended?"},
    {name = "sirenLights", toolTip = "Should the siren lights be activated? Works with any emergency vehicle. False by default.", type = "boolean", text = "Activate siren lights?"},
    {name = "searchlightFollowsPlayer", toolTip = "Should a searchlight be following the player? Works with any vehicle. False by default.", type = "boolean", text = "Activate searchlight?"},
    {name = "searchlightOffset", toolTip = "The searchlight offset, where should the searchlight start on the given vehicle. 0 by default.\nNote: offsets are calculated to the local position of the vehicle.\nTip: go to {0, 0, 0} in the world place a vehicle and use an object to find the perfect offset.", type = "table"},
    {name = "adjustableProperty", toolTip = "Adjustable properties are used for adjusting the movable parts of a model, for example hydra jets or dump truck tray. ", type = "boolean", text = "Use adjustable property"},
    {name = "adjPropValue", toolTip = "A value from 0 between ? (Set the adjustable value between 0 and N. 0 is the default value. It is possible to force the setting beyond default maximum, for example setting above 5000 on the dump truck (normal max 2500) will cause the tray to be fully vertical).\nDefault maximum values - Packer: 2500, Dumper: 2500, Forklift: 2500, Hydra: 5000, ", type = "float", text = "Set adjustable property value"},
    {name = "interpolateAdjProp", toolTip = "Decide if you want to interpolate between two values for the adjustable property.", type = "boolean", text = "Adjustable property interpolation"},
    {name = "startValue", toolTip = "Start value: see tooltip for adjustable property. 0 by default.", type = "float", text = "Start value"},
    {name = "endValue", toolTip = "End value: see tooltip for adjustable property. 2500 by default.", type = "float", text = "End value"},
    {name = "duration", toolTip = "Duration for the adjustable property set in milliseconds. 3000 by default.", type = "float", text = "Duration"}

}

editFields = {}
switchButtons = {}
isFlushEnabled = false

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
        outputDebugString("All files have been successfully added to the ComboBox.")
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
    outputDebugString("updateMarkersList triggered on client")

    DGS:dgsGridListClear(markerGridList)
    if DGS:dgsGridListGetColumnCount(markerGridList) == 0 then
        DGS:dgsGridListAddColumn(markerGridList, "Select one of your markers", 1)
    end

    if not serverMarkers or #serverMarkers == 0 then
        outputDebugString("No markers received from server.")
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

function createMainGuiMenu()

    local playerVehicle = getPedOccupiedVehicle(localPlayer)

    ------------------------------------------
    --------- Table for gui settings ---------
    ------------------------------------------

    local declare = {
        sPosX = (screenWidth / 2),
        sPosY = (screenHeight / 2),
        sWidth = 250,
        sHeight = 700,
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

        if i >= 4 then
            if i == 4 then
                local optional = DGS:dgsCreateLabel(declare.marginLeft + declare.width / 4, y + 10, declare.width, declare.height, "Optional arguments", false, mainRecordMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, optional, "Optional arguments are not required for the function to work. You can leave them as they are and it will make use of the default value.\nNote: You'd normally provide every argument in order, but you dont have to because we are setting certain conditions to provide default values.")
            end
            y = y + declare.spacing * 8
        end
        
        
        if argumentType == "string" or argumentType == "float" or argumentType == "integer" then
            local argumentEdit = DGS:dgsCreateEdit(declare.marginLeft, y, declare.width, declare.height, argumentText, false, mainRecordMenu)
            local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
            DGS:dgsTooltipApplyTo(tooltip, argumentEdit, argumentToolTip)
            table.insert(editFields, argumentEdit)
        
            -- Set input mode to "no_binds" when the edit field is focused
            addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                if button == "left" and state == "down" then
                    DGS:dgsSetInputMode("no_binds")
                    DGS:dgsSetText(argumentEdit, "")
                end
            end, false)
        
            -- Set input mode back to "all" when the edit field is unfocused
            addEventHandler("onDgsBlur", argumentEdit, function()
                DGS:dgsSetInputMode("allow_binds")
                local playerVehicle = getPedOccupiedVehicle(localPlayer)
                if DGS:dgsGetText(argumentEdit) == "" then
                    DGS:dgsSetText(argumentEdit, argumentText)
                elseif argumentName == "pedID" then
                    local pedID = tonumber(DGS:dgsGetText(argumentEdit))
                    if not pedID then
                        DGS:dgsSetText(argumentEdit, tostring(getElementModel(localPlayer)))
                    end
                elseif argumentName == "vehicleID" and playerVehicle then
                    local vehicleID = tonumber(DGS:dgsGetText(argumentEdit))
                    if not vehicleID then
                        DGS:dgsSetText(argumentEdit, tostring(getElementModel(playerVehicle)))
                    end
                elseif argumentType == "float" or argumentType == "integer" then
                    local value = tonumber(DGS:dgsGetText(argumentEdit))
                    if not value then
                        DGS:dgsSetText(argumentEdit, argumentText)
                    end
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
            local labels = {"X", "Y", "Z"}
            for j = 0, 2 do
                local argumentEdit = DGS:dgsCreateEdit((declare.marginLeft) + ((j * declare.width / 3) + (j * declare.spacing / 3)), y, (declare.width / 3) - declare.spacing / 3, declare.height, "offset" .. labels[j + 1], false, mainRecordMenu)
                local tooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
                DGS:dgsTooltipApplyTo(tooltip, argumentEdit, argumentToolTip)
                table.insert(editFields, argumentEdit)
        
                -- Set input mode to "no_binds" when the edit field is focused
                addEventHandler("onDgsMouseClick", argumentEdit, function(button, state)
                    if button == "left" and state == "down" then
                        DGS:dgsSetInputMode("no_binds")
                        DGS:dgsSetText(argumentEdit, "")
                    end
                end, false)
        
                -- Set input mode back to "all" when the edit field is unfocused
                addEventHandler("onDgsBlur", argumentEdit, function()
                    DGS:dgsSetInputMode("allow_binds")
                    if DGS:dgsGetText(argumentEdit) == "" then
                        DGS:dgsSetText(argumentEdit, "offset" .. labels[j + 1])
                    end
                end, false)
            end
        end
    end

    ------------------------------------------
    ---------- Buttons for main menu ---------
    ------------------------------------------

    local recordButton = DGS:dgsCreateButton(declare.marginLeft, declare.sHeight - declare.height - declare.spacing - declare.marginBottom * 2.5, (declare.width / 2) - declare.spacing / 2, declare.height, "Record", false, mainRecordMenu)
    local recordButtonTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(recordButtonTooltip, recordButton, "Starts recording the path. You can stop the recording by pressing N.\nNote: You need to be in a vehicle to record a path.")
    local closeButton = DGS:dgsCreateButton(declare.marginLeft + declare.width / 2, declare.sHeight - declare.height - declare.spacing - declare.marginBottom * 2.5, (declare.width / 2) + declare.spacing / 8, declare.height, "Close", false, mainRecordMenu)
    local importButton = DGS:dgsCreateButton(declare.marginLeft, declare.sHeight - declare.height - declare.marginBottom * 1.5, declare.width, declare.height, "Import", false, mainRecordMenu)

    addEventHandler("onDgsMouseClick", recordButton, function(key, state)
        if key == "left" and state == "up" then
            local playerVehicle = getPedOccupiedVehicle(localPlayer)
    
            if playerVehicle then
                setElementFrozen(playerVehicle, false)
                setElementVelocity(playerVehicle, vx, vy, vz)
                toggleTimer()
            else
                DGS:dgsSetVisible(mainRecordMenu, false)
                DGS:dgsSetVisible(pathsMenu, false)
                DGS:dgsSetVisible(mainMemoMenu, false)
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
            showCursor(false)
            if playerVehicle then

                if isElementFrozen(playerVehicle) then
                    setElementFrozen(playerVehicle, false)
                end

                setElementVelocity(playerVehicle, vx, vy, vz)

            end
            isMenuOpen = false
        end
    end, false)

    addEventHandler("onDgsMouseClick", importButton, function(key, state)
        if key == "left" and state == "up" then

            if DGS:dgsGetVisible(pathsMenu) then
                DGS:dgsSetVisible(pathsMenu, false)
                DGS:dgsSetVisible(mainMemoMenu, false)
            else
                DGS:dgsSetVisible(pathsMenu, true)
                DGS:dgsSetVisible(mainMemoMenu, true)
            end
        end
    end, false)

    DGS:dgsSetVisible(mainRecordMenu, false)

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
    DGS:dgsTooltipApplyTo(saveButtonTooltip, saveButton, "Saves the current memo content to the selected map. You need to select a map before you can save.\nNote: This will create everything necessary inside your map folder. One click and you are done!\n<font color='#FF0000'>Disclaimer: this might take a lot longer on slower servers!")

    --create button for file_list.json
    addButton = DGS:dgsCreateButton(declare.marginLeft, declare.marginTop * 3 + declare.height * 6 + declare.spacing * 3, declare.width * 1.25, declare.height, "Add path/s to memo", false, pathsMenu)
    local addButtonTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(addButtonTooltip, addButton, "Adds the selected path to the memo. You can add multiple paths to the memo before you decide to save.\nNote: You need to select a marker and a path before you can add it to the memo.\nInfo: You can use one marker for multiple paths by selecting the marker that has already been added.")

    --[[create resource button
    resourceButton = DGS:dgsCreateButton(declare.marginLeft + (declare.width * 1.25) / 2 + declare.spacing / 2, declare.marginTop * 3 + declare.height * 7 + declare.spacing * 4, (declare.width * 1.25) / 2 - declare.spacing / 2, declare.height, "Create a resource", false, pathsMenu)
    local resourceButtonTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(resourceButtonTooltip, resourceButton, "Creates a resource with the selected path and marker. You need to have something present in the memo to create a resource.")--]]
    
    --create checkbox for flushEnabled
    flushEnabledCheckBox = DGS:dgsCreateCheckBox(declare.marginLeft + declare.width * 1.25 + declare.spacing, declare.marginTop * 3 + declare.height * 6 + declare.spacing * 3.5, declare.width - declare.spacing - declare.marginRight * 2, declare.height, "Override existing file", false, false, pathsMenu)
    local flushEnabledCheckBoxTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(flushEnabledCheckBoxTooltip, flushEnabledCheckBox, "Choose if you want to override the existing file or not. Default is off.")
    
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

        if selectedMarker == -1 or selectedPath == -1 then return end

        local path = DGS:dgsComboBoxGetItemText(pathsComboBox, selectedPath)
        local marker = DGS:dgsGridListGetItemText(markerGridList, selectedMarker, 1)

        local currentText = DGS:dgsGetText(mainMemo)

        local markerValue = "marker"
        local markerString = ""
        for _, m in ipairs(markers) do
            if m.displayText == marker then
                markerString = string.format(
                    'local %s = createMarker(%f, %f, %f, "corona", 10, 0, 0, 0, 0)',
                    m.id,
                    m.position.x,
                    m.position.y,
                    m.position.z
                )
                if not currentText:find(markerString, 1, true) then
                    markerValue = m.id
                else
                    markerString = "" -- Setze markerString auf leer, wenn er bereits vorhanden ist
                    markerValue = m.id
                end
                break
            end
        end
        

        for i, entry in ipairs(fileList) do
            if entry.path == path then
                local arguments = entry.arguments
                outputDebugString("Arguments for path: " .. toJSON(arguments))

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

                if type(searchlightOffset) ~= "table" then
                    searchlightOffset = {"0", "0", "0"}
                end

                local formattedString = string.format(
                    "createOccupiedVehicleAndMoveOverPath(%s, %s, %s, \"%s\", %s, %s, %s, %s, {%s, %s, %s}, %s, %s, %s, %s, %s, %s)",
                    markerValue,
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
                    duration
                )

                local currentText = DGS:dgsGetText(mainMemo)
                if markerString == "" then
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
    
            if selectedMarker == -1 or selectedPath == -1 then
                outputChatBox("#D7DF01INFO#FFFFFF: Please select a path and a marker.", 255, 255, 255, true)
                return
            end

            DGS:dgsComboBoxClear(pathsComboBox)
            triggerServerEvent("onRequestFileList", localPlayer)
            saveMemoScriptToFile()
        end
    end, false)

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

    mainMemoMenu = DGS:dgsCreateWindow(declare.sPosX - (declare.sWidth / 2) - declare.pathMenuWidth - declare.spacing + declare.marginRight * 2, declare.sPosY + declare.spacing, declare.pathMenuWidth - declare.marginRight * 2, declare.sHeight / 2 - declare.spacing, "Memo paths script", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(mainMemoMenu, false)
    
    local memoWidth = declare.pathMenuWidth - declare.marginRight * 2 - declare.marginLeft
    local memoHeight = declare.sHeight / 2 - declare.spacing - declare.marginTop - declare.marginBottom
    local memoX = (declare.pathMenuWidth - memoWidth) / 2 - declare.marginRight
    local memoY = (declare.sHeight / 2 - memoHeight) / 2 - declare.spacing * 3
    
    mainMemo = DGS:dgsCreateMemo((declare.pathMenuWidth - memoWidth) / 2 - declare.marginRight, (declare.sHeight / 2 - memoHeight) / 2 - declare.spacing * 3, declare.pathMenuWidth - declare.marginRight * 2 - declare.marginLeft, declare.sHeight / 2 - declare.spacing - declare.marginTop - declare.marginBottom, "", false, mainMemoMenu)
    
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

    addEventHandler("onDgsPositionChange", mainRecordMenu, function()
        local mainX, mainY = DGS:dgsGetPosition(mainRecordMenu, false)
        local deltaX = mainX - lastMainPos.x
        local deltaY = mainY - lastMainPos.y

        local currentPathsX, currentPathsY = DGS:dgsGetPosition(pathsMenu, false)
        local currentMemoX, currentMemoY = DGS:dgsGetPosition(mainMemoMenu, false)
        
        DGS:dgsSetPosition(pathsMenu, currentPathsX + deltaX, currentPathsY + deltaY, false)
        DGS:dgsSetPosition(mainMemoMenu, currentMemoX + deltaX, currentMemoY + deltaY, false)

        lastMainPos.x = mainX
        lastMainPos.y = mainY
        lastPathsPos.x = currentPathsX + deltaX
        lastPathsPos.y = currentPathsY + deltaY
        lastMemoPos.x = currentMemoX + deltaX
        lastMemoPos.y = currentMemoY + deltaY
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
        outputDebugString("Failed to save scriptmemo.json")
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
            outputDebugString("scriptmemo.json loaded.")
        else
            outputDebugString("Failed to load scriptmemo.json")
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

    local selectedPath = DGS:dgsComboBoxGetSelectedItem(pathsComboBox)
    local selectedMap = DGS:dgsGridListGetSelectedItem(mapsGridList)

    local filePath = DGS:dgsComboBoxGetItemText(pathsComboBox, selectedPath)
    local mapName = DGS:dgsGridListGetItemText(mapsGridList, selectedMap, 1)
    local stringFunction = DGS:dgsGetText(mainMemo)

    if message == 0 then
        outputChatBox("#FF0000ERROR#FFFFFF: I have no permission to edit files. Add admin rights to this resource.", 255, 255, 255, true)
    elseif message == 1 then
        local cleanedFilePath = string.gsub(filePath, "^paths/", "")
        cleanedFilePath = string.gsub(cleanedFilePath, "%.json$", "")
        outputChatBox("#D7DF01INFO#FFFFFF: You saved the path/s successfully to your map: " .. mapName, 255, 255, 255, true)
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
    if isMTAWindowActive() or DGS:dgsGetInputMode() == "no_binds" then return end
    
    local playerVehicle = getPedOccupiedVehicle(localPlayer)
    
    if key == "n" and state then
        if timer then
            stopRecording()
            return
        elseif DGS:dgsGetVisible(mainRecordMenu) then

            DGS:dgsSetVisible(mainRecordMenu, false)
            if DGS:dgsGetVisible(pathsMenu) then
                DGS:dgsSetVisible(pathsMenu, false)
            end
            if DGS:dgsGetVisible(mainMemoMenu) then
                DGS:dgsSetVisible(mainMemoMenu, false)
            end
            showCursor(false)
            isMenuOpen = false
            

            triggerServerEvent("onElementDrop", localPlayer)
            
            if playerVehicle then
                setElementFrozen(playerVehicle, false)
                setElementVelocity(playerVehicle, vx, vy, vz)
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
                
                vx, vy, vz = getElementVelocity(playerVehicle)
                setElementFrozen(playerVehicle, true)
            end
            
            DGS:dgsSetVisible(mainRecordMenu, true)
            showCursor(true)
            isMenuOpen = true

            triggerServerEvent("onElementDrop", localPlayer)
        end
    end
end

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