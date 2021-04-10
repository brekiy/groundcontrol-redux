GM.AlivePlayers = {}

net.Receive("GC_ALIVE_PLAYER_COUNT", function()
    for teamID, teamData in pairs(GAMEMODE.OpposingTeam) do
        GAMEMODE.AlivePlayers[teamID] = 0
    end

    local targetTeam = net.ReadInt(8)
    local opposingTeam = GAMEMODE.OpposingTeam[targetTeam]

    if opposingTeam then
        local alivePlayers = net.ReadInt(8)

        GAMEMODE.AlivePlayers[opposingTeam] = alivePlayers
    end
end)