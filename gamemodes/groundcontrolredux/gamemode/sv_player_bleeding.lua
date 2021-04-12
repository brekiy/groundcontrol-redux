include("sh_player_bleeding.lua")

GM.BandageTime = 2.3


local PLAYER = FindMetaTable("Player")

function PLAYER:shouldBleed()
    return CurTime() >= self.bleedHealthDrainTime
end

function PLAYER:bleed(silentBleed)
    self:SetHealth(self:Health() - GetConVar("gc_bleed_hp_lost_per_tick"):GetFloat())
    self:delayBleed()
    self:postBleed()

    if !silentBleed then
        self:EmitSound("GC_BLEED_SOUND")
    end
end

function PLAYER:delayBleed(time)
    time = time or GetConVar("gc_bleed_time"):GetFloat()
    self.bleedHealthDrainTime = CurTime() + time
end

function PLAYER:postBleed()
    if self:Health() <= 0 then -- if we have no health left after bleeding, we die
        self:Kill()

        if IsValid(self.bleedInflictor) then -- reward whoever caused us to bleed
            self.bleedInflictor:addCurrency(GAMEMODE.CashPerKill, GAMEMODE.ExpPerKill, "BLEED_OUT_KILL", ply)
            self.bleedInflictor = nil
        end
    end
end

function PLAYER:startBleeding(bleedInflictor)
    self:delayBleed()

    if bleedInflictor then
        self.bleedInflictor = bleedInflictor -- the person that caused us to bleed
    end

    self:setBleeding(true)
end

function PLAYER:sendBleedState()
    net.Start("GC_BLEEDSTATE")
    net.WriteBool(self.bleeding)
    net.Send(self)
end

function PLAYER:attemptBandage()
    if !self:Alive() then
        return
    end

    local target = self:getBandageTarget()

    if self:canBandage(target) then
        target:bandage(self)
    end
end

function PLAYER:useBandage()
    self.bandages = self.bandages - 1
end

function PLAYER:bandage(bandagedBy)
    bandagedBy = bandagedBy or self

    bandagedBy:useBandage()
    bandagedBy:EmitSound("GC_BANDAGE_SOUND")
    bandagedBy:sendBandages()
    bandagedBy:calculateWeight()

    local wep = bandagedBy:GetActiveWeapon()

    if IsValid(wep) then
        wep:setGlobalDelay(GAMEMODE.BandageTime + 0.3, true, CW_ACTION, GAMEMODE.BandageTime)
    end

    self:setBleeding(false)

    if bandagedBy != self then
        bandagedBy:addCurrency(GAMEMODE.CashPerBandage, GAMEMODE.ExpPerBandage, "TEAMMATE_BANDAGED")
        GAMEMODE:trackRoundMVP(bandagedBy, "bandaging", 1)
    end

    self:restoreHealth(bandagedBy.healAmount)
end

function PLAYER:sendBandages()
    net.Start("GC_BANDAGES")
    net.WriteInt(self.bandages, 8)
    net.Send(self)
end

concommand.Add("gc_bandage", function(ply, com, args)
    ply:attemptBandage()
end)
