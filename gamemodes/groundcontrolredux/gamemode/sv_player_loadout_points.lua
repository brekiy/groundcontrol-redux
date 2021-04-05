include("sh_player_loadout_points.lua")

-- local PLAYER = FindMetaTable("Player")

-- durrr
hook.Add("gc_event_update_loadout_cost", function(ply)
    ply:updateLoadoutPoints()
end)