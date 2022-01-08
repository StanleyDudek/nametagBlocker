--nametagBlocker (SERVER)

-----------------------------------------CONFIG----------------------------------------
local nametagBlockerAdmins = {"Dudekahedron"} --names can be stored as comma-separated strings, e.g. {"name1", "name2", "etc"}
local nametagWhitelist = {} --names can be stored as comma-separated strings, e.g. {"name1", "name2", "etc"}
local commandPrefix = "!" --can be whatever you want, be mindful of command prefixes used by other plugins
-----------------------------------------CONFIG----------------------------------------

local nametagBlockerTimeout
local nametagBlockerTimeoutStep = 0.2
local nametagBlockerActive = false

function onInit()
	MP.RegisterEvent("onChatMessage", "onChatMessage")
	MP.RegisterEvent("txWhitelist", "txWhitelist")
	MP.RegisterEvent("txNametagBlockerActive", "txNametagBlockerActive")
	MP.RegisterEvent("txNametagBlockerTimeout", "txNametagBlockerTimeout")
	MP.RegisterEvent("nametagBlockerTimer", "nametagBlockerTimer")
	MP.CreateEventTimer("txWhitelist", 500)
	MP.CreateEventTimer("txNametagBlockerActive", 500)
	MP.CreateEventTimer("nametagBlockerTimer", 200)
	print("nametagBlocker loaded")
end

function onChatMessage(ID, name, message)
	if message:sub(1,1) == commandPrefix then
		command = string.sub(message,2)
		onCommand(ID, command)
		return 1
	else
	end
end

function txWhitelist()
	local isWhitelisted
	for playerID,playerName in pairs(MP.GetPlayers()) do
		if MP.IsPlayerConnected(playerID) then
			if isPlayerWhitelisted(playerID) then
				isWhitelisted = "true"
			else
				isWhitelisted = "false"
			end
			MP.TriggerClientEvent(playerID,"rxWhitelist",isWhitelisted)
		end
	end
end

function txNametagBlockerActive()
	local isNametagBlockerActive
	for playerID,playerName in pairs(MP.GetPlayers()) do
		if MP.IsPlayerConnected(playerID) then
			if nametagBlockerActive then
				isNametagBlockerActive = "true"
			else
				isNametagBlockerActive = "false"
			end
			MP.TriggerClientEvent(playerID,"rxNametagBlockerActive",isNametagBlockerActive)
		end
	end
end

function txNametagBlockerTimeout()
	for playerID,playerName in pairs(MP.GetPlayers()) do
		if MP.IsPlayerConnected(playerID) then
			if nametagBlockerTimeout ~= nil then
				MP.TriggerClientEvent(playerID,"rxNametagBlockerTimeout",tostring(nametagBlockerTimeout))
			else
				MP.TriggerClientEvent(playerID,"rxNametagBlockerTimeout","0")
				nametagBlockerTimeout = nil
			end
		end
	end
end

function nametagBlockerTimer()
	if nametagBlockerActive then
		if nametagBlockerTimeout ~= nil then
			nametagBlockerTimeout = nametagBlockerTimeout - nametagBlockerTimeoutStep
			if nametagBlockerTimeout > 0 then
			else
				nametagBlockerTimeout = nil
				nametagBlockerActive = false
				txNametagBlockerTimeout()
				MP.SendChatMessage(-1, "---------------nametagBlocker Timer---------------")
				MP.SendChatMessage(-1, "nametagBlocker timer now deactivated!")
				MP.SendChatMessage(-1, "nametagBlocker now disabled!")
				MP.SendChatMessage(-1, "---------------nametagBlocker Timer---------------")
			end
		end
	end
end

function adminStatus(senderID)
	MP.SendChatMessage(senderID, "---------------nametagBlocker Admins--------------")
	if #nametagBlockerAdmins > 0 then
		for _,playerName in pairs(nametagBlockerAdmins) do
			MP.SendChatMessage(senderID, playerName)
		end
		
	else
		MP.SendChatMessage(senderID, "No nametagBlocker Admins! Make sure at least one is configured in nametagBlocker.lua and restart server")
	end
	MP.SendChatMessage(senderID, "---------------nametagBlocker Admins--------------")
