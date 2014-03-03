
local slotidxmappings = {
	[1] = "fists",
	[2] = "primary",
	[3] = "secondary",
	[4] = "melee",
	[5] = "throw"	
}

local toggle_crouch = CreateConVar("ejb_togglecrouch", "0", FCVAR_ARCHIVE)

hook.Add("PlayerBindPress", "OverridePlayerBinds", function(ply, bind, pressed)
	if bind == "+menu" and pressed then
		RunConsoleCommand("jb_dropweapon")
		return true	
	end
	if bind == "+use" and pressed and (LocalPlayer():Team() == TEAM_SPECTATOR or not LocalPlayer():Alive()) then
		local tr = LocalPlayer():GetEyeTrace()
		if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			net.Start("wyodr_specply")
			net.WriteEntity(tr.Entity)
			net.SendToServer()
		end
		return true	
	end
	local slotidx = tonumber(string.match(bind, "slot(%d)"))
	if slotidx and slotidxmappings[slotidx] then
		local simap = slotidxmappings[slotidx]
		local wepclass
		if simap == "fists" then wepclass = "weapon_jb_fists"
		else
			local wep = ply:GetWeaponOfCat(simap)
			if IsValid(wep) then wepclass = wep:GetClass() end
		end
		if wepclass then RunConsoleCommand("use", wepclass) end
	end
	if bind == "+duck" and toggle_crouch:GetBool() then
		wyodr.CrouchToggle = not wyodr.CrouchToggle
		return true
	end
end)

hook.Add("CreateMove", "ToggleCrouch", function(cmd)
	if toggle_crouch:GetBool() and wyodr.CrouchToggle then
		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_DUCK))	
	end
end)
