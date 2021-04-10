include("sh_events.lua")

function GM:sendEvent(ply, event, additionalData)
    local eventData = self:getEventByName(event)
    self.EventData.eventId = eventData.eventId
    self.EventData.eventData = additionalData or self.EmptyTable

    net.Start("GC_EVENT")
    net.WriteTable(self.EventData)
    net.Send(ply)

    net.Start("GC_UPDATE_LOADOUT_LIMIT")
    net.Send(ply)
    -- hook.Run("gc_event_update_loadout_cost", ply)
end
