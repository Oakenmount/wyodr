wyodr.GetRoundState = function()
	return GetGlobalInt("roundstate", ROUND_WAIT)
end

wyodr.UnpackPlyString = function(plystr)
	local spl = plystr:Split("::")
	if #spl < 3 then return nil end
	return spl[1], spl[3], ULib.getPlyByID(spl[1]), tonumber(spl[2])
end

wyodr.PackPlyString = function(ply)
	return string.format("%s::%d::%s", ply:SteamID(), ply:Team(), ply:Nick())
end

wyodr.PackEntString = function(ent)
	if not IsValid(ent) or ent:IsWorld() then return "world" end
	if ent:IsPlayer() then return wyodr.PackPlyString(ent) end
	return ent:GetClass()
end

local playermeta = FindMetaTable("Player")

function playermeta:IsActivePlayer()
	return (self:Team() == TEAM_DEATH or self:Team() == TEAM_RUNNER)
end

function playermeta:IsAlivePlayer()
	return self:Alive() and self:IsActivePlayer()
end

hook.Add("PlayerFootstep", "PreventFootstepsPlaying", function(ply, pos, foot, sound, volume, rf)
	if IsValid(ply) and (ply:Crouching() or ply:GetMaxSpeed() < 150) then
		-- do not play anything, just prevent normal sounds from playing
		return true
	end
end)

if SERVER then
	hook.Add("PlayerInitialSpawn", "FetchPlayerCountry", function(ply)
		http.Fetch("http://freegeoip.net/json/" .. (ply:IPAddress():Split(":")[1]), function(data)
			local tbl = util.JSONToTable(data)
			if tbl and IsValid(ply) then
				ply:SetNWString("countryname", tbl.country_name)
				ply:SetNWString("countrycode", tbl.country_code)
			end
		end, function() end)
	end)
end