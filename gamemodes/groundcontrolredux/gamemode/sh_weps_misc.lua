AddCSLuaFile()

-- Weapons that are uploaded individually
function GM:registerWepsMisc()
    local pkp = {
        weaponClass = "cw_pkp",
        weight = 7.5,
        maxMags = 2
    }
    self:registerPrimaryWeapon(pkp)

    local vz61 = {
        weaponClass = "cw_vz61_kry",
        weight = 1.3,
    }
    self:registerSecondaryWeapon(vz61)

    local g18 = {
        weaponClass = "cw_g18",
        weight = 0.92,
    }
    self:registerSecondaryWeapon(g18)
end

