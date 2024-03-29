include("shared.lua")

local displayFont = "CW_HUD14"

function ENT:Initialize()
    GAMEMODE:AddObjectiveEntity(self)
end

local white, black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
ENT.CaptureText = "Intel retrieval point"
ENT.DeliverText = "Deliver intel"

local horizontalBoundary, verticalBoundary = 75, 75
local point = surface.GetTextureID("ground_control/hud/point_of_interest")

function ENT:drawHUD()
    local ply = LocalPlayer()
    local sameTeam = ply:Team() == self:GetCapturerTeam()
    if !sameTeam then return end
    local pos = nil

    -- this is a static ent, get it's position once instead of spamming tables per each draw call
    if !self.ownPos then
        self.ownPos = self:GetPos()
        self.ownPos.z = self.ownPos.z + 32
    end

    pos = self.ownPos

    local text = nil
    local skipVisCheck = false
    local alpha = 1

    if ply.hasIntel then
        text = self.DeliverText
        skipVisCheck = true
        alpha = alpha * (0.2 + 0.8 * math.flash(CurTime(), 1.5))
    else
        text = self.CaptureText
        alpha = 0.4
    end

    white.a = 255 * alpha
    black.a = 255 * alpha

    local screen = pos:ToScreen()

    if screen.visible or skipVisCheck then
        screen.x = math.Clamp(screen.x, horizontalBoundary, ScrW() - horizontalBoundary)
        screen.y = math.Clamp(screen.y, verticalBoundary, ScrH() - 200)

        if skipVisCheck then
            surface.SetTexture(point)
            surface.SetDrawColor(255, 255, 255, 255 * alpha)
            surface.DrawTexturedRect(screen.x - 8, screen.y - 8 - 16, 16, 16)
        end

        draw.ShadowText(text, displayFont, screen.x, screen.y, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function ENT:Think()
end
