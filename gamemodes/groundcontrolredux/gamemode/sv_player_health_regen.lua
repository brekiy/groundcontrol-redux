local PLAYER = FindMetaTable("Player")

function PLAYER:ResetHealthRegenData()
    self.regenPool = 0
    self.regenDelay = 0
    self.sentHPRegenHint = false

    self:SetStatusEffect("healing", false)
end

function PLAYER:AddHealthRegen(amount)
    self.regenPool = self.regenPool + amount
    self:SetStatusEffect("healing", true)
end

function PLAYER:DelayHealthRegen()
    self.regenDelay = CurTime() + GetConVar("gc_health_regen_time"):GetFloat()
end

function PLAYER:RegenHealth()
    if self:Health() >= GAMEMODE.MAX_HEALTH then
        self.regenPool = 0
        self:SetStatusEffect("healing", false)
        return
    end

    self.regenPool = self.regenPool - 1
    self:SetHealth(self:Health() + 1)
    self:DelayHealthRegen()

    -- if we run out of the regen pool, then notify the player's status effect display that we're !healing anymore
    if self.regenPool == 0 then
        self:SetStatusEffect("healing", false)
    end

    if !self.sentHPRegenHint then
        self:SendTip("HEALTH_REGEN")
    end
end