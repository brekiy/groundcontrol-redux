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

function GM:RegisterArmor(data)
    self.Armor[data.category] = self.Armor[data.category] or {}
    table.insert(self.Armor[data.category], data)

    self.ArmorById[data.category] = self.ArmorById[data.category] or {}
    self.ArmorById[data.category][data.id] = data

    if CLIENT then
        data.icon = surface.GetTextureID(data.icon)
    end
end

function GM:GetArmorData(armorId, category)
    return self.Armor[category][armorId]
end

function GM:PrepareArmorPiece(ply, armorId, category)
    local armorPiece = self.Armor[category]

    if !armorPiece or !armorPiece[armorId] then
        return
    end

    armorPiece = armorPiece[armorId]

    local armorObject = {health = armorPiece.durability, id = armorId}
    ply.armor[category] = armorObject
end

function GM:GetArmorWeight(category, id)
    local data = self.Armor[category][id]
    return data and data.weight or 0
end

function GM:GetArmorCost(category, id)
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
    displayName = "PACA Low-Vis Carrier",
    weight = 1.7,
    protection = 10,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.69, -- hehe
    protectionDelta = 0.0085,
    damageDecreasePenetrated = 0.125,
    durability = 40,
    pointCost = 5,
    icon = "ground_control/hud/armor/aa_vest_dyneema",
    description = "Minimalist carrier with level II soft panels."
}
GM:RegisterArmor(vestPaca)

local vestPacaII = {
    category = "vest",
    id = "vest_paca",
    displayName = "PACA II Low-Vis Carrier",
    weight = 5,
    protection = 15,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.69, -- hehe
    protectionDelta = 0.0085,
    damageDecreasePenetrated = 0.125,
    durability = 45,
    pointCost = 10,
    icon = "ground_control/hud/armor/aa_vest_dyneema",
    description = "Minimalist carrier with level IIIA soft panels."
}
GM:RegisterArmor(vestPacaII)

local vestIba = {
    category = "vest",
    id = "vest_iba",
    displayName = "Interceptor Body Armor",
    weight = 12,
    protection = 30,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.725,
    protectionDelta = 0.00875,
    damageDecreasePenetrated = 0.15,
    durability = 50,
    pointCost = 15,
    icon = "ground_control/hud/armor/aa_vest_spectra",
    description = "Surplus soft armor with level III rifle plates."
}
GM:RegisterArmor(vestIba)

local vestPc = {
    category = "vest",
    id = "vest_pc",
    displayName = "LBX Armatus II",
    weight = 8.5,
    protection = 40,
    protectionAreas = {[HITGROUP_CHEST] = true},
    damageDecrease = 0.725,
    protectionDelta = 0.009,
    damageDecreasePenetrated = 0.15,
    durability = 40,
    pointCost = 25,
    icon = "ground_control/hud/armor/aa_vest_lbx",
    description = "Modern lightweight plate carrier with level IV rifle plates."
}
GM:RegisterArmor(vestPc)

local vestRatnik = {
    category = "vest",
    id = "vest_ratnik",
    displayName = "6B45 Body Armor",
    weight = 16,
    protection = 40,
    protectionAreas = {[HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true},
    damageDecrease = 0.725,
    protectionDelta = 0.009,
    damageDecreasePenetrated = 0.15,
    durability = 50,
    pointCost = 40,
    icon = "ground_control/hud/armor/aa_vest_ratnik",
    description = "Modern heavy plate carrier with level IV rifle plates."
}
GM:RegisterArmor(vestRatnik)


-- Helmets
-- =======================

local helmetPasgt = {
    category = "helmet",
    id = "helmet_pasgt",
    displayName = "PASGT Helmet",
    weight = 1.1,
    protection = 15,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.69,
    protectionDelta = 0.0125,
    damageDecreasePenetrated = 0.05,
    durability = 10,
    pointCost = 5,
    icon = "ground_control/hud/armor/aa_helmet_spectra",
    description = "Surplus aramid helmet. Provides level IIIA protection."
}
GM:RegisterArmor(helmetPasgt)

local helmetAltyn = {
    category = "helmet",
    id = "helmet_altyn",
    displayName = "Altyn",
    weight = 4,
    protection = 15,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.7,
    protectionDelta = 0.015,
    damageDecreasePenetrated = 0.05,
    durability = 25,
    pointCost = 10,
    icon = "ground_control/hud/armor/aa_helmet_altyn",
    description = "Heavy titanium helmet with faceshield. Provides level IIIA protection."
}
GM:RegisterArmor(helmetAltyn)

local helmetOperator = {
    category = "helmet",
    id = "helmet_operator",
    displayName = "N49 ULW Helmet",
    weight = 0.9,
    protection = 30,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.675,
    protectionDelta = 0.011,
    damageDecreasePenetrated = 0.05,
    durability = 10,
    pointCost = 15,
    icon = "ground_control/hud/armor/aa_helmet_operator",
    description = "Lightweight polyethylene helmet with additional armor. Provides level III protection."
}
GM:RegisterArmor(helmetOperator)

local helmetVulkan = {
    category = "helmet",
    id = "helmet_vulkan",
    displayName = "Vulkan-5",
    weight = 4.5,
    protection = 30,
    protectionAreas = {[HITGROUP_HEAD] = true},
    damageDecrease = 0.7,
    protectionDelta = 0.0135,
    damageDecreasePenetrated = 0.05,
    durability = 20,
    pointCost = 20,
    icon = "ground_control/hud/armor/aa_helmet_vulkan",
    description = "Heavy composite helmet. Provides level III protection."
}
GM:RegisterArmor(helmetVulkan)

local PLAYER = FindMetaTable("Player")

-- Set the armor on the client side. Why? idk
function PLAYER:SetArmorPiece(armorData, category)
    if CLIENT then
        self:ResetArmorData(armorData.category)
        self:SetupArmorPiece(armorData, category)
        self.armor[category] = armorData
    end
end

-- Clear the armor attribute for a given category
function PLAYER:ResetArmorData(category)
    self.armor = self.armor or {}
    if self.armor[category] then
        self.armor[category] = nil
    end
end

-- Clear all of the player's tracked armor
function PLAYER:ResetTrackedArmor()
    self.armor = {}
end

-- Force resets the player to have no armor
function PLAYER:ResetAllArmor()
    self:GiveGCArmor("vest", 0)
    self:GiveGCArmor("helmet", 0)
end

function PLAYER:GetDesiredVest()
    return tonumber(self:GetInfoNum("gc_armor_vest", 1))
end

function PLAYER:GetDesiredHelmet()
    return tonumber(self:GetInfoNum("gc_armor_helmet", 1))
end

function PLAYER:GetTotalArmorPieces()
    local combinedArmor = {}
    if self.armor then
        for k,v in pairs(self.armor) do
            table.insert(combinedArmor, v)
        end
    end
    return combinedArmor
end