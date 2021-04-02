include("shared.lua")

function ENT:Initialize()
    self.Emitter = ParticleEmitter(self:GetPos())
    self.ParticleDelay = 0
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:OnRemove()
    local dlight = DynamicLight(self:EntIndex())

    dlight.r = 255
    dlight.g = 255
    dlight.b = 255
    dlight.Brightness = 4
    dlight.Pos = self:GetPos()
    dlight.Size = 256
    dlight.Decay = 128
    dlight.DieTime = CurTime() + 0.1
end