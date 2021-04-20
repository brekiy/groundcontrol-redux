AddCSLuaFile()
AddCSLuaFile("cl_events.lua")

if CLIENT then
    include("cl_events.lua")
end

GM.EventsByName = {}
GM.EventsByID = {}
GM.EmptyTable = {}

function GM:registerEvent(eventName, display, tipId, cash, exp)
    local eventId = #self.EventsByID + 1
    local data = {
        eventName = eventName,
        eventId = eventId,
        display = display,
        tipId = tipId,
        cash = cash,
        exp = exp
    }

    self.EventsByName[eventName] = data
    self.EventsByID[eventId] = data
end
GM:registerEvent("ENEMY_KILLED", "Enemy down", "KILLED_ENEMY", 50, 20)
GM:registerEvent("KILL_ASSIST", "Kill assist", nil)
GM:registerEvent("TEAMMATE_RESUPPLIED", "Teammate resupplied", nil, 15, 20)
GM:registerEvent("TEAMMATE_BANDAGED", "Teammate bandaged", nil, 20, 25)
-- kill a target that was about to kill a buddy
GM:registerEvent("TEAMMATE_SAVED", "Saved teammate", nil, 25, 40)
-- kill a target that was starting to damage a buddy
GM:registerEvent("TEAMMATE_HELPED", "Helped teammate", nil, 15, 30)
-- kill someone while on the verge of death
GM:registerEvent("CLOSE_CALL", "Close call", nil, 15, 10)
GM:registerEvent("WON_ROUND", "Round won", nil, 200, 150)
GM:registerEvent("HEADSHOT", "Headshot", nil, 10, 5)
GM:registerEvent("SPOT_KILL", "Spot kill")
-- kill someone while being the last living team member
GM:registerEvent("ONE_MAN_ARMY", "One man army", nil, 15, 10)
GM:registerEvent("REPORT_ENEMY_DEATH", "Reported enemy death")
GM:registerEvent("TEAMKILL", "Teamkill", nil, -50, -80)
GM:registerEvent("OBJECTIVE_CAPTURED", "Objective captured", nil, 50, 50)
GM:registerEvent("WAVE_WON", "Wave won")
GM:registerEvent("RETURNED_DRUGS", "Returned drugs")
GM:registerEvent("KILLED_OBJ_CARRIER", "Killed objective carrier", nil, 25, 25)
GM:registerEvent("SECURED_DRUGS", "Secured drugs")
GM:registerEvent("TOOK_DRUGS", "Took drugs")
GM:registerEvent("BLEED_OUT_KILL", "Enemy bled out")
GM:registerEvent("SECURED_INTEL", "Secured intel", nil, 100, 100)
-- GM:registerEvent("KILLED_INTEL_CARRIER", "Killed intel carrier")

GM.EventData = {}

function GM:getEventIdFromName(eventName)
    return self.EventsByName[eventName].eventId
end

function GM:getEventById(eventId)
    return self.EventsByID[eventId]
end

function GM:getEventByName(eventName)
    return self.EventsByName[eventName]
end

function GM:getEventId(eventData)
    return eventData.id
end