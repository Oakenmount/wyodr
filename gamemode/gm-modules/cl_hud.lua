local useless_stuff = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}

hook.Add("HUDShouldDraw", "HideEverythingUseless", function(name)
    if GetConVarNumber("cl_hudstyle") == 4 then return end
    if table.HasValue(useless_stuff, name) then return false end
end)

local rstate_colors = {
    [ROUND_WAIT] = Color(149, 165, 166),
    [ROUND_ACTIVE] = Color(155, 89, 182),
    [ROUND_POST] = Color(39, 174, 96)
}

local rstate_names = {
    [ROUND_WAIT] = "Waiting/Preparing",
    [ROUND_ACTIVE] = "Active",
    [ROUND_POST] = "Post-round"
}

hook.Add("HUDPaint", "YouGottaDrawTheHUD", function()
    local rstate = wyodr.GetRoundState()
    
    local roundProgress = (CurTime() - GetGlobalFloat("roundstart"))
    local roundEnd = (GetGlobalFloat("roundend") - CurTime())
        
    local roundfrac = roundProgress / wyodr.RoundLengths[rstate]
    surface.SetDrawColor(rstate_colors[rstate])
    surface.DrawRect(0, 0, ScrW()*roundfrac, 25)
    
    draw.SimpleText(rstate_names[rstate] .. " " .. string.ToMinutesSeconds(math.max(math.Round(roundEnd), 0)), "DermaLarge", 3, -2, Color(255, 255, 255))   
end)

hook.Add("CalcView", "DeathView", function(pl, origin, angles, fov)
    --[[
    
    Noone likes you jacob
    
    local ragdoll = pl:GetRagdollEntity()
    if( !ragdoll or ragdoll == NULL or !ragdoll:IsValid() ) then return end
      
    local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) )
    
    local view = {
        origin = eyes.Pos,
        angles = eyes.Ang,
		fov = 90, 
    }
    
    return view]]
end)
