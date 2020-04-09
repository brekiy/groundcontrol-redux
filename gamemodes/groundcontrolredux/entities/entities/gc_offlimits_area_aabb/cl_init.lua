include('shared.lua')

function ENT:drawHUD()
    local w, h = ScrW(), ScrH()
    
    if self.penalizeTime then
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
        
        local text = self:getPenaltyText()
        text = string.gsub(text, "TIME", self:getTimeToDeath())
        
        drawShadowText(text, "ChatFont", w * 0.5, h * 0.5, GAMEMODE.HUDColors.white, GAMEMODE.HUDColors.black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end