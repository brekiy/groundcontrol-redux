AddCSLuaFile()

include("gametypes/gc_drug_bust.lua")
include("gametypes/gc_urban_warfare.lua")
include("gametypes/gc_rush.lua")
include("gametypes/gc_intel_retrieval.lua")

GM.Gametypes = {}
GM.GametypesByName = {}
GM.curGametype = nil
GM.DefaultGametypeID = 1 -- this is what we default to in case something goes wrong when attempting to switch to another gametype

function GM:registerNewGametype(gametypeData)
    table.insert(self.Gametypes, gametypeData)
    self.GametypesByName[gametypeData.name] = gametypeData
end

function GM:setGametype(gameTypeID)
    self.curGametypeID = gameTypeID
    self.curGametype = self.Gametypes[gameTypeID]

    if self.curGametype.prepare then
        self.curGametype:prepare()
    end

    if SERVER then
        -- doesn't do what the method says it does, please look in sv_gametypes.lua to see what it really does (bad name for the method, I know)
        self:removeCurrentGametype()
    end
end

function GM:setGametypeCVarByPrettyName(targetName)
    local key, _ = self:getGametypeFromConVar(targetName)

    if key then
        self:changeGametype(key)
        game.ConsoleCommand("gc_gametype " .. key .. "\n")

        return true
    end

    return false
end

function GM:getGametypeNameData(id)
    return id .. " - " .. self.Gametypes[id].prettyName .. " (" .. self.Gametypes[id].name .. ")"
end

function GM:getGametypeFromConVar(targetValue)
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
    print(self:appendHelpText("[GROUND CONTROL] Error - non-existent gametype ID '" .. targetValue .. "', last gametype in gametype table is '" .. GAMEMODE:getGametypeNameData(#self.Gametypes) .. "', resetting to default gametype"))
    return self.DefaultGametypeID, self.Gametypes[self.DefaultGametypeID]
end

GM.HelpText = "\ntype 'gc_gametypelist' to get a list of all valid gametypes\ntype 'gc_gametype_maplist' to get a list of all supported maps for all available gametypes\n"

function GM:appendHelpText(text)
    return text .. self.HelpText
end

-- changes the gametype for the next map
function GM:changeGametype(newGametypeID)
    if !newGametypeID then
        return
    end

    local newGID = tonumber(newGametypeID) -- check if the passed on value is a string

    -- if it is, attempt to set a gametype by the string we were passed on
    if !newGID and self:setGametypeCVarByPrettyName(newGametypeID) then
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
        print(self:appendHelpText("[GROUND CONTROL] Invalid gametype '" .. tostring(newGametypeID) .. "'\n"))
        return false
    end
end

function GM:getGametypeByID(id)
    return GAMEMODE.Gametypes[id]
end

function GM:initializeGameTypeEntities(gameType)
    local map = string.lower(game.GetMap())
    local objEnts = gameType.objectives[map]
    if objEnts then
        for key, data in ipairs(objEnts) do
            local objEnt = ents.Create(data.objectiveClass)
            objEnt:SetPos(data.pos)
            objEnt:Spawn()

            GAMEMODE.entityInitializer:initEntity(objEnt, gameType, data)

            table.insert(gameType.objectiveEnts, objEnt)
        end
    end
end

function GM:addObjectivePositionToGametype(gametypeName, map, pos, objectiveClass, additionalData)
    local gametypeData = self.GametypesByName[gametypeName]
    if gametypeData then
        gametypeData.objectives = gametypeData.objectives or {}
        gametypeData.objectives[map] = gametypeData.objectives[map] or {}

        table.insert(gametypeData.objectives[map], {pos = pos, objectiveClass = objectiveClass, data = additionalData})
    end
end

function GM:getGametype()
    return self.curGametype
end

GM:registerRush()
GM:registerUrbanWarfare()
GM:registerDrugBust()
GM:registerIntelRetrieval()
