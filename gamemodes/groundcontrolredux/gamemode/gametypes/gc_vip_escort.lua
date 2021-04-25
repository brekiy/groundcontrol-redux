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
    vipEscort.timeLimit = 255
    vipEscort.swappedTeams = false

    if SERVER then
        vipEscort.mapRotation = GM:GetMapRotation("vip_escort_maps")
    end

    function oneSideRush:Prepare()
        if CLIENT then
            RunConsoleCommand("gc_team_selection")
        end
    end

    function vipEscort:PlayerSpawn(ply)
        ply.isVIP = false
    end

    function vipEscort:Think()
    end

    function vipEscort:RoundStart()
        if SERVER then
            GAMEMODE:SetTimeLimit(self.timeLimit)
            local vipPlayers = team.GetPlayers(self.vipTeam)
            local vipIdx = math.random(1, #vipPlayers)
            vipPlayers[vipIdx].isVIP = true
        end
    end

    function vipEscort:PlayerDisconnected(ply)
        if ply.isVIP then
            GAMEMODE:EndRound(nil)
        end
    end

    function vipEscort:PlayerDeath(ply, attacker, dmginfo)
        if ply.isVIP then
            if IsValid(attacker) and ply != attacker and attacker:IsPlayer() then
                local victimTeam = ply:Team()
                local attackerTeam = attacker:Team()
                if victimTeam != attackerTeam then
                    attacker:AddCurrency("KILLED_VIP", nil)
                end
                GAMEMODE:EndRound(self.AmbushTeam)
            end
            GAMEMODE:EndRound(nil)
        end
    end

end