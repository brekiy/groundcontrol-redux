AddCSLuaFile()

-- maybe in the future i'll decompile this and remove the scope from the model
-- 0    lo_Circle0
-- 1    lo_body002
-- 2    Object001
-- 3    Object002
-- 4    Object003
-- 5    Object004
-- 6    Object005
-- 7    Object006
-- 63    Object007

CustomizableWeaponry:registerAmmo(".338 Lapua", ".338 Lapua", 8.58, 69.20)

if CLIENT then
    SWEP.DrawCrosshair = false
    SWEP.PrintName = "L115"
    SWEP.CSMuzzleFlashes = true
    SWEP.ViewModelMovementScale = 1.15

    SWEP.IconLetter = "r"
    killicon.AddFont("cw_l115", "CW_KillIcons", SWEP.IconLetter, Color(255, 80, 0, 150))

    SWEP.ZoomTextures = {{tex = surface.GetTextureID("sprites/scope_leo"), offset = {0, 1}}}
    SWEP.SimpleTelescopicsFOV = 75

    SWEP.MuzzleEffect = "muzzleflash_SR25"
    SWEP.PosBasedMuz = false
    SWEP.SnapToGrip = true
    SWEP.ShellScale = 0.7
    SWEP.ShellOffsetMul = 1
    SWEP.ShellDelay = 0.7
    SWEP.ShellPosOffset = {x = 0, y = -2, z = 0}
    SWEP.ForeGripOffsetCycle_Draw = 0
    SWEP.ForeGripOffsetCycle_Reload = 0.9
    SWEP.ForeGripOffsetCycle_Reload_Empty = 0.8
    SWEP.FireMoveMod = 0.6
    SWEP.OverrideAimMouseSens = 0.2

    SWEP.DrawTraditionalWorldModel = false
    SWEP.WM = "models/weapons/w_cstm_l96.mdl"
    SWEP.WMPos = Vector(-1, 0, 1.75)
    SWEP.WMAng = Vector(0, 0, 180)

    SWEP.IronsightPos = Vector(-2.678, -1, 0.15)
    SWEP.IronsightAng = Vector(0, 0, 0)

    SWEP.FoldSightPos = Vector(-2.208, -4.3, 0.143)
    SWEP.FoldSightAng = Vector(0.605, 0, -0.217)

    SWEP.EoTechPos = Vector(-2.21, -4.686, 0.239)
    SWEP.EoTechAng = Vector(0, 0, -0.217)

    SWEP.AimpointPos = Vector(-2.194, -4.686, 0.338)
    SWEP.AimpointAng = Vector(-1.951, 0, -0.217)

    SWEP.MicroT1Pos = Vector(-2.208, 1, 0.83)
    SWEP.MicroT1Ang = Vector(-1.938, 0, -0.217)

    SWEP.ACOGPos = Vector(-2.211, -4, 0.146)
    SWEP.ACOGAng = Vector(-1.4, 0, 0)

    SWEP.ShortDotPos = Vector(-2.201, -4.148, 0.425)
    SWEP.ShortDotAng = Vector(0, 0, 0)

    SWEP.SprintPos = Vector(1.786, 0, -1)
    SWEP.SprintAng = Vector(-10.778, 27.573, 0)

    SWEP.AlternativePos = Vector(0.2, 0, -1)
    SWEP.AlternativeAng = Vector(0, 0, 0)

    SWEP.AimBreathingEnabled = true
    SWEP.CrosshairEnabled = false
    SWEP.AimViewModelFOV = 40

    SWEP.HipFireFOVIncrease = false

    SWEP.LuaVMRecoilAxisMod = {vert = 0.5, hor = 1, roll = 1, forward = 0.5, pitch = 0.5}
    SWEP.RTAlign = {right = 1.2, up = 0.25, forward = 0}

    SWEP.AttachmentModelsVM = {
        ["md_aimpoint"] = {model = "models/wystan/attachments/aimpoint.mdl", bone = "lo_body002",  pos = Vector(-0.281, -4.3, -2.086), adjustment = {min = -4.3, max = -2.8, axis = "y", inverseOffsetCalc = true}, angle = Angle(0, 0, 0), size = Vector(1, 1, 1)},
        ["md_eotech"] = {model = "models/wystan/attachments/2otech557sight.mdl", bone = "lo_body002", pos = Vector(0.238, -9.2, -7.223), adjustment = {min = -9.2, max = -7.6, axis = "y", inverseOffsetCalc = true}, angle = Angle(0, -90, 0), size = Vector(1, 1, 1)},
        ["md_saker"] = {model = "models/cw2/attachments/556suppressor.mdl", bone = "lo_body002", pos = Vector(0, 4.4, -1.5), angle = Angle(0, 0, 0), size = Vector(1, 1, 1)},
        ["md_microt1"] = {model = "models/cw2/attachments/microt1.mdl", bone = "lo_body002", pos = Vector(-0.027, 1.25, 2.634), adjustment = {min = 1.25, max = 3.6, axis = "y", inverseOffsetCalc = true}, angle = Angle(0, 180, 0), size = Vector(0.4, 0.4, 0.4)},
        ["md_acog"] = {model = "models/wystan/attachments/2cog.mdl", bone = "lo_body002", pos = Vector(-0.401, -3.291, -2.22), angle = Angle(0, 0, 0), size = Vector(1, 1, 1)},
        ["md_schmidt_shortdot"] = {model = "models/cw2/attachments/schmidt.mdl", bone = "lo_body002", pos = Vector(-0.35, -2.554, -1.627), angle = Angle(0, -90, 0), size = Vector(0.899, 0.899, 0.899)}
    }
