AddCSLuaFile()

-- Weapons that are uploaded individually
function GM:RegisterWepsCW2BaseThrowables()
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

