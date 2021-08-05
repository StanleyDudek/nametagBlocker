--nametagBlocker (CLIENT)

local M = {}

local function onPreRender(dt)
	MPVehicleGE.hideNicknames(true)
end

local function onExtensionLoaded()
	MPVehicleGE.hideNicknames(true)
	log("M","nametagBlocker","Loading nametagBlocker")
end

local function onExtensionUnloaded()
	Lua:requestReload()
	log("M","nametagBlocker","Unloading nametagBlocker")
end

M.onPreRender = onPreRender

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

return M