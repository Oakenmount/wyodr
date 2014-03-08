local SWEP = {}

SWEP.HoldType                   = "slam"
 
SWEP.Base = "weapon_base"

SWEP.Slot = 0
SWEP.SlotPos = 1	
 
SWEP.PrintName                       = "Jihad bomb"


SWEP.ViewModel  = Model("models/weapons/v_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.DrawCrosshair      = false
SWEP.ViewModelFlip      = false

SWEP.Primary = {}
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 5.0

SWEP.Secondary = {}
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo     = "none"

SWEP.NoSights = true

util.PrecacheSound("jihad/allahuakbar.wav")


----------------------
--  Weapon its self --
----------------------


function SWEP:SparkySparky()
	local effectdata = EffectData()
	if IsValid(effectdata) then
		effectdata:SetOrigin( self.Owner:GetPos() )
		effectdata:SetNormal( self.Owner:GetPos() )
		effectdata:SetMagnitude( 6 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 16 )
		util.Effect( "Sparks", effectdata )
	end
end

-- PrimaryAttack
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 3)
	
	self.BaseClass.ShootEffects( self )
	
	local AsplodeTime = 2.4
	local Sparks = math.floor(AsplodeTime / 0.6)
	
	self:SparkySparky()
	
	timer.Create( "JihadSparker" .. tostring(self:EntIndex()), 0.6, (Sparks-1), function()
		if IsValid(self) then
			self:SparkySparky()
		end
	end )
	
	-- The rest is only done on the server
	if (SERVER) then
		self.LastOwner = self.Owner
	
		timer.Simple(AsplodeTime + 0.1, function() self:Asplode() end )
			self.LastOwner:EmitSound( "jihad/allahuakbar.wav",400 )
	end

end

-- The asplode function
function SWEP:Asplode()
--local k, v
	
	if self.Owner and self.Owner ~= NULL and self.LastOwner == self.Owner then
	
		-- Make an explosion at your position
		local ent = ents.Create( "env_explosion" )
		ent:SetPos( self.Owner:GetPos() )
		ent:SetOwner( self.Owner )
		ent:Spawn()
		ent:SetKeyValue( "iMagnitude", "150" )
		ent:SetKeyValue("iRadiusOverride", "700")
		ent:Fire( "Explode", 0, 0 )
		local vPoint = self.Owner:GetPos()
			local effectdata = EffectData()
			effectdata:SetStart( vPoint ) // not sure if we need a start and origin (endpoint) for this effect, but whatever
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 5 )
			util.Effect( "HelicopterMegaBomb", effectdata )
		self.Owner:EmitSound( "siege/big_explosion.wav") 
		self.Owner:Ignite()
		local muslim = self.Owner
		self.Owner:IncrAchStat("allahuakbar", 1)
		self.Owner:Kill( )
		if IsValid(muslim:GetRagdollEntity()) then
			muslim:GetRagdollEntity():Ignite(10,10)
			timer.Simple(10,function()
				if IsValid(muslim:GetRagdollEntity()) then
					muslim:GetRagdollEntity():SetModel("models/Humans/Charple02.mdl")
				end
			end)
		end
		self:Remove()
	
	else
	
	end

end

-- SecondaryAttack
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + 1 )
	-- old taunt vo/npc/male01/overhere01.wav
	local TauntSound = Sound( "hostage/hunuse/comeback.wav" )
	self.Weapon:EmitSound( TauntSound )
	
	-- The rest is only done on the server
	if (!SERVER) then return end
	self.Weapon:EmitSound( TauntSound )
end

-- Bewm
function SWEP:WorldBoom()
	surface.EmitSound( "siege/big_explosion.wav" )
end

weapons.Register(SWEP, "weapon_jb_jihad", true)