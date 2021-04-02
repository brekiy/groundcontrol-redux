AddCSLuaFile()

GM.soundTable = {
    channel = CHAN_AUTO,
    volume = 1,
    level = 65,
    pitchstart = 100,
    pitchend = 100,
    name = "noName",
    sound = "path/to/sound"
}

function GM:registerSound(name, snd, volume, soundLevel, channel, pitchStart, pitchEnd)
    -- use defaults if no args are provided
    volume = volume or 1
    soundLevel = soundLevel or 65
    channel = channel or CHAN_AUTO
    pitchStart = pitchStart or 100
    pitchEnd = pitchEnd or 100

    self.soundTable.name = name
    self.soundTable.sound = snd

    self.soundTable.channel = channel
    self.soundTable.volume = volume
    self.soundTable.level = soundLevel
    self.soundTable.pitchstart = pitchStart
    self.soundTable.pitchend = pitchEnd

    sound.Add(self.soundTable)

    -- precache the registered sounds

    if type(self.soundTable.sound) == "table" then
        for k, v in pairs(self.soundTable.sound) do
            util.PrecacheSound(v)
        end
    else
        util.PrecacheSound(snd)
    end
end

GM:registerSound("GC_BANDAGE", {"ground_control/player/bandage1.mp3", "ground_control/player/bandage2.mp3", "ground_control/player/bandage3.mp3"})
GM:registerSound("GC_BLEED", {"ground_control/player/bleed1.mp3", "ground_control/player/bleed2.mp3", "ground_control/player/bleed3.mp3", "ground_control/player/bleed4.mp3", "ground_control/player/bleed5.mp3"})
GM:registerSound("GC_DEATH_SOUND", {"vo/npc/Barney/ba_pain01.wav", "vo/npc/Barney/ba_pain02.wav", "vo/npc/Barney/ba_pain03.wav", "vo/npc/Barney/ba_pain04.wav", "vo/npc/Barney/ba_pain05.wav", "vo/npc/Barney/ba_pain06.wav", "vo/npc/Barney/ba_pain07.wav", "vo/npc/Barney/ba_pain08.wav", "vo/npc/Barney/ba_pain09.wav", "vo/npc/male01/pain01.wav", "vo/npc/male01/pain02.wav", "vo/npc/male01/pain03.wav", "vo/npc/male01/pain04.wav", "vo/npc/male01/pain05.wav"}, 1, 400)
GM:registerSound("GC_DINK", {"physics/metal/metal_sheet_impact_bullet1.wav", "physics/metal/metal_sheet_impact_bullet2.wav"}, 1, 200)
