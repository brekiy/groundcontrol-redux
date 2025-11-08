AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/error.mdl")
    self:SetNoDraw(true)
    self:SetDistance(self.distance)
end


function ENT:Think()
    if GAMEMODE.RoundOver then
        return
    end

    local curTime = CurTime()
    local ownPos = self:GetPos()
    local targets = nil

    if self:GetTargetTeam() == 0 then
        targets = select(2, player.Iterator())
    else
        targets = team.GetPlayers(self:GetTargetTeam())
    end

    for _, ply in ipairs(targets) do
        if self:canPenalizePlayer(ply, ownPos) then
            if !ply.penalizeTime then
                ply.penalizeTime = curTime + self.timeToPenalize
            else
                if curTime >= ply.penalizeTime then
                    ply:Kill()
                end
            end
        else
            ply.penalizeTime = nil
        end
    end
end

function ENT:Use(activator, caller)
    return false
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end