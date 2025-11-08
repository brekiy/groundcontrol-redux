GM.KillCountByTeam = {}
GM.ReportedDeadEnemies = {}
GM.AlivePlayers = {}

function GM:ResetKillcountData()
    for teamID, teamData in pairs(self.RegisteredTeamData) do
        self.KillCountByTeam[teamID] = 0

        self.ReportedDeadEnemies[teamID] = self.ReportedDeadEnemies[teamID] and table.Empty(self.ReportedDeadEnemies[teamID]) or {}
        self.AlivePlayers[teamID] = #team.GetPlayers(teamID) -- get the amount of players at the start of round

        self:SendAlivePlayerCount(self.OpposingTeam[teamID])
    end
end

function GM:ResetAllKillcountData() -- used in Urban Warfare
    self:ResetKillcountData()

    -- reset unconfirmed kills on players

    for _, plyObj in player.Iterator() do
        plyObj:ResetKillcountData()
    end
end

-- teamID is the recipient, it will automatically determine which list to send based on that
function GM:SendAlivePlayerCount(teamID)
    if teamID then -- if we're providing a team ID to send the alive player count to, then we will send the opposing team to them
        local playerCount = self.AlivePlayers[self.OpposingTeam[teamID]]

        if playerCount then
            for key, ply in ipairs(team.GetPlayers(teamID)) do
                net.Start("GC_ALIVE_PLAYER_COUNT")
                net.WriteInt(teamID, 8)
                net.WriteInt(playerCount, 8)
                net.Send(player)
            end
        end

        return
    end

    for key, enemyTeamID in pairs(self.OpposingTeam) do
        self:SendAlivePlayerCount(key)
    end
end

function GM:WasPlayerReportedDead(playerObject)
    local plyTeam = playerObject:Team()

    for key, otherPlayer in ipairs(self.ReportedDeadEnemies[plyTeam]) do
        if otherPlayer == playerObject then
            return key
        end
    end

    return false
end

-- called when a player disconnects
function GM:RemovePlayerFromReportedDeadList(playerObject, key)
    local theirTeam = playerObject:Team()

    if !self.OpposingTeam[theirTeam] then -- spectator, ignore
        return
    end

    if key then
        table.remove(self.ReportedDeadEnemies[theirTeam], key)
        self:SendAlivePlayerCount(self.OpposingTeam[theirTeam])
        return
    end

    local newKey = self:WasPlayerReportedDead(playerObject)

    if newKey then
        self:RemovePlayerFromReportedDeadList(playerObject, newKey)
    else
        self.AlivePlayers[theirTeam] = self.AlivePlayers[theirTeam] - 1
        self:SendAlivePlayerCount(self.OpposingTeam[theirTeam])
    end
end

function GM:AddReportedDeadEnemy(playerObject)
    if IsValid(playerObject) then
        local targetTeam = playerObject:Team()
        table.insert(self.ReportedDeadEnemies[targetTeam], playerObject)
        self.AlivePlayers[targetTeam] = self.AlivePlayers[targetTeam] - 1
    end
end

local PLAYER = FindMetaTable("Player")

function PLAYER:ResetKillcountData()
    self.unconfirmedKills = self.unconfirmedKills and table.Empty(self.unconfirmedKills) or {}
    self.confirmedKills = 0
end

function PLAYER:IncreaseKillcount(killedPlayer)
    self.unconfirmedKills[#self.unconfirmedKills + 1] = killedPlayer
end

function PLAYER:SendKillConfirmations()
    local confirmable = #self.unconfirmedKills

    if confirmable == 0 then
        return
    end

    for key, playerObject in ipairs(self.unconfirmedKills) do
        GAMEMODE:AddReportedDeadEnemy(playerObject)
        self.unconfirmedKills[key] = nil
    end

    GAMEMODE:SendAlivePlayerCount(self:Team())

    return confirmable -- return the amount of people we've confirmed the deaths of
end