AddCSLuaFile()

GM.FOOTSTEP_LOUDNESS = {
    ULTRA_LOW = 1,
    VERY_LOW = 2,
    LOW = 3,
    MEDIUM = 4,
    HIGH = 5
}

-- the loudness value of our footsteps, used to figure out what sound should be played
GM.LOUDNESS_LEVELS = {
    [GM.FOOTSTEP_LOUDNESS.ULTRA_LOW] = 20, -- sneaking with a really low amount of weight
    [GM.FOOTSTEP_LOUDNESS.VERY_LOW] = 25, -- sneaking with a low amount of weight
    [GM.FOOTSTEP_LOUDNESS.LOW] = 38, -- walking with <10kg
    [GM.FOOTSTEP_LOUDNESS.MEDIUM] = 50, -- running with <15kg
    [GM.FOOTSTEP_LOUDNESS.HIGH] = 58, -- running with >15kg
}

-- the actual volume of the footstep sounds
GM.FOOTSTEP_LOUDNESS_LEVELS = {
    [GM.FOOTSTEP_LOUDNESS.ULTRA_LOW] = 38, -- sneaking with a really low amount of weight
    [GM.FOOTSTEP_LOUDNESS.VERY_LOW] = 45, -- sneaking with a low amount of weight
    [GM.FOOTSTEP_LOUDNESS.LOW] = 53, -- walking with <10kg
    [GM.FOOTSTEP_LOUDNESS.MEDIUM] = 63, -- running with <15kg
    [GM.FOOTSTEP_LOUDNESS.HIGH] = 71 -- running with >15kg
}

GM.FOOTSTEP_VOLUME_LEVELS = {
    [GM.FOOTSTEP_LOUDNESS.ULTRA_LOW] = 0.65, -- sneaking with a really low amount of weight
    [GM.FOOTSTEP_LOUDNESS.VERY_LOW] = 0.675, -- sneaking with a low amount of weight
    [GM.FOOTSTEP_LOUDNESS.LOW] = 0.7, -- walking with <10kg
    [GM.FOOTSTEP_LOUDNESS.MEDIUM] = 0.85, -- running with <15kg
    [GM.FOOTSTEP_LOUDNESS.HIGH] = 0.95 -- running with >15kg
}

-- special enumerations that don't have values listed in the wiki
MAT_LADDER = -100
MAT_GRAVEL = -101
MAT_CARPET = -102
MAT_WOODPANEL = -103

-- map the default sounds to a material ID, cheaper/hackier than traces
GM.DEFAULT_FOOTSTEP_TO_MATERIAL = {
    ["player/footsteps/wood1.wav"] = MAT_WOOD,
    ["player/footsteps/wood2.wav"] = MAT_WOOD,
    ["player/footsteps/wood3.wav"] = MAT_WOOD,
    ["player/footsteps/wood4.wav"] = MAT_WOOD,
    ["player/footsteps/grass1.wav"] = MAT_GRASS,
    ["player/footsteps/grass2.wav"] = MAT_GRASS,
    ["player/footsteps/grass3.wav"] = MAT_GRASS,
    ["player/footsteps/grass4.wav"] = MAT_GRASS,
    ["player/footsteps/dirt1.wav"] = MAT_DIRT,
    ["player/footsteps/dirt2.wav"] = MAT_DIRT,
    ["player/footsteps/dirt3.wav"] = MAT_DIRT,
    ["player/footsteps/dirt4.wav"] = MAT_DIRT,
    ["player/footsteps/ladder1.wav"] = MAT_LADDER,
    ["player/footsteps/ladder2.wav"] = MAT_LADDER,
    ["player/footsteps/ladder3.wav"] = MAT_LADDER,
    ["player/footsteps/ladder4.wav"] = MAT_LADDER,
    ["player/footsteps/slosh1.wav"] = MAT_SLOSH,
    ["player/footsteps/slosh2.wav"] = MAT_SLOSH,
    ["player/footsteps/slosh3.wav"] = MAT_SLOSH,
    ["player/footsteps/slosh4.wav"] = MAT_SLOSH,
    ["player/footsteps/metal1.wav"] = MAT_METAL,
    ["player/footsteps/metal2.wav"] = MAT_METAL,
    ["player/footsteps/metal3.wav"] = MAT_METAL,
    ["player/footsteps/metal4.wav"] = MAT_METAL,
    ["player/footsteps/gravel1.wav"] = MAT_GRAVEL,
    ["player/footsteps/gravel2.wav"] = MAT_GRAVEL,
    ["player/footsteps/gravel3.wav"] = MAT_GRAVEL,
    ["player/footsteps/gravel4.wav"] = MAT_GRAVEL,
    ["player/footsteps/snow1.wav"] = MAT_SNOW,
    ["player/footsteps/snow2.wav"] = MAT_SNOW,
    ["player/footsteps/snow3.wav"] = MAT_SNOW,
    ["player/footsteps/snow4.wav"] = MAT_SNOW,
    ["player/footsteps/sand1.wav"] = MAT_SAND,
    ["player/footsteps/sand2.wav"] = MAT_SAND,
    ["player/footsteps/sand3.wav"] = MAT_SAND,
    ["player/footsteps/sand4.wav"] = MAT_SAND,
    ["physics/wood/wood_box_footstep1.wav"] = MAT_WOODPANEL,
    ["physics/wood/wood_box_footstep2.wav"] = MAT_WOODPANEL,
    ["physics/wood/wood_box_footstep3.wav"] = MAT_WOODPANEL,
    ["physics/wood/wood_box_footstep4.wav"] = MAT_WOODPANEL,
    ["player/footsteps/concrete1.wav"] = MAT_CONCRETE,
    ["player/footsteps/concrete2.wav"] = MAT_CONCRETE,
    ["player/footsteps/concrete3.wav"] = MAT_CONCRETE,
    ["player/footsteps/concrete4.wav"] = MAT_CONCRETE
}

