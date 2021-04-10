include("sh_player_stamina.lua")

local PLAYER = FindMetaTable("Player")

function PLAYER:drainStamina()
    if self.stamina > GAMEMODE.MinStaminaFromSprinting then
        local drainAmount = GAMEMODE.StaminaDrainPerTick * self:getStaminaDrainAdrenalineModifier() * self:getStaminaDrainWeightModifier() * self.staminaDrainMultiplier

        self:setStamina(math.max(self.stamina - drainAmount, GAMEMODE.MinStaminaFromSprinting), true)
        self.staminaDrainTime = CurTime() + GetConVar("gc_stamina_drain_time"):GetFloat()
        self:sendStamina()
    end

    self.staminaRegenTime = math.max(self.staminaRegenTime, CurTime() + GAMEMODE.PostDrainStaminaRegenTickDelay)
end

function PLAYER:regenStamina()
    local regenAmount = GAMEMODE.StaminaDrainPerTick * self:getStaminaRegenAdrenalineModifier()

    self:setStamina(self.stamina + regenAmount)
    self.staminaRegenTime = CurTime() + GetConVar("gc_stamina_regen_time"):GetFloat()
end

function PLAYER:delayStaminaRegen(time)
    self.staminaRegenTime = math.max(self.staminaRegenTime, CurTime() + time)
end