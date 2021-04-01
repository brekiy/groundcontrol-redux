AddCSLuaFile()

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
    local key, data = self:getGametypeFromConVar(targetName)

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

GM:registerNewGametype(tdm)]]--

local oneSideRush = {} -- one side rush because you only need to cap 1 point as the attacker
oneSideRush.name = "onesiderush"
oneSideRush.prettyName = "Rush"
oneSideRush.objectiveEnts = {}
oneSideRush.attackerTeam = TEAM_BLUE
oneSideRush.defenderTeam = TEAM_RED
oneSideRush.swappedTeams = false
oneSideRush.timeLimit = 195
oneSideRush.stopCountdown = true
oneSideRush.objectiveCounter = 0
oneSideRush.spawnDuringPreparation = true

if SERVER then
    oneSideRush.mapRotation = GM:getMapRotation("one_side_rush")
end

function oneSideRush:assignPointID(point)
    self.objectiveCounter = self.objectiveCounter + 1
    point.dt.PointID = self.objectiveCounter
end

function oneSideRush:prepare()
    if CLIENT then
        RunConsoleCommand("gc_team_selection")
    end
end

function oneSideRush:arePointsFree()
    local curTime = CurTime()

    for key, obj in ipairs(self.objectiveEnts) do
        if obj.winDelay > curTime then
            return false
        end
    end

    return true
end

function oneSideRush.teamSwapCallback(player)
    net.Start("GC_NEW_TEAM")
    net.WriteInt(player:Team(), 16)
    net.Send(player)
end

function oneSideRush:roundStart()
    if SERVER then
        if !self.swappedTeams and GAMEMODE.RoundsPlayed >= GAMEMODE.RoundsPerMap * 0.5 then
            -- if GAMEMODE.RoundsPlayed >= GetConVar("gc_rounds_per_map"):GetInt() * 0.5 then
                GAMEMODE:swapTeams(self.attackerTeam, self.defenderTeam, oneSideRush.teamSwapCallback, oneSideRush.teamSwapCallback)
                self.swappedTeams = true
        end

        GAMEMODE:setTimeLimit(self.timeLimit)

        self.realAttackerTeam = self.attackerTeam
        self.realDefenderTeam = self.defenderTeam
        table.Empty(self.objectiveEnts)
        self.stopCountdown = false

        GAMEMODE:initializeGameTypeEntities(self)
    end
end

function oneSideRush:think()
    if !self.stopCountdown and GAMEMODE:hasTimeRunOut() and self:arePointsFree() then
            GAMEMODE:endRound(self.realDefenderTeam)
    end
end

function oneSideRush:onTimeRanOut()
    GAMEMODE:endRound(self.defenderTeam)
end

function oneSideRush:onRoundEnded(winTeam)
    table.Empty(self.objectiveEnts)
    self.stopCountdown = true
    self.objectiveCounter = 0
end

function oneSideRush:postPlayerDeath(ply) -- check for round over possibility
    GAMEMODE:checkRoundOverPossibility(ply:Team())
end

function oneSideRush:playerDisconnected(ply)
    local hisTeam = ply:Team()

    timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call postPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
        GAMEMODE:checkRoundOverPossibility(hisTeam, true)
    end)
end
-- dunno why this wasn't defined initially...
function oneSideRush:playerInitialSpawn(ply)
    if GAMEMODE.RoundsPlayed == 0 and #player.GetAll() >= 2 then
        GAMEMODE:endRound(nil)
    end
end

function oneSideRush:playerJoinTeam(ply, teamId)
    GAMEMODE:checkRoundOverPossibility(nil, true)
    GAMEMODE:sendTimeLimit(ply)
    ply:reSpectate()
end

GM:registerNewGametype(oneSideRush)

GM:addObjectivePositionToGametype("onesiderush", "de_dust2", Vector(1147.345093, 2437.071045, 96.031250), "gc_capture_point")
GM:addObjectivePositionToGametype("onesiderush", "de_dust2", Vector(-1546.877197, 2657.465332, 1.431068), "gc_capture_point")

GM:addObjectivePositionToGametype("onesiderush", "de_port", Vector(-3131.584473, -2.002135, 640.031250), "gc_capture_point", {captureDistance = 256})
GM:addObjectivePositionToGametype("onesiderush", "de_port", Vector(1712.789551, 347.170563, 690.031250), "gc_capture_point", {captureDistance = 300})

