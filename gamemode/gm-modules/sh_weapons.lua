
local WeaponTable = {
	primary = {
	"weapon_ak47",
	"weapon_aug",
	"weapon_awp",
	"weapon_famas",
	"weapon_g3sg1",
	"weapon_galil",
	"weapon_m249",
	"weapon_m3",
	"weapon_m4a1",
	"weapon_mac10",
	"weapon_mp5",
	"weapon_scout",
	"weapon_sg550",
	"weapon_sg552",
	"weapon_tmp",
	"weapon_ump45",
	"weapon_xm1014",
	"weapon_p90"
	},
	secondary = {
	"weapon_deagle",
	"weapon_dualelites",
	"weapon_fiveseven",
	"weapon_glock",
	"weapon_p228",
	"weapon_usp"
	},
	melee = {
	"weapon_knife"
	},
	throw = {
	"weapon_hegrenade",
	"weapon_smokegrenade"
	}
}

if SERVER then
	hook.Add("ScalePlayerDamage", "BuffWeapons", function(ply, hitgroup, dmginfo)
		local attacker = dmginfo:GetAttacker()
		if not IsValid(attacker) or not attacker:IsPlayer() then return end
		local wep = attacker:GetActiveWeapon()
		if not IsValid(wep) then return end
		
		if table.HasValue(WeaponTable.secondary, wep:GetClass()) and hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(2)
		end
		if wep:GetClass() == "weapon_awp" then
			dmginfo:ScaleDamage(5)	
		end
	end)
end

local plymeta = FindMetaTable("Player")

local function GetWepClassCat(wepcls)
	for cat,classes in pairs(WeaponTable) do
		for _,cls in pairs(classes) do
			if cls == wepcls then return cat end
		end
	end
end

function plymeta:GetWeaponByClass(cls)
	for _,wep in pairs(self:GetWeapons()) do
		if wep:GetClass() == cls then return wep end	
	end
end

function plymeta:GetWeaponOfCat(cat)
	local cat_weapons = WeaponTable[cat]
	if not cat_weapons then return end
	for _,wepcls in pairs(cat_weapons) do
		local wep = self:GetWeaponByClass(wepcls)
		if IsValid(wep) then return wep end
	end
end
function plymeta:HasWeaponOfCat(cat)
	return self:GetWeaponOfCat(cat) ~= nil
end
function plymeta:CanPickupWepClass(cls)
	-- No worries of multiple fists being picked up; they dont spawn in map as ents
	if cls == "weapon_jb_fists" then return true end
	
	local wepcat = GetWepClassCat(cls)
	if not wepcat then return true end -- No weapon category; allow pickup
	
	return not self:HasWeaponOfCat(wepcat) and self:Team() ~= TEAM_SPECTATOR
end

