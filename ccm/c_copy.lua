DGS = exports.dgs
local index = 0
local vIndex = 0
local oIndex = 0
local pIndex = 0

-- Function to save settings to a file
function saveSettings()
    local settings = {
        useTableFormat = useTableFormat,
        useComma = useComma,
        infoEnabled = infoEnabled,
        enableWindowShWindow = enableWindowShWindow,
        copyKey = copyKey
    }
    local file = fileCreate("settings.json")
    if file then
        fileWrite(file, toJSON(settings))
        fileClose(file)
        --outputDebugString("Settings saved.")
    else
        outputDebugString("[CCM]: Failed to save settings.", 0, 255, 100, 100)
    end
end

-- Function to load settings from a file
function loadSettings()
    local defaultSettings = {
        useTableFormat = false,
        useComma = false,
        infoEnabled = true,
        enableWindowShWindow = true,
        copyKey = "b"
    }

    if fileExists("settings.json") then
        local file = fileOpen("settings.json")
        if file then
            local size = fileGetSize(file)
            local content = fileRead(file, size)
            local settings = fromJSON(content)
            fileClose(file)
            if settings then
                -- Merge default settings with loaded settings
                for key, value in pairs(defaultSettings) do
                    if settings[key] == nil then
                        settings[key] = value
                    end
                end
                useTableFormat = settings.useTableFormat
                useComma = settings.useComma
                infoEnabled = settings.infoEnabled
                enableWindowShWindow = settings.enableWindowShWindow
                copyKey = settings.copyKey
                -- Save the updated settings back to the file
                saveSettings()
            else
                outputDebugString("[CCM]: Failed to parse settings.", 0, 255, 100, 100)
            end
        else
            outputDebugString("[CCM]: Failed to open settings file.", 0, 255, 100, 100)
        end
    else
        useTableFormat = defaultSettings.useTableFormat
        useComma = defaultSettings.useComma
        infoEnabled = defaultSettings.infoEnabled
        enableWindowShWindow = defaultSettings.enableWindowShWindow
        copyKey = defaultSettings.copyKey
        outputDebugString("[CCM]: Settings file does not exist.", 0, 255, 100, 100)
        -- Save the default settings to a new file
        saveSettings()
    end
end
addEventHandler("onClientPlayerJoin", root, loadSettings)
addEventHandler("onClientResourceStart", resourceRoot, loadSettings)

-- Function to save memo contents to a file
function saveMemoToFile(memo, filename)
    local content = DGS:dgsGetText(memo)
    local file = fileCreate(filename)
    if file then
        fileWrite(file, toJSON({content = content}))
        fileClose(file)
    else
        outputDebugString("[CCM]: Failed to save " .. filename, 0, 255, 100, 100)
    end
end

-- Function to load memo contents from a file
function loadMemoFromFile(memo, filename)
    if fileExists(filename) then
        local file = fileOpen(filename)
        if file then
            local size = fileGetSize(file)
            local content = fileRead(file, size)
            local data = fromJSON(content)
            fileClose(file)
            if data and data.content then
                DGS:dgsSetText(memo, data.content)
                outputDebugString("[CCM]: " .. filename .. " loaded.", 4, 100, 255, 100)
            else
                outputDebugString("[CCM]: Failed to parse " .. filename, 0, 255, 100, 100)
            end
        else
            outputDebugString("[CCM]: Failed to open " .. filename, 0, 255, 100, 100)
        end
    else
        outputDebugString("[CCM]: " .. filename .. " does not exist.", 0, 255, 100, 100)
    end
end

-- Function to save all memos to files
function saveAllMemos()
    saveMemoToFile(Copymemo, "markermemo.json")
    saveMemoToFile(vCopymemo, "vehiclememo.json")
    saveMemoToFile(oCopymemo, "objectsmemo.json")
    saveMemoToFile(pCopymemo, "pedmemo.json")
end
addEventHandler("onClientResourceStop", resourceRoot, saveAllMemos)

