ENT.Base             = "base_anim"
ENT.Type             = "anim"
ENT.Spawnable         = false
ENT.AdminSpawnable     = false

ENT.timeToPenalize = 10

ENT.Base = "gc_offlimits_area"

function ENT:SetupDataTables()
    -- whether the entity should function in reverse (too far = get back here)
    self:NetworkVar("Bool", 0, "InverseFunctioning")
    self:NetworkVar("Int", 0, "TargetTeam")

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

    if self:GetTargetTeam() != 0 and self:GetTargetTeam() != ply:Team() then
        return false
    end

    if self:GetInverseFunctioning() then
        return !self:isWithinCaptureAABB(ply:GetPos())
    end

    return self:isWithinCaptureAABB(ply:GetPos())
end