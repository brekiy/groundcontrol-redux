AddCSLuaFile()

-- HUGE pack made by soap on kk's improved cw2 base, quality is however inconsistent
function GM:RegisterWepsCW2Soap()

    -- bro why doesnt this have burst mode? wack
    local abakan = {
        weaponClass = "cw_kk_ins2_abakan",
        weight = 3.85,
        pointCost = 23,
    }
    self:RegisterPrimaryWeapon(abakan)

    local acr556 = {
        weaponClass = "cw_kk_ins2_acr556",
        weight = 3.6,
        pointCost = 23,
    }
    self:RegisterPrimaryWeapon(acr556)

    local aek971 = {
        weaponClass = "cw_kk_ins2_aek971",
        weight = 3.3,
        pointCost = 24,
    }
    self:RegisterPrimaryWeapon(aek971)

    local ak5d = {
        weaponClass = "cw_kk_ins2_ak5d",
        weight = 3.9,
        pointCost = 22,
    }
    self:RegisterPrimaryWeapon(ak5d)

    local ak74z = {
        weaponClass = "cw_kk_ins2_ak74z",
        weight = 4,
        pointCost = 23,
        penMod = 1.15
    }
    self:RegisterPrimaryWeapon(ak74z)

    local akalfa = {
        weaponClass = "cw_kk_ins2_akalfa",
        weight = 5.2,
        pointCost = 25,
        penMod = 1.15
    }
    self:RegisterPrimaryWeapon(akalfa)

    local akmconc = {
        weaponClass = "cw_kk_ins2_akmconc",
        weight = 3.1,
        pointCost = 23,
    }
    self:RegisterPrimaryWeapon(akmconc)

    local ak742 = {
        weaponClass = "cw_kk_ins2_ak742",
        weight = 3,
        pointCost = 21,
        penMod = 1.05
    }
    self:RegisterPrimaryWeapon(ak742)

    local aks74uz = {
        weaponClass = "cw_kk_ins2_aks74uz",
        weight = 3.3,
        pointCost = 24,
        penMod = 1.1
    }
    self:RegisterPrimaryWeapon(aks74uz)

    local asval = {
        weaponClass = "cw_kk_ins2_asval",
        weight = 2.6,
        pointCost = 28
    }
    self:RegisterPrimaryWeapon(asval)

    local aug = {
        weaponClass = "cw_kk_ins2_aug",
        weight = 3.3,
        pointCost = 25,
    }
    self:RegisterPrimaryWeapon(aug)

    local edge = {
        weaponClass = "cw_kk_ins2_edge",
        weight = 2.9,
        pointCost = 27,
        penMod = 1.1
    }
    self:RegisterPrimaryWeapon(edge)

    local cz805 = {
        weaponClass = "cw_kk_ins2_cz805",
        weight = 3.6,
        pointCost = 26,
    }
    self:RegisterPrimaryWeapon(cz805)

    local k2 = {
        weaponClass = "cw_kk_ins2_k2",
        weight = 3.26,
        pointCost = 27,
    }
    self:RegisterPrimaryWeapon(k2)

    local famasf1 = {
        weaponClass = "cw_kk_ins2_famasf1",
        weight = 3.61,
        pointCost = 27,
    }
    self:RegisterPrimaryWeapon(famasf1)

    local fnf2000 = {
        weaponClass = "cw_kk_ins2_fnf2000",
        weight = 3.3,
        pointCost = 26,
    }
    self:RegisterPrimaryWeapon(fnf2000)

    local g36 = {
        weaponClass = "cw_kk_ins2_g36",
        weight = 3,
        pointCost = 26,
    }
    self:RegisterPrimaryWeapon(g36)

    local lr300 = {
        weaponClass = "cw_kk_ins2_lr300",
        weight = 3.1,
        pointCost = 27,
    }
    self:RegisterPrimaryWeapon(lr300)

    -- has some really weird vm bug with the foregrip attached in ads
    -- local mk18mod1 = {
    --     weaponClass = "cw_kk_ins2_mk18mod1",
    --     weight = ,
    --     pointCost = ,
    -- }
    -- self:RegisterPrimaryWeapon(mk18mod1)

    local qbz03 = {
        weaponClass = "cw_kk_ins2_qbz03",
        weight = 3.5,
        pointCost = 26,
    }
    self:RegisterPrimaryWeapon(qbz03)

    local sa58 = {
        weaponClass = "cw_kk_ins2_sa58",
        weight = 3.9,
        pointCost = 32,
    }
    self:RegisterPrimaryWeapon(sa58)

    local scarl = {
        weaponClass = "cw_kk_ins2_scarl",
        weight = 3.29,
        pointCost = 24,
    }
    self:RegisterPrimaryWeapon(scarl)

    local sg551 = {
        weaponClass = "cw_kk_ins2_sg551",
        weight = 3.4,
        pointCost = 27,
    }
    self:RegisterPrimaryWeapon(sg551)

    local sg552 = {
        weaponClass = "cw_kk_ins2_sg552",
        weight = 3.2,
        pointCost = 26,
    }
    self:RegisterPrimaryWeapon(sg552)

    local vz58 = {
        weaponClass = "cw_kk_ins2_vz58",
        weight = 2.91,
        pointCost = 24,
    }
    self:RegisterPrimaryWeapon(vz58)

    local xm8 = {
        weaponClass = "cw_kk_ins2_xm8",
        weight = 3.4,
        pointCost = 27,
    }
    self:RegisterPrimaryWeapon(xm8)

    local stonerlmg = {
        weaponClass = "cw_kk_ins2_stonerlmg",
        weight = 5.5,
        maxMags = 2,
        pointCost = 32,
    }
    self:RegisterPrimaryWeapon(stonerlmg)

    local m240b = {
        weaponClass = "cw_kk_ins2_m240b",
        weight = 12.5,
        maxMags = 2,
        pointCost = 36,
    }
    self:RegisterPrimaryWeapon(m240b)

    local pkp = {
        weaponClass = "cw_kk_ins2_pkp",
        weight = 8.7,
        maxMags = 2,
        pointCost = 38,
    }
    self:RegisterPrimaryWeapon(pkp)

    local rpk12 = {
        weaponClass = "cw_kk_ins2_rpk12",
        weight = 4.6,
        pointCost = 29,
    }
    self:RegisterPrimaryWeapon(rpk12)

    local cs5 = {
        weaponClass = "cw_kk_ins2_cs5",
        weight = 6,
        pointCost = 28,
        penMod = 1.1
    }
    self:RegisterPrimaryWeapon(cs5)

    local awm = {
        weaponClass = "cw_kk_ins2_awm",
        weight = 6.5,
        pointCost = 38
    }
    self:RegisterPrimaryWeapon(awm)

    local ax308 = {
        weaponClass = "cw_kk_ins2_ax308",
        weight = 6.2,
        pointCost = 27,
        penMod = 1.1
    }
    self:RegisterPrimaryWeapon(ax308)

    local cdxmc = {
        weaponClass = "cw_kk_ins2_cdxmc",
        weight = 6.87,
        pointCost = 27,
        penMod = 1.15
    }
    self:RegisterPrimaryWeapon(cdxmc)

    local dsr1 = {
        weaponClass = "cw_kk_ins2_dsr1",
        weight = 5.9,
        pointCost = 42,
    }
    self:RegisterPrimaryWeapon(dsr1)

    local obrez = {
        weaponClass = "cw_kk_ins2_obrez",
        weight = 3.7,
        pointCost = 25,
        penMod = 0.9
    }
    self:RegisterPrimaryWeapon(obrez)

    local m14wood = {
        weaponClass = "cw_kk_ins2_m14wood",
        weight = 4.1,
        pointCost = 32,
    }
    self:RegisterPrimaryWeapon(m14wood)

    local m98 = {
        weaponClass = "cw_kk_ins2_m98",
        weight = 5.6,
        pointCost = 35,
        penMod = 1.3
    }
    self:RegisterPrimaryWeapon(m98)

    local t5000 = {
        weaponClass = "cw_kk_ins2_t5000",
        weight = 6.3,
        pointCost = 35,
        penMod = 1.3
    }
    self:RegisterPrimaryWeapon(t5000)

    local saiga762 = {
        weaponClass = "cw_kk_ins2_saiga762",
        weight = 3.2,
        pointCost = 21,
    }
    self:RegisterPrimaryWeapon(saiga762)

    local scarh = {
        weaponClass = "cw_kk_ins2_scarh",
        weight = 3.72,
        pointCost = 32
    }
    self:RegisterPrimaryWeapon(scarh)

    -- local sv98b = {
    --     weaponClass = "cw_kk_ins2_sv98b",
    --     weight = ,
    --     pointCost = ,
    -- }
    -- self:RegisterPrimaryWeapon(sv98b)

    local sv98g = {
        weaponClass = "cw_kk_ins2_sv98g",
        weight = 5.8,
        pointCost = 35,
        penMod = 1.25
    }
    self:RegisterPrimaryWeapon(sv98g)

    local svd = {
        weaponClass = "cw_kk_ins2_svd",
        weight = 4,
        pointCost = 36,
        penMod = 1.25
    }
    self:RegisterPrimaryWeapon(svd)

    local svu = {
        weaponClass = "cw_kk_ins2_svu",
        weight = 4.4,
        pointCost = 37,
        penMod = 1.25
    }
    self:RegisterPrimaryWeapon(svu)

    local vss = {
        weaponClass = "cw_kk_ins2_vss",
        weight = 2.6,
        pointCost = 27
    }
    self:RegisterPrimaryWeapon(vss)

    local scorpion = {
        weaponClass = "cw_kk_ins2_scorpion",
        weight = 2.39,
        pointCost = 17,
        penMod = 1.5
    }
    self:RegisterPrimaryWeapon(scorpion)

    local mp5a4 = {
        weaponClass = "cw_kk_ins2_mp5a4",
        weight = 2.5,
        pointCost = 15,
        penMod = 1.5
    }
    self:RegisterPrimaryWeapon(mp5a4)

    local mp7 = {
        weaponClass = "cw_kk_ins2_mp7",
        weight = 1.9,
        pointCost = 19,
    }
    self:RegisterPrimaryWeapon(mp7)

    local uzi = {
        weaponClass = "cw_kk_ins2_uzi",
        weight = 3.5,
        pointCost = 13,
    }
    self:RegisterPrimaryWeapon(uzi)

    local vector = {
        weaponClass = "cw_kk_ins2_vector",
        weight = 2.7,
        pointCost = 15,
        penMod = 1.5
    }
    self:RegisterPrimaryWeapon(vector)

    -- weird shader error
    -- local m4spec = {
    --     weaponClass = "cw_kk_ins2_m4spec",
    --     weight = ,
    --     pointCost = ,
    -- }
    -- self:RegisterPrimaryWeapon(m4spec)

    local mac10 = {
        weaponClass = "cw_kk_ins2_mac10",
        weight = 2.84,
        pointCost = 13,
    }
    self:RegisterPrimaryWeapon(mac10)

    local p90 = {
        weaponClass = "cw_kk_ins2_p90",
        weight = 2.6,
        pointCost = 18
    }
    self:RegisterPrimaryWeapon(p90)

    local mpx = {
        weaponClass = "cw_kk_ins2_mpx",
        weight = 2.7,
        pointCost = 16,
    }
    self:RegisterPrimaryWeapon(mpx)

    local veresk = {
        weaponClass = "cw_kk_ins2_veresk",
        weight = 1.65,
        pointCost = 18,
        penMod = 1.2
    }
    self:RegisterPrimaryWeapon(veresk)

    local vityaz = {
        weaponClass = "cw_kk_ins2_vityaz",
        weight = 2.9,
        pointCost = 16,
        penMod = 1.2
    }
    self:RegisterPrimaryWeapon(vityaz)

    local aa12 = {
        weaponClass = "cw_kk_ins2_aa12",
        weight = 5.2,
        pointCost = 18,
    }
    self:RegisterPrimaryWeapon(aa12)

    local br99 = {
        weaponClass = "cw_kk_ins2_br99",
        weight = 3.62,
        pointCost = 17,
    }
    self:RegisterPrimaryWeapon(br99)

    local ithaca37 = {
        weaponClass = "cw_kk_ins2_ithaca37",
        weight = 3.6,
        pointCost = 14
    }
    self:RegisterPrimaryWeapon(ithaca37)

    local toz66 = {
        weaponClass = "cw_kk_ins2_toz66",
        weight = 3.2,
        pointCost = 11,
    }
    self:RegisterPrimaryWeapon(toz66)

    local sawed = {
        weaponClass = "cw_kk_ins2_toz66_sawed",
        weight = 2,
        pointCost = 10,
    }
    self:RegisterPrimaryWeapon(sawed)

    local ks23 = {
        weaponClass = "cw_kk_ins2_ks23",
        weight = 3.85,
        pointCost = 15,
    }
    self:RegisterPrimaryWeapon(ks23)

    local m1014 = {
        weaponClass = "cw_kk_ins2_m1014",
        weight = 3.82,
        pointCost = 15,
    }
    self:RegisterPrimaryWeapon(m1014)

    local chaser13 = {
        weaponClass = "cw_kk_ins2_chaser13",
        weight = 2.5,
        pointCost = 13,
    }
    self:RegisterPrimaryWeapon(chaser13)

    local mts255 = {
        weaponClass = "cw_kk_ins2_mts255",
        weight = 3.7,
        pointCost = 15,
    }
    self:RegisterPrimaryWeapon(mts255)

    local saiga12 = {
        weaponClass = "cw_kk_ins2_saiga12",
        weight = 3.6,
        pointCost = 15,
    }
    self:RegisterPrimaryWeapon(saiga12)

    local saigaspike = {
        weaponClass = "cw_kk_ins2_saigaspike",
        weight = 3.4,
        pointCost = 16,
        penMod = 2
    }
    self:RegisterPrimaryWeapon(saigaspike)

    local sawedithaca37 = {
        weaponClass = "cw_kk_ins2_sawedithaca37",
        weight = 3,
        pointCost = 13,
    }
    self:RegisterPrimaryWeapon(sawedithaca37)

    local spas12 = {
        weaponClass = "cw_kk_ins2_spas12",
        weight = 4.4,
        pointCost = 15,
    }
    self:RegisterPrimaryWeapon(spas12)

    local typhoon12 = {
        weaponClass = "cw_kk_ins2_typhoon12",
        weight = 3.8,
        pointCost = 16,
    }
    self:RegisterPrimaryWeapon(typhoon12)

    local browninghp = {
        weaponClass = "cw_kk_ins2_browninghp",
        weight = 1,
        pointCost = 6,
    }
    self:RegisterSecondaryWeapon(browninghp)

    local python = {
        weaponClass = "cw_kk_ins2_python",
        weight = 1.2,
        pointCost = 7,
    }
    self:RegisterSecondaryWeapon(python)

    local cz75 = {
        weaponClass = "cw_kk_ins2_cz75",
        weight = 1.12,
        pointCost = 10,
    }
    self:RegisterSecondaryWeapon(cz75)

    local deagle = {
        weaponClass = "cw_kk_ins2_deagle",
        weight = 1.998,
        pointCost = 10
    }
    self:RegisterSecondaryWeapon(deagle)

    local fiveseven = {
        weaponClass = "cw_kk_ins2_fiveseven",
        weight = 0.61,
        pointCost = 9
    }
    self:RegisterSecondaryWeapon(fiveseven)

    local gsh18 = {
        weaponClass = "cw_kk_ins2_gsh18",
        weight = 0.590,
        pointCost = 8,
        penMod = 1.2
    }
    self:RegisterSecondaryWeapon(gsh18)

    local gyurza = {
        weaponClass = "cw_kk_ins2_gyurza",
        weight = 0.95,
        pointCost = 10,
        penMod = 1.1
    }
    self:RegisterSecondaryWeapon(gyurza)

    local mr96 = {
        weaponClass = "cw_kk_ins2_mr96",
        weight = 1.22,
        pointCost = 8
    }
    self:RegisterSecondaryWeapon(mr96)

    local grach = {
        weaponClass = "cw_kk_ins2_grach",
        weight = 0.950,
        pointCost = 8,
        penMod = 1.25,
    }
    self:RegisterSecondaryWeapon(grach)

    local sw500 = {
        weaponClass = "cw_kk_ins2_sw500",
        weight = 2.26,
        pointCost = 11,
    }
    self:RegisterSecondaryWeapon(sw500)

    local tokarev = {
        weaponClass = "cw_kk_ins2_tokarev",
        weight = 0.854,
        pointCost = 7
    }
    self:RegisterSecondaryWeapon(tokarev)

    local p99 = {
        weaponClass = "cw_kk_ins2_p99",
        weight = 0.63,
        pointCost = 6
    }
    self:RegisterSecondaryWeapon(p99)
end
