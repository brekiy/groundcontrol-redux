AddCSLuaFile()

function GM:RegisterWepsCW2Khris()
    local fnfal = {
        weaponClass = "khr_fnfal",
        weight = 4.45,
        pointCost = 32
    }
    self:RegisterPrimaryWeapon(fnfal)

    local svt40 = {
        weaponClass = "khr_svt40",
        weight = 3.9,
        pointCost = 30
    }
    self:RegisterPrimaryWeapon(svt40)

    local aek971 = {
        weaponClass = "khr_aek971",
        weight = 3.3,
        pointCost = 26
    }
    self:RegisterPrimaryWeapon(aek971)

    local ak103 = {
        weaponClass = "khr_ak103",
        weight = 3.4,
        pointCost = 25
    }
    self:RegisterPrimaryWeapon(ak103)

    local cz858 = {
        weaponClass = "khr_cz858",
        weight = 2.91,
        pointCost = 26
    }
    self:RegisterPrimaryWeapon(cz858)

    local simsks = {
        weaponClass = "khr_simsks",
        weight = 3.67,
        pointCost = 21
    }
    self:RegisterPrimaryWeapon(simsks)

    local sks = {
        weaponClass = "khr_sks",
        weight = 3.8,
        pointCost = 21
    }
    self:RegisterPrimaryWeapon(sks)

    local fmg9 = {
        weaponClass = "khr_fmg9",
        weight = 1.7,
        pointCost = 14
    }
    self:RegisterPrimaryWeapon(fmg9)

    local p90 = {
        weaponClass = "khr_p90",
        weight = 2.6,
        pointCost = 19
    }
    self:RegisterPrimaryWeapon(p90)

    local vector = {
        weaponClass = "khr_vector",
        weight = 2.7,
        pointCost = 16
    }
    self:RegisterPrimaryWeapon(vector)

    local mp40 = {
        weaponClass = "khr_mp40",
        weight = 3.97,
        pointCost = 13
    }
    self:RegisterPrimaryWeapon(mp40)

    local veresk = {
        weaponClass = "khr_veresk",
        weight = 1.65,
        pointCost = 18
    }
    self:RegisterPrimaryWeapon(veresk)

    local l2a3 = {
        weaponClass = "khr_l2a3",
        weight = 2.7,
        pointCost = 13
    }
    self:RegisterPrimaryWeapon(l2a3)

    local m1carbine = {
        weaponClass = "khr_m1carbine",
        weight = 2.6,
        pointCost = 18
    }
    self:RegisterPrimaryWeapon(m1carbine)

    local pkm = {
        weaponClass = "khr_pkm",
        weight = 7.5,
        maxMags = 2,
        pointCost = 37
    }
    self:RegisterPrimaryWeapon(pkm)

    local m60 = {
        weaponClass = "khr_m60",
        weight = 10.5,
        maxMags = 2,
        pointCost = 37
    }
    self:RegisterPrimaryWeapon(m60)

    local mp153 = {
        weaponClass = "khr_mp153",
        weight = 3.45,
        pointCost = 16
    }
    self:RegisterPrimaryWeapon(mp153)

    local ns2000 = {
        weaponClass = "khr_ns2000",
        weight = 3.9,
        pointCost = 15
    }
    self:RegisterPrimaryWeapon(ns2000)

    local m620 = {
        weaponClass = "khr_m620",
        weight = 3.6,
        pointCost = 14
    }
    self:RegisterPrimaryWeapon(m620)

    local toz194 = {
        weaponClass = "khr_toz194",
        weight = 2.9,
        pointCost = 14
    }
    self:RegisterPrimaryWeapon(toz194)

    local khr_cb4 = {
        weaponClass = "khr_cb4",
        weight = 3.27,
        pointCost = 18
    }
    self:RegisterPrimaryWeapon(khr_cb4)

    local m98b = {
        weaponClass = "khr_m98b",
        weight = 5.6,
        pointCost = 40
    }
    self:RegisterPrimaryWeapon(m98b)

    local hcar = {
        weaponClass = "khr_hcar",
        weight = 4.75,
        pointCost = 34
    }
    self:RegisterPrimaryWeapon(hcar)

    local m82a3 = {
        weaponClass = "khr_m82a3",
        weight = 13.5,
        pointCost = 40
    }
    self:RegisterPrimaryWeapon(m82a3)

    local m95 = {
        weaponClass = "khr_m95",
        weight = 10.3,
        pointCost = 40
    }
    self:RegisterPrimaryWeapon(m95)

    local mosin = {
        weaponClass = "khr_mosin",
        weight = 4,
        pointCost = 22,
        penMod = 1.15
    }
    self:RegisterPrimaryWeapon(mosin)

    local t5000 = {
        weaponClass = "khr_t5000",
        weight = 6.5,
        pointCost = 40
    }
    self:RegisterPrimaryWeapon(t5000)

    local sr338 = {
        weaponClass = "khr_sr338",
        weight = 6.75,
        pointCost = 42
    }
    self:RegisterPrimaryWeapon(sr338)

    local deagle = {
        weaponClass = "khr_deagle",
        weight = 2,
        pointCost = 10
    }
    self:RegisterSecondaryWeapon(deagle)

    local makarov = {
        weaponClass = "khr_makarov",
        weight = 0.73,
        pointCost = 4
    }
    self:RegisterSecondaryWeapon(makarov)

    local microdeagle = {
        weaponClass = "khr_microdeagle",
        weight = 0.4,
        pointCost = 7
    }
    self:RegisterSecondaryWeapon(microdeagle)

    local cz52 = {
        weaponClass = "khr_cz52",
        weight = 0.95,
        pointCost = 8
    }
    self:RegisterSecondaryWeapon(cz52)

    local cz75 = {
        weaponClass = "khr_cz75",
        weight = 1.12,
        pointCost = 6
    }
    self:RegisterSecondaryWeapon(cz75)

    local gsh18 = {
        weaponClass = "khr_gsh18",
        weight = 0.59,
        pointCost = 7,
        penMod = 1.25
    }
    self:RegisterSecondaryWeapon(gsh18)

    local m92fs = {
        weaponClass = "khr_m92fs",
        weight = 0.97,
        pointCost = 6
    }
    self:RegisterSecondaryWeapon(m92fs)

    local mp443 = {
        weaponClass = "khr_mp443",
        weight = 0.95,
        pointCost = 7,
        penMod = 1.25
    }
    self:RegisterSecondaryWeapon(mp443)

    local ots33 = {
        weaponClass = "khr_ots33",
        weight = 1.15,
        pointCost = 6
    }
    self:RegisterSecondaryWeapon(ots33)

    local ruby = {
        weaponClass = "khr_ruby",
        weight = 0.85,
        pointCost = 3
    }
    self:RegisterSecondaryWeapon(ruby)

    local rugermk3 = {
        weaponClass = "khr_rugermk3",
        weight = 0.88,
        pointCost = 3
    }
    self:RegisterSecondaryWeapon(rugermk3)

    local p345 = {
        weaponClass = "khr_p345",
        weight = 0.91,
        pointCost = 6
    }
    self:RegisterSecondaryWeapon(p345)

    local p226 = {
        weaponClass = "khr_p226",
        weight = 0.964,
        pointCost = 7
    }
    self:RegisterSecondaryWeapon(p226)

    local sr1m = {
        weaponClass = "khr_sr1m",
        weight = 0.95,
        pointCost = 10
    }
    self:RegisterSecondaryWeapon(sr1m)

    local tokarev = {
        weaponClass = "khr_tokarev",
        weight = 0.854,
        pointCost = 7
    }
    self:RegisterSecondaryWeapon(tokarev)

    local model29 = {
        weaponClass = "khr_model29",
        weight = 1.28,
        pointCost = 7
    }
    self:RegisterSecondaryWeapon(model29)

    local model642 = {
        weaponClass = "khr_38snub",
        weight = 0.56,
        pointCost = 4
    }
    self:RegisterSecondaryWeapon(model642)

    local swr8 = {
        weaponClass = "khr_swr8",
        weight = 1.02,
        pointCost = 5
    }
    self:RegisterSecondaryWeapon(swr8)

    local publicDefender = {
        weaponClass = "khr_410jury",
        weight = 0.765,
        pointCost = 5
    }
    self:RegisterSecondaryWeapon(publicDefender)

    local ragingbull = {
        weaponClass = "khr_ragingbull",
        weight = 1.5,
        pointCost = 7
    }
    self:RegisterSecondaryWeapon(ragingbull)
end