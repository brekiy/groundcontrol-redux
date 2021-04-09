include("sh_player_loadout_points.lua")

-- local PLAYER = FindMetaTable("Player")

-- durrr
hook.Add("gc_event_update_loadout_cost", "GCR update_player_loadout_limit", function(ply)
    -- print("wowee hook firing on loadout cost time")
    ply:updateLoadoutPoints()
end)

-- hook.Add("gc_loadout_cost_tip", "GCR loadout_cost_tip", function(ply)
--     net.Start("GC_NOT_ENOUGH_CASH")
--     -- net.WriteInt(price, 32)
--     net.Send(ply)
-- end)