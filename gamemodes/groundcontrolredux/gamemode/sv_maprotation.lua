GM.MapRotation = {}

function GM:RegisterMapRotation(name, maps)
    self.MapRotation[name] = maps
end

function GM:GetMapRotation(name)
    return self.MapRotation[name]
end

function GM:FilterExistingMaps(list)
    local newList = {}

    for key, mapName in ipairs(list) do
        if self:HasMap(mapName) then
            newList[#newList + 1] = mapName
        end
    end

    return newList
end

function GM:AddMapToMapRotationList(mapRotationList, mapName)
    if !self.MapRotation[mapRotationList] then
        self.MapRotation[mapRotationList] = {}
        print("[GROUND CONTROL] - attempt to add a map to a non-existant map rotation list, creating list")
    end

    table.insert(self.MapRotation[mapRotationList], mapName)
end

function GM:HasMap(mapName)
    return file.Exists("maps/" .. mapName .. ".bsp", "GAME")
end

GM:RegisterMapRotation("one_side_rush", {"de_dust", "de_dust2", "cs_assault", "cs_compound", "cs_havana", "de_cbble",
        "de_inferno", "de_nuke", "de_port", "de_tides", "de_aztec", "de_chateau", "de_piranesi",
        "de_prodigy", "de_train", "de_secretcamp", "nt_isolation", "cs_jungle", "cs_siege_2010", "gc_outpost",
        "de_desert_atrocity_v3", "gc_depot_b2", "rp_downtown_v2", "rp_downtown_v4c_v2", "nt_marketa", "nt_redlight", "nt_rise",
        "nt_skyline", "nt_shrine", "nt_dusk", "nt_transit"})
GM:RegisterMapRotation("ghetto_drug_bust_maps", {"cs_assault", "cs_compound", "cs_havana", "cs_militia", "cs_italy",
        "de_chateau", "de_inferno", "de_shanty_v3_fix", "gm_blackbrook_asylum", "nt_isolation", "nt_marketa", "nt_redlight", "nt_rise",
        "nt_skyline", "nt_shrine", "nt_dusk", "nt_transit", "cs_backalley2"})
    -- not being updated anymore
-- GM:RegisterMapRotation("assault_maps", {"cs_jungle", "cs_siege_2010", "gc_outpost", "de_desert_atrocity_v3", "gc_depot_b2", "nt_isolation"})
GM:RegisterMapRotation("urban_warfare_maps", {"ph_skyscraper_construct", "de_desert_atrocity_v3", "nt_isolation",
        "dm_zavod_yantar", "rp_downtown_v2", "rp_downtown_v4c_v2", "nt_marketa", "nt_redlight", "nt_rise", "nt_skyline",
        "nt_shrine", "nt_dusk", "nt_transit"})
GM:RegisterMapRotation("intel_retrieval_maps", {"de_chateau", "de_prodigy", "de_nuke", "nt_isolation", "nt_marketa",
        "nt_redlight", "nt_rise", "nt_skyline", "nt_shrine", "nt_dusk", "nt_transit", "nt_zaibatsu"})
GM:RegisterMapRotation("vip_escort_maps", {"cs_siege_2010", "nt_rise", "nt_isolation"})