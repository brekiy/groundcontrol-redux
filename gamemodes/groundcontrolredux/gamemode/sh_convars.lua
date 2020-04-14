AddCSLuaFile()
CreateConVar("gc_min_weight_speed_decrease", 7.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "weight at which runspeed begins to be impacted", 1)
CreateConVar("gc_run_speed_penalty_per_weight", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "how much runspeed is subtracted per unit of weight over the threshold", 0)
CreateConVar("gc_bleed_time", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "time in seconds between each bleed tick", 0.5)
CreateConVar("gc_bleed_hp_lost_per_tick", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "health lost per bleed tick")
CreateConVar("gc_rounds_per_map", 16, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "num rounds per map - currently does nothing", 0)
CreateConVar("gc_health_regen_time", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "time between each regen tick from blunt trauma", 0)
CreateConVar("gc_enable_traits", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "allow traits to take effect")
