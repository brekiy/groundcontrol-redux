AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.escapeDistance = 128

function ENT:Initialize()
    self:SetNoDraw(true)
    self:SetEscapeDistance(self.escapeDistance)
end

function ENT:Think()
    if GAMEMODE.RoundOver then
        return
    end

    for key, obj in ipairs(ents.FindInSphere(self:GetPos(), self:GetEscapeDistance())) do
        if obj:IsPlayer() and obj:Alive() and obj.isVIP then
            for key2, ply in ipairs(team.GetPlayers(obj:Team())) do
                -- reward team for getting the VIP out
                ply:AddCurrency("EXTRACT_VIP")
            end
            GAMEMODE:EndRound(obj:Team())
            return
        end
    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end
