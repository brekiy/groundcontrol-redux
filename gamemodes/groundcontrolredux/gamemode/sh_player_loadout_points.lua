AddCSLuaFile()

local PLAYER = FindMetaTable("Player")

function PLAYER:resetLoadoutPoints()
    self.loadoutPoints = 0
end

function PLAYER:getCurrentLoadoutPoints()
    return self.loadoutPoints
end

function PLAYER:updateLoadoutPoints()
    -- in case someone cheeky tries to set the base higher than the max? idk
    local max = math.max(GetConVar("gc_max_loadout_points"):GetInt(), GetConVar("gc_base_loadout_points"):GetInt())
    self.loadoutPoints = math.min(
        max,
        GetConVar("gc_base_loadout_points"):GetInt() + math.floor(self:GetNWInt("GC_SCORE") * GetConVar("gc_loadout_points_per_score"):GetFloat())
    )
end


function GM:getImaginaryLoadoutCost(ply, primaryCost, secondaryCost, tertiaryCost, vestCost, helmetCost)
    local primary = primaryCost or (ply:getDesiredPrimaryWeapon() != nil and ply:getDesiredPrimaryWeapon().pointCost or 0)
    local secondary = secondaryCost or (ply:getDesiredSecondaryWeapon() != nil and ply:getDesiredSecondaryWeapon().pointCost or 0)
    local tertiary = tertiaryCost or (ply:getDesiredTertiaryWeapon() != nil and ply:getDesiredTertiaryWeapon().pointCost or 0)
    local vest = vestCost or GAMEMODE:getArmorCost("vest", ply:getDesiredVest())
    local helmet = helmetCost or GAMEMODE:getArmorCost("helmet", ply:getDesiredHelmet())
    -- print("total cost: " .. primary + secondary + tertiary + vest + helmet)
    return primary + secondary + tertiary + vest + helmet
end

function GM:calculateCurrentLoadoutCost(ply, withCost, filterPrimary, filterSecondary, filterTertiary)
    withCost = withCost or 0
    filterPrimary = filterPrimary or false
    filterSecondary = filterSecondary or false
    filterTertiary = filterTertiary or false
    local totalCost = 0 + withCost
    -- print("starting totalcost " .. totalCost .. "filter primary/secondary/tertiary? " .. tostring(filterPrimary) .. "," .. tostring(filterSecondary) .. "," .. tostring(filterTertiary))
    totalCost = totalCost + GAMEMODE:getArmorCost("vest", ply:getDesiredVest())
    totalCost = totalCost + GAMEMODE:getArmorCost("helmet", ply:getDesiredHelmet())

    for key, weapon in pairs(ply:GetWeapons()) do
        -- print(weapon:GetPrintName() .. " checking for filter...")
        -- print((filterPrimary and weapon.isPrimaryWeapon) .. ", " ..
        -- (filterSecondary and !weapon.isPrimaryWeapon and !weapon.isTertiaryWeapon and !weapon.isKnife) .. ", " ..
        -- (filterTertiary and weapon.isTertiaryWeapon))
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
