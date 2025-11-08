AddCSLuaFile()

--[[
    VIP Escort gamemode. One team protects a VIP and needs to escort them to a random predetermined spot on the map.
    Only the VIP needs to touch the exfil zone.
    The other team must eliminate the VIP.

    VIP will have a random secondary weapon and the lightest armor/helmet, as well as a unique playermodel.
--]]

-- TODO
function GM:RegisterVIPEscort()
    local vipEscort = {}
    vipEscort.name = "vip_escort"
    vipEscort.prettyName = "VIP Escort"
    vipEscort.preventManualTeamJoining = false
    vipEscort.vipTeam = TEAM_RED
    vipEscort.ambushTeam = TEAM_BLUE
    vipEscort.stopCountdown = true
    vipEscort.timeLimit = 225
    vipEscort.swappedTeams = false
    vipEscort.reversedVIP = false
    vipEscort.objectiveEnts = {}
    vipEscort.objectiveCounter = 0
    vipEscort.objectives = {}
    vipEscort.vipModel = "models/player/gman_high.mdl"

    if SERVER then
        vipEscort.mapRotation = GM:GetMapRotation("vip_escort_maps")
    end

    function vipEscort:Prepare()
        if CLIENT then
            RunConsoleCommand("gc_team_selection")
        end
    end

    function vipEscort:PlayerSpawn(ply)
        ply.isVIP = false
    end

    function vipEscort:Think()
        if !self.stopCountdown and GAMEMODE:HasTimeRunOut() then
            GAMEMODE:EndRound(self.ambushTeam)
        end
    end

    function vipEscort:RoundStart()
        if SERVER then
            GAMEMODE:SetTimeLimit(self.timeLimit)
            if !self.swappedTeams and GAMEMODE.RoundsPlayed >= GetConVar("gc_default_rounds_per_map"):GetInt() * 0.5 then
                GAMEMODE:SwapTeams(self.vipTeam, self.ambushTeam, vipEscort.teamSwapCallback, vipEscort.teamSwapCallback)
                self.swappedTeams = true
            end
            GAMEMODE:InitializeGameTypeEntities(self)
            local vipPlayers = team.GetPlayers(self.vipTeam)
            local vipIdx = math.random(1, #vipPlayers)
            vipPlayers[vipIdx].isVIP = true
            self.stopCountdown = false
        end
    end

    function vipEscort.teamSwapCallback(ply)
        net.Start("GC_NEW_TEAM")
        net.WriteInt(ply:Team(), 16)
        net.Send(player)
    end

    function vipEscort:PlayerDisconnected(ply)
        if ply.isVIP then
            GAMEMODE:EndRound(nil)
        else
            local plyTeam = ply:Team()
            timer.Simple(0, function()
                GAMEMODE:CheckRoundOverPossibility(plyTeam, true)
            end)
        end
    end

    function vipEscort:PlayerSpawn(ply)
        if ply.isVIP then
            CustomizableWeaponry:removeAllAttachments(ply)
            ply:StripWeapons()
            ply:RemoveAllAmmo()
            ply:ResetGadgetData()
            ply:ApplyTraits()

            ply:ResetTrackedArmor()
            ply:GiveGCArmor("vest", 1)
            ply:GiveGCArmor("helmet", 0)

            local pickedWeapon = GAMEMODE.SecondaryWeapons[math.random(1, #GAMEMODE.SecondaryWeapons)]
            local givenWeapon = ply:Give(pickedWeapon.weaponClass)

            ply:GiveAmmo(3 * givenWeapon.Primary.ClipSize_Orig, givenWeapon.Primary.Ammo)
            givenWeapon:maxOutWeaponAmmo(givenWeapon.Primary.ClipSize_Orig)
            ply:SetModel(self.vipModel)
            net.Start("GC_SET_VIP", ply)
            net.WriteBool(true)
            net.Send(ply)
        end
    end

    function vipEscort:OnRoundEnded(winTeam)
        self.stopCountdown = true
        for _, ply in player.Iterator() do
            ply.isVIP = false
            net.Start("GC_SET_VIP", ply)
            net.WriteBool(false)
            net.Send(ply)
        end
    end

    function vipEscort:PostPlayerDeath(ply)
        GAMEMODE:CheckRoundOverPossibility(ply:Team())
    end

    function vipEscort:PlayerInitialSpawn(ply)
        if GAMEMODE.RoundsPlayed == 0 and player.GetCount() >= 2 then
            GAMEMODE:EndRound(nil)
        end
    end

    function vipEscort:PlayerJoinTeam(ply, teamId)
        GAMEMODE:CheckRoundOverPossibility(nil, true)
        GAMEMODE:SendTimeLimit(ply)
        ply:reSpectate()
    end

    function vipEscort:CanReceiveLoadout(ply)
        ply:Give(GAMEMODE.KnifeWeaponClass)
        return !ply.isVIP
    end

    function vipEscort:GCPlayerDeath(ply, attacker, dmginfo)
        if ply.isVIP then
            if IsValid(attacker) and ply != attacker and attacker:IsPlayer() then
                local victimTeam = ply:Team()
                local attackerTeam = attacker:Team()
                if victimTeam != attackerTeam then
                    attacker:AddCurrency("KILLED_VIP", nil)
                end
            end
            -- any vip death is a W for ambushers
            GAMEMODE:EndRound(self.ambushTeam)
        end
    end

    -- Swaps the assigned red/blue teams if the map calls for it
    function vipEscort:SwapVIPTeam()
        if !self.reversedVip then
            local temp = self.vipTeam
            self.vipTeam = self.ambushTeam
            self.ambushTeam = temp
            self.reversedVip = true
        end
    end

    GM:RegisterNewGametype(vipEscort)
    GM:AddObjectivePositionToGametype("vip_escort", "nt_isolation", Vector(1219.424, 2665.713, 93.224), "gc_vip_escape_point")
    GM:AddObjectivePositionToGametype("vip_escort", "nt_isolation", Vector(-2519.902, 2936.052, 215.031), "gc_vip_escape_point")
    -- 3 escape zones seems too much for a small map, but vip is surrounded, idk
    -- GM:AddObjectivePositionToGametype("vip_escort", "nt_isolation", Vector(-4513.248, -944.515, 153.938), "gc_vip_escape_point")

    -- only one escape seems difficult but we'll see
    GM:AddObjectivePositionToGametype("vip_escort", "cs_siege_2010", Vector(-498.195, 2120.627, -56.163), "gc_vip_escape_point", {reverseVIP = true})

    GM:AddObjectivePositionToGametype("vip_escort", "nt_rise",
            Vector(-514.183, 458.125, -71.968), "gc_vip_escape_point")
    GM:AddObjectivePositionToGametype("vip_escort", "nt_rise",
            Vector(729.067, 940.035, 80.031), "gc_vip_escape_point")
end