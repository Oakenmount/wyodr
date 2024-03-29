hook.Add("PlayerCanPickupWeapon","PlayerCanPickupWeapon",function(ply, wep)
	return true
	--return ply:CanPickupWepClass(wep:GetClass()) or wep:GetClass() == "weapon_physgun"
end)

concommand.Add("dr_dropweapon", function(ply)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() ~= "weapon_jb_fists" then
		ply:DropWeapon(wep)
		hook.Call("JBPlayerDroppedWeapon", GAMEMODE, ply, wep)
	end
end)

hook.Add("Think", "ZeroAmmoGrenadeFix", function()
	local grenades = {}
	table.Add(grenades, ents.FindByClass("bb_cssfrag_alt"))
	table.Add(grenades, ents.FindByClass("bb_css_smoke_alt"))
	for _,gren in pairs(grenades) do
		if gren:Clip1() == 0 then
			gren:Remove()
		end	
	end
end)

-- Some maps strip fists, this gives them back
hook.Add("EntityRemoved", "GiveBackFists", function(ent)
	if ent:GetClass() == "weapon_crowbar" then
		local owner = ent:GetOwner()
		timer.Simple(0.1, function()
			if IsValid(owner) and owner:Alive() and owner:Team() ~= TEAM_SPECTATOR then 
			    owner:Give("weapon_knife")	
			end
		end)
	end
end)

hook.Add("DoPlayerDeath","HOOBESCANTCODEDIS",function(ply,inflic,killer)
	for k,v in pairs(ply:GetWeapons()) do
		if v:GetClass() ~= "weapon_jb_fists" and v:GetClass() ~= "weapon_jb_clicker" then
			ply:DropWeapon(v)
		end
	end
end)

hook.Add("AllowPlayerPickup","AllowPlayerPickup",function( player, entity)
    return true
end)