--[[
    you can easily add more armor vests, along with things like helmets and leg armor
    the reason why I did not add helmets and leg armor is because, despite the game focusing a lot on realism/playing slowly, this is garry's mod, and noone plays this slowly
    so naturally I saw no reason to add super extensive armor options
    all you need to do is specify the cvar it should use, create that cvar on the client, specify the hitgroups which the armor should protect, and add some UI elements for the selection of the armor to the loadout menu
]]--

AddCSLuaFile()
AddCSLuaFile("cl_player_armor.lua")

GM.DefaultArmor = 1 -- 1 is dyneema vest by default
GM.DefaultHelmet = 1 -- 1 is steel helmet by default

if CLIENT then
    include("cl_player_armor.lua")
    CreateClientConVar("gc_armor_vest", GM.DefaultArmor, true, true)
    CreateClientConVar("gc_armor_helmet", GM.DefaultHelmet, true, true)
end

GM.Armor = {}
GM.ArmorById = {}

function GM:registerArmor(data)
    self.Armor[data.category] = self.Armor[data.category] or {}
    table.insert(self.Armor[data.category], data)
    
    self.ArmorById[data.category] = self.ArmorById[data.category] or {}
    self.ArmorById[data.category][data.id] = data
    
    if CLIENT then
        local string = data.icon
        data.icon = surface.GetTextureID(data.icon)
    end
end

function GM:getArmorData(armorId, category)
    return self.Armor[category][armorId]
end

function GM:prepareArmorPiece(ply, armorId, category)
    local armorPiece = self.Armor[category]
    
    if not armorPiece then
        return
    end
    
    armorPiece = armorPiece[armorId]
    
    if not armorPiece then
        return
    end
    
    local armorObject = {health = 100, id = armorId, category = category}
    if (category == "vest") then
        table.insert(ply.armor, armorObject)
    -- if (category == "helmet") then
    --     table.insert(ply.helmet, armorObject)
    -- end
    elseif (category == "helmet") then
        table.insert(ply.helmet, armorObject)
    end
end

function GM:getArmorWeight(category, id)
    local data = self.Armor[category][id]
    return data and data.weight or 0
end

-- Armor properties
-- =======================
-- category: denotes what this armor piece is grouped with, valid options are vest, helmet, arms.
-- id: an internal reference name.
-- displayName: what's displayed to the client in the GUI.
-- weight: weight of the armor in KG.
-- protection: an arbitrary value. weapons that have a penetration value less than the armor's protection value do reduced damage and don't cause bleeding.
--      buckshot: 5
--      9mm Mak: 6
--      .45 ACP: 6-9
--      9mm Para: 7-9
--      5.7x28: 11
--      .44 Mag: 14
--      .50 AE: 15 (nerfed from 17 vanilla, since there are tests of it being stopped by IIIA vests)
--      9x39: 15
--      5.56 NATO: 16
--      5.45x39: 17
--      7.62 NATO: 18
--      .338 Lapua: 30
-- protectionAreas: the various hitgroups that this armor protects.
-- protectionDeltaToDamageDecrease: in the event of no penetration, damage is scaled by an additional amount determined by
--      (penetrationValue (weapon variable set in sh_loadout.lua) - protection) * protectionDeltaToDamageDecrease
--      ie if a weapon's penetration value is 6 and the vest's protection value is 10, 
--      an additional 4% ((10 - 6) * 0.01) damage reduction will be added to the final calculation.
-- damageDecrease: percent damage reduction in case of no penetration. represents blunt trauma suffered.
-- damageDecreasePenetration: percent damage reduction in case of penetration. original suggestion is to not raise this above 20%.
-- icon: path to the icon in the GUI.
-- description: description displayed in the GUI.
-- =======================

-- Vests
-- =======================

local dyneemaVest = {}
dyneemaVest.category = "vest"
dyneemaVest.id = "dyneema_vest"
dyneemaVest.displayName = "Dyneema Vest"
dyneemaVest.weight = 1.36
dyneemaVest.protection = 10
dyneemaVest.protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true}
dyneemaVest.protectionDeltaToDamageDecrease = 0.01
dyneemaVest.damageDecrease = 0.25
dyneemaVest.damageDecreasePenetration = 0.1
dyneemaVest.icon = "ground_control/hud/armor/aa_dyneema_vest"
dyneemaVest.description = "Soft vest. Provides type II protection against projectiles."

GM:registerArmor(dyneemaVest)

local kevlarVest = {}
kevlarVest.category = "vest"
kevlarVest.id = "kevlar_vest"
kevlarVest.displayName = "Kevlar Vest"
kevlarVest.weight = 3.27
kevlarVest.protection = 15
kevlarVest.protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true}
kevlarVest.damageDecrease = 0.275
kevlarVest.protectionDeltaToDamageDecrease = 0.008
kevlarVest.damageDecreasePenetration = 0.125
kevlarVest.icon = "ground_control/hud/armor/aa_kevlar_vest"
kevlarVest.description = "Soft vest. Provides type IIIA protection against projectiles."

