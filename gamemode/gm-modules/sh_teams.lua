TEAM_DEATH = 1
TEAM_RUNNER = 2
TEAM_SPECTATOR = 3

team.SetUp(TEAM_DEATH,"Deaths",Color(192, 57, 43))
team.SetUp(TEAM_RUNNER,"Runners",Color(52, 73, 94))
team.SetUp(TEAM_SPECTATOR,"Spectator",Color(243, 156, 18))

local team_spawns = {
    [TEAM_DEATH] = "info_player_terrorist",
    [TEAM_RUNNER] = "info_player_counterterrorist"
}

hook.Add("PlayerSelectSpawn", "SelectTeamSpawn", function(ply)
    local spawn_ent = team_spawns[ply:Team()] or "info_player*"
    return table.Random(ents.FindByClass(spawn_ent))
end)