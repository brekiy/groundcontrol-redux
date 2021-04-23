AddCSLuaFile()

GM.MAX_STAMINA = 100
GM.INITIAL_STAMINA = 100
GM.STAMINA_DRAIN_PER_TICK = 1 -- how much stamina we lose every drain tick
GM.PostDrainStaminaRegenTickDelay = 1 -- we have to wait this much after our stamina being drained
GM.StaminaRegenAmount = 1 -- how much stamina we regen when we're in idle state
GM.MinStaminaFromSprinting = 20 -- how far our stamina will drop from sprinting
GM.INJURED_STAMINA_REDUCTION = 70 -- we lose this much max stamina by the time our health reaches 0

local PLAYER = FindMetaTable("Player")

function PLAYER:SetStamina(amount, dontSend)
    if SERVER then
        self.stamina = math.Clamp(amount, 0, self:GetMaxStamina())
    else
        self.stamina = amount
    end

    if SERVER and !dontSend then
        self:SendStamina()
    end
end

function PLAYER:ResetStaminaData()
    self:SetStamina(GAMEMODE.INITIAL_STAMINA)
    self.staminaDrainTime = 0
    self.staminaRegenTime = 0
    self.staminaDrainMultiplier = 1
end

function PLAYER:SendStamina()
    net.Start("GC_STAMINA")
    net.WriteFloat(self.stamina)
    net.Send(self)
end

function PLAYER:GetStaminaRunSpeedModifier()
    local difference = GetConVar("gc_stamina_run_impact_level"):GetInt() - self.stamina
    local runSpeedImpact = math.max(difference, 0)

    return runSpeedImpact * GetConVar("gc_stamina_run_impact"):GetFloat()
end

function PLAYER:GetMaxStaminaDecreaseFromHealth()
    return GAMEMODE.INJURED_STAMINA_REDUCTION - self:Health() / self:GetMaxHealth() * GAMEMODE.INJURED_STAMINA_REDUCTION
end

function PLAYER:GetMaxStamina()
    return GAMEMODE.MAX_STAMINA - self:GetMaxStaminaDecreaseFromHealth()
end
