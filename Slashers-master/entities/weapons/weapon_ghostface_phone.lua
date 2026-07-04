-- Utopia Games - Slashers
-- Ghostface Phone SWEP
-- A static-prop phone weapon attached to the right hand via VElements/WElements.
-- No rigged viewmodel — the base models are hidden (alpha 0) and the phone
-- prop is rendered in-place through TFA's bone-attachment system.

-- ─────────────────────────────────────────────────────────────────────────────
-- TFA base safe-stubs (prevents nil-value crashes if base methods are absent)
-- ─────────────────────────────────────────────────────────────────────────────
if not SWEP.GetHolstering     then SWEP.GetHolstering     = function(self) return self._bHolstering     or false end end
if not SWEP.GetDrawing        then SWEP.GetDrawing        = function(self) return self._bDrawing         or false end end
if not SWEP.GetReloading      then SWEP.GetReloading      = function(self) return self._bReloading       or false end end
if not SWEP.GetBashing        then SWEP.GetBashing        = function(self) return self._bBashing         or false end end
if not SWEP.GetShooting       then SWEP.GetShooting       = function(self) return self._bShooting        or false end end
if not SWEP.GetSprinting      then SWEP.GetSprinting      = function(self) return self._bSprinting       or false end end
if not SWEP.GetInspecting     then SWEP.GetInspecting     = function(self) return self._bInspecting      or false end end
if not SWEP.GetIronSights     then SWEP.GetIronSights     = function(self) return self._bIronSights      or false end end
if not SWEP.GetRunSightsRatio then SWEP.GetRunSightsRatio = function(self) return self._nRunSightsRatio  or 0     end end
if not SWEP.GetNearWallRatio  then SWEP.GetNearWallRatio  = function(self) return self._nNearWallRatio   or 0     end end
if not SWEP.SetShooting       then SWEP.SetShooting       = function(self, v) self._bShooting    = v end end
if not SWEP.SetShootingEnd    then SWEP.SetShootingEnd    = function(self, v) self._bShootingEnd = v end end
if not SWEP.SetHolstering     then SWEP.SetHolstering     = function(self, v) self._bHolstering  = v end end
if not SWEP.SetHolsteringEnd  then SWEP.SetHolsteringEnd  = function(self, v) self._bHolsteringEnd = v end end
if not SWEP.SetInspecting     then SWEP.SetInspecting     = function(self, v) self._bInspecting  = v end end
if not SWEP.GetChangingSilence then SWEP.GetChangingSilence = function(self) return false end end
if not SWEP.SetChangingSilence then SWEP.SetChangingSilence = function(self, v) end end

-- ─────────────────────────────────────────────────────────────────────────────
-- SWEP Definition
-- ─────────────────────────────────────────────────────────────────────────────
SWEP.Base             = "tfa_nmrimelee_base"
SWEP.Category         = "TFA NMRIH"
SWEP.Spawnable        = false
SWEP.AdminSpawnable   = true

SWEP.PrintName        = "Phone"
SWEP.Author           = "Slashers Dev"

-- Generic fallback models — hidden at runtime via alpha/DrawWorldModel suppression.
-- The phone prop is rendered entirely through VElements / WElements below.
SWEP.ViewModel        = "models/weapons/v_stunbaton.mdl"
SWEP.ViewModelFOV     = 50
SWEP.WorldModel       = "models/weapons/w_stunbaton.mdl"

SWEP.HoldType         = "slam"
SWEP.DefaultHoldType  = "slam"

SWEP.ShowViewModel    = false
SWEP.ShowWorldModel   = false

