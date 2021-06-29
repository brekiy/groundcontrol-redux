GM.RadioSelection = {selectedCategory = 0, selectedId = 0, alpha = 0, active = false, position = 0}
GM.RadioSoundCache = {}

function GM:SelectRadioCommand(id)
    self.RadioSelection.selectedId = id
    self.RadioSelection.active = false

    RunConsoleCommand("gc_radio_command", self.RadioSelection.selectedCategory, id)
end

function GM:ReceiveRadioCommand(data)
    local seed = net.ReadFloat()
    local category = net.ReadUInt(8)
    local commandId = net.ReadUInt(8)
    local voiceVariant = net.ReadUInt(8)
    local sender = net.ReadEntity()

    if !IsValid(sender) then
        return
    end

    local commandData = self.RadioCommands[category].commands[commandId]

    if commandData.receive then
        commandData:receive(sender, commandId, category, data)
    end

    self:PlayRadioCommand(category, commandId, voiceVariant, sender, seed)
end

function GM:PlayRadioCommand(category, commandId, voiceVariant, sender, seed)
    local senderIsLocalPlayer = sender == LocalPlayer()

    if !senderIsLocalPlayer then
        GAMEMODE.tipController:HandleTipEvent("RADIO_USED")
    end

    sender.radioTime = CurTime() + 2
    sender.radioAlpha = 255

    local commandData = self.RadioCommands[category].commands[commandId]
    local voiceVar = self.VoiceVariants[voiceVariant]
    local voiceVariantName = voiceVar.id
    local variations = commandData.variations[voiceVariantName]

    if commandData.tipId and !senderIsLocalPlayer then
        GAMEMODE.tipController:HandleTipEvent(commandData.tipId)
    end

    math.randomseed(seed) -- set seed to CurTime so that the variant of the voice command is synced with everyone else
    local variation = variations[math.random(1, #variations)]

    self:AddRadioTextToChat(variation.text, sender, variation.sound, voiceVar, commandData)
end

function GM:GetRadioSoundFromCache(sender, soundName)
    local entIndex = sender:EntIndex()

    self.RadioSoundCache[entIndex] = self.RadioSoundCache[entIndex] or {} -- store sound objects by entity index (multiple players need separate sounds) + sound name

    if !self.RadioSoundCache[entIndex][soundName] then -- create a new sound object, cache it and return it if it wasn't created yet
        local soundObject = CreateSound(sender, soundName, CHAN_STATIC)
        soundObject:SetSoundLevel(0) -- audible everywhere
        self.RadioSoundCache[entIndex][soundName] = soundObject
    end

    return self.RadioSoundCache[entIndex][soundName]
end

function GM:PlayRadioSound(sender, soundName)
    local soundObject = self:GetRadioSoundFromCache(sender, soundName)
    soundObject:Stop()
    soundObject:PlayEx(1, 100) -- replay the sound
    sender.currentRadioSound = soundObject
end

function GM:AddRadioTextToChat(text, sender, sound, voiceVariantData, commandData)
    if voiceVariantData.requiresSubtitles then
        text =  "(" .. commandData.menuText .. ") " .. text
    end

    chat.AddText(self.HUD_COLORS.blue, "(RADIO) ", sender, self.HUD_COLORS.white, ": ", text)
    self:PlayRadioSound(sender, sound)
    --surface.PlaySound(sound)
end

function GM:ToggleRadio()
    if !LocalPlayer():Alive() then
        self.RadioSelection.active = false
        return
    end

    self.RadioSelection.active = !self.RadioSelection.active

    if self.RadioSelection.active then
        self.RadioSelection.position = 0
        self.RadioSelection.selectedCategory = 0
        self.RadioSelection.selectedId = 0
        self:hideWeaponSelection()
    end
end

function GM:HideRadio()
    self.RadioSelection.active = false
end

function GM:CycleRadio(direction)
    if #self.RadioCommands > 9 then
        self.RadioSelection.position = math.Clamp(self.RadioSelection.position + 9 * direction, 0, #self.RadioCommands)
    end
end

function GM:DrawRadioDisplay(frameTime)
    if self.RadioSelection.active then
        self.RadioSelection.alpha = math.Approach(self.RadioSelection.alpha, 1, frameTime * 8)
    else
        self.RadioSelection.alpha = math.Approach(self.RadioSelection.alpha, 0, frameTime * 8)
    end

    if self.RadioSelection.alpha > 0 then
        local midX, midY = ScrW() * 0.5, ScrH() * 0.5
        self.HUD_COLORS.white.a, self.HUD_COLORS.black.a, self.HUD_COLORS.green.a = 255 * self.RadioSelection.alpha, 255 * self.RadioSelection.alpha, 255 * self.RadioSelection.alpha

        if self.RadioSelection.selectedCategory == 0 then
            local categoryCount = #self.VisibleRadioCommands + 1
            local basePos = midY - categoryCount * 10
            surface.SetDrawColor(0, 0, 0, 150 * self.RadioSelection.alpha)
            surface.DrawRect(50, basePos, 235, categoryCount * 20)

            for key, data in ipairs(self.VisibleRadioCommands) do
                draw.ShadowText(key .. ". " .. data.display, "CW_HUD16", 55, basePos + key * 20 - 10, self.HUD_COLORS.white, self.HUD_COLORS.black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            draw.ShadowText(self:getKeyBind("+attack2") .. " - close radio", "CW_HUD16", 55, basePos + categoryCount * 20 - 10, self.HUD_COLORS.white, self.HUD_COLORS.black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            local category = self.RadioCommands[self.RadioSelection.selectedCategory]
            local commandCount = #category.commands + 1

            local basePos = midY - commandCount * 10
            surface.SetDrawColor(0, 0, 0, 150 * self.RadioSelection.alpha)
            surface.DrawRect(50, basePos, 220, commandCount * 20)

            for key, data in ipairs(category.commands) do
                local color = self.HUD_COLORS.white

                if self.RadioSelection.selectedId == key then
                    color = self.HUD_COLORS.green
                end

                draw.ShadowText(key .. ". " .. data.menuText, "CW_HUD16", 55, basePos + key * 20 - 10, color, self.HUD_COLORS.black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            draw.ShadowText(self:getKeyBind("+attack2") .. " - go back", "CW_HUD16", 55, basePos + commandCount * 20 - 10, self.HUD_COLORS.white, self.HUD_COLORS.black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        self.HUD_COLORS.white.a, self.HUD_COLORS.black.a, self.HUD_COLORS.green.a = 255, 255, 255
    end
end

local PLAYER = FindMetaTable("Player")

function PLAYER:StopRadioSound()
    if self.currentRadioSound and self.currentRadioSound:IsPlaying() then -- if we die in the middle of a radio command, we cut it off and play the radio off sound
        self.currentRadioSound:Stop()
        surface.PlaySound("ground_control/radio/radio_off.mp3")
    end
end

gameevent.Listen("entity_killed")

local function entity_killed(data)
    local victim = Entity(data.entindex_killed)

    if IsValid(victim) and victim:IsPlayer() then
        if victim:Team() == LocalPlayer():Team() then
            victim:stopRadioSound()
        end

        GAMEMODE:onPlayerDied(victim, data)
    end
end

hook.Add("entity_killed", "GroundControl.entity_killed", entity_killed)

-- local function GC_Radio(data)
--     GAMEMODE:ReceiveRadioCommand(data)
-- end

-- usermessage.Hook("GC_RADIO", GC_Radio)

-- original functions using umsg would pass in the bf_read message. hopefully this will never break again lol
net.Receive("GC_RADIO", function(a, b)
    GAMEMODE:ReceiveRadioCommand(nil)
end)

net.Receive("GC_RADIO_MARKED", function(a, b)
    GAMEMODE:ReceiveRadioCommand(nil)
end)

-- net.Receive("GC_FRAGOUT", function()
--     local variant = net.ReadUInt(8)
--     local emitter = net.ReadEntity()

--     GAMEMODE:PlayRadioCommand(9, 1, variant, emitter)
-- end)

concommand.Add("gc_radio_menu", function(ply, com, args)
    GAMEMODE:ToggleRadio()
end)
