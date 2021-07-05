AddCSLuaFile()

GM.MIN_BANDAGES = 1
GM.MAX_BANDAGES = 8 -- maximum bandages a player can carry
GM.DEFAULT_BANDAGES = 2 -- how many bandages we should start out with when we first join the server
GM.BANDAGE_WEIGHT = 0.1 -- how much each individual bandage weighs
GM.BANDAGE_DISTANCE = 50 -- distance between us and another player to bandage them

if CLIENT then
    CreateClientConVar("gc_bandages", GM.DEFAULT_BANDAGES, true, true)
end

local PLAYER = FindMetaTable("Player")

local traceData = {}

function PLAYER:getBandageTarget()
    if self.bleeding then -- first and foremost we must take care of our own wounds
        return self
    end

    local target = nil

    traceData.start = self:GetShootPos()
    traceData.endpos = traceData.start + self:GetAimVector() * GAMEMODE.BANDAGE_DISTANCE
    traceData.filter = self

    local trace = util.TraceLine(traceData)
    local ent = trace.Entity


    if IsValid(ent) and ent:IsPlayer() and self:CanBandage(ent) then
        target = ent
    end

    return target
end

function PLAYER:CanBandage(target)
    if !IsValid(target) or !self:Alive() or target:Team() ~= self:Team() or self.bandages <= 0 then
        return false
    end

    local wep = self:GetActiveWeapon()

    if IsValid(wep) and CurTime() < wep.GlobalDelay then
        return false
    end

    if SERVER then
        if !target.bleeding and !target.crippledArm then
            return false
        end
    elseif CLIENT then
        if !target:HasStatusEffect("bleeding") and !target:hasStatusEffect("crippled_arm") then
            return false
        end
    end

    return true
end

function PLAYER:SetBleeding(bleeding)
    self.bleeding = bleeding

    if SERVER then
        self:SendBleedState()
        if !bleeding then
            self.bleedInflictor = nil
            if (self.regenPool and self.regenPool > 0) then
                self:SendStatusEffect("healing", true)
            end
        end
    end
end

function PLAYER:SetBandages(bandages)
    bandages = bandages or GAMEMODE.DEFAULT_BANDAGES
    self.bandages = bandages

    if SERVER then
        self:sendBandages()
    end
end

function PLAYER:ResetBleedData()
    self:SetBleeding(false)
    self.bleedInflictor = nil
    self.bleedHealthDrainTime = 0
    self.healAmount = 0
    self.healAmountAlly = 0
end

function PLAYER:GetDesiredBandageCount()
    if GAMEMODE.curGametype.GetDesiredBandageCount then
        local count = GAMEMODE.curGametype:GetDesiredBandageCount(self)

        if count then
            return count
        end
    end

    return math.Clamp(self:GetInfoNum("gc_bandages", GAMEMODE.DEFAULT_BANDAGES), GAMEMODE.MIN_BANDAGES, GAMEMODE.MAX_BANDAGES)
end

function GM:GetBandageWeight(bandageCount)
    bandageCount = bandageCount or 0
    return bandageCount * self.BANDAGE_WEIGHT
end