AddCSLuaFile()

-- adrenaline and suppression is the same thing in Ground Control
-- gameplay-wise it increases when enemy bullets hit nearby surfaces,
-- it's effects are increased run speed and hip fire accuracy at the
-- expense of a shaking view when taking aim and lower aim accuracy

-- max additional units/sec we can achieve from adrenaline
GM.MaxSpeedIncreaseFromAdrenaline = 0.1
-- our stamina drain decrease from sprinting will be multiplied by this value depending on our adrenaline level
-- (ie. with this value at 0.5: 100% adrenaline = 50% less stamina drained from sprinting, 0% adrenaline = 0% less stamina drain)
GM.AdrenalineStaminaDrainModifier = 0.5
-- same as with draining, but for regeneration
GM.AdrenalineStaminaRegenModifier = 0.1
-- when adrenaline reaches 100%, our hip fire accuracy should increase by this much; this value should be negative to increase hip fire accuracy
GM.HipFireAccuracyAdrenalineModifier = -0.3
-- when adrenaline reaches 100%, our aim accuracy should decrease by this much; this value should be positive to increase aim fire spread
GM.AimFireAccuracyAdrenalineModifier = 0.3

local PLAYER = FindMetaTable("Player")

function PLAYER:SetAdrenaline(amount)
    self.adrenaline = math.Clamp(amount, 0, 1)

    if SERVER then
        net.Start("GC_ADRENALINE")
        net.WriteFloat(self.adrenaline)
        net.Send(self)
    end
end

function PLAYER:CanSuppress(suppressedBy)
    return self:Alive() and self:Team() != suppressedBy:Team()
end

function PLAYER:ResetAdrenalineData()
    if SERVER then
        self:SetAdrenaline(0)
        self.adrenalineDuration = 0
        self.adrenalineSpeedHold = 0
        self.adrenalineIncreaseSpeed = 0
        self.adrenalineIncreaseMultiplier = 1
        self.maxAdrenalineDurationMultiplier = 1
    end

    self.adrenaline = 0
end

function PLAYER:GetRunSpeedAdrenalineModifier()
    -- return self.adrenaline * GAMEMODE.MaxSpeedIncreaseFromAdrenaline
    return self.adrenaline * GetConVar("gc_adrenaline_maxspeed_increase"):GetFloat()
end

function PLAYER:GetStaminaDrainAdrenalineModifier()
    -- return 1 - self.adrenaline * GAMEMODE.AdrenalineStaminaDrainModifier
    return 1 - self.adrenaline * GetConVar("gc_adrenaline_stamina_drain_modifier"):GetFloat()
end

function PLAYER:GetStaminaRegenAdrenalineModifier()
    -- return 1 + self.adrenaline * GAMEMODE.AdrenalineStaminaRegenModifier
    return 1 + self.adrenaline * GetConVar("gc_adrenaline_stamina_regen_modifier"):GetFloat()
end

function PLAYER:GetAdrenalineAccuracyModifiers()
    return 1 + GAMEMODE.HipFireAccuracyAdrenalineModifier * self.adrenaline, 1 + GAMEMODE.AimFireAccuracyAdrenalineModifier
end

AddCSLuaFile("cl_player_adrenaline.lua")