ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = "Spy"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "HasDrugs")
end