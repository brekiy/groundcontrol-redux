AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.captureDistance = 192
ENT.captureAmount = 1
ENT.captureTime = 0.25
ENT.captureSpeedIncrease = 0.1
ENT.maxSpeedIncrease = 0.5
ENT.deCaptureTime = 1
ENT.deCaptureAmount = 1
ENT.roundOverOnCapture = true

function ENT:Initialize()
    self:SetModel("models/error.mdl")
    self:SetNoDraw(true)

    self.captureDelay = 0
    self.deCaptureDelay = 0
    self:SetCurCaptureTeam(0)
end

function ENT:SetCaptureDistance(distance)
    self.captureDistance = distance
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
        GAMEMODE:EndRound(self:GetCurCaptureTeam())
        return
    end

    local curTime = CurTime()
    local redMembers = 0
    local blueMembers = 0
    local ownPos = self:GetPos()

    for key, ply in ipairs(team.GetPlayers(TEAM_RED)) do
        if ply:Alive() then
            local dist = ply:GetPos():Distance(ownPos)

            if dist <= self.captureDistance then
                redMembers = redMembers + 1
            end
        end
    end

    for key, ply in ipairs(team.GetPlayers(TEAM_BLUE)) do
        if ply:Alive() then
            local dist = ply:GetPos():Distance(ownPos)

            if dist <= self.captureDistance then
                blueMembers = blueMembers + 1
            end
        end
    end

    -- don't calc capture progress if the point is being contested
    if redMembers > 0 and blueMembers > 0 then
        return
    end

    local desiredTeam = nil
    local capturingMembers = nil

    if redMembers > 0 then
        desiredTeam = TEAM_RED
        capturingMembers = redMembers
    elseif blueMembers > 0 then
        desiredTeam = TEAM_BLUE
        capturingMembers = blueMembers
    end

    if desiredTeam then
        if curTime < self.captureDelay then
            return
        end

        local canCapture = desiredTeam == self:GetCurCaptureTeam()
        local multiplier = math.max(1 - (capturingMembers - 1) * self.captureSpeedIncrease, self.maxSpeedIncrease)

        self.captureDelay = curTime + self.captureTime * multiplier
        self.deCaptureDelay = curTime + self.deCaptureTime

        if canCapture then
            -- if we can capture, advance progress to 100
            if self:GetCurCaptureTeam() == 0 then
                self:SetCurCaptureTeam(desiredTeam)
            end

            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 100, self.captureAmount))
        else
            -- else reduce enemy progress to 0 first
            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 0, self.captureAmount))

            if self:GetCaptureProgress() == 0 then
                self:SetCurCaptureTeam(desiredTeam)
            end
        end
    else
        if curTime < self.deCaptureDelay then
            return
        end

        self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 0, 1))
        self.deCaptureDelay = curTime + self.deCaptureTime
    end
end

function ENT:Use(activator, caller)
    return false
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end