end

SWEP.MuzzleVelocity = 936 -- in meter/s

-- SWEP.Attachments = {[1] = {header = "Sight", offset = {800, -500}, atts = {"bg_foldsight", "md_microt1", "md_eotech", "md_aimpoint", "md_schmidt_shortdot", "md_acog"}},
--     [2] = {header = "Barrel", offset = {300, -500}, atts = {"md_saker"}},
--     ["+reload"] = {header = "Ammo", offset = {800, 0}, atts = {"am_magnum", "am_matchgrade"}}}

SWEP.Attachments = {
    [1] = {header = "Barrel", offset = {300, -500}, atts = {"md_saker"}},
    ["+reload"] = {header = "Ammo", offset = {800, 0}, atts = {"am_magnum", "am_matchgrade"}}}

SWEP.SightBGs = {main = 2, foldsight = 1, none = 0}
SWEP.ADSFireAnim = true
SWEP.PreventQuickScoping = true
SWEP.QuickScopeSpreadIncrease = 0.2

SWEP.Animations = {fire = {"shot"},
    reload = "reload",
    idle = "idle",
    draw = "draw"}

SWEP.Sounds = {shot = {{time = 0.5, sound = "CW_L96_BOLTUP"},
        {time = 0.7, sound = "CW_L96_BOLTPULL"},
        {time = 1, sound = "CW_L96_BOLTPUSH"},
        {time = 1.35, sound = "CW_L96_BOLTDOWN"}},

    draw = {{time = 0, sound = "CW_FOLEY_MEDIUM"}},

    reload = {{time = 0.17, sound = "CW_L96_BOLTUP"},
        {time = 0.29, sound = "CW_L96_BOLTPULL"},

    {time = 1.1, sound = "CW_L96_MAGOUT"},
    {time = 1.47, sound = "CW_FOLEY_LIGHT"},
    {time = 2, sound = "CW_L96_MAGIN"},
    {time = 2.86, sound = "CW_L96_BOLTPUSH"},
    {time = 3.15, sound = "CW_L96_BOLTDOWN"},
    {time = 3.3, sound = "CW_FOLEY_LIGHT"}}
}

SWEP.SpeedDec = 50

SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.NormalHoldType = "ar2"
SWEP.RunHoldType = "passive"
SWEP.FireModes = {"bolt"}
SWEP.Base = "cw_base"
SWEP.Category = "CW 2.0"

SWEP.Author            = "brekiy"
SWEP.Contact        = ""
SWEP.Purpose        = ""
SWEP.Instructions    = ""

