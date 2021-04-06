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
        data.icon = surface.GetTextureID(data.icon)
    end
end

function GM:getArmorData(armorId, category)
    return self.Armor[category][armorId]
end

function GM:prepareArmorPiece(ply, armorId, category)
    local armorPiece = self.Armor[category]

    if !armorPiece or !armorPiece[armorId] then
        return
    end

    armorPiece = armorPiece[armorId]

    local armorObject = {health = armorPiece.durability, id = armorId}
    ply.armor[category] = armorObject
end

function GM:getArmorWeight(category, id)
    local data = self.Armor[category][id]
    return data and data.weight or 0
end

function GM:getArmorCost(category, id)
    local data = self.Armor[category][id]
    return data and data.pointCost or 1
end

-- Armor properties
-- =======================
-- category: Denotes what this armor piece is grouped with, e.g. vest, helmet.
-- id: Internal reference name.
-- displayName: Displayed to client in the GUI.
-- weight: Armor weight in KG.
-- protection: Arbitrary value. Weapons with a penetration value less than this do reduced damage and don't cause bleeding.
-- protectionAreas: protected hitgroup table.
-- protectionDelta: in the event of no penetration, damage is scaled by an additional amount determined by
--      (protection - penetration) * protectionDelta
--      e.g. if a weapon's penetration value is 6 and shoots someone wearing a 10 protection vest with 0.015 protectionDelta,
--      an additional ((10 - 6) * 0.015) damage reduction will be added to the final calculation.
-- damageDecrease: Percent damage reduction in case of no penetration. Represents blunt trauma suffered.
-- damageDecreasePenetrated: Percent damage reduction in case of penetration. original suggestion is to not raise this above 20%.
-- durability: Amount of health points.
-- pointCost: Cost to add this to loadout.
-- icon: Path to the icon in the GUI.
-- description: Description displayed in the GUI.
-- =======================

-- Vests
-- =======================

local vestPaca = {
    category = "vest",
    id = "vest_paca",
    displayName = "PACA Low Visibility Carrier",
    weight = 1.7,
    protection = 8,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.75,
    protectionDelta = 0.0075,
    damageDecreasePenetrated = 0.15,
    durability = 30,
    pointCost = 4,
    icon = "ground_control/hud/armor/aa_vest_dyneema",
    description = "Minimalist carrier with level II soft panels."
}
GM:registerArmor(vestPaca)

local vestIba = {
    category = "vest",
    id = "vest_iba",
    displayName = "Interceptor Body Armor",
    weight = 11,
    protection = 16,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.775,
    protectionDelta = 0.01,
    damageDecreasePenetrated = 0.15,
    durability = 65,
    pointCost = 10,
    icon = "ground_control/hud/armor/aa_vest_spectra",
    description = "Surplus soft armor with level III rifle plates."
}
GM:registerArmor(vestIba)

local vestPc = {
    category = "vest",
    id = "vest_pc",
    displayName = "LBX Armatus II",
    weight = 8.5,
    protection = 20,
    protectionAreas = {[HITGROUP_CHEST] = true},
    damageDecrease = 0.775,
    protectionDelta = 0.01,
    damageDecreasePenetrated = 0.15,
    durability = 45,
    pointCost = 16,
    icon = "ground_control/hud/armor/aa_vest_lbx",
    description = "Modern, lightweight plate carrier with level IV rifle plates."
}
GM:registerArmor(vestPc)

local vestRatnik = {
    category = "vest",
    id = "vest_ratnik",
    displayName = "6B45 Body Armor",
    weight = 15,
    protection = 20,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true, [HITGROUP_LEFTARM] = true, [HITGROUP_RIGHTARM] = true},
    damageDecrease = 0.775,
    protectionDelta = 0.01,
    damageDecreasePenetrated = 0.15,
    durability = 75,
    pointCost = 24,
    icon = "ground_control/hud/armor/aa_vest_ratnik",
    description = "Body armor with level IV rifle plates and additional soft protection."
}
GM:registerArmor(vestRatnik)


-- Helmets
-- =======================

local helmetPasgt = {
    category = "helmet",
    id = "helmet_pasgt",
    displayName = "PASGT Helmet",
    weight = 1.1,
    protection = 12,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.8,
    protectionDelta = 0.01,
    damageDecreasePenetrated = 0.15,
    durability = 15,
    pointCost = 6,
    icon = "ground_control/hud/armor/aa_helmet_spectra",
    description = "Surplus kevlar helmet. Provides level IIIA protection."
}
GM:registerArmor(helmetPasgt)

local helmetAltyn = {
    category = "helmet",
    id = "helmet_altyn",
    displayName = "Altyn",
    weight = 4,
    protection = 12,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.8,
    protectionDelta = 0.01,
    damageDecreasePenetrated = 0.15,
    durability = 25,
    pointCost = 10,
    icon = "ground_control/hud/armor/aa_helmet_altyn",
    description = "Heavy titanium helmet. Provides level IIIA protection."
}
GM:registerArmor(helmetAltyn)

local helmetOperator = {
    category = "helmet",
    id = "helmet_operator",
    displayName = "N49 ULW Helmet",
    weight = 0.9,
    protection = 16,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.8,
    protectionDelta = 0.01,
    damageDecreasePenetrated = 0.15,
    durability = 10,
    pointCost = 12,
    icon = "ground_control/hud/armor/aa_helmet_operator",
    description = "Modern lightweight ballistic helmet with additional armor. Provides level III protection."
}
GM:registerArmor(helmetOperator)

local helmetVulkan = {
    category = "helmet",
    id = "helmet_vulkan",
    displayName = "Vulkan-5",
    weight = 4.5,
    protection = 20,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.8,
    protectionDelta = 0.01,
    damageDecreasePenetrated = 0.15,
    durability = 20,
    pointCost = 18,
    icon = "ground_control/hud/armor/aa_helmet_vulkan",
    description = "Heavy composite helmet. Provides level IV protection."
}
GM:registerArmor(helmetVulkan)

local PLAYER = FindMetaTable("Player")

-- Set the armor on the client side. Why? idk
function PLAYER:setArmorPiece(armorData, category)
    if CLIENT then
        self:resetArmorData(armorData.category)
        self:setupArmorPiece(armorData, category)
        self.armor[category] = armorData
    end
end

-- Clear the armor attribute for a given category
function PLAYER:resetArmorData(category)
    self.armor = self.armor or {}
    if self.armor[category] then
        self.armor[category] = nil
    end
end

-- Clear all of the player's tracked armor
function PLAYER:resetAllArmor()
    self.armor = self.armor or {}
    table.Empty(self.armor)
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
        for k,v in pairs(self.armor) do
            table.insert(combinedArmor, v)
        end
    end
    return combinedArmor
end