--[[
    Contains definitions for handlers on receiving networked game state updates
--]]
net.Receive("GC_BLEEDSTATE", function(a, b)
    local isBleeding = net.ReadBool()

    if isBleeding then
        GAMEMODE.tipController:HandleTipEvent("BEGIN_BLEEDING")
        GAMEMODE:ShowStatusEffect("bleeding")
    else
        GAMEMODE.tipController:HandleTipEvent("STOPPED_BLEEDING")
        GAMEMODE:RemoveStatusEffect("bleeding")
    end

    LocalPlayer():SetBleeding(isBleeding)
end)

net.Receive("GC_BANDAGES", function(a, b)
    LocalPlayer():SetBandages(net.ReadInt(8))
end)

net.Receive("GC_ADRENALINE", function(a, b)
    LocalPlayer():SetAdrenaline(net.ReadFloat())
end)

net.Receive("GC_STAMINA", function(a, b)
    LocalPlayer():SetStamina(net.ReadFloat())
end)

net.Receive("GC_RETRYTEAMSELECTION", function(a, b)
    GAMEMODE:OpenTeamSelection(true)
end)

net.Receive("GC_TEAM_SELECTION_SUCCESS", function(a, b)
    RunConsoleCommand("gc_desired_team", net.ReadUInt(8))
end)

net.Receive("GC_CASH", function(a, b)
    LocalPlayer():SetCash(net.ReadInt(32))
end)

net.Receive("GC_NOT_ENOUGH_CASH", function(a, b)
    local required = net.ReadInt(32)
    chat.AddText(GAMEMODE.HUD_COLORS.white, "Not enough cash! You need ", GAMEMODE.HUD_COLORS.blue, tostring(required) .. "$", GAMEMODE.HUD_COLORS.white, " whereas you have ", GAMEMODE.HUD_COLORS.blue, tostring(LocalPlayer().cash) .. "$")
    surface.PlaySound("buttons/combine_button7.wav")
end)

net.Receive("GC_ROUND_OVER", function(a, b)
    local winningTeam = net.ReadInt(8)
    local actionType = net.ReadInt(8)

    GAMEMODE:ResetRoundData()
    GAMEMODE:createRoundOverDisplay(winningTeam, actionType)
end)

net.Receive("GC_GAME_BEGIN", function(a, b)
    GAMEMODE:ResetRoundData()
    GAMEMODE:createRoundOverDisplay(nil)
end)

net.Receive("GC_ROUND_PREPARATION", function(a, b)
    GAMEMODE:RoundPreparation(net.ReadFloat())
end)

net.Receive("GC_SPECTATE_TARGET", function(a, b)
    LocalPlayer():SetSpectateTarget(net.ReadEntity())
end)

net.Receive("GC_NEW_ROUND", function(a, b)
    LocalPlayer():spawn(net.ReadEntity())
end)

net.Receive("GC_UNLOCKED_SLOTS", function(a, b)
    LocalPlayer():setUnlockedAttachmentSlots(net.ReadUInt(8))
end)

net.Receive("GC_EXPERIENCE", function(a, b)
    LocalPlayer():setExperience(net.ReadInt(32))
end)

net.Receive("GC_LAST_MAN_STANDING", function(a, b)
    GAMEMODE:CreateLastManStandingDisplay()
end)

net.Receive("GC_NOTIFICATION", function(a, b)
    chat.AddText(Color(150, 197, 255, 255), "[GROUND CONTROL] ", Color(255, 255, 255, 255), net.ReadString())
end)

net.Receive("GC_GAMETYPE", function(a, b)
    GAMEMODE:SetGametype(net.ReadInt(16))
end)

net.Receive("GC_AUTOBALANCED_TO_TEAM", function(a, b)
    if GAMEMODE.teamSwitchPopup then
        GAMEMODE.teamSwitchPopup:Remove()
        GAMEMODE.teamSwitchPopup = nil
    end

    local popup = vgui.Create("GCGenericPopup")
    popup:SetSize(310, 50)
    popup:SetText("You've been autobalanced to " .. team.GetName(net.ReadInt(8)), "Don't shoot your new team mates.")
    popup:SetExistTime(7)
    popup:Center()

    local x, y = popup:GetPos()
    popup:SetPos(x, y - 140)

    GAMEMODE.teamSwitchPopup = popup
end)

net.Receive("GC_NEW_TEAM", function(a, b)
    if GAMEMODE.teamSwitchPopup then
        GAMEMODE.teamSwitchPopup:Remove()
        GAMEMODE.teamSwitchPopup = nil
    end

    local popup = vgui.Create("GCGenericPopup")
    popup:SetSize(310, 50)
    popup:SetText("You are now on " .. team.GetName(net.ReadInt(16)), "Acknowledge your new objectives.")
    popup:SetExistTime(7)
    popup:Center()

    local x, y = popup:GetPos()
    popup:SetPos(x, y - 140)

    GAMEMODE.teamSwitchPopup = popup
end)