GM:registerArmor(kevlarVest)

local spectraVest = {}
spectraVest.category = "vest"
spectraVest.id = "spectra_vest"
spectraVest.displayName = "SPECTRA Vest"
spectraVest.weight = 6.3
spectraVest.protection = 20
spectraVest.protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true}
spectraVest.damageDecrease = 0.3
spectraVest.protectionDeltaToDamageDecrease = 0.015
spectraVest.damageDecreasePenetration = 0.15
spectraVest.icon = "ground_control/hud/armor/aa_spectra_vest"
spectraVest.description = "Vest with hard plates. Provides type III protection against projectiles."

GM:registerArmor(spectraVest)

local ratnikVest = {}
ratnikVest.category = "vest"
ratnikVest.id = "heavy_vest"
ratnikVest.displayName = "Ratnik Vest"
ratnikVest.weight = 12.8
ratnikVest.protection = 20
ratnikVest.protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true, [HITGROUP_LEFTARM] = true, [HITGROUP_RIGHTARM] = true}
ratnikVest.damageDecrease = 0.35
ratnikVest.protectionDeltaToDamageDecrease = 0.02
ratnikVest.damageDecreasePenetration = 0.15
ratnikVest.icon = "ground_control/hud/armor/aa_ratnik_vest"
ratnikVest.description = "Vest with hard plates and upper arm protection. Provides type III protection against projectiles."

GM:registerArmor(ratnikVest)

-- Helmets
-- =======================

local steelHelmet = {}
steelHelmet.category = "helmet"
steelHelmet.id = "steel_helmet"
steelHelmet.displayName = "Steel Helmet"
steelHelmet.weight = 1.5
steelHelmet.protection = 6
steelHelmet.protectionAreas = {[HITGROUP_HEAD] = true}
steelHelmet.damageDecrease = 0.25
steelHelmet.protectionDeltaToDamageDecrease = 0.015
steelHelmet.damageDecreasePenetration = 0.15
steelHelmet.icon = "ground_control/hud/armor/aa_steel_helmet"
steelHelmet.description = "Provides type I protection against projectiles."

GM:registerArmor(steelHelmet)

local spectraHelmet = {}
spectraHelmet.category = "helmet"
spectraHelmet.id = "spectra_helmet"
spectraHelmet.displayName = "SPECTRA Helmet"
spectraHelmet.weight = 1.75
spectraHelmet.protection = 14
spectraHelmet.protectionAreas = {[HITGROUP_HEAD] = true}
spectraHelmet.damageDecrease = 0.4
spectraHelmet.protectionDeltaToDamageDecrease = 0.02
spectraHelmet.damageDecreasePenetration = 0.15
spectraHelmet.icon = "ground_control/hud/armor/aa_spectra_helmet"
spectraHelmet.description = "Provides type IIIA protection against projectiles."

GM:registerArmor(spectraHelmet)

local altynHelmet = {}
altynHelmet.category = "helmet"
altynHelmet.id = "altyn_helmet"
altynHelmet.displayName = "Altyn Helmet"
altynHelmet.weight = 2.5
altynHelmet.protection = 17
altynHelmet.protectionAreas = {[HITGROUP_HEAD] = true}
altynHelmet.damageDecrease = 0.5
altynHelmet.protectionDeltaToDamageDecrease = 0.03
altynHelmet.damageDecreasePenetration = 0.15
altynHelmet.icon = "ground_control/hud/armor/aa_altyn_helmet"
altynHelmet.description = "Provides type III protection against projectiles."

GM:registerArmor(altynHelmet)


local PLAYER = FindMetaTable("Player")

function PLAYER:setArmor(armorData)
    if CLIENT then
        self:resetArmorData()

        for key, data in ipairs(armorData) do
            self:setupArmorPiece(data)
            -- print("vest received "..GAMEMODE:getArmorData(data.id, data.category).displayName)
            self.armor = armorData
        end
    end
end

function PLAYER:setHelmet(armorData)
    if CLIENT then
        self:resetHelmetData()

        for key, data in ipairs(armorData) do
            self:setupArmorPiece(data)
            -- print("helmet received "..GAMEMODE:getArmorData(data.id, data.category).displayName)
            self.helmet = armorData
        end
    end
end

function PLAYER:resetArmorData()
    self.armor = self.armor or {}
    table.Empty(self.armor)
end

function PLAYER:resetHelmetData()
    self.helmet = self.helmet or {}
    table.Empty(self.helmet)
end    

function PLAYER:getDesiredVest()
    return tonumber(self:GetInfoNum("gc_armor_vest", 0))
end

function PLAYER:getDesiredHelmet()
    return tonumber(self:GetInfoNum("gc_armor_helmet", 0))
end

function PLAYER:getTotalArmorPieces()
    local combinedArmor = {}
    if self.armor then
        for k,v in ipairs(self.armor) do
            table.insert(combinedArmor, v)
        end
    end
    if self.helmet then
        for k,v in ipairs(self.helmet) do
            table.insert(combinedArmor, v)
        end
    end
    return combinedArmor
end