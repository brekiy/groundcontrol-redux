AddCSLuaFile()

-- Weapons that are uploaded individually
function GM:registerWepsTFAIns2()
    local uspm = {
        weaponClass = "tfa_ins2_usp_match",
        weight = 3.7,
        pointCost = 7
    }
    self:RegisterSecondaryWeapon(uspm)


end

