
-- the most barebones gametype, commented out because people kept picking it even though it's the most boring one and they thought it had respawns
-- you can use this as a base if you wish, but if you want to know what other methods gametype tables have, please take a look at other available gametypes

--[[
function GM:registerTeamDeathmatch()
    local tdm = {}
    tdm.name = "tdm"
    tdm.prettyName = "Team Deathmatch"

    if SERVER then
        tdm.mapRotation = GM:getMapRotation("one_side_rush")
    end

    if SERVER then
        function tdm:postPlayerDeath(ply) -- check for round over possibility
            GAMEMODE:checkRoundOverPossibility(ply:Team())
        end

        function tdm:playerDisconnected(ply)
            local hisTeam = ply:Team()

            timer.Simple(0, function() -- nothing fancy, just skip 1 frame and call postPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
                GAMEMODE:checkRoundOverPossibility(hisTeam, true)
            end)
        end

        function tdm:playerJoinTeam(ply, teamId)
            GAMEMODE:checkRoundOverPossibility(nil, true)
        end
    end

    GM:registerNewGametype(tdm)
end
]]--