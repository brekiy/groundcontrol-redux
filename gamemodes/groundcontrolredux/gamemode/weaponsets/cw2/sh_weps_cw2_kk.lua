AddCSLuaFile()

-- Knife Kitty's INS2 pack
function GM:registerWepsCW2KK()
    local mini14 = {
        weaponClass = "cw_kk_ins2_mini14",
        weight = 2.9,
        pointCost = 24,
    }
    self:registerPrimaryWeapon(mini14)

    local ak74 = {
        weaponClass = "cw_kk_ins2_ak74",
        weight = 3.07,
        pointCost = 22,
    }
    self:registerPrimaryWeapon(ak74)

    local akm = {
        weaponClass = "cw_kk_ins2_akm",
        weight = 3.5,
        pointCost = 24,
    }
    self:registerPrimaryWeapon(akm)

    local aks74u = {
        weaponClass = "cw_kk_ins2_aks74u",
        weight = 2.7,
        pointCost = 24,
    }
    self:registerPrimaryWeapon(aks74u)

    local fnfal = {
        weaponClass = "cw_kk_ins2_fnfal",
        weight = 4.45,
        pointCost = 32
    }
    self:registerPrimaryWeapon(fnfal)

    local galil = {
        weaponClass = "cw_kk_ins2_galil",
        weight = 4.35,
        pointCost = 24,
    }
    self:registerPrimaryWeapon(galil)

    local mp40 = {
        weaponClass = "cw_kk_ins2_mp40",
        weight = 4,
        pointCost = 11,
    }
    self:registerPrimaryWeapon(mp40)

    local mp5k = {
        weaponClass = "cw_kk_ins2_mp5k",
        weight = 2,
        pointCost = 13,
    }
    self:registerPrimaryWeapon(mp5k)

    local ump45 = {
        weaponClass = "cw_kk_ins2_ump45",
        weight = 2.5,
        pointCost = 13,
        penMod = 1.5
    }
    self:registerPrimaryWeapon(ump45)

    local l1a1 = {
        weaponClass = "cw_kk_ins2_l1a1",
        weight = 4.337,
        pointCost = 27,
    }
    self:registerPrimaryWeapon(l1a1)

    local m1a1 = {
        weaponClass = "cw_kk_ins2_m1a1",
        weight = 2.6,
        pointCost = 18,
    }
    self:registerPrimaryWeapon(m1a1)

    local m14 = {
        weaponClass = "cw_kk_ins2_m14",
        weight = 5.1,
        pointCost = 32,
    }
    self:registerPrimaryWeapon(m14)

    local m16a4 = {
        weaponClass = "cw_kk_ins2_m16a4",
        weight = 6.37,
        pointCost = 26,
        penMod = 1.1
    }
    self:registerPrimaryWeapon(m16a4)

    local para = {
        weaponClass = "cw_kk_ins2_m1a1_para",
        weight = 2,
        pointCost = 19,
    }
    self:registerPrimaryWeapon(para)

    local m249 = {
        weaponClass = "cw_kk_ins2_m249",
        weight = 7.5,
        maxMags = 2,
        pointCost = 32,
    }
    self:registerPrimaryWeapon(m249)

    local m40a1 = {
        weaponClass = "cw_kk_ins2_m40a1",
        weight = 6.57,
        pointCost = 26,
        penMod = 1.2
    }
    self:registerPrimaryWeapon(m40a1)

    local m4a1 = {
        weaponClass = "cw_kk_ins2_m4a1",
        weight = 3.1,
        pointCost = 26,
    }
    self:registerPrimaryWeapon(m4a1)

    local m590 = {
        weaponClass = "cw_kk_ins2_m590",
        weight = 2.85,
        pointCost = 14,
    }
    self:registerPrimaryWeapon(m590)

    local mk18 = {
        weaponClass = "cw_kk_ins2_mk18",
        weight = 2.72,
        pointCost = 27,
        penMod = 1.05
    }
    self:registerPrimaryWeapon(mk18)

    local mosin = {
        weaponClass = "cw_kk_ins2_mosin",
        weight = 4,
        pointCost = 24,
        penMod = 1.15
    }
    self:registerPrimaryWeapon(mosin)

    local rpk = {
        weaponClass = "cw_kk_ins2_rpk",
        weight = 4.8,
        pointCost = 29,
    }
    self:registerPrimaryWeapon(rpk)

    local sks = {
        weaponClass = "cw_kk_ins2_sks",
        weight = 3.67,
        pointCost = 20,
    }
    self:registerPrimaryWeapon(sks)

    local sterling = {
        weaponClass = "cw_kk_ins2_sterling",
        weight = 2.7,
        pointCost = 12,
    }
    self:registerPrimaryWeapon(sterling)

    local toz = {
        weaponClass = "cw_kk_ins2_toz",
        weight = 2.9,
        pointCost = 14,
    }
    self:registerPrimaryWeapon(toz)

    local m9 = {
        weaponClass = "cw_kk_ins2_m9",
        weight = 0.970,
        pointCost = 7,
    }
    self:registerSecondaryWeapon(m9)

    local m45 = {
        weaponClass = "cw_kk_ins2_m45",
        weight = 1.105,
        pointCost = 4,
    }
    self:registerSecondaryWeapon(m45)

    local m1911 = {
        weaponClass = "cw_kk_ins2_m1911",
        weight = 1.105,
        pointCost = 4,
    }
    self:registerSecondaryWeapon(m1911)

    local makarov = {
        weaponClass = "cw_kk_ins2_makarov",
        weight = 0.73,
        pointCost = 4,
    }
    self:registerSecondaryWeapon(makarov)

    local revolver = {
        weaponClass = "cw_kk_ins2_revolver",
        weight = 0.963,
        pointCost = 2,
    }
    self:registerSecondaryWeapon(revolver)

    local p2a1 = {
        weaponClass = "cw_kk_ins2_p2a1",
        weight = 0.52,
        pointCost = 1,
    }
    self:registerSecondaryWeapon(p2a1)
end

