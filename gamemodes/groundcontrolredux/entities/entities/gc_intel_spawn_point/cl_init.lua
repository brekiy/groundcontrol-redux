include("shared.lua")

-- local baseFont = "CW_HUD72"

function ENT:Initialize()
    GAMEMODE:addObjectiveEntity(self)
end

local white, black = Color(255, 255, 255, 255), Color(0, 0, 0, 255)
local horizontalBoundary, verticalBoundary = 75, 75
local point = surface.GetTextureID("ground_control/hud/point_of_interest")

function ENT:drawHUD()
    if self.dt.HasIntel then
        local pos = nil

        if !self.ownPos then -- we know that this entity's position isn't going to be changed (it's a static ent) so just get it's position once instead of spamming tables per each draw call
            self.ownPos = self:GetPos()
            self.ownPos.z = self.ownPos.z + 32
        end

        pos = self.ownPos

        local text = "Last known intel location"
        local alpha = 1
        alpha = alpha * (0.2 + 0.8 * math.flash(CurTime(), 2))
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
end

function ENT:Draw()
end

function ENT:Think()
end