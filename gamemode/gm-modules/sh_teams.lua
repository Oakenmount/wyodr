team.SetUp(TEAM_RUNNER,"Runners",Color(192, 57, 43))
team.SetUp(TEAM_DEATH,"Death",Color(52, 73, 94))
team.SetUp(TEAM_SPECTATOR,"Spectator",Color(243, 156, 18))
team.SetSpawnPoint( TEAM_DEATH, "info_player_terrorist" )
team.SetSpawnPoint( TEAM_RUNNER, "info_player_counterterrorist" )

--[[
hook.Add("PlayerSelectSpawn","selectleepikspawn",function( pl )
    
    if pl:Team() == TEAM_RUNNER then
            local spawns = ents.FindByClass( "info_player_counterterrorist" )
            local random_entry = math.random(#spawns)
 
            return spawns[random_entry]
    end
    if pl:Team() == TEAM_DEATH then
            local spawns = ents.FindByClass( "info_player_terrorist" )
            local random_entry = math.random(#spawns)
 
            return spawns[random_entry]
    end             
 
end)
]]