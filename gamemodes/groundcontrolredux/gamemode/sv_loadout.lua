include("sh_loadout.lua")

local PLAYER = FindMetaTable("Player")

function PLAYER:AttemptGiveLoadoutAmmo(weaponData)
    local wep = self:GetWeapon(weaponData.weaponClass)

    if weaponData.startAmmo then
        wep.Owner:SetAmmo(weaponData.startAmmo, wep.Primary.Ammo)
    end
end

function PLAYER:AttemptGiveWeapon(givenWeaponData)
    if !givenWeaponData then
        return
    end

    if givenWeaponData.weaponClass and !givenWeaponData.skipWeaponGive then
        self:Give(givenWeaponData.weaponClass)
    end

    if givenWeaponData.onGive then
        givenWeaponData:onGive(self)
    end
end

function PLAYER:AttemptPostGiveWeapon(givenWeaponData)
    if givenWeaponData.postGive then
        givenWeaponData:postGive(self)
    end
end

function PLAYER:giveLoadout(forceGive)
    if !forceGive and GAMEMODE.curGametype.CanReceiveLoadout and !GAMEMODE.curGametype:CanReceiveLoadout(self) then
        return
    end

    self:StripWeapons()
    self:RemoveAllAmmo()
    self:ResetGadgetData()
    self:ApplyTraits()

    if self:IsBot() then
        GiveBotRandomLoadout(self)
        self:SetWeight(self:CalculateWeight())
    elseif GAMEMODE:GetImaginaryLoadoutCost(self) > self:GetCurrentLoadoutPoints() then
        -- Reset desired armor, primary weapon to 0
        GAMEMODE:CheapOut(self)
        net.Start("GC_START_LOADOUT_EXPENSIVE")
        net.Send(self)
    else
        self:GiveGCArmor("vest")
        self:GiveGCArmor("helmet")
    end

    -- get the weapons we want to spawn with
    local primaryData = self:GetDesiredPrimaryWeapon()
    local secondaryData = self:GetDesiredSecondaryWeapon()
    local tertiaryData = self:GetDesiredTertiaryWeapon()

    -- give the weapons
    self:AttemptGiveWeapon(primaryData)
    self:AttemptGiveWeapon(secondaryData)
    self:AttemptGiveWeapon(tertiaryData)
    self:Give(GAMEMODE.KnifeWeaponClass)

    -- Bots exit early with no attachments
    if self:IsBot() then return end

    -- get the amount of ammo we want to spawn with
    local primaryMags = self:GetDesiredPrimaryMags()
    local secondaryMags = self:GetDesiredSecondaryMags()

    primaryMags = self:AdjustMagCount(primaryData, primaryMags)
    secondaryMags = self:AdjustMagCount(secondaryData, secondaryMags)

    timer.Simple(0.3, function()
        if !IsValid(self) or !self:Alive() then
            return
        end

        if GAMEMODE.curGametype.SkipAttachmentGive then
            if !GAMEMODE.curGametype:SkipAttachmentGive(self) then
                CustomizableWeaponry.giveAttachments(self, self.ownedAttachmentsNumeric, true, true)
            end
        else
            CustomizableWeaponry.giveAttachments(self, self.ownedAttachmentsNumeric, true, true)
        end

        local primaryWepObj, secWepObj = nil, nil

        if primaryData then
            primaryWepObj = self:GetWeapon(primaryData.weaponClass)
            self:SetupAttachmentLoadTable(primaryWepObj)
            self:EquipAttachments(primaryWepObj, GAMEMODE.AttachmentLoadTable)
        end

        if secondaryData then
            secWepObj = self:GetWeapon(secondaryData.weaponClass)
            self:SetupAttachmentLoadTable(secWepObj)
            self:EquipAttachments(secWepObj, GAMEMODE.AttachmentLoadTable)
        end

        -- remove any ammo that may have been added to our reserve
        self:RemoveAllAmmo()

        if primaryWepObj then
            local magSize = GC_GetWeaponMagSize(primaryWepObj)
            -- set the ammo after we've attached everything, since some attachments may modify mag size
            self:GiveAmmo(primaryMags * magSize, primaryWepObj.Primary.Ammo)
            MaxOutWeaponAmmo(primaryWepObj, magSize) -- same for the magazine
        end

        if secWepObj then
            local magSize = GC_GetWeaponMagSize(secWepObj)
            self:GiveAmmo(secondaryMags * magSize, secWepObj.Primary.Ammo)
            MaxOutWeaponAmmo(secWepObj, magSize)
        end

        self:GiveAmmo(1, "Frag Grenades")

        if primaryData then
            self:AttemptGiveLoadoutAmmo(primaryData)
            self:AttemptPostGiveWeapon(primaryData)
        end

        if secondaryData then
            self:AttemptGiveLoadoutAmmo(secondaryData)
            self:AttemptPostGiveWeapon(secondaryData)
        end

        if tertiaryData then
            self:AttemptGiveLoadoutAmmo(tertiaryData)
            self:AttemptPostGiveWeapon(tertiaryData)
        end
        self:SetWeight(self:CalculateWeight())
        if self.weight >= GAMEMODE.MAX_WEIGHT * 0.65 then
            self:SendTip("HIGH_WEIGHT")
        end
    end)

    self:giveGadgets()
