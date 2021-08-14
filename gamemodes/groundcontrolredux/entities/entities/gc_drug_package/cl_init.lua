include("shared.lua")

-- local baseFont = "CW_HUD72"
ENT.RetrieveAndProtect = "Retrieve & protect"
ENT.ProtectText = "Protect"
ENT.AttackAndCapture = "Attack & capture"
ENT.CaptureText = "Capture"
ENT.BasicText = "Drugs"

function ENT:Initialize()
    GAMEMODE:AddObjectiveEntity(self)
end

-- the distance within which the contents of the box will be displayed
ENT.displayDistance = 256

function ENT:Think()
    self.inRange = LocalPlayer():GetPos():Distance(self:GetPos()) <= self.displayDistance
end

local white, black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
local displayFont = "CW_HUD14"
local horizontalBoundary, verticalBoundary = 75, 75
local point = surface.GetTextureID("ground_control/hud/point_of_interest")

function ENT:drawHUD()
    local ply = LocalPlayer()

    local pos = self:GetPos()
    pos.z = pos.z + 32

    local text = nil
    local gametype = GAMEMODE.curGametype
    local team = ply:Team()

    local alpha = ply.hasDrugs and 0.4 or 1

    if self:GetDropped() then
        if self.inRange then
            text = self.BasicText
        else
            text = team == gametype.swatTeam and self.CaptureText or self.RetrieveAndProtect
        end
        alpha = alpha * (0.25 + 0.75 * math.flash(CurTime(), 1.5))
    else
        text = team == gametype.swatTeam and self.AttackAndCapture or self.ProtectText
    end

    local screen = pos:ToScreen()

    screen.x = math.Clamp(screen.x, horizontalBoundary, ScrW() - horizontalBoundary)
    screen.y = math.Clamp(screen.y, verticalBoundary, ScrH() - 200)

    surface.SetTexture(point)
    surface.SetDrawColor(255, 255, 255, 255 * alpha)
    surface.DrawTexturedRect(screen.x - 8, screen.y - 8 - 16, 16, 16)

    white.a = 255 * alpha
    black.a = 255 * alpha

    draw.ShadowText(text, displayFont, screen.x, screen.y, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
