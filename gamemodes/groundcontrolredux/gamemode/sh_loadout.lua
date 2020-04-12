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

if CLIENT then
    include("cl_loadout.lua")
end

GM.RegisteredWeaponData = {}

GM.PrimaryWeapons = GM.PrimaryWeapons or {}
GM.SecondaryWeapons = GM.SecondaryWeapons or {}
GM.TertiaryWeapons = GM.TertiaryWeapons or {}
GM.CaliberWeights = GM.CaliberWeights or {}

BestPrimaryWeapons = BestPrimaryWeapons or {damage = -math.huge, recoil = -math.huge, aimSpread = math.huge, firerate = math.huge, hipSpread = math.huge, spreadPerShot = -math.huge, velocitySensitivity = math.huge, maxSpreadInc = -math.huge, speedDec = math.huge, weight = -math.huge, magWeight = -math.huge, penetrationValue = -math.huge}
BestSecondaryWeapons = BestSecondaryWeapons or {damage = -math.huge, recoil = -math.huge, aimSpread = math.huge, firerate = math.huge, hipSpread = math.huge, spreadPerShot = -math.huge, velocitySensitivity = math.huge, maxSpreadInc = -math.huge, speedDec = math.huge, weight = -math.huge, magWeight = -math.huge, penetrationValue = -math.huge}

local PLAYER = FindMetaTable("Player")

function PLAYER:getDesiredPrimaryMags()
    return math.Clamp(self:GetInfoNum("gc_primary_mags", GAMEMODE.DefaultPrimaryIndex), 1, GAMEMODE.MaxPrimaryMags)
end

function PLAYER:getDesiredSecondaryMags()
    return math.Clamp(self:GetInfoNum("gc_secondary_mags", GAMEMODE.DefaultPrimaryIndex), 1, GAMEMODE.MaxSecondaryMags)
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
    if not weaponData then
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
    if not storedWep then print("Attempted to register non-existing weapon "..weaponClassname) end
    return storedWep
end

function GM:applyWeaponDataToWeaponClass(weaponData, primaryWeapon, slot)
    local wepClass = weapons.GetStored(weaponData.weaponClass)
    wepClass.weight = weaponData.weight -- apply weight to the weapon class
    wepClass.isPrimaryWeapon = primaryWeapon
    wepClass.Slot = slot
    wepClass.penetrationValue = weaponData.penetration

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

-- 1 grain = 0.06479891 gram
function GM:registerCaliberWeight(caliberName, grams) -- when registering a caliber's weight, the caliberName value should be the ammo type that the weapon uses
    self.CaliberWeights[caliberName] = grams / 1000 -- convert grams to kilograms in advance
end

function GM:findBestWeapons(lookInto, output)
    for key, weaponData in ipairs(lookInto) do
        local wepObj = weaponData.weaponObject
        -- Handle edge cases where the SWEP creator didn't define this property explicitly
        if not wepObj.Shots then wepObj.Shots = 1 end
        
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
        output.penetrationValue = math.max(output.penetrationValue, wepObj.penetrationValue)
        
        local magWeight = self:getAmmoWeight(wepObj.Primary.Ammo, wepObj.Primary.ClipSize)
        wepObj.magWeight = magWeight
        
        output.magWeight = math.max(output.magWeight, magWeight)
    end
end

function GM:getAmmoWeight(caliber, roundCount)
    roundCount = roundCount or 1
    return self.CaliberWeights[caliber] and self.CaliberWeights[caliber] * roundCount or 0
end

