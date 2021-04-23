function GM:CreateLastManStandingDisplay(teamId)
    local living = 0
    local obj = nil

    for key, plyObj in ipairs(team.GetPlayers(teamId)) do
        if plyObj:Alive() then
            living = living + 1
            obj = plyObj
        end
    end

    if living == 1 and obj then
        net.Start("GC_LAST_MAN_STANDING")
        net.Send(obj)
    end
end

function GM:SwapPlayerTeams(players, targetTeam, callback)
    for key, ply in ipairs(players) do
        ply:SetTeam(targetTeam)

        if callback then
            callback(ply)
        end
    end
end

function GM:SwapTeams(teamOne, teamTwo, teamOneCallback, teamTwoCallback)
    local playersOne = team.GetPlayers(teamOne)
    local playersTwo = team.GetPlayers(teamTwo)

    self:SwapPlayerTeams(playersOne, teamTwo, teamOneCallback)
    self:SwapPlayerTeams(playersTwo, teamOne, teamTwoCallback)
end
