include("sh_player_armor.lua")

local PLAYER = FindMetaTable("Player")

--[[
    This function takes in the bullet damage dealt to the player and calculates the armor
    degredation and health damage that the player takes.
]]--
function PLAYER:processArmorDamage(dmgInfo, penetrationValue, hitGroup, allowBleeding)
    if not penetrationValue then
        return
    end

    local shouldBleed = true
    local removeIndex = 1

    local combinedArmor = self:getTotalArmorPieces()

    for i = 1, #combinedArmor do
        local armorPiece = combinedArmor[removeIndex]
        local armorData = GAMEMODE:getArmorData(armorPiece.id, armorPiece.category)
        local removeArmor = false
        if armorData.protectionAreas[hitGroup] then
            -- print(armorData.displayName.." is mitigating damage")
            local protectionDelta = armorData.protection - penetrationValue
            local penetratesArmor = protectionDelta < 0
            local damageNegation = nil
            
            if not penetratesArmor then
                shouldBleed = false
                
                damageNegation = armorData.damageDecrease + protectionDelta * armorData.protectionDeltaToDamageDecrease
                local regenAmount = math.floor(dmgInfo:GetDamage() * damageNegation)
                self:addHealthRegen(regenAmount)
                self:delayHealthRegen()
            else
                damageNegation = armorData.damageDecreasePenetration
                self:resetHealthRegenData() -- if our armor gets penetrated, it doesn't matter how much health we had in our regen pool, we still start bleeding
            end
            
            self:takeArmorDamage(armorPiece, dmgInfo)
            dmgInfo:ScaleDamage(1 - damageNegation)
            
            local health = armorPiece.health
            
            if armorPiece.health > 0 then
                removeIndex = removeIndex + 1
            else
                removeArmor = true
            end
            
            self:sendArmorPiece(i, health, armorData.category)
            if removeArmor then
                table.remove(combinedArmor, removeIndex)
                self:calculateWeight()
            end
        end
    end
    
    if allowBleeding and shouldBleed then
        self:startBleeding(dmgInfo:GetAttacker())
    end
end

function PLAYER:giveArmor()
    self:resetArmorData()
    local desiredVest = self:getDesiredVest()
    if desiredVest ~= 0 then
        self:addArmorPart(desiredVest, "vest")
    end
    self:sendArmor()
end

function PLAYER:giveHelmet()
    self:resetHelmetData()
    local desiredHelmet = self:getDesiredHelmet()
    if desiredHelmet ~= 0 then
        self:addArmorPart(desiredHelmet, "helmet")
    end
    self:sendHelmet()
end

function PLAYER:takeArmorDamage(armorData, dmgInfo)
    armorData.health = math.ceil(armorData.health - dmgInfo:GetDamage() * 0.75)
end

function PLAYER:addArmorPart(id, category)
    GAMEMODE:prepareArmorPiece(self, id, category)
end

function PLAYER:sendArmor()
    net.Start("GC_ARMOR")
    net.WriteTable(self.armor)
    net.Send(self)
end

function PLAYER:sendHelmet()
    net.Start("GC_HELMET")
    net.WriteTable(self.helmet)
    net.Send(self)
end

function PLAYER:sendArmorPiece(index, health, category)
    net.Start("GC_ARMOR_PIECE")
    net.WriteInt(index, 32)
    net.WriteFloat(health)
    net.WriteString(category)
    net.Send(self)
end