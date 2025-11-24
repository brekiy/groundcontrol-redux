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
    intelRetrieval.swappedTeams = false
    intelRetrieval.objectiveEnts = {}
    intelRetrieval.objectiveCounter = 0
    intelRetrieval.objectives = {}

    intelRetrieval.invertedSpawnpoints = {}

    if SERVER then
        intelRetrieval.mapRotation = GM:GetMapRotation("intel_retrieval_maps")
    end

    function intelRetrieval:Prepare()
        if CLIENT then
            RunConsoleCommand("gc_team_selection")
        end
    end

    function intelRetrieval.teamSwapCallback(player)
        net.Start("GC_NEW_TEAM")
        net.WriteInt(player:Team(), 16)
        net.Send(player)
    end

    function intelRetrieval:PickupIntel(intelEnt, ply)
        if !ply.hasIntel then
            self:GiveIntel(ply)
            ply.intel = intelEnt
            return true
        end
    end

    function intelRetrieval:GCPlayerDeath(ply, attacker, dmginfo)
        if ply.hasIntel then
            if IsValid(attacker) and ply != attacker and attacker:IsPlayer() then
                local plyTeam = ply:Team()
                local attackerTeam = attacker:Team()

                if plyTeam != attackerTeam then -- we grant the killer a cash and exp bonus if they kill the intel carrier of the opposite team
                    attacker:AddCurrency("KILLED_OBJ_CARRIER")
                end
            end

            self:DropIntel(ply)
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
        net.Start("GC_INTEL_REMOVED")
        net.Send(ply)
    end

    function intelRetrieval:ResetRoundData()
        for _, ply in player.Iterator() do
            ply.hasIntel = false
            if ply.intel then
                ply.intel:Remove()
            end
            ply.intel = nil
        end
    end

    function intelRetrieval:RemoveIntel(ply)
        ply.hasIntel = false
        ply.intel:Remove()
        ply.intel = nil
        net.Start("GC_INTEL_REMOVED")
        net.Send(ply)
    end

    function intelRetrieval:AttemptCaptureIntel(ply, host)
        if ply.hasIntel then
            self:RemoveIntel(ply)
            ply:AddCurrency("SECURED_INTEL")
            GAMEMODE:TrackRoundMVP(ply, "objective", 1)
            return true
        end
    end

    function intelRetrieval:PlayerDisconnected(ply)
        if ply.hasIntel then
            self:DropIntel(ply)
        end

        local plyTeam = ply:Team()

        -- nothing fancy, just skip 1 frame and call PostPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
        timer.Simple(0, function()
            GAMEMODE:CheckRoundOverPossibility(plyTeam, true)
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
        if GAMEMODE.RoundsPlayed == 0 and player.GetCount() >= 2 then
            GAMEMODE:EndRound(nil)
        end
    end

    function intelRetrieval:PostPlayerDeath(ply)
        GAMEMODE:CheckRoundOverPossibility(ply:Team())
    end

    function intelRetrieval:RoundStart()
        if SERVER then
            if !self.swappedTeams and GAMEMODE.RoundsPlayed >= GetConVar("gc_default_rounds_per_map"):GetInt() * 0.5 then
                GAMEMODE:SwapTeams(TEAM_RED, TEAM_BLUE, intelRetrieval.teamSwapCallback, intelRetrieval.teamSwapCallback)
                self.swappedTeams = true
            end
            GAMEMODE:SetTimeLimit(self.timeLimit)
            self.stopCountdown = false
            GAMEMODE:InitializeGameTypeEntities(self)

            local intelSpawns = ents.FindByClass("gc_intel_spawn_point")
            local intelIdx = math.random(1, #intelSpawns)
            intelSpawns[intelIdx]:AssignAsIntelTarget(true)
        end
    end

    function intelRetrieval:OnRoundEnded(winTeam)
        self.objectiveEnts = {}
        self.stopCountdown = true
        self.objectiveCounter = 0
    end

    function intelRetrieval:DeadDraw(w, h)
        if player.GetCount() < 2 then
            draw.ShadowText("This gametype requires at least 2 players, waiting for more people...",
                    "CW_HUD20", w * 0.5, 15, GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black, 1,
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

    GM:AddObjectivePositionToGametype("intel_retrieval", "de_chateau", Vector(218.866, 998.638, 0.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_chateau", Vector(3037.416, 1134.801, 0.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_chateau", Vector(759.893, 442.813, 0.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_chateau", Vector(1438.378, -852.531, -146.378), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_chateau", Vector(1301.257, 2577.233, -7.968), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "de_nuke", Vector(1213.487, -720.706, -415.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_nuke", Vector(565.344, 888.676, -479.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_nuke", Vector(42.075, -1018.45, -767.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_nuke", Vector(1239.821, -382.545, -639.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_nuke", Vector(3348.193, -586.974, -351.968), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_nuke", Vector(-2838.978, -830.091, -419.248), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "de_prodigy", Vector(759.178, 576.998, -255.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_prodigy", Vector(1784.239, -1065.4, -287.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_prodigy", Vector(1961.651, -23.339, -415.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_prodigy", Vector(1587.872, -1530.458, -479.968), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "de_prodigy", Vector(2169.519, 960.655, -383.968), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_isolation",
            Vector(-668.997, -908.508, 347.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_isolation",
            Vector(-2419.906, 329.347, 158.344), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_isolation",
            Vector(1214.574, 2681.112, 152.780), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_isolation",
            Vector(-4151.822, -2887.363, 214.317), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_marketa",
            Vector(-711.968, 356.306, 34.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_marketa",
            Vector(495.545, -200.91, 34.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_marketa",
            Vector(433.071, 712.107, 219.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_marketa",
            Vector(1010.148, -1968.728, 34.031), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_marketa",
            Vector(1359.785, 1671.985, 210.193), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(1151.793, 176.499, -559.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(99.725, -413.747, -559.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(-334.771, 707.341, -528.951), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(-514.183, 458.125, -71.968), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(729.067, 940.035, 80.031), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(1862.929, 244.652, -1055.968), "gc_intel_capture_point", {capturerTeam = TEAM_RED})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_rise",
            Vector(-1434.110, 425.498, -799.968), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(-246.661, 121.966, -127.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(-465.048, 1632.92, -151.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(-14.23, 4433.187, -228.798), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(974.008, 2807.303, -247.145), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(-123.526, 4964.61, -167.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(-2107.822, 2904.274, -191.968), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_dusk",
            Vector(2083.512, 4031.088, -122.888), "gc_intel_capture_point", {capturerTeam = TEAM_RED})

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(-1889.271, -1335.286, -6.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(-1514.379, 1410.057, -87.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(960.134, 1400.334, -126.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(-2621.576, -156.134, 177.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(1220.419, -1216.523, -127.968), "gc_intel_capture_point", {capturerTeam = TEAM_RED})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(1496.701, 928.433, -127.968), "gc_intel_capture_point", {capturerTeam = TEAM_RED})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(-4106.05, 180.471, -159.968), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_skyline",
            Vector(-3556.096, -1164.421, -239.968), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(-879.058, 275.746, -127.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(512.862, -10.079, 40.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(-554.277, -421.518, -133.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(191.941, 632.141, -133.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(-387.427, 1168.738, -127.968), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(547.694, 1385.821, 32.031), "gc_intel_capture_point", {capturerTeam = TEAM_RED})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_transit",
            Vector(-108.409, -1392.375, 112.031), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_zaibatsu",
            Vector(-1941.632, -576.81, 251.019), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_zaibatsu",
            Vector(-1514.418, 239.218, 208.031), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_zaibatsu",
            Vector(-1511.74, 195.88, 216.528), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_zaibatsu",
            Vector(-1412.821, 37.955, -38.44), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_zaibatsu",
            Vector(-678.772, 251.278, -23.471), "gc_intel_spawn_point")
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_zaibatsu",
            Vector(-618.57, -1148.943, 460.031), "gc_intel_capture_point", {capturerTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("intel_retrieval", "nt_zaibatsu",
            Vector(-754.34, -1349.575, -39.968), "gc_intel_capture_point", {capturerTeam = TEAM_RED})
end