end

function admins(senderID)
	adminStatus(senderID)
end

function a(senderID)
	adminStatus(senderID)
end

function as(senderID)
	adminStatus(senderID)
end

function addAdmin(senderID, targetName)
	MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
	if not isPlayerAdmin(senderID) then
		MP.SendChatMessage(senderID,"You cannot use the nametagBlocker Admin function!")
		MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
		return
	end
	if targetName == MP.GetPlayerName(senderID) then
		MP.SendChatMessage(senderID, "You are already a nametagBlocker Admin!")
	elseif targetName == "" then
		MP.SendChatMessage(senderID, "No name specified!")
	else
		table.insert(nametagBlockerAdmins, targetName)
		MP.SendChatMessage(senderID, targetName .. " added as a nametagBlocker Admin!")
	end
	MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
end

function removeAdmin(senderID, targetName)
	MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
	if not isPlayerAdmin(senderID) then
		MP.SendChatMessage(senderID,"You cannot use the nametagBlocker Admin function!")
		MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
		return
	end
	if targetName == "self" or targetName == "me" or targetName == MP.GetPlayerName(senderID) then
		targetName = MP.GetPlayerName(senderID)
		removeByName(nametagBlockerAdmins, targetName)
		MP.SendChatMessage(senderID, targetName .. " removed as a nametagBlocker Admin!")
	elseif targetName == "" then
		MP.SendChatMessage(senderID, "No name specified!")
	else
		removeByName(nametagBlockerAdmins, targetName)
		MP.SendChatMessage(senderID, targetName .. " removed as a nametagBlocker Admin!")
	end
	MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
end

function addadmin(senderID, targetName)
	addAdmin(senderID, targetName)
end

function removeadmin(senderID, targetName)
	removeAdmin(senderID, targetName)
end

function aa(senderID, targetName)
	addAdmin(senderID, targetName)
end

function ra(senderID, targetName)
	removeAdmin(senderID, targetName)
end

function whitelist(senderID, targetName)
	MP.SendChatMessage(senderID, "---------------nametagBlocker Whitelist---------------")
	if not isPlayerAdmin(senderID) then
		whitelistStatus(senderID)
		MP.SendChatMessage(senderID, "---------------nametagBlocker Whitelist---------------")
		return
	end
	if targetName == "self" or targetName == "me" then
		targetName = MP.GetPlayerName(senderID)
		table.insert(nametagWhitelist, targetName)
		MP.SendChatMessage(senderID, targetName .. " added to the whitelist!")
	elseif targetName == "" then
		whitelistStatus(senderID)
	else
		table.insert(nametagWhitelist, targetName)
		MP.SendChatMessage(senderID, targetName .. " added to the whitelist!")
	end
	MP.SendChatMessage(senderID, "---------------nametagBlocker Whitelist---------------")
end

function blacklist(senderID, targetName)
	MP.SendChatMessage(senderID, "---------------nametagBlocker Whitelist---------------")
	if not isPlayerAdmin(senderID) then
		MP.SendChatMessage(senderID,"You cannot operate the whitelist!")
		return
	end
	MP.SendChatMessage(senderID, "---------------nametagBlocker Whitelist---------------")
	if targetName == "self" or targetName == "me" then
		targetName = MP.GetPlayerName(senderID)
		removeByName(nametagWhitelist,targetName)
		MP.SendChatMessage(senderID, targetName .. " removed from the whitelist!")
	elseif targetName == "" then
		whitelistStatus(senderID)
	else
		removeByName(nametagWhitelist,targetName)
		MP.SendChatMessage(senderID, targetName .. " removed from the whitelist!")
	end
	MP.SendChatMessage(senderID, "---------------nametagBlocker Whitelist---------------")
end

function w(senderID, targetName)
	whitelist(senderID, targetName)
end

function b(senderID, targetName)
	blacklist(senderID, targetName)
