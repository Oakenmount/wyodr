hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn", function(ply)
	if wyodr.GetRoundState() == ROUND_ACTIVE then
		ply:SilentKill()
	end
	
	ply:SetTeam(TEAM_RUNNER)
end)
hook.Add("PlayerSpawn", "PlayerSpawn", function(ply)
	if ply:Team() ~= TEAM_DEATH and ply:Team() ~= TEAM_RUNNER then
		GAMEMODE:PlayerSpawnAsSpectator(ply)
		return
	end
    
    ply:AllowFlashlight(true)
    ply:SetRunSpeed(325)
    ply:SetWalkSpeed(250)
    ply:SetJumpPower( math.sqrt(2 * 800 * 57.0) ) -- 2 * gravity * height
    ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 62 ) )
    ply:SetHullDuck( Vector( -16, -16, 0 ), Vector( 16, 16, 45 ) )
	
	ply:UnSpectate()
    player_manager.OnPlayerSpawn(ply)
    player_manager.RunClass(ply, "Spawn")
    
    ply:SetNoCollideWithTeammates( true )
    
    hook.Call("PlayerSetModel", GAMEMODE, ply)
    hook.Call("PlayerLoadout", GAMEMODE, ply)
    

	local oldhands = ply:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end
	
	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		ply:SetHands( hands )
		hands:SetOwner( ply )
		
		-- Which hands should we use?
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
		local info = player_manager.TranslatePlayerHands( cl_playermodel )
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end
		
		-- Attach them to the viewmodel
		local vm = ply:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )
		
		vm:DeleteOnRemove( hands )
		ply:DeleteOnRemove( hands )
		
		hands:Spawn()
	end

end)
hook.Add("PlayerLoadout", "PlayerLoadout", function(ply)
    ply:Give("weapon_crowbar")
	ply:StripWeapons()
	return true
end)

hook.Add("PlayerSpawnAsSpectator", "PlayerSpawnAsSpectator", function(ply)
    ply:StripWeapons()
    ply:SetTeam(TEAM_SPECTATOR)
    ply:Spectate(OBS_MODE_ROAMING)
    return true
end)

hook.Add("PlayerSetModel", "PlayerSetModel", function(ply)
	local team = ply:Team()
	local model
	if team == TEAM_RUNNER then
		model = "models/player/group03/male_0"..math.random(1,9)..".mdl"
	elseif team == TEAM_DEATH then
		model = "models/player/combine_soldier.mdl"
	end
	
	if model then ply:SetModel(model) end
end)

hook.Add("PlayerDeathSound", "PlayerDeathSound", function()
	return true
end)

hook.Add("PlayerDeathThink", "PlayerDeathThink", function(ply)
    local DeathTime = DeathTime or CurTime() + 1.2
    if #team.GetPlayers(TEAM_DEATH) < 1 then
        ply:Spawn()
    end
    
	if ply:GetObserverMode() == OBS_MODE_NONE and CurTime() > DeathTime then
		ply:Spectate(OBS_MODE_ROAMING)
	end
	return true
end)

hook.Add("DRPreventTeamJoin", "DRPreventTeamJoin", function(ply,teamid)
	local runners = team.NumPlayers(TEAM_RUNNER)
	local deaths = team.NumPlayers(TEAM_DEATH)
	
	if deaths == 0 then return false end
	
	if teamid == TEAM_DEATH and ply:Team() == TEAM_RUNNER and (((runners  - 1) / (deaths + 1)) < GetConVarNumber("dr_death_ratio")) then
		wyodr.ErrorMsg(ply,"Team is full! Ratio must be 1:"..GetConVarNumber("dr_death_ratio"))
		return true
	elseif teamid == TEAM_DEATH and ply:Team() == TEAM_SPECTATOR and (((runners ) / (deaths + 1)) < GetConVarNumber("dr_death_ratio")) then
		wyodr.ErrorMsg(ply,"Team is full! Ratio must be 1:"..GetConVarNumber("dr_death_ratio"))
		return true
	end
	return false
end)

util.AddNetworkString("teamChange")
net.Receive("teamChange",function(len,ply)
	if ply.NextTeamSwitch and ply.NextTeamSwitch > CurTime() then
		wyodr.ErrorMsg(ply,"You are attempting to switch teams too fast!")
		return
	end
	
	local teamid = net.ReadUInt(8)
	local oldteamid = ply:Team()
	if teamid == ply:Team() then
		return wyodr.ErrorMsg(ply, "You can't join the team you're already on!")
	end
	if not hook.Call("DRPreventTeamJoin",GAMEMODE,ply,teamid) then 
		ply.NextTeamSwitch = CurTime() + 1.5
		ply:SetNWBool("FreshMeat",false)
		if (wyodr.GetRoundState() == ROUND_WAIT) then
			ply:SetTeam(teamid)
			ply:Spawn()
		else
			ply:KillSilent()
			ply:SetTeam(teamid)
		end
		
		if wyodr.GetRoundState() == ROUND_ACTIVE and oldteamid != TEAM_SPECTATOR and (ply:GetObserverMode() != OBS_MODE_NONE) then
			if ply:GetObserverMode() == OBS_MODE_NONE  then
				ply:Kill()
				GAMEMODE:PlayerSpawnAsSpectator(ply)
			else
				ply:KillSilent()
				GAMEMODE:PlayerSpawnAsSpectator(ply)
			end
		end
	end

end)




hook.Add("EntityTakeDamage", "MMDmgBlock", function(target, dmginfo)
	if target:IsPlayer() and target:GetMoonMode() then
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) and attacker:IsPlayer() then
			wyodr.ErrorMsg(attacker, "Target is in coding mode, do not attack!")
		end
		dmginfo:SetDamage(0)
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "DeafModeStuff", function(listener, talker)
	if listener:GetDeafMode() then return false end -- If deafmode, dont transmit any voices
end)

hook.Add("OnPlayerHitGround","StaminaReplicate",function(ply,bool)
	ply:SetJumpPower(268.4)
	timer.Simple(0.2,function () ply:SetJumpPower(280) end)
end)
