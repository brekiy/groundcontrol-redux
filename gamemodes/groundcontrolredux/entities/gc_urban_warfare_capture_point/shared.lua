ENT.Base             = "base_anim"
ENT.Type             = "anim"
ENT.Spawnable         = false
ENT.AdminSpawnable     = false

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "CaptureProgress")
    self:NetworkVar("Float", 1, "WaveTimeLimit")
    self:NetworkVar("Int", 1, "CapturerTeam")
    self:NetworkVar("Int", 2, "PointID")
    self:NetworkVar("Int", 3, "CaptureDistance")

    self:NetworkVar("Int", 4, "RedTicketCount")
    self:NetworkVar("Int", 5, "BlueTicketCount")

    self:NetworkVar("Float", 2, "CaptureSpeed")
    self:NetworkVar("Float", 3, "Cooldown")

    self:NetworkVar("Vector", 0, "CaptureMin")
    self:NetworkVar("Vector", 1, "CaptureMax")
    self:NetworkVar("Int", 0, "MaxTickets")
end

function ENT:isWithinCaptureAABB(pos)
    local min, max = self:GetCaptureMin(), self:GetCaptureMax()
    pos.z = pos.z + 32
    if pos.x > min.x and pos.y > min.y and pos.z > min.z and pos.x < max.x and pos.y < max.y and pos.z < max.z then
        return true
    end

    return false
end

function ENT:getTeamTickets(teamID)
    if teamID == TEAM_RED then
        return self:GetRedTicketCount()
    else
        return self:GetBlueTicketCount()
    end
end