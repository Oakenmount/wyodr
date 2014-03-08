hook.Add("PlayerDeath", "GhostMode", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) and not ply:Alive() and ply:IsSuperAdmin() then
            --wply:Spawn()
            --ply:SetMaterial("models/props_c17/frostedglass_01a")
            --ply.IsGhost = true
        end
    end)
end)

hook.Add("EntityTakeDamage", "GhostModeSwag", function(ply, dmginfo)
    --if ply.IsGhost then dmginfo:ScaleDamage(0) end
end)