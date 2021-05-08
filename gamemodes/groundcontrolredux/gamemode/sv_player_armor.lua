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
    for category, armorPiece in pairs(self.armor) do
        local armorData = GAMEMODE:GetArmorData(armorPiece.id, category)
        local removeArmor = false
        -- if for some reason we still have health don't do any calcs
        if armorData.protectionAreas[hitGroup] and armorPiece.health > 0 then
            local penetrationDelta = armorData.protection - penetrationValue
            local penetratesArmor = penetrationDelta <= 0
            local damageNegation = nil

            if !penetratesArmor then
                if hitGroup == HITGROUP_HEAD then self:EmitSound("GC_HELMET_RICOCHET_SOUND") end
                shouldBleed = false
                damageNegation = armorData.damageDecrease + penetrationDelta * armorData.protectionDelta
                -- Cap health regen at 95% of stopped damage
                local regenAmount = math.floor(dmgInfo:GetDamage() * (1 - damageNegation) * 0.95)
                self:AddHealthRegen(regenAmount)
                self:DelayHealthRegen()
            else
                if hitGroup == HITGROUP_HEAD then self:EmitSound("GC_HEADSHOT_SOUND") end
                --[[
                    New penetration dmg formula:
                    armorData.damageDecreasePenetrated + penetrationDelta * 0.01
                    with this formula, the higher the round's penetrative power, the less the vest will reduce damage after being penetrated.
                    Doesn't matter as much at high dmg mults, since you're going to die fast anyway, but makes a difference on lower ones
                ]]--
                damageNegation = armorData.damageDecreasePenetrated + penetrationDelta * 0.01
                -- damageNegation = armorData.damageDecreasePenetrated
                -- if our armor gets penetrated, it doesn't matter how much health we had in our regen pool, we still start bleeding
                self:ResetHealthRegenData()
            end
            -- Clamp ballistic damage reduction between 0-90%
            damageNegation = math.Clamp(damageNegation, 0, 0.9)
            dmgInfo:ScaleDamage(1 - damageNegation)
            --[[
                Armor damage formula: dmg * (1 + (armor - bulletPen) / armor))
                The more a bullet defeats armor, the less damage it does to the material.
                The less a bullet defeats armor, the more damage it does to the material.
                Clamp the penetration delta stuff
                and then further scale it by our armor damage factor.
            ]]--
            local armorDamage = dmgInfo:GetDamage()
                    * (1 + math.Clamp(penetrationDelta / armorData.protection, -0.35, 0.15))
                    * GetConVar("gc_armor_damage_factor"):GetFloat()
            self:TakeArmorDamage(armorPiece, armorDamage)

            local health = armorPiece.health
            if armorPiece.health <= 0 then
                removeArmor = true
            end

            self:SendArmorHealthUpdate(health, armorData.category)
            if removeArmor then
                self:ResetArmorData()
                self:CalculateWeight()
            end
        end
    end

    if allowBleeding and shouldBleed then
        self:startBleeding(dmgInfo:GetAttacker())
    end
end

-- Get a player's desired armor piece for a given category, add it to the player armor attribute, and send it to the client
function PLAYER:GiveGCArmor(category, forceArmor)
    self:ResetArmorData(category)
    local desiredArmor = nil
    local caseSwitch = {
        ["vest"] = self:GetDesiredVest(),
        ["helmet"] = self:GetDesiredHelmet()
    }
    if forceArmor then
        desiredArmor = forceArmor
    else
        desiredArmor = caseSwitch[category]
    end
    if desiredArmor != 0 then
        self:AddArmorPart(desiredArmor, category)
        self:SendArmor(category)
    end
end

function PLAYER:TakeArmorDamage(armorData, dmg)
    armorData.health = armorData.health - math.floor(dmg)
end

function PLAYER:AddArmorPart(id, category)
    GAMEMODE:PrepareArmorPiece(self, id, category)
end

-- Tell the client to replace a piece of armor with something else
function PLAYER:SendArmor(category)
    net.Start("GC_ARMOR")
    net.WriteTable(self.armor[category])
    net.WriteString(category)
    net.Send(self)
end

-- Tell the client to set a piece of armor to a new health value
function PLAYER:SendArmorHealthUpdate(health, category)
    net.Start("GC_ARMOR_HEALTH_UPDATE")
    net.WriteString(category)
    net.WriteFloat(health)
    net.Send(self)
end
