team.SetUp(TEAM_RUNNER,"Runners",Color(192, 57, 43))
team.SetUp(TEAM_DEATH,"Death",Color(52, 73, 94))
team.SetUp(TEAM_SPECTATOR,"Spectator",Color(243, 156, 18))

local team_spawns = {
	[TEAM_DEATH] = "info_player_terrorist",
	[TEAM_RUNNER] = "info_player_counterterrorist"
}

hook.Add("PlayerSelectSpawn", "SelectTeamSpawn", function(ply)
	local spawn_ent = team_spawns[ply:Team()] or "info_player*"
	return table.Random(ents.FindByClass(spawn_ent))
end)