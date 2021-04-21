include("sh_loadout.lua")

local PLAYER = FindMetaTable("Player")

function PLAYER:attemptGiveLoadoutAmmo(weaponData)
    local wep = self:GetWeapon(weaponData.weaponClass)

    if weaponData.startAmmo then
        wep.Owner:SetAmmo(weaponData.startAmmo, wep.Primary.Ammo)
    end
end

function PLAYER:attemptGiveWeapon(givenWeaponData)
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

function PLAYER:attemptPostGiveWeapon(givenWeaponData)
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

    -- get the weapons we want to spawn with
    local primaryData = self:getDesiredPrimaryWeapon()
    local secondaryData = self:getDesiredSecondaryWeapon()
    local tertiaryData = self:getDesiredTertiaryWeapon()

    -- give the weapons
    self:attemptGiveWeapon(primaryData)
    self:attemptGiveWeapon(secondaryData)
    self:attemptGiveWeapon(tertiaryData)

    -- get the amount of ammo we want to spawn with
    local primaryMags = self:getDesiredPrimaryMags()
    local secondaryMags = self:getDesiredSecondaryMags()

    primaryMags = self:adjustMagCount(primaryData, primaryMags)
    secondaryMags = self:adjustMagCount(secondaryData, secondaryMags)

    local plyObj = self

    timer.Simple(0.3, function()
        if !IsValid(plyObj) or !plyObj:Alive() then
            return
        end

        GAMEMODE:cheapOut(self)

        if GAMEMODE.curGametype.SkipAttachmentGive then
            if !GAMEMODE.curGametype:SkipAttachmentGive(self) then
                CustomizableWeaponry.giveAttachments(self, self.ownedAttachmentsNumeric, true, true)
            end
        else
            CustomizableWeaponry.giveAttachments(self, self.ownedAttachmentsNumeric, true, true)
        end

        local primaryWepObj, secWepObj = nil, nil

        if primaryData then
            primaryWepObj = plyObj:GetWeapon(primaryData.weaponClass)
            plyObj:setupAttachmentLoadTable(primaryWepObj)
            plyObj:equipAttachments(primaryWepObj, GAMEMODE.AttachmentLoadTable)
        end

        if secondaryData then
            secWepObj = plyObj:GetWeapon(secondaryData.weaponClass)
            plyObj:setupAttachmentLoadTable(secWepObj)
            plyObj:equipAttachments(secWepObj, GAMEMODE.AttachmentLoadTable)
        end

        -- remove any ammo that may have been added to our reserve
        plyObj:RemoveAllAmmo()

        if primaryWepObj then
            -- set the ammo after we've attached everything, since some attachments may modify mag size
            plyObj:GiveAmmo(primaryMags * primaryWepObj.Primary.ClipSize_Orig, primaryWepObj.Primary.Ammo)
            primaryWepObj:maxOutWeaponAmmo(primaryWepObj.Primary.ClipSize_Orig) -- same for the magazine
        end

        if secWepObj then
            plyObj:GiveAmmo(secondaryMags * secWepObj.Primary.ClipSize_Orig, secWepObj.Primary.Ammo)
            secWepObj:maxOutWeaponAmmo(secWepObj.Primary.ClipSize_Orig)
        end

        plyObj:GiveAmmo(1, "Frag Grenades")

        if primaryData then
            plyObj:attemptGiveLoadoutAmmo(primaryData)
            plyObj:attemptPostGiveWeapon(primaryData)
        end

        if secondaryData then
            plyObj:attemptGiveLoadoutAmmo(secondaryData)
            plyObj:attemptPostGiveWeapon(secondaryData)
        end

        if tertiaryData then
            plyObj:attemptGiveLoadoutAmmo(tertiaryData)
            plyObj:attemptPostGiveWeapon(tertiaryData)
        end

        plyObj:setWeight(plyObj:calculateWeight())

        if plyObj.weight >= GAMEMODE.MaxWeight * 0.65 then
            plyObj:sendTip("HIGH_WEIGHT")
        end
    end)

    self:giveGadgets()
    if plyObj:IsBot() then
        plyObj:GiveGCArmor("vest", 2)
        plyObj:GiveGCArmor("helmet", 1)
    elseif GAMEMODE:getImaginaryLoadoutCost(plyObj) > self:getCurrentLoadoutPoints() then
        self:GiveGCArmor("vest", 0)
        self:GiveGCArmor("helmet", 0)
        plyObj:sendTip("LOADOUT_LIMIT")
    else
        self:GiveGCArmor("vest")
        self:GiveGCArmor("helmet")
    end

    self:Give(GAMEMODE.KnifeWeaponClass)
end

--[[
    Used when the game detects that your loadout costs way too much.
    Happens if you were wearing some gucci kit and the game swaps to a new map, and your loadout suddenly costs way too much.
]]--
function GM:cheapOut(ply)
    local limit = ply:getCurrentLoadoutPoints()
    if self:getImaginaryLoadoutCost(ply) <= limit then return end

    if ply:GetInfoNum("gc_tertiary_weapon", GAMEMODE.DefaultTertiaryIndex) > 0 then
        ply:ConCommand("gc_tertiary_weapon " .. 0)
    end
    local curHelmet = ply:GetInfoNum("gc_armor_helmet", 0)
    while self:getImaginaryLoadoutCost(ply) > limit and curHelmet > 0 do
        print(ply:getDesiredHelmet())
        ply:ConCommand("gc_armor_helmet " .. curHelmet - 1)
        print(ply:getDesiredHelmet())
        curHelmet = curHelmet - 1
        print("docked a helmet, curHelmet is now " .. curHelmet)
    end
    local curArmor = ply:GetInfoNum("gc_armor_vest", 0)
    while self:getImaginaryLoadoutCost(ply) > limit and curArmor > 0 do
        print(ply:getDesiredVest())
        ply:ConCommand("gc_armor_vest " .. curArmor - 1)
        curArmor = curArmor - 1
        print("docked a vest, curvest is now " .. curArmor)
    end
end

function PLAYER:attemptGiveLoadout()
    if GAMEMODE.LoadoutSelectTime and CurTime() < GAMEMODE.LoadoutSelectTime and (self.spawnPoint and self:GetPos():Distance(self.spawnPoint) <= GAMEMODE.LoadoutDistance) then
        self:giveLoadout()
    end
end


concommand.Add("gc_ask_for_loadout", function(ply)
    if !ply:Alive() then
        return
    end

    ply:attemptGiveLoadout()
end)