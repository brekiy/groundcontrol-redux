AddCSLuaFile()

-- WIP
function GM:RegisterWepsARCCWFAS2()
    local pkp = {
        weaponClass = "cw_pkp",
        weight = 8.7,
        maxMags = 2,
        pointCost = 38
    }
    self:RegisterPrimaryWeapon(pkp)

    local vz61 = {
        weaponClass = "cw_vz61_kry",
        weight = 1.3,
        pointCost = 9
    }
    self:RegisterSecondaryWeapon(vz61)

    local g18 = {
        weaponClass = "cw_g18",
        weight = 0.92,
        pointCost = 10
    }
    self:RegisterSecondaryWeapon(g18)
end

