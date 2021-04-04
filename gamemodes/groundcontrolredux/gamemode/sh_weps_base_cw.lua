AddCSLuaFile()

function GM:registerWepsBaseCW()
    -- battle rifles
    local g3a3 = {
        weaponClass = "cw_g3a3",
        weight = 4.1,
        penetration = 18,
        pointCost = 28
    }
    GAMEMODE:registerPrimaryWeapon(g3a3)

    local scarH = {
        weaponClass = "cw_scarh",
        weight = 3.72,
        penetration = 18,
        pointCost = 30
    }
    GAMEMODE:registerPrimaryWeapon(scarH)

    local m14 = {
        weaponClass = "cw_m14",
        weight = 5.1,
        penetration = 18,
        pointCost = 30
    }
    GAMEMODE:registerPrimaryWeapon(m14)

     -- assault rifles
     local ak74 = {
        weaponClass = "cw_ak74",
        weight = 3.07,
        penetration = 15,
        pointCost = 20
    }
    GAMEMODE:registerPrimaryWeapon(ak74)

    local ar15 = {
        weaponClass = "cw_ar15",
        weight = 2.88,
        penetration = 15,
        pointCost = 25
    }
    GAMEMODE:registerPrimaryWeapon(ar15)

    local g36c = {
        weaponClass = "cw_g36c",
        weight = 2.82,
        penetration = 15,
        pointCost = 22
    }
    GAMEMODE:registerPrimaryWeapon(g36c)

    local l85 = {
        weaponClass = "cw_l85a2",
        weight = 3.82,
        penetration = 15,
        pointCost = 22
    }
    GAMEMODE:registerPrimaryWeapon(l85)

    local vss = {
        weaponClass = "cw_vss",
        weight = 2.6,
        penetration = 15,
        pointCost = 28
    }
    GAMEMODE:registerPrimaryWeapon(vss)

    -- sub-machine guns/light carbines
    local mp5 = {
        weaponClass = "cw_mp5",
        weight = 2.5,
        penetration = 7,
        pointCost = 15
    }
    GAMEMODE:registerPrimaryWeapon(mp5)

    local mac11 = {
        weaponClass = "cw_mac11",
        weight = 1.59,
        penetration = 6,
        pointCost = 12
    }
    GAMEMODE:registerPrimaryWeapon(mac11)

    local ump45 = {
        weaponClass = "cw_ump45",
        weight = 2.5,
        penetration = 7,
        pointCost = 13
    }
    GAMEMODE:registerPrimaryWeapon(ump45)

    -- heavy weapons
    local m249 = {
        weaponClass = "cw_m249_official",
        weight = 7.5,
        penetration = 15,
        maxMags = 2,
        pointCost = 30
    }
    GAMEMODE:registerPrimaryWeapon(m249)

    -- shotguns
    local m3super90 = {
        weaponClass = "cw_m3super90",
        weight = 3.27,
        penetration = 4,
        pointCost = 14
    }
    GAMEMODE:registerPrimaryWeapon(m3super90)

    local serbushorty = {
        weaponClass = "cw_shorty",
        weight = 1.8,
        penetration = 4,
        pointCost = 12
    }
    GAMEMODE:registerPrimaryWeapon(serbushorty)

    -- sniper rifles
    local l115 = {
        weaponClass = "gc_cw_l115",
        weight = 6.5,
        penetration = 20,
        pointCost = 38
    }
    GAMEMODE:registerPrimaryWeapon(l115)

    -- handguns
    local deagle = {
        weaponClass = "cw_deagle",
        weight = 1.998,
        penetration = 10,
        pointCost = 10
    }
    GAMEMODE:registerSecondaryWeapon(deagle)

    local mr96 = {
        weaponClass = "cw_mr96",
        weight = 1.22,
        penetration = 12,
        pointCost = 8
    }
    GAMEMODE:registerSecondaryWeapon(mr96)

    local m1911 = {
        weaponClass = "cw_m1911",
        weight = 1.105,
        penetration = 7,
        pointCost = 7
    }
    GAMEMODE:registerSecondaryWeapon(m1911)

    local fiveseven = {
        weaponClass = "cw_fiveseven",
        weight = 0.61,
        penetration = 11,
        pointCost = 9
    }
    GAMEMODE:registerSecondaryWeapon(fiveseven)

    local p99 = {
        weaponClass = "cw_p99",
        weight = 0.63,
        penetration = 7,
        pointCost = 8
    }
    GAMEMODE:registerSecondaryWeapon(p99)

    local makarov = {
        weaponClass = "cw_makarov",
        weight = 0.73,
        penetration = 6,
        pointCost = 5
    }
    GAMEMODE:registerSecondaryWeapon(makarov)
end
