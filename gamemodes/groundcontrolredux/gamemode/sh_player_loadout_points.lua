AddCSLuaFile()

local PLAYER = FindMetaTable("Player")

function PLAYER:ResetLoadoutPoints()
    self.loadoutPoints = 0
end

function PLAYER:GetCurrentLoadoutPoints()
    return self.loadoutPoints
end

function PLAYER:UpdateLoadoutPoints()
    -- in case someone cheeky tries to set the base higher than the max? idk
    local max = math.max(GetConVar("gc_max_loadout_points"):GetInt(), GetConVar("gc_base_loadout_points"):GetInt())
    self.loadoutPoints = math.min(
        max,
        GetConVar("gc_base_loadout_points"):GetInt() + math.floor(self:GetNWInt("GC_SCORE") * GetConVar("gc_loadout_points_per_score"):GetFloat())
    )
end


function GM:GetImaginaryLoadoutCost(ply, primaryCost, secondaryCost, tertiaryCost, vestCost, helmetCost)
    local primary = primaryCost or (ply:GetDesiredPrimaryWeapon() != nil and ply:GetDesiredPrimaryWeapon().pointCost or 0)
    local secondary = secondaryCost or (ply:GetDesiredSecondaryWeapon() != nil and ply:GetDesiredSecondaryWeapon().pointCost or 0)
    local tertiary = tertiaryCost or (ply:GetDesiredTertiaryWeapon() != nil and ply:GetDesiredTertiaryWeapon().pointCost or 0)
    local vest = vestCost or GAMEMODE:GetArmorCost("vest", ply:GetDesiredVest())
    local helmet = helmetCost or GAMEMODE:GetArmorCost("helmet", ply:GetDesiredHelmet())
    -- print("total cost: " .. primary + secondary + tertiary + vest + helmet)
    return primary + secondary + tertiary + vest + helmet
end

function GM:CalculateCurrentLoadoutCost(ply, withCost, filterPrimary, filterSecondary, filterTertiary)
    withCost = withCost or 0
    filterPrimary = filterPrimary or false
    filterSecondary = filterSecondary or false
    filterTertiary = filterTertiary or false
    local totalCost = 0 + withCost
    totalCost = totalCost + GAMEMODE:GetArmorCost("vest", ply:GetDesiredVest())
    totalCost = totalCost + GAMEMODE:GetArmorCost("helmet", ply:GetDesiredHelmet())

    for key, weapon in pairs(ply:GetWeapons()) do
        if !((filterPrimary and weapon.isPrimaryWeapon) or
            (filterSecondary and !weapon.isPrimaryWeapon and !weapon.isTertiaryWeapon and !weapon.isKnife) or
            (filterTertiary and weapon.isTertiaryWeapon)) then
            local cost = weapon.pointCost or 0
            -- print(weapon:GetPrintName() .. "," .. cost)
            totalCost = totalCost + cost
        end
    end

    -- for key, data in ipairs(self.gadgets) do
    --     local baseData = GAMEMODE.GadgetsById[data.id]

    --     totalCost = totalCost + baseData:getWeight(self, data)
    -- end
    -- print("calculated current loadout cost as " .. totalCost)
    return totalCost
end
