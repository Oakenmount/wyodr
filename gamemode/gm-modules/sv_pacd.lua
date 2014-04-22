hook.Add("PrePACConfigApply", "donators only", function(ply, outfit_data)
    if not ply:IsSuperAdmin() then return false, "GIBE MONI PLS!" end
end)