SWEP.ViewModelFOV    = 70
SWEP.ViewModelFlip    = false
SWEP.ViewModel        = "models/cw2/rifles/l96.mdl"
SWEP.WorldModel        = "models/weapons/w_cstm_l96.mdl"

SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true

SWEP.Primary.ClipSize        = 5
SWEP.Primary.DefaultClip    = 5
SWEP.Primary.Automatic        = false
SWEP.Primary.Ammo            = ".338 Lapua"

SWEP.FireDelay = 1.5
SWEP.FireSound = "CW_L96_FIRE"
SWEP.FireSoundSuppressed = "CW_AR15_FIRE_SUPPRESSED"
SWEP.Recoil = 2.5

SWEP.HipSpread = 0.075
SWEP.AimSpread = 0.001
SWEP.VelocitySensitivity = 2.5
SWEP.MaxSpreadInc = 0.2
SWEP.SpreadPerShot = 0.01
SWEP.SpreadCooldown = 1.55
SWEP.Shots = 1
SWEP.Damage = 90
SWEP.DeployTime = 1

SWEP.ReloadSpeed = 1
SWEP.ReloadTime = 2.42
SWEP.ReloadTime_Empty = 2.42
SWEP.ReloadHalt = 3.48
SWEP.ReloadHalt_Empty = 3.48

if CLIENT then
    local old, x, y, ang
    local reticle = surface.GetTextureID("sprites/scope_leo")

    local lens = surface.GetTextureID("cw2/gui/lense")
    local lensMat = Material("cw2/gui/lense")
    local cd, alpha = {}, 0.5
    local Ini = true

    -- render target var setup
    cd.x = 0
    cd.y = 0
    cd.w = 512
    cd.h = 512
    cd.fov = 3
    cd.drawviewmodel = false
    cd.drawhud = false
    cd.dopostprocess = false

    function SWEP:RenderTargetFunc()
        local complexTelescopics = self:canUseComplexTelescopics()

        -- if we don't have complex telescopics enabled, don't do anything complex, and just set the texture of the lens to a fallback 'lens' texture
        if !complexTelescopics then
            self.TSGlass:SetTexture("$basetexture", lensMat:GetTexture("$basetexture"))
            return
        end

        if self.dt.State == CW_AIMING then
            alpha = math.Approach(alpha, 0, FrameTime() * 5)
        else
            alpha = math.Approach(alpha, 1, FrameTime() * 5)
        end

        x, y = ScrW(), ScrH()
        old = render.GetRenderTarget()

        ang = self:getTelescopeAngles()

        if self.ViewModelFlip then
            ang.r = -self.BlendAng.z
        else
            ang.r = self.BlendAng.z
        end

        if !self.freeAimOn then
            ang:RotateAroundAxis(ang:Right(), self.RTAlign.right)
            ang:RotateAroundAxis(ang:Up(), self.RTAlign.up)
            ang:RotateAroundAxis(ang:Forward(), self.RTAlign.forward)
        end

        local size = self:getRenderTargetSize()

        cd.w = size
        cd.h = size
        cd.angles = ang
        cd.origin = self:GetOwner():GetShootPos()
        render.SetRenderTarget(self.ScopeRT)
        render.SetViewPort(0, 0, size, size)
            if alpha < 1 or Ini then
                render.RenderView(cd)
                Ini = false
            end

            ang = self:GetOwner():EyeAngles()
            ang.p = ang.p + self.BlendAng.x
            ang.y = ang.y + self.BlendAng.y
            ang.r = ang.r + self.BlendAng.z
            ang = -ang:Forward()

            local light = render.ComputeLighting(self:GetOwner():GetShootPos(), ang)

            cam.Start2D()
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetTexture(reticle)
                surface.DrawTexturedRect(0, 0, size, size)

                surface.SetDrawColor(150 * light[1], 150 * light[2], 150 * light[3], 255 * alpha)
                surface.SetTexture(lens)
                surface.DrawTexturedRectRotated(size * 0.5, size * 0.5, size, size, 90)
            cam.End2D()
        render.SetViewPort(0, 0, x, y)
        render.SetRenderTarget(old)

        if self.TSGlass then
            self.TSGlass:SetTexture("$basetexture", self.ScopeRT)
        end
    end
end