function copyObjectDetails(source)
    if not isElement(source) then
        outputChatBox("Invalid object.", 255, 0, 0)
        return
    end

    local elementType = getElementType(source)
    local details -- Declare details variable outside the if-else blocks to make it accessible for clipboard operation

    if elementType == "object" or elementType == "vehicle" then
        local modelID = getElementModel(source)
        local x, y, z = getElementPosition(source)
        local rx, ry, rz = getElementRotation(source)
        
        -- Prepare the details string for object or vehicle
        if useTableFormat then
            details = string.format("{%.2f, %.2f, %.2f, %.2f, %.2f, %.2f},",
                x, y, z, rx, ry, rz)
        elseif useComma then
            details = string.format("%.2f, %.2f, %.2f, %.2f, %.2f, %.2f,",
                x, y, z, rx, ry, rz)
        else
            details = string.format("%.2f, %.2f, %.2f, %.2f, %.2f, %.2f",
                x, y, z, rx, ry, rz)
        end
    elseif elementType == "ped" or elementType == "animatedped" then
        local x, y, z = getElementPosition(source)
        local rx, ry, rz = getElementRotation(source)

        -- Prepare the details string for ped
        if useTableFormat then
            details = string.format("{%.2f, %.2f, %.2f, %.2f},",
                x, y, z, rz)
        elseif useComma then
            details = string.format("%.2f, %.2f, %.2f, %.2f,",
                x, y, z, rz)
        else
            details = string.format("%.2f, %.2f, %.2f, %.2f",
                x, y, z, rz)
        end
    elseif elementType == "marker" then
        local x, y, z = getElementPosition(source)
        if useTableFormat then
            details = string.format("{%.2f, %.2f, %.2f},",
                x, y, z)
        elseif useComma then
            details = string.format("%.2f, %.2f, %.2f,",
                x, y, z)
        else
            details = string.format("%.2f, %.2f, %.2f",
                x, y, z)
        end
    else
        outputChatBox("#FF0000ERROR#FFFFFF: Element is not an object, vehicle, or ped.", 255, 255, 255, true)
        return -- Exit the function if the element is not of a supported type
    end
    
    -- Copy the details to the clipboard for object, vehicle, or ped
    if details and setClipboard(details) and infoEnabled then
        outputChatBox("#D7DF01INFO#FFFFFF: " .. details .. " details copied to clipboard.", 255, 255, 255, true)
    elseif details and setClipboard(details) and not infoEnabled then
        return details
    else
        outputChatBox("Failed to copy object details to clipboard.", 255, 0, 0)
    end

    return details
end

function copyToClipboard(key, state)

    if isMTAWindowActive() or DGS:dgsGetInputMode() == "no_binds" then return end

    if key == copyKey and state then
        local selectedElement = exports["editor_main"]:getSelectedElement()
        if not isElement(exports["editor_main"]:getSelectedElement()) then
            outputChatBox("#D7DF01INFO#FFFFFF: No object selected.", 255, 255, 255, true)
            return
        end
        local elementType = getElementType(selectedElement)
        if elementType == "marker" then
            local memoInsert = copyObjectDetails(selectedElement)
            DGS:dgsMemoInsertText(Copymemo, 1, 1 + index, memoInsert)
            saveMemoToFile(Copymemo, "markermemo.json")
            index = index + 1
        elseif elementType == "vehicle" then
            local memoInsert = copyObjectDetails(selectedElement)
            DGS:dgsMemoInsertText(vCopymemo, 1, 1 + vIndex, memoInsert)
            saveMemoToFile(vCopymemo, "vehiclememo.json")
            vIndex = vIndex + 1
        elseif elementType == "object" then
            local memoInsert = copyObjectDetails(selectedElement)
            DGS:dgsMemoInsertText(oCopymemo, 1, 1 + oIndex, memoInsert)
            saveMemoToFile(oCopymemo, "objectsmemo.json")
            oIndex = oIndex + 1
        elseif elementType == "ped" or elementType == "animatedped" then
            local memoInsert = copyObjectDetails(selectedElement)
            DGS:dgsMemoInsertText(pCopymemo, 1, 1 + pIndex, memoInsert)
            saveMemoToFile(pCopymemo, "pedmemo.json")
            pIndex = pIndex + 1
        end
    end
