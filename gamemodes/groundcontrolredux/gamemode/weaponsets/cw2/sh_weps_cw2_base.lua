AddCSLuaFile()

function GM:RegisterWepsCW2Base()
    -- battle rifles
    local g3a3 = {
        weaponClass = "cw_g3a3",
        weight = 4.1,
        pointCost = 32
    }
    GAMEMODE:RegisterPrimaryWeapon(g3a3)

    local scarH = {
        weaponClass = "cw_scarh",
        weight = 3.72,
        pointCost = 32
    }
    GAMEMODE:RegisterPrimaryWeapon(scarH)

    local m14 = {
        weaponClass = "cw_m14",
        weight = 5.1,
        pointCost = 32
    }
    GAMEMODE:RegisterPrimaryWeapon(m14)

     -- assault rifles
     local ak74 = {
        weaponClass = "cw_ak74",
        weight = 3.07,
        pointCost = 22
    }
    GAMEMODE:RegisterPrimaryWeapon(ak74)

    local ar15 = {
        weaponClass = "cw_ar15",
        weight = 3.01,
        pointCost = 26
    }
    GAMEMODE:RegisterPrimaryWeapon(ar15)

    local g36c = {
        weaponClass = "cw_g36c",
        weight = 2.82,
        pointCost = 24
    }
    GAMEMODE:RegisterPrimaryWeapon(g36c)

    local l85 = {
        weaponClass = "cw_l85a2",
        weight = 3.82,
        pointCost = 24
    }
    GAMEMODE:RegisterPrimaryWeapon(l85)

    local vss = {
        weaponClass = "cw_vss",
        weight = 2.6,
        pointCost = 23
    }
    GAMEMODE:RegisterPrimaryWeapon(vss)

    -- sub-machine guns/light carbines
    local mp5 = {
        weaponClass = "cw_mp5",
        weight = 2.5,
        pointCost = 15,
        penMod = 1.2
    }
    GAMEMODE:RegisterPrimaryWeapon(mp5)

    local mac11 = {
        weaponClass = "cw_mac11",
        weight = 1.59,
        pointCost = 12
    }
    GAMEMODE:RegisterPrimaryWeapon(mac11)

    local ump45 = {
        weaponClass = "cw_ump45",
        weight = 2.5,
        pointCost = 13,
        penMod = 1.5
    }
    GAMEMODE:RegisterPrimaryWeapon(ump45)

    local mp9 = {
        weaponClass = "cw_mp9_official",
        weight = 1.4,
        pointCost = 16,
        penMod = 1.1
    }
    GAMEMODE:RegisterPrimaryWeapon(mp9)

    -- heavy weapons
    local m249 = {
        weaponClass = "cw_m249_official",
        weight = 7.5,
        maxMags = 2,
        pointCost = 32
    }
    GAMEMODE:RegisterPrimaryWeapon(m249)

    -- shotguns
    local m3super90 = {
        weaponClass = "cw_m3super90",
        weight = 3.27,
        pointCost = 14
    }
    GAMEMODE:RegisterPrimaryWeapon(m3super90)

    local m1014 = {
        weaponClass = "cw_xm1014_official",
        weight = 3.82,
        pointCost = 15,
    }
    GAMEMODE:RegisterPrimaryWeapon(m1014)

    local saiga12 = {
        weaponClass = "cw_saiga12k_official",
        weight = 3.6,
        pointCost = 15,
    }
    GAMEMODE:RegisterPrimaryWeapon(saiga12)

    local serbushorty = {
        weaponClass = "cw_shorty",
        weight = 1.8,
        pointCost = 8
    }
    GAMEMODE:RegisterSecondaryWeapon(serbushorty)

    -- sniper rifles
    local l115 = {
        weaponClass = "cw_l115",
        weight = 6.5,
        pointCost = 38
    }
    GAMEMODE:RegisterPrimaryWeapon(l115)

    -- handguns
    local deagle = {
        weaponClass = "cw_deagle",
        weight = 2,
        pointCost = 10
    }
    GAMEMODE:RegisterSecondaryWeapon(deagle)

    local mr96 = {
        weaponClass = "cw_mr96",
        weight = 1.22,
        pointCost = 8
    }
    GAMEMODE:RegisterSecondaryWeapon(mr96)

    local m1911 = {
        weaponClass = "cw_m1911",
        weight = 1.105,
        pointCost = 4
    }
    GAMEMODE:RegisterSecondaryWeapon(m1911)

    local fiveseven = {
        weaponClass = "cw_fiveseven",
        weight = 0.61,
        pointCost = 9
    }
    GAMEMODE:RegisterSecondaryWeapon(fiveseven)

    local p99 = {
        weaponClass = "cw_p99",
        weight = 0.63,
        pointCost = 6
    }
    GAMEMODE:RegisterSecondaryWeapon(p99)

    local makarov = {
        weaponClass = "cw_makarov",
        weight = 0.73,
        pointCost = 4
    }
    GAMEMODE:RegisterSecondaryWeapon(makarov)

    local flash = {
        weaponClass = "gc_cw_flash_grenade",
        weight = 0.5,
        startAmmo = 2,
        hideMagIcon = true, -- whether the mag icon and text should be hidden in the UI for this weapon
        description = {
            {t = "Flashbang", font = "CW_HUD24", c = Color(255, 255, 255, 255)},
            {t = "Blinds nearby enemies facing the grenade upon detonation.", font = "CW_HUD20", c = Color(255, 255, 255, 255)},
            {t = "2x grenades.", font = "CW_HUD20", c = Color(255, 255, 255, 255)}
        },
        pointCost = 3
    }
    self:RegisterTertiaryWeapon(flash)

    local smoke = {
        weaponClass = "gc_cw_smoke_grenade",
        weight = 0.5,
        startAmmo = 2,
        hideMagIcon = true,
        description = {
            {t = "Smoke grenade", font = "CW_HUD24", c = Color(255, 255, 255, 255)},
            {t = "Provides a smoke screen to deter enemies from advancing or pushing through.", font = "CW_HUD20", c = Color(255, 255, 255, 255)},
            {t = "2x grenades.", font = "CW_HUD20", c = Color(255, 255, 255, 255)}
        },
        pointCost = 3
    }
    self:RegisterTertiaryWeapon(smoke)

    local spareGrenade = {
        weaponClass = "gc_cw_frag_grenade",
        weight = 0.5,
        amountToGive = 1,
        skipWeaponGive = true,
        hideMagIcon = true,
        description = {
            {t = "Spare frag grenade", font = "CW_HUD24", c = Color(255, 255, 255, 255)},
            {t = "Allows for a second frag grenade to be thrown.", font = "CW_HUD20", c = Color(255, 255, 255, 255)}
        },
        pointCost = 5
    }

    function spareGrenade:postGive(ply)
        ply:GiveAmmo(self.amountToGive, "Frag Grenades")
    end

    self:RegisterTertiaryWeapon(spareGrenade)
end
