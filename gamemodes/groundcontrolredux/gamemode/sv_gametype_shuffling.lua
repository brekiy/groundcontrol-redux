-- the following module, when enabled, disables map and gametype votes, and will pick a random valid gametype (one that has maps valid for it) and will change to a random map within that gametype)
-- this module will assume that you have at least 1 map for at least 1 gametype (ie. a minimum of 1 valid gametype)
CreateConVar("gc_randomly_pick_gametype_and_map", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

function GM:RandomlyPickGametypeAndMap()
    local validGametypes = {}

    for key, gametypeData in ipairs(self.Gametypes) do
        local validMaps = self:FilterExistingMaps(gametypeData.mapRotation)

        if #validMaps > 0 then
            validGametypes[gametypeData] = validMaps
        end
    end

    local randomMaps, randomGametype = table.Random(validGametypes)

    game.ConsoleCommand("gc_gametype " .. randomGametype.name .. "\n")

    timer.Simple(0, function()
        game.ConsoleCommand("changelevel " .. randomMaps[math.random(1, #randomMaps)] .. "\n")
    end)
end