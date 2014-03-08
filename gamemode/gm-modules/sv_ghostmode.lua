hook.Add("PlayerDeath", "GhostMode", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) and not ply:Alive() and ply:IsSuperAdmin() then
            ply:Spawn()
            ply:SetMaterial("models/props_c17/frostedglass_01a")
        end
    end)
end)