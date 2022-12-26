AddCSLuaFile()

function GM:RegisterWepsCW2Base()
    -- battle rifles
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_g3a3",
        weight = 4.1,
        pointCost = 32
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_scarh",
        weight = 3.72,
        pointCost = 32
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_m14",
        weight = 5.1,
        pointCost = 32
    })

    -- assault rifles
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_ak74",
        weight = 3.07,
        pointCost = 22
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_akm_official",
        weight = 3.5,
        pointCost = 24
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_ar15",
        weight = 3.01,
        pointCost = 26
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_g36c",
        weight = 2.82,
        pointCost = 24
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_l85a2",
        weight = 3.82,
        pointCost = 24
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_vss",
        weight = 2.6,
        pointCost = 23
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_famasg2_official",
        weight = 3.8,
        pointCost = 27
    })

    -- sub-machine guns/light carbines
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_mp5",
        weight = 2.5,
        pointCost = 15,
        penMod = 1.2
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_mac11",
        weight = 1.59,
        pointCost = 12
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_ump45",
        weight = 2.5,
        pointCost = 13,
        penMod = 1.5
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_mp9_official",
        weight = 1.4,
        pointCost = 16,
        penMod = 1.1
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_mp7_official",
        weight = 1.9,
        pointCost = 19,
    })

    -- heavy weapons
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_m249_official",
        weight = 7.5,
        maxMags = 2,
        pointCost = 32
    })

    -- shotguns
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_m3super90",
        weight = 3.27,
        pointCost = 14
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_xm1014_official",
        weight = 3.82,
        pointCost = 15,
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_saiga12k_official",
        weight = 3.6,
        pointCost = 15,
    })
    GAMEMODE:RegisterSecondaryWeapon({
        weaponClass = "cw_shorty",
        weight = 1.8,
        pointCost = 8
    })

    -- sniper rifles
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_l115",
        weight = 6.5,
        pointCost = 38
    })
    GAMEMODE:RegisterPrimaryWeapon({
        weaponClass = "cw_svd_official",
        weight = 4,
        pointCost = 36,
        penMod = 1.25
    })


    -- handguns
    GAMEMODE:RegisterSecondaryWeapon({
        weaponClass = "cw_deagle",
        weight = 2,
        pointCost = 10
    })
    GAMEMODE:RegisterSecondaryWeapon({
        weaponClass = "cw_mr96",
        weight = 1.22,
        pointCost = 8
    })
    GAMEMODE:RegisterSecondaryWeapon({
        weaponClass = "cw_m1911",
        weight = 1.105,
        pointCost = 4
    })
    GAMEMODE:RegisterSecondaryWeapon({
        weaponClass = "cw_fiveseven",
        weight = 0.61,
        pointCost = 9
    })
    GAMEMODE:RegisterSecondaryWeapon({
        weaponClass = "cw_p99",
        weight = 0.63,
        pointCost = 6
    })
    GAMEMODE:RegisterSecondaryWeapon({
        weaponClass = "cw_makarov",
        weight = 0.73,
        pointCost = 4
    })
end
