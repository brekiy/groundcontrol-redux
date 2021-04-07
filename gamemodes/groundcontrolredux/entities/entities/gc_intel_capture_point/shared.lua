ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = "brekiy"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.CaptureDistance = 192

function ENT:SetupDataTables()
    self:DTVar("Int", 0, "CapturerTeam")
    self:DTVar("Int", 1, "PointID")
    self:DTVar("Int", 2, "CaptureDistance")
end