AddCSLuaFile()

-- weight is in kilograms
GM.MAX_WEIGHT = 40
-- factor to reduce runspeed by
GM.MaxSpeedDecrease = 0.05
-- Difference between "max weight" (since there's no limit to how much your dude can carry right now) and min runspeed impact threshold
GM.MaxSpeedDecreaseWeightDelta = GM.MAX_WEIGHT - GetConVar("gc_weight_min_level_speed_decrease"):GetFloat()

local PLAYER = FindMetaTable("Player")

function PLAYER:ResetWeightData()
    self.weight = 0
end

function GM:CalculateImaginaryWeight(ply, withoutWeight, withWeight)
    withoutWeight = withoutWeight or 0
    withWeight = withWeight or 0

    local totalWeight = 0 - withoutWeight + withWeight

    local primaryData = ply:GetDesiredPrimaryWeapon()
    local secondaryData = ply:GetDesiredSecondaryWeapon()
    local tertiaryData = ply:GetDesiredTertiaryWeapon()

    local primaryMags = ply:GetDesiredPrimaryMags()
    local secondaryMags = ply:GetDesiredSecondaryMags()

    primaryMags = ply:AdjustMagCount(primaryData, primaryMags)
    secondaryMags = ply:AdjustMagCount(secondaryData, secondaryMags)

    if primaryData then
        totalWeight = totalWeight + primaryData.weight -- take weapon weight into account
        totalWeight = totalWeight + self:GetAmmoWeight(primaryData.weaponObject.Primary.Ammo, primaryData.weaponObject.Primary.ClipSize * (primaryMags + 1)) -- take ammo in weapon weight into account
    end

    if secondaryData then
        totalWeight = totalWeight + (secondaryData.weight or 0)
        totalWeight = totalWeight + self:GetAmmoWeight(secondaryData.weaponObject.Primary.Ammo, secondaryData.weaponObject.Primary.ClipSize * (secondaryMags + 1))
    end

    if tertiaryData then
        totalWeight = totalWeight + (tertiaryData.weight or 0)
    end

    -- tally up other equipment weight
    totalWeight = totalWeight + self:GetBandageWeight(ply:GetDesiredBandageCount())
    totalWeight = totalWeight + self:GetSpareAmmoWeight(ply:GetDesiredAmmoCount())
    totalWeight = totalWeight + self:GetArmorWeight("vest", ply:GetDesiredVest())
    totalWeight = totalWeight + self:GetArmorWeight("helmet", ply:GetDesiredHelmet())

    return totalWeight
end

function PLAYER:CalculateWeight(withoutWeight, withWeight)
    withoutWeight = withoutWeight or 0
    withWeight = withWeight or 0

    local totalWeight = 0 - withoutWeight + withWeight
    totalWeight = totalWeight + GAMEMODE:GetArmorWeight("vest", self:GetDesiredVest())
    totalWeight = totalWeight + GAMEMODE:GetArmorWeight("helmet", self:GetDesiredHelmet())

    for key, weapon in pairs(self:GetWeapons()) do
        -- take weapon weight into account, move conditional check up here to avoid arithmetic error
        local weaponWeight = weapon.weight or 0
        totalWeight = totalWeight + weaponWeight
        -- take ammo weight into account
        totalWeight = totalWeight + GAMEMODE:GetAmmoWeight(weapon.Primary.Ammo, weapon:Clip1() + self:GetAmmoCount(weapon.Primary.Ammo))
    end

    if !self:IsBot() then
        totalWeight = totalWeight + GAMEMODE:GetBandageWeight(self.bandages)
        if self.gadgets then
            for key, data in ipairs(self.gadgets) do
                local baseData = GAMEMODE.GadgetsById[data.id]
                totalWeight = totalWeight + baseData:getWeight(self, data)
            end
        end
    end

    return totalWeight
end

function PLAYER:GetJumpStaminaDrain(weight)
    weight = weight or self.weight
    return GAMEMODE.StaminaPerJump + math.max(0, -GAMEMODE.StaminaPerJumpBaselineNoWeightPenalty + weight * GAMEMODE.StaminaPerJumpWeightIncrease)
end

function PLAYER:GetMovementSpeedWeightAffector(weight)
    local delta = math.max(weight - GetConVar("gc_weight_min_level_speed_decrease"):GetFloat(), 0) / GAMEMODE.MaxSpeedDecreaseWeightDelta * GAMEMODE.MaxSpeedDecrease

    return delta
end

function PLAYER:GetStaminaDrainWeightModifier(weight)
    weight = weight or self.weight
    return 1 + (weight / GAMEMODE.MAX_WEIGHT) * GetConVar("gc_weight_stamina_drain"):GetFloat()
end

function PLAYER:SetWeight(weight)
    self.weight = weight
end

function PLAYER:CanCarryWeight(desiredWeight)
    return desiredWeight < GAMEMODE.MAX_WEIGHT
end

function PLAYER:GetWeightRunSpeedModifier()
    local difference = self.weight - GetConVar("gc_weight_min_level_speed_decrease"):GetFloat()
    local runSpeedImpact = math.max(difference, 0)
    return runSpeedImpact * GetConVar("gc_weight_sprint_penalty"):GetFloat()
end
