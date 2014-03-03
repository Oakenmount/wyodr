
hook.Add("PlayerBindPress", "OverridePlayerBinds", function(ply, bind, pressed)
	if bind == "+use" and pressed and (LocalPlayer():Team() == TEAM_SPECTATOR or not LocalPlayer():Alive()) then
		local tr = LocalPlayer():GetEyeTrace()
		if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			net.Start("wyodr_specply")
			net.WriteEntity(tr.Entity)
			net.SendToServer()
		end
		return true	
	end
end)