-- this function gets called in InitPostEntity for both the client and server, this is where we register a bunch of stuff
function GM:postInitEntity()
    -- battle rifles
    local g3a3 = {
        weaponClass = "cw_g3a3",
        weight = 4.1,
        penetration = 18
    }
    self:registerPrimaryWeapon(g3a3)

    local scarH = {
        weaponClass = "cw_scarh",
        weight = 3.72,
        penetration = 18
    }
    self:registerPrimaryWeapon(scarH)
    
    local m14 = {
        weaponClass = "cw_m14",
        weight = 5.1,
        penetration = 18
    }
    self:registerPrimaryWeapon(m14)
   
    local fnfal = {
        weaponClass = "khr_fnfal",
        weight = 4.45,
        penetration = 18
    }
    self:registerPrimaryWeapon(fnfal)

    local svt40 = {
        weaponClass = "khr_svt40",
        weight = 3.9,
        penetration = 18
    }
    self:registerPrimaryWeapon(svt40)
    
    -- assault rifles
    local ak74 = {
        weaponClass = "cw_ak74",
        weight = 3.07,
        penetration = 16
    }
    self:registerPrimaryWeapon(ak74)

    local ar15 = {
        weaponClass = "cw_ar15",
        weight = 2.88,
        penetration = 16
    }
    self:registerPrimaryWeapon(ar15)
    
    local g36c = {
        weaponClass = "cw_g36c",
        weight = 2.82,
        penetration = 16
    }
    self:registerPrimaryWeapon(g36c)
    
    local g36c = {
        weaponClass = "cw_l85a2",
        weight = 3.82,
        penetration = 16
    }
    self:registerPrimaryWeapon(g36c)
    
    local vss = {
        weaponClass = "cw_vss",
        weight = 2.6,
        penetration = 16
    }
    self:registerPrimaryWeapon(vss)

    local aek971 = {
        weaponClass = "khr_aek971",
        weight = 3.3,
        penetration = 16
    }
    self:registerPrimaryWeapon(aek971)
   
    local ak103 = {
        weaponClass = "khr_ak103",
        weight = 3.4,
        penetration = 17
    }
    self:registerPrimaryWeapon(ak103)
   
    local cz858 = {
        weaponClass = "khr_cz858",
        weight = 2.91,
        penetration = 17
    }
    self:registerPrimaryWeapon(cz858)

    local m4a4 = {
        weaponClass = "khr_m4a4",
        weight = 2.88,
        penetration = 16
    }
    self:registerPrimaryWeapon(m4a4)

    local simsks = {
        weaponClass = "khr_simsks",
        weight = 3.9,
        penetration = 17
    }
    self:registerPrimaryWeapon(simsks)
   
    local sks = {
        weaponClass = "khr_sks",
        weight = 4.0,
        penetration = 17
    }
    self:registerPrimaryWeapon(sks)
    
    -- sub-machine guns/light carbines
    local mp5 = {
        weaponClass = "cw_mp5",
        weight = 2.5,
        penetration = 9
    }
    self:registerPrimaryWeapon(mp5)
    
    local mac11 = {
        weaponClass = "cw_mac11",
        weight = 1.59,
        penetration = 6
    }
    self:registerPrimaryWeapon(mac11)
    
    local ump45 = {
        weaponClass = "cw_ump45",
        weight = 2.5,
        penetration = 7
    }    
    self:registerPrimaryWeapon(ump45)

    local fmg9 = {
        weaponClass = "khr_fmg9",
        weight = 1.7,
        penetration = 7
    }
    self:registerPrimaryWeapon(fmg9)
   
    local p90 = {
        weaponClass = "khr_p90",
        weight = 2.6,
        penetration = 11
    }
    self:registerPrimaryWeapon(p90)
   
    local vector = {
        weaponClass = "khr_vector",
        weight = 2.7,
        penetration = 7
    }
    self:registerPrimaryWeapon(vector)
   
    local mp40 = {
        weaponClass = "khr_mp40",
        weight = 3.97,
        penetration = 7
    }
    self:registerPrimaryWeapon(mp40)

    -- Disabled by default since it literally adds nothing over the base one.
    -- local mp5a4 = {}
    -- mp5a4.weaponClass = "khr_mp5a4"
    -- mp5a4.weight = 2.5
    -- mp5a4.penetration = 9
   
    -- self:registerPrimaryWeapon(mp5a4)
   
    -- Fires .22LR for some ungodly reason. Can be here as a meme I guess
    local mp5a5 = {
        weaponClass = "khr_mp5a5",
        weight = 2.5,
        penetration = 4
    }
    self:registerPrimaryWeapon(mp5a5)

    local veresk = {
        weaponClass = "khr_veresk",
        weight = 1.65,
        penetration = 9
    }
    self:registerPrimaryWeapon(veresk)
   
    local l2a3 = {
        weaponClass = "khr_l2a3",
        weight = 2.7,
        penetration = 7
    }
    self:registerPrimaryWeapon(l2a3)

    local m1carbine = {
        weaponClass = "khr_m1carbine",
        weight = 2.6,
        penetration = 13
    }
    self:registerPrimaryWeapon(m1carbine)

    local delisle = {
        weaponClass = "khr_delisle",
        weight = 3.74,
        penetration = 8
    }
    self:registerPrimaryWeapon(delisle)

    -- heavy weapons
    local m249 = {
        weaponClass = "cw_m249_official",
        weight = 7.5,
        penetration = 16,
        maxMags = 2
    }
    self:registerPrimaryWeapon(m249)
    
    local pkp = {
        weaponClass = "cw_pkp",
        weight = 7.5,
        penetration = 18,
        maxMags = 1
    }
    self:registerPrimaryWeapon(pkp)
    
    local m79 = {
        weaponClass = "cw_m79",
        weight = 2.7,
        penetration = 5
    }
    self:registerPrimaryWeapon(m79)

    -- Khris', feel free to enable this and disable the pkp
    local pkm = {
        weaponClass = "khr_pkm",
        weight = 7.5,
        penetration = 18,
        maxMags = 1
    }
    self:registerPrimaryWeapon(pkm)

    local m60 = {
        weaponClass = "khr_m60",
        weight = 10.5,
        penetration = 18,
        maxMags = 2
    }
    self:registerPrimaryWeapon(m60)
   
    local hmg = {
        weaponClass = "khr_hmg",
        weight = 15,
        penetration = 40,
        maxMags = 0
    }
    self:registerPrimaryWeapon(hmg)
    
    -- shotguns
    local m3super90 = {
        weaponClass = "cw_m3super90",
        weight = 3.27,
        penetration = 5
    }
    self:registerPrimaryWeapon(m3super90)
    
    local serbushorty = {
        weaponClass = "cw_shorty",
        weight = 1.8,
        penetration = 5
    }
    self:registerPrimaryWeapon(serbushorty)

    local mp153 = {
        weaponClass = "khr_mp153",
        weight = 3.45,
        penetration = 5
    }
    self:registerPrimaryWeapon(mp153)
   
    local ns2000 = {
        weaponClass = "khr_ns2000",
        weight = 3.9,
        penetration = 5
    }
    self:registerPrimaryWeapon(ns2000)
   
    local m620 = {
        weaponClass = "khr_m620",
        weight = 3.6,
        penetration = 5
    }
    self:registerPrimaryWeapon(m620)
   
    local toz194 = {
        weaponClass = "khr_toz194",
        weight = 2.9,
        penetration = 5
    }
    self:registerPrimaryWeapon(toz194)
   
    local khr_cb4 = {
        weaponClass = "khr_cb4",
        weight = 3.27,
        penetration = 6
    }
    self:registerPrimaryWeapon(khr_cb4)
    
    -- sniper rifles
    -- bolt-action versions of "regular" rifle rounds like 7.62 NATO and mmR will get penetration buffs for balance
    local l115 = {
        weaponClass = "gc_cw_l115",
        weight = 6.5,
        penetration = 30
    }
    self:registerPrimaryWeapon(l115)

    local m98b = {
        weaponClass = "khr_m98b",
        weight = 5.6,
        penetration = 30
    }
    self:registerPrimaryWeapon(m98b)
   
    local hcar = {
        weaponClass = "khr_hcar",
        weight = 4.75,
        penetration = 24
    }
    self:registerPrimaryWeapon(hcar)
   
    local m82a3 = {
        weaponClass = "khr_m82a3",
        weight = 13.5,
        penetration = 40
    }   
    self:registerPrimaryWeapon(m82a3)
   
    local m95 = {
        weaponClass = "khr_m95",
        weight = 10.3,
        penetration = 40
    }
    self:registerPrimaryWeapon(m95)
   
    local mosin = {
        weaponClass = "khr_mosin",
        weight = 4,
        penetration = 20 -- sniper load 7.62mmR or something, +2 pen
    }
    self:registerPrimaryWeapon(mosin)
   
    local t5000 = {
        weaponClass = "khr_t5000",
        weight = 6.5,
        penetration = 30
    }
    self:registerPrimaryWeapon(t5000)
   
    local sr338 = {
        weaponClass = "khr_sr338",
        weight = 6.75,
        penetration = 30
    }
    self:registerPrimaryWeapon(sr338)
    
    -- handguns
    local deagle = {
        weaponClass = "cw_deagle", -- "khr_deagle" Khris' deagle if you prefer it instead.
        weight = 1.998,
        penetration = 13
    }
    self:registerSecondaryWeapon(deagle)
    
    local mr96 = {
        weaponClass = "cw_mr96",
        weight = 1.22,
        penetration = 14
    }
    self:registerSecondaryWeapon(mr96)
    
    local m1911 = {
        weaponClass = "cw_m1911",
        weight = 1.105,
        penetration = 7
    }
    self:registerSecondaryWeapon(m1911)
    
    local fiveseven = {
        weaponClass = "cw_fiveseven",
        weight = 0.61,
        penetration = 11
    }
    self:registerSecondaryWeapon(fiveseven)
    
    local p99 = {
        weaponClass = "cw_p99",
        weight = 0.63,
        penetration = 7
    }
    self:registerSecondaryWeapon(p99)
    
    local makarov = {
        weaponClass = "cw_makarov", -- "khr_makarov" if you prefer khris'
        weight = 0.73,
        penetration = 6
    }
    self:registerSecondaryWeapon(makarov)
    
    local vz61 = {
        weaponClass = "cw_vz61_kry",
        weight = 1.3,
        penetration = 5
    }
    self:registerSecondaryWeapon(vz61)
    
    local g18 = {
        weaponClass = "cw_g18",
        weight = 0.92,
        penetration = 7
    }
    self:registerSecondaryWeapon(g18)
   
    local microdeagle = {
        weaponClass = "khr_microdeagle",
        weight = 0.4,
        penetration = 6
    }
    self:registerSecondaryWeapon(microdeagle)

    local cz52 = {
        weaponClass = "khr_cz52",
        weight = 0.95,
        penetration = 8
    }
    self:registerSecondaryWeapon(cz52)
   
    local cz75 = {
        weaponClass = "khr_cz75",
        weight = 1.12,
        penetration = 7
    }
    self:registerSecondaryWeapon(cz75)
   
    local gsh18 = {
        weaponClass = "khr_gsh18",
        weight = 0.59,
        penetration = 7
    }
    self:registerSecondaryWeapon(gsh18)
   
    local m92fs = {
        weaponClass = "khr_m92fs",
        weight = 0.97,
        penetration = 7
    }
    self:registerSecondaryWeapon(m92fs)
   
    local mp443 = {
        weaponClass = "khr_mp443",
        weight = 0.95,
        penetration = 7
    }
    self:registerSecondaryWeapon(mp443)
   
    local ots33 = {
        weaponClass = "khr_ots33",
        weight = 1.15,
        penetration = 6
    }
    self:registerSecondaryWeapon(ots33)
   
    local ruby = {
        weaponClass = "khr_ruby",
        weight = 0.85,
        penetration = 5
    }
    self:registerSecondaryWeapon(ruby)
   
    local rugermk3 = {
        weaponClass = "khr_rugermk3",
        weight = 0.88,
        penetration = 4
    }
    self:registerSecondaryWeapon(rugermk3)
   
    local p345 = {
        weaponClass = "khr_p345",
        weight = 0.91,
        penetration = 7
    }
    self:registerSecondaryWeapon(p345)
   
    local p226 = {
        weaponClass = "khr_p226",
        weight = 0.964,
        penetration = 8
    }
    self:registerSecondaryWeapon(p226)
   
    local sr1m = {
        weaponClass = "khr_sr1m",
        weight = 0.95,
        penetration = 9
    }
    self:registerSecondaryWeapon(sr1m)
   
    local tokarev = {
        weaponClass = "khr_tokarev",
        weight = 0.854,
        penetration = 8
    }
    self:registerSecondaryWeapon(tokarev)
   
    local model29 = {
        weaponClass = "khr_model29",
        weight = 1.28,
        penetration = 14
    }
    self:registerSecondaryWeapon(model29)
   
    local model642 = {
        weaponClass = "khr_38snub",
        weight = 0.56,
        penetration = 7
    }
    self:registerSecondaryWeapon(model642)
   
    local swr8 = {
        weaponClass = "khr_swr8",
        weight = 1.02,
        penetration = 13
    }
    self:registerSecondaryWeapon(swr8)
   
    local publicDefender = {
        weaponClass = "khr_410jury",
        weight = 0.765,
        penetration = 5
    }
    self:registerSecondaryWeapon(publicDefender)
   
    local ragingbull = {
        weaponClass = "khr_ragingbull",
        weight = 1.5,
        penetration = 14
    }
    self:registerSecondaryWeapon(ragingbull)
    
    local flash = {}
    flash.weaponClass = "gc_cw_flash_grenade"
    flash.weight = 0.5
    flash.startAmmo = 2
    flash.hideMagIcon = true -- whether the mag icon and text should be hidden in the UI for this weapon
    flash.description = {{t = "Flashbang", font = "CW_HUD24", c = Color(255, 255, 255, 255)},
        {t = "Blinds nearby enemies facing the grenade upon detonation.", font = "CW_HUD20", c = Color(255, 255, 255, 255)},
        {t = "2x grenades.", font = "CW_HUD20", c = Color(255, 255, 255, 255)}
    }
        
    
    self:registerTertiaryWeapon(flash)
    
    local smoke = {}
    smoke.weaponClass = "gc_cw_smoke_grenade"
    smoke.weight = 0.5
    smoke.startAmmo = 2
    smoke.hideMagIcon = true
    smoke.description = {{t = "Smoke grenade", font = "CW_HUD24", c = Color(255, 255, 255, 255)},
        {t = "Provides a smoke screen to deter enemies from advancing or pushing through.", font = "CW_HUD20", c = Color(255, 255, 255, 255)},
        {t = "2x grenades.", font = "CW_HUD20", c = Color(255, 255, 255, 255)}
    }
    
    self:registerTertiaryWeapon(smoke)
    
    local spareGrenade = {}
    spareGrenade.weaponClass = "gc_cw_frag_grenade"
    spareGrenade.weight = 0.5
    spareGrenade.amountToGive = 1
    spareGrenade.skipWeaponGive = true
    spareGrenade.hideMagIcon = true
    spareGrenade.description = {{t = "Spare frag grenade", font = "CW_HUD24", c = Color(255, 255, 255, 255)},
        {t = "Allows for a second frag grenade to be thrown.", font = "CW_HUD20", c = Color(255, 255, 255, 255)}
    }
    
    function spareGrenade:postGive(ply)
        ply:GiveAmmo(self.amountToGive, "Frag Grenades")
    end
    
    self:registerTertiaryWeapon(spareGrenade)
    
    -- KNIFE, give it 0 weight and make it undroppable (can't shoot out of hand, can't drop when dying)
    local wepObj = weapons.GetStored(self.KnifeWeaponClass)
    wepObj.weight = 0
    wepObj.dropsDisabled = true
    wepObj.isKnife = true
    
    self:registerCaliberWeight("7.62x54mmR", 25.6)
    self:registerCaliberWeight("7.62x54MMR", 25.6) -- lol
    self:registerCaliberWeight("7.92x57MM Mauser", 26.0)
    self:registerCaliberWeight("7.62x51MM", 25.4)
    self:registerCaliberWeight("7.62x39MM", 16.3)
    self:registerCaliberWeight("5.45x39MM", 10.7)
    self:registerCaliberWeight("5.56x45MM", 11.5)
    self:registerCaliberWeight("9x19MM", 8.03)
    self:registerCaliberWeight(".50 AE", 22.67)
    self:registerCaliberWeight(".44 Magnum", 16)
    self:registerCaliberWeight(".45 ACP", 15)
    self:registerCaliberWeight("12 Gauge", 50)
    self:registerCaliberWeight(".338 Lapua", 46.2)
    self:registerCaliberWeight("9x39MM", 24.2)
    self:registerCaliberWeight("9x17MM", 7.5)
    self:registerCaliberWeight("5.7x28MM", 6.15)
    self:registerCaliberWeight("9x18MM", 8)
    self:registerCaliberWeight("9x21MM", 8.1)
    self:registerCaliberWeight(".50 BMG", 70)
    self:registerCaliberWeight(".410 Bore", 20)
    self:registerCaliberWeight(".357 Magnum", 14)
    self:registerCaliberWeight(".38 Special", 12.5)
    self:registerCaliberWeight("7.62x25MM", 7.5)
    self:registerCaliberWeight(".357 SIG", 8.1)
    self:registerCaliberWeight(".30 Carbine", 12)
    self:registerCaliberWeight("40MM", 230)
    self:registerCaliberWeight("7.65x17MM", 7.2)
    self:registerCaliberWeight(".380 ACP", 7.5)
    self:registerCaliberWeight(".32 ACP", 6.8)
    self:registerCaliberWeight(".22LR", 4.5)
    
    hook.Call("GroundControlPostInitEntity", nil)
    
    self:findBestWeapons(self.PrimaryWeapons, BestPrimaryWeapons)
    self:findBestWeapons(self.SecondaryWeapons, BestSecondaryWeapons)
    weapons.GetStored("cw_base").AddSafeMode = false -- disable safe firemode
    
    if CLIENT then
        self:createMusicObjects()
    end
end