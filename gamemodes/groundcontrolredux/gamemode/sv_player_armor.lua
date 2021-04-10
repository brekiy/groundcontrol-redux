include("sh_player_armor.lua")

local PLAYER = FindMetaTable("Player")

--[[
    This function takes in the bullet damage dealt to the player and calculates the armor
    degredation and health damage that the player takes.
]]--
function PLAYER:processArmorDamage(dmgInfo, penetrationValue, hitGroup, allowBleeding)
    if !penetrationValue then
        return
    end

    local shouldBleed = true
    -- local removeIndex = 1
    for category, armorPiece in pairs(self.armor) do
        local armorData = GAMEMODE:getArmorData(armorPiece.id, category)
        local removeArmor = false
        -- if for some reason we still have health don't do any calcs
        if armorData.protectionAreas[hitGroup] and armorPiece.health > 0 then
            local penetrationDelta = armorData.protection - penetrationValue
            local penetratesArmor = penetrationDelta <= 0
            local damageNegation = nil

            if !penetratesArmor then
                shouldBleed = false
                if hitGroup == HITGROUP_HEAD then self:EmitSound("GC_DINK") end
                damageNegation = armorData.damageDecrease + penetrationDelta * armorData.protectionDelta
                -- Cap health regen at 80% of stopped damage
                local regenAmount = math.floor(dmgInfo:GetDamage() * (1 - damageNegation) * 0.8)
                self:addHealthRegen(regenAmount)
                self:delayHealthRegen()
            else
                --[[
                    New penetration dmg formula:
                    armorData.damageDecreasePenetrated + penetrationDelta * 0.01
                    with this formula, the higher the round's penetrative power, the less the vest will reduce damage after being penetrated.
                    Doesn't matter as much at high dmg mults, since you're going to die fast anyway, but makes a difference on lower ones
                ]]--
                damageNegation = armorData.damageDecreasePenetrated + penetrationDelta * 0.01
                -- damageNegation = armorData.damageDecreasePenetrated
                -- if our armor gets penetrated, it doesn't matter how much health we had in our regen pool, we still start bleeding
                self:resetHealthRegenData()
            end
            -- Clamp ballistic damage reduction between 0-95%
            damageNegation = math.Clamp(damageNegation, 0, 0.95)
            dmgInfo:ScaleDamage(1 - damageNegation)
            --[[
                Armor damage formula: dmg * (1 + (armor - bulletPen) / armor)
                The more a bullet defeats armor, the less damage it does to the material.
                The less a bullet defeats armor, the more damage it does to the material.
                Clamp the factor between 0.75-1.1 and then further scale it by our armor damage factor.
            ]]--
            local armorDamage = dmgInfo:GetDamage() * math.Clamp(1 + (penetrationDelta / armorData.protection), 0.75, 1.1) * GetConVar("gc_armor_damage_factor"):GetFloat()
            self:takeArmorDamage(armorPiece, armorDamage)

            local health = armorPiece.health

            if armorPiece.health <= 0 then
                removeArmor = true
            end

            self:sendArmorHealthUpdate(health, armorData.category)
            if removeArmor then
                self:resetArmorData()
                self:calculateWeight()
            end
        end
        -- removeIndex = removeIndex + 1
    end

    if allowBleeding and shouldBleed then
        self:startBleeding(dmgInfo:GetAttacker())
    end
end

-- Get a player's desired armor piece for a given category, add it to the player armor attribute, and send it to the client
function PLAYER:giveArmor(category, forceArmor)
    self:resetArmorData(category)
    local desiredArmor = nil
    local caseSwitch = {
        ["vest"] = self:getDesiredVest(),
        ["helmet"] = self:getDesiredHelmet()
    }
    if forceArmor then
        desiredArmor = forceArmor
    else
        desiredArmor = caseSwitch[category]
    end
    if desiredArmor != 0 then
        self:addArmorPart(desiredArmor, category)
        self:sendArmor(category)
    end
end

function PLAYER:takeArmorDamage(armorData, dmg)
    armorData.health = armorData.health - math.floor(dmg)
end

function PLAYER:addArmorPart(id, category)
    GAMEMODE:prepareArmorPiece(self, id, category)
end

-- Tell the client to replace a piece of armor with something else
function PLAYER:sendArmor(category)
    net.Start("GC_ARMOR")
    net.WriteTable(self.armor[category])
    net.WriteString(category)
    net.Send(self)
end

-- Tell the client to set a piece of armor to a new health value
function PLAYER:sendArmorHealthUpdate(health, category)
    net.Start("GC_ARMOR_HEALTH_UPDATE")
    net.WriteString(category)
    net.WriteFloat(health)
    net.Send(self)
end
