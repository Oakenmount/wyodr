
local default_round_lengths = {
	[ROUND_WAIT] = 10,
	[ROUND_ACTIVE] = 60 * 6,
	[ROUND_POST] = 10	
}

local round_stuff = {
	[ROUND_WAIT] = function()
		wyodr.CleaningMap = true
		game.CleanUpMap()
		wyodr.CleaningMap = false
		for _,ply in pairs(player.GetAll()) do
			if ply:IsActivePlayer() then
				ply:Spawn()
			end
		end
	end,
	[ROUND_ACTIVE] = function()
		for _,ply in pairs(player.GetAll()) do
			if ply:IsActivePlayer() and not ply:Alive() then
				ply:Spawn()
			end
		end
	end
}

wyodr.SetRoundState = function(state)
	MsgN("Round state changing to ", state)
	SetGlobalFloat("roundstart", CurTime())
	SetGlobalFloat("roundend", CurTime() + default_round_lengths[state])
	local rstuff = round_stuff[state]
	if rstuff then
		local stat, err = pcall(rstuff)
		if not stat then
			MsgN("Errors and stuff: ", err)	
		end
	end
	
	return SetGlobalInt("roundstate", state)
end

wyodr.ExtendRoundBy = function(seconds)
	SetGlobalFloat("roundend", GetGlobalFloat("roundend") + seconds)
end


timer.Create("roundlogic", 1, 0, function()
	local state = wyodr.GetRoundState()
	local expired = GetGlobalFloat("roundend") < CurTime()
	if expired then
		if state == ROUND_WAIT then
			local guards, prisoners = team.GetPlayers(TEAM_DEATH), team.GetPlayers(TEAM_RUNNER)
			if #guards > 0 and #prisoners > 0 then
				wyodr.SetRoundState(ROUND_ACTIVE)
				hook.Call("RoundStart",GAMEMODE)
				BroadcastLua([[hook.Call("RoundStart",GAMEMODE)]])
			end
		elseif state == ROUND_ACTIVE then
			wyodr.SetRoundState(ROUND_POST)
			hook.Call("RoundEnd",GAMEMODE,nil)
			BroadcastLua([[hook.Call("RoundEnd",GAMEMODE,nil)]])
		elseif state == ROUND_POST then
			wyodr.SetRoundState(ROUND_WAIT)
			hook.Call("RoundPreparing",GAMEMODE)
		end	
	end
	
	if state == ROUND_ACTIVE then
		local guards, prisoners = team.GetPlayers(TEAM_DEATH) , team.GetPlayers(TEAM_RUNNER)
		local guard_count, pri_count = #guards, #prisoners
		table.foreach(guards, function(k,v) if not v:Alive() or  v:GetMoonMode() then guard_count = guard_count-1 end end) 	
		table.foreach(prisoners, function(k,v) if not v:Alive() or v:GetMoonMode() then pri_count = pri_count-1 end end) 
		local enough_players = (#guards+#prisoners > 1) or (guard_count == 0 and pri_count == 0) -- >1 players or both teams empty
		if (guard_count == 0) and enough_players then
			wyodr.SetRoundState(ROUND_POST)
			hook.Call("RoundEnd",GAMEMODE,TEAM_RUNNER)
			BroadcastLua([[hook.Call("RoundEnd",GAMEMODE,nil)]])
			SetGlobalBool("WardenActive",false)
			wyodr.Notify("Runners win!")
		elseif (pri_count == 0) and enough_players then
			wyodr.SetRoundState(ROUND_POST)
			hook.Call("RoundEnd",GAMEMODE,TEAM_DEATH)
			BroadcastLua([[hook.Call("RoundEnd",GAMEMODE,nil)]])
			wyodr.Notify("Deaths win!")
		end
	end
end)