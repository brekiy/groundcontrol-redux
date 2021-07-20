include("shared.lua")

ENT.PointName = {"A", "B", "C", "D", "E", "F"}
ENT.PointName[0] = "" -- muh lua errors

function ENT:Initialize()
    GAMEMODE:AddObjectiveEntity(self)
end

function ENT:Think()
end

ENT.barWidth = 60
ENT.barHeight = 8

ENT.capBarWidth = 100
ENT.capBarHeight = 10

ENT.topSize = 30
ENT.spacing = 10

ENT.captureText = "Capturing "
ENT.defendText = "Defending "

function ENT:GetProgressColor(sameTeam)
    if sameTeam then
        return 124, 185, 255, 255
    else
        return 255, 117, 99, 255
    end
end

function ENT:drawHUD()
    local ply = LocalPlayer()
    local x, y = ScrW(), ScrH()
    local midX = x * 0.5
    local hudPos = midX - (self.topSize + self.spacing) * #GAMEMODE.ObjectiveEntities * 0.5
    hudPos = hudPos + (self.topSize + self.spacing) * (self:GetPointID() - 1) + self.spacing * 0.5

    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(hudPos, 50, self.topSize, self.topSize)
    surface.DrawOutlinedRect(hudPos, 50, self.topSize, self.topSize)

    local sameTeam = ply:Team() == self:GetCapturerTeam()
    local r, g, b, a = self:GetProgressColor(sameTeam)
    local percentage = self:GetCaptureProgress() / self.CAPTURE_TIME

    if percentage > 0 then
        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(hudPos + 1, 51, (self.topSize - 2) * percentage, self.topSize - 2)
    end

    local white, black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    white.a = 255
    black.a = 255

    draw.ShadowText(self.PointName[self:GetPointID()], "CW_HUD24", hudPos + self.topSize * 0.5, 50 + self.topSize * 0.5, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local pos = self:GetPos()
    pos.z = pos.z + 32

    local coords = pos:ToScreen()

    if coords.visible then
        local baseX, baseY = math.ceil(coords.x - self.barWidth * 0.5), math.ceil(coords.y - 8)
        local alpha = math.Clamp(math.Distance(baseX, baseY, x * 0.5, y * 0.5), 150, 255) / 255

        surface.SetDrawColor(0, 0, 0, 255 * alpha)
        surface.DrawOutlinedRect(baseX, baseY, self.barWidth, self.barHeight)

        surface.SetDrawColor(0, 0, 0, 200 * alpha)
        surface.DrawRect(baseX + 1, baseY + 1, self.barWidth - 2, self.barHeight - 2)

        surface.SetDrawColor(r, g, b, a * alpha)

        surface.DrawRect(baseX + 2, baseY + 2, (self.barWidth - 4) * percentage, self.barHeight - 4)

        white.a = 255 * alpha
        black.a = 255 * alpha
        draw.ShadowText((sameTeam and "Capture " or "Protect ") .. self.PointName[self:GetPointID()], "CW_HUD14",
                coords.x, coords.y - 16, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        white.a = 255
        black.a = 255
    end

    if ply:Alive() and ply:GetPos():Distance(pos) <= self:GetCaptureDistance() then
        local midY = y * 0.5 + 150
        local desiredText = sameTeam and self.captureText or self.defendText
        draw.ShadowText(desiredText .. self.PointName[self:GetPointID()], "CW_HUD24",
                midX, midY, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(midX - self.capBarWidth * 0.5, midY + 15, self.capBarWidth, self.capBarHeight)

        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(midX + 1 - self.capBarWidth * 0.5, midY + 16, self.capBarWidth - 2, self.capBarHeight - 2)

        surface.SetDrawColor(r, g, b, 255)
        surface.DrawRect(midX + 2 - self.capBarWidth * 0.5, midY + 17, (self.capBarWidth - 4) * percentage, self.capBarHeight - 4)

        if self:GetCaptureSpeed() != 0 then
            draw.ShadowText("SPEED: x" .. math.Round(self:GetCaptureSpeed(), 2), "CW_HUD24",
                    midX, midY + self.capBarHeight + draw.GetFontHeight("CW_HUD24") + 5,
                    white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end