end

function whitelistStatus(senderID)
	if #nametagWhitelist > 0 then
		for _,playerName in pairs(nametagWhitelist) do
			MP.SendChatMessage(senderID, "Whitelisted Player: " .. playerName)
		end
	else
		MP.SendChatMessage(senderID, "No Whitelisted Players!")
	end
end

function timer(senderID, data)
	if tonumber(data) ~= nil then
		if not isPlayerAdmin(senderID) then
			MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
			MP.SendChatMessage(senderID,"You cannot operate the timer!")
			MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
			return
		end
		MP.SendChatMessage(-1, "---------------nametagBlocker Timer---------------")
		if tonumber(data) > 0 then
			nametagBlockerTimeout = tonumber(data)
			nametagBlockerActive = true
			txNametagBlockerTimeout()
			MP.SendChatMessage(-1, "nametagBlocker now enabled!")
			MP.SendChatMessage(-1, "nametagBlocker timer now active for " .. nametagBlockerTimeout .. " seconds!")
		elseif tonumber(data) == 0 then
			nametagBlockerTimeout = nil
			nametagBlockerActive = false
			txNametagBlockerTimeout()
			MP.SendChatMessage(-1, "nametagBlocker timer now deactivated!")
			MP.SendChatMessage(-1, "nametagBlocker now disabled!")
		end
		MP.SendChatMessage(-1, "---------------nametagBlocker Timer---------------")
	else
		MP.SendChatMessage(senderID, "---------------nametagBlocker Timer---------------")
		if nametagBlockerTimeout == nil then
			MP.SendChatMessage(senderID, "nametagBlocker timer is not active!")
		else
			MP.SendChatMessage(senderID, nametagBlockerTimeout .. " seconds remaining in nametagBlocker timer!")
		end
		MP.SendChatMessage(senderID, "---------------nametagBlocker Timer---------------")
	end
end

function t(senderID, data)
	timer(senderID, data)
end

function nametagBlocker(senderID, data)
	if not isPlayerAdmin(senderID) then
		if data ~= "" then
			MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
			MP.SendChatMessage(senderID, "You cannot operate the nametagBlocker!")
			MP.SendChatMessage(senderID, "---------------nametagBlocker Admin---------------")
		else
			status(senderID)
		end
	else
		if data == "enable" or data == "e" then
			MP.SendChatMessage(-1, "---------------nametagBlocker Admin---------------")
			if nametagBlockerActive == true then
				MP.SendChatMessage(-1, "nametagBlocker already enabled!")
			else
				nametagBlockerActive = true
				MP.SendChatMessage(-1, "nametagBlocker enabled!")
			end
				MP.SendChatMessage(-1, "---------------nametagBlocker Admin---------------")
		elseif data == "disable" or data == "d" then
			MP.SendChatMessage(-1, "---------------nametagBlocker Admin---------------")
			if nametagBlockerActive == false then
				MP.SendChatMessage(-1, "nametagBlocker already disabled!")
			else
				nametagBlockerActive = false
				MP.SendChatMessage(-1, "nametagBlocker disabled!")
			end
			MP.SendChatMessage(-1, "---------------nametagBlocker Admin---------------")
		elseif data == "" then
			status(senderID)
		end
	end
end

function nb(senderID, data)
	nametagBlocker(senderID, data)
end

function status(senderID, data)
	MP.SendChatMessage(senderID, "---------------nametagBlocker Status---------------")
	if nametagBlockerActive then
		MP.SendChatMessage(senderID, "nametagBlocker is Active!")
	else
		MP.SendChatMessage(senderID, "nametagBlocker is Inactive!")
	end
	
	if nametagBlockerTimeout == nil then
		MP.SendChatMessage(senderID, "nametagBlocker Timer is Inactive!")
	else
		MP.SendChatMessage(senderID, "nametagBlocker Timer is Active!")
	end
	
	if #nametagWhitelist > 0 then
	
		for _,playerName in pairs(nametagWhitelist) do
			MP.SendChatMessage(senderID, "Whitelisted Player: " .. playerName)
		end
		
	else
		MP.SendChatMessage(senderID, "No Whitelisted Players!")
	end
	MP.SendChatMessage(senderID, "---------------nametagBlocker Status---------------")