GM.FOOTSTEP_LOUNDLESS_LEVEL_ORDER = {}

for key, id in pairs(GM.FOOTSTEP_LOUDNESS) do
    table.insert(GM.FOOTSTEP_LOUNDLESS_LEVEL_ORDER, id)
end

-- sort them from lowest to highest
table.sort(GM.FOOTSTEP_LOUNDLESS_LEVEL_ORDER, function(a, b)
    return GM.FOOTSTEP_LOUDNESS_LEVELS[a] < GM.FOOTSTEP_LOUDNESS_LEVELS[b]
end)

GM.BASE_NOISE_LEVEL = 30
GM.LOUDNESS_PER_VELOCITY = 30 / GetConVar("gc_base_run_speed"):GetInt() -- add 30 loudness when we reach full run speed
GM.CROUCH_LOUDNESS_VELOCITY_AFFECTOR = 0.5 -- multiply loudness increase from velocity by this much when crouch-walking
GM.CROUCH_LOUDNESS_OVERALL_AFFECTOR = 0.5 -- overall multiplier for loudness when crouch-walking
GM.SNEAKWALK_LOUDNESS_VELOCITY_AFFECTOR = 0.7 -- multiply loudness increase from velocity by this much when walking (+walk)
GM.SNEAKWALK_LOUDNESS_OVERALL_AFFTER = 0.5 -- overall multiplier for loudness when walking
GM.MAX_LOUDNESS_FROM_VELOCITY = 25 -- max loudness we can get from velocity
GM.NOISE_PER_KILOGRAM = 1.25
GM.SNEAKWALK_VELOCITY_CUTOFF = 105 -- if the player is walking slower than this, he is considered to be sneak-walking

-- key is surface ID, value is table with sounds, filled automatically
GM.SURFACE_FOOTSTEP_SOUNDS = {}

-- the sounds to play when walking on a surface that does !have a footstep sound registered to it
GM.FALLBACK_FOOTSTEP_SOUND = nil

GM.FOOTSTEP_PITCH_START = 95
GM.FOOTSTEP_PITCH_END = 105

-- Map a precached sound to a material ID.
function GM:RegisterWalkSound(materialID, desiredSound)
    -- local targetList = nil

    if materialID then
        self.SURFACE_FOOTSTEP_SOUNDS[materialID] = desiredSound
        -- targetList = self.SURFACE_FOOTSTEP_SOUNDS[materialID]
    else
        self.FALLBACK_FOOTSTEP_SOUND = desiredSound
    end
    -- table.insert(targetList, desiredSounds)
end

