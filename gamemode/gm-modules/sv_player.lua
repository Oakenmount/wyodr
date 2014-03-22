function GAMEMODE:PlayerInitialSpawn(ply)
    ply:SetTeam(TEAM_RUNNER)
    ply:Spawn()
	if wyodr.GetRoundState() == ROUND_ACTIVE then
		ply:KillSilent()
	end
	if tobool(ply:GetPData("supporter",false) or false) == true then
    	ply:SetNWBool("supporter",true)
    end
end

function GAMEMODE:PlayerSpawn(ply)
	if ply:Team() ~= TEAM_DEATH and ply:Team() ~= TEAM_RUNNER then
		GAMEMODE:PlayerSpawnAsSpectator(ply)
		return
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
    
    ply:StripWeapons()
   	ply:Give("weapon_crowbar")
	
end

function GAMEMODE:PlayerLoadout(ply)

end

function GAMEMODE:PlayerSpawnAsSpectator(ply)
    ply:StripWeapons()
    ply:SetTeam(TEAM_SPECTATOR)
    ply:Spectate(OBS_MODE_ROAMING)
end

function GAMEMODE:PlayerSetModel(ply)
	local team = ply:Team()
	local model
	if team == TEAM_RUNNER then
		model = "models/player/group03/male_0"..math.random(1,9)..".mdl"
	elseif team == TEAM_DEATH then
		model = "models/player/combine_soldier.mdl"
	end
	
	if model then ply:SetModel(model) end
end

function GAMEMODE:PlayerDeathSound()
    return true
end

function GAMEMODE:PlayerDeath(ply,wep,kil)
    ply.nextspawn = CurTime() + 0.8
    ply.CheckCleanup = false
end


function GAMEMODE:PlayerDeathThink(ply)
    if ply.nextspawn and CurTime() < ply.nextspawn then return end
    if wyodr.GetRoundState() == ROUND_POST then return end
    if ply.CheckCleanup then return end
    
    if #team.GetPlayers(TEAM_DEATH) < 1 then
        local elapsed_roundtime = CurTime() - GetGlobalFloat("roundstart")
        if elapsed_roundtime > 60 then
            wyodr.Notify("Clearing map to clear all anti-AFK mechanisms etc..")
            SetGlobalFloat("roundstart", CurTime())
            timer.Simple(2, function() game.CleanUpMap()  end)
            ply.CheckCleanup = true
            ply:Spawn()
            --game.CleanUpMap()
            -- todo check if time > 2 min or something and cleanp map
        else
            ply:Spawn()
        end
    end
    
	if ply:GetObserverMode() == OBS_MODE_NONE and #team.GetPlayers(TEAM_DEATH) >= 1 then
		ply:Spectate(OBS_MODE_ROAMING)
	end
end

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

hook.Add("KeyPress", "2Swag", function(ply, key)
    if ply:Alive() and key == IN_ATTACK then
        local tr = ply:GetEyeTrace()
        if IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:EyePos():Distance(ply:EyePos()) < 127 then
        --    tr.Entity:SetVelocity(ply:GetAimVector() * 200)   
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
	if target:IsPlayer() and attacker:IsPlayer() and target:Team() == attacker:Team() and not (target:IsSuperAdmin() and attacker:IsSuperAdmin()) then
		dmginfo:SetDamage(0)
	end
end)                                    


function GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)
	if listener:GetDeafMode() then return false end -- If deafmode, dont transmit any voices
end

