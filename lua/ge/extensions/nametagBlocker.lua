--nametagBlocker (CLIENT)

local M = {}

local whitelisted = false
local nametagBlockerActive = false
local nametagBlockerTimeout

local function rxWhitelist(data)
	if data == "false" then
		whitelisted = false
	elseif data == "true" then
		whitelisted = true
	end
end

local function rxNametagBlockerActive(data)
	if data == "false" then
		nametagBlockerActive = false
	elseif data == "true" then
		nametagBlockerActive = true
	end
end

local function rxNametagBlockerTimeout(data)
	if tonumber(data) == 0 then
		nametagBlockerTimeout = nil
	else
		nametagBlockerTimeout = tonumber(data)
	end
end

local function onExtensionLoaded()
	log("D","nametagBlocker","Loading nametagBlocker")
	AddEventHandler("rxWhitelist", rxWhitelist)
	AddEventHandler("rxNametagBlockerActive", rxNametagBlockerActive)
	AddEventHandler("rxNametagBlockerTimeout", rxNametagBlockerTimeout)
	log("D","nametagBlocker","nametagBlocker Loaded")
end

local function onExtensionUnloaded()
	log("D","nametagBlocker","Unloading nametagBlocker")
	Lua:requestReload()
	log("D","nametagBlocker","nametagBlocker Unoaded")
end

local function onPreRender(dt)
	if nametagBlockerActive then
		if nametagBlockerTimeout ~= nil then
			nametagBlockerTimeout = nametagBlockerTimeout - dt
			if nametagBlockerTimeout > 0 then
				if not whitelisted then
					MPVehicleGE.hideNicknames(true)
				else
					MPVehicleGE.hideNicknames(false)
				end
			else
				nametagBlockerTimeout = nil
			end
		else
			if not whitelisted then
				MPVehicleGE.hideNicknames(true)
			else
				MPVehicleGE.hideNicknames(false)
			end
		end
	else
		MPVehicleGE.hideNicknames(false)
	end
end

M.onPreRender = onPreRender

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

return M