net.Receive("GC_NEW_WAVE", function(a, b)
    local lostTickets = net.ReadInt(16)

    if GAMEMODE.teamSwitchPopup then
        GAMEMODE.teamSwitchPopup:Remove()
        GAMEMODE.teamSwitchPopup = nil
    end

    local popup = vgui.Create("GCGenericPopup")

    local bottomText = lostTickets > 0 and ("Lost " .. lostTickets .. " tickets last wave.") or "No ticket loss."
    popup:SetSize(310, 50)
    popup:SetText("New wave.", bottomText)
    popup:SetExistTime(7)
    popup:Center()

    local x, y = popup:GetPos()
    popup:SetPos(x, y - 140)

    GAMEMODE.teamSwitchPopup = popup
end)

net.Receive("GC_GOT_DRUGS", function(a, b)
    if GAMEMODE.teamSwitchPopup then
        GAMEMODE.teamSwitchPopup:Remove()
        GAMEMODE.teamSwitchPopup = nil
    end

    local gametype = GAMEMODE.curGametype
    local bottomText = LocalPlayer():Team() == gametype.gangTeam and "Now bring them back to the base!" or "Now deliver them to the secure point!"

    local popup = vgui.Create("GCGenericPopup")
    popup:SetSize(330, 50)
    popup:SetText("You picked up the drugs!", bottomText)
    popup:SetExistTime(7)
    popup:Center()

    local x, y = popup:GetPos()
    popup:SetPos(x, y - 140)

    GAMEMODE.teamSwitchPopup = popup

    LocalPlayer().hasDrugs = true
end)

net.Receive("GC_DRUGS_REMOVED", function(a, b)
    LocalPlayer().hasDrugs = false
end)

net.Receive("GC_CARRIED_DRUGS_POSITION", function(a, b)
-- we're being sent 3 individual floats because vectors are compressed and that results in inaccuracy
    local x, y, z = net.ReadFloat(), net.ReadFloat(), net.ReadFloat()
    GAMEMODE:AddMarker(Vector(x, y, z), "Taken drugs", GAMEMODE.HUD_COLORS.red, GAMEMODE.curGametype.bugMarkerDuration)
end)

net.Receive("GC_STATUS_EFFECT", function()
    local statusEffect = net.ReadString()
    local state = net.ReadBool()
    if state then
        GAMEMODE:ShowStatusEffect(statusEffect)
    else
        GAMEMODE:RemoveStatusEffect(statusEffect)
    end
end)

net.Receive("GC_RESET_STATUS_EFFECTS", function(a, b)
    GAMEMODE:RemoveAllStatusEffects()
end)

net.Receive("GC_LOADOUTPOSITION", function(a, b)
    local vector = net.ReadVector()
    local duration = net.ReadFloat()
    GAMEMODE:SetLoadoutAvailabilityInfo(vector, duration)
end)

net.Receive("GC_KILLED_BY", function(a, b)
    local killerPlayer = net.ReadEntity()
    local killerEntClass = net.ReadString() -- the sent inflictor is not an entity, but is instead the entity class
    local wasBleeding = net.ReadBool()
    if IsValid(killerPlayer) and killerEntClass then
        GAMEMODE:createKilledByDisplay(killerPlayer, killerEntClass, wasBleeding)
    end
end)

net.Receive("GC_UPDATE_LOADOUT_LIMIT", function(a, b)
    LocalPlayer():UpdateLoadoutPoints()
end)

net.Receive("GC_GOT_INTEL", function(a, b)
    if GAMEMODE.teamSwitchPopup then
        GAMEMODE.teamSwitchPopup:Remove()
        GAMEMODE.teamSwitchPopup = nil
    end

    local bottomText = "Now deliver it to the secure point!"

    local popup = vgui.Create("GCGenericPopup")
    popup:SetSize(330, 50)
    popup:SetText("You picked up the intel!", bottomText)
    popup:SetExistTime(7)
    popup:Center()

    local x, y = popup:GetPos()
    popup:SetPos(x, y - 140)

    GAMEMODE.teamSwitchPopup = popup

    LocalPlayer().hasIntel = true
end)

net.Receive("GC_INTEL_REMOVED", function(a, b)
    LocalPlayer().hasIntel = false
end)

net.Receive("GC_SET_VIP", function(a, b)
    local isVIP = net.ReadBool()
    if isVIP then
        if GAMEMODE.teamSwitchPopup then
            GAMEMODE.teamSwitchPopup:Remove()
            GAMEMODE.teamSwitchPopup = nil
        end

        local popup = vgui.Create("GCGenericPopup")
        popup:SetSize(330, 50)
        popup:SetText("You are the VIP!", "Stay close to your bodyguards and escape!")
        popup:SetExistTime(7)
        popup:Center()

        local x, y = popup:GetPos()
        popup:SetPos(x, y - 140)

        GAMEMODE.teamSwitchPopup = popup
    end
    LocalPlayer().isVIP = isVIP
end)

net.Receive("GC_START_LOADOUT_EXPENSIVE", function(a, b)
    chat.AddText(GAMEMODE.HUD_COLORS.limeYellow, "Your previous loadout was too expensive and has been stripped down for this round.")
end)
