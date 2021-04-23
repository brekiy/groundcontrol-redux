AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.captureDistance = 128

function ENT:Initialize()
    self:SetNoDraw(true)
    self.captureTeam = nil
    self:SetCaptureDistance(self.captureDistance)
end

function ENT:SetCaptureDistance(distance)
    self.captureDistance = distance
    self:SetCaptureDistance(distance)
end

function ENT:SetCapturerTeam(team) -- the team that has to capture this point
    self.capturerTeam = team
    self:SetCapturerTeam(team)
end

function ENT:Think()
    if GAMEMODE.RoundOver then
        return
    end

    for key, obj in ipairs(ents.FindInSphere(self:GetPos(), self.captureDistance)) do
        if obj:IsPlayer() and obj:Alive() and GAMEMODE.curGametype:attemptCaptureIntel(obj, self) then
            GAMEMODE:EndRound(obj:Team())
        end
    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end