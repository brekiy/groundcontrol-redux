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
    local plyTrace = util.GetPlayerTrace(self, Vector(0, 0, -1))
    util.Decal("Blood", plyTrace.start, plyTrace.endpos, self)
end

function PLAYER:delayBleed(time)
    time = time or GetConVar("gc_bleed_time"):GetFloat()
    self.bleedHealthDrainTime = CurTime() + time
end

function PLAYER:postBleed()
    if self:Health() <= 0 then -- if we have no health left after bleeding, we die
        self:Kill()

        if IsValid(self.bleedInflictor) then -- reward whoever caused us to bleed
            self.bleedInflictor:AddCurrency("BLEED_OUT_KILL", self)
            self.bleedInflictor:AddFrags(1)
            GAMEMODE:TrackRoundMVP(self.bleedInflictor, "kills", 1)
            self.bleedInflictor = nil
        end
    end
end

function PLAYER:startBleeding(bleedInflictor)
    self:delayBleed()

    if bleedInflictor then
        self.bleedInflictor = bleedInflictor -- the person that caused us to bleed
    end

    self:SetBleeding(true)
end

function PLAYER:SendBleedState()
    net.Start("GC_BLEEDSTATE")
    net.WriteBool(self.bleeding)
    net.Send(self)
end

function PLAYER:attemptBandage()
    if !self:Alive() then
        return
    end

    local target = self:getBandageTarget()

    if self:CanBandage(target) then
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
    bandagedBy:CalculateWeight()

    local wep = bandagedBy:GetActiveWeapon()

    if IsValid(wep) then
        wep:setGlobalDelay(GAMEMODE.BandageTime + 0.3, true, CW_ACTION, GAMEMODE.BandageTime)
    end
    local wasBleeding = self.bleeding
    self:SetBleeding(false)

    if bandagedBy != self then
        if bandagedBy.canUncrippleLimbs and self:uncrippleArm() then
            bandagedBy:addCurrency(GAMEMODE.CashPerUncripple, GAMEMODE.ExpPerUncripple, "TEAMMATE_UNCRIPPLED")
        end

        bandagedBy:AddCurrency("TEAMMATE_BANDAGED")
        GAMEMODE:TrackRoundMVP(bandagedBy, "bandaging", 1)
        if wasBleeding then
            self:restoreHealth(bandagedBy.healAmountAlly)
        end
    else
        self:restoreHealth(bandagedBy.healAmount)
    end
end

function PLAYER:sendBandages()
    net.Start("GC_BANDAGES")
    net.WriteInt(self.bandages, 8)
    net.Send(self)
end

concommand.Add("gc_bandage", function(ply, com, args)
    ply:attemptBandage()
end)
