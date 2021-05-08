AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/harddrive01.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    -- for some reason, use() wasn't working with solid_none
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:SetDropped(true)
    self:SetUseType(SIMPLE_USE)
    self:DrawShadow(false)
    if SERVER then
        self:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES))
    end
end

function ENT:wakePhysics()
    self:SetMoveType(MOVETYPE_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys and phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if GAMEMODE.RoundOver then
        return
    end

    local gametype = GAMEMODE.curGametype
    if gametype:PickupIntel(self, activator) then
        if self.host then
            self.host:SetHasIntel(false)
        end
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        self:SetDropped(false)
        self:SetModelScale(0.1)
        -- local bone = activator:LookupBone("ValveBiped.Bip01_Spine2")
        -- if bone then
        --     local pos, ang = activator:GetBonePosition(bone)
        --     pos = pos - ang:Up() * Vector(0, 0, 10) + ang:Forward() * Vector(-7, -15, 0)
        --     self:SetPos(pos)
        --     self:SetAngles(ang)
        -- else
        --     local pos = activator:GetPos()
        --     pos.z = pos.z + 50
        --     self:SetPos(pos)
        -- end
        self:SetParent(activator)

    end
end

function ENT:SetHost(host)
    self.host = host
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:Drop()
    local ply = self:GetParent()
    self:SetParent(nil)
    self:SetUseType(SIMPLE_USE)
    local pos = self:GetPos()
    pos.z = pos.z + 20

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetDropped(true)
    self:SetModelScale(1)
    -- physics push
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        print("gc debug intel drop, valid phys object")
        phys:SetMass(10)

        if IsValid(ply) then
            phys:SetVelocityInstantaneous(ply:GetVelocity())
        end

        phys:ApplyForceCenter(Vector(0, 0, -100))
        phys:AddAngleVelocity(VectorRand() * 200)
        phys:Wake()
    end
end
