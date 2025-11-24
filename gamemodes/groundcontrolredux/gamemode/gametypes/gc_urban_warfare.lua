AddCSLuaFile()

function GM:RegisterUrbanWarfare()
    local urbanwarfare = {}
    urbanwarfare.name = "urban_warfare"
    urbanwarfare.prettyName = "Urban Warfare"
    urbanwarfare.timeLimit = 315
    urbanwarfare.waveTimeLimit = 135
    urbanwarfare.objectiveCounter = 0
    urbanwarfare.spawnDuringPreparation = true
    urbanwarfare.objectiveEnts = {}
    urbanwarfare.startingTickets = 100 -- the amount of tickets that a team starts with
    urbanwarfare.ticketsPerPlayer = 3 -- amount of tickets to increase per each player on server
    urbanwarfare.capturePoint = nil -- the entity responsible for a bulk of the gametype logic, the reference to it is assigned when it is initialized
    urbanwarfare.waveWinReward = {cash = 50, exp = 50}

    if SERVER then
        urbanwarfare.mapRotation = GM:GetMapRotation("urban_warfare_maps")
    end

    function urbanwarfare:AssignPointID(point)
        self.objectiveCounter = self.objectiveCounter + 1
        point:SetPointID(self.objectiveCounter)
    end

    function urbanwarfare:EndWave(capturer, noTicketDrainForWinners)
        self.waveEnded = true

        timer.Simple(0, function()
            for key, ent in ipairs(ents.FindByClass("cw_dropped_weapon")) do
                SafeRemoveEntity(ent)
            end

            GAMEMODE:BalanceTeams(true)

            if capturer then
                local opposingTeam = GAMEMODE.OpposingTeam[capturer]

                if self.capturePoint:GetTeamTickets(opposingTeam) == 0 then
                    GAMEMODE:EndRound(capturer)
                end
            else
                self:checkEndWaveTickets(TEAM_RED)
                self:checkEndWaveTickets(TEAM_BLUE)
            end

            self:spawnPlayersNewWave(capturer, TEAM_RED, capturer and (noTicketDrainForWinners and TEAM_RED == capturer))
            self:spawnPlayersNewWave(capturer, TEAM_BLUE, capturer and (noTicketDrainForWinners and TEAM_BLUE == capturer))
            self.waveEnded = false

            GAMEMODE:ResetAllKillcountData()
            GAMEMODE:SendAlivePlayerCount()
        end)
    end

    function urbanwarfare:checkEndWaveTickets(teamID)
        if self.capturePoint:GetTeamTickets(teamID) == 0 then
            GAMEMODE:EndRound(GAMEMODE.OpposingTeam[teamID])
        end
    end

    function urbanwarfare:spawnPlayersNewWave(capturer, teamID, isFree)
        local bypass = false
        local players = team.GetPlayers(teamID)

        -- get the number of living players on our team if the enemy team captured the point
        if capturer and capturer != teamID then
            local alive = 0

            for key, ply in ipairs(players) do
                if ply:Alive() then
                    alive = alive + 1
                end
            end

            -- if our entire team was alive and the point was captured, we lose tickets equivalent to the total team size
            -- penalizes teams that let the point get capped uncontested
            bypass = alive == #players
        end

        local lostTickets = 0
        local teamHasTickets = self.capturePoint:GetTeamTickets(teamID) > 0
        if bypass then
            -- skip the spawn loop and just drain all tickets, we lost the point and everyone's alive
            lostTickets = #players
        else
            for key, ply in ipairs(players) do
                if teamHasTickets and !ply:Alive() then
                    ply:Spawn()
                    if !isFree then
                        self.capturePoint:drainTicket(teamID)
                        lostTickets = lostTickets + 1
                    end
                end
                if capturer == teamID then
                    ply:AddCurrency("WAVE_WON", self.waveWinReward.cash, self.waveWinReward.exp)
                end
            end
        end

        for key, ply in ipairs(players) do
            net.Start("GC_NEW_WAVE")
            net.WriteInt(lostTickets, 16)
            net.Send(ply)
        end
    end

    function urbanwarfare:PostPlayerDeath(ply) -- check for round over possibility
        self:checkTickets(ply:Team())
    end

    function urbanwarfare:PlayerDisconnected(ply)
        local plyTeam = ply:Team()

        timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call PostPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
            self:checkTickets(plyTeam)
        end)
    end

    function urbanwarfare:checkTickets(teamID)
        if !IsValid(self.capturePoint) then
            return
        end

        if self.capturePoint:GetTeamTickets(teamID) == 0 then
            GAMEMODE:CheckRoundOverPossibility(teamID)
        else
            self:checkWaveOverPossibility(teamID)
        end
    end

    function urbanwarfare:checkWaveOverPossibility(teamID)
        local players = team.GetAlivePlayers(teamID)

        if players == 0 then
            self.capturePoint:EndWave(GAMEMODE.OpposingTeam[teamID], true)
        end
    end

    function urbanwarfare:Prepare()
        if CLIENT then
            RunConsoleCommand("gc_team_selection")
        else
            GAMEMODE.RoundsPerMap = GetConVar("gc_urban_warfare_rounds_per_map"):GetInt()
        end
    end

    function urbanwarfare:OnRoundEnded(winTeam)
        self.objectiveCounter = 0
    end

    function urbanwarfare:PlayerJoinTeam(ply, teamId)
        GAMEMODE:CheckRoundOverPossibility(nil, true)
        GAMEMODE:SendTimeLimit(ply)
        ply:reSpectate()
    end

    function urbanwarfare:PlayerInitialSpawn(ply)
        if GAMEMODE.RoundsPlayed == 0 and player.GetCount() >= 2 then
            GAMEMODE:EndRound(nil)
            GAMEMODE.RoundsPlayed = 1
        end
    end

    function urbanwarfare:RoundStart()
        if SERVER then
            GAMEMODE:InitializeGameTypeEntities(self)
        end
    end

    GM:RegisterNewGametype(urbanwarfare)

    GM:AddObjectivePositionToGametype("urban_warfare", "rp_downtown_v4c_v2",
            Vector(-817.765076, -1202.352417, -195.968750), "gc_urban_warfare_capture_point", {capMin = Vector(-1022.9687, -952.0312, -196), capMax = Vector(-449.0312, -1511.9696, 68.0313)})

    GM:AddObjectivePositionToGametype("urban_warfare", "ph_skyscraper_construct",
            Vector(2.9675, -558.3918, -511.9687), "gc_urban_warfare_capture_point", {capMin = Vector(-159.9687, -991.9687, -515), capMax = Vector(143.6555, -288.0312, -440)})

    GM:AddObjectivePositionToGametype("urban_warfare", "de_desert_atrocity_v3",
            Vector(2424.1348, -920.4495, 120.0313), "gc_urban_warfare_capture_point", {capMin = Vector(2288.031250, -816.031250, 120.031250), capMax = Vector(2598.074951, -1092.377441, 200)})

    GM:AddObjectivePositionToGametype("urban_warfare", "nt_isolation",
            Vector(-553.745, -827.579, 401.031), "gc_urban_warfare_capture_point", {capMin = Vector(-48.781, -422.024, 339.031), capMax = Vector(-1092.570, -1140.968, 423.031)})

    GM:AddObjectivePositionToGametype("urban_warfare", "dm_zavod_yantar",
            Vector(-397.236969, 1539.315308, 743.031250), "gc_urban_warfare_capture_point", {capMin = Vector(172.090851, 1113.220947, 543.680664), capMax = Vector(-992.968750, 2007.968750, 1003.031250)})

    GM:AddObjectivePositionToGametype("urban_warfare", "nt_marketa",
            Vector(315.07, 1008.616, 206.031), "gc_urban_warfare_capture_point", {capMin = Vector(167.665, 1202.217, 206.031), capMax = Vector(442.073, 786.566, 347.967)})

    GM:AddObjectivePositionToGametype("urban_warfare", "nt_redlight",
            Vector(-25.995, 289.58, 33.031), "gc_urban_warfare_capture_point", {capMin = Vector(607.396, 388.482, 100.031), capMax = Vector(-783.968, -153.168, 32.031)})

    GM:AddObjectivePositionToGametype("urban_warfare", "nt_rise",
            Vector(-176.031, 672.708, -559.968), "gc_urban_warfare_capture_point", {capMin = Vector(18.337, 1065.509, -559.968), capMax = Vector(-495.968, 360.031, -559.968)})

    GM:AddObjectivePositionToGametype("urban_warfare", "nt_dusk",
            Vector(78.944, 2896.031, -44.939), "gc_urban_warfare_capture_point", {capMin = Vector(488.873, 1524.945, -52.429), capMax = Vector(-413.863, 4536.108, -188.956)})

    GM:AddObjectivePositionToGametype("urban_warfare", "nt_skyline",
            Vector(78.944, 2896.031, -44.939), "gc_urban_warfare_capture_point", {capMin = Vector(-479.007, -498.685, 0.031), capMax = Vector(578.683, 559.266, -129.968)})

    GM:AddObjectivePositionToGametype("urban_warfare", "nt_transit",
            Vector(-173.56, -119.268, -127.968), "gc_urban_warfare_capture_point", {capMin = Vector(219.217, -310.638, -133.968), capMax = Vector(-601.865, 35.149, -23.968)})

    GM:AddObjectivePositionToGametype("urban_warfare", "nt_shrine",
            Vector(-908.194, 3617.923, 134.252), "gc_urban_warfare_capture_point", {capMin = Vector(-1444.414, 4119.525, 88.47), capMax = Vector(-170.031, 3000.031, 88.031)})
end