end

function MaxOutWeaponAmmo(weapon, magsize)
    if weapon.Base == "cw_base" then
        weapon:maxOutWeaponAmmo(magsize)
    elseif weapon.Base == "arccw_base" then
        weapon:SetClip1(magsize + weapon:GetChamberSize())
    end
end

function GC_GetWeaponMagSize(weapon)
    if weapon.CW20Weapon then
        return weapon.Primary.ClipSize_Orig
    elseif weapon.ArcCW then
        return weapon.Primary.ClipSize
    else
        return 1
    end
end

function GiveBotRandomLoadout(bot)
    -- Give primary, then give secondary
    local pickedWeapon = GAMEMODE.PrimaryWeapons[math.random(1, #GAMEMODE.PrimaryWeapons)]
    local givenWeapon = bot:Give(pickedWeapon.weaponClass)
    local magSize = GC_GetWeaponMagSize(givenWeapon)
    bot:GiveAmmo(3 * magSize, givenWeapon.Primary.Ammo)
    MaxOutWeaponAmmo(givenWeapon, magSize)

    pickedWeapon = GAMEMODE.SecondaryWeapons[math.random(1, #GAMEMODE.SecondaryWeapons)]
    givenWeapon = bot:Give(pickedWeapon.weaponClass)
    magSize = GC_GetWeaponMagSize(givenWeapon)
    bot:GiveAmmo(3 * magSize, givenWeapon.Primary.Ammo)
    MaxOutWeaponAmmo(givenWeapon, magSize)

    bot:GiveGCArmor("vest", 2)
    bot:GiveGCArmor("helmet", 1)
end

--[[
    Used when the game detects that your loadout costs way too much.
    Happens if you were wearing some gucci kit and the game swaps to a new map, and your loadout suddenly costs way too much.
]]--
function GM:CheapOut(ply)
    ply:ConCommand("gc_primary_weapon " .. 0)
    ply:ConCommand("gc_tertiary_weapon " .. 0)
    ply:ConCommand("gc_armor_helmet " .. 0)
    ply:ConCommand("gc_armor_vest " .. 0)
    ply:GiveGCArmor("vest", 0)
    ply:GiveGCArmor("helmet", 0)
    -- local curHelmet = ply:GetInfoNum("gc_armor_helmet", 0)
    -- while self:GetImaginaryLoadoutCost(ply) > limit and curHelmet > 0 do
        -- print(ply:GetDesiredHelmet())
        -- ply:ConCommand("gc_armor_helmet " .. curHelmet - 1)
        -- print(ply:GetDesiredHelmet())
        -- curHelmet = curHelmet - 1
        -- print("docked a helmet, curHelmet is now " .. curHelmet)
    -- end
    -- local curArmor = ply:GetInfoNum("gc_armor_vest", 0)
    -- while self:GetImaginaryLoadoutCost(ply) > limit and curArmor > 0 do
        -- print(ply:GetDesiredVest())
        -- ply:ConCommand("gc_armor_vest " .. curArmor - 1)
        -- curArmor = curArmor - 1
        -- print("docked a vest, curvest is now " .. curArmor)
    -- end
end

function PLAYER:AttemptGiveLoadout()
    if GAMEMODE.LoadoutSelectTime and CurTime() < GAMEMODE.LoadoutSelectTime and (self.spawnPoint and self:GetPos():Distance(self.spawnPoint) <= GAMEMODE.LoadoutDistance) then
        self:giveLoadout()
    end
end


concommand.Add("gc_ask_for_loadout", function(ply)
    if !ply:Alive() then
        return
    end

    ply:AttemptGiveLoadout()
end)