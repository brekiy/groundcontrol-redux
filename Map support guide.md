Map Support guide

1. Register your map to an existing gamemode rotation.
Check the sv_maprotation.lua file for an example. Currently the gamemodes are:
one_side_rush
urbanwarfare_maps
ghetto_drug_bust

You can put your map directly in the table of map names or call the function
GM:AddMapToMapRotationList(mapRotationListName, mapName)

Original recommendation from the old documentation was to put this call in the sv_config.lua file and I agree.

2. Create objectives.
You need to call the function
GM:AddObjectivePositionToGametype("gameTypeName", "mapName", entityPosition, "entityClass", {customFlagsWithinTable = "yeas my bro."})

Read sh_gametypes.lua and the corresponding entities for examples. The custom flags are only needed if the entities require them.

In sh_entity_initializer, you'll find a function that will run the custom code you need for your own entities.
GM.entityInitializer:RegisterEntityInitializeCallback("entityClass", function(entity, curGameType, data)
        if data.data then
            if data.data.customFlagsWithinTable == "yeas my bro." then
                print("hello!")
            end
        end
    end)

"data.data" refers to the table that was passed in through the AddObjectivePositionToGametype() function.

3. Add spawn points.
Check sv_custom_spawn_points.lua for examples. They're very self explanatory.