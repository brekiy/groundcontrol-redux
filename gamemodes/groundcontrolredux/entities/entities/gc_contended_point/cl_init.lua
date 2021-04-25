include("shared.lua")

function ENT:Initialize()
    GAMEMODE:AddObjectiveEntity(self)
end

function ENT:Think()
end

ENT.barWidth = 60
ENT.barHeight = 8

ENT.colorByTeam = {[TEAM_RED] = Color(124, 185, 255, 255),
    [TEAM_BLUE] = Color(255, 117, 99, 255)}

function ENT:drawHUD()
    local pos = self:GetPos()
    pos.z = pos.z + 32

    local coords = pos:ToScreen()
    local white, black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    if coords.visible then
        local baseX, baseY = math.ceil(coords.x - self.barWidth * 0.5), math.ceil(coords.y - 8)
        local alpha = math.Clamp(math.Distance(baseX, baseY, ScrW() * 0.5, ScrH() * 0.5), 150, 255) / 255

        surface.SetDrawColor(0, 0, 0, 255 * alpha)
        surface.DrawOutlinedRect(baseX, baseY, self.barWidth, self.barHeight)

        surface.SetDrawColor(0, 0, 0, 200 * alpha)
        surface.DrawRect(baseX + 1, baseY + 1, self.barWidth - 2, self.barHeight - 2)

        local drawColor = self.colorByTeam[self:GetCurCaptureTeam()]

        if drawColor then
            drawColor.a = 255 * alpha

            surface.SetDrawColor(drawColor)

            local percentage = self:GetCaptureProgress() / 100
            surface.DrawRect(baseX + 2, baseY + 2, (self.barWidth - 4) * percentage, self.barHeight - 4)
        end

        white.a = 255 * alpha
        black.a = 255 * alpha
        draw.ShadowText("Capture", "CW_HUD14", coords.x, coords.y - 16, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        white.a = 255
        black.a = 255
    end

    if ply:Alive() and ply:GetPos():Distance(pos) <= self:GetCaptureDistance() then
        local midY = y * 0.5 + 150
        local desiredText = sameTeam and self.captureText or self.defendText
        draw.ShadowText(desiredText .. self.PointName[self:GetPointID()], "CW_HUD24", midX, midY, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(midX - self.capBarWidth * 0.5, midY + 15, self.capBarWidth, self.capBarHeight)

        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(midX + 1 - self.capBarWidth * 0.5, midY + 16, self.capBarWidth - 2, self.capBarHeight - 2)

        surface.SetDrawColor(r, g, b, 255)
        surface.DrawRect(midX + 2 - self.capBarWidth * 0.5, midY + 17, (self.capBarWidth - 4) * percentage, self.capBarHeight - 4)

        draw.ShadowText("SPEED: x" .. math.Round(self:GetCaptureSpeed(), 2), "CW_HUD24", midX, midY + self.capBarHeight + draw.GetFontHeight("CW_HUD24") + 5, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end