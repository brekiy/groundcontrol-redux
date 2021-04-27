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

local helmetImpacts = {
    "physics/metal/metal_sheet_impact_bullet1.wav",
    "physics/metal/metal_sheet_impact_bullet2.wav",
    "physics/metal/metal_computer_impact_bullet1.wav",
    "physics/metal/metal_computer_impact_bullet2.wav",
    "physics/metal/metal_computer_impact_bullet3.wav",
}

local headImpacts = {
    "physics/flesh/flesh_squishy_impact_hard1.wav",
    "physics/flesh/flesh_squishy_impact_hard2.wav",
    "physics/flesh/flesh_squishy_impact_hard3.wav",
    "physics/flesh/flesh_squishy_impact_hard4.wav",
}

local deathSounds = {
    "vo/npc/Barney/ba_pain01.wav",
    "vo/npc/Barney/ba_pain02.wav",
    "vo/npc/Barney/ba_pain03.wav",
    "vo/npc/Barney/ba_pain04.wav",
    "vo/npc/Barney/ba_pain05.wav",
    "vo/npc/Barney/ba_pain06.wav",
    "vo/npc/Barney/ba_pain07.wav",
    "vo/npc/Barney/ba_pain08.wav",
    "vo/npc/Barney/ba_pain09.wav",
    "vo/npc/male01/pain01.wav",
    "vo/npc/male01/pain02.wav",
    "vo/npc/male01/pain03.wav",
    "vo/npc/male01/pain04.wav",
    "vo/npc/male01/pain05.wav"
}

-- Footstep sounds
local concreteSounds = {
    "ground_control/footsteps/concrete1.wav",
    "ground_control/footsteps/concrete2.wav",
    "ground_control/footsteps/concrete3.wav",
    "ground_control/footsteps/concrete4.wav"
}

local woodSounds = {
    "ground_control/footsteps/wood1.wav",
    "ground_control/footsteps/wood2.wav",
    "ground_control/footsteps/wood3.wav",
    "ground_control/footsteps/wood4.wav"
}

local grassSounds = {
    "ground_control/footsteps/grass1.wav",
    "ground_control/footsteps/grass2.wav",
    "ground_control/footsteps/grass3.wav",
    "ground_control/footsteps/grass4.wav"
}

local sloshSounds = {
    "ground_control/footsteps/slosh1.wav",
    "ground_control/footsteps/slosh2.wav",
    "ground_control/footsteps/slosh3.wav",
    "ground_control/footsteps/slosh4.wav"
}

local metalSounds = {
    "ground_control/footsteps/metal1.wav",
    "ground_control/footsteps/metal2.wav",
    "ground_control/footsteps/metal3.wav",
    "ground_control/footsteps/metal4.wav"
}

local ladderSounds = {"ground_control/footsteps/ladder1.wav", "ground_control/footsteps/ladder2.wav", "ground_control/footsteps/ladder3.wav", "ground_control/footsteps/ladder4.wav"}
local gravelSounds = {"ground_control/footsteps/gravel1.wav", "ground_control/footsteps/gravel2.wav", "ground_control/footsteps/gravel3.wav", "ground_control/footsteps/gravel4.wav"}
local snowSounds = {"ground_control/footsteps/snow1.wav", "ground_control/footsteps/snow2.wav", "ground_control/footsteps/snow3.wav", "ground_control/footsteps/snow4.wav"}
local dirtSounds = {"ground_control/footsteps/dirt1.wav", "ground_control/footsteps/dirt2.wav", "ground_control/footsteps/dirt3.wav", "ground_control/footsteps/dirt4.wav"}
local woodPanelSounds = {"ground_control/footsteps/woodpanel1.wav", "ground_control/footsteps/woodpanel2.wav", "ground_control/footsteps/woodpanel3.wav", "ground_control/footsteps/woodpanel4.wav"}

function GM:RegisterSound(name, snd, volume, soundLevel, channel, pitchStart, pitchEnd)
    -- use defaults if no args are provided
    volume = volume or 1
    soundLevel = soundLevel or 65
    channel = channel or CHAN_AUTO
    pitchStart = pitchStart or 90
    pitchEnd = pitchEnd or 110

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

GM:RegisterSound("GC_BANDAGE_SOUND", {"ground_control/player/bandage1.mp3", "ground_control/player/bandage2.mp3", "ground_control/player/bandage3.mp3"}, 1, 70, CHAN_ITEM)
GM:RegisterSound("GC_BLEED_SOUND", {"ground_control/player/bleed1.mp3", "ground_control/player/bleed2.mp3", "ground_control/player/bleed3.mp3", "ground_control/player/bleed4.mp3", "ground_control/player/bleed5.mp3"}, 1, 55, CHAN_BODY)
GM:RegisterSound("GC_DEATH_SOUND", deathSounds, 1, 125, CHAN_VOICE)
GM:RegisterSound("GC_HELMET_RICOCHET_SOUND", helmetImpacts, 1, 85, CHAN_BODY)
GM:RegisterSound("GC_HEADSHOT_SOUND", headImpacts, 1, 95, CHAN_BODY)

-- Footstep sounds get precached
GM:RegisterSound("GC_FALLBACK_WALK_SOUNDS", concreteSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_CONCRETE", concreteSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_WOOD", woodSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_GRASS", grassSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_SLOSH", sloshSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_METAL", metalSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_LADDER", ladderSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_GRAVEL", gravelSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_SNOW", snowSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_DIRT", dirtSounds, 1, 65, CHAN_BODY)
GM:RegisterSound("GC_WALK_WOODPANEL", woodPanelSounds, 1, 65, CHAN_BODY)
