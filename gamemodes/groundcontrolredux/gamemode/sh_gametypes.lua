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

--[[
-- the most barebones gametype, commented out because people kept picking it even though it's the most boring one and they thought it had respawns
-- you can use this as a base if you wish, but if you want to know what other methods gametype tables have, please take a look at other available gametypes

local tdm = {}
tdm.name = "tdm"
tdm.prettyName = "Team Deathmatch"

if SERVER then
    tdm.mapRotation = GM:getMapRotation("one_side_rush")
end

if SERVER then
    function tdm:postPlayerDeath(ply) -- check for round over possibility
        GAMEMODE:checkRoundOverPossibility(ply:Team())
    end

    function tdm:playerDisconnected(ply)
        local hisTeam = ply:Team()

        timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call postPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
            GAMEMODE:checkRoundOverPossibility(hisTeam, true)
        end)
    end

    function tdm:playerJoinTeam(ply, teamId)
        GAMEMODE:checkRoundOverPossibility(nil, true)
    end
end

GM:registerNewGametype(tdm)
]]--



-- ASSAULT GAMETYPE
-- fuck this gametype, its WACK
-- local assault = {}
-- assault.name = "assault"
-- assault.prettyName = "Assault"
-- assault.attackerTeam = TEAM_RED
-- assault.defenderTeam = TEAM_BLUE
-- assault.timeLimit = 315
-- assault.stopCountdown = true
-- assault.attackersPerDefenders = 3
-- assault.objectiveCounter = 0
-- assault.spawnDuringPreparation = true
-- assault.objectiveEnts = {}

-- if SERVER then
--     assault.mapRotation = GM:getMapRotation("assault_maps")
-- end

-- function assault:assignPointID(point)
--     self.objectiveCounter = self.objectiveCounter + 1
--     point.dt.PointID = self.objectiveCounter
-- end

-- function assault:arePointsFree()
--     local curTime = CurTime()

--     for key, obj in ipairs(self.objectiveEnts) do
--         if obj.winDelay and obj.winDelay > curTime then
--             return false
--         end
--     end

--     return true
-- end

-- function assault:prepare()
--     if CLIENT then
--         RunConsoleCommand("gc_team_selection")
--     end
-- end

-- function assault:think()
--     if !self.stopCountdown then
--         if GAMEMODE:hasTimeRunOut() and self:arePointsFree() then
--             GAMEMODE:endRound(self.defenderTeam)
--         end
--     end
-- end

-- function assault:playerInitialSpawn(ply)
--     if GAMEMODE.RoundsPlayed == 0 then
--         if #player.GetAll() >= 2 then
--             GAMEMODE:endRound(nil)
--         end
--     end
-- end

-- function assault:postPlayerDeath(ply) -- check for round over possibility
--     GAMEMODE:checkRoundOverPossibility(ply:Team())
-- end

-- function assault:playerDisconnected(ply)
--     local hisTeam = ply:Team()

--     timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call postPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
--         GAMEMODE:checkRoundOverPossibility(hisTeam, true)
--     end)
-- end

-- function assault.teamSwapCallback(player)
--     net.Start("GC_NEW_TEAM")
--     net.WriteInt(player:Team(), 16)
--     net.Send(player)
-- end

-- function assault:roundStart()
--     if SERVER then
--         GAMEMODE:swapTeams(self.attackerTeam, self.defenderTeam, assault.teamSwapCallback, assault.teamSwapCallback) -- swap teams on every round start

--         GAMEMODE:setTimeLimit(self.timeLimit)

--         self.realAttackerTeam = self.attackerTeam
--         self.realDefenderTeam = self.defenderTeam

--         table.Empty(self.objectiveEnts)
--         self.stopCountdown = false

--         GAMEMODE:initializeGameTypeEntities(self)
--     end
-- end

-- function assault:onRoundEnded(winTeam)
--     table.Empty(self.objectiveEnts)
--     self.stopCountdown = true
--     self.objectiveCounter = 0
-- end

-- function assault:playerJoinTeam(ply, teamId)
--     GAMEMODE:checkRoundOverPossibility(nil, true)
--     GAMEMODE:sendTimeLimit(ply)
--     ply:reSpectate()
-- end

