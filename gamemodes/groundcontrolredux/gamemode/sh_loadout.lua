AddCSLuaFile()
AddCSLuaFile("cl_loadout.lua")

GM.DefaultPrimaryIndex = 1 -- default indexes for primary and secondary weapons in case we fail to get the number
GM.DefaultSecondaryIndex = 1
GM.DefaultTertiaryIndex = 1

GM.DefaultPrimaryMagCount = 3
GM.DefaultSecondaryMagCount = 3

GM.DefaultSpareAmmoCount = 0

GM.MaxPrimaryMags = 5
GM.MaxSecondaryMags = 5
GM.RemoveAttachments = {"am_ultramegamatchammo", "md_m203", "md_cmag_556_official"}

IncludeDir("weaponsets", "THIRDPARTY")
IncludeDir("weaponsets", "WORKSHOP")

if CLIENT then
    include("cl_loadout.lua")
end

GM.RegisteredWeaponData = {}

GM.PrimaryWeapons = GM.PrimaryWeapons or {}
GM.SecondaryWeapons = GM.SecondaryWeapons or {}
GM.TertiaryWeapons = GM.TertiaryWeapons or {}
GM.Calibers = GM.Calibers or {}
GM.CaliberAliases = GM.CaliberAliases or {}

BestPrimaryWeapons = BestPrimaryWeapons or {damage = -math.huge, recoil = -math.huge, aimSpread = math.huge, firerate = math.huge, hipSpread = math.huge, spreadPerShot = -math.huge, velocitySensitivity = math.huge, maxSpreadInc = -math.huge, speedDec = math.huge, weight = -math.huge, magWeight = -math.huge, penetrationValue = -math.huge}
BestSecondaryWeapons = BestSecondaryWeapons or {damage = -math.huge, recoil = -math.huge, aimSpread = math.huge, firerate = math.huge, hipSpread = math.huge, spreadPerShot = -math.huge, velocitySensitivity = math.huge, maxSpreadInc = -math.huge, speedDec = math.huge, weight = -math.huge, magWeight = -math.huge, penetrationValue = -math.huge}

local PLAYER = FindMetaTable("Player")

function PLAYER:GetDesiredPrimaryMags()
    return math.Clamp(self:GetInfoNum("gc_primary_mags", GAMEMODE.DefaultPrimaryMagCount), 1, GAMEMODE.MaxPrimaryMags)
end

function PLAYER:GetDesiredSecondaryMags()
    return math.Clamp(self:GetInfoNum("gc_secondary_mags", GAMEMODE.DefaultSecondaryMagCount), 1, GAMEMODE.MaxSecondaryMags)
end

