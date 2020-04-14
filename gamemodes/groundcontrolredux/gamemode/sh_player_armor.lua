--[[
    Adding extra armor options shouldn't be too hard if you really want anything more than
    body armor and a helmet. I think this is enough complexity for a pick up and play Gmod gamemode.
]]--

AddCSLuaFile()
AddCSLuaFile("cl_player_armor.lua")

GM.DefaultArmor = 1
GM.DefaultHelmet = 1

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
-- category: Denotes what this armor piece is grouped with, e.g. vest, helmet.
-- id: Internal reference name.
-- displayName: Displayed to client in the GUI.
-- weight: Armor weight in KG.
-- protection: Arbitrary value. Weapons with a penetration value less than this do reduced damage and don't cause bleeding.
-- protectionAreas: protected hitgroup table.
-- protectionDeltaToDamageDecrease: in the event of no penetration, damage is scaled by an additional amount determined by
--      (protection - penetration) * protectionDeltaToDamageDecrease
--      e.g. if a weapon's penetration value is 6 shoots a guy wearing the dyneema vest, 
--      an additional 6% ((10 - 6) * 0.015) damage reduction will be added to the final calculation.
-- damageDecrease: Percent damage reduction in case of no penetration. Represents blunt trauma suffered.
-- damageDecreasePenetration: Percent damage reduction in case of penetration. original suggestion is to not raise this above 20%.
-- icon: Path to the icon in the GUI.
-- description: Description displayed in the GUI.
-- =======================

-- Vests
-- =======================

local dyneemaVest = {
    category = "vest",
    id = "dyneema_vest",
    displayName = "Dyneema Vest",
    weight = 1.7,
    protection = 10,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    protectionDeltaToDamageDecrease = 0.015,
    damageDecrease = 0.3,
    damageDecreasePenetration = 0.125,
    icon = "ground_control/hud/armor/aa_dyneema_vest",
    description = "Thin soft vest. Provides type II protection against projectiles."
}
GM:registerArmor(dyneemaVest)

local kevlarVest = {
    category = "vest",
    id = "kevlar_vest",
    displayName = "Kevlar Vest",
    weight = 3.3,
    protection = 15,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.3,
    protectionDeltaToDamageDecrease = 0.015,
    damageDecreasePenetration = 0.125,
    icon = "ground_control/hud/armor/aa_kevlar_vest",
    description = "Soft vest. Provides type IIIA protection against projectiles."
}
GM:registerArmor(kevlarVest)

local spectraVest = {
    category = "vest",
    id = "spectra_vest",
    displayName = "SPECTRA Vest",
    weight = 6.3,
    protection = 20,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.5,
    protectionDeltaToDamageDecrease = 0.0155,
    damageDecreasePenetration = 0.15,
    icon = "ground_control/hud/armor/aa_spectra_vest",
    description = "Vest with hard plates. Provides type III protection against projectiles."
}
GM:registerArmor(spectraVest)

local ratnikVest = {
    category = "vest",
    id = "ratnik_vest",
    displayName = "Ratnik Vest",
    weight = 14,
    protection = 20,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true, [HITGROUP_LEFTARM] = true, [HITGROUP_RIGHTARM] = true},
    damageDecrease = 0.525,
    protectionDeltaToDamageDecrease = 0.0155,
    damageDecreasePenetration = 0.15,
    icon = "ground_control/hud/armor/aa_ratnik_vest",
    description = "Heavy body armor. Provides type III protection against projectiles."
}
GM:registerArmor(ratnikVest)

local lbxVest = {
    category = "vest",
    id = "lbx_vest",
    displayName = "LBX Vest",
    weight = 10,
    protection = 25,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.5,
    protectionDeltaToDamageDecrease = 0.0155,
    damageDecreasePenetration = 0.15,
    icon = "ground_control/hud/armor/aa_lbx_vest",
    description = "Advanced plate carrier. Provides type VI protection against projectiles."
}
GM:registerArmor(lbxVest)

-- Helmets
-- =======================

local steelHelmet = {
    category = "helmet",
    id = "steel_helmet",
    displayName = "Steel Helmet",
    weight = 1.25,
    protection = 8,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.4,
    protectionDeltaToDamageDecrease = 0.0125,
    damageDecreasePenetration = 0.15,
    icon = "ground_control/hud/armor/aa_steel_helmet",
    description = "Provides type II protection against projectiles."
}
GM:registerArmor(steelHelmet)

local spectraHelmet = {
    category = "helmet",
    id = "spectra_helmet",
    displayName = "SPECTRA Helmet",
    weight = 1.75,
    protection = 13,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.4,
    protectionDeltaToDamageDecrease = 0.0125,
    damageDecreasePenetration = 0.15,
    icon = "ground_control/hud/armor/aa_spectra_helmet",
    description = "Provides type IIIA protection against projectiles."
}
GM:registerArmor(spectraHelmet)

local altynHelmet = {
    category = "helmet",
    id = "altyn_helmet",
    displayName = "Altyn Helmet",
    weight = 4,
    protection = 18,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.4,
    protectionDeltaToDamageDecrease = 0.0125,
    damageDecreasePenetration = 0.15,
    icon = "ground_control/hud/armor/aa_altyn_helmet",
    description = "Provides type III protection against projectiles."
}
GM:registerArmor(altynHelmet)


local PLAYER = FindMetaTable("Player")

function PLAYER:setArmor(armorData)
    if CLIENT then
        self:resetArmorData()
        for key, data in ipairs(armorData) do
            self:setupArmorPiece(data)
            self.armor = armorData
        end
    end
end

function PLAYER:setHelmet(armorData)
    if CLIENT then
        self:resetHelmetData()
        for key, data in ipairs(armorData) do
            self:setupArmorPiece(data)
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
    return tonumber(self:GetInfoNum("gc_armor_vest", 1))
end

function PLAYER:getDesiredHelmet()
    return tonumber(self:GetInfoNum("gc_armor_helmet", 1))
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