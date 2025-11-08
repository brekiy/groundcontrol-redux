AddCSLuaFile()

function GM:RegisterRush()
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
        oneSideRush.mapRotation = GM:GetMapRotation("one_side_rush")
    end

    function oneSideRush:AssignPointID(point)
        self.objectiveCounter = self.objectiveCounter + 1
        point:SetPointID(self.objectiveCounter)
    end

    function oneSideRush:Prepare()
        if CLIENT then
            RunConsoleCommand("gc_team_selection")
        end
    end

    function oneSideRush:ArePointsFree()
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

    function oneSideRush:RoundStart()
        if SERVER then
            if !self.swappedTeams and GAMEMODE.RoundsPlayed >= GetConVar("gc_default_rounds_per_map"):GetInt() * 0.5 then
                GAMEMODE:SwapTeams(self.attackerTeam, self.defenderTeam, oneSideRush.teamSwapCallback, oneSideRush.teamSwapCallback)
                self.swappedTeams = true
            end

            GAMEMODE:SetTimeLimit(self.timeLimit)

            table.Empty(self.objectiveEnts)
            self.stopCountdown = false

            GAMEMODE:InitializeGameTypeEntities(self)
        end
    end

    function oneSideRush:Think()
        if !self.stopCountdown and GAMEMODE:HasTimeRunOut() and self:ArePointsFree() then
                GAMEMODE:EndRound(self.realDefenderTeam)
        end
    end

    function oneSideRush:OnTimeRanOut()
        GAMEMODE:EndRound(self.defenderTeam)
    end

    function oneSideRush:OnRoundEnded(winTeam)
        table.Empty(self.objectiveEnts)
        self.stopCountdown = true
        self.objectiveCounter = 0
    end

    function oneSideRush:PostPlayerDeath(ply) -- check for round over possibility
        GAMEMODE:CheckRoundOverPossibility(ply:Team())
    end

    function oneSideRush:PlayerDisconnected(ply)
        local plyTeam = ply:Team()
        -- nothing fancy, just skip 1 frame and call PostPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
        timer.Simple(0, function()
            GAMEMODE:CheckRoundOverPossibility(plyTeam, true)
        end)
    end

    -- dunno why this wasn't defined initially...
    function oneSideRush:PlayerInitialSpawn(ply)
        if GAMEMODE.RoundsPlayed == 0 and player.GetCount() >= 2 then
            GAMEMODE:EndRound(nil)
        end
    end

    function oneSideRush:PlayerJoinTeam(ply, teamId)
        GAMEMODE:CheckRoundOverPossibility(nil, true)
        GAMEMODE:SendTimeLimit(ply)
        ply:reSpectate()
    end

    GM:RegisterNewGametype(oneSideRush)

    GM:AddObjectivePositionToGametype("onesiderush", "de_dust2",
            Vector(1147.345093, 2437.071045, 96.031250), "gc_capture_point")
    GM:AddObjectivePositionToGametype("onesiderush", "de_dust2",
            Vector(-1546.877197, 2657.465332, 1.431068), "gc_capture_point")

    GM:AddObjectivePositionToGametype("onesiderush", "de_port",
            Vector(-3131.584473, -2.002135, 640.031250), "gc_capture_point", {captureDistance = 256})
    GM:AddObjectivePositionToGametype("onesiderush", "de_port",
            Vector(1712.789551, 347.170563, 690.031250), "gc_capture_point", {captureDistance = 300})

    GM:AddObjectivePositionToGametype("onesiderush", "cs_compound",
            Vector(1934.429321, -1240.472046, 0.584229), "gc_capture_point", {captureDistance = 256, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "cs_compound",
            Vector(1772.234375, 623.238525, 0.031250), "gc_capture_point", {captureDistance = 256, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "cs_havana",
            Vector(890.551331, 652.600220, 256.031250), "gc_capture_point", {captureDistance = 256, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "cs_havana",
            Vector(93.409294, 2024.913696, 16.031250), "gc_capture_point", {captureDistance = 256, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "de_aztec",
            Vector(-290.273560, -1489.696289, -226.568970), "gc_capture_point", {captureDistance = 256})
    GM:AddObjectivePositionToGametype("onesiderush", "de_aztec",
            Vector(-1846.402222, 1074.247803, -221.927124), "gc_capture_point", {captureDistance = 256})

    GM:AddObjectivePositionToGametype("onesiderush", "de_cbble",
            Vector(-2751.983643, -1788.725342, 48.025673), "gc_capture_point", {captureDistance = 256})
    GM:AddObjectivePositionToGametype("onesiderush", "de_cbble",
            Vector(824.860535, -977.904724, -127.968750), "gc_capture_point", {captureDistance = 256})

    GM:AddObjectivePositionToGametype("onesiderush", "de_chateau",
            Vector(137.296066, 999.551453, 0.031250), "gc_capture_point", {captureDistance = 256})
    GM:AddObjectivePositionToGametype("onesiderush", "de_chateau",
            Vector(2242.166260, 1220.794800, 0.031250), "gc_capture_point", {captureDistance = 256})

    GM:AddObjectivePositionToGametype("onesiderush", "de_dust",
            Vector(122.117203, -1576.552856, 64.031250), "gc_capture_point", {captureDistance = 256})
    GM:AddObjectivePositionToGametype("onesiderush", "de_dust",
            Vector(1998.848999, 594.460327, 3.472847), "gc_capture_point", {captureDistance = 256})

    GM:AddObjectivePositionToGametype("onesiderush", "de_inferno",
            Vector(2088.574707, 445.291107, 160.031250), "gc_capture_point", {captureDistance = 256})
    GM:AddObjectivePositionToGametype("onesiderush", "de_inferno",
            Vector(396.628296, 2605.968750, 164.031250), "gc_capture_point", {captureDistance = 256})

    GM:AddObjectivePositionToGametype("onesiderush", "de_nuke",
            Vector(706.493347, -963.940552, -415.968750), "gc_capture_point", {captureDistance = 256})
    GM:AddObjectivePositionToGametype("onesiderush", "de_nuke",
            Vector(619.076172, -955.975037, -767.968750), "gc_capture_point", {captureDistance = 256})

    GM:AddObjectivePositionToGametype("onesiderush", "de_piranesi",
            Vector(-1656.252563, 2382.538818, 224.031250), "gc_capture_point", {captureDistance = 256})
    GM:AddObjectivePositionToGametype("onesiderush", "de_piranesi",
            Vector(-258.952271, -692.915649, 96.031250), "gc_capture_point", {captureDistance = 256})

    GM:AddObjectivePositionToGametype("onesiderush", "de_tides",
            Vector(-182.13874816895, -425.63604736328, 0.03125), "gc_capture_point", {captureDistance = 230})
    GM:AddObjectivePositionToGametype("onesiderush", "de_tides",
            Vector(-1120.269531, -1442.878418, -122.518227), "gc_capture_point", {captureDistance = 230})

    GM:AddObjectivePositionToGametype("onesiderush", "dm_runoff",
            Vector(10341.602539, 1974.626709, -255.968750), "gc_capture_point", {captureDistance = 256})

    GM:AddObjectivePositionToGametype("onesiderush", "de_train",
            Vector(1322.792725, -250.027832, -215.968750), "gc_capture_point", {captureDistance = 192})
    GM:AddObjectivePositionToGametype("onesiderush", "de_train",
            Vector(32.309258, -1397.823120, -351.968750), "gc_capture_point", {captureDistance = 192})

    GM:AddObjectivePositionToGametype("onesiderush", "cs_assault",
            Vector(6733.837402, 4496.704590, -861.968750), "gc_capture_point", {captureDistance = 220, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "cs_assault",
            Vector(6326.040527, 4106.064453, -606.738403), "gc_capture_point", {captureDistance = 220, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "de_prodigy",
            Vector(408.281616, -492.238770, -207.968750), "gc_capture_point", {captureDistance = 220})
    GM:AddObjectivePositionToGametype("onesiderush", "de_prodigy",
            Vector(1978.739258, -277.940277, -415.968750), "gc_capture_point", {captureDistance = 220})

    GM:AddObjectivePositionToGametype("onesiderush", "de_desert_atrocity_v3",
            Vector(384.5167, -1567.5787, -2.5376), "gc_capture_point", {captureDistance = 200})
    GM:AddObjectivePositionToGametype("onesiderush", "de_desert_atrocity_v3",
            Vector(3832.3855, -2022.0819, 248.0313), "gc_capture_point", {captureDistance = 200})

    GM:AddObjectivePositionToGametype("onesiderush", "de_secretcamp",
            Vector(90.6324, 200.1089, -87.9687), "gc_capture_point", {captureDistance = 200})
    GM:AddObjectivePositionToGametype("onesiderush", "de_secretcamp",
            Vector(-45.6821, 1882.2468, -119.9687), "gc_capture_point", {captureDistance = 200})

    GM:AddObjectivePositionToGametype("onesiderush", "cs_jungle",
            Vector(560.8469, 334.9528, -127.9688), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "cs_jungle",
            Vector(1962.2684, 425.7988, -95.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "cs_siege_2010",
            Vector(3164.2295, -1348.2546, -143.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "cs_siege_2010",
            Vector(3983.9688, -480.3419, -47.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "gc_outpost",
            Vector(4718.394, 1762.6437, 0.0313), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "gc_outpost",
            Vector(3947.8335, 2541.6055, 0.0313), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "rp_downtown_v2",
            Vector(686.9936, 1363.9843, -195.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "rp_downtown_v2",
            Vector(-144.8516, 1471.2026, -195.9687), "gc_capture_point", {captureDistance = 200,capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "gc_depot_b2",
            Vector(-5565.1865, 832.9864, 128.0313), "gc_capture_point", {captureDistance = 150, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "gc_depot_b2",
            Vector(-7676.4849, -597.2024, -351.9687), "gc_capture_point", {captureDistance = 150, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "nt_isolation",
            Vector(-586.738, -859.093, 411.031), "gc_capture_point", {captureDistance = 300, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "nt_isolation",
            Vector(-2419.906, 329.347, 158.344), "gc_capture_point", {captureDistance = 300, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "nt_marketa",
            Vector(-92.797, 323.37, 34.39), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "nt_marketa",
            Vector(657.203, 621.576, 215.031), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "nt_redlight",
            Vector(1107.868, 529.97, 36.86), "gc_capture_point", {captureDistance = 225})
    GM:AddObjectivePositionToGametype("onesiderush", "nt_redlight",
            Vector(113.076, -592.264, 37.031), "gc_capture_point", {captureDistance = 225})

    GM:AddObjectivePositionToGametype("onesiderush", "nt_rise",
            Vector(507.465, 68.648, -524.883), "gc_capture_point", {captureDistance = 225, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "nt_rise",
            Vector(-102.238, 732.526, -559.968), "gc_capture_point", {captureDistance = 225, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "nt_dusk",
            Vector(389.854, 1686.257, -40.989), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "nt_dusk",
            Vector(47.565, 4688.481, -167.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "nt_skyline",
            Vector(-50.813, 392.031, -127.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "nt_skyline",
            Vector(152.424, 1071.968, -120.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "nt_transit",
            Vector(-886.097, 249.77, -127.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "nt_transit",
            Vector(182.765, 368.824, -133.968), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("onesiderush", "nt_shrine",
            Vector(-768.155, 1988.454, 90.031), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})
    GM:AddObjectivePositionToGametype("onesiderush", "nt_shrine",
            Vector(922.37, 3423.223, 78.907), "gc_capture_point", {captureDistance = 250, capturerTeam = TEAM_RED, defenderTeam = TEAM_BLUE})

    GM:AddObjectivePositionToGametype("contendedpoint", "rp_outercanals",
            Vector(-1029.633667, -22.739532, 0.031250), "gc_contended_point", {captureDistance = 384})
end