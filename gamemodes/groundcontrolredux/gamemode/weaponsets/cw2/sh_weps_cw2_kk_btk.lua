AddCSLuaFile()

function GM:RegisterWepsCW2KKBTK()
    local akm = {
        weaponClass = "cw_kk_ins2_nam_akm",
        weight = 3.5,
        pointCost = 24,
    }
    self:RegisterPrimaryWeapon(akm)

    local python = {
        weaponClass = "cw_kk_ins2_nam_python",
        weight = 1.2,
        pointCost = 7,
    }
    self:RegisterSecondaryWeapon(python)

    local ithaca = {
        weaponClass = "cw_kk_ins2_nam_ithaca",
        weight = 3.6,
        pointCost = 14
    }
    self:RegisterPrimaryWeapon(ithaca)

    local dbs = {
        weaponClass = "cw_kk_ins2_nam_dbs",
        weight = 3.2,
        pointCost = 11,
    }
    self:RegisterPrimaryWeapon(dbs)

    local m14 = {
        weaponClass = "cw_kk_ins2_nam_m14",
        weight = 4.1,
        pointCost = 32
    }
    self:RegisterPrimaryWeapon(m14)

    local m16a1 = {
        weaponClass = "cw_kk_ins2_nam_m16a1",
        weight = 2.89,
        pointCost = 25,
    }
    self:RegisterPrimaryWeapon(m16a1)

    local m4 = {
        weaponClass = "cw_kk_ins2_nam_m4",
        weight = 2.43,
        pointCost = 24,
        penMod = 0.85
    }
    self:RegisterPrimaryWeapon(m4)

    local mac10 = {
        weaponClass = "cw_kk_ins2_nam_mac10",
        weight = 2.84,
        pointCost = 13,
    }
    self:RegisterPrimaryWeapon(mac10)

    local mat49 = {
        weaponClass = "cw_kk_ins2_nam_mat49",
        weight = 3.5,
        pointCost = 14,
    }
    self:RegisterPrimaryWeapon(mat49)

    local ppsh = {
        weaponClass = "cw_kk_ins2_nam_ppsh",
        weight = 3.63,
        pointCost = 15,
    }
    self:RegisterPrimaryWeapon(ppsh)

    local sks = {
        weaponClass = "cw_kk_ins2_nam_sks",
        weight = 3.85,
        pointCost = 20
    }
    self:RegisterPrimaryWeapon(sks)

    local s620 = {
        weaponClass = "cw_kk_ins2_nam_s620",
        weight = 3.6,
        pointCost = 14
    }
    self:RegisterPrimaryWeapon(s620)

    local svd = {
        weaponClass = "cw_kk_ins2_nam_svd",
        weight = 4,
        pointCost = 36,
        penMod = 1.25
    }
    self:RegisterPrimaryWeapon(svd)

    local svt40 = {
        weaponClass = "cw_kk_ins2_nam_svt40",
        weight = 3.9,
        pointCost = 30
    }
    self:RegisterPrimaryWeapon(svt40)

    local sw39 = {
        weaponClass = "cw_kk_ins2_nam_sw39",
        weight = 0.9,
        pointCost = 7,
    }
    self:RegisterSecondaryWeapon(sw39)

    local tt33 = {
        weaponClass = "cw_kk_ins2_nam_tt33",
        weight = 0.85,
        pointCost = 8
    }
    self:RegisterSecondaryWeapon(tt33)

    local vz58 = {
        weaponClass = "cw_kk_ins2_nam_vz58",
        weight = 2.91,
        pointCost = 24,
    }
    self:RegisterPrimaryWeapon(vz58)

    local vz61 = {
        weaponClass = "cw_kk_ins2_nam_vz61",
        weight = 1.3,
        pointCost = 9
    }
    self:RegisterSecondaryWeapon(vz61)
end
