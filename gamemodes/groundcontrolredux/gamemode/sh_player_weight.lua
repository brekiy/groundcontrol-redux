AddCSLuaFile()

-- weight is in kilograms
GM.MaxWeight = 40
-- factor to reduce runspeed by
GM.MaxSpeedDecrease = 0.05
-- Difference between "max weight" (since there's no limit to how much your dude can carry right now) and min runspeed impact threshold
GM.MaxSpeedDecreaseWeightDelta = GM.MaxWeight - GetConVar("gc_weight_min_level_speed_decrease"):GetFloat()

local PLAYER = FindMetaTable("Player")

function PLAYER:resetWeightData()
    self.weight = 0
end

function GM:calculateImaginaryWeight(ply, withoutWeight, withWeight)
    withoutWeight = withoutWeight or 0
    withWeight = withWeight or 0

    local totalWeight = 0 - withoutWeight + withWeight

    local primaryData = ply:getDesiredPrimaryWeapon()
    local secondaryData = ply:getDesiredSecondaryWeapon()
    local tertiaryData = ply:getDesiredTertiaryWeapon()

    local primaryMags = ply:getDesiredPrimaryMags()
    local secondaryMags = ply:getDesiredSecondaryMags()

    primaryMags = ply:adjustMagCount(primaryData, primaryMags)
    secondaryMags = ply:adjustMagCount(secondaryData, secondaryMags)

    if primaryData then
        totalWeight = totalWeight + primaryData.weight -- take weapon weight into account
        totalWeight = totalWeight + self:getAmmoWeight(primaryData.weaponObject.Primary.Ammo, primaryData.weaponObject.Primary.ClipSize * (primaryMags + 1)) -- take ammo in weapon weight into account
    end

    if secondaryData then
        totalWeight = totalWeight + (secondaryData.weight or 0)
        totalWeight = totalWeight + self:getAmmoWeight(secondaryData.weaponObject.Primary.Ammo, secondaryData.weaponObject.Primary.ClipSize * (secondaryMags + 1))
    end

    if tertiaryData then
        totalWeight = totalWeight + (tertiaryData.weight or 0)
    end

    -- tally up other equipment weight
    totalWeight = totalWeight + self:getBandageWeight(ply:getDesiredBandageCount())
    totalWeight = totalWeight + self:getSpareAmmoWeight(ply:getDesiredAmmoCount())
    totalWeight = totalWeight + self:getArmorWeight("vest", ply:getDesiredVest())
    totalWeight = totalWeight + self:getArmorWeight("helmet", ply:getDesiredHelmet())

    return totalWeight
end

function PLAYER:calculateWeight(withoutWeight, withWeight)
    withoutWeight = withoutWeight or 0
    withWeight = withWeight or 0

    local totalWeight = 0 - withoutWeight + withWeight
    totalWeight = totalWeight + GAMEMODE:getBandageWeight(self.bandages)
    totalWeight = totalWeight + GAMEMODE:getArmorWeight("vest", self:getDesiredVest())
    totalWeight = totalWeight + GAMEMODE:getArmorWeight("helmet", self:getDesiredHelmet())

    for key, weapon in pairs(self:GetWeapons()) do
        -- take weapon weight into account, move conditional check up here to avoid arithmetic error
        local weaponWeight = weapon.weight or 0
        totalWeight = totalWeight + weaponWeight
        -- take ammo weight into account
        totalWeight = totalWeight + GAMEMODE:getAmmoWeight(weapon.Primary.Ammo, weapon:Clip1() + self:GetAmmoCount(weapon.Primary.Ammo))
    end

    for key, data in ipairs(self.gadgets) do
        local baseData = GAMEMODE.GadgetsById[data.id]

        totalWeight = totalWeight + baseData:getWeight(self, data)
    end

    return totalWeight
end

function PLAYER:getJumpStaminaDrain(weight)
    weight = weight or self.weight
    return GAMEMODE.StaminaPerJump + math.max(0, -GAMEMODE.StaminaPerJumpBaselineNoWeightPenalty + weight * GAMEMODE.StaminaPerJumpWeightIncrease)
end

function PLAYER:getMovementSpeedWeightAffector(weight)
    local delta = math.max(weight - GetConVar("gc_weight_min_level_speed_decrease"):GetFloat(), 0) / GAMEMODE.MaxSpeedDecreaseWeightDelta * GAMEMODE.MaxSpeedDecrease

    return delta
end

function PLAYER:getStaminaDrainWeightModifier(weight)
    weight = weight or self.weight
    return 1 + (weight / GAMEMODE.MaxWeight) * GetConVar("gc_weight_stamina_drain"):GetFloat()
end

function PLAYER:setWeight(weight)
    self.weight = weight
end

function PLAYER:canCarryWeight(desiredWeight)
    return desiredWeight < GAMEMODE.MaxWeight
end

function PLAYER:getWeightRunSpeedModifier()
    local difference = self.weight - GetConVar("gc_weight_min_level_speed_decrease"):GetFloat()
    local runSpeedImpact = math.max(difference, 0)
    return runSpeedImpact * GetConVar("gc_weight_sprint_penalty"):GetFloat()
end
