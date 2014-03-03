local mappings = {
	["weapon_mp5navy"] = "bb_mp5_alt",
	["weapon_hegrenade"] = "bb_cssfrag_alt",
	["weapon_smokegrenade"] = "bb_css_smoke_alt",
	["weapon_knife"] = "bb_css_knife_alt",
}

for _,v in pairs({"ak47", "aug", "awp", "famas", "g3sg1", "galil", "m249", "m3", "m4a1", "mac10",
				  "mp5", "scout", "sg550", "sg552", "tmp", "ump45", "xm1014", "deagle", "dualelites",
				  "fiveseven", "glock", "p228", "usp", "p90"}) do
	mappings["weapon_" .. v] = "bb_" .. v .. "_alt"
end

do
	local ENT = {}

	ENT.Type = "anim"
	ENT.Model = "models/weapons/w_smg_p90.mdl"
	
	function ENT:Initialize()
		if SERVER then
			self:SetModel(self.Model)
			self:PhysicsInit(SOLID_BBOX)
			self:SetSolid(SOLID_BBOX)
			if not wyodr.CleaningMap then
				local phys = self:GetPhysicsObject()
				if phys:IsValid() then phys:Wake() end
			else
				self:SetMoveType(MOVETYPE_NONE)
			end
			
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		end
	end
	
	function ENT:Use(ply)
		if not ply:CanPickupWepClass(self.WepClass) then return end
		ply:Give(self.WepClass)
		ply:SelectWeapon(self.WepClass)
		self:Remove()
	end
	
	scripted_ents.Register(ENT, "weapon_jbdummy2")
end

-- Make dummy entities
for cssname,gmname in pairs(mappings) do
	local modelwep = weapons.Get(gmname:sub(1, -5))
	if not modelwep then MsgN("NO MODELWEP FOR ", gmname) continue end
	
	local SWEP = {}
	SWEP.Base = "weapon_jbdummy2"
    SWEP.Model = modelwep.WorldModel
    SWEP.WepClass = gmname
    scripted_ents.Register(SWEP, cssname)
	--MsgN("Registered SWEP for ", cssname, " using", SWEP.Model)
end

if wyodr.CleaningMap == nil then wyodr.CleaningMap = true end
hook.Add("InitPostEntity", "FixCleanMapFreeze", function()
	wyodr.CleaningMap = false
end)