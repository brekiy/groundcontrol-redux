AddCSLuaFile()
-- Weight/stamina cvars
CreateConVar("gc_weight_min_level_speed_decrease", 7.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Weight (kg) at which sprinting begins to be impacted", 1)
CreateConVar("gc_weight_sprint_penalty", 0.75, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Sprint speed penalty per kg over the threshold, walking affected at half", 0)
CreateConVar("gc_weight_stamina_drain", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Stamina drain factor for weight", 0)
CreateConVar("gc_stamina_drain_time", 0.25, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time in seconds between each stamina tick", 0.1)
CreateConVar("gc_stamina_regen_time", 0.35, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time in seconds between each stamina tick", 0.1)
CreateConVar("gc_stamina_run_impact_level", 80, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "% stamina where sprint speed starts to drop", 0.1)
CreateConVar("gc_stamina_run_impact", 1.3, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "low stamina sprint speed affector ", 0.1)
CreateConVar("gc_stamina_aim_shake_factor", 0.025, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "aim shake factor when tired, set to 0 if you dont like it", 0)

-- Movement cvars
CreateConVar("gc_base_run_speed", 270, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "base run speed", 200)
CreateConVar("gc_base_walk_speed", 200, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "base walk speed - if this gets too low, cw2 viewmodels start getting this really ugly jitter", 100)

-- Adrenaline cvars
CreateConVar("gc_adrenaline_maxspeed_increase", 0.1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("gc_adrenaline_stamina_drain_modifier", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("gc_adrenaline_stamina_regen_modifier", 0.1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

-- Health/bleed cvars
CreateConVar("gc_bleed_time", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time in seconds between each bleed tick", 0.5)
CreateConVar("gc_bleed_hp_lost_per_tick", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "health lost per bleed tick", 1)
CreateConVar("gc_health_regen_time", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time between each regen tick", 0.5)

-- Round cvars
CreateConVar("gc_default_rounds_per_map", 16, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "num rounds per game", 4)
CreateConVar("gc_urban_warfare_rounds_per_map", 6, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "num rounds per urban warfare game", 2)
CreateConVar("gc_enable_traits", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "allow traits to take effect - currently does nothing")
CreateConVar("gc_print_damage_log", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "show damage log in console after round")
CreateConVar("gc_force_pip_scopes", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "0/1 to turn on/off pip scopes for everyone", 0, 1)
CreateConVar("gc_force_free_aim", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "0/1 to turn on/off free-aim hipfire for everyone", 0, 1)

-- Loadout cvars
CreateConVar("gc_base_loadout_points", 40, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "points to spend on loadout", 30)
CreateConVar("gc_loadout_points_per_score", 0.005, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "loadout points awarded per score", 0)
CreateConVar("gc_max_loadout_points", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "max loadout points", 50)
CreateConVar("gc_armor_damage_factor", 1.25, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "adjust rate at which armor takes damage")
CreateConVar("gc_damage_multiplier", 1.55, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "bullet damage multiplier")
CreateConVar("gc_use_cw2_weps", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
CreateConVar("gc_use_cw2_spy", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "enable spy's cw2 weps")
CreateConVar("gc_use_cw2_kk_ins2", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "enable knife kitty's ins2 weps")
CreateConVar("gc_use_cw2_kk_ext", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "enable knife kitty's extra weps")
CreateConVar("gc_use_cw2_kk_btk", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "enable knife kitty's btk weps")
CreateConVar("gc_use_cw2_khris", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "enable khris' extra weps")
CreateConVar("gc_use_cw2_soap", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "enable soap's extra weps")
CreateConVar("gc_use_cw2_misc", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "enable misc extra cw weps")
CreateConVar("gc_use_arccw_weps", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "wip non functional")
CreateConVar("gc_use_tfa_weps", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "wip non functional")

-- Gametype cvars
CreateConVar("gc_gametype", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("gc_allow_gametype_votes", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

-- Misc
CreateConVar("gc_meme_radio_chance", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "chance out of 1000 to have special radio lines come up", 1, 1000)
CreateConVar("gc_autopunish_teamdamage", 300, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "maximum team damage allowed before autovotekick", 100)
CreateConVar("gc_cw2_phys_bullets", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "force physical bullets on for cw2.0")
