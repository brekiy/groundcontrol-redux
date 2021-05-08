AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.captureDistance = 192
-- Incrementing/decrementing progress will use the same time tick under the new formula
ENT.captureTime = 1
-- How much to decrement progress by
ENT.deCaptureSpeed = 1
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
    self:SetCurCaptureTeam(0)
end

function ENT:SetCaptureDistance(distance)
    self.captureDistance = distance
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
        self:SetCaptureSpeed(self:CalcCaptureSpeed(capturingMembers))
        self.captureDelay = curTime + self.CAPTURE_TICK
        self.deCaptureDelay = curTime + self.CAPTURE_TICK

        if canCapture then
            -- if we can capture, advance progress to 100
            if self:GetCurCaptureTeam() == 0 then
                self:SetCurCaptureTeam(desiredTeam)
            end

            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), self.CAPTURE_TIME, self:GetCaptureSpeed()))
        else
            -- else reduce enemy progress to 0 first
            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 0, self:GetCaptureSpeed()))

            if self:GetCaptureProgress() == 0 then
                self:SetCurCaptureTeam(desiredTeam)
            end
        end
    else
        if curTime < self.deCaptureDelay then
            return
        end

        self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 0, self.deCaptureSpeed))
        self.deCaptureDelay = curTime + self.CAPTURE_TICK
    end
end

function ENT:Use(activator, caller)
    return false
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end