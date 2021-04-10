AddCSLuaFile("cl_timelimit.lua")
include("sh_timelimit.lua")

function GM:setTimeLimit(time)
    self.TimeLimit = time
    self.RoundStart = CurTime()
    self.RoundTime = CurTime() + time
end

function GM:sendTimeLimit(target)
    if not self.TimeLimit then
        return
    end

    net.Start("GC_TIMELIMIT")
    net.WriteFloat(self.RoundStart)
    net.WriteFloat(self.TimeLimit)
    net.Send(target)
end

function GM:hasTimeLimit()
    return self.TimeLimit ~= nil
end

function GM:hasTimeRunOut()
    return CurTime() >= self.RoundTime
end