function PLAYER:GetDesiredPrimaryWeapon()
    local primary = math.Clamp(self:GetInfoNum("gc_primary_weapon", GAMEMODE.DefaultPrimaryIndex), 0, #GAMEMODE.PrimaryWeapons) -- don't go out of bounds
    return GAMEMODE.PrimaryWeapons[primary], primary
end

function PLAYER:GetDesiredSecondaryWeapon()
    local secondary = math.Clamp(self:GetInfoNum("gc_secondary_weapon", GAMEMODE.DefaultSecondaryIndex), 0, #GAMEMODE.SecondaryWeapons)
    return GAMEMODE.SecondaryWeapons[secondary], secondary
end

function PLAYER:GetDesiredTertiaryWeapon()
    local tertiary = math.Clamp(self:GetInfoNum("gc_tertiary_weapon", GAMEMODE.DefaultTertiaryIndex), 0, #GAMEMODE.TertiaryWeapons)
    return GAMEMODE.TertiaryWeapons[tertiary], tertiary
end

function PLAYER:AdjustMagCount(weaponData, desiredMags)
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
    if !storedWep then print("Couldn't register weapon " .. weaponClassname) end
    return storedWep
end

-- Should work just fine for TFA and ArcCW
function GM:ApplyWeaponDataToWeaponClass(weaponData, primaryWeapon, slot)
    local wepClass = weapons.GetStored(weaponData.weaponClass)

    wepClass.weight = weaponData.weight -- apply weight to the weapon class
    wepClass.isPrimaryWeapon = primaryWeapon
    wepClass.Slot = slot
    wepClass.penetrationValue = weaponData.penetration
    wepClass.pointCost = weaponData.pointCost
    wepClass.penMod = weaponData.penMod
    -- Let people rebalance stuff as they want for this gamemode
    -- if weaponData.Base == "tfa_gun_base" then
    --     wepClass.Damage = self:parseTFAWeapon(weaponData)
    -- elseif weaponData.Base == "arccw_base" then
    --     wepClass.Damage = self:parseArcCWWeapon(weaponData)
    -- else
    wepClass.Damage = weaponData.damage or wepClass.Damage
    -- end

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

function GM:RegisterPrimaryWeapon(weaponData)
    if checkWeaponExists(weaponData.weaponClass) then
        weaponData.id = weaponData.id or weaponData.weaponClass
        self.RegisteredWeaponData[weaponData.id] = weaponData
        self:ApplyWeaponDataToWeaponClass(weaponData, true, 0)
        self.PrimaryWeapons[#self.PrimaryWeapons + 1] = weaponData
    end
end

function GM:RegisterSecondaryWeapon(weaponData)
    if checkWeaponExists(weaponData.weaponClass) then
        weaponData.id = weaponData.id or weaponData.weaponClass
        self.RegisteredWeaponData[weaponData.id] = weaponData
        self:ApplyWeaponDataToWeaponClass(weaponData, false, 1)
        self.SecondaryWeapons[#self.SecondaryWeapons + 1] = weaponData
    end
end

function GM:RegisterTertiaryWeapon(weaponData)
    if checkWeaponExists(weaponData.weaponClass) then
        weaponData.id = weaponData.id or weaponData.weaponClass
        self.RegisteredWeaponData[weaponData.id] = weaponData
        self:ApplyWeaponDataToWeaponClass(weaponData, false, 2)
        weapons.GetStored(weaponData.weaponClass).isTertiaryWeapon = true
        self.TertiaryWeapons[#self.TertiaryWeapons + 1] = weaponData
    end
end

--[[
    Sets up an ammo type for the gamemode, assigning a weight and penetration value to it
]]--
function GM:registerCaliber(caliberName, grams, penetration, aliases)
    -- 1 grain = 0.06479891 gram
    -- convert grams to kilograms in advance
    local caliberObj = {
        weight = grams / 1000,
        penetration = penetration
    }
    -- kill all attempts at unique capitalization
    self.Calibers[string.lower(caliberName)] = caliberObj

    -- further kill different naming conventions
    if aliases then
        for k, alias in ipairs(aliases) do
            self.CaliberAliases[string.lower(alias)] = string.lower(caliberName)
        end
    end
end

function GM:parseArcCWWeapon(data)
    local walkSpeed = GetConVar("gc_base_walk_speed"):GetInt()
    local output = {
        Shots = data.Num,
        Damage = data.Damage,
        GCRecoil = data.Recoil,
        AimSpread = data.AccuracyMOA * 0.017,
        FireDelay = data.Delay,
        HipSpread = (data.AccuracyMOA + data.HipDispersion) * 0.017,
        SpreadPerShot = 0,
        VelocitySensitivity = 1,
        MaxSpreadInc = 0,
        SpeedDec = walkSpeed - walkSpeed * data.SpeedMult,
        weight = data.weight
    }
    return output
end

function GM:parseTFAWeapon(data)
    local walkSpeed = GetConVar("gc_base_walk_speed"):GetInt()
    local output = {
        Shots = data.Primary.NumShots,
        Damage = data.Primary.Damage,
        GCRecoil = data.Primary.StaticRecoilFactor,
        AimSpread = data.Primary.IronAccuracy,
        FireDelay = data.Primary.RPM,
        HipSpread = data.Primary.Spread,
        SpreadPerShot = data.Primary.SpreadIncrement,
        VelocitySensitivity = 1,
        MaxSpreadInc = data.Primary.SpreadMultiplierMax,
        SpeedDec = walkSpeed - walkSpeed * data.MoveSpeed,
        weight = data.weight
    }
    return output
end

function GM:FindBestWeapons(lookInto, output)
    for key, weaponData in ipairs(lookInto) do
        local wepObj = weaponData.weaponObject
        -- We need a separate field otherwise TFA breaks
        wepObj.GCRecoil = wepObj.Recoil or 1
        if wepObj.Base == "tfa_gun_base" then
            wepObj = table.Merge(wepObj, self:parseTFAWeapon(wepObj))
        elseif weaponData.Base == "arccw_base" then
            wepObj = table.Merge(wepObj, self:parseArcCWWeapon(wepObj))
        end
        -- Handle edge cases where the SWEP creator didn't define this property explicitly
        if !wepObj.Shots then wepObj.Shots = 1 end

        output.damage = math.max(output.damage, wepObj.Damage * wepObj.Shots or 1)
        output.recoil = math.max(output.recoil, wepObj.GCRecoil)
        output.aimSpread = math.min(output.aimSpread, wepObj.AimSpread)
        output.firerate = math.min(output.firerate, wepObj.FireDelay)
        output.hipSpread = math.min(output.hipSpread, wepObj.HipSpread)
        output.spreadPerShot = math.max(output.spreadPerShot, wepObj.SpreadPerShot)
        output.velocitySensitivity = math.min(output.velocitySensitivity, wepObj.VelocitySensitivity)
        output.maxSpreadInc = math.max(output.maxSpreadInc, wepObj.MaxSpreadInc)
        output.speedDec = math.min(output.speedDec, wepObj.SpeedDec)
        output.weight = math.max(output.weight, wepObj.weight)
        output.penetrationValue = math.max(output.penetrationValue, self:GetAmmoPen(wepObj.Primary.Ammo, wepObj.penMod))

        local magWeight = self:GetAmmoWeight(wepObj.Primary.Ammo, wepObj.Primary.ClipSize)
        wepObj.magWeight = magWeight

        output.magWeight = math.max(output.magWeight, magWeight)
    end
end

function GM:GetAmmoWeight(caliber, roundCount)
    caliber = string.lower(caliber)
    roundCount = roundCount or 1
    return self.Calibers[caliber] and self.Calibers[caliber].weight * roundCount or
        (self.Calibers[self.CaliberAliases[caliber]] and self.Calibers[self.CaliberAliases[caliber]].weight or 0)
end

function GM:GetAmmoPen(caliber, penMod)
    caliber = string.lower(caliber)
    penMod = penMod or 1
    local pen = self.Calibers[caliber] and self.Calibers[caliber].penetration
        or (self.Calibers[self.CaliberAliases[caliber]] and self.Calibers[self.CaliberAliases[caliber]].penetration or 0)
    return math.Round(pen * penMod)
end

-- this function gets called in InitPostEntity for both the client and server, this is where we register a bunch of stuff
function GM:postInitEntity()

    -- KNIFE, give it 0 weight and make it undroppable (can't shoot out of hand, can't drop when dying)
    local wepObj = weapons.GetStored(self.KnifeWeaponClass)
    wepObj.weight = 0
    wepObj.dropsDisabled = true
    wepObj.isKnife = true
    wepObj.pointCost = 0

    if self.RemoveAttachments then
        -- remove M203 from all weapons
        local wepList = weapons.GetList()

        for i = 1, #wepList do
            local className = wepList[i].ClassName
            local data = weapons.GetStored(className)

            if weapons.Get(className).CW20Weapon and data.Attachments then
                for k, v in pairs(data.Attachments) do
                    for idx = 1, #self.RemoveAttachments do
                        table.Exclude(v.atts, self.RemoveAttachments[idx])
                    end
                end
            end
        end
    end


    -- Load all allowed weapon packs and registered ammo
    -- there's probably a better way to do this...
    if GetConVar("gc_use_cw2_weps"):GetBool() then
        if GetConVar("gc_use_cw2_spy"):GetBool() then
            self:RegisterWepsCW2Base()
        end
        if GetConVar("gc_use_cw2_spy_nades"):GetBool() then
            self:RegisterWepsCW2BaseThrowables()
        end
        if GetConVar("gc_use_cw2_khris"):GetBool() then
            self:RegisterWepsCW2Khris()
        end
        if GetConVar("gc_use_cw2_misc"):GetBool() then
            self:RegisterWepsCW2Misc()
        end
        if GetConVar("gc_use_cw2_kk_ins2"):GetBool() then
            self:RegisterWepsCW2KK()
        end
        if GetConVar("gc_use_cw2_kk_ext"):GetBool() then
            self:RegisterWepsCW2KKEXT()
        end
        if GetConVar("gc_use_cw2_kk_btk"):GetBool() then
            self:RegisterWepsCW2KKBTK()
        end
        if GetConVar("gc_use_cw2_kk_doi"):GetBool() then
            self:RegisterWepsCW2KKDOI()
        end
        if GetConVar("gc_use_cw2_soap"):GetBool() then
            self:RegisterWepsCW2Soap()
        end
        if GetConVar("gc_use_cw2_fas2"):GetBool() then
            self:RegisterWepsCW2FAS2()
        end
        self:RegisterAttsCW2KK()
    end
    self:RegisterCalibers()
    hook.Call("GroundControlPostInitEntity", nil)

    self:FindBestWeapons(self.PrimaryWeapons, BestPrimaryWeapons)
    self:FindBestWeapons(self.SecondaryWeapons, BestSecondaryWeapons)
    weapons.GetStored("cw_base").AddSafeMode = false -- disable safe firemode
    -- reduce/disable annoying camera effects from cw base
    weapons.GetStored("cw_base").RVBPitchMod = 0.4
    weapons.GetStored("cw_base").RVBYawMod = 0.4
    weapons.GetStored("cw_base").RVBRollMod = 0.4
    weapons.GetStored("cw_base").HipFireFOVIncrease = false
    -- weapons.GetStored("cw_base").LuaViewmodelRecoil = false

    if CLIENT then
        self:CreateMusicObjects()
    end
end