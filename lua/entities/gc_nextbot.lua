if SERVER then AddCSLuaFile() end

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

-- Credits to wyozi-gmod's gamemode and nextbot base.
-- https://github.com/wyozi-gmod/budgetday/blob/master/entities/entities/bd_nextbotbase.lua
ENT.HitBoxToHitGroup = {
    [0] = HITGROUP_HEAD,
    [16] = HITGROUP_CHEST,
    [15] = HITGROUP_STOMACH,
    [5] = HITGROUP_RIGHTARM,
    [2] = HITGROUP_LEFTARM,
    [12] = HITGROUP_RIGHTLEG,
    [8] = HITGROUP_LEFTLEG
}

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/player/group01/male_01.mdl")
        self.SetHealth(100)
    end
end

function ENT:AimAt(pos)
    local angdiff = (pos - self:EyePosN()):Angle()

    self:LookAt(pos)

    local yaw = math.NormalizeAngle(angdiff.y - self:GetAngles().y)
    self:SetPoseParameter("aim_yaw", -yaw)

    local pitch = math.Clamp(-math.NormalizeAngle(angdiff.p), -50, 50)
    self:SetPoseParameter("aim_pitch", -pitch)
end