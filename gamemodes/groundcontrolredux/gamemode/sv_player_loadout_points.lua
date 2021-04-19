include("sh_player_loadout_points.lua")

hook.Add("gc_event_update_loadout_cost", "GCR update_player_loadout_limit", function(ply)
    -- print("wowee hook firing on loadout cost time")
    ply:updateLoadoutPoints()
end)
