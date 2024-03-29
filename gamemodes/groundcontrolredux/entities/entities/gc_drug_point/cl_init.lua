include("shared.lua")

local baseFont = "CW_HUD72"

function ENT:Initialize()
    GAMEMODE:AddObjectiveEntity(self)
    surface.SetFont(baseFont)
    self.baseHorSize, self.vertFontSize = surface.GetTextSize(self.PrintName)
    self.baseHorSize = self.baseHorSize < 600 and 600 or self.baseHorSize
    self.baseHorSize = self.baseHorSize + 20
    self.halfBaseHorSize = self.baseHorSize * 0.5
    self.halfVertFontSize = self.vertFontSize * 0.5
end

-- the distance within which the contents of the box will be displayed
ENT.upOffset = Vector(0, 0, 30)

local white, black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
local horizontalBoundary, verticalBoundary = 75, 75
local point = surface.GetTextureID("ground_control/hud/point_of_interest")

ENT.DeliverText = "Return drugs"

function ENT:Draw()
end

function ENT:drawHUD()
    local ply = LocalPlayer()

    if ply:Team() == GAMEMODE.curGametype.swatTeam then
        return
    end

    local pos = nil

    -- this is a static ent, get it's position once instead of spamming tables per each draw call
    if !self.ownPos then
        self.ownPos = self:GetPos()
        self.ownPos.z = self.ownPos.z + 32
    end

    pos = self.ownPos
    local alpha = 1

    local text = nil

    if ply.hasDrugs and !self:GetHasDrugs() then
        text = self.DeliverText
        alpha = alpha * (0.2 + 0.8 * math.flash(CurTime(), 1.5))
    end

    white.a = 255 * alpha
    black.a = 255 * alpha

    if text then
        local screen = pos:ToScreen()

        screen.x = math.Clamp(screen.x, horizontalBoundary, ScrW() - horizontalBoundary)
        screen.y = math.Clamp(screen.y, verticalBoundary, ScrH() - verticalBoundary)

        surface.SetTexture(point)
        surface.SetDrawColor(255, 255, 255, 255 * alpha)
        surface.DrawTexturedRect(screen.x - 8, screen.y - 8 - 16, 16, 16)

        draw.ShadowText(text, "CW_HUD20", screen.x, screen.y, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function ENT:Think()
end