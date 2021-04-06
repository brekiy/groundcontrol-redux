net.Receive("GC_ARMOR", function(a, b)
    local newArmor = net.ReadTable()
    local category = net.ReadString()

    LocalPlayer():resetArmorData(category)
    LocalPlayer():setArmorPiece(newArmor, category)
    -- attachArmorPM(LocalPlayer())
end)

net.Receive("GC_ARMOR_HEALTH_UPDATE", function(a, b)
    LocalPlayer():updateArmorPiece(net.ReadString(), net.ReadFloat())
end)

-- experimental dumb stuff
-- function attachArmorPM(ply)
--     if SERVER then
--         print("starting attach armor")
--         if !IsValid(ply.hat) then
--             print("spawning attach armor")
--             local hat = ents.Create("gc_armor_vest")
--             if !IsValid(hat) then return end

--             hat:SetPos(ply:GetPos() + Vector(0,0,70))
--             hat:SetAngles(ply:GetAngles())

--             hat:SetParent(ply)

--             ply.hat = hat

--             hat:Spawn()
--         end
--     end
-- end

function GM:drawArmor(ply, baseX, baseY)
    local offset = 0
    local spacing = 60
    if ply.armor and !table.IsEmpty(ply.armor) then
        local curTime = CurTime()
        local frameTime = FrameTime()
        local white, black = self.HUDColors.white, self.HUDColors.black
        for key, armorPiece in SortedPairs(ply.armor) do
            local curPos = baseX + offset
            local colorFade = curTime > armorPiece.colorHold

            if armorPiece.red > 0 and colorFade then
                armorPiece.red = math.Approach(armorPiece.red, 0, frameTime * 1000)
            end

            if armorPiece.health <= 0 then
                armorPiece.alpha = math.Approach(armorPiece.alpha, 0, frameTime)
                if armorPiece.alpha == 0 then
                    offset = offset - spacing
                end
            end

            if armorPiece.alpha > 0 then
                white.a, black.a = white.a * armorPiece.alpha, black.a * armorPiece.alpha

                surface.SetDrawColor(255, 255 - armorPiece.red, 255 - armorPiece.red, 255 * armorPiece.alpha)
                surface.SetTexture(armorPiece.armorData.icon)
                surface.DrawTexturedRect(curPos, baseY - 45, 40, 40)

                draw.ShadowText(math.max(armorPiece.health, 0), "CW_HUD14", curPos + spacing * 0.5 - 10, baseY, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            offset = offset + spacing
        end

        white.a, black.a = 255, 255
    end

    return offset
end

local PLAYER = FindMetaTable("Player")
PLAYER._armorFlashTime = 0.3
PLAYER._armorFlashRedAmount = 255

function PLAYER:updateArmorPiece(category, newHealth)
    local armorData = self.armor[category]
    local oldHealth = armorData.health
    armorData.health = newHealth

    if newHealth < oldHealth then
        self:flashArmorPiece(armorData)
    end
    if newHealth <= 0 then
        self:resetArmorData(category)
    end
end

function PLAYER:flashArmorPiece(armorData)
    armorData.red = self._armorFlashRedAmount
    armorData.colorHold = CurTime() + self._armorFlashTime
end

function PLAYER:setupArmorPiece(data, category)
    local armorData = GAMEMODE:getArmorData(data.id, category)
    data.red = 0
    data.colorHold = 0
    data.alpha = 1
    data.armorData = armorData
end