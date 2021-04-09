AddCSLuaFile()
AddCSLuaFile("cl_loadout.lua")

GM.DefaultPrimaryIndex = 1 -- default indexes for primary and secondary weapons in case we fail to get the number
GM.DefaultSecondaryIndex = 1
GM.DefaultTertiaryIndex = 1

GM.DefaultPrimaryMagCount = 3
GM.DefaultSecondaryMagCount = 3

GM.DefaultSpareAmmoCount = 0
GM.MaxSpareAmmoCount = 400

GM.MaxPrimaryMags = 5
GM.MaxSecondaryMags = 5

GM.DefaultPoints = 70

if CLIENT then
    include("cl_loadout.lua")
end

GM.RegisteredWeaponData = {}

GM.PrimaryWeapons = GM.PrimaryWeapons or {}
GM.SecondaryWeapons = GM.SecondaryWeapons or {}
GM.TertiaryWeapons = GM.TertiaryWeapons or {}
GM.Calibers = GM.Calibers or {}

BestPrimaryWeapons = BestPrimaryWeapons or {damage = -math.huge, recoil = -math.huge, aimSpread = math.huge, firerate = math.huge, hipSpread = math.huge, spreadPerShot = -math.huge, velocitySensitivity = math.huge, maxSpreadInc = -math.huge, speedDec = math.huge, weight = -math.huge, magWeight = -math.huge, penetrationValue = -math.huge}
BestSecondaryWeapons = BestSecondaryWeapons or {damage = -math.huge, recoil = -math.huge, aimSpread = math.huge, firerate = math.huge, hipSpread = math.huge, spreadPerShot = -math.huge, velocitySensitivity = math.huge, maxSpreadInc = -math.huge, speedDec = math.huge, weight = -math.huge, magWeight = -math.huge, penetrationValue = -math.huge}

-- Weapon packs
include("sh_weps_base_cw.lua")
include("sh_weps_khris.lua")
include("sh_weps_misc.lua")

-- Ammo definitions
include ("sh_weps_calibers.lua")

local PLAYER = FindMetaTable("Player")

function PLAYER:getDesiredPrimaryMags()
    return math.Clamp(self:GetInfoNum("gc_primary_mags", GAMEMODE.DefaultPrimaryMagCount), 1, GAMEMODE.MaxPrimaryMags)
end

function PLAYER:getDesiredSecondaryMags()
    return math.Clamp(self:GetInfoNum("gc_secondary_mags", GAMEMODE.DefaultSecondaryMagCount), 1, GAMEMODE.MaxSecondaryMags)
end

