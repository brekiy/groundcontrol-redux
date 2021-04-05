AddCSLuaFile()

local PLAYER = FindMetaTable("Player")

function PLAYER:resetLoadoutPoints()
    self.loadoutPoints = GetConVar("gc_base_loadout_points"):GetInt()
end

function PLAYER:getCurrentLoadoutPoints()
    return self.loadoutPoints
end

function PLAYER:updateLoadoutPoints()
    print("wowee updating the loadout points!")
    self.loadoutPoints = math.min(
        GetConVar("gc_max_loadout_points"):GetInt(),
        GetConVar("gc_base_loadout_points"):GetInt() + math.floor(self:GetNWInt("GC_SCORE") * GetConVar("gc_loadout_points_per_score"):GetFloat()))
end


function GM:getImaginaryLoadoutCost(ply, primaryCost, secondaryCost, tertiaryCost, vestCost, helmetCost)
    -- local totalCost = 0
    local primary = primaryCost or ply:getDesiredPrimaryWeapon().pointCost
    local secondary = secondaryCost or ply:getDesiredSecondaryWeapon().pointCost
    local tertiary = tertiaryCost or ply:getDesiredTertiaryWeapon().pointCost
    local vest = vestCost or GAMEMODE:getArmorCost("vest", ply:getDesiredVest())
    local helmet = helmetCost or GAMEMODE:getArmorCost("helmet", ply:getDesiredHelmet())

    -- totalCost = primary + secondary + tertiary + vest + helmet
    return primary + secondary + tertiary + vest + helmet
end

function GM:calculateCurrentLoadoutCost(ply, withCost, filterPrimary, filterSecondary, filterTertiary)
    withoutCost = withoutCost or 0
    withCost = withCost or 0
    local totalCost = 0 - withoutCost + withCost
    totalCost = totalCost + GAMEMODE:getArmorCost("vest", ply:getDesiredVest())
    totalCost = totalCost + GAMEMODE:getArmorCost("helmet", ply:getDesiredHelmet())

    for key, weapon in pairs(ply:GetWeapons()) do
        if !((filterPrimary and weapon.isPrimaryWeapon) or
            (filterSecondary and !weapon.isPrimaryWeapon and !weapon.isTertiaryWeapon and !weapon.isKnife) or
            (filterTertiary and weapon.isTertiaryWeapon)) then
            local cost = weapon.pointCost or 1
            totalCost = totalCost + cost
        end
    end

    -- for key, data in ipairs(self.gadgets) do
    --     local baseData = GAMEMODE.GadgetsById[data.id]

    --     totalCost = totalCost + baseData:getWeight(self, data)
    -- end

    return totalCost
end
