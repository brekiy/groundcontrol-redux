AddCSLuaFile()
AddCSLuaFile("cl_events.lua")

if CLIENT then
    include("cl_events.lua")
end

GM.EventsByName = {}
GM.EventsByID = {}
GM.EmptyTable = {}

function GM:RegisterEvent(eventName, display, tipId, cash, exp)
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
GM:RegisterEvent("ENEMY_KILLED", "Enemy down", "KILLED_ENEMY", 50, 20)
GM:RegisterEvent("KILL_ASSIST", "Kill assist", nil)
GM:RegisterEvent("TEAMMATE_RESUPPLIED", "Teammate resupplied", nil, 15, 20)
GM:RegisterEvent("TEAMMATE_BANDAGED", "Teammate bandaged", nil, 20, 25)
-- kill a target that was about to kill a buddy
GM:RegisterEvent("TEAMMATE_SAVED", "Saved teammate", nil, 25, 40)
-- kill a target that was starting to damage a buddy
GM:RegisterEvent("TEAMMATE_HELPED", "Helped teammate", nil, 15, 30)
-- kill someone while on the verge of death
GM:RegisterEvent("CLOSE_CALL", "Close call", nil, 15, 10)
GM:RegisterEvent("WON_ROUND", "Round won", nil, 200, 150)
GM:RegisterEvent("HEADSHOT", "Headshot", nil, 10, 5)
GM:RegisterEvent("SPOT_KILL", "Spot kill")
-- kill someone while being the last living team member
GM:RegisterEvent("ONE_MAN_ARMY", "One man army", nil, 15, 10)
GM:RegisterEvent("REPORT_ENEMY_DEATH", "Reported enemy death")
GM:RegisterEvent("TEAMKILL", "Teamkill", nil, -50, -80)
GM:RegisterEvent("OBJECTIVE_CAPTURED", "Objective captured", nil, 50, 50)
GM:RegisterEvent("WAVE_WON", "Wave won")
GM:RegisterEvent("RETURNED_DRUGS", "Returned drugs")
GM:RegisterEvent("KILLED_OBJ_CARRIER", "Killed objective carrier", nil, 25, 25)
GM:RegisterEvent("SECURED_DRUGS", "Secured drugs")
GM:RegisterEvent("TOOK_DRUGS", "Took drugs")
GM:RegisterEvent("BLEED_OUT_KILL", "Enemy bled out")
GM:RegisterEvent("SECURED_INTEL", "Secured intel", nil, 100, 100)
-- GM:RegisterEvent("KILLED_INTEL_CARRIER", "Killed intel carrier")

GM.EventData = {}

function GM:GetEventIdFromName(eventName)
    return self.EventsByName[eventName].eventId
end

function GM:GetEventById(eventId)
    return self.EventsByID[eventId]
end

function GM:GetEventByName(eventName)
    return self.EventsByName[eventName]
end

function GM:GetEventId(eventData)
    return eventData.id
end