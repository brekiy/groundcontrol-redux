
-- the most barebones gametype, commented out because people kept picking it even though it's the most boring one and they thought it had respawns
-- you can use this as a base if you wish, but if you want to know what other methods gametype tables have, please take a look at other available gametypes

--[[
function GM:registerTeamDeathmatch()
    local tdm = {}
    tdm.name = "tdm"
    tdm.prettyName = "Team Deathmatch"

    if SERVER then
        tdm.mapRotation = GM:GetMapRotation("one_side_rush")
    end

    if SERVER then
        function tdm:PostPlayerDeath(ply) -- check for round over possibility
            GAMEMODE:CheckRoundOverPossibility(ply:Team())
        end

        function tdm:PlayerDisconnected(ply)
            -- nothing fancy, just skip 1 frame and call PostPlayerDeath, since 1 frame later the player won't be anywhere in the player tables
            timer.Simple(0, function()
                GAMEMODE:CheckRoundOverPossibility(ply:Team(), true)
            end)
        end

        function tdm:PlayerJoinTeam(ply, teamId)
            GAMEMODE:CheckRoundOverPossibility(nil, true)
        end
    end

    GM:RegisterNewGametype(tdm)
end
]]--