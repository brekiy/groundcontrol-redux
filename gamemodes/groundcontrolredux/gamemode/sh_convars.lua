AddCSLuaFile()
CreateConVar("gc_min_weight_speed_decrease", 7.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "weight at which runspeed begins to be impacted", 1)
CreateConVar("gc_run_speed_penalty_per_weight", 0.65, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "how much runspeed is subtracted per unit of weight over the threshold", 0)
CreateConVar("gc_bleed_time", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "time in seconds between each bleed tick", 0.5)
CreateConVar("gc_bleed_hp_lost_per_tick", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "health lost per bleed tick")
CreateConVar("gc_rounds_per_map", 16, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "num rounds per map - currently does nothing", 0)
CreateConVar("gc_health_regen_time", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "time between each regen tick from blunt trauma", 0)
CreateConVar("gc_enable_traits", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "allow traits to take effect - currently does nothing")
CreateConVar("gc_print_damage_log", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "show damage log in console after round")

CreateConVar("gc_force_pip_scopes", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "0/1 to turn on/off pip scopes for everyone", 0, 1)
CreateConVar("gc_force_free_aim", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "0/1 to turn on/off free-aim hipfire for everyone", 0, 1)

-- Loadout cvars
CreateConVar("gc_base_loadout_points", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "points to spend on loadout", 50)
CreateConVar("gc_loadout_points_per_score", 0.01, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "loadout points awarded per score", 0)
CreateConVar("gc_max_loadout_points", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "max loadout points", 50)
CreateConVar("gc_armor_damage_factor", 1.25, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "adjust rate at which armor takes damage")
CreateConVar("gc_damage_multiplier", 1.55, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "bullet damage multiplier")

-- Gametype cvars
CreateConVar("gc_gametype", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("gc_allow_gametype_votes", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

-- Misc
CreateConVar("gc_meme_radio_chance", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "chance out of 1000 to have special radio lines come up", 1, 1000) -- in 1000
CreateConVar("gc_autopunish_teamdamage", 300, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "maximum team damage allowed before autovotekick", 10)

