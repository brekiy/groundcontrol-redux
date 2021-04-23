AddCSLuaFile()

include("gametypes/gc_drug_bust.lua")
include("gametypes/gc_urban_warfare.lua")
include("gametypes/gc_rush.lua")
include("gametypes/gc_intel_retrieval.lua")

GM.Gametypes = {}
GM.GametypesByName = {}
GM.curGametype = nil
GM.DefaultGametypeID = 1 -- this is what we default to in case something goes wrong when attempting to switch to another gametype

function GM:RegisterNewGametype(gametypeData)
    table.insert(self.Gametypes, gametypeData)
    self.GametypesByName[gametypeData.name] = gametypeData
end

function GM:SetGametype(gameTypeID)
    self.CurGametypeID = gameTypeID
    self.CurGametype = self.Gametypes[gameTypeID]

    if self.CurGametype.Prepare then
        self.CurGametype:Prepare()
    end

    if SERVER then
        -- doesn't do what the method says it does, please look in sv_gametypes.lua to see what it really does (bad name for the method, I know)
        self:RemoveCurrentGametype()
    end
end

function GM:SetGametypeCVarByPrettyName(targetName)
    local key, _ = self:GetGametypeFromConVar(targetName)

    if key then
        self:ChangeGametype(key)
        game.ConsoleCommand("gc_gametype " .. key .. "\n")

        return true
    end

    return false
end

function GM:GetGametypeNameData(id)
    return id .. " - " .. self.Gametypes[id].prettyName .. " (" .. self.Gametypes[id].name .. ")"
end

function GM:GetGametypeFromConVar(targetValue)
    local cvarValue = targetValue and targetValue or GetConVar("gc_gametype"):GetString()
    local newGID = tonumber(cvarValue)

    if !newGID then
        local lowered = string.lower(cvarValue)

        for key, gametype in ipairs(self.Gametypes) do
            if string.lower(gametype.prettyName) == lowered or string.lower(gametype.name) == lowered then
                return key, gametype
            end
        end
    else
        if self.Gametypes[newGID] then
            return newGID, self.Gametypes[newGID]
        end
    end

    -- in case of failure
    print(self:AppendHelpText("[GROUND CONTROL] Error - non-existent gametype ID '" .. targetValue .. "', last gametype in gametype table is '" .. GAMEMODE:GetGametypeNameData(#self.Gametypes) .. "', resetting to default gametype"))
    return self.DefaultGametypeID, self.Gametypes[self.DefaultGametypeID]
end

GM.HELP_TEXT = "\ntype 'gc_gametypelist' to get a list of all valid gametypes\ntype 'gc_gametype_maplist' to get a list of all supported maps for all available gametypes\n"

function GM:AppendHelpText(text)
    return text .. self.HELP_TEXT
end

-- changes the gametype for the next map
function GM:ChangeGametype(newGametypeID)
    if !newGametypeID then
        return
    end

    local newGID = tonumber(newGametypeID) -- check if the passed on value is a string

    -- if it is, attempt to set a gametype by the string we were passed on
    if !newGID and self:SetGametypeCVarByPrettyName(newGametypeID) then
        return true
    end

    if newGID then
        local gameTypeData = self.Gametypes[newGID]

        if !gameTypeData then -- non-existant gametype, can't switch
            game.ConsoleCommand("gc_gametype " .. self.DefaultGametypeID .. "\n")
            return
        end

        local text = "NEXT MAP GAMETYPE: " .. gameTypeData.prettyName
        print("[GROUND CONTROL] " .. text)

        net.Start("GC_NOTIFICATION")
        net.WriteString(text)
        net.Broadcast()

        return true
    else
        print(self:AppendHelpText("[GROUND CONTROL] Invalid gametype '" .. tostring(newGametypeID) .. "'\n"))
        return false
    end
end

function GM:GetGametypeByID(id)
    return GAMEMODE.Gametypes[id]
end

function GM:InitializeGameTypeEntities(gameType)
    local map = string.lower(game.GetMap())
    local objEnts = gameType.objectives[map]
    if objEnts then
        for key, data in ipairs(objEnts) do
            local objEnt = ents.Create(data.objectiveClass)
            objEnt:SetPos(data.pos)
            objEnt:Spawn()

            GAMEMODE.entityInitializer:InitEntity(objEnt, gameType, data)

            table.insert(gameType.objectiveEnts, objEnt)
        end
    end
end

function GM:AddObjectivePositionToGametype(gametypeName, map, pos, objectiveClass, additionalData)
    local gametypeData = self.GametypesByName[gametypeName]
    if gametypeData then
        gametypeData.objectives = gametypeData.objectives or {}
        gametypeData.objectives[map] = gametypeData.objectives[map] or {}

        table.insert(gametypeData.objectives[map], {pos = pos, objectiveClass = objectiveClass, data = additionalData})
    end
end

function GM:GetGametype()
    return self.curGametype
end

GM:RegisterRush()
GM:RegisterUrbanWarfare()
GM:RegisterDrugBust()
GM:RegisterIntelRetrieval()