end

function s(senderID, data)
	status(senderID, data)
end

function usage(senderID, data)
	MP.SendChatMessage(senderID, "---------------nametagBlocker Help---------------")
	MP.SendChatMessage(senderID, commandPrefix .. "nb -or- " .. commandPrefix .. "s -or- " .. commandPrefix .. "status -> show nametagBlocker Status")
	MP.SendChatMessage(senderID, commandPrefix .. "nb enable -or- " .. commandPrefix .. "nb e -> enable nametagBlocker")
	MP.SendChatMessage(senderID, commandPrefix .. "nb disable -or- " .. commandPrefix .. "nb d -> disable nametagBlocker")
	MP.SendChatMessage(senderID, commandPrefix .. "a -or- " .. commandPrefix .. "as -or- " .. commandPrefix .. "admins -> show list of nametagBlocker Admins")
	MP.SendChatMessage(senderID, commandPrefix .. "aa -or- " .. commandPrefix .. "addadmin -> adds name to nametagBlocker Admins")
	MP.SendChatMessage(senderID, commandPrefix .. "ra -or- " .. commandPrefix .. "removeadmin -> removes name from nametagBlocker Admins")
	MP.SendChatMessage(senderID, commandPrefix .. "w -> show whitelist")
	MP.SendChatMessage(senderID, commandPrefix .. "w [targetName] -> adds name to whitelist")
	MP.SendChatMessage(senderID, commandPrefix .. "w self -or- " .. commandPrefix .. "w me -> adds self to whitelist")
	MP.SendChatMessage(senderID, commandPrefix .. "b [targetName] -or- " .. commandPrefix .. "blacklist [targetName] -> removes name from whitelist")
	MP.SendChatMessage(senderID, commandPrefix .. "b self -or- " .. commandPrefix .. "b me -> removes self from blacklist")
	MP.SendChatMessage(senderID, commandPrefix .. "t -or- " .. commandPrefix .. "timer -> shows nametagBlocker timer status")
	MP.SendChatMessage(senderID, commandPrefix .. "t [seconds > 0] -> sets nametagBlocker timer")
	MP.SendChatMessage(senderID, commandPrefix .. "t 0 -> deactivate nametagBlocker timer")
	MP.SendChatMessage(senderID, commandPrefix .. "h -or- " .. commandPrefix .. "help -or- " .. commandPrefix .. "u -or- " .. commandPrefix .. "usage -> shows this help")
	MP.SendChatMessage(senderID, "---------------nametagBlocker Help---------------")
end

function u(senderID, data)
	usage(senderID, data)
end

function help(senderID, data)
	usage(senderID, data)
end

function h(senderID, data)
	usage(senderID, data)
end

function isPlayerAdmin(playerID)
	local playerName = MP.GetPlayerName(playerID)
	local isAdmin = false
	for _, adminName in pairs(nametagBlockerAdmins) do
		if playerName == adminName then
			isAdmin = true
			break
		end
	end
	return isAdmin
end

function isPlayerWhitelisted(playerID)
	local playerName = MP.GetPlayerName(playerID)
	local isWhitelisted = false
	for _, whitelistName in pairs(nametagWhitelist) do
		if playerName == whitelistName then
			isWhitelisted = true
			break
		end
	end
	return isWhitelisted
end

function onCommand(ID, data)
	local command = split(data," ")[1]
	local args
	local s = data:find(" ")
	if s ~= nil then
		args = data:sub(s+1)
	end
	args = args or ""
	_G[command](ID, args)
end

function split(s, sep)
	local fields = {}
	local sep = sep or " "
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
	return fields
end

function removeByName(tableName, playerName)
	for index, value in ipairs(tableName) do 
		if (value == playerName) then
			tableName[index] = nil
		end
	end
end
