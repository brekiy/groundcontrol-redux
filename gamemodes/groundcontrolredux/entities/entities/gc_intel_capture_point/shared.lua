ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = "brekiy"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.CaptureDistance = 192

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "CapturerTeam")
    self:NetworkVar("Int", 1, "PointID")
    self:NetworkVar("Int", 2, "CaptureDistance")
end