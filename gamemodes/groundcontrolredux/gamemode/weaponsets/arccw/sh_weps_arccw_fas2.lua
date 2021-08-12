AddCSLuaFile()

-- WIP
function GM:RegisterWepsARCCWFAS2()
    local ak47 = { weaponClass = "arccw_mifl_fas2_ak47", weight = 8.7, pointCost = 38 }
    self:RegisterPrimaryWeapon(ak47)

    local mass26 = {
        weaponClass = "arccw_fml_fas2_custom_mass26",
        weight = 0.92,
        pointCost = 10
    }
    self:RegisterSecondaryWeapon(mass26)
end

