CreateConVar("gc_min_weight_speed_decrease", 7.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "weight at which runspeed begins to be impacted", 1)
CreateConVar("gc_run_speed_penalty_per_weight", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "how much runspeed is subtracted per unit of weight over the threshold", 0)
CreateConVar("gc_bleed_time", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "time in seconds between each bleed tick", 0.5)
CreateConVar("gc_bleed_hp_lost_per_tick", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "health lost per bleed tick")