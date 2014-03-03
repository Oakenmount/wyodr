hook.Add("HUDPaint", "swag", function()
    draw.SimpleText(tostring(wyodr.GetRoundState()), "DermaLarge", 100, 100)  
        
    local roundProgress = (CurTime() - GetGlobalFloat("roundstart"))
    local roundEnd = (GetGlobalFloat("roundend") - CurTime())
        
    draw.SimpleText(string.ToMinutesSeconds(math.Round(roundEnd)), "DermaLarge", 100, 130)      
end)

hook.Add("CalcView", "DeathView", function(pl, origin, angles, fov)
    local ragdoll = pl:GetRagdollEntity()
    if( !ragdoll or ragdoll == NULL or !ragdoll:IsValid() ) then return end
      
    local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) )
    
    local view = {
        origin = eyes.Pos,
        angles = eyes.Ang,
		fov = 90, 
    }
    
    
    return view
     
end)