GM:RegisterWalkSound(nil, "GC_FALLBACK_WALK_SOUNDS")
GM:RegisterWalkSound(MAT_CONCRETE, "GC_WALK_CONCRETE")
GM:RegisterWalkSound(MAT_WOOD, "GC_WALK_WOOD")
GM:RegisterWalkSound(MAT_GRASS, "GC_WALK_GRASS")
GM:RegisterWalkSound(MAT_SLOSH, "GC_WALK_SLOSH")
GM:RegisterWalkSound(MAT_METAL, "GC_WALK_METAL")
GM:RegisterWalkSound(MAT_LADDER, "GC_WALK_LADDER")
GM:RegisterWalkSound(MAT_GRAVEL, "GC_WALK_GRAVEL")
GM:RegisterWalkSound(MAT_SNOW, "GC_WALK_SNOW")
GM:RegisterWalkSound(MAT_DIRT, "GC_WALK_DIRT")
GM:RegisterWalkSound(MAT_WOODPANEL, "GC_WALK_WOODPANEL")

function GM:GetWalkSound(materialID, loudnessLevel)
    local sound = self.SURFACE_FOOTSTEP_SOUNDS[materialID]

    if sound then
        return sound
    end

    return self.FALLBACK_FOOTSTEP_SOUND
end

function GM:PlayerFootstep(ply, position, foot, snd, volume, filter)
    if !ply:Alive() then
        return
    end

    local materialID = MAT_CONCRETE
    if self.DEFAULT_FOOTSTEP_TO_MATERIAL[snd] != nil then
        materialID = self.DEFAULT_FOOTSTEP_TO_MATERIAL[snd]
    end
    local loudnessID, noiseLevel = self:GetLoudnessLevel(ply)
    local stepSound = self:GetWalkSound(materialID, loudnessID)

    -- if SERVER then
    ply:EmitSound(stepSound, self.FOOTSTEP_LOUDNESS_LEVELS[loudnessID], math.random(self.FOOTSTEP_PITCH_START, self.FOOTSTEP_PITCH_END), self.FOOTSTEP_VOLUME_LEVELS[loudnessID], CHAN_BODY)
    -- elseif SERVER then
    --     sound.Play(stepSound, ply:GetPos(), self.FOOTSTEP_LOUDNESS_LEVELS[loudnessID], math.random(self.FOOTSTEP_PITCH_START, self.FOOTSTEP_PITCH_END), self.FOOTSTEP_VOLUME_LEVELS[loudnessID])
    -- end

    -- suppress default sounds
    return true
end

function GM:GetLoudnessLevel(ply)
    local noiseLevel = self.BASE_NOISE_LEVEL

    if CLIENT then -- on the client we will re-calculate the weight, because it's more accurate that way
        noiseLevel = noiseLevel + ply:CalculateWeight() * self.NOISE_PER_KILOGRAM
    else -- on the server we will use the pre-calculated weight value, because the server knows more than the client about his weight values
        noiseLevel = noiseLevel + ply.weight * self.NOISE_PER_KILOGRAM
    end

    local crouching = ply:Crouching()
    local velLength = ply:GetVelocity():Length()

    local sneakWalking = velLength <= self.SNEAKWALK_VELOCITY_CUTOFF

    local overallAffector = 1
    local velocityAffector = 1

    if crouching then
        overallAffector = self.CROUCH_LOUDNESS_OVERALL_AFFECTOR
        velocityAffector = self.CROUCH_LOUDNESS_VELOCITY_AFFECTOR
    elseif sneakWalking then
        overallAffector = self.SNEAKWALK_LOUDNESS_OVERALL_AFFTER
        velocityAffector = self.SNEAKWALK_LOUDNESS_VELOCITY_AFFECTOR
    end

    noiseLevel = noiseLevel + math.min(velLength * self.LOUDNESS_PER_VELOCITY, self.MAX_LOUDNESS_FROM_VELOCITY) * velocityAffector
    noiseLevel = noiseLevel * overallAffector

    local mostValidLoudnessLevel = self.FOOTSTEP_LOUDNESS.ULTRA_LOW

    for key, loudnessID in ipairs(self.FOOTSTEP_LOUNDLESS_LEVEL_ORDER) do
        if noiseLevel > self.LOUDNESS_LEVELS[loudnessID] then -- if the loudness value is greater than this one
            mostValidLoudnessLevel = loudnessID
        end
    end

    return mostValidLoudnessLevel, noiseLevel
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetWeightFootstepNoiseAffector(weight)
    weight = weight or self.weight or self:CalculateWeight()

    return weight * GAMEMODE.NOISE_PER_KILOGRAM
end