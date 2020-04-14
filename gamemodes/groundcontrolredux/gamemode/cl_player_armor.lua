net.Receive("GC_ARMOR", function(a, b)
    LocalPlayer():resetArmorData()
    LocalPlayer():setArmor(net.ReadTable())
end)

net.Receive("GC_HELMET", function(a, b)
    LocalPlayer():resetHelmetData()
    LocalPlayer():setHelmet(net.ReadTable())
end)

net.Receive("GC_ARMOR_PIECE", function(a, b)
    LocalPlayer():updateArmorPiece(net.ReadInt(32), net.ReadFloat(), net.ReadString())
end)

function GM:drawArmor(ply, baseX, baseY)
    local offset = 0
    local spacing = 60

    if ply.armor or ply.helmet then
        local curTime = CurTime()
        local frameTime = FrameTime()
        local removeIndex = 1
        local white, black = self.HUDColors.white, self.HUDColors.black
        local combinedArmor = ply:getTotalArmorPieces()

        for i = 1, #combinedArmor do
            local curPos = baseX + offset
            
            local data = combinedArmor[removeIndex]
            local colorFade = curTime > data.colorHold
            if data.red > 0 then
                if colorFade then
                    data.red = math.Approach(data.red, 0, frameTime * 1000)
                end
            end
        
            if data.health <= 0 then
                data.alpha = math.Approach(data.alpha, 0, frameTime)
            
                if data.alpha == 0 then
                    table.remove(ply.armor, removeIndex)
                    offset = offset - spacing
                else
                    removeIndex = removeIndex + 1
                end
            else
                removeIndex = removeIndex + 1
            end
            
            if data.alpha > 0 then
                white.a, black.a = white.a * data.alpha, black.a * data.alpha
                
                surface.SetDrawColor(255, 255 - data.red, 255 - data.red, 255 * data.alpha)
                surface.SetTexture(data.armorData.icon)
                surface.DrawTexturedRect(curPos, baseY - 45, 40, 40)
                
                draw.ShadowText(math.max(data.health, 0) .. "%", "CW_HUD14", curPos + spacing * 0.5 - 10, baseY, white, black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

function PLAYER:updateArmorPiece(index, newHealth, category)
    local combinedArmor = self:getTotalArmorPieces()
    local armorData = nil
    -- very hacky lol
    if category == "vest" then 
        armorData = self.armor[1]
    elseif category == "helmet" then
        armorData = self.helmet[1]
    else return
    end
    local oldHealth = armorData.health
    armorData.health = newHealth
    
    if newHealth < oldHealth then
        self:flashArmorPiece(armorData)
    end
end

function PLAYER:updateHelmetPiece(index, newHealth)
    local armorData = self.helmet[index]
    local oldHealth = armorData.health
    armorData.health = newHealth
    
    if newHealth < oldHealth then
        self:flashArmorPiece(armorData)
    end
end

function PLAYER:flashArmorPiece(armorData)
    armorData.red = self._armorFlashRedAmount
    armorData.colorHold = CurTime() + self._armorFlashTime
end

function PLAYER:setupArmorPiece(data)
    local armorData = GAMEMODE:getArmorData(data.id, data.category)
    data.red = 0
    data.colorHold = 0
    data.alpha = 1
    data.armorData = armorData
end