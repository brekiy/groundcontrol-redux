AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.captureDistance = 192
-- Incrementing/decrementing progress will use the same time tick under the new formula
ENT.captureTime = 1
-- How much to decrement progress by
ENT.deCaptureSpeed = 1
-- seconds until round win if: 1. time has run out + the person was capturing a point and suddenly left the capture range
ENT.roundWinTime = 5
ENT.roundOverOnCapture = true
-- Hard cap on how fast capture can occur
ENT.MAX_CAPTURERS = 4
-- The starting factor added to the capture amount
ENT.BASE_CAP_FACTOR = 0.6
-- How often in seconds to cap
ENT.CAPTURE_TICK = 1

function ENT:Initialize()
    self:SetModel("models/error.mdl")
    self:SetNoDraw(true)

    self.captureDelay = 0
    self.deCaptureDelay = 0
    self.winDelay = 0
    self.ownPos = self:GetPos()

    self:SetCaptureDistance(self.captureDistance)

    local gametype = GAMEMODE:GetGametype()
    gametype:AssignPointID(self)
end

function ENT:CalcCaptureSpeed(numPly)
    numPly = math.Clamp(numPly, 1, self.MAX_CAPTURERS)
    return 1 + ((numPly - 1) * self.BASE_CAP_FACTOR) / math.pow(2, numPly - 2)
end

function ENT:SetRoundOverOnCapture(roundOver)
    self.roundOverOnCapture = roundOver
end

function ENT:SetCaptureTime(time)
    self.CAPTURE_TIME = time
end

function ENT:Think()
    if GAMEMODE.RoundOver then
        return
    end

    if self.roundOverOnCapture and self:GetCaptureProgress() >= self.CAPTURE_TIME then
        for key, ply in ipairs(team.GetPlayers(self:GetCapturerTeam())) do
            if ply:Alive() and ply:GetPos():Distance(self.ownPos) <= self.captureDistance then
                GAMEMODE:TrackRoundMVP(ply, "objective", 1)
            end
        end
        GAMEMODE:EndRound(self:GetCapturerTeam())
        return
    end

    local curTime = CurTime()
    local defendingPlayers = 0

    for key, ply in ipairs(team.GetPlayers(self:GetDefenderTeam())) do
        if ply:Alive() and ply:GetPos():Distance(self.ownPos) <= self.captureDistance then
            defendingPlayers = defendingPlayers + 1
        end
    end

    local capturingPlayers = 0

    if defendingPlayers == 0 then
        for key, ply in ipairs(team.GetPlayers(self:GetCapturerTeam())) do
            if ply:Alive() and ply:GetPos():Distance(self.ownPos) <= self.captureDistance then
                capturingPlayers = capturingPlayers + 1
            end
        end
    end

    if capturingPlayers > 0 then
        if curTime > self.captureDelay then
            self:SetCaptureSpeed(self:CalcCaptureSpeed(capturingPlayers))
            self.captureDelay = curTime + self.CAPTURE_TICK
            self.deCaptureDelay = curTime + self.CAPTURE_TICK
            self.winDelay = curTime + self.roundWinTime
            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), self.CAPTURE_TIME, self:GetCaptureSpeed()))
        end
    else
        if curTime > self.deCaptureDelay then
            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 0, self.deCaptureSpeed))
            self.deCaptureDelay = curTime + self.CAPTURE_TICK
        end
    end
end

function ENT:Use(activator, caller)
    return false
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end