end
addEventHandler("onClientKey", root, copyToClipboard)

-- Memo to input copy positions
function cMemoFPlayer()

    if infoEnabled then
        outputChatBox("")
        outputChatBox("Press:#FF0000 " .. copyKey .. "#FFFFFF to copy an element to the Memo Clipboard.\nPress #FF0000V #FFFFFFto open the Clipboard.", 255, 255, 255, true)
        outputChatBox("Press #FF0000N #FFFFFFto start/stop recording paths.", 255, 255, 255, true)
    end

    local screenWidth, screenHeight = guiGetScreenSize()
    Window = DGS:dgsCreateWindow((screenWidth / 2) - 445, (screenHeight / 2) - 260, 890, 480, "Clipboard - Press V to close", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    DGS:dgsWindowSetSizable(Window, false)

    if enableWindowShWindow then
        DGS:dgsSetVisible(Window, true)
        showCursor(true)
    else
        DGS:dgsSetVisible(Window, false)
        showCursor(false)
    end

    --Create the memo for copy positions
    Copymemo = DGS:dgsCreateMemo(15, 35, 200, 300, "", false, Window)
    vCopymemo = DGS:dgsCreateMemo(235, 35, 200, 300, "", false, Window)
    oCopymemo = DGS:dgsCreateMemo(455, 35, 200, 300, "", false, Window)
    pCopymemo = DGS:dgsCreateMemo(675, 35, 200, 300, "", false, Window)

    --Set the memo to read-only
    DGS:dgsMemoSetReadOnly(Copymemo, true)
    DGS:dgsMemoSetReadOnly(vCopymemo, true)
    DGS:dgsMemoSetReadOnly(oCopymemo, true)
    DGS:dgsMemoSetReadOnly(pCopymemo, true)

    -- Load memo contents from files
    loadMemoFromFile(Copymemo, "markermemo.json")
    loadMemoFromFile(vCopymemo, "vehiclememo.json")
    loadMemoFromFile(oCopymemo, "objectsmemo.json")
    loadMemoFromFile(pCopymemo, "pedmemo.json")

    
    -- Create the settings menu (screenWidth / 2) - 445, (screenHeight / 2) - 260, 890, 480
    settingsWindow = DGS:dgsCreateWindow(((screenWidth / 2) - 445) - 250, (screenHeight / 2) - 260, 250, 250, "Settings", false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, 0x96141414, 5, true)
    local settingsButton = DGS:dgsCreateButton(15, 410, 200, 30, "Settings", false, Window)
    addEventHandler("onDgsMouseClickUp", settingsButton, function()
        if DGS:dgsGetVisible(settingsWindow) then
            DGS:dgsSetVisible(settingsWindow, false)
        else
            DGS:dgsSetVisible(settingsWindow, true)
        end
    end, false)
    
    DGS:dgsSetVisible(settingsWindow, false)
    
    -- Create the checkbox for table format
    checkboxTableFormat = DGS:dgsCreateCheckBox(15, 45, 200, 30, "Use table format", useTableFormat, false, settingsWindow)
    local checkboxTableFormatTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(checkboxTableFormatTooltip, checkboxTableFormat, "Use table format to copy positions. Format is \"{x, y, z, rx, ry, rz},\" or \"{x, y, z},\".")
    addEventHandler("onDgsMouseClickUp", checkboxTableFormat, function()
        if DGS:dgsCheckBoxGetSelected(checkboxTableFormat) then
            DGS:dgsCheckBoxSetSelected(checkboxCommaFormat, false)
            useTableFormat = true
            useComma = false
        else
            useTableFormat = false
        end
        saveSettings()
    end, false)


    -- Create the checkbox for comma format
    checkboxCommaFormat = DGS:dgsCreateCheckBox(15, 75, 200, 30, "Use comma for non-table format", useComma, false, settingsWindow)
    local checkboxCommaFormatTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(checkboxCommaFormatTooltip, checkboxCommaFormat, "Use comma to separate positions. Format is \"x, y, z, rx, ry, rz,\" or \"x, y, z,\".")
    addEventHandler("onDgsMouseClickUp", checkboxCommaFormat, function()
        if DGS:dgsCheckBoxGetSelected(checkboxCommaFormat) then
            DGS:dgsCheckBoxSetSelected(checkboxTableFormat, false)
            useComma = true
            useTableFormat = false
        else
            useComma = false
        end
        saveSettings()
    end, false)

    --Create the checkbox for disabling info
    checkboxInfo = DGS:dgsCreateCheckBox(15, 105, 200, 30, "Enable Information", infoEnabled, false, settingsWindow)
    local checkboxInfoTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(checkboxInfoTooltip, checkboxInfo, "Enable or disable information messages when copying positions.")
    addEventHandler("onDgsMouseClickUp", checkboxInfo, function()
        infoEnabled = DGS:dgsCheckBoxGetSelected(checkboxInfo)
        saveSettings()
    end, false)

    
    --Create the checkbox for disabling that the window is shown on start/join
    checkboxShWindow = DGS:dgsCreateCheckBox(15, 135, 200, 30, "Enable window on start or join", enableWindowShWindow, false, settingsWindow)
    local checkboxShWindowTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(checkboxShWindowTooltip, checkboxShWindow, "Enable or disable the window to be shown on start or join.")
    addEventHandler("onDgsMouseClickUp", checkboxShWindow, function()
        enableWindowShWindow = DGS:dgsCheckBoxGetSelected(checkboxShWindow)
        saveSettings()
    end, false)
    
    -- Create the checkbox for selecting if the memo should be read only or not
    checkboxReadOnly = DGS:dgsCreateCheckBox(15, 165, 200, 30, "Enable read-only memo", true, false, settingsWindow)
    local checkboxReadOnlyTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(checkboxReadOnlyTooltip, checkboxReadOnly, "Enable or disable the memo to be read-only.")
    addEventHandler("onDgsMouseClickUp", checkboxReadOnly, function()
        local readOnly = DGS:dgsCheckBoxGetSelected(checkboxReadOnly)
        DGS:dgsMemoSetReadOnly(Copymemo, readOnly)
        DGS:dgsMemoSetReadOnly(vCopymemo, readOnly)
        DGS:dgsMemoSetReadOnly(oCopymemo, readOnly)
        DGS:dgsMemoSetReadOnly(pCopymemo, readOnly)
    end, false)

    -- Helper function to find the index of a value in a table
    local function indexOf(tbl, value)
        for i, v in ipairs(tbl) do
            if v == value then
                return i 
            end
        end
        return -1
    end
    
    -- Create the combo box for selecting the copy key
    local keyOptions = {"mouse3", "mouse4", "mouse5", "b", "g", "m", "r", "x", ".", ",", "-"}
    local comboBox = DGS:dgsCreateComboBox(15, 15, 200, 30, "Select Copy Key", false, settingsWindow)
    local comboBoxTooltip = DGS:dgsCreateToolTip(0xFFFFFFFF, 0xFF000000)
    DGS:dgsTooltipApplyTo(comboBoxTooltip, comboBox, "Select the key to copy elements to the memo clipboard. \"b\" by default.")
    for i, key in ipairs(keyOptions) do
        DGS:dgsComboBoxAddItem(comboBox, key)
    end
    local selectedIndex = indexOf(keyOptions, copyKey)
    if selectedIndex >= 0 then
        DGS:dgsComboBoxSetSelectedItem(comboBox, selectedIndex)
    end
    addEventHandler("onDgsComboBoxSelect", comboBox, function()
        local selectedKey = DGS:dgsComboBoxGetItemText(comboBox, DGS:dgsComboBoxGetSelectedItem(comboBox))
        if selectedKey then
            copyKey = selectedKey
            saveSettings()
        end
    end, false)

    local lastWindowPos = {
        x = (screenWidth / 2) - 445, y = (screenHeight / 2) - 260
    }
    
    local lastSettingsPos = {
        x = (screenWidth / 2) - 445 + 890 - 265, y = (screenHeight / 2) - 260 + 15
    }

    addEventHandler("onDgsPositionChange", Window, function()
        local mainX, mainY = DGS:dgsGetPosition(Window, false)
        local deltaX = mainX - lastWindowPos.x
        local deltaY = mainY - lastWindowPos.y

        local currentsettingsWindowX, currentsettingsWindowY = DGS:dgsGetPosition(settingsWindow, false)
        
        DGS:dgsSetPosition(settingsWindow, currentsettingsWindowX + deltaX, currentsettingsWindowY + deltaY, false)

        lastWindowPos.x = mainX
        lastWindowPos.y = mainY
        lastSettingsPos.x = currentsettingsWindowX + deltaX
        lastSettingsPos.y = currentsettingsWindowY + deltaY
    end, false)

    --Create the label for the memo
    local label = DGS:dgsCreateLabel(15, 10, 200, 30, "Marker Positions", false, Window)

    local label2 = DGS:dgsCreateLabel(235, 10, 200, 30, "Vehicle Positions", false, Window)

    local label3 = DGS:dgsCreateLabel(455, 10, 200, 30, "Object Positions", false, Window)

    local label4 = DGS:dgsCreateLabel(675, 10, 200, 30, "Ped Positions", false, Window)

    -- Create copy buttons
    local copyButton1 = DGS:dgsCreateButton(15, 340, 200, 30, "Copy Marker Positions", false, Window)
    addEventHandler("onDgsMouseClickUp", copyButton1, function()
        local text = DGS:dgsGetText(Copymemo)
        setClipboard(text)
        outputChatBox("#D7DF01INFO#FFFFFF: Marker positions copied to clipboard.", 255, 255, 255, true)
    end, false)

    local copyButton2 = DGS:dgsCreateButton(235, 340, 200, 30, "Copy Vehicle Positions", false, Window)
    addEventHandler("onDgsMouseClickUp", copyButton2, function()
        local text = DGS:dgsGetText(vCopymemo)
        setClipboard(text)
        outputChatBox("#D7DF01INFO#FFFFFF: Vehicle positions copied to clipboard.", 255, 255, 255, true)
    end, false)

    local copyButton3 = DGS:dgsCreateButton(455, 340, 200, 30, "Copy Object Positions", false, Window)
    addEventHandler("onDgsMouseClickUp", copyButton3, function()
        local text = DGS:dgsGetText(oCopymemo)
        setClipboard(text)
        outputChatBox("#D7DF01INFO#FFFFFF: Object positions copied to clipboard.", 255, 255, 255, true)
    end, false)

    local copyButton4 = DGS:dgsCreateButton(675, 340, 200, 30, "Copy Ped Positions", false, Window)
    addEventHandler("onDgsMouseClickUp", copyButton4, function()
        local text = DGS:dgsGetText(pCopymemo)
        setClipboard(text)
        outputChatBox("#D7DF01INFO#FFFFFF: Ped positions copied to clipboard.", 255, 255, 255, true)
    end, false)

    --Create clear buttons
    local clearButton1 = DGS:dgsCreateButton(15, 375, 200, 30, "Clear", false, Window)
    addEventHandler("onDgsMouseClickUp", clearButton1, function()
        DGS:dgsSetText(Copymemo, "")
        saveMemoToFile(Copymemo, "markermemo.json")
        index = 0
    end, false)

    local clearButton2 = DGS:dgsCreateButton(235, 375, 200, 30, "Clear", false, Window)
    addEventHandler("onDgsMouseClickUp", clearButton2, function()
        DGS:dgsSetText(vCopymemo, "")
        saveMemoToFile(vCopymemo, "vehiclememo.json")
        vIndex = 0
    end, false)

    local clearButton3 = DGS:dgsCreateButton(455, 375, 200, 30, "Clear", false, Window)
    addEventHandler("onDgsMouseClickUp", clearButton3, function()
        DGS:dgsSetText(oCopymemo, "")
        saveMemoToFile(oCopymemo, "objectsmemo.json")
        oIndex = 0
    end, false)

    local clearButton4 = DGS:dgsCreateButton(675, 375, 200, 30, "Clear", false, Window)
    addEventHandler("onDgsMouseClickUp", clearButton4, function()
        DGS:dgsSetText(pCopymemo, "")
        saveMemoToFile(pCopymemo, "pedmemo.json")
        pIndex = 0
    end, false)
end
addEventHandler("onClientResourceStart", resourceRoot, cMemoFPlayer)

isMemoMenuOpen = false

function showMemoGui(key, state)
    if isMTAWindowActive() or DGS:dgsGetInputMode() == "no_binds" then return end

    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        toggleControl("change_camera", false)
    else
        toggleControl("change_camera", true)
    end
    
    if key == "v" and state then
        if DGS:dgsGetVisible(Window) then

            DGS:dgsSetVisible(Window, false)
            showCursor(false)
            isMemoMenuOpen = false
            
            if DGS:dgsGetVisible(settingsWindow) then
                DGS:dgsSetVisible(settingsWindow, false)
            end
            triggerServerEvent("onElementDrop", localPlayer)
            
        else

            DGS:dgsSetVisible(Window, true)
            showCursor(true)
            isMemoMenuOpen = true

            triggerServerEvent("onElementDrop", localPlayer)
        end
    end
end
addEventHandler("onClientKey", root, showMemoGui)

timer = nil
local startPosition = nil
local startRotation = nil
local lastRotation = nil
local lastOutputTime = 0
local outputInterval = 0
local keyPressCount = 0
local outputCounter = 3
local isFirstEntry = true
local currentFilePath = nil

function recordMovement()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not startPosition then
        startPosition = {getElementPosition(vehicle)}
        startRotation = {getElementRotation(vehicle)}
        local vehicle = getPedOccupiedVehicle(localPlayer)
        if vehicle then
            local vehicleID = getElementModel(vehicle)
            outputChatBox("Vehicle ID: " .. vehicleID .. ".", 255, 255, 255)
        else
            outputChatBox("#FF0000ERROR#FFFFFF: You are not in a vehicle.", 255, 255, 255, true)
        end
        
        local initialData = string.format(
            '[{"x": %.3f, "y": %.3f, "z": %.3f, "rx": %.3f, "ry": %.3f, "rz": %.3f}]',
            startPosition[1], startPosition[2], startPosition[3],
            -startRotation[1], -startRotation[2], startRotation[3]
        )
        
        triggerServerEvent("onStartRecording", localPlayer, initialData)
        isFirstEntry = false
    else
        local currentPosition = {getElementPosition(vehicle)}
        local currentRotation = {getElementRotation(vehicle)}
        local controlStateLeft = getPedAnalogControlState(localPlayer, "vehicle_left", true)
        local controlStateRight = getPedAnalogControlState(localPlayer, "vehicle_right", true) 
        local rotationDifference
        if lastRotation then
            rotationDifference = {
                ((currentRotation[1] - lastRotation[1] + 180) % 360) - 180,
                ((currentRotation[2] - lastRotation[2] + 180) % 360) - 180,
                ((currentRotation[3] - lastRotation[3] + 180) % 360) - 180
            }
        else
            rotationDifference = {
                normalizeRotation(((currentRotation[1] - startRotation[1] + 180) % 360) - 180),
                normalizeRotation(((currentRotation[2] - startRotation[2] + 180) % 360) - 180),
                normalizeRotation(((currentRotation[3] - startRotation[3] + 180) % 360) - 180)
            }
        end

        local currentTime = getTickCount()
        if currentTime - lastOutputTime >= outputInterval then
            local positionData = string.format(
                '[{"x": %.3f, "y": %.3f, "z": %.3f, "rx": %.3f, "ry": %.3f, "rz": %.3f, "cl": %.2f, "cr": %.2f}]',
                currentPosition[1], currentPosition[2], currentPosition[3],
                currentRotation[1], currentRotation[2], currentRotation[3], 
                controlStateLeft, controlStateRight
            )
            
            triggerServerEvent("onRecordData", localPlayer, positionData)
            outputCounter = outputCounter + 1
            lastOutputTime = currentTime
            isFirstEntry = false
        end
    end
end

function normalizeRotation(rotation)
    if rotation > 180 then
        return rotation - 360
    elseif rotation < -180 then
        return rotation + 360
    else
        return rotation
    end
end

function toggleTimer()
    if isMTAWindowActive() or guiGetInputMode() == "no_binds" then return end
    
    local vehicle = getPedOccupiedVehicle(localPlayer)

    if vehicle then
        DGS:dgsSetVisible(mainRecordMenu, false)
        DGS:dgsSetVisible(pathsMenu, false)
        DGS:dgsSetVisible(mainMemoMenu, false)
        showCursor(false)

        if not timer then
            local argumentValues = {}
            argumentValues.pedID = DGS:dgsGetText(editFields[1])
            argumentValues.vehicleID = DGS:dgsGetText(editFields[2])
            argumentValues.heightOffset = DGS:dgsGetText(editFields[4])
            argumentValues.destroyVehicle = DGS:dgsSwitchButtonGetState(switchButtons[1])
            argumentValues.sirenLights = DGS:dgsSwitchButtonGetState(switchButtons[2])
            argumentValues.searchlightFollowsPlayer = DGS:dgsSwitchButtonGetState(switchButtons[3])
            argumentValues.searchlightOffset = {DGS:dgsGetText(editFields[5]), DGS:dgsGetText(editFields[6]), DGS:dgsGetText(editFields[7])}
            argumentValues.adjustableProperty = DGS:dgsSwitchButtonGetState(switchButtons[4])
            argumentValues.adjPropValue = DGS:dgsGetText(editFields[8])
            argumentValues.interpolateAdjProp = DGS:dgsSwitchButtonGetState(switchButtons[5])
            argumentValues.startValue = DGS:dgsGetText(editFields[9])
            argumentValues.endValue = DGS:dgsGetText(editFields[10])
            argumentValues.duration = DGS:dgsGetText(editFields[11])
            argumentValues.reversePath = DGS:dgsSwitchButtonGetState(switchButtons[6])
            
            local filePath = DGS:dgsGetText(editFields[3])
            if filePath == "" or filePath == "Choose a file name" then
                filePath = "path"
            end

            filePath = sanitizeFilename(filePath)
            
            outputDebugString("[CCM]: Sending file creation request: " .. filePath, 4, 100, 255, 100)
            triggerServerEvent("onRequestFileCreation", localPlayer, filePath, argumentValues)
            timer = setTimer(recordMovement, outputInterval, 0)
        elseif not vehicle then
            outputChatBox("#FF0000ERROR#FFFFFF: You are not in a vehicle.", 255, 255, 255, true)
        else
            outputChatBox("#D7DF01INFO#FFFFFF: Timer is already running.", 255, 255, 255, true)
        end
    end
end

function stopRecording()
    if timer then
        killTimer(timer)
        timer = nil
        triggerServerEvent("onStopRecording", localPlayer)
        startPosition = nil
        startRotation = nil
        lastRotation = nil
        lastOutputTime = 0
        outputInterval = 0
        isMenuOpen = false
        outputChatBox("Timer stopped.", 255, 255, 255)
    end
end

function sanitizeFilename(filename)
    return filename:gsub("[^%w%-_%.%s]", "")
end

function killTimerOnExit()
    if timer then
        stopRecording()
    end
end

-- Event Handler
addEventHandler("onClientResourceStop", resourceRoot, killTimerOnExit)
addEventHandler("onClientPlayerVehicleExit", localPlayer, killTimerOnExit)
addEventHandler("onClientPlayerWasted", localPlayer, killTimerOnExit)

-- Server Response Handler
addEvent("onFileCreationSuccess", true)
addEventHandler("onFileCreationSuccess", localPlayer, function(path)
    currentFilePath = path
    outputChatBox("Recording started for: " .. path, 255, 255, 255)
    DGS:dgsComboBoxAddItem(pathsComboBox, path)
end)
