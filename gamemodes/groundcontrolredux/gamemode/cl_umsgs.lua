-- The file is named umsgs, but that library sucks. Only net allowed in this house. -brekiy 2020-03-26

net.Receive("GC_BLEEDSTATE", function(a, b)
    local isBleeding = net.ReadBool()

    if isBleeding then
        GAMEMODE.tipController:handleEvent("BEGIN_BLEEDING")
        GAMEMODE:showStatusEffect("bleeding")
    else
        GAMEMODE.tipController:handleEvent("STOPPED_BLEEDING")
        GAMEMODE:removeStatusEffect("bleeding")
    end

    LocalPlayer():setBleeding(isBleeding)
end)

net.Receive("GC_BANDAGES", function(a, b)
    LocalPlayer():setBandages(net.ReadInt(8))
end)

net.Receive("GC_ADRENALINE", function(a, b)
    LocalPlayer():setAdrenaline(net.ReadFloat())
end)

net.Receive("GC_STAMINA", function(a, b)
    LocalPlayer():setStamina(net.ReadFloat())
end)

net.Receive("GC_RETRYTEAMSELECTION", function(a, b)
    GAMEMODE:openTeamSelection(true)
end)

net.Receive("GC_TEAM_SELECTION_SUCCESS", function(a, b)
    RunConsoleCommand("gc_desired_team", net.ReadUInt(8))
end)

net.Receive("GC_CASH", function(a, b)
    LocalPlayer():setCash(net.ReadInt(32))
end)

net.Receive("GC_NOT_ENOUGH_CASH", function(a, b)
    local required = net.ReadInt(32)
    chat.AddText(GAMEMODE.HUDColors.white, "Not enough cash! You need ", GAMEMODE.HUDColors.blue, tostring(required) .. "$", GAMEMODE.HUDColors.white, " whereas you have ", GAMEMODE.HUDColors.blue, tostring(LocalPlayer().cash) .. "$")
    surface.PlaySound("buttons/combine_button7.wav")
end)

net.Receive("GC_ROUND_OVER", function(a, b)
    local winningTeam = net.ReadInt(8)
    local actionType = net.ReadInt(8)
    
    GAMEMODE:resetRoundData()
    GAMEMODE:createRoundOverDisplay(winningTeam, actionType)
end)

net.Receive("GC_GAME_BEGIN", function(a, b)
    GAMEMODE:resetRoundData()
    GAMEMODE:createRoundOverDisplay(nil)
end)

net.Receive("GC_ROUND_PREPARATION", function(a, b)
    GAMEMODE:roundPreparation(net.ReadFloat())
end)

net.Receive("GC_SPECTATE_TARGET", function(a, b)
    LocalPlayer():setSpectateTarget(net.ReadEntity())
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
    GAMEMODE:createLastManStandingDisplay()
end)

net.Receive("GC_NOTIFICATION", function(a, b)
    chat.AddText(Color(150, 197, 255, 255), "[GROUND CONTROL] ", Color(255, 255, 255, 255), net.ReadString())
end)

local function GC_AUTOBALANCED_TO_TEAM(um)
    if GAMEMODE.teamSwitchPopup then
        GAMEMODE.teamSwitchPopup:Remove()
        GAMEMODE.teamSwitchPopup = nil
    end
    
    local popup = vgui.Create("GCGenericPopup")
    popup:SetSize(310, 50)
    popup:SetText("You've been autobalanced to " .. team.GetName(um:ReadShort()), "Don't shoot your new team mates.")
    popup:SetExistTime(7)
    popup:Center()
    
    local x, y = popup:GetPos()
    popup:SetPos(x, y - 140)
    
    GAMEMODE.teamSwitchPopup = popup
end

usermessage.Hook("GC_AUTOBALANCED_TO_TEAM", GC_AUTOBALANCED_TO_TEAM)

local function GC_NEW_TEAM(um)
    if GAMEMODE.teamSwitchPopup then
        GAMEMODE.teamSwitchPopup:Remove()
        GAMEMODE.teamSwitchPopup = nil
    end
    
    local popup = vgui.Create("GCGenericPopup")
    popup:SetSize(310, 50)
    popup:SetText("You are now on " .. team.GetName(um:ReadShort()), "Acknowledge your new objectives.")
    popup:SetExistTime(7)
    popup:Center()
    
    local x, y = popup:GetPos()
    popup:SetPos(x, y - 140)
    
    GAMEMODE.teamSwitchPopup = popup
end

usermessage.Hook("GC_NEW_TEAM", GC_NEW_TEAM)

local function GC_NEW_WAVE(um)
    local lostTickets = um:ReadShort()
    
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
end

usermessage.Hook("GC_NEW_WAVE", GC_NEW_WAVE)

local function GC_GOT_DRUGS(um)
    if GAMEMODE.teamSwitchPopup then
        GAMEMODE.teamSwitchPopup:Remove()
        GAMEMODE.teamSwitchPopup = nil
    end
    
    local gametype = GAMEMODE.curGametype
    local bottomText = LocalPlayer():Team() == gametype.regularTeam and "Now bring them back to the base!" or "Now deliver them to the secure point!"
    
    local popup = vgui.Create("GCGenericPopup")
    popup:SetSize(330, 50)
    popup:SetText("You picked up the drugs!", bottomText)
    popup:SetExistTime(7)
    popup:Center()
    
    local x, y = popup:GetPos()
    popup:SetPos(x, y - 140)
    
    GAMEMODE.teamSwitchPopup = popup
    
    LocalPlayer().hasDrugs = true
end

usermessage.Hook("GC_GOT_DRUGS", GC_GOT_DRUGS)

net.Receive("GC_DRUGS_REMOVED", function(a, b)
    LocalPlayer().hasDrugs = false
end)

local function GC_CARRIED_DRUGS_POSITION(um)
    -- we're being sent 3 individual floats because vectors are compressed and that results in inaccuracy
    local x, y, z = um:ReadFloat(), um:ReadFloat(), um:ReadFloat()
    
    GAMEMODE:AddMarker(Vector(x, y, z), "Taken drugs", GAMEMODE.HUDColors.red, GAMEMODE.curGametype.bugMarkerDuration)
end

usermessage.Hook("GC_CARRIED_DRUGS_POSITION", GC_CARRIED_DRUGS_POSITION)

local function GC_StatusEffect(data)
    local statusEffect = data:ReadString()
    local state = data:ReadBool()
        
    if state then
        GAMEMODE:showStatusEffect(statusEffect)
    else
        GAMEMODE:removeStatusEffect(statusEffect)
    end
end

usermessage.Hook("GC_STATUS_EFFECT", GC_StatusEffect)

local function GC_ResetStatusEffects(data)
    GAMEMODE:removeAllStatusEffects()
end

usermessage.Hook("GC_RESET_STATUS_EFFECTS", GC_ResetStatusEffects)

-- receives loadout position and duration
local function GC_LoadoutPosition(um)
    local vector = um:ReadVector()
    local duration = um:ReadFloat()
    
    GAMEMODE:setLoadoutAvailabilityInfo(vector, duration)
end

usermessage.Hook("GC_LOADOUTPOSITION", GC_LoadoutPosition)

net.Receive("GC_KILLED_BY", function()
    local killerPlayer = net.ReadEntity()
    local killerEntClass = net.ReadString() -- the sent inflictor is not an entity, but is instead the entity class
    
    if IsValid(killerPlayer) and killerEntClass then
        GAMEMODE:createKilledByDisplay(killerPlayer, killerEntClass)
    end
end)