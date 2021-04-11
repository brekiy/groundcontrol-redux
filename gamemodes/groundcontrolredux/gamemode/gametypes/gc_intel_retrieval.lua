AddCSLuaFile()

--[[
    Functionally 1 flag CTF. Teams must search for an intelligence dead drop and return it to their spawn.

    Allow a convar to adjust ticket count? Don't know if it should have respawns
    models/props_lab/harddrive01.mdl
--]]

-- TODO
function GM:registerIntelRetrieval()
    local intelRetrieval = {}
    intelRetrieval.name = "intel_retrieval"
    intelRetrieval.prettyName = "Intel Retrieval"
    intelRetrieval.timeLimit = 195
    intelRetrieval.stopCountdown = true
    intelRetrieval.objectiveEnts = {}
    intelRetrieval.objectiveCounter = 0
    intelRetrieval.objectives = {}

    intelRetrieval.cashPerIntelReturn = 50
    intelRetrieval.expPerIntelReturn = 50

    intelRetrieval.cashPerIntelCapture = 100
    intelRetrieval.expPerIntelCapture = 100

    intelRetrieval.cashPerIntelCarrierKill = 25
    intelRetrieval.expPerIntelCarrierKill = 25

    if SERVER then
        intelRetrieval.mapRotation = GM:getMapRotation("Intel_retrieval_maps")
    end

    function intelRetrieval:pickupIntel(intelEnt, ply)

        if !ply.hasIntel then
            self:giveIntel(ply)
            return true
        end
    end

    function intelRetrieval:playerDeath(ply, attacker, dmginfo)
        if ply.hasIntel then
            if IsValid(attacker) and ply != attacker and attacker:IsPlayer() then
                local plyTeam = ply:Team()
                local attackerTeam = attacker:Team()

                if plyTeam != attackerTeam then -- we grant the killer a cash and exp bonus if they kill the intel carrier of the opposite team
                    attacker:addCurrency(self.cashPerIntelCarrierKill, self.expPerIntelCarrierKill, "KILLED_INTEL_CARRIER")
                end
            end


            intelRetrieval:dropIntel(ply)
        end
    end

    function intelRetrieval:giveIntel(ply)
        ply.hasIntel = true
        net.Start("GC_GOT_INTEL", ply)
        net.Send(ply)
    end

    function intelRetrieval:dropIntel(ply)
        local pos = ply:GetPos()
        pos.z = pos.z + 20

        local ent = ents.Create("gc_intel")
        ent:SetPos(pos)
        ent:SetAngles(AngleRand())
        ent:Spawn()
        ent:wakePhysics()
        ent.dt.Dropped = true

        ply.hasIntel = false
    end

    function intelRetrieval:resetRoundData()
        for key, ply in ipairs(player.GetAll()) do
            ply.hasIntel = false
        end
    end

    function intelRetrieval:removeIntel(ply)
        ply.hasIntel = false
        net.Start("GC_INTEL_REMOVED")
        net.Send(ply)
    end

    function intelRetrieval:attemptCaptureIntel(ply, host)

        if player.hasIntel then
            intelRetrieval:removeIntel(player)

            player:addCurrency(self.cashPerIntelCapture, self.expPerIntelCapture, "SECURED_INTEL")
            return true
        end
    end

    function intelRetrieval:playerDisconnected(ply)
        if ply.hasIntel then
            self:dropIntel(ply)
        end

        local hisTeam = ply:Team()

        timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call postPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
            GAMEMODE:checkRoundOverPossibility(hisTeam, true)
        end)
    end

    function intelRetrieval:playerSpawn(ply)
        ply.hasIntel = false
    end

    function intelRetrieval:think()
        if !self.stopCountdown and GAMEMODE:hasTimeRunOut() then
            GAMEMODE:endRound(nil)
            -- local curTime = CurTime()
        end
    end

    function intelRetrieval:playerInitialSpawn(ply)
        if GAMEMODE.RoundsPlayed == 0 and #player.GetAll() >= 2 then
            GAMEMODE:endRound(nil)
        end
    end

    function intelRetrieval:postPlayerDeath(ply) -- check for round over possibility
        GAMEMODE:checkRoundOverPossibility(ply:Team())
    end

    function intelRetrieval:roundStart()
        if SERVER then
            GAMEMODE:setTimeLimit(self.timeLimit)
            self.stopCountdown = false
            GAMEMODE:initializeGameTypeEntities(self)
        end
    end

    function intelRetrieval:onRoundEnded(winTeam)
        table.Empty(self.objectiveEnts)
        self.stopCountdown = true
        self.objectiveCounter = 0
    end

    function intelRetrieval:deadDraw(w, h)
        if GAMEMODE:getActivePlayerAmount() < 2 then
            draw.ShadowText("This gametype requires at least 2 players, waiting for more people...", "CW_HUD20", w * 0.5, 15, GAMEMODE.HUDColors.white, GAMEMODE.HUDColors.black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    function intelRetrieval:adjustSpawnpoint(ply, plyTeam)
        if self.invertedSpawnpoints[GAMEMODE.CurMap] then
            return GAMEMODE.OpposingTeam[plyTeam]
        end

        return nil
    end

    GM:registerNewGametype(intelRetrieval)

    GM:addObjectivePositionToGametype("intelRetrieval", "cs_assault", Vector(6794.2886, 3867.2642, -575.0213), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_assault", Vector(4907.146, 6381.4331, -871.9687), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "cs_compound", Vector(2303.8857, -710.6038, 31.016), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_compound", Vector(2053.3057, -1677.0895, 56.0783), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_compound", Vector(2119.7871, 2032.4009, 8.0313), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "cs_havana", Vector(415.6184, 1283.9724, 281.7604), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_havana", Vector(196.039, 807.587, 282.6608), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_havana", Vector(-255.9446, -774.599, 0.0313), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "cs_militia", Vector(171.7497, 754.8995, -115.9687), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_militia", Vector(1287.92, 635.789, -120.620), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_militia", Vector(489.6373, -2447.677, -169.529), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "cs_italy", Vector(740.9838, 2303.0881, 168.4486), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_italy", Vector(-382.8103, 1900.0341, -119.9687), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "cs_italy", Vector(-697.3092, -1622.7435, -239.9687), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "de_chateau", Vector(99.3907, 919.5341, 24.0313), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "de_chateau", Vector(2081.2983, 1444.7068, 36.0313), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "de_chateau", Vector(1662.7606, -662.5977, -159.9687), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "de_inferno", Vector(-572.666, -435.3488, 228.9928), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "de_inferno", Vector(-32.3297, 549.7234, 83.4212), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "de_inferno", Vector(2377.4863, 2517.3298, 131.9956), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "de_shanty_v3_fix", Vector(497.7796, -1688.5574, 21.6237), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "de_shanty_v3_fix", Vector(-203.0704, -1800.5228, 165.4134), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "de_shanty_v3_fix", Vector(534.512, 19.6704, 6.9165), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "gm_blackbrook_asylum", Vector(784.7302, -224.303, 390.031), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "gm_blackbrook_asylum", Vector(391.3977, 289.818939, 520.03125), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "gm_blackbrook_asylum", Vector(-470.82025146484, 329.79114, 1.03125), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "nt_isolation", Vector(-668.997, -908.508, 347.031), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_isolation", Vector(-2419.906, 329.347, 158.344), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_isolation", Vector(1214.574, 2681.112, 152.780), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "nt_marketa", Vector(-735.212, 1331.367, 35.031), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_marketa", Vector(684.374, 1265.75, 39.031), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_marketa", Vector(318.746, -1410.498, 34.031), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "nt_redlight", Vector(-272.03, 621.03, 96.03), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_redlight", Vector(-657.96, -875.49, 104.03), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_redlight", Vector(1591.913, -1402.049, 33.031), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "nt_rise", Vector(75.829, 276.173, -847.968), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_rise", Vector(-343.012, 805.753, -559.968), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_rise", Vector(311.216, -247.248, -216.879), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "nt_dusk", Vector(357.424, 2568.138, -221.933), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_dusk", Vector(-31.3, 4883.031, -167.968), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_dusk", Vector(-1773.096, 3429.306, -191.968), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "nt_skyline", Vector(89.317, 148.282, -127.968), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_skyline", Vector(284.703, 1128.617, -120.968), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_skyline", Vector(-1357.663, 86.206, 220.031), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "nt_transit", Vector(-617.042, 393.701, -113.002), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_transit", Vector(238.325, 384.474, -112.885), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_transit", Vector(-334.29, -1388.189, 112.042), "gc_intel_capture_point")

    GM:addObjectivePositionToGametype("intelRetrieval", "nt_shrine", Vector(-568.914, 1925.868, 102.251), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_shrine", Vector(832.32, 3529.435, 136.397), "gc_intel_point")
    GM:addObjectivePositionToGametype("intelRetrieval", "nt_shrine", Vector(-2469.47, 5674.688, 128.031), "gc_intel_capture_point")
end