GM:addObjectivePositionToGametype("onesiderush", "cs_compound", Vector(1934.429321, -1240.472046, 0.584229), "gc_capture_point", {captureDistance = 256, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "cs_compound", Vector(1772.234375, 623.238525, 0.031250), "gc_capture_point", {captureDistance = 256, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "cs_havana", Vector(890.551331, 652.600220, 256.031250), "gc_capture_point", {captureDistance = 256, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "cs_havana", Vector(93.409294, 2024.913696, 16.031250), "gc_capture_point", {captureDistance = 256, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "de_aztec", Vector(-290.273560, -1489.696289, -226.568970), "gc_capture_point", {captureDistance = 256})
GM:addObjectivePositionToGametype("onesiderush", "de_aztec", Vector(-1846.402222, 1074.247803, -221.927124), "gc_capture_point", {captureDistance = 256})

GM:addObjectivePositionToGametype("onesiderush", "de_cbble", Vector(-2751.983643, -1788.725342, 48.025673), "gc_capture_point", {captureDistance = 256})
GM:addObjectivePositionToGametype("onesiderush", "de_cbble", Vector(824.860535, -977.904724, -127.968750), "gc_capture_point", {captureDistance = 256})

GM:addObjectivePositionToGametype("onesiderush", "de_chateau", Vector(137.296066, 999.551453, 0.031250), "gc_capture_point", {captureDistance = 256})
GM:addObjectivePositionToGametype("onesiderush", "de_chateau", Vector(2242.166260, 1220.794800, 0.031250), "gc_capture_point", {captureDistance = 256})

GM:addObjectivePositionToGametype("onesiderush", "de_dust", Vector(122.117203, -1576.552856, 64.031250), "gc_capture_point", {captureDistance = 256})
GM:addObjectivePositionToGametype("onesiderush", "de_dust", Vector(1998.848999, 594.460327, 3.472847), "gc_capture_point", {captureDistance = 256})

GM:addObjectivePositionToGametype("onesiderush", "de_inferno", Vector(2088.574707, 445.291107, 160.031250), "gc_capture_point", {captureDistance = 256})
GM:addObjectivePositionToGametype("onesiderush", "de_inferno", Vector(396.628296, 2605.968750, 164.031250), "gc_capture_point", {captureDistance = 256})

GM:addObjectivePositionToGametype("onesiderush", "de_nuke", Vector(706.493347, -963.940552, -415.968750), "gc_capture_point", {captureDistance = 256})
GM:addObjectivePositionToGametype("onesiderush", "de_nuke", Vector(619.076172, -955.975037, -767.968750), "gc_capture_point", {captureDistance = 256})

GM:addObjectivePositionToGametype("onesiderush", "de_piranesi", Vector(-1656.252563, 2382.538818, 224.031250), "gc_capture_point", {captureDistance = 256})
GM:addObjectivePositionToGametype("onesiderush", "de_piranesi", Vector(-258.952271, -692.915649, 96.031250), "gc_capture_point", {captureDistance = 256})

GM:addObjectivePositionToGametype("onesiderush", "de_tides", Vector(-182.13874816895, -425.63604736328, 0.03125), "gc_capture_point", {captureDistance = 230})
GM:addObjectivePositionToGametype("onesiderush", "de_tides", Vector(-1120.269531, -1442.878418, -122.518227), "gc_capture_point", {captureDistance = 230})

GM:addObjectivePositionToGametype("onesiderush", "dm_runoff", Vector(10341.602539, 1974.626709, -255.968750), "gc_capture_point", {captureDistance = 256})

GM:addObjectivePositionToGametype("onesiderush", "de_train", Vector(1322.792725, -250.027832, -215.968750), "gc_capture_point", {captureDistance = 192})
GM:addObjectivePositionToGametype("onesiderush", "de_train", Vector(32.309258, -1397.823120, -351.968750), "gc_capture_point", {captureDistance = 192})

GM:addObjectivePositionToGametype("onesiderush", "cs_assault", Vector(6733.837402, 4496.704590, -861.968750), "gc_capture_point", {captureDistance = 220, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "cs_assault", Vector(6326.040527, 4106.064453, -606.738403), "gc_capture_point", {captureDistance = 220, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "de_prodigy", Vector(408.281616, -492.238770, -207.968750), "gc_capture_point", {captureDistance = 220})
GM:addObjectivePositionToGametype("onesiderush", "de_prodigy", Vector(1978.739258, -277.940277, -415.968750), "gc_capture_point", {captureDistance = 220})

GM:addObjectivePositionToGametype("onesiderush", "de_desert_atrocity_v3", Vector(384.5167, -1567.5787, -2.5376), "gc_capture_point", {captureDistance = 200})
GM:addObjectivePositionToGametype("onesiderush", "de_desert_atrocity_v3", Vector(3832.3855, -2022.0819, 248.0313), "gc_capture_point", {captureDistance = 200})

GM:addObjectivePositionToGametype("onesiderush", "de_secretcamp", Vector(90.6324, 200.1089, -87.9687), "gc_capture_point", {captureDistance = 200})
GM:addObjectivePositionToGametype("onesiderush", "de_secretcamp", Vector(-45.6821, 1882.2468, -119.9687), "gc_capture_point", {captureDistance = 200})

GM:addObjectivePositionToGametype("onesiderush", "cs_jungle", Vector(560.8469, 334.9528, -127.9688), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "cs_jungle", Vector(1962.2684, 425.7988, -95.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "cs_siege_2010", Vector(3164.2295, -1348.2546, -143.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "cs_siege_2010", Vector(3983.9688, -480.3419, -47.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "gc_outpost", Vector(4718.394, 1762.6437, 0.0313), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "gc_outpost", Vector(3947.8335, 2541.6055, 0.0313), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "rp_downtown_v2", Vector(686.9936, 1363.9843, -195.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "rp_downtown_v2", Vector(-144.8516, 1471.2026, -195.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "gc_depot_b2", Vector(-5565.1865, 832.9864, 128.0313), "gc_capture_point", {captureDistance = 150, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "gc_depot_b2", Vector(-7676.4849, -597.2024, -351.9687), "gc_capture_point", {captureDistance = 150, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "nt_isolation", Vector(-586.738, -859.093, 411.031), "gc_capture_point", {captureDistance = 300, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "nt_isolation", Vector(-2419.906, 329.347, 158.344), "gc_capture_point", {captureDistance = 300, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "nt_marketa", Vector(-92.797, 323.37, 34.39), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "nt_marketa", Vector(657.203, 621.576, 215.031), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "nt_redlight", Vector(1107.868, 529.97, 36.86), "gc_capture_point", {captureDistance = 225})
GM:addObjectivePositionToGametype("onesiderush", "nt_redlight", Vector(113.076, -592.264, 37.031), "gc_capture_point", {captureDistance = 225})

GM:addObjectivePositionToGametype("onesiderush", "nt_rise", Vector(507.465, 68.648, -524.883), "gc_capture_point", {captureDistance = 225, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "nt_rise", Vector(-102.238, 732.526, -559.968), "gc_capture_point", {captureDistance = 225, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "nt_dusk", Vector(389.854, 1686.257, -40.989), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "nt_dusk", Vector(47.565, 4688.481, -167.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "nt_skyline", Vector(-50.813, 392.031, -127.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "nt_skyline", Vector(152.424, 1071.968, -120.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "nt_transit", Vector(-886.097, 249.77, -127.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "nt_transit", Vector(182.765, 368.824, -133.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("onesiderush", "nt_shrine", Vector(-768.155, 1988.454, 90.031), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
GM:addObjectivePositionToGametype("onesiderush", "nt_shrine", Vector(922.37, 3423.223, 78.907), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

GM:addObjectivePositionToGametype("contendedpoint", "rp_outercanals", Vector(-1029.633667, -22.739532, 0.031250), "gc_contended_point", {captureDistance = 384})

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


local urbanwarfare = {}
urbanwarfare.name = "urbanwarfare"
urbanwarfare.prettyName = "Urban Warfare"
urbanwarfare.timeLimit = 315
urbanwarfare.waveTimeLimit = 135
urbanwarfare.attackersPerDefenders = 3
urbanwarfare.objectiveCounter = 0
urbanwarfare.spawnDuringPreparation = true
urbanwarfare.objectiveEnts = {}
urbanwarfare.startingTickets = 100 -- the amount of tickets that a team starts with
urbanwarfare.ticketsPerPlayer = 2.5 -- amount of tickets to increase per each player on server
urbanwarfare.capturePoint = nil -- the entity responsible for a bulk of the gametype logic, the reference to it is assigned when it is initialized
urbanwarfare.waveWinReward = {cash = 50, exp = 50}

if SERVER then
    urbanwarfare.mapRotation = GM:getMapRotation("urbanwarfare_maps")
end

function urbanwarfare:assignPointID(point)
    self.objectiveCounter = self.objectiveCounter + 1
    point.dt.PointID = self.objectiveCounter
end

function urbanwarfare:endWave(capturer, noTicketDrainForWinners)
    self.waveEnded = true

    timer.Simple(0, function()
        for key, ent in ipairs(ents.FindByClass("cw_dropped_weapon")) do
            SafeRemoveEntity(ent)
        end

        GAMEMODE:balanceTeams(true)

        if capturer then
            local opposingTeam = GAMEMODE.OpposingTeam[capturer]

            if self.capturePoint:getTeamTickets(opposingTeam) == 0 then
                GAMEMODE:endRound(capturer)
            end
        else
            self:checkEndWaveTickets(TEAM_RED)
            self:checkEndWaveTickets(TEAM_BLUE)
        end

        self:spawnPlayersNewWave(capturer, TEAM_RED, (capturer and (noTicketDrainForWinners and TEAM_RED == capturer)))
        self:spawnPlayersNewWave(capturer, TEAM_BLUE, (capturer and (noTicketDrainForWinners and TEAM_BLUE == capturer)))
        self.waveEnded = false

        GAMEMODE:resetAllKillcountData()
        GAMEMODE:sendAlivePlayerCount()
    end)
end

function urbanwarfare:checkEndWaveTickets(teamID)
    if self.capturePoint:getTeamTickets(teamID) == 0 then
        GAMEMODE:endRound(GAMEMODE.OpposingTeam[teamID])
    end
end

function urbanwarfare:spawnPlayersNewWave(capturer, teamID, isFree)
    local bypass = false
    local players = team.GetPlayers(teamID)

    if capturer and capturer != teamID then
        local alive = 0

        for key, ply in ipairs(players) do
            if ply:Alive() then
                alive = alive + 1
            end
        end

        -- if the enemy team captured the point and noone died on the loser team, then that teams will lose tickets equivalent to the amount of players in their team
        bypass = alive == #players
    end

    local lostTickets = 0

    for key, ply in ipairs(players) do
        if !isFree or bypass then
            self.capturePoint:drainTicket(teamID)
            lostTickets = lostTickets + 1
        end

        if !ply:Alive() then
            ply:Spawn()
        end

        if capturer == teamID then
            ply:addCurrency(self.waveWinReward.cash, self.waveWinReward.exp, "WAVE_WON")
        end
    end

    for key, ply in ipairs(players) do
        net.Start("GC_NEW_WAVE")
        net.WriteInt(lostTickets, 16)
        net.Send(ply)
    end
end

function urbanwarfare:postPlayerDeath(ply) -- check for round over possibility
    self:checkTickets(ply:Team())
end

function urbanwarfare:playerDisconnected(ply)
    local hisTeam = ply:Team()

    timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call postPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
        self:checkTickets(hisTeam)
    end)
end

function urbanwarfare:checkTickets(teamID)
    if !IsValid(self.capturePoint) then
        return
    end

    if self.capturePoint:getTeamTickets(teamID) == 0 then
        GAMEMODE:checkRoundOverPossibility(teamID)
    else
        self:checkWaveOverPossibility(teamID)
    end
end

function urbanwarfare:checkWaveOverPossibility(teamID)
    local players = team.GetAlivePlayers(teamID)

    if players == 0 then
        self.capturePoint:endWave(GAMEMODE.OpposingTeam[teamID], true)
    end
end

function urbanwarfare:prepare()
    if CLIENT then
        RunConsoleCommand("gc_team_selection")
    else
        GAMEMODE.RoundsPerMap = 4
    end
end

function urbanwarfare:onRoundEnded(winTeam)
    self.objectiveCounter = 0
end

function urbanwarfare:playerJoinTeam(ply, teamId)
    GAMEMODE:checkRoundOverPossibility(nil, true)
    GAMEMODE:sendTimeLimit(ply)
    ply:reSpectate()
end

function urbanwarfare:playerInitialSpawn(ply)
    if GAMEMODE.RoundsPlayed == 0 and #player.GetAll() >= 2 then
        GAMEMODE:endRound(nil)
        GAMEMODE.RoundsPlayed = 1
    end
end

function urbanwarfare:roundStart()
    if SERVER then
        GAMEMODE:initializeGameTypeEntities(self)
    end
end

GM:registerNewGametype(urbanwarfare)

GM:addObjectivePositionToGametype("urbanwarfare", "rp_downtown_v4c_v2", Vector(-817.765076, -1202.352417, -195.968750), "gc_urban_warfare_capture_point", {capMin = Vector(-1022.9687, -952.0312, -196), capMax = Vector(-449.0312, -1511.9696, 68.0313)})

GM:addObjectivePositionToGametype("urbanwarfare", "ph_skyscraper_construct", Vector(2.9675, -558.3918, -511.9687), "gc_urban_warfare_capture_point", {capMin = Vector(-159.9687, -991.9687, -515), capMax = Vector(143.6555, -288.0312, -440)})

GM:addObjectivePositionToGametype("urbanwarfare", "de_desert_atrocity_v3", Vector(2424.1348, -920.4495, 120.0313), "gc_urban_warfare_capture_point", {capMin = Vector(2288.031250, -816.031250, 120.031250), capMax = Vector(2598.074951, -1092.377441, 200)})

GM:addObjectivePositionToGametype("urbanwarfare", "nt_isolation", Vector(-553.745, -827.579, 401.031), "gc_urban_warfare_capture_point", {capMin = Vector(-48.781, -422.024, 339.031), capMax = Vector(-1092.570, -1140.968, 423.031)})

GM:addObjectivePositionToGametype("urbanwarfare", "dm_zavod_yantar", Vector(-397.236969, 1539.315308, 743.031250), "gc_urban_warfare_capture_point", {capMin = Vector(172.090851, 1113.220947, 543.680664), capMax = Vector(-992.968750, 2007.968750, 1003.031250)})

GM:addObjectivePositionToGametype("urbanwarfare", "nt_marketa", Vector(315.07, 1008.616, 206.031), "gc_urban_warfare_capture_point", {capMin = Vector(167.665, 1202.217, 206.031), capMax = Vector(442.073, 786.566, 347.967)})

GM:addObjectivePositionToGametype("urbanwarfare", "nt_redlight", Vector(-25.995, 289.58, 33.031), "gc_urban_warfare_capture_point", {capMin = Vector(607.396, 388.482, 100.031), capMax = Vector(-783.968, -153.168, 32.031)})

GM:addObjectivePositionToGametype("urbanwarfare", "nt_rise", Vector(-176.031, 672.708, -559.968), "gc_urban_warfare_capture_point", {capMin = Vector(18.337, 1065.509, -559.968), capMax = Vector(-495.968, 360.031, -559.968)})

GM:addObjectivePositionToGametype("urbanwarfare", "nt_dusk", Vector(78.944, 2896.031, -44.939), "gc_urban_warfare_capture_point", {capMin = Vector(488.873, 1524.945, -52.429), capMax = Vector(-413.863, 4536.108, -188.956)})

GM:addObjectivePositionToGametype("urbanwarfare", "nt_skyline", Vector(78.944, 2896.031, -44.939), "gc_urban_warfare_capture_point", {capMin = Vector(-479.007, -498.685, 0.031), capMax = Vector(578.683, 559.266, -129.968)})

GM:addObjectivePositionToGametype("urbanwarfare", "nt_transit", Vector(-173.56, -119.268, -127.968), "gc_urban_warfare_capture_point", {capMin = Vector(219.217, -310.638, -133.968), capMax = Vector(-601.865, 35.149, -23.968)})

GM:addObjectivePositionToGametype("urbanwarfare", "nt_shrine", Vector(-908.194, 3617.923, 134.252), "gc_urban_warfare_capture_point", {capMin = Vector(-1444.414, 4119.525, 88.47), capMax = Vector(-170.031, 3000.031, 88.031)})

local ghettoDrugBust = {}
ghettoDrugBust.name = "ghettodrugbust"
ghettoDrugBust.prettyName = "Ghetto Drug Bust"
ghettoDrugBust.preventManualTeamJoining = true
ghettoDrugBust.swatTeam = TEAM_RED
ghettoDrugBust.gangTeam = TEAM_BLUE
ghettoDrugBust.timeLimit = 195
ghettoDrugBust.stopCountdown = true
ghettoDrugBust.noTeamBalance = true
ghettoDrugBust.magsToGive = 3
ghettoDrugBust.bandagesToGive = 4
ghettoDrugBust.objectiveEnts = {}
ghettoDrugBust.objectiveCounter = 0
ghettoDrugBust.blueGuyPer = 2.5 -- for every 3rd player, 1 will be a red dude
ghettoDrugBust.voiceOverride = {[ghettoDrugBust.gangTeam] = "ghetto"}
ghettoDrugBust.objectives = {}

ghettoDrugBust.cashPerDrugReturn = 50
ghettoDrugBust.expPerDrugReturn = 50

ghettoDrugBust.cashPerDrugCapture = 100
ghettoDrugBust.expPerDrugCapture = 100

ghettoDrugBust.cashPerDrugCarrierKill = 25
ghettoDrugBust.expPerDrugCarrierKill = 25

ghettoDrugBust.grenadeChance = 20 -- chance that a ghetto team player will receive a grenade upon spawn

ghettoDrugBust.invertedSpawnpoints = {
    de_chateau = true
}
ghettoDrugBust.redTeamWeapons = {
    {weapon = "cw_ak74", chance = 3, mags = 1},
    {weapon = "cw_shorty", chance = 8, mags = 12},
    {weapon = "cw_mac11", chance = 10, mags = 1},
    {weapon = "cw_deagle", chance = 15, mags = 2},
    {weapon = "cw_mr96", chance = 17, mags = 3},
    {weapon = "cw_fiveseven", chance = 35, mags = 2},
    {weapon = "cw_m1911", chance = 40, mags = 4},
    {weapon = "cw_p99", chance = 66, mags = 3},
    {weapon = "cw_makarov", chance = 100, mags = 7}
}

ghettoDrugBust.sidewaysHoldingWeapons = {
    cw_deagle = true,
    cw_mr96 = true,
    cw_fiveseven = true,
    cw_m1911 = true,
    cw_p99 = true,
    cw_makarov = true
}

ghettoDrugBust.sidewaysHoldingBoneOffsets = {
    cw_mr96 = {["Bip01 L UpperArm"] = {target = Vector(0, -30, 0), current = Vector(0, 0, 0)}},
    cw_m1911 = {["arm_controller_01"] = {target = Vector(0, 0, -30), current = Vector(0, 0, 0)}},
    cw_p99 = {["l_forearm"] = {target = Vector(0, 0, 30), current = Vector(0, 0, 0)}},
    cw_fiveseven = {["arm_controller_01"] = {target = Vector(0, 0, -30), current = Vector(0, 0, 0)}},
    cw_makarov = {["Left_U_Arm"] = {target = Vector(30, 0, 0), current = Vector(0, 0, 0)}},
    cw_deagle = {["arm_controller_01"] = {target = Vector(0, 0, -30), current = Vector(0, 0, 0)}},
}

if SERVER then
    ghettoDrugBust.mapRotation = GM:getMapRotation("ghetto_drug_bust_maps")
end

function ghettoDrugBust:skipAttachmentGive(ply)
    return ply:Team() == self.gangTeam
end

function ghettoDrugBust:canHaveAttachments(ply)
    return ply:Team() == self.swatTeam
end

function ghettoDrugBust:canReceiveLoadout(ply)
    ply:Give(GAMEMODE.KnifeWeaponClass)
    return ply:Team() == self.swatTeam
end

function ghettoDrugBust:pickupDrugs(drugEnt, ply)
    local team = ply:Team()

    if team == self.swatTeam then
        if !ply.hasDrugs then
            self:giveDrugs(ply)
            return true
        end
    elseif team == self.gangTeam then
        if drugEnt.dt.Dropped and !ply.hasDrugs then
            self:giveDrugs(ply)
            GAMEMODE:startAnnouncement("ghetto", "return_drugs", CurTime(), nil, ply)
            return true
        end
    end
end

function ghettoDrugBust:playerDeath(ply, attacker, dmginfo)
    if ply.hasDrugs then
        if IsValid(attacker) and ply != attacker and attacker:IsPlayer() then
            local plyTeam = ply:Team()
            local attackerTeam = attacker:Team()

            if plyTeam != attackerTeam then -- we grant the killer a cash and exp bonus if they kill the drug carrier of the opposite team
                attacker:addCurrency(self.cashPerDrugCarrierKill, self.expPerDrugCarrierKill, "KILLED_DRUG_CARRIER")
            end
        end

        GAMEMODE:startAnnouncement("ghetto", "retrieve_drugs", CurTime(), self.gangTeam)

        ghettoDrugBust:dropDrugs(ply)
    end
end

function ghettoDrugBust:giveDrugs(ply)
    if ply:Team() == self.swatTeam then
        GAMEMODE:startAnnouncement("ghetto", "drugs_stolen", CurTime(), self.gangTeam)
    end

    ply.hasDrugs = true
    SendUserMessage("GC_GOT_DRUGS", ply)
end

function ghettoDrugBust:dropDrugs(ply)
    local pos = ply:GetPos()
    pos.z = pos.z + 20

    local ent = ents.Create("gc_drug_package")
    ent:SetPos(pos)
    ent:SetAngles(AngleRand())
    ent:Spawn()
    ent:wakePhysics()
    ent.dt.Dropped = true

    ply.hasDrugs = false
end

function ghettoDrugBust:resetRoundData()
    for key, ply in ipairs(player.GetAll()) do
        ply.hasDrugs = false
    end
end

function ghettoDrugBust:removeDrugs(ply)
    ply.hasDrugs = false
    net.Start("GC_DRUGS_REMOVED")
    net.Send(ply)
    SendUserMessage("GC_DRUGS_REMOVED", ply)
end

function ghettoDrugBust:attemptReturnDrugs(player, host)
    local team = player:Team()

    if team == ghettoDrugBust.gangTeam and player.hasDrugs and !host.dt.HasDrugs then
        ghettoDrugBust:removeDrugs(player)

        host:createDrugPackageObject()
        player:addCurrency(self.cashPerDrugReturn, self.expPerDrugReturn, "RETURNED_DRUGS")
        GAMEMODE:startAnnouncement("ghetto", "drugs_retrieved", CurTime(), nil, player)
    end
end

function ghettoDrugBust:attemptCaptureDrugs(player, host)
    local team = player:Team()

    if team == ghettoDrugBust.swatTeam and player.hasDrugs then
        ghettoDrugBust:removeDrugs(player)

        player:addCurrency(self.cashPerDrugCapture, self.expPerDrugCapture, "SECURED_DRUGS")
        GAMEMODE:startAnnouncement("ghetto", "drugs_secured", CurTime(), self.gangTeam)
        return true
    end
end

function ghettoDrugBust:playerDisconnected(ply)
    if ply.hasDrugs then
        self:dropDrugs(ply)
    end

    local hisTeam = ply:Team()

    timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call postPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
        GAMEMODE:checkRoundOverPossibility(hisTeam, true)
    end)
end

function ghettoDrugBust:playerSpawn(ply)
    ply.hasDrugs = false

    if ply:Team() != self.swatTeam then
        CustomizableWeaponry:removeAllAttachments(ply)
        ply:StripWeapons()
        ply:RemoveAllAmmo()
        ply:resetGadgetData()
        ply:applyTraits()

        ply:resetArmorData()
        ply:resetHelmetData()
        ply:sendArmor()
        ply:sendHelmet()

        local pickedWeapon = nil

        for key, weaponData in ipairs(self.redTeamWeapons) do
            if math.random(1, 100) <= weaponData.chance then
                pickedWeapon = weaponData
                break
            end
        end

        -- if for some reason the chance roll failed and no weapon was chosen, we pick one at random
        pickedWeapon = pickedWeapon or self.redTeamWeapons[math.random(1, #self.redTeamWeapons)]

        local randIndex = self.redTeamWeapons[math.random(1, #self.redTeamWeapons)]
        local givenWeapon = ply:Give(pickedWeapon.weapon)

        ply:GiveAmmo(pickedWeapon.mags * givenWeapon.Primary.ClipSize_Orig, givenWeapon.Primary.Ammo)
        givenWeapon:maxOutWeaponAmmo(givenWeapon.Primary.ClipSize_Orig)

        if math.random(1, 100) <= ghettoDrugBust.grenadeChance then
            ply:GiveAmmo(1, "Frag Grenades")
        end
    end
end

function ghettoDrugBust:getDesiredBandageCount(ply)
    if ply:Team() != self.swatTeam then
        return self.bandagesToGive
    end

    return nil
end

function ghettoDrugBust:think()
    if !self.stopCountdown then
        if GAMEMODE:hasTimeRunOut() then
            GAMEMODE:endRound(self.gangTeam)
        end

        local curTime = CurTime()
    end
end

function ghettoDrugBust:playerInitialSpawn(ply)
    if GAMEMODE.RoundsPlayed == 0 and #player.GetAll() >= 2 then
        GAMEMODE:endRound(nil)
    end
end

function ghettoDrugBust:postPlayerDeath(ply) -- check for round over possibility
    GAMEMODE:checkRoundOverPossibility(ply:Team())
end

function ghettoDrugBust:roundStart()
    if SERVER then
        local players = player.GetAll()
        local gearGuys = math.max(math.floor(#players / self.blueGuyPer), 1) -- aka the dudes who get the cool gear
        GAMEMODE:setTimeLimit(self.timeLimit)
        self.stopCountdown = false

        for i = 1, gearGuys do
            local randomIndex = math.random(1, #players)
            local dude = players[randomIndex]

            if dude then
                dude:SetTeam(self.swatTeam)

                table.remove(players, randomIndex)
            end
        end

        for key, ply in ipairs(players) do
            ply:SetTeam(self.gangTeam)
        end

        GAMEMODE:initializeGameTypeEntities(self)
    end
end

function ghettoDrugBust:onRoundEnded(winTeam)
    table.Empty(self.objectiveEnts)
    self.stopCountdown = true
    self.objectiveCounter = 0
end

function ghettoDrugBust:deadDraw(w, h)
    if GAMEMODE:getActivePlayerAmount() < 2 then
        draw.ShadowText("This gametype requires at least 2 players, waiting for more people...", "CW_HUD20", w * 0.5, 15, GAMEMODE.HUDColors.white, GAMEMODE.HUDColors.black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function ghettoDrugBust:adjustSpawnpoint(ply, plyTeam)
    if self.invertedSpawnpoints[GAMEMODE.CurMap] then
        return GAMEMODE.OpposingTeam[plyTeam]
    end

    return nil
end

GM:registerNewGametype(ghettoDrugBust)

GM:addObjectivePositionToGametype("ghettodrugbust", "cs_assault", Vector(6794.2886, 3867.2642, -575.0213), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_assault", Vector(4907.146, 6381.4331, -871.9687), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "cs_compound", Vector(2303.8857, -710.6038, 31.016), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_compound", Vector(2053.3057, -1677.0895, 56.0783), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_compound", Vector(2119.7871, 2032.4009, 8.0313), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "cs_havana", Vector(415.6184, 1283.9724, 281.7604), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_havana", Vector(196.039, 807.587, 282.6608), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_havana", Vector(-255.9446, -774.599, 0.0313), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "cs_militia", Vector(171.7497, 754.8995, -115.9687), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_militia", Vector(1287.92, 635.789, -120.620), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_militia", Vector(489.6373, -2447.677, -169.529), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "cs_italy", Vector(740.9838, 2303.0881, 168.4486), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_italy", Vector(-382.8103, 1900.0341, -119.9687), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "cs_italy", Vector(-697.3092, -1622.7435, -239.9687), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "de_chateau", Vector(99.3907, 919.5341, 24.0313), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "de_chateau", Vector(2081.2983, 1444.7068, 36.0313), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "de_chateau", Vector(1662.7606, -662.5977, -159.9687), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "de_inferno", Vector(-572.666, -435.3488, 228.9928), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "de_inferno", Vector(-32.3297, 549.7234, 83.4212), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "de_inferno", Vector(2377.4863, 2517.3298, 131.9956), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "de_shanty_v3_fix", Vector(497.7796, -1688.5574, 21.6237), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "de_shanty_v3_fix", Vector(-203.0704, -1800.5228, 165.4134), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "de_shanty_v3_fix", Vector(534.512, 19.6704, 6.9165), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "gm_blackbrook_asylum", Vector(784.7302, -224.303, 390.031), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "gm_blackbrook_asylum", Vector(391.3977, 289.818939, 520.03125), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "gm_blackbrook_asylum", Vector(-470.82025146484, 329.79114, 1.03125), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "nt_isolation", Vector(-668.997, -908.508, 347.031), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_isolation", Vector(-2419.906, 329.347, 158.344), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_isolation", Vector(1214.574, 2681.112, 152.780), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "nt_marketa", Vector(-735.212, 1331.367, 35.031), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_marketa", Vector(684.374, 1265.75, 39.031), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_marketa", Vector(318.746, -1410.498, 34.031), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "nt_redlight", Vector(-272.03, 621.03, 96.03), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_redlight", Vector(-657.96, -875.49, 104.03), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_redlight", Vector(1591.913, -1402.049, 33.031), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "nt_rise", Vector(75.829, 276.173, -847.968), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_rise", Vector(-343.012, 805.753, -559.968), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_rise", Vector(311.216, -247.248, -216.879), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "nt_dusk", Vector(357.424, 2568.138, -221.933), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_dusk", Vector(-31.3, 4883.031, -167.968), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_dusk", Vector(-1773.096, 3429.306, -191.968), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "nt_skyline", Vector(89.317, 148.282, -127.968), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_skyline", Vector(284.703, 1128.617, -120.968), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_skyline", Vector(-1357.663, 86.206, 220.031), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "nt_transit", Vector(-617.042, 393.701, -113.002), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_transit", Vector(238.325, 384.474, -112.885), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_transit", Vector(-334.29, -1388.189, 112.042), "gc_drug_capture_point")

GM:addObjectivePositionToGametype("ghettodrugbust", "nt_shrine", Vector(-568.914, 1925.868, 102.251), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_shrine", Vector(832.32, 3529.435, 136.397), "gc_drug_point")
GM:addObjectivePositionToGametype("ghettodrugbust", "nt_shrine", Vector(-2469.47, 5674.688, 128.031), "gc_drug_capture_point")
