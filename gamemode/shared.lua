
local basefol = GM.FolderName.."/gamemode/gm-modules/"

local function LoadModuleFolder(modulenm)

	local full_folder = basefol
	if modulenm and modulenm ~= "" then
	    full_folder = full_folder .. modulenm .. "/"
	end

	local files, folders = file.Find(full_folder .. "*", "LUA")

	-- Uncommenting lines after will enable recursivity. Unrequired at this point and might interrupt with item systems etc
	--for _, ifolder in pairs(folders) do
	--	LoadModuleFolder(modulenm .. "/" .. ifolder .. "/")
	--end

	for _, shfile in pairs(file.Find(full_folder .. "sh_*.lua", "LUA")) do
		if SERVER then AddCSLuaFile(full_folder .. shfile) end
		include(full_folder .. shfile)
		wyodr.PersistLog("Loading sh module " .. shfile)
	end

	if SERVER then
		for _, svfile in pairs(file.Find(full_folder .. "sv_*.lua", "LUA")) do
			include(full_folder .. svfile)
			wyodr.PersistLog("Loading sv module " .. svfile)
		end
	end

	for _, clfile in pairs(file.Find(full_folder .. "cl_*.lua", "LUA")) do
		if SERVER then AddCSLuaFile(full_folder .. clfile) end
		if CLIENT then include(full_folder .. clfile) end
		wyodr.PersistLog("Loading cl module " .. clfile)
	end
end

local function LoadModules()

	local _, folders = file.Find(basefol .. "*", "LUA")

	for _, ifolder in pairs(folders) do
		MsgN("Loading module folder " .. ifolder)
		LoadModuleFolder(ifolder)
	end
	
	LoadModuleFolder("")
	MsgN("Loading e modules")

end

GM.Name = "Deathrun"
GM.Author = "Wyozi&Jacob"

local is_debug = CreateConVar("wyodr_debug", "0", FCVAR_ARCHIVE)

wyodr = wyodr or {}
function wyodr.Debug(...)
	if not is_debug:GetBool() then return end
	print("[wyodr-DEBUG] ", ...)
end
function wyodr.IsDebug() return is_debug:GetBool() end

function wyodr.PersistLog(msg)
	if not is_debug:GetBool() then return end

	local f = file.Open("wyodrlog" .. tostring(SERVER and "_sv" or "_cl") .. ".txt", "a", "DATA")
	f:Write(msg .. "\n")
	f:Close()
	
	wyodr.Debug(msg)
end

hook.Add("InitPostEntity", "LoadGamemode", LoadModules)