ENT.Base             = "base_anim"
ENT.Type             = "anim"
ENT.Spawnable         = false
ENT.AdminSpawnable     = false

ENT.timeToPenalize = 10

ENT.Base = "gc_offlimits_area"

function ENT:SetupDataTables()
    self:DTVar("Bool", 0, "inverseFunctioning") -- whether the entity should function in reverse (too far = get back here)
    self:DTVar("Int", 0, "targetTeam")

    self:NetworkVar("Vector", 0, "AABBMin")
    self:NetworkVar("Vector", 1, "AABBMax")
end

function ENT:setAABB(vec1, vec2)
    local vecMin = Vector(math.min(vec1.x, vec2.x), math.min(vec1.y, vec2.y), math.min(vec1.z, vec2.z))
    local vecMax = Vector(math.max(vec1.x, vec2.x), math.max(vec1.y, vec2.y), math.max(vec1.z, vec2.z))

    self:SetAABBMin(vecMin)
    self:SetAABBMax(vecMax)
end

function ENT:isWithinCaptureAABB(pos)
    local min, max = self:GetAABBMin(), self:GetAABBMax()
    pos.z = pos.z + 32

    if pos.x > min.x and pos.y > min.y and pos.z > min.z and pos.x < max.x and pos.y < max.y and pos.z < max.z then
        return true
    end

    return false
end

function ENT:canPenalizePlayer(ply, ownPos)
    if GAMEMODE.RoundOver then
        return false
    end

    if !ply:Alive() then
        return false
    end

    if self.dt.targetTeam != 0 and self.dt.targetTeam != ply:Team() then
        return false
    end

    if self.dt.inverseFunctioning then
        return !self:isWithinCaptureAABB(ply:GetPos())
    end

    return self:isWithinCaptureAABB(ply:GetPos())
end