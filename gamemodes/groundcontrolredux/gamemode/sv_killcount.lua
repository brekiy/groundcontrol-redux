GM.KillCountByTeam = {}
GM.ReportedDeadEnemies = {}
GM.AlivePlayers = {}

function GM:resetKillcountData()
    for teamID, teamData in pairs(self.RegisteredTeamData) do
        self.KillCountByTeam[teamID] = 0

        self.ReportedDeadEnemies[teamID] = self.ReportedDeadEnemies[teamID] and table.Empty(self.ReportedDeadEnemies[teamID]) or {}
        self.AlivePlayers[teamID] = #team.GetPlayers(teamID) -- get the amount of players at the start of round

        self:sendAlivePlayerCount(self.OpposingTeam[teamID])
    end
end

function GM:resetAllKillcountData() -- used in Urban Warfare
    self:resetKillcountData()

    -- reset unconfirmed kills on players

    for key, plyObj in ipairs(player.GetAll()) do
        plyObj:resetKillcountData()
    end
end

-- teamID is the recipient, it will automatically determine which list to send based on that
function GM:sendAlivePlayerCount(teamID)
    if teamID then -- if we're providing a team ID to send the alive player count to, then we will send the opposing team to them
        local playerCount = self.AlivePlayers[self.OpposingTeam[teamID]]

        if playerCount then
            for key, player in ipairs(team.GetPlayers(teamID)) do
                net.Start("GC_ALIVE_PLAYER_COUNT")
                    net.WriteInt(teamID, 8)
                    net.WriteInt(playerCount, 8)
                net.Send(player)
            end
        end

        return
    end

    for teamID, enemyTeamID in pairs(self.OpposingTeam) do
        self:sendAlivePlayerCount(teamID)
    end
end

function GM:wasPlayerReportedDead(playerObject)
    local team = playerObject:Team()

    for key, otherPlayer in ipairs(self.ReportedDeadEnemies[team]) do
        if otherPlayer == playerObject then
            return key
        end
    end

    return false
end

-- called when a player disconnects
function GM:removePlayerObjectFromReportedDeadList(playerObject, key)
    local theirTeam = playerObject:Team()

    if !self.OpposingTeam[theirTeam] then -- spectator, ignore
        return
    end

    if key then
        table.remove(self.ReportedDeadEnemies[theirTeam], key)
        self:sendAlivePlayerCount(self.OpposingTeam[theirTeam])
        return
    end

    local key = self:wasPlayerReportedDead(playerObject)

    if key then
        self:removePlayerObjectFromReportedDeadList(playerObject, key)
    else
        self.AlivePlayers[theirTeam] = self.AlivePlayers[theirTeam] - 1
        self:sendAlivePlayerCount(self.OpposingTeam[theirTeam])
    end
end

function GM:addReportedDeadEnemy(playerObject)
    local team = playerObject:Team()

    table.insert(self.ReportedDeadEnemies[team], playerObject)
    self.AlivePlayers[team] = self.AlivePlayers[team] - 1
end

local PLAYER = FindMetaTable("Player")

function PLAYER:resetKillcountData()
    self.unconfirmedKills = self.unconfirmedKills and table.Empty(self.unconfirmedKills) or {}
    self.confirmedKills = 0
end

function PLAYER:increaseKillcount(killedPlayer)
    self.unconfirmedKills[#self.unconfirmedKills + 1] = killedPlayer
end

function PLAYER:sendKillConfirmations()
    local confirmable = #self.unconfirmedKills

    if confirmable == 0 then
        return
    end

    for key, playerObject in ipairs(self.unconfirmedKills) do
        GAMEMODE:addReportedDeadEnemy(playerObject)
        self.unconfirmedKills[key] = nil
    end

    GAMEMODE:sendAlivePlayerCount(self:Team())

    return confirmable -- return the amount of people we've confirmed the deaths of
end