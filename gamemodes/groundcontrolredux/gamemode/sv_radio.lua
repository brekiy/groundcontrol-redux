include("sh_radio.lua")

GM.RadioDelay = 2

local PLAYER = FindMetaTable("Player")

function PLAYER:resetRadioData()
    self.radioWait = 0
end

function GM:SendRadioCommand(ply, category, radioId, command)
    local radioDelay = self.RadioDelay
    radioDelay = command and command.radioWait or radioDelay

    ply.radioWait = CurTime() + radioDelay

    if command and command.send then
        command:send(ply, radioId, category)
    else
        for key, obj in pairs(team.GetPlayers(ply:Team())) do
            self:SendRadio(ply, obj, category, radioId)
        end
    end
end

function GM:SetVoiceVariant(ply, stringID)
    ply.voiceVariant = self.VoiceVariantsById[stringID].numId
end

function GM:AttemptSetMemeRadio(ply)
    if self.MemeRadio and math.random(1, 1000) <= GetConVar("gc_meme_radio_chance"):GetInt() then
        self:SetVoiceVariant(ply, "bandlet")
        return true
    end

    return false
end

function GM:SendRadio(ply, target, category, radioId)
    net.Start("GC_RADIO")
    net.WriteFloat(CurTime())
    net.WriteUInt(category, 8)
    net.WriteUInt(radioId, 8)
    net.WriteUInt(ply.voiceVariant, 8)
    net.WriteEntity(ply)
    net.Send(target)
end

function GM:SendMarkedSpot(category, commandId, sender, receiver, pos)
    net.Start("GC_RADIO_MARKED")
    net.WriteFloat(CurTime())
    net.WriteUInt(category, 8)
    net.WriteUInt(commandId, 8)
    net.WriteUInt(sender.voiceVariant, 8)
    net.WriteEntity(sender)
    net.WriteVector(pos)
    net.Send(receiver)
end

concommand.Add("gc_radio_command", function(ply, com, args)
    local category = args[1]
    local radioId = args[2]

    if !category or !radioId then
        return
    end

    if !ply:Alive() or CurTime() < ply.radioWait then
        return
    end

    category = tonumber(category)
    radioId = tonumber(radioId)

    local desiredCategory = GAMEMODE.RadioCommands[category]

    if desiredCategory then
        local command = desiredCategory.commands[radioId]

        if command then
            GAMEMODE:SendRadioCommand(ply, category, radioId, command)
        end
    end
end)

CustomizableWeaponry.callbacks:addNew("beginThrowGrenade", "GroundControl_beginThrowGrenade", function(wep)
    -- Automatically call the frag out command
    GAMEMODE:SendRadioCommand(wep.Owner, 9, 1, nil)
end)