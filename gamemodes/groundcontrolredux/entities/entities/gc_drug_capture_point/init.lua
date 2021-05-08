AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetNoDraw(true)
end

function ENT:Think()
    if GAMEMODE.RoundOver then
        return
    end

    for key, obj in ipairs(ents.FindInSphere(self:GetPos(), self.CaptureDistance)) do
        if obj:IsPlayer() and obj:Alive() and GAMEMODE.curGametype:AttemptCaptureDrugs(obj, self) then
            GAMEMODE:EndRound(obj:Team())
        end
    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end