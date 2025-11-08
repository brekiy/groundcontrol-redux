AddCSLuaFile()

function GM:RegisterDrugBust()
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
    ghettoDrugBust.timeLimitMap = {
        cs_backalley2 = 255
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
        ghettoDrugBust.mapRotation = GM:GetMapRotation("ghetto_drug_bust_maps")
    end

    function ghettoDrugBust:SkipAttachmentGive(ply)
        return ply:Team() == self.gangTeam
    end

    function ghettoDrugBust:CanHaveAttachments(ply)
        return ply:Team() == self.swatTeam
    end

    function ghettoDrugBust:CanReceiveLoadout(ply)
        ply:Give(GAMEMODE.KnifeWeaponClass)
        return ply:Team() == self.swatTeam
    end

    function ghettoDrugBust:PickupDrugs(drugEnt, ply)
        local team = ply:Team()

        if team == self.swatTeam then
            if !ply.hasDrugs then
                self:GiveDrugs(ply)
                return true
            end
        elseif team == self.gangTeam then
            if drugEnt:GetDropped() and !ply.hasDrugs then
                self:GiveDrugs(ply)
                GAMEMODE:StartAnnouncement("ghetto", "return_drugs", CurTime(), nil, ply)
                return true
            end
        end
    end

    function ghettoDrugBust:GCPlayerDeath(ply, attacker, dmginfo)
        if ply.hasDrugs then
            if IsValid(attacker) and ply != attacker and attacker:IsPlayer() then
                local plyTeam = ply:Team()
                local attackerTeam = attacker:Team()
                if plyTeam != attackerTeam then -- we grant the killer a cash and exp bonus if they kill the drug carrier of the opposite team
                    attacker:AddCurrency("KILLED_OBJ_CARRIER", nil, self.cashPerDrugCarrierKill, self.expPerDrugCarrierKill)
                end
            end

            GAMEMODE:StartAnnouncement("ghetto", "retrieve_drugs", CurTime(), self.gangTeam)

            ghettoDrugBust:DropDrugs(ply)
        end
    end

    function ghettoDrugBust:GiveDrugs(ply)
        if ply:Team() == self.swatTeam then
            GAMEMODE:StartAnnouncement("ghetto", "drugs_stolen", CurTime(), self.gangTeam)
        end

        ply.hasDrugs = true
        net.Start("GC_GOT_DRUGS", ply)
        net.Send(ply)
    end

    function ghettoDrugBust:DropDrugs(ply)
        local pos = ply:GetPos()
        pos.z = pos.z + 20

        local ent = ents.Create("gc_drug_package")
        ent:SetPos(pos)
        ent:SetAngles(AngleRand())
        ent:Spawn()
        ent:wakePhysics()
        ent:SetDropped(true)

        ply.hasDrugs = false
    end

    function ghettoDrugBust:ResetRoundData()
        for _, ply in player.Iterator() do
            ply.hasDrugs = false
        end
    end

    function ghettoDrugBust:RemoveDrugs(ply)
        ply.hasDrugs = false
        net.Start("GC_DRUGS_REMOVED")
        net.Send(ply)
    end

    function ghettoDrugBust:AttemptReturnDrugs(ply, host)
        local team = ply:Team()

        if team == ghettoDrugBust.gangTeam and ply.hasDrugs and !host:GetHasDrugs() then
            ghettoDrugBust:RemoveDrugs(ply)

            host:createDrugPackageObject()
            ply:AddCurrency("RETURNED_DRUGS", nil, self.cashPerDrugReturn, self.expPerDrugReturn)
            GAMEMODE:TrackRoundMVP(ply, "objective", 1)
            GAMEMODE:StartAnnouncement("ghetto", "drugs_retrieved", CurTime(), nil, ply)
        end
    end

    function ghettoDrugBust:AttemptCaptureDrugs(ply, host)
        local team = ply:Team()

        if team == ghettoDrugBust.swatTeam and ply.hasDrugs then
            ghettoDrugBust:RemoveDrugs(ply)

            ply:AddCurrency("SECURED_DRUGS", nil, self.cashPerDrugCapture, self.expPerDrugCapture)
            GAMEMODE:TrackRoundMVP(ply, "objective", 1)
            GAMEMODE:StartAnnouncement("ghetto", "drugs_secured", CurTime(), self.gangTeam)
            return true
        end
    end

    function ghettoDrugBust:PlayerDisconnected(ply)
        if ply.hasDrugs then
            self:DropDrugs(ply)
        end
        local plyTeam = ply:Team()
        timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call PostPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
            GAMEMODE:CheckRoundOverPossibility(plyTeam, true)
        end)
    end

    function ghettoDrugBust:PlayerSpawn(ply)
        ply.hasDrugs = false

        if ply:Team() != self.swatTeam then
            CustomizableWeaponry:removeAllAttachments(ply)
            ply:StripWeapons()
            ply:RemoveAllAmmo()
            ply:ResetGadgetData()
            ply:ApplyTraits()

            ply:ResetTrackedArmor()
            ply:GiveGCArmor("vest", 0)
            ply:GiveGCArmor("helmet", 0)
            local pickedWeapon = nil

            for key, weaponData in ipairs(self.redTeamWeapons) do
                if math.random(1, 100) <= weaponData.chance then
                    pickedWeapon = weaponData
                    break
                end
            end

            -- if for some reason the chance roll failed and no weapon was chosen, we pick one at random
            pickedWeapon = pickedWeapon or self.redTeamWeapons[math.random(1, #self.redTeamWeapons)]
            local givenWeapon = ply:Give(pickedWeapon.weapon)

            ply:GiveAmmo(pickedWeapon.mags * givenWeapon.Primary.ClipSize_Orig, givenWeapon.Primary.Ammo)
            givenWeapon:maxOutWeaponAmmo(givenWeapon.Primary.ClipSize_Orig)

            if math.random(1, 100) <= ghettoDrugBust.grenadeChance then
                ply:GiveAmmo(1, "Frag Grenades")
            end
        end
    end

    function ghettoDrugBust:GetDesiredBandageCount(ply)
        if ply:Team() != self.swatTeam then
            return self.bandagesToGive
        end

        return nil
    end

    function ghettoDrugBust:Think()
        if !self.stopCountdown and GAMEMODE:HasTimeRunOut() then
            GAMEMODE:EndRound(self.gangTeam)
        end
    end

    function ghettoDrugBust:PlayerInitialSpawn(ply)
        if GAMEMODE.RoundsPlayed == 0 and player.GetCount() >= 2 then
            GAMEMODE:EndRound(nil)
        end
    end

    function ghettoDrugBust:PostPlayerDeath(ply) -- check for round over possibility
        GAMEMODE:CheckRoundOverPossibility(ply:Team())
    end

    function ghettoDrugBust:RoundStart()
        if SERVER then
            local players = player.GetAll()
            local playerCount = #players
            local gearGuys = math.max(math.floor(playerCount / self.blueGuyPer), 1) -- aka the dudes who get the cool gear
            if self.timeLimitMap[self.CurMap] then
                GAMEMODE:SetTimeLimit(self.timeLimitMap[self.CurMap])
            else
                GAMEMODE:SetTimeLimit(self.timeLimit)
            end
            self.stopCountdown = false

            for i = 1, gearGuys do
                local randomIndex = math.random(1, playerCount)
                local dude = players[randomIndex]

                if dude then
                    dude:SetTeam(self.swatTeam)
                    table.remove(players, randomIndex)
                end
            end

            for _, ply in ipairs(players) do
                ply:SetTeam(self.gangTeam)
            end

            GAMEMODE:InitializeGameTypeEntities(self)
        end
    end

    function ghettoDrugBust:OnRoundEnded(winTeam)
        table.Empty(self.objectiveEnts)
        self.stopCountdown = true
        self.objectiveCounter = 0
    end

    function ghettoDrugBust:DeadDraw(w, h)
        if player.GetCount() < 2 then
            draw.ShadowText("This gametype requires at least 2 players, waiting for more people...", "CW_HUD20", w * 0.5, 15, GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    function ghettoDrugBust:AdjustSpawnpoint(ply, plyTeam)
        if self.invertedSpawnpoints[GAMEMODE.CurMap] then
            return GAMEMODE.OpposingTeam[plyTeam]
        end

        return nil
    end

    GM:RegisterNewGametype(ghettoDrugBust)

    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_assault",
            Vector(6794.2886, 3867.2642, -575.0213), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_assault",
            Vector(4907.146, 6381.4331, -871.9687), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_compound",
            Vector(2303.8857, -710.6038, 31.016), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_compound",
            Vector(2053.3057, -1677.0895, 56.0783), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_compound",
            Vector(2119.7871, 2032.4009, 8.0313), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_havana",
            Vector(415.6184, 1283.9724, 281.7604), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_havana",
            Vector(196.039, 807.587, 282.6608), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_havana",
            Vector(-255.9446, -774.599, 0.0313), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_militia",
            Vector(171.7497, 754.8995, -115.9687), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_militia",
            Vector(1287.92, 635.789, -120.620), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_militia",
            Vector(489.6373, -2447.677, -169.529), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_italy",
            Vector(740.9838, 2303.0881, 168.4486), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_italy",
            Vector(-382.8103, 1900.0341, -119.9687), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_italy",
            Vector(-697.3092, -1622.7435, -239.9687), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_chateau",
            Vector(99.3907, 919.5341, 24.0313), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_chateau",
            Vector(2081.2983, 1444.7068, 36.0313), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_chateau",
            Vector(1662.7606, -662.5977, -159.9687), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_inferno",
            Vector(-572.666, -435.3488, 228.9928), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_inferno",
            Vector(-32.3297, 549.7234, 83.4212), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_inferno",
            Vector(2377.4863, 2517.3298, 131.9956), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_shanty_v3_fix",
            Vector(497.7796, -1688.5574, 21.6237), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_shanty_v3_fix",
            Vector(-203.0704, -1800.5228, 165.4134), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "de_shanty_v3_fix",
            Vector(534.512, 19.6704, 6.9165), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "gm_blackbrook_asylum",
            Vector(784.7302, -224.303, 390.031), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "gm_blackbrook_asylum",
            Vector(391.3977, 289.818939, 520.03125), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "gm_blackbrook_asylum",
            Vector(-470.82025146484, 329.79114, 1.03125), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_isolation",
            Vector(-668.997, -908.508, 347.031), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_isolation",
            Vector(-2419.906, 329.347, 158.344), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_isolation",
            Vector(1214.574, 2681.112, 152.780), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_marketa",
            Vector(-735.212, 1331.367, 35.031), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_marketa",
            Vector(684.374, 1265.75, 39.031), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_marketa",
            Vector(318.746, -1410.498, 34.031), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_redlight",
            Vector(-272.03, 621.03, 96.03), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_redlight",
            Vector(-657.96, -875.49, 104.03), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_redlight",
            Vector(1591.913, -1402.049, 33.031), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_rise",
            Vector(75.829, 276.173, -847.968), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_rise",
            Vector(-343.012, 805.753, -559.968), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_rise",
            Vector(311.216, -247.248, -216.879), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_dusk",
            Vector(357.424, 2568.138, -221.933), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_dusk",
            Vector(-31.3, 4883.031, -167.968), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_dusk",
            Vector(-1773.096, 3429.306, -191.968), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_skyline",
            Vector(89.317, 148.282, -127.968), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_skyline",
            Vector(284.703, 1128.617, -120.968), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_skyline",
            Vector(-1357.663, 86.206, 220.031), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_transit",
            Vector(-617.042, 393.701, -113.002), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_transit",
            Vector(238.325, 384.474, -112.885), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_transit",
            Vector(-334.29, -1388.189, 112.042), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_shrine",
            Vector(-568.914, 1925.868, 102.251), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_shrine",
            Vector(832.32, 3529.435, 136.397), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "nt_shrine",
            Vector(-2469.47, 5674.688, 128.031), "gc_drug_capture_point")

    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_backalley2",
            Vector(2059.864014, -1114.874878, -79.413551), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_backalley2",
            Vector(2806.182373, -846.709045, 369.094177), "gc_drug_point")
    GM:AddObjectivePositionToGametype("ghettodrugbust", "cs_backalley2",
            Vector(1729.624390, 905.680908, 0.031250), "gc_drug_capture_point")
end