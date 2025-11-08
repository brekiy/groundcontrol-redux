GM.entityInitializer = {}
GM.entityInitializer.entClassCallbacks = {}

function GM.entityInitializer:InitEntity(ent, curGameType, data)
    local class = ent:GetClass()

    if self.entClassCallbacks[class] then
        self.entClassCallbacks[class](ent, curGameType, data)
    end
end

function GM.entityInitializer:RegisterEntityInitializeCallback(entClass, callback)
    self.entClassCallbacks[entClass] = callback
end

GM.entityInitializer:RegisterEntityInitializeCallback("gc_capture_point", function(entity, curGameType, data)
    if data.data then
        if data.data.captureDistance then
            entity:SetCaptureDistance(data.data.captureDistance)
        end

        if data.data.capturerTeam then
            entity:SetCapturerTeam(data.data.capturerTeam)
            -- curGameType.realAttackerTeam = data.data.capturerTeam
        else
            entity:SetCapturerTeam(curGameType.attackerTeam)
            -- curGameType.realAttackerTeam = curGameType.attackerTeam
        end

        if data.data.defenderTeam then
            entity:SetDefenderTeam(data.data.defenderTeam)
            -- curGameType.realDefenderTeam = data.data.defenderTeam
        else
            entity:SetDefenderTeam(curGameType.defenderTeam)
            -- curGameType.realDefenderTeam = curGameType.defenderTeam
        end
    else
        entity:SetCapturerTeam(curGameType.attackerTeam)
        entity:SetDefenderTeam(curGameType.defenderTeam)
    end
end)

GM.entityInitializer:RegisterEntityInitializeCallback("gc_offlimits_area", function(entity, curGameType, data)
    if data.data then
        if data.data.inverseFunctioning then
            entity:SetInverseFunctioning(true)
        end

        if data.data.targetTeam then
            entity:SetTargetTeam(data.data.targetTeam)
        end

        if data.data.distance then
            entity:SetDistance(data.data.distance)
        end
    end
end)

GM.entityInitializer:RegisterEntityInitializeCallback("gc_offlimits_area_aabb", function(entity, curGameType, data)
    if data.data then
        if data.data.inverseFunctioning then
            entity:SetInverseFunctioning(true)
        end

        if data.data.targetTeam then
            entity:SetTargetTeam(data.data.targetTeam)
        end

        entity:SetAABB(data.data.min, data.data.max)
    end
end)

GM.entityInitializer:RegisterEntityInitializeCallback("gc_urban_warfare_capture_point", function(entity, curGameType, data)
    if data.data and data.data.capMin and data.data.capMax then
        entity:SetCaptureAABB(data.data.capMin, data.data.capMax)
    end

    curGameType.capturePoint = entity

    local ticketAmount = nil

    if curGameType.ticketsPerPlayer then
        ticketAmount = math.Round(player.GetCount() * curGameType.ticketsPerPlayer)
    else
        ticketAmount = curGameType.startingTickets
    end

    entity:InitTickets(ticketAmount)
end)


GM.entityInitializer:RegisterEntityInitializeCallback("gc_drug_point", function(entity, curGameType, data)
    entity:FreezeNearbyProps()
    entity:SpawnDrugs()
end)

GM.entityInitializer:RegisterEntityInitializeCallback("gc_intel_spawn_point", function(entity, curGameType, data)
    entity:FreezeNearbyProps()
end)

GM.entityInitializer:RegisterEntityInitializeCallback("gc_intel_capture_point", function(entity, curGameType, data)
    if data.data then
        if data.data.captureDistance then
            entity:SetCaptureDistance(data.data.captureDistance)
        end

        if data.data.capturerTeam then
            entity:SetCapturerTeam(data.data.capturerTeam)
        end
    end
end)

GM.entityInitializer:RegisterEntityInitializeCallback("gc_vip_escape_point", function(entity, curGameType, data)
    if data.data then
        -- boolean
        if data.data.reverseVIP then
            curGameType:SwapVIPTeam()
        end

        if data.data.escapeDistance then
            entity:SetEscapeDistance(data.data.escapeDistance)
        end
    end
    entity:SetVIPTeam(curGameType.vipTeam)
end)
