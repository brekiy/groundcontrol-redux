AddCSLuaFile()

-- Weapons that are uploaded individually
function GM:RegisterWepsCW2KKEXT()
    local colt = {
        weaponClass = "cw_kk_ins2_cstm_colt",
        weight = 2.43,
        pointCost = 24,
        penMod = 0.85
    }
    self:RegisterPrimaryWeapon(colt)

    local famas = {
        weaponClass = "cw_kk_ins2_cstm_famas",
        weight = 3.61,
        pointCost = 27,
    }
    self:RegisterPrimaryWeapon(famas)

    local g19 = {
        weaponClass = "cw_kk_ins2_cstm_g19",
        weight = 0.6,
        pointCost = 7,
    }
    self:RegisterSecondaryWeapon(g19)

    local g36c = {
        weaponClass = "cw_kk_ins2_cstm_g36c",
        weight = 2.82,
        pointCost = 24,
    }
    self:RegisterPrimaryWeapon(g36c)

    local mp5a4 = {
        weaponClass = "cw_kk_ins2_cstm_mp5a4",
        weight = 2.5,
        pointCost = 15,
        penMod = 1.2
    }
    self:RegisterPrimaryWeapon(mp5a4)

    local mp7 = {
        weaponClass = "cw_kk_ins2_cstm_mp7",
        weight = 1.9,
        pointCost = 19,
    }
    self:RegisterPrimaryWeapon(mp7)

    local cobra = {
        weaponClass = "cw_kk_ins2_cstm_cobra",
        weight = 0.79,
        pointCost = 7,
    }
    self:RegisterSecondaryWeapon(cobra)

    local kriss = {
        weaponClass = "cw_kk_ins2_cstm_kriss",
        weight = 2.7,
        pointCost = 15,
        penMod = 1.5
    }
    self:RegisterPrimaryWeapon(kriss)

    local ksg = {
        weaponClass = "cw_kk_ins2_cstm_ksg",
        weight = 3.1,
        pointCost = 14
    }
    self:RegisterPrimaryWeapon(ksg)

    local m14 = {
        weaponClass = "cw_kk_ins2_cstm_m14",
        weight = 4.1,
        pointCost = 32
    }
    self:RegisterPrimaryWeapon(m14)

    local m500 = {
        weaponClass = "cw_kk_ins2_cstm_m500",
        weight = 2.5,
        pointCost = 13,
    }
    self:RegisterPrimaryWeapon(m500)

    local scar = {
        weaponClass = "cw_kk_ins2_cstm_scar",
        weight = 3.72,
        pointCost = 32
    }
    self:RegisterPrimaryWeapon(scar)

    local spas12 = {
        weaponClass = "cw_kk_ins2_cstm_spas12",
        weight = 4.4,
        pointCost = 14,
    }
    self:RegisterPrimaryWeapon(spas12)

    -- inexplicably worse audio quality than the doi one
    -- local sten = {
    --     weaponClass = "cw_kk_ins2_cstm_sten",
    --     weight = ,
    --     pointCost = ,
    -- }
    -- self:RegisterPrimaryWeapon(sten)

    local aug = {
        weaponClass = "cw_kk_ins2_cstm_aug",
        weight = 3.3,
        pointCost = 25,
    }
    self:RegisterPrimaryWeapon(aug)

    local uzi = {
        weaponClass = "cw_kk_ins2_cstm_uzi",
        weight = 3.5,
        pointCost = 13,
    }
    self:RegisterPrimaryWeapon(uzi)

    local l85 = {
        weaponClass = "cw_kk_ins2_cstm_l85",
        weight = 3.82,
        pointCost = 24
    }
    self:RegisterPrimaryWeapon(l85)
end
