AddCSLuaFile()

function GM:RegisterWepsCW2KKDOI()
    local bren = {
        weaponClass = "cw_kk_ins2_doi_bren",
        weight = 10.35,
        pointCost = 32,
    }
    self:RegisterPrimaryWeapon(bren)

    local browninghp = {
        weaponClass = "cw_kk_ins2_doi_browninghp",
        weight = 1,
        pointCost = 6,
    }
    self:RegisterSecondaryWeapon(browninghp)

    local fg42 = {
        weaponClass = "cw_kk_ins2_doi_fg42",
        weight = 4.2,
        pointCost = 32,
    }
    self:RegisterPrimaryWeapon(fg42)

    local g43 = {
        weaponClass = "cw_kk_ins2_doi_g43",
        weight = 4.4,
        pointCost = 28,
    }
    self:RegisterPrimaryWeapon(g43)

    local ithaca = {
        weaponClass = "cw_kk_ins2_doi_ithaca",
        weight = 3.6,
        pointCost = 14
    }
    self:RegisterPrimaryWeapon(ithaca)

    local k98k = {
        weaponClass = "cw_kk_ins2_doi_k98k",
        weight = 3.9,
        pointCost = 22,
    }
    self:RegisterPrimaryWeapon(k98k)

    local lewis = {
        weaponClass = "cw_kk_ins2_doi_lewis",
        weight = 13,
        pointCost = 34,
    }
    self:RegisterPrimaryWeapon(lewis)

    local enfield = {
        weaponClass = "cw_kk_ins2_doi_enfield",
        weight = 4.19,
        pointCost = 24,
    }
    self:RegisterPrimaryWeapon(enfield)

    local luger = {
        weaponClass = "cw_kk_ins2_doi_luger",
        weight = 0.871,
        pointCost = 5,
    }
    self:RegisterSecondaryWeapon(luger)

    local m1 = {
        weaponClass = "cw_kk_ins2_doi_m1",
        weight = 2.4,
        pointCost = 17,
    }
    self:RegisterPrimaryWeapon(m1)

    local m1a1_car = {
        weaponClass = "cw_kk_ins2_doi_m1a1",
        weight = 2,
        pointCost = 18,
    }
    self:RegisterPrimaryWeapon(m1a1_car)

    local garand = {
        weaponClass = "cw_kk_ins2_doi_garand",
        weight = 4.8,
        pointCost = 28,
    }
    self:RegisterPrimaryWeapon(garand)

    local spring = {
        weaponClass = "cw_kk_ins2_doi_spring",
        weight = 3.9,
        pointCost = 22,
    }
    self:RegisterPrimaryWeapon(spring)

    local m1911 = {
        weaponClass = "cw_kk_ins2_doi_m1911",
        weight = 1.105,
        pointCost = 4,
    }
    self:RegisterSecondaryWeapon(m1911)

    local m1912 = {
        weaponClass = "cw_kk_ins2_doi_m1912",
        weight = 3.7,
        pointCost = 14,
    }
    self:RegisterPrimaryWeapon(m1912)

    local bar = {
        weaponClass = "cw_kk_ins2_doi_bar",
        weight = 8.8,
        pointCost = 32,
    }
    self:RegisterPrimaryWeapon(bar)

    local browning = {
        weaponClass = "cw_kk_ins2_doi_browning",
        weight = 14,
        pointCost = 38,
        maxMags = 2
    }
    self:RegisterPrimaryWeapon(browning)

    local tommy1928 = {
        weaponClass = "cw_kk_ins2_doi_thom_1928",
        weight = 4.9,
        pointCost = 14,
    }
    self:RegisterPrimaryWeapon(tommy1928)

    local m1a1_tommy = {
        weaponClass = "cw_kk_ins2_doi_thom_m1a1",
        weight = 4.5,
        pointCost = 14,
    }
    self:RegisterPrimaryWeapon(m1a1_tommy)

    local m3 = {
        weaponClass = "cw_kk_ins2_doi_m3",
        weight = 3.7,
        pointCost = 11,
    }
    self:RegisterPrimaryWeapon(m3)

    local c96_c = {
        weaponClass = "cw_kk_ins2_doi_c96_c",
        weight = 2.3,
        pointCost = 12,
    }
    self:RegisterPrimaryWeapon(c96_c)

    local c96 = {
        weaponClass = "cw_kk_ins2_doi_c96",
        weight = 1.13,
        pointCost = 6,
    }
    self:RegisterSecondaryWeapon(c96)

    local mg34 = {
        weaponClass = "cw_kk_ins2_doi_mg34",
        weight = 12.1,
        pointCost = 37,
    }
    self:RegisterPrimaryWeapon(mg34)

    local mg42 = {
        weaponClass = "cw_kk_ins2_doi_mg42",
        weight = 11.6,
        pointCost = 42,
    }
    self:RegisterPrimaryWeapon(mg42)

    local mp40 = {
        weaponClass = "cw_kk_ins2_doi_mp40",
        weight = 4,
        pointCost = 11,
    }
    self:RegisterPrimaryWeapon(mp40)

    local mk1 = {
        weaponClass = "cw_kk_ins2_doi_owen_mk1",
        weight = 4.23,
        pointCost = 12,
    }
    self:RegisterPrimaryWeapon(mk1)

    local mk2 = {
        weaponClass = "cw_kk_ins2_doi_sten_mk2",
        weight = 3.2,
        pointCost = 12,
    }
    self:RegisterPrimaryWeapon(mk2)

    local mk5 = {
        weaponClass = "cw_kk_ins2_doi_sten_mk5",
        weight = 3.5,
        pointCost = 13,
    }
    self:RegisterPrimaryWeapon(mk5)

    local stg44 = {
        weaponClass = "cw_kk_ins2_doi_stg44",
        weight = 4.6,
        pointCost = 23,
    }
    self:RegisterPrimaryWeapon(stg44)

    local m1917 = {
        weaponClass = "cw_kk_ins2_doi_m1917",
        weight = 1,
        pointCost = 3,
    }
    self:RegisterSecondaryWeapon(m1917)

    local p38 = {
        weaponClass = "cw_kk_ins2_doi_p38",
        weight = 0.8,
        pointCost = 5,
    }
    self:RegisterSecondaryWeapon(p38)

    local ppk = {
        weaponClass = "cw_kk_ins2_doi_ppk",
        weight = 0.59,
        pointCost = 3,
    }
    self:RegisterSecondaryWeapon(ppk)

    local webley = {
        weaponClass = "cw_kk_ins2_doi_webley",
        weight = 0.95,
        pointCost = 2,
    }
    self:RegisterSecondaryWeapon(webley)

    local welrod = {
        weaponClass = "cw_kk_ins2_doi_welrod",
        weight = 1,
        pointCost = 1,
    }
    self:RegisterSecondaryWeapon(welrod)
end
