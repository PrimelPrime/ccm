--[[
	* This script was made from scratch by chris1384.
	* Do not redistribute this (under other names) without my permission, do not edit & upload without my permission or take any credit from it.
	* For any questions, bug reports or any suggestions, send a message to @chris1384 on Discord.
	
	* Have fun mapping! - chris1384 <3
    * Thanks to chris1384 to letting me use this script! - primelprime
]]

local autoUpdate = true -- // make MT+ auto-update itself, set this to 'false' or delete this file to remove the auto-update feature

local filesFetched = 0
local remoteFiles = {}

addEventHandler("onResourceStart", resourceRoot, function()
	queueGitRepo()
	setTimer(queueGitRepo, 24*60*60*1000, 0) -- 24 hours
end)

function queueGitRepo() -- starting sequence

	filesFetched = 0
	remoteFiles = {}
	
	if not autoUpdate then return end
	
	if not hasObjectPermissionTo(resource, "function.fetchRemote") then 
		setTimer(function()
			local resourceName = getResourceName(getThisResource())
			outputChatBox("[CCM] #FFFFFFResource is #AA0000not allowed #FFFFFFto auto-update itself or modify other content, please allow it using #FF64FF'/aclrequest allow "..resourceName.." all'#FFFFFF then restart!", root, 255, 100, 255, true) 
			outputDebugString("[CCM]: Resource is not allowed to fetch GitHub updates using 'fetchRemote', please allow it using '/aclrequest allow "..resourceName.." all' then restart!", 0, 255, 100, 100) 
		end, 1000, 1)
		return 
	end
	
	fetchRemote("https://api.github.com/repos/primelprime/ccm/contents/ccm", function(response, err)
	
		if response == "ERROR" then
			outputDebugString("[CCM]: Resource failed to fetch for updates, returned "..tostring(response).." with code: "..tostring(err), 0, 255, 100, 100)
			return
		else
			outputDebugString("[CCM]: Checking for updates..", 4, 255, 255, 100)
		end
		
		local response = {fromJSON(response)}
		local dataToSave = {}
	
		for k, v in ipairs(response) do
			if v.download_url then
				remoteFiles[v.name] = {url = v.download_url, sha = v.sha}
				dataToSave[v.name] = {sha = v.sha}
				filesFetched = filesFetched + 1
			end
		end
		
		setTimer(function(dataLoL) downloadRepoFiles(dataLoL) downloadTimer = nil end, 1000, 1, dataToSave, response)
		
	end)
	
end

function downloadRepoFiles(data2save, response)

	if filesFetched == 0 then outputDebugString("[CCM]: Resource file paths failed to fetch, aborting download.", 0, 255, 100, 100) return end
	
	local targetFiles = remoteFiles
	remoteFiles = {}
	
	for k,v in pairs(targetFiles) do
	
		fetchRemote(v.url, function(response)
			remoteFiles[k] = {data = response, sha = v.sha}
			filesFetched = filesFetched - 1
			if filesFetched == 0 then
				processFiles(data2save)
			end
		end)
		
	end
	
end

function processFiles(data2save)
	
	local filesModified = {}
	local resourceData = loadDirectoryData() or ""
	local unformattedData = fromJSON(resourceData)
	
	if resourceData and unformattedData and type(unformattedData) == "table" then
		
		for fileName,remoteData in pairs(remoteFiles) do
		
			remoteData.sha = remoteData.sha:upper()
			
			if unformattedData[fileName] and fileExists(fileName) then
			
				unformattedData[fileName].sha = unformattedData[fileName].sha:upper()
				if remoteData.sha ~= unformattedData[fileName].sha then
				
					if fileExists("addons/backups/"..fileName..".bak") then 
						fileDelete("addons/backups/"..fileName..".bak") 
					end
					
					if fileExists(fileName) then 
						fileRename(fileName, "addons/backups/"..fileName..".bak")
					end
					
					local file = fileCreate(fileName)
					if file then	
						fileWrite(file, remoteData.data)
						table.insert(filesModified, fileName)
						fileClose(file)
					end
				
				end
				
			else
			
				local file = fileCreate(fileName)
				if file then	
					fileWrite(file, remoteData.data)
					table.insert(filesModified, fileName)
					fileClose(file)
				end
				
			end
		end
		
	else
	
		for fileName,remoteData in pairs(remoteFiles) do
		
			if fileExists("addons/backups/"..fileName..".bak") then 
				fileDelete("addons/backups/"..fileName..".bak") 
			end
			
			if fileExists(fileName) then 
				fileRename(fileName, "addons/backups/"..fileName..".bak")
			end
			
			local file = fileCreate(fileName)
			if file then	
				fileWrite(file, remoteData.data)
				table.insert(filesModified, fileName)
				fileClose(file)
			end
				
		end
	end
	
	saveDirectoryData(toJSON(data2save))
	
	if #filesModified > 0 then
		fetchRemote("https://api.github.com/repos/primelprime/ccm/commits", function(...)
		
			local commitData = {fromJSON(...)}
			
			if commitData then
			
				outputDebugString("[CCM]: Auto-updater has finished. Modified ["..table.concat(filesModified, ", ").."] "..tostring(#filesModified).." files.", 4, 100, 255, 100)
				outputDebugString("[CCM]: Update title: '"..string.gsub(commitData[1].commit.message, "\n\n", " - ").."'", 4, 100, 255, 100)
				outputChatBox("[CCM] #FFFFFFThe resource has been updated! Title: #FF64FF'"..string.gsub(commitData[1].commit.message, "\n\n", " #FFFFFF- #FF64FF").."'", root, 255, 100, 255, true)
				
				if hasObjectPermissionTo(resource, "function.restartResource") then 
					restartResource(resource)
				else
					outputDebugString("[CCM]: Resource was not able to restart itself, please restart it to apply updates.", 0, 255, 100, 100) 
				end
				
			end
			
		end)
	else
		outputDebugString("[CCM]: Auto-updater has finished. No updates.", 4, 100, 255, 100)
	end
	
end

function saveDirectoryData(data)
	if fileExists("addons/autoupdater.json") then fileDelete("addons/autoupdater.json") end
	local file = fileCreate("addons/autoupdater.json")
	if file then
		fileWrite(file, data)
		fileClose(file)
		return true
	end
	return false
end

function loadDirectoryData()
	local returnedData
	local file = fileExists("addons/autoupdater.json") == true and fileOpen("addons/autoupdater.json") or nil
	if file then
		returnedData = fileRead(file, fileGetSize(file))
		fileClose(file)
	end
	return returnedData
end