ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = "brekiy"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/props_lab/harddrive01.mdl" -- what model to use

function ENT:SetupDataTables()
    self:DTVar("Bool", 0, "Dropped")
end