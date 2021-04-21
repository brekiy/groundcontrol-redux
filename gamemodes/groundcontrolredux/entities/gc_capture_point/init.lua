AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.captureDistance = 192
ENT.captureAmount = 1
ENT.captureTime = 0.25
ENT.captureSpeedIncrease = 0.25
ENT.maxSpeedIncrease = 0.5
ENT.deCaptureTime = 1
ENT.deCaptureAmount = 1
ENT.roundWinTime = 5 -- seconds until round win if: 1. time has run out + the person was capturing a point and suddenly left the capture range
ENT.roundOverOnCapture = true

function ENT:Initialize()
    self:SetModel("models/error.mdl")
    self:SetNoDraw(true)

    self.captureDelay = 0
    self.deCaptureDelay = 0
    self.defenderTeam = nil
    self.winDelay = 0

    self:setCaptureDistance(self.captureDistance)

    local gametype = GAMEMODE:GetGametype()
    gametype:AssignPointID(self)
end

function ENT:setCapturerTeam(team) -- the team that has to capture this point
    self.capturerTeam = team
    self:SetCapturerTeam(team)
end

function ENT:setDefenderTeam(team)
    self.defenderTeam = team
end

function ENT:setCaptureDistance(distance)
    self.captureDistance = distance
    self:SetCaptureDistance(distance)
end

function ENT:setCaptureSpeed(speed)
    self.captureAmount = speed
end

-- we increase CaptureProgress by captureAmount every captureTime
function ENT:setCaptureDuration(time)
    self.captureTime = time
end

-- each player makes the capture go this % faster
function ENT:setCaptureSpeedInceasePerPlayer(speedIncrease)
    self.captureSpeedIncrease = speedIncrease
end

function ENT:setMaxCaptureSpeedIncrease(max)
    self.maxSpeedIncrease = max
end

function ENT:setRoundOverOnCapture(roundOver)
    self.roundOverOnCapture = roundOver
end

function ENT:Think()
    if GAMEMODE.RoundOver then
        return
    end

    if self.roundOverOnCapture and self:GetCaptureProgress() == 100 then
        GAMEMODE:EndRound(self.capturerTeam)
        return
    end

    local curTime = CurTime()
    local defendingPlayers = 0

    local ownPos = self:GetPos()

    for key, ply in ipairs(team.GetPlayers(self.defenderTeam)) do
        if ply:Alive() then
            local dist = ply:GetPos():Distance(ownPos)

            if dist <= self.captureDistance then
                defendingPlayers = defendingPlayers + 1
            end
        end
    end

    local capturingPlayers = 0

    if defendingPlayers == 0 then
        for key, ply in ipairs(team.GetPlayers(self.capturerTeam)) do
            if ply:Alive() then
                local dist = ply:GetPos():Distance(ownPos)

                if dist <= self.captureDistance then
                    capturingPlayers = capturingPlayers + 1
                end
            end
        end
    end

    if capturingPlayers > 0 then
        if curTime > self.captureDelay then
            local multiplier = math.max(1 - (capturingPlayers - 1) * self.captureSpeedIncrease, self.maxSpeedIncrease)

            self:SetCaptureSpeed(self.captureTime * multiplier / self.captureTime)
            self.captureDelay = curTime + self.captureTime * multiplier
            self.deCaptureDelay = curTime + self.deCaptureTime
            self.winDelay = curTime + self.roundWinTime
            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 100, self.captureAmount))
        end
    else
        if curTime > self.deCaptureDelay then
            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 0, 1))
            self.deCaptureDelay = curTime + self.deCaptureTime
        end
    end
end

function ENT:Use(activator, caller)
    return false
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end