AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.FreezeRange = 64

local freezeEnts = {
    prop_physics = true,
    prop_physics_multiplayer = true
}

function ENT:Initialize()
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetNoDraw(true)
end

function ENT:AssignAsIntelTarget()
    self:SetHasIntel(true)
    self:CreateIntelObject()
end

function ENT:FreezeNearbyProps()
    for key, obj in ipairs(ents.FindInSphere(self:GetPos(), self.FreezeRange)) do
        if freezeEnts[obj:GetClass()] then
            obj:SetMoveType(MOVETYPE_NONE) -- freeze em
            obj:SetHealth(9999999) -- give nearby props a shitton of health (in case it's a wooden table or something)
        end
    end
end

function ENT:CreateIntelObject()
    local randAngle = AngleRand()

    local pos = self:GetPos()
    pos.z = pos.z + 6

    local ent = ents.Create("gc_intel")
    ent:SetPos(pos)
    ent:SetAngles(Angle(0, randAngle.y, randAngle.r))
    ent:Spawn()
    ent:SetHost(self)

    -- self:SetHasIntel(true)
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end