AddCSLuaFile()

-- Util functions that have been defined under lua libraries
function file.verifyDataFolder(path)
    if !file.IsDir(path, "DATA") then
        file.CreateDir(path)
    end
end

function table.Exclude(tbl, obj)
    for key, value in pairs(tbl) do
        if value == obj then
            table.remove(tbl, key)
        end
    end

    return tbl
end

function team.GetLivingPlayers(teamID)
    local total = 0

    for key, ply in ipairs(team.GetPlayers(teamID)) do
        if ply:Alive() then
            total = total + 1
        end
    end

    return total
end

function AddFile(File, dir)
    local fileSide = string.lower(string.Left(File , 3))

    if SERVER and fileSide == "sv_" then
        include(dir .. File)
        print("[AUTOLOAD] SV INCLUDE: " .. File)
    elseif fileSide == "sh_" then
        if SERVER then
            AddCSLuaFile(dir .. File)
            print("[AUTOLOAD] SH ADDCS: " .. File)
        end
        include(dir .. File)
        print("[AUTOLOAD] SH INCLUDE: " .. File)
    elseif fileSide == "cl_" then
        if SERVER then
            AddCSLuaFile(dir .. File)
            print("[AUTOLOAD] CL ADDCS: " .. File)
        elseif CLIENT then
            include(dir .. File)
            print("[AUTOLOAD] CL INCLUDE: " .. File)
        end
    end
end

-- Lifted from the Gmod wiki with some extra params to
-- specify the filesearch path and prepend a wildcard.
function IncludeDir(dir, path)
    dir = dir .. "/"
    local findDir = "gamemodes/groundcontrolredux/gamemode/" .. dir
    local File, Directory = file.Find(findDir .. "*", path)
    for k, v in ipairs(File) do
        print("[AUTOLOAD] FILE: " .. v)
        if string.EndsWith(v, ".lua") then
            AddFile(v, dir)
        end
    end

    for k, v in ipairs(Directory) do
        print("[AUTOLOAD] Directory: " .. v)
        IncludeDir(dir .. v, path)
    end

end

-- Lifted pretty much from CW2.0
function GCCheckLowTotalAmmo(wep)
    if wep:GetOwner():GetAmmoCount(wep.Primary.Ammo) + wep:Clip1() <= wep.Primary.ClipSize * 2 then
        return true
    end

    return false
end

function GCGetMagCapacity(wep)
    local mag = wep:Clip1()
    local magCap = wep:GetMaxClip1()
    if mag > magCap then
        return magCap .. " + " .. mag - magCap
    end

    return mag
end

function GM:GetWeaponData(id, isPrimary)
    if isPrimary then
        return GAMEMODE.PrimaryWeapons[id]
    elseif isPrimary != nil and !isPrimary then
        return GAMEMODE.SecondaryWeapons[id]
    else
        return GAMEMODE.TertiaryWeapons[id]
    end
end

if CLIENT then
    draw.VERTICAL = 1
    draw.HORIZONTAL = 2

    -- taken from somewhere, can't recall, whoever wrote this - please don't get mad at me!
    function draw.LinearGradient(x,y,w,h,from,to,dir)
        dir = dir or draw.HORIZONTAL
        local res = nil

        if dir == draw.HORIZONTAL then
            res = w
        elseif dir == draw.VERTICAL then
            res = h
        end

        for i = 1, res do
            surface.SetDrawColor(
                Lerp(i / res, from.r, to.r),
                Lerp(i / res, from.g, to.g),
                Lerp(i / res, from.b, to.b),
                Lerp(i / res, from.a, to.a)
            )

            if dir == draw.HORIZONTAL then
                surface.DrawRect(x + i, y, 1, h )
            elseif dir == draw.VERTICAL then
                surface.DrawRect(x, y + i, w, 1 )
            end
        end
    end
end

--[[
    Given a base string, subs out keys for associated values
    Input format: <target string with keys> <key1> <value1> ...
--]]
function string.easyformatbykeys(target, ...)
    local cur = 1

    while true do
        local element = select(cur, ...)
        local replacement = select(cur + 1, ...)

        if !element or !replacement then
            break
        end

        target = string.gsub(target, element, replacement)
        cur = cur + 2
    end

    return target
end

function math.flash(value, flashSpeed)
    value = value * flashSpeed
    local flash = math.ceil(value) - value
    local dist = math.abs(0.5 - flash) * 2

    return dist
end

function math.signedmin(value, otherValue)
    local sign = value / math.abs(value)

    return math.max(math.min(value, otherValue), otherValue * sign)
end
