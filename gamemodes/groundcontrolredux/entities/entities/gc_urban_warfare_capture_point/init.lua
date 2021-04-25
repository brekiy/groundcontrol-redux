AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.captureDistance = 192
-- Incrementing/decrementing progress will use the same time tick under the new formula
ENT.captureTime = 1
-- How much to decrement progress by
ENT.deCaptureSpeed = 1
-- time in seconds the de-capture will be delayed when being capped
ENT.deCaptureTimeOnCapture = 5
ENT.deCaptureAmount = 1
ENT.deCaptureSpeedMultiplier = 2.5
ENT.noCaptureDuration = 10
-- seconds until round win if: 1. time has run out + the person was capturing a point and suddenly left the capture range
ENT.roundWinTime = 5
ENT.roundOverOnCapture = true
-- The starting factor added to the capture amount
ENT.BASE_CAP_FACTOR = 0.6
-- Hard cap on how fast capture can occur
ENT.MAX_CAPTURERS = 4
-- How often in seconds to cap
ENT.CAPTURE_TICK = 1

function ENT:Initialize()
    self:SetModel("models/error.mdl")
    self:SetNoDraw(true)

    self.winDelay = 0
    self.noCaptureTime = 0
    self.deCaptureDelay = 0
    self.lastUpdate = 0

    self:SetCaptureDistance(self.captureDistance)

    local gametype = GAMEMODE:GetGametype()
    gametype:AssignPointID(self)

    self:SetCaptureMin(Vector(0, 0, 0))
    self:SetCaptureMax(Vector(0, 0, 0))
end

function ENT:CalcCaptureSpeed(numPly)
    numPly = math.Clamp(numPly, 1, self.MAX_CAPTURERS)
    return 1 + ((numPly - 1) * self.BASE_CAP_FACTOR) / math.pow(2, numPly - 2)
end

function ENT:setRoundOverOnCapture(roundOver)
    self.roundOverOnCapture = roundOver
end

function ENT:GetClosePlayers(position, listOfPlayers)
    local total, alive = 0, 0

    for key, ply in ipairs(listOfPlayers) do
        if ply:Alive() then
            alive = alive + 1
            if self:IsWithinCaptureAABB(ply:GetPos()) then
                total = total + 1
            end
        end
    end
    return total, alive
end

function ENT:InitTickets(startAmount)
    self:SetRedTicketCount(startAmount)
    self:SetBlueTicketCount(startAmount)
    self:SetMaxTickets(startAmount)
    self:SetupWaveTime()
end

function ENT:SetCaptureAABB(vec1, vec2)
    local vecMin = Vector(math.min(vec1.x, vec2.x), math.min(vec1.y, vec2.y), math.min(vec1.z, vec2.z))
    local vecMax = Vector(math.max(vec1.x, vec2.x), math.max(vec1.y, vec2.y), math.max(vec1.z, vec2.z))

    self:SetCaptureMin(vecMin)
    self:SetCaptureMax(vecMax)
end

function ENT:SetupWaveTime(timeModifier)
    timeModifier = timeModifier or 0

    self:SetWaveTimeLimit(CurTime() + GAMEMODE.curGametype.waveTimeLimit + timeModifier)
end

function ENT:Think()
    if GAMEMODE.RoundOver then
        return
    end

    local curTime = CurTime()

    if curTime < self.noCaptureTime then
        self.lastUpdate = curTime
        return
    end

    local ownPos = self:GetPos()

    local red, blue = team.GetPlayers(TEAM_RED), team.GetPlayers(TEAM_BLUE)
    local redPlayers, redAlive = self:GetClosePlayers(ownPos, red)
    local bluePlayers, blueAlive = self:GetClosePlayers(ownPos, blue)
    local capturer, capturerPlayers, capturerAlive = nil, nil, nil
    local loserPlayers = nil

    -- if there are equal forces on both teams, then the enemy team will begin capture
    if redPlayers > bluePlayers then
        capturer = TEAM_RED
        capturerPlayers = redPlayers
        capturerAlive = redAlive
        loserPlayers = bluePlayers
    elseif bluePlayers > redPlayers then
        capturer = TEAM_BLUE
        capturerPlayers = bluePlayers
        capturerAlive = blueAlive
        loserPlayers = redPlayers
    end

    if curTime > self:GetWaveTimeLimit() then
        if self:GetCaptureProgress() != 0 then
            if self.capturerTeam != 0 then
                -- make the capturers win, and make them not lose any tickets if no enemies are present on the point
                self:EndWave(self:GetCapturerTeam(), loserPlayers == 0)
            end
        else
            self:EndWave(nil, false)
        end
    end

    if capturer then
        self:SetCaptureSpeed(self:CalcCaptureSpeed(math.min(capturerPlayers - loserPlayers, self.MAX_CAPTURERS)))
        self:AdvanceCapture(self:GetCaptureSpeed(), capturer)
    else
        if curTime > self.deCaptureDelay then
            self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 0, 1))
            self.deCaptureDelay = curTime + self.CAPTURE_TICK

            if self:GetCaptureProgress() == 0 then
                self:SetCapturerTeam(0)
            end
        end
    end

    self.lastUpdate = curTime
end

function ENT:AdvanceCapture(capSpeed, capturerTeam)
    local delta = CurTime() - self.lastUpdate

    -- de-throne the previous capturer team in case they were capping it
    if capturerTeam != self:GetCapturerTeam() and self:GetCaptureProgress() != 0 then
        self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), 0, capSpeed * delta))

        if self:GetCaptureProgress() == 0 then
            -- swap capturing team once progress resets
            self:SetCapturerTeam(capturerTeam)
        end
    else
        -- self:SetCaptureSpeed(capSpeed / self.captureAmount)
        self:SetCaptureProgress(math.Approach(self:GetCaptureProgress(), self.CAPTURE_TIME, capSpeed * delta))

        if self.roundOverOnCapture and self:GetCaptureProgress() >= self.CAPTURE_TIME then
            self:EndWave(self:GetCapturerTeam(), true)

            for key, ply in ipairs(team.GetPlayers(self.capturerTeam)) do
                ply:AddCurrency("OBJECTIVE_CAPTURED")
            end

            return
        end
    end
    self.deCaptureDelay = CurTime() + self.deCaptureTimeOnCapture
end

function ENT:EndWave(capturerTeam, noTicketDrainForWinner)
    -- disable capturing for 10 secs
    self.noCaptureTime = CurTime() + self.noCaptureDuration
    self:SetCooldown(self.noCaptureTime)
    self:SetCaptureProgress(0)
    self:SetupWaveTime(-15)
    GAMEMODE.curGametype:EndWave(capturerTeam, noTicketDrainForWinner)
end

function ENT:drainTicket(teamID)
    if teamID == TEAM_RED then
        self:SetRedTicketCount(math.Approach(self:GetRedTicketCount(), 0, 1))
    else
        self:SetBlueTicketCount(math.Approach(self:GetBlueTicketCount(), 0, 1))
    end
end

function ENT:Use(activator, caller)
    return false
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end