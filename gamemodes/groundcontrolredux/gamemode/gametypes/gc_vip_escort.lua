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
    vipEscort.timeLimit = 255
    vipEscort.swappedTeams = false
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
            -- print("vip team", self.vipTeam)
            if !self.swappedTeams and GAMEMODE.RoundsPlayed >= GetConVar("gc_default_rounds_per_map"):GetInt() * 0.5 then
                GAMEMODE:SwapTeams(self.vipTeam, self.ambushTeam, vipEscort.teamSwapCallback, vipEscort.teamSwapCallback)
                self.swappedTeams = true
                -- print("vip team after swapping", self.vipTeam)
            end
            -- timer(0, function()
            -- print("vip team right before setting vip", self.vipTeam)
            local vipPlayers = team.GetPlayers(self.vipTeam)
            local vipIdx = math.random(1, #vipPlayers)
            vipPlayers[vipIdx].isVIP = true
            self.stopCountdown = false
            GAMEMODE:InitializeGameTypeEntities(self)
            -- end)
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
        for k, ply in pairs(player.GetAll()) do
            ply.isVIP = false
            net.Start("GC_SET_VIP", ply)
            net.WriteBool(false)
            net.Send(ply)
        end
    end

    function vipEscort:PostPlayerDeath(ply) -- check for round over possibility
        GAMEMODE:CheckRoundOverPossibility(ply:Team())
    end

    function vipEscort:PlayerInitialSpawn(ply)
        if GAMEMODE.RoundsPlayed == 0 and #player.GetAll() >= 2 then
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

    GM:RegisterNewGametype(vipEscort)

    GM:AddObjectivePositionToGametype("vip_escort", "nt_isolation",
        Vector(-4151.822, -2887.363, 214.317), "gc_vip_escape_point")
end