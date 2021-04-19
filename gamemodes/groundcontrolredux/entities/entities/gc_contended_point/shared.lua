ENT.Base             = "base_anim"
ENT.Type             = "anim"
ENT.Spawnable         = false
ENT.AdminSpawnable     = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "CaptureProgress")
    self:NetworkVar("Int", 1, "CurCaptureTeam")
end