ENT.Base             = "base_anim"
ENT.Type             = "anim"
ENT.Spawnable         = false
ENT.AdminSpawnable     = false
-- How long the point needs to be capped for
ENT.CAPTURE_TIME = 30

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "CapturerTeam")
    self:NetworkVar("Int", 1, "DefenderTeam")
    self:NetworkVar("Int", 2, "PointID")
    self:NetworkVar("Int", 3, "CaptureDistance")

    self:NetworkVar("Float", 0, "CaptureProgress")
    self:NetworkVar("Float", 1, "CaptureSpeed")
end