-- World model offset (applies to the hidden fallback — safe to leave at defaults)
SWEP.Offset = {
	Pos = { Up = -0.5, Right = 2, Forward = 5.5 },
	Ang = { Up = -1,   Right = 5, Forward = 178  },
	Scale = 1.0
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Combat stats (non-damaging prop — adjust as needed)
-- ─────────────────────────────────────────────────────────────────────────────
SWEP.Primary.Sound      = Sound("Weapon_Melee.CrowbarLight")
SWEP.Secondary.Sound    = Sound("Weapon_Melee.CrowbarLight")

SWEP.MoveSpeed          = 1.0
SWEP.IronSightsMoveSpeed = SWEP.MoveSpeed

SWEP.InspectPos = Vector(0, 0, 0)
SWEP.InspectAng = Vector(0, 0, 0)

-- TFA spread safety (prevents nil crashes on hot-reload)
SWEP.FireModes                   = { "Single" }
SWEP.Primary.SpreadRecovery      = 0
SWEP.Primary.SpreadMultiplierMax = 1
SWEP.Primary.SpreadIncrement     = 1
SWEP.Primary.Spread              = 0.01
SWEP.Primary.Accuracy            = 0.01

SWEP.Primary.Reach      = 40
SWEP.Primary.RPM        = 60
SWEP.Primary.Damage     = 0      -- Non-damaging; just cosmetic / ability trigger
SWEP.Primary.SoundDelay = 0
SWEP.Primary.Delay      = 0.5
SWEP.Primary.Window     = 0.2
SWEP.Primary.Automatic  = false
SWEP.Primary.Blunt      = true

SWEP.Secondary.Reach      = 40
SWEP.Secondary.RPM        = 60
SWEP.Secondary.Damage     = 0
SWEP.Secondary.SoundDelay = 0
SWEP.Secondary.Delay      = 0.5
SWEP.Secondary.Blunt      = true

SWEP.Secondary.BashDamage = 0
SWEP.Secondary.BashDelay  = 0.3
SWEP.Secondary.BashLength = 40

SWEP.AllowViewAttachment  = false

-- ─────────────────────────────────────────────────────────────────────────────
-- VElements — phone prop rendered in first-person on the right hand bone
-- All offsets are zeroed for easy in-game tweaking via the TFA bone editor.
-- ─────────────────────────────────────────────────────────────────────────────
SWEP.VElements = {
	["base"] = {
		type          = "Model",
		model         = SWEP.ViewModel,
		bone          = "ValveBiped.Bip01_R_Hand",
		rel           = "",
		pos           = Vector(0, 0, 0),
		angle         = Angle(0, 0, 0),
		size          = Vector(1, 1, 1),
		color         = Color(255, 255, 255, 0),  -- invisible fallback
		surpresslights = true,
		material      = "",
		skin          = 0,
		bonemerge     = false,
		active        = false
	},
	["phone"] = {
		type          = "Model",
		model         = "models/weapons/slashers_phone.mdl",
		bone          = "ValveBiped.Bip01_R_Hand",
		rel           = "",
		pos           = Vector(0, 0, 0),   -- tweak in-game to fit the hand
		angle         = Angle(0, 0, 0),   -- tweak in-game to fit the hand
		size          = Vector(1, 1, 1),
		color         = Color(255, 255, 255, 255),
		surpresslights = true,
		material      = "",
		skin          = 0,
		bonemerge     = false,
		active        = true
	}
}

-- ─────────────────────────────────────────────────────────────────────────────
-- WElements — phone prop rendered on the third-person world model
-- ─────────────────────────────────────────────────────────────────────────────
SWEP.WElements = {
	["base"] = {
		type          = "Model",
		model         = SWEP.WorldModel,
		bone          = "ValveBiped.Bip01_R_Hand",
		rel           = "",
		pos           = Vector(0, 0, 0),
		angle         = Angle(0, 0, 0),
		size          = Vector(1, 1, 1),
		color         = Color(255, 255, 255, 0),  -- invisible fallback
		surpresslights = true,
		material      = "",
		skin          = 0,
		bonemerge     = false,
		active        = false
	},
	["phone"] = {
		type          = "Model",
		model         = "models/weapons/slashers_phone.mdl",
		bone          = "ValveBiped.Bip01_R_Hand",
		rel           = "",
		pos           = Vector(0, 0, 0),   -- tweak in-game to fit the hand
		angle         = Angle(0, 0, 0),   -- tweak in-game to fit the hand
		size          = Vector(1, 1, 1),
		color         = Color(255, 255, 255, 255),
		surpresslights = true,
		material      = "",
		skin          = 0,
		bonemerge     = false,
		active        = true
	}
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Functions
-- ─────────────────────────────────────────────────────────────────────────────

-- PrimaryAttack: test ring for development purposes.
-- Replace the body with the real ability trigger when ready.
function SWEP:PrimaryAttack()
	if not IsValid(self) or not IsValid(self.Owner) then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if SERVER then
		self.Owner:EmitSound("buttons/button14.wav", 75, 100, 1.0)
		self.Owner:ChatPrint("Ring ring!")
	end
end

function SWEP:SecondaryAttack()
	self:AltAttack()
end

function SWEP:Reload()
	-- intentionally empty
end

function SWEP:PrimarySlash()
	-- intentionally empty
end

function SWEP:Holster()
	return true
end

-- Hide the fallback base viewmodel on the client side.
if CLIENT then
	local _base_Init = SWEP.Initialize
	function SWEP:Initialize()
		if _base_Init then _base_Init(self) end
		timer.Simple(0, function()
			if not IsValid(self) then return end
			local vm = self.Owner and self.Owner:GetViewModel()
			if IsValid(vm) then
				vm:SetColor(Color(255, 255, 255, 0))
			end
		end)
	end

	-- Suppress the fallback world model — WElements handle prop rendering.
	function SWEP:DrawWorldModel()
		-- Intentionally empty
	end
end
