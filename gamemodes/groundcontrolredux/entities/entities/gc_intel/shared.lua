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
            sound.Play(beep, self:GetPos(), amp, 100)
        end

        local nextTime = (etime - CurTime()) / 30
        self.NextBeepTime = CurTime() + nextTime
    end
end