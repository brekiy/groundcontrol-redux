include("shared.lua")

local baseFont = "CW_HUD72"
ENT.BasicText = "Intel"
-- the distance within which the contents of the box will be displayed
ENT.displayDistance = 128

function ENT:Initialize()
    self:SetParent(nil)
end

function ENT:Think()
    self.inRange = LocalPlayer():GetPos():Distance(self:GetPos()) <= self.displayDistance
end

local white, black = Color(255, 255, 255, 255), Color(0, 0, 0, 255)
local horizontalBoundary, verticalBoundary = 75, 75
local point = surface.GetTextureID("ground_control/hud/point_of_interest")

-- TODO: figure out the dumb renderorigin stuff
-- function ENT:Draw()
    -- local plyParent = self:GetParent()
    -- if plyParent and plyParent:IsPlayer() then
    --     local bone = plyParent:LookupBone("ValveBiped.Bip01_Spine2")
    --     if !bone then
    --         bone = plyParent:LookupBone("ValveBiped.Bip01_Pelvis")
    --     end
    --     local pos, ang = ply:GetBonePosition(bone)
    --     pos = pos - ang:Up() * Vector(0, 0, 10) + ang:Forward() * Vector(-7, -15, 0)
    --     self:SetRenderOrigin(pos)
    --     self:SetRenderAngles(ang)
    -- end
    -- self:DrawModel()
-- end

function ENT:drawHUD()
    if !self.inRange then return end
    local pos = self:GetPos()

    local text = self:GetDropped() and "Intel" or "Intel carrier"
    local alpha = 1
    alpha = alpha * (0.2 + 0.8 * math.flash(CurTime(), 1))
    local screen = pos:ToScreen()

    screen.x = math.Clamp(screen.x, horizontalBoundary, ScrW() - horizontalBoundary)
    screen.y = math.Clamp(screen.y, verticalBoundary, ScrH() - 200)

    surface.SetTexture(point)
    surface.SetDrawColor(255, 255, 255, 255 * alpha)
    surface.DrawTexturedRect(screen.x - 8, screen.y - 8 - 16, 16, 16)

    white.a = 255 * alpha
    black.a = 255 * alpha

    draw.ShadowText(text, "CW_HUD14", screen.x, screen.y, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