-- function assault:deadDraw(w, h)
--     if GAMEMODE:getActivePlayerAmount() < 2 then
--         draw.ShadowText("This gametype requires at least 2 players, waiting for more people...", "CW_HUD20", w * 0.5, 15, GAMEMODE.HUDColors.white, GAMEMODE.HUDColors.black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--     end
-- end

-- GM:registerNewGametype(assault)

-- GM:addObjectivePositionToGametype("assault", "cs_jungle", Vector(560.8469, 334.9528, -127.9688), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
-- GM:addObjectivePositionToGametype("assault", "cs_jungle", Vector(1962.2684, 425.7988, -95.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
-- GM:addObjectivePositionToGametype("assault", "cs_jungle", Vector(1442.923218, 489.496857, -127.968758), "gc_offlimits_area", {distance = 2048, targetTeam = assault.defenderTeam, inverseFunctioning = true})

-- GM:addObjectivePositionToGametype("assault", "cs_siege_2010", Vector(3164.2295, -1348.2546, -143.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
-- GM:addObjectivePositionToGametype("assault", "cs_siege_2010", Vector(3983.9688, -480.3419, -47.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
-- GM:addObjectivePositionToGametype("assault", "cs_siege_2010", Vector(3878.5757, -1108.7665, -143.9687), "gc_offlimits_area", {distance = 2500, targetTeam = assault.defenderTeam, inverseFunctioning = true})

-- GM:addObjectivePositionToGametype("assault", "gc_outpost", Vector(4718.394, 1762.6437, 0.0313), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
-- GM:addObjectivePositionToGametype("assault", "gc_outpost", Vector(3947.8335, 2541.6055, 0.0313), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
-- GM:addObjectivePositionToGametype("assault", "gc_outpost", Vector(3147.9561, 1540.1907, -8.068), "gc_offlimits_area", {distance = 2048, targetTeam = assault.defenderTeam, inverseFunctioning = true})

-- GM:addObjectivePositionToGametype("assault", "rp_downtown_v2", Vector(686.9936, 1363.9843, -195.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
-- GM:addObjectivePositionToGametype("assault", "rp_downtown_v2", Vector(-144.8516, 1471.2026, -195.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
-- GM:addObjectivePositionToGametype("assault", "rp_downtown_v2", Vector(816.7338, 847.4449, -195.9687), "gc_offlimits_area", {distance = 1400, targetTeam = assault.defenderTeam, inverseFunctioning = true})

-- GM:addObjectivePositionToGametype("assault", "de_desert_atrocity_v3", Vector(384.5167, -1567.5787, -2.5376), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.defenderTeam, defenderTeam = assault.attackerTeam})
-- GM:addObjectivePositionToGametype("assault", "de_desert_atrocity_v3", Vector(3832.3855, -2022.0819, 248.0313), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.defenderTeam, defenderTeam = assault.attackerTeam})
-- GM:addObjectivePositionToGametype("assault", "de_desert_atrocity_v3", Vector(1898.58, -1590.46, 136.0313), "gc_offlimits_area", {distance = 2000, targetTeam = assault.attackerTeam, inverseFunctioning = true})

-- GM:addObjectivePositionToGametype("assault", "gc_depot_b2", Vector(-5565.1865, 832.9864, 128.0313), "gc_capture_point", {captureDistance = 150, capturerTeam = assault.defenderTeam, defenderTeam = assault.attackerTeam})
-- GM:addObjectivePositionToGametype("assault", "gc_depot_b2", Vector(-7676.4849, -597.2024, -351.9687), "gc_capture_point", {captureDistance = 150, capturerTeam = assault.defenderTeam, defenderTeam = assault.attackerTeam})
-- GM:addObjectivePositionToGametype("assault", "gc_depot_b2", Vector(-5108.8721, -1509.1794, -933.2501), "gc_offlimits_area_aabb", {distance = 2000, targetTeam = assault.attackerTeam, min = Vector(-5108.8721, -1509.1794, -933.2501), max = Vector(930.1258, 5336.1563, 686.4084)})

GM:registerRush()
GM:registerUrbanWarfare()
GM:registerDrugBust()
GM:registerIntelRetrieval()
