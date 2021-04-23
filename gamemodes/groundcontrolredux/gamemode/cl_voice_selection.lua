CreateClientConVar("gc_desired_voice", 0, true, true)

concommand.Add("gc_voice_menu", function(ply)
    GAMEMODE:OpenVoiceSelection()
end)

function GM:OpenVoiceSelection()
    if IsValid(self.curPanel) then
        self.curPanel:Remove()
        self.curPanel = nil
        return
    end

    local panel = vgui.Create("GCFrame")
    panel:SetSize(200, 30 + 30 * #self.VisibleVoiceVariants)
    panel:Center()
    panel:DisableMouseOnClose(true)
    panel:SetTitle("Voice selection")
    panel:SetDraggable(false, false)

    self.curPanel = panel
    self:toggleMouse()

    for key, voiceData in pairs(self.VisibleVoiceVariants) do
        local option = vgui.Create("GCVoiceSelectionButton", panel)
        option:SetPos(5, 30 * key)
        option:SetSize(190, 22)
        option:SetVoice(voiceData.id)
        option:SetTextColor(self.HUD_COLORS.white)
    end
end