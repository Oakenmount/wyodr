

local spec_mode_cycle = {
	OBS_MODE_ROAMING,
	OBS_MODE_IN_EYE,
	OBS_MODE_CHASE,
}

-- FINLAND STRONK NOKIA STRONK LEGO IS KILL!
function GAMEMODE:KeyPress( ply, key )
	if ply:Team() ~= TEAM_SPECTATOR and ply:Alive() then return end -- only specs pls
	
	if ( key == IN_ATTACK or key == IN_ATTACK2 ) then
		local AlivePlys = {}
		for k,v in pairs(player.GetAll()) do
			if v:Alive() and v:Team() ~= TEAM_SPECTATOR and not v:GetMoonMode() then
				table.insert(AlivePlys,v)
			end
		end
	
		local spectarg = ply:GetObserverTarget()
		local newspectarg
		if IsValid(spectarg) and spectarg:IsPlayer() and #AlivePlys > 0 then
			local nfunc = key == IN_ATTACK and table.FindNext or table.FindPrev
			newspectarg = nfunc(AlivePlys, spectarg)
		else
			newspectarg = AlivePlys[1]
		end
	
		if IsValid(newspectarg) then
			ply:SpectateEntity(newspectarg)
			if ply:GetObserverMode() ~= OBS_MODE_CHASE and ply:GetObserverMode() ~= OBS_MODE_IN_EYE then
				ply:Spectate( OBS_MODE_CHASE )
			end
		end
	end
	if ( key == IN_JUMP ) then
		if IsValid(ply:GetObserverTarget()) and ply:GetObserverTarget() ~= ply then
			ply:Spectate(table.FindNext(spec_mode_cycle, ply:GetObserverMode()))
		else
			ply:Spectate(OBS_MODE_ROAMING)
		end
	end
end

util.AddNetworkString("wyodr_specply")
net.Receive("wyodr_specply", function(len, cl)
	if cl:Alive() and cl:Team() ~= TEAM_SPECTATOR then return end
	local targ = net.ReadEntity()
	if not IsValid(targ) or not targ:IsPlayer() then return end
	
	cl:SpectateEntity(targ)
	cl:Spectate(OBS_MODE_CHASE)
end)