function PLAYER:getDesiredPrimaryWeapon()
    local primary = math.Clamp(self:GetInfoNum("gc_primary_weapon", GAMEMODE.DefaultPrimaryIndex), 0, #GAMEMODE.PrimaryWeapons) -- don't go out of bounds
    return GAMEMODE.PrimaryWeapons[primary], primary
end

function PLAYER:getDesiredSecondaryWeapon()
    local secondary = math.Clamp(self:GetInfoNum("gc_secondary_weapon", GAMEMODE.DefaultSecondaryIndex), 0, #GAMEMODE.SecondaryWeapons)
    return GAMEMODE.SecondaryWeapons[secondary], secondary
end

function PLAYER:getDesiredTertiaryWeapon()
    local tertiary = math.Clamp(self:GetInfoNum("gc_tertiary_weapon", GAMEMODE.DefaultTertiaryIndex), 0, #GAMEMODE.TertiaryWeapons)
    return GAMEMODE.TertiaryWeapons[tertiary], tertiary
end

function PLAYER:adjustMagCount(weaponData, desiredMags)
    if !weaponData then
        return 0
    end

    if weaponData.magOverride then
        return weaponData.magOverride
    end

    if weaponData.maxMags then
        desiredMags = math.min(desiredMags, weaponData.maxMags)
    end

    return desiredMags
end

function checkWeaponExists(weaponClassname)
    local storedWep = weapons.GetStored(weaponClassname)
    if !storedWep then print("Attempted to register non-existing weapon " .. weaponClassname) end
    return storedWep
end

function GM:applyWeaponDataToWeaponClass(weaponData, primaryWeapon, slot)
    local wepClass = weapons.GetStored(weaponData.weaponClass)
    wepClass.weight = weaponData.weight -- apply weight to the weapon class
    wepClass.isPrimaryWeapon = primaryWeapon
    wepClass.Slot = slot
    wepClass.penetrationValue = weaponData.penetration
    wepClass.pointCost = weaponData.pointCost

    weaponData.weaponObject = wepClass
    weaponData.processedWeaponObject = weapons.Get(weaponData.weaponClass)
end

function GM:setWeaponWeight(wepClass, weight)
    local wepObj = weapons.GetStored(wepClass)
    wepObj.weight = weight
end

function GM:disableDropsForWeapon(wepClass)
    local wepObj = weapons.GetStored(wepClass)
    wepObj.dropsDisabled = true
end

function GM:registerPrimaryWeapon(weaponData)
    if checkWeaponExists(weaponData.weaponClass) then
        weaponData.id = weaponData.id or weaponData.weaponClass
        self.RegisteredWeaponData[weaponData.id] = weaponData
        self:applyWeaponDataToWeaponClass(weaponData, true, 0)
        self.PrimaryWeapons[#self.PrimaryWeapons + 1] = weaponData
    end
end

function GM:registerSecondaryWeapon(weaponData)
    if checkWeaponExists(weaponData.weaponClass) then
        weaponData.id = weaponData.id or weaponData.weaponClass
        self.RegisteredWeaponData[weaponData.id] = weaponData

        self:applyWeaponDataToWeaponClass(weaponData, false, 1)
        self.SecondaryWeapons[#self.SecondaryWeapons + 1] = weaponData
    end
end

function GM:registerTertiaryWeapon(weaponData)
    if checkWeaponExists(weaponData.weaponClass) then
        weaponData.id = weaponData.id or weaponData.weaponClass
        self.RegisteredWeaponData[weaponData.id] = weaponData

        self:applyWeaponDataToWeaponClass(weaponData, false, 2)
        weapons.GetStored(weaponData.weaponClass).isTertiaryWeapon = true
        self.TertiaryWeapons[#self.TertiaryWeapons + 1] = weaponData
    end
end

--[[
    Sets up an ammo type for the gamemode, assigning a weight and penetration value to it
]]--
function GM:registerCaliber(caliberName, grams, penetration)
    -- 1 grain = 0.06479891 gram
    -- convert grams to kilograms in advance
    local caliberObj = {
        weight = grams / 1000,
        penetration = penetration
    }
    -- kill all attempts at unique capitalization
    self.Calibers[string.lower(caliberName)] = caliberObj
end

function GM:findBestWeapons(lookInto, output)
    for key, weaponData in ipairs(lookInto) do
        local wepObj = weaponData.weaponObject
        -- Handle edge cases where the SWEP creator didn't define this property explicitly
        if !wepObj.Shots then wepObj.Shots = 1 end

        output.damage = math.max(output.damage, wepObj.Damage * wepObj.Shots)
        output.recoil = math.max(output.recoil, wepObj.Recoil)
        output.aimSpread = math.min(output.aimSpread, wepObj.AimSpread)
        output.firerate = math.min(output.firerate, wepObj.FireDelay)
        output.hipSpread = math.min(output.hipSpread, wepObj.HipSpread)
        output.spreadPerShot = math.max(output.spreadPerShot, wepObj.SpreadPerShot)
        output.velocitySensitivity = math.min(output.velocitySensitivity, wepObj.VelocitySensitivity)
        output.maxSpreadInc = math.max(output.maxSpreadInc, wepObj.MaxSpreadInc)
        output.speedDec = math.min(output.speedDec, wepObj.SpeedDec)
        output.weight = math.max(output.weight, wepObj.weight)
        output.penetrationValue = math.max(output.penetrationValue, self:getAmmoPen(wepObj.Primary.Ammo, wepObj.penMod))

        local magWeight = self:getAmmoWeight(wepObj.Primary.Ammo, wepObj.Primary.ClipSize)
        wepObj.magWeight = magWeight

        output.magWeight = math.max(output.magWeight, magWeight)
    end
end

function GM:getAmmoWeight(caliber, roundCount)
    roundCount = roundCount or 1
    return self.Calibers[caliber] and self.Calibers[caliber].weight * roundCount or 0
end

function GM:getAmmoPen(caliber, penMod)
    caliber = string.lower(caliber)
    penMod = penMod or 0
    return self.Calibers[caliber] and self.Calibers[caliber].penetration + penMod or 0
end

-- this function gets called in InitPostEntity for both the client and server, this is where we register a bunch of stuff
function GM:postInitEntity()

    GAMEMODE:registerWepsBaseCW()
    GAMEMODE:registerWepsKhris()
    GAMEMODE:registerWepsMisc()

    -- KNIFE, give it 0 weight and make it undroppable (can't shoot out of hand, can't drop when dying)
    local wepObj = weapons.GetStored(self.KnifeWeaponClass)
    wepObj.weight = 0
    wepObj.dropsDisabled = true
    wepObj.isKnife = true
    wepObj.pointCost = 0

    GAMEMODE:registerCalibers()
    hook.Call("GroundControlPostInitEntity", nil)

    self:findBestWeapons(self.PrimaryWeapons, BestPrimaryWeapons)
    self:findBestWeapons(self.SecondaryWeapons, BestSecondaryWeapons)
    weapons.GetStored("cw_base").AddSafeMode = false -- disable safe firemode
    weapons.GetStored("cw_base").RVBPitchMod = 0.4
    weapons.GetStored("cw_base").RVBYawMod = 0.4
    weapons.GetStored("cw_base").RVBRollMod = 0.4

    if CLIENT then
        self:createMusicObjects()
    end
end