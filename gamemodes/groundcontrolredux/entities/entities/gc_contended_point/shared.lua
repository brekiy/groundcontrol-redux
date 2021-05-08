ENT.Base             = "base_anim"
ENT.Type             = "anim"
ENT.Spawnable         = false
ENT.AdminSpawnable     = false
-- How long the point needs to be capped for
ENT.CAPTURE_TIME = 30

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "CaptureProgress")
    self:NetworkVar("Float", 1, "CaptureSpeed")
    self:NetworkVar("Int", 1, "CurCaptureTeam")
end