ENT.Base             = "base_anim"
ENT.Type             = "anim"
ENT.Spawnable         = false
ENT.AdminSpawnable     = false

ENT.distance = 1024
ENT.timeToPenalize = 10

function ENT:SetupDataTables()
    -- whether the entity should function in reverse (too far = get back here)
    self:NetworkVar("Bool", 0, "InverseFunctioning")
    self:NetworkVar("Int", 0, "TargetTeam")
    self:NetworkVar("Int", 1, "Distance")
end

function ENT:IsInRange(target, ourPos)
    return target:GetPos():Distance(ourPos) <= self:GetDistance()
end

function ENT:CanPenalizePlayer(ply, ownPos)
    if GAMEMODE.RoundOver then
        return false
    end

    if !ply:Alive() then
        return false
    end

    if self:GetTargetTeam() != 0 and self:GetTargetTeam() != ply:Team() then
        return false
    end

    ownPos = ownPos or self:GetPos()

    if self:GetInverseFunctioning() then
        return !self:isInRange(ply, ownPos)
    end

    return self:IsInRange(ply, ownPos)
end
