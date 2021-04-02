if SERVER then AddCSLuaFile() end

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

-- Credits to wyozi-gmod's gamemode and nextbot base.
-- https://github.com/wyozi-gmod/budgetday/blob/master/entities/entities/bd_nextbotbase.lua
-- https://github.com/lepotatur/tttbots
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
    self:SetModel("models/props_lab/huladoll.mdl")
    self:SetNoDraw(true)
    self:DrawShadow(false)
    self:SetSolid(SOLID_NONE)
    self.PosGen = nil
end

function ENT:SetEnemy(ent)
    self.Enemy = ent
end

function ENT:GetEnemy()
    return self.Enemy
end

function ENT:RunBehaviour()
    while (true) do
        if self.PosGen then
            self:ChasePos()
        end
        coroutine.yield()
    end
end

function ENT:ChasePos()
    if self.PosGen == nil then return end
    self.P = Path("Follow")
    self.P:SetMinLookAheadDistance(00)
    self.P:SetGoalTolerance(100)
    self.P:Compute(self, self.PosGen)
    if !self.P:IsValid() then return end

    if self.P:GetAge() > 0.2 then
        self.P:Compute(self, self.PosGen)
    end
    if GetConVar("gc_bot_nav_debug"):GetBool() then
        self.P:Draw()
    end
end
-- function ENT:AimAt(pos)
--     local angdiff = (pos - self:EyePosN()):Angle()

--     self:LookAt(pos)

--     local yaw = math.NormalizeAngle(angdiff.y - self:GetAngles().y)
--     self:SetPoseParameter("aim_yaw", -yaw)

--     local pitch = math.Clamp(-math.NormalizeAngle(angdiff.p), -50, 50)
--     self:SetPoseParameter("aim_pitch", -pitch)
-- end