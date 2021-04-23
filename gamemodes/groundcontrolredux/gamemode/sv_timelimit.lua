AddCSLuaFile("cl_timelimit.lua")
include("sh_timelimit.lua")

function GM:SetTimeLimit(time)
    self.TimeLimit = time
    self.RoundStart = CurTime()
    self.RoundTime = CurTime() + time
end

function GM:SendTimeLimit(target)
    if !self.TimeLimit then
        return
    end

    net.Start("GC_TIMELIMIT")
    net.WriteFloat(self.RoundStart)
    net.WriteFloat(self.TimeLimit)
    net.Send(target)
end

function GM:HasTimeLimit()
    return self.TimeLimit != nil
end

function GM:HasTimeRunOut()
    return CurTime() >= self.RoundTime
end