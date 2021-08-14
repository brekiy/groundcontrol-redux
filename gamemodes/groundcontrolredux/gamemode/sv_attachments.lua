AddCSLuaFile("cl_attachments.lua")
include("sh_attachments.lua")

local PLAYER = FindMetaTable("Player")

GM.AttachmentDirectory = GM.MainDataDirectory .. "/player_attachments/" -- where we save the attachments that players possess
GM.AttachmentLoadTable = {}
GM.ExpAmount = {exp = nil}

file.verifyDataFolder(GM.MainDataDirectory)
file.verifyDataFolder(GM.AttachmentDirectory)

function PLAYER:SaveAttachments()
    local data = util.TableToJSON(self.ownedAttachments)

    file.Write(GAMEMODE.AttachmentDirectory .. self:SteamID64() .. ".txt", data)
end

function PLAYER:LoadAttachments()
    local readData = file.Read(GAMEMODE.AttachmentDirectory .. self:SteamID64() .. ".txt", "DATA")
    readData = readData and util.JSONToTable(readData) or {}

    self.ownedAttachmentsNumeric = {}
    self.ownedAttachments = readData
    self:UpdateNumericAttachmentsTable(readData)
    self:SendAttachments()
end

function PLAYER:CheckForAttachmentSlotUnlock()
    local reqExp = self:getNextAttachmentSlotPrice()
    local residue = self.experience - reqExp

    if residue > 0 then
        if self:canUnlockMoreSlots() then
            self:UnlockAttachmentSlot()
            self:setExperience(residue)
        else
            self:setExperience(0)
        end
    end
end

function PLAYER:UnlockAttachmentSlot()
    self.unlockedAttachmentSlots = self.unlockedAttachmentSlots + 1
    self:SaveUnlockedAttachmentSlots()
    self:SendUnlockedAttachmentSlots()
end

function PLAYER:UpdateNumericAttachmentsTable(fillWith)
    if type(fillWith) == "string" then
        table.insert(self.ownedAttachmentsNumeric, fillWith)
    elseif type(fillWith) == "table" then
        for attachmentName, name in pairs(fillWith) do
            table.insert(self.ownedAttachmentsNumeric, attachmentName)
        end
    end
end

function PLAYER:UnlockAttachment(attachmentName, isFree)
    local attachmentData = CustomizableWeaponry.registeredAttachmentsSKey[attachmentName] or ArcCW.AttachmentTable[attachmentName]
    local price = nil

    if isFree then
        price = 0
    else
        price = attachmentData.price
    end

    -- this attachment is free/already was bought, dont need to unlock
    if !isFree and (!price or price < 0) or self.ownedAttachments[attachmentName] then
        return
    end

    if self.cash >= price then
        self.ownedAttachments[attachmentName] = true
        self:RemoveCash(price)
        self:SendUnlockedAttachment(attachmentName)
        self:SaveAttachments()
        self:UpdateNumericAttachmentsTable(attachmentName)
    else
        net.Start("GC_NOT_ENOUGH_CASH")
        net.WriteInt(price, 32)
        net.Send(self)
    end
end

-- no idea why you would need this, but whatever
function PLAYER:LockAttachment(attachmentName)
    self.ownedAttachments[attachmentName] = nil
end

function PLAYER:SendUnlockedAttachment(attachmentName)
    net.Start("GC_UNLOCK_ATTACHMENT")
    net.WriteString(attachmentName)
    net.Send(self)
end

function PLAYER:SendAttachments()
    net.Start("GC_ATTACHMENTS")
    net.WriteTable(self.ownedAttachments)
    net.Send(self)
end

function PLAYER:SetupAttachmentLoadTable(weaponObject)
    table.Empty(GAMEMODE.AttachmentLoadTable)

    --local baseConvarName = weaponObject.isPrimaryWeapon and "gc_primary_attachment_" or "gc_secondary_attachment_"
    local targetTable = weaponObject.isPrimaryWeapon and GAMEMODE.PrimaryAttachmentStrings or GAMEMODE.SecondaryAttachmentStrings

    for i = 1, self:getAvailableAttachmentSlotCount() do -- get all attachments the player can set up on the client
        local desiredAttachment = self:GetInfo(targetTable[i]) --self:GetInfo(baseConvarName .. i)

        if desiredAttachment and self:hasUnlockedAttachment(desiredAttachment) then -- check whether the attachment exists
            -- now we iterate over all weapon attachments, find it in it's category and assign the category to the attachment name
            for category, data in pairs(weaponObject.Attachments) do
                for index, attachmentName in ipairs(data.atts) do
                    if attachmentName == desiredAttachment then
                        GAMEMODE.AttachmentLoadTable[category] = index
                    end
                end
            end
        end
    end
end

function PLAYER:EquipAttachments(targetWeapon, data)
    -- and lastly, we load all the attachments via CW 2.0's attachment preset system
    if targetWeapon.CW20Weapon then
        CustomizableWeaponry.preset.load(targetWeapon, data, "GroundControlPreset")
    end
end

function PLAYER:SendUnlockedAttachmentSlots()
    net.Start("GC_UNLOCKED_SLOTS")
    net.WriteUInt(self.unlockedAttachmentSlots, 8)
    net.Send(self)
end

function PLAYER:LoadUnlockedAttachmentSlots()
    local slots = self:GetPData("GroundControlUnlockedAttachmentSlots") or 0

    self.unlockedAttachmentSlots = tonumber(slots)
end

function PLAYER:SaveUnlockedAttachmentSlots()
    self:SetPData("GroundControlUnlockedAttachmentSlots", self.unlockedAttachmentSlots)
end

function PLAYER:LoadExperience()
    local exp = self:GetPData("GroundControlExperience") or 0

    self.experience = tonumber(exp)
end

function PLAYER:SaveExperience()
    self:SetPData("GroundControlExperience", self.experience)
end

function PLAYER:SendExperience()
    net.Start("GC_EXPERIENCE")
    net.WriteInt(self.experience, 32)
    net.Send(self)
end

function PLAYER:AddExperience(amount, event)
    self:SetNWInt("GC_SCORE", self:GetNWInt("GC_SCORE") + amount)

    if !self:canUnlockMoreSlots() then
        return
    end

    self.experience = math.max(self.experience + amount, 0)
    self:CheckForAttachmentSlotUnlock()
    self:SaveExperience()

    self:SendExperience()

    if event then
        GAMEMODE.ExpAmount.exp = amount
        GAMEMODE:sendEvent(self, event, GAMEMODE.ExpAmount)
    end
end

concommand.Add("gc_buy_attachment", function(ply, com, args)
    local attName = args[1]

    if !attName then
        return
    end

    if !ply:hasUnlockedAttachment(attName) then
        ply:UnlockAttachment(attName)
    end
end)