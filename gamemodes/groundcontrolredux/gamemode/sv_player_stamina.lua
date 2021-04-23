include("sh_player_stamina.lua")

local PLAYER = FindMetaTable("Player")

function PLAYER:DrainStamina()
    if self.stamina > GAMEMODE.MinStaminaFromSprinting then
        local drainAmount = GAMEMODE.STAMINA_DRAIN_PER_TICK * self:GetStaminaDrainAdrenalineModifier() * self:GetStaminaDrainWeightModifier() * self.staminaDrainMultiplier

        self:SetStamina(math.max(self.stamina - drainAmount, GAMEMODE.MinStaminaFromSprinting), true)
        self.staminaDrainTime = CurTime() + GetConVar("gc_stamina_drain_time"):GetFloat()
        self:SendStamina()
    end

    self.staminaRegenTime = math.max(self.staminaRegenTime, CurTime() + GAMEMODE.PostDrainStaminaRegenTickDelay)
end

function PLAYER:RegenStamina()
    local regenAmount = GAMEMODE.STAMINA_DRAIN_PER_TICK * self:GetStaminaRegenAdrenalineModifier()

    self:SetStamina(self.stamina + regenAmount)
    self.staminaRegenTime = CurTime() + GetConVar("gc_stamina_regen_time"):GetFloat()
end

function PLAYER:DelayStaminaRegen(time)
    self.staminaRegenTime = math.max(self.staminaRegenTime, CurTime() + time)
end