AddCSLuaFile()

local PLAYER = FindMetaTable("Player")

function PLAYER:resetLoadoutPoints()
    self.loadoutPoints = GetConVar("gc_base_loadout_points"):GetInt()
end

function PLAYER:getCurrentLoadoutPoints()
    return self.loadoutPoints
end

function PLAYER:updateLoadoutPoints()
    self.loadoutPoints = math.min(
        GetConVar("gc_max_loadout_points"):GetInt(),
        GetConVar("gc_base_loadout_points"):GetInt() + math.floor(self:GetNWInt("GC_SCORE") * GetConVar("gc_loadout_points_per_score"):GetFloat()))
end


function GM:calculateCurrentLoadoutCost(ply, withoutCost, withCost)
    withoutCost = withoutCost or 0
    withCost = withCost or 0
    local totalCost = 0 - withoutCost + withCost
    totalCost = totalCost + GAMEMODE:getArmorCost("vest", ply:getDesiredVest())
    totalCost = totalCost + GAMEMODE:getArmorCost("helmet", ply:getDesiredHelmet())

    for key, weapon in pairs(ply:GetWeapons()) do
        local cost = weapon.pointCost or 1
        totalCost = totalCost + cost
    end

    -- for key, data in ipairs(self.gadgets) do
    --     local baseData = GAMEMODE.GadgetsById[data.id]

    --     totalCost = totalCost + baseData:getWeight(self, data)
    -- end

    return totalCost
end
