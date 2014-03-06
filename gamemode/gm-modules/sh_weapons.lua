
local WeaponTable = {
	primary = {
	"weapon_ak47",
	"weapon_aug",
	"weapon_awp",
	"bb_famas_alt",
	"bb_g3sg1_alt",
	"bb_galil_alt",
	"bb_m249_alt",
	"bb_m3_alt",
	"bb_m4a1_alt",
	"bb_mac10_alt",
	"bb_mp5_alt",
	"bb_scout_alt",
	"bb_sg550_alt",
	"bb_sg552_alt",
	"bb_tmp_alt",
	"bb_ump45_alt",
	"bb_xm1014_alt",
	"bb_p90_alt"
	},
	secondary = {
	"bb_deagle_alt",
	"bb_dualelites_alt",
	"bb_fiveseven_alt",
	"bb_glock_alt",
	"bb_p228_alt",
	"bb_usp_alt"
	},
	melee = {
	"bb_css_knife_alt"
	},
	throw = {
	"bb_cssfrag_alt",
	"bb_css_smoke_alt"
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
		if wep:GetClass() == "bb_awp_alt" then
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

