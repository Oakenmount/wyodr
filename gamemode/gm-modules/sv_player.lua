hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn", function(ply)
    ply:SetTeam(TEAM_RUNNER)
    ply:Spawn()
	if wyodr.GetRoundState() == ROUND_ACTIVE then
		ply:KillSilent()
	end
	if tobool(ply:GetPData("supporter",false) or false) == true then
    	ply:SetNWBool("supporter",true)
    end
	return true
end)

hook.Add("PlayerSpawn", "PlayerSpawn", function(ply)
	if ply:Team() ~= TEAM_DEATH and ply:Team() ~= TEAM_RUNNER then
		GAMEMODE:PlayerSpawnAsSpectator(ply)
		return true
	end
    
    ply:AllowFlashlight(true)
    ply:SetRunSpeed(250)
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
    
	
    return true
end)
hook.Add("PlayerLoadout", "PlayerLoadout", function(ply)
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
	
	return true
end)

hook.Add("PlayerDeathSound", "PlayerDeathSound", function()
	return true
end)

hook.Add( "PlayerDeath", "player_initalize_dvars", function(ply,wep,kil)
    ply.nextspawn = CurTime() + 0.8
end)


hook.Add("PlayerDeathThink", "PlayerDeathThink", function(ply)
    if ply.nextspawn and CurTime() < ply.nextspawn then return true end
    if wyodr.GetRoundState() == ROUND_POST then return true end
    if #team.GetPlayers(TEAM_DEATH) < 1 then
        --ply:Spawn()
        return true
    end
    
	if ply:GetObserverMode() == OBS_MODE_NONE then
		ply:Spectate(OBS_MODE_ROAMING)
		return true
	end
	return true
end)

hook.Add("DRPreventTeamJoin", "DRPreventTeamJoin", function(ply,teamid)
	local runners = team.NumPlayers(TEAM_RUNNER)
	local deaths = team.NumPlayers(TEAM_DEATH)
	
	if deaths == 0 then return false end
	
	if teamid == TEAM_DEATH and deaths >= 2 then
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


hook.Add("EntityTakeDamage", "TeamDmgBlock", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
	if target:IsPlayer() and attacker:IsPlayer() and target:Team() == attacker:Team() then
		dmginfo:SetDamage(0)
	end
end)                                    


hook.Add("PlayerCanHearPlayersVoice", "DeafModeStuff", function(listener, talker)
	if listener:GetDeafMode() then return false end -- If deafmode, dont transmit any voices
	return true
end)

hook.Add("OnPlayerHitGround","StaminaReplicate",function(ply,bool)

end)

timer.Create("HealthRegen",1,0,function()
    for k,v in pairs(team.GetPlayers(TEAM_RUNNER)) do
        if v:Health() < v:GetMaxHealth() and v:Alive() then
            v:SetHealth(v:Health() + 1)
        end
    end
end)

