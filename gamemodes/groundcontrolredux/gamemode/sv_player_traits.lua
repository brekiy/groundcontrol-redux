AddCSLuaFile("cl_player_traits.lua")
include("sh_player_traits.lua")

local PLAYER = FindMetaTable("Player")

function PLAYER:ApplyTraits()
    self:RemoveTraits()

    for key, convar in ipairs(GAMEMODE.TraitConvars) do
        local desiredTrait = self:GetInfoNum(convar, "0")

        if desiredTrait then
            desiredTrait = tonumber(desiredTrait)

            GAMEMODE:ApplyTraitToPlayer(self, convar, desiredTrait)
        end
    end
end

function PLAYER:RemoveTraits()
    local traits = GAMEMODE.Traits

    for key, traitConfig in ipairs(self.currentTraits) do
        local traitData = traits[traitConfig[1]][traitConfig[2]]

        if traitData.remove then
            traitData:remove(self, self.traits[traitData.id])
        end

        self.currentTraits[key] = nil
    end
end

function PLAYER:LoadTraits()
    local traitData = self:GetPData("GC_TRAITS")

    if traitData then
        traitData = util.JSONToTable(traitData)
    else
        traitData = {}
    end

    self.traits = traitData
end

function PLAYER:SaveTraits()
    local traitData = util.TableToJSON(self.traits)
    self:SetPData("GC_TRAITS", traitData)
end

function PLAYER:unlockTrait(traitID)
    local traitData = GAMEMODE.TraitsById[traitID]

    if !traitData then
        return
    end

    local requiredCash = GAMEMODE:GetTraitPrice(traitData, 0)

    if self.cash < requiredCash then
        return
    end

    self:SetTraitLevel(traitData.id, 1)
    self:RemoveCash(requiredCash)
end

function PLAYER:ProgressTrait(traitID)
    local traitLevel = self.traits[traitID]

    if !traitLevel then
        return
    end

    local traitData = GAMEMODE.TraitsById[traitID]

    if !traitData or traitLevel >= traitData.maxLevel then
        return
    end

    local requiredCash = GAMEMODE:GetTraitPrice(traitData, traitLevel)

    if self.cash < requiredCash then
        return
    end

    self:SetTraitLevel(traitData.id, traitLevel + 1)
    self:RemoveCash(requiredCash)
end

function PLAYER:SetTraitLevel(trait, level)
    self.traits[trait] = level
    self:SaveTraits()
    self:sendTraits()
end

function PLAYER:sendTraits()
    net.Start("GC_TRAITS")
        net.WriteTable(self.traits)
    net.Send(self)
end

concommand.Add("gc_buy_trait", function(ply, com, args)
    local targetTrait = args[1]

    if !targetTrait then
        return
    end

    if !ply:HasTrait(targetTrait) then
        ply:unlockTrait(targetTrait)
    else
        ply:ProgressTrait(targetTrait)
    end
end)