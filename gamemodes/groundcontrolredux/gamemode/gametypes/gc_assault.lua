-- ASSAULT GAMETYPE
-- fuck this gametype, its WACK
-- may get reworked into something else down the line, but its literally just rush with area restrictions.
--[[
function GM:registerAssault()
    local assault = {}
    assault.name = "assault"
    assault.prettyName = "Assault"
    assault.attackerTeam = TEAM_RED
    assault.defenderTeam = TEAM_BLUE
    assault.timeLimit = 315
    assault.stopCountdown = true
    assault.attackersPerDefenders = 3
    assault.objectiveCounter = 0
    assault.spawnDuringPreparation = true
    assault.objectiveEnts = {}

    if SERVER then
        -- this map rotation has been commented out. if youre digging around and wanna play assault uncomment it
        assault.mapRotation = GM:GetMapRotation("assault_maps")
    end

    function assault:AssignPointID(point)
        self.objectiveCounter = self.objectiveCounter + 1
        point.dt.PointID = self.objectiveCounter
    end

    function assault:ArePointsFree()
        local curTime = CurTime()

        for key, obj in ipairs(self.objectiveEnts) do
            if obj.winDelay and obj.winDelay > curTime then
                return false
            end
        end

        return true
    end

    function assault:Prepare()
        if CLIENT then
            RunConsoleCommand("gc_team_selection")
        end
    end

    function assault:Think()
        if !self.stopCountdown then
            if GAMEMODE:HasTimeRunOut() and self:ArePointsFree() then
                GAMEMODE:EndRound(self.defenderTeam)
            end
        end
    end

    function assault:PlayerInitialSpawn(ply)
        if GAMEMODE.RoundsPlayed == 0 then
            if player.GetCount() >= 2 then
                GAMEMODE:EndRound(nil)
            end
        end
    end

    function assault:PostPlayerDeath(ply) -- check for round over possibility
        GAMEMODE:CheckRoundOverPossibility(ply:Team())
    end

    function assault:PlayerDisconnected(ply)
        local hisTeam = ply:Team()

        timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call PostPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
            GAMEMODE:CheckRoundOverPossibility(ply:Team(), true)
        end)
    end

    function assault.teamSwapCallback(player)
        net.Start("GC_NEW_TEAM")
        net.WriteInt(player:Team(), 16)
        net.Send(player)
    end

    function assault:RoundStart()
        if SERVER then
            GAMEMODE:SwapTeams(self.attackerTeam, self.defenderTeam, assault.teamSwapCallback, assault.teamSwapCallback) -- swap teams on every round start

            GAMEMODE:SetTimeLimit(self.timeLimit)

            self.realAttackerTeam = self.attackerTeam
            self.realDefenderTeam = self.defenderTeam

            self.objectiveEnts = {}
            self.stopCountdown = false

            GAMEMODE:InitializeGameTypeEntities(self)
        end
    end

    function assault:OnRoundEnded(winTeam)
        self.objectiveEnts = {}
        self.stopCountdown = true
        self.objectiveCounter = 0
    end

    function assault:PlayerJoinTeam(ply, teamId)
        GAMEMODE:CheckRoundOverPossibility(nil, true)
        GAMEMODE:SendTimeLimit(ply)
        ply:reSpectate()
    end

    function assault:DeadDraw(w, h)
        if player.GetCount() < 2 then
            draw.ShadowText("This gametype requires at least 2 players, waiting for more people...", "CW_HUD20", w * 0.5, 15, GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    GM:RegisterNewGametype(assault)

    GM:AddObjectivePositionToGametype("assault", "cs_jungle", Vector(560.8469, 334.9528, -127.9688), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
    GM:AddObjectivePositionToGametype("assault", "cs_jungle", Vector(1962.2684, 425.7988, -95.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
    GM:AddObjectivePositionToGametype("assault", "cs_jungle", Vector(1442.923218, 489.496857, -127.968758), "gc_offlimits_area", {distance = 2048, targetTeam = assault.defenderTeam, inverseFunctioning = true})

    GM:AddObjectivePositionToGametype("assault", "cs_siege_2010", Vector(3164.2295, -1348.2546, -143.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
    GM:AddObjectivePositionToGametype("assault", "cs_siege_2010", Vector(3983.9688, -480.3419, -47.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
    GM:AddObjectivePositionToGametype("assault", "cs_siege_2010", Vector(3878.5757, -1108.7665, -143.9687), "gc_offlimits_area", {distance = 2500, targetTeam = assault.defenderTeam, inverseFunctioning = true})

    GM:AddObjectivePositionToGametype("assault", "gc_outpost", Vector(4718.394, 1762.6437, 0.0313), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
    GM:AddObjectivePositionToGametype("assault", "gc_outpost", Vector(3947.8335, 2541.6055, 0.0313), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
    GM:AddObjectivePositionToGametype("assault", "gc_outpost", Vector(3147.9561, 1540.1907, -8.068), "gc_offlimits_area", {distance = 2048, targetTeam = assault.defenderTeam, inverseFunctioning = true})

    GM:AddObjectivePositionToGametype("assault", "rp_downtown_v2", Vector(686.9936, 1363.9843, -195.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
    GM:AddObjectivePositionToGametype("assault", "rp_downtown_v2", Vector(-144.8516, 1471.2026, -195.9687), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.attackerTeam, defenderTeam = assault.defenderTeam})
    GM:AddObjectivePositionToGametype("assault", "rp_downtown_v2", Vector(816.7338, 847.4449, -195.9687), "gc_offlimits_area", {distance = 1400, targetTeam = assault.defenderTeam, inverseFunctioning = true})

    GM:AddObjectivePositionToGametype("assault", "de_desert_atrocity_v3", Vector(384.5167, -1567.5787, -2.5376), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.defenderTeam, defenderTeam = assault.attackerTeam})
    GM:AddObjectivePositionToGametype("assault", "de_desert_atrocity_v3", Vector(3832.3855, -2022.0819, 248.0313), "gc_capture_point", {captureDistance = 200, capturerTeam = assault.defenderTeam, defenderTeam = assault.attackerTeam})
    GM:AddObjectivePositionToGametype("assault", "de_desert_atrocity_v3", Vector(1898.58, -1590.46, 136.0313), "gc_offlimits_area", {distance = 2000, targetTeam = assault.attackerTeam, inverseFunctioning = true})

    GM:AddObjectivePositionToGametype("assault", "gc_depot_b2", Vector(-5565.1865, 832.9864, 128.0313), "gc_capture_point", {captureDistance = 150, capturerTeam = assault.defenderTeam, defenderTeam = assault.attackerTeam})
    GM:AddObjectivePositionToGametype("assault", "gc_depot_b2", Vector(-7676.4849, -597.2024, -351.9687), "gc_capture_point", {captureDistance = 150, capturerTeam = assault.defenderTeam, defenderTeam = assault.attackerTeam})
    GM:AddObjectivePositionToGametype("assault", "gc_depot_b2", Vector(-5108.8721, -1509.1794, -933.2501), "gc_offlimits_area_aabb", {distance = 2000, targetTeam = assault.attackerTeam, min = Vector(-5108.8721, -1509.1794, -933.2501), max = Vector(930.1258, 5336.1563, 686.4084)})
end
]]--