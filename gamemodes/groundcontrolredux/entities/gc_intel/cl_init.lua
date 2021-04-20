include("shared.lua")

local baseFont = "CW_HUD72"
ENT.BasicText = "Intel"
-- the distance within which the contents of the box will be displayed
ENT.displayDistance = 128

function ENT:Initialize()
    self:SetParent(nil)
    surface.SetFont(baseFont)
    self.baseHorSize, self.vertFontSize = surface.GetTextSize(self.BasicText)
    self.baseHorSize = self.baseHorSize < 600 and 600 or self.baseHorSize
    self.baseHorSize = self.baseHorSize + 20
    self.halfBaseHorSize = self.baseHorSize * 0.5
    self.halfVertFontSize = self.vertFontSize * 0.5
    self.upOffset = Vector(0, 0, -10)
    self.forwardOffset = Vector(0, -60, 0)
end

function ENT:Think()
    self.inRange = LocalPlayer():GetPos():Distance(self:GetPos()) <= self.displayDistance
end

local white, black = Color(255, 255, 255, 255), Color(0, 0, 0, 255)

function ENT:Draw()
    local plyParent = self:GetParent()
    if plyParent and plyParent:IsPlayer() then
        local bone = plyParent:LookupBone("ValveBiped.Bip01_Spine2")
        if !bone then
            bone = plyParent:LookupBone("ValveBiped.Bip01_Pelvis")
        end
        local pos, ang = ply:GetBonePosition(bone)
        pos = pos - ang:Up() * Vector(0, 0, 10) + ang:Forward() * Vector(-7, -15, 0)
        self:SetRenderOrigin(pos)
        self:SetRenderAngles(ang)
    end
    self:DrawModel()

    -- don't draw the text box if it's too far away or if someone's carrying it
    if !self.inRange or !self:GetDropped() then
        return
    end

    local eyeAng = EyeAngles()
    eyeAng.p = 0
    eyeAng.y = eyeAng.y - 90
    eyeAng.r = 90

    local pos = self:GetPos()
    pos.z = pos.z + 30

    cam.Start3D2D(pos, eyeAng, 0.05)
    local clrs = CustomizableWeaponry.ITEM_PACKS_TOP_COLOR
    surface.SetDrawColor(clrs.r, clrs.g, clrs.b, clrs.a)
    surface.DrawRect(-self.halfBaseHorSize, 0, self.baseHorSize, self.vertFontSize)

    draw.ShadowText(self.BasicText, baseFont, 0, self.halfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:drawHUD()
end
