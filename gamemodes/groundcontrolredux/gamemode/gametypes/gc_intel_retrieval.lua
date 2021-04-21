AddCSLuaFile()

--[[
    Functionally 1 flag CTF. Teams must search for an intelligence dead drop and return it to their spawn.

    Allow a convar to adjust ticket count? Don't know if it should have respawns
    models/props_lab/harddrive01.mdl
--]]

function GM:RegisterIntelRetrieval()
    local intelRetrieval = {}
    intelRetrieval.name = "intel_retrieval"
    intelRetrieval.prettyName = "Intel Retrieval"
    intelRetrieval.timeLimit = 195
    intelRetrieval.stopCountdown = true
    intelRetrieval.objectiveEnts = {}
    intelRetrieval.objectiveCounter = 0
    intelRetrieval.objectives = {}

    intelRetrieval.invertedSpawnpoints = {}

    if SERVER then
        intelRetrieval.mapRotation = GM:GetMapRotation("intel_retrieval_maps")
    end

    function intelRetrieval:PickupIntel(intelEnt, ply)
        if !ply.hasIntel then
            self:GiveIntel(ply)
            ply.intel = intelEnt
            return true
        end
    end

    function intelRetrieval:PlayerDeath(ply, attacker, dmginfo)
        if ply.hasIntel then
            if IsValid(attacker) and ply != attacker and attacker:IsPlayer() then
                local plyTeam = ply:Team()
                local attackerTeam = attacker:Team()

                if plyTeam != attackerTeam then -- we grant the killer a cash and exp bonus if they kill the intel carrier of the opposite team
                    attacker:AddCurrency("KILLED_OBJ_CARRIER")
                end
            end

            intelRetrieval:DropIntel(ply)
        end
    end

    function intelRetrieval:GiveIntel(ply)
        ply.hasIntel = true
        net.Start("GC_GOT_INTEL", ply)
        net.Send(ply)
    end

    function intelRetrieval:DropIntel(ply)
        ply.hasIntel = false
        ply.intel:Drop()
        ply.intel = nil
    end

    function intelRetrieval:ResetRoundData()
        for key, ply in ipairs(player.GetAll()) do
            ply.hasIntel = false
            ply.intel = nil
        end
    end

    function intelRetrieval:RemoveIntel(ply)
        ply.hasIntel = false
        ply.intel = nil
        net.Start("GC_INTEL_REMOVED")
        net.Send(ply)
    end

    function intelRetrieval:AttemptCaptureIntel(ply, host)
        if ply.hasIntel then
            intelRetrieval:RemoveIntel(ply)
            ply:AddCurrency("SECURED_INTEL")
            return true
        end
    end

    function intelRetrieval:PlayerDisconnected(ply)
        if ply.hasIntel then
            self:DropIntel(ply)
        end

        local theirTeam = ply:Team()

        -- nothing fancy, just skip 1 frame and call PostPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
        timer.Simple(0, function()
            GAMEMODE:CheckRoundOverPossibility(theirTeam, true)
        end)
    end

    function intelRetrieval:PlayerSpawn(ply)
        ply.hasIntel = false
    end

    function intelRetrieval:Think()
        if !self.stopCountdown and GAMEMODE:HasTimeRunOut() then
            GAMEMODE:EndRound(nil)
        end
    end

    function intelRetrieval:PlayerInitialSpawn(ply)
        if GAMEMODE.RoundsPlayed == 0 and #player.GetAll() >= 2 then
            GAMEMODE:EndRound(nil)
        end
    end

    function intelRetrieval:PostPlayerDeath(ply)
        GAMEMODE:CheckRoundOverPossibility(ply:Team())
    end

    function intelRetrieval:RoundStart()
        if SERVER then
            GAMEMODE:SetTimeLimit(self.timeLimit)
            self.stopCountdown = false
            GAMEMODE:InitializeGameTypeEntities(self)

            local intelSpawns = ents.FindByClass("gc_intel_spawn_point")
            local intelIdx = math.random(1, #intelSpawns)
            intelSpawns[intelIdx]:SetHasIntel(true)
        end
    end

    function intelRetrieval:OnRoundEnded(winTeam)
        table.Empty(self.objectiveEnts)
        self.stopCountdown = true
        self.objectiveCounter = 0
    end

    function intelRetrieval:DeadDraw(w, h)
        if GAMEMODE:GetActivePlayerAmount() < 2 then
            draw.ShadowText("This gametype requires at least 2 players, waiting for more people...",
                    "CW_HUD20", w * 0.5, 15, GAMEMODE.HUDColors.white, GAMEMODE.HUDColors.black, 1,
                    TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    function intelRetrieval:AdjustSpawnpoint(ply, plyTeam)
        if self.invertedSpawnpoints[GAMEMODE.CurMap] then
            return GAMEMODE.OpposingTeam[plyTeam]
        end

        return nil
    end

    GM:RegisterNewGametype(intelRetrieval)

    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_assault",
            Vector(6794.2886, 3867.2642, -575.0213), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_assault",
            Vector(4907.146, 6381.4331, -871.9687), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_compound",
            Vector(2303.8857, -710.6038, 31.016), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_compound",
            Vector(2053.3057, -1677.0895, 56.0783), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_compound",
            Vector(2119.7871, 2032.4009, 8.0313), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_havana",
            Vector(415.6184, 1283.9724, 281.7604), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_havana",
            Vector(196.039, 807.587, 282.6608), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_havana",
            Vector(-255.9446, -774.599, 0.0313), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_militia",
            Vector(171.7497, 754.8995, -115.9687), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_militia",
            Vector(1287.92, 635.789, -120.620), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_militia",
            Vector(489.6373, -2447.677, -169.529), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_italy",
            Vector(740.9838, 2303.0881, 168.4486), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_italy",
            Vector(-382.8103, 1900.0341, -119.9687), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "cs_italy",
            Vector(-697.3092, -1622.7435, -239.9687), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "de_chateau",
            Vector(99.3907, 919.5341, 24.0313), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_chateau",
            Vector(2081.2983, 1444.7068, 36.0313), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_chateau",
            Vector(1662.7606, -662.5977, -159.9687), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "de_inferno",
            Vector(-572.666, -435.3488, 228.9928), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_inferno",
            Vector(-32.3297, 549.7234, 83.4212), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_inferno",
            Vector(2377.4863, 2517.3298, 131.9956), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "de_shanty_v3_fix",
            Vector(497.7796, -1688.5574, 21.6237), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_shanty_v3_fix",
            Vector(-203.0704, -1800.5228, 165.4134), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_shanty_v3_fix",
            Vector(534.512, 19.6704, 6.9165), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "gm_blackbrook_asylum",
            Vector(784.7302, -224.303, 390.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "gm_blackbrook_asylum",
            Vector(391.3977, 289.818939, 520.03125), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "gm_blackbrook_asylum",
            Vector(-470.82025146484, 329.79114, 1.03125), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_isolation",
            Vector(-668.997, -908.508, 347.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_isolation",
            Vector(-2419.906, 329.347, 158.344), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_isolation",
            Vector(1214.574, 2681.112, 152.780), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_isolation",
            Vector(-4151.822, -2887.363, 214.317), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_marketa",
            Vector(-735.212, 1331.367, 35.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_marketa",
            Vector(684.374, 1265.75, 39.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_marketa",
            Vector(318.746, -1410.498, 34.031), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_redlight",
            Vector(-272.03, 621.03, 96.03), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_redlight",
            Vector(-657.96, -875.49, 104.03), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_redlight",
            Vector(1591.913, -1402.049, 33.031), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(75.829, 276.173, -847.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(-343.012, 805.753, -559.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(311.216, -247.248, -216.879), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(357.424, 2568.138, -221.933), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(-31.3, 4883.031, -167.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(-1773.096, 3429.306, -191.968), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(89.317, 148.282, -127.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(284.703, 1128.617, -120.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(-1357.663, 86.206, 220.031), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(-617.042, 393.701, -113.002), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(238.325, 384.474, -112.885), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(-334.29, -1388.189, 112.042), "gc_intel_capture_point")

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_shrine",
            Vector(-568.914, 1925.868, 102.251), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_shrine",
            Vector(832.32, 3529.435, 136.397), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_shrine",
            Vector(-2469.47, 5674.688, 128.031), "gc_intel_capture_point")
end