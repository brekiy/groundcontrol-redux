ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = "brekiy"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/props_lab/harddrive01.mdl" -- what model to use
ENT.NextBeepTime = 0

function ENT:SetupDataTables()
    self:DTVar("Bool", 0, "Dropped")
end

-- TODO
function ENT:Think()
    if self.dt.Dropped and self.NextBeepTime < CurTime() then
        if SERVER then
            self:EmitSound("HL1/fvox/beep.wav", 110, 100)
        end

        local nextTime = 1.5
        self.NextBeepTime = CurTime() + nextTime
    end
end