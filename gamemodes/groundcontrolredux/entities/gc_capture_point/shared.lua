ENT.Base             = "base_anim"
ENT.Type             = "anim"
ENT.Spawnable         = false
ENT.AdminSpawnable     = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "CaptureProgress")
    self:NetworkVar("Int", 1, "CapturerTeam")
    self:NetworkVar("Int", 2, "PointID")
    self:NetworkVar("Int", 3, "CaptureDistance")

    self:NetworkVar("Float", 0, "CaptureSpeed")
end