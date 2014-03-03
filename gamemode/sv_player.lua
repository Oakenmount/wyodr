function GAMEMODE:PlayerInitialSpawn(ply)
	if epicjb.GetRoundState() == ROUND_ACTIVE then
		ply:SetTeam(TEAM_SPECTATOR)
	else
		ply:SetTeam(TEAM_PRISONER)
	end
end
function GAMEMODE:PlayerSpawn(ply)
	if ply:Team() ~= TEAM_GUARD and ply:Team() ~= TEAM_PRISONER then
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
    
	if ply:Team() == TEAM_GUARD then
		ply:SetArmor(25)
	end

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

end
function GAMEMODE:PlayerLoadout(ply)
	ply:StripWeapons()
	ply:Give("weapon_jb_fists")
	if ply:Team() == TEAM_PRISONER and math.random(1,4) == 1 then
		ply:Give("bb_css_knife_alt")
	end
end

function GAMEMODE:PlayerSpawnAsSpectator(ply)
    ply:StripWeapons()
	ply:SetNWBool("FreshMeat",true)
    ply:SetTeam(TEAM_SPECTATOR)
    ply:Spectate(OBS_MODE_ROAMING)
end

function GAMEMODE:PlayerSetModel(ply)
	local team = ply:Team()
	local model
	if team == TEAM_PRISONER then
		model = "models/player/group03/male_0"..math.random(1,9)..".mdl"
	elseif team == TEAM_GUARD then
		model = "models/player/combine_soldier.mdl"
	end
	
	if model then ply:SetModel(model) end
end

function GAMEMODE:PlayerDeathSound()
	return true
end

function GAMEMODE:PlayerDeathThink(ply)
    local DeathTime = DeathTime or CurTime() + 1.2
	if ply:GetObserverMode() == OBS_MODE_NONE and CurTime() > DeathTime then
		ply:Spectate(OBS_MODE_ROAMING)
	end
end

function GAMEMODE:JBPreventTeamJoin(ply,teamid)
	local prisoners = team.NumPlayers(TEAM_PRISONER)
	local guards = team.NumPlayers(TEAM_GUARD)
	
	if guards == 0 then return false end
	
	if teamid == TEAM_GUARD and ply:Team() == TEAM_PRISONER and (((prisoners  - 1) / (guards + 1)) < GetConVarNumber("jb_guard_ratio")) then
		epicjb.ErrorMsg(ply,"Team is full! Ratio must be 1:"..GetConVarNumber("jb_guard_ratio"))
		return true
	elseif teamid == TEAM_GUARD and ply:Team() == TEAM_SPECTATOR and (((prisoners ) / (guards + 1)) < GetConVarNumber("jb_guard_ratio")) then
		epicjb.ErrorMsg(ply,"Team is full! Ratio must be 1:"..GetConVarNumber("jb_guard_ratio"))
		return true
	end
	return false
end


util.AddNetworkString("teamChange")
net.Receive("teamChange",function(len,ply)
	if ply.NextTeamSwitch and ply.NextTeamSwitch > CurTime() then
		epicjb.ErrorMsg(ply,"You are attempting to switch teams too fast!")
		return
	end
	
	local teamid = net.ReadUInt(8)
	local oldteamid = ply:Team()
	if teamid == ply:Team() then
		return epicjb.ErrorMsg(ply, "You can't join the team you're already on!")
	end
	if not hook.Call("JBPreventTeamJoin",GAMEMODE,ply,teamid) then 
		ply.NextTeamSwitch = CurTime() + 1.5
		ply:SetNWBool("FreshMeat",false)
		if (epicjb.GetRoundState() == ROUND_WAIT) then
			ply:SetTeam(teamid)
			ply:Spawn()
		else
			ply:KillSilent()
			ply:SetTeam(teamid)
		end
		
		if epicjb.GetRoundState() == ROUND_ACTIVE and oldteamid != TEAM_SPECTATOR and (ply:GetObserverMode() != OBS_MODE_NONE) then
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


hook.Add("ScalePlayerDamage", "NerfEverything", function(ply, hitgroup, dmginfo)
	if dmginfo:IsBulletDamage() and hitgroup ~= HITGROUP_HEAD then
		dmginfo:ScaleDamage(0.6)	
	end
end)

hook.Add("PlayerShouldTakeDamage","NOFF",function( victim, pl )
	if pl:IsPlayer() and pl ~= victim then
		if (pl:Team() == victim:Team() and epicjb.GetRoundState() ~= ROUND_POST) and GetConVarNumber("mp_friendlyfire") == 0 then -- check the teams are equal and that friendly fire is off.
			return false
		end
	end
	
	return true
end)


local function TeamBalance()
	
	local numGuard = team.NumPlayers(TEAM_GUARD)
	local numPrisoner = team.NumPlayers(TEAM_PRISONER)
	
	if #player.GetAll() < (GetConVarNumber("jb_guard_ratio") + 1) or numGuard <= 1 then return end
	
	if ((numPrisoner) / numGuard) < GetConVarNumber("jb_guard_ratio") then
		local randomMember = math.random(1,#team.GetPlayers(TEAM_GUARD))
		local affected_pl = team.GetPlayers(TEAM_GUARD)[randomMember]
		epicjb.Notify(affected_pl:Nick().." was moved due to teambalance!")
		affected_pl:SetTeam(TEAM_PRISONER)
		TeamBalance()
	end
	
end
hook.Add("RoundEnd","TeamBalance",TeamBalance)

hook.Add("RoundStart","MutePrisoners",function()
	epicjb.PrisonersMuted = true
	epicjb.Notify("Prisoners have been gagged for 20 seconds!")
	timer.Create("unmuteprisoners", 20, 1, function()
		epicjb.PrisonersMuted = false
		epicjb.Notify("Prisoners have been ungagged!")
	end)
end)
hook.Add("RoundEnd","TeamBalance",function()
	epicjb.PrisonersMuted = false
	timer.Destroy("unmuteprisoners")
	for k,v in pairs(player.GetAll()) do
	    if v:IsActivePlayer() then
	        v:IncrAchStat("roundsplayed", 1)
	    end
    end
    
end)

hook.Add("EntityTakeDamage", "MMDmgBlock", function(target, dmginfo)
	if target:IsPlayer() and target:GetMoonMode() then
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) and attacker:IsPlayer() then
			epicjb.ErrorMsg(attacker, "Target is in coding mode, do not attack!")
		end
		dmginfo:SetDamage(0)
	end
end)

function GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)
	if listener:GetDeafMode() then return false end -- If deafmode, dont transmit any voices
	return (((talker:Team() ~= TEAM_PRISONER or not epicjb.PrisonersMuted) and (talker:IsAlivePlayer() or (not listener:IsAlivePlayer()))) or epicjb.GetRoundState() ~= ROUND_ACTIVE) or talker:IsAdmin()
end

hook.Add("PlayerDeath","notifyvictim",function(victim,ent,killer)
    if victim == killer or (not killer:IsPlayer()) then return end
    epicjb.NotifyPly(victim,"You were killed by "..killer:Nick())
end)


hook.Add("OnPlayerHitGround","StaminaReplicate",function(ply,bool)
	ply:SetJumpPower(268.4)
	timer.Simple(0.3,function () ply:SetJumpPower(280) end)
end)
