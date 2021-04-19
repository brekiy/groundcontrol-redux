ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = "brekiy"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/props_lab/harddrive01.mdl"
ENT.NextBeepTime = 0

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Dropped")
end

function ENT:Think()
    if self:GetDropped() and self.NextBeepTime < CurTime() then
        if SERVER then
            self:EmitSound("buttons/blip1.wav", 75, 100)
        end

        local nextTime = 5
        self.NextBeepTime = CurTime() + nextTime
    end
end
