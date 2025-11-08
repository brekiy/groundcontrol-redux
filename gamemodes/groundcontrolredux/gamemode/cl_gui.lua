GM.AllFrames = {}
local PLAYER = FindMetaTable("Player")
CreateClientConVar("gc_pretty_loadout_icons", 1, true, false)
-- this will take effect each map reload
GM.LoadWepModels = GetConVar("gc_pretty_loadout_icons"):GetBool()

function PLAYER:ComplainAboutLoadout(objName)
    chat.AddText(GAMEMODE.HUD_COLORS.limeYellow, "Not enough points for " .. objName .. "!\nGet good and increase your requisition allowance.")
    surface.PlaySound("buttons/combine_button7.wav")
end

function GM:addFrame(frame)
    table.insert(self.AllFrames, frame)
end

function GM:removeFrame(frame)
    for key, value in ipairs(self.AllFrames) do
        if value == frame then
            table.remove(self.AllFrames, key)
            break
        end
    end
end

-- Clamps position to screen size, so that the descbox stays within the screen's boundaries
function GM:ClampVGUIPosition(element)
    local scrW, scrH = ScrW(), ScrH()
    local x, y = element:GetPos()
    local w, h = element:GetSize()
    local newX, newY = nil, nil

    if x + w > scrW then
        newX = scrW - w
    else
        newX = x
    end

    newX = math.max(newX, 0)

    if y + h > scrH then
        newY = scrH - h
    else
        newY = y
    end

    newY = math.max(newY, 0)

    element:SetPos(newX, newY)
end

local gcFrame = {}
gcFrame.alpha = 200
gcFrame.disableOnClose = true

function gcFrame:Init()
    self:SetText("")
    GAMEMODE:addFrame(self)
end

function gcFrame:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    surface.DrawRect(2, 2, w - 4, 20)

    surface.SetDrawColor(0, 0, 0, self.alpha)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

function gcFrame:DisableMouseOnClose(should)
    self.disableOnClose = should
end

function gcFrame:OnRemove()
    if self.disableOnClose then
        GAMEMODE:removeFrame(self)
        GAMEMODE:toggleMouse()
    end

    self:PostRemove()
end

function gcFrame:PostRemove()
end

vgui.Register("GCFrame", gcFrame, "DFrame")

local gcPanel = {}
gcPanel.alpha = 200

function gcPanel:Init()
    self:SetFont("CW_HUD20")
end

function gcPanel:SetFont(font)
    self.font = font
    self.fontHeight = draw.GetFontHeight(font)
end

function gcPanel:SetText(text)
    self.text = text
end

function gcPanel:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    surface.SetDrawColor(0, 0, 0, self.alpha)
    surface.DrawRect(1, 1, w - 2, h - 2)

    surface.DrawRect(2, 2, w - 4, self.fontHeight + 2)
    draw.ShadowText(self.text, self.font, 4, 2, GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function gcPanel:OnRemove()
    self:PostRemove()
end

function gcPanel:PostRemove()
end

vgui.Register("GCPanel", gcPanel, "DPanel")

local gcBaseButton = {}
gcBaseButton.font = "CW_HUD16"
gcBaseButton.text = ""
gcBaseButton.hoverR, gcBaseButton.hoverG, gcBaseButton.hoverB, gcBaseButton.hoverA = GM.HUD_COLORS.brass:Unpack()
gcBaseButton.idleR, gcBaseButton.idleG, gcBaseButton.idleB, gcBaseButton.idleA = 75, 75, 75, 255
gcBaseButton.textColor = Color(255, 255, 255, 255)

function gcBaseButton:Init()
end

function gcBaseButton:SetFont(font)
    self.font = font
end

function gcBaseButton:SetText(text)
    self.text = text
end

function gcBaseButton:SetHoveredColor(r, g, b, a)
    self.hoverR, self.hoverG, self.hoverB, self.hoverA = r, g, b, a
end

function gcBaseButton:SetIdleColor(r, g, b, a)
    self.idleR, self.idleG, self.idleB, self.idleA = r, g, b, a
end

function gcBaseButton:SetTextColor(color)
    self.textColor = color
end

function gcBaseButton:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    local hovered = self:IsHovered()

    if hovered then
        surface.SetDrawColor(self.hoverR, self.hoverG, self.hoverB, self.hoverA)
    else
        surface.SetDrawColor(self.idleR, self.idleG, self.idleB, self.idleA)
    end

    surface.DrawRect(1, 1, w - 2, h - 2)

    local x, y = math.ceil(w * 0.5), math.ceil(h * 0.5)
    draw.ShadowText(self.text, self.font, x, y, self.textColor, GAMEMODE.HUD_COLORS.black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("GCBaseButton", gcBaseButton, "DPanel")

local voiceSelectionButton = {}

function voiceSelectionButton:Init()
end

function voiceSelectionButton:SetVoice(voiceID)
    local voiceData = GAMEMODE.VoiceVariantsById[voiceID]
    self.voiceID = voiceData.numId
    self:SetText(voiceData.display)
end

function voiceSelectionButton:OnMousePressed(a, b, c)
    if IsValid(GAMEMODE.curPanel) then
        GAMEMODE.curPanel:Remove()
        GAMEMODE.curPanel = nil
    end

    RunConsoleCommand("gc_desired_voice", self.voiceID)
end

vgui.Register("GCVoiceSelectionButton", voiceSelectionButton, "GCBaseButton")

local teamSelectionButton = {}

function teamSelectionButton:SetFont(font)
    self.font = font
end

function teamSelectionButton:SetText(text)
    self.baseText = text
end

function teamSelectionButton:SetTeam(teamId)
    self.desiredTeam = teamId
    self.teamData = GAMEMODE.RegisteredTeamData[teamId]
    self.selectionColors = self.teamData.selectionColors

    local start, finish = self.selectionColors[1], self.selectionColors[2]
    self.startColor = Color(start.r, start.g, start.b, 100)
    self.finishColor = Color(finish.r, finish.g, finish.b, 100)
end

teamSelectionButton.BOTTOM_SIZE = 35

function teamSelectionButton:Paint()
    --self.text = self.baseText .. " (" .. #team.GetPlayers(self.desiredTeam) .. " player(s))"

    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)

    local hovered = self:IsHovered()

    if hovered then
        draw.LinearGradient(1, 0, w - 2, h - self.BOTTOM_SIZE - 2, self.startColor, self.finishColor, draw.VERTICAL, w)
    end

    local color = self.teamData.color
    local r, g, b = color.r, color.g, color.b

    if hovered then
        surface.SetDrawColor(Lerp(0.75, r, 255), Lerp(0.75, g, 255), Lerp(0.75, b, 255), 255)
    else
        surface.SetDrawColor(50, 50, 50, 255)
    end

    surface.SetTexture(self.teamData.textureID)
    surface.DrawTexturedRect(5, 4, 512 - 4, 256 - 4)

    draw.LinearGradient(1, h - self.BOTTOM_SIZE - 2, w - 2, self.BOTTOM_SIZE, self.selectionColors[1], self.selectionColors[2], draw.VERTICAL)

    local playerCount = #team.GetPlayers(self.desiredTeam)
    draw.ShadowText(
        string.easyformatbykeys("TEAMNAME - COUNT PLAYERTEXT", "TEAMNAME", self.teamData.teamName,
            "COUNT", playerCount, "PLAYERTEXT", playerCount == 1 and "player" or "players"),
        "CW_HUD28", 5, h - self.BOTTOM_SIZE * 0.5, GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
    )
end

function teamSelectionButton:OnMousePressed(a, b, c)
    if IsValid(GAMEMODE.curPanel) then
        GAMEMODE.curPanel:Remove()
    end

    GAMEMODE:AttemptJoinTeam(LocalPlayer(), self.desiredTeam)
end

vgui.Register("GCTeamSelectionButton", teamSelectionButton, "GCBaseButton")

local gcModelPanel = {}

gcModelPanel.modelReang = {
    ["models/cw2/rifles/w_vss.mdl"] = Angle(0, 180, 0),
    ["models/cw2/pistols/w_makarov.mdl"] = Angle(0, -90, 0),
    ["models/weapons/w_eq_flashbang.mdl"] = Angle(-90, -90, 90),
    ["models/weapons/w_cw_fraggrenade_thrown.mdl"] = Angle(-90, -90, 90),
    ["models/weapons/w_eq_smokegrenade.mdl"] = Angle(-90, -90, 90)
}

gcModelPanel.modelRepos = {
    ["models/weapons/w_pist_deagle.mdl"] = Vector(-6.75, 12, 0),
    ["models/weapons/w_snip_g3sg1.mdl"] = Vector(4, 12, -8),
    ["models/weapons/w_cstm_l96.mdl"] = Vector(-14, 10, 0),
    ["models/cw2/rifles/w_scarh.mdl"] = Vector(-10, 12, -4),
    ["models/weapons/w_cstm_m14.mdl"] = Vector(-12, 14, -3),
    ["models/weapons/w_rif_ak47.mdl"] = Vector(1, 12, -3),
    ["models/weapons/w_rif_m4a1.mdl"] = Vector(1, 12, -3),
    ["models/weapons/w_smg_mp5.mdl"] = Vector(-3, 12, -6),
    ["models/weapons/w_smg_ump45.mdl"] = Vector(-3, 12, -6),
    ["models/weapons/w_cstm_m3super90.mdl"] = Vector(-9, 12, -2),
    ["models/weapons/w_pist_deagle.mdl"] = Vector(-5, 20, -4),
    ["models/weapons/w_357.mdl"] = Vector(-9, 15, 0),
    ["models/cw2/rifles/w_vss.mdl"] = Vector(0, 12, 0),
    ["models/weapons/w_cst_mac11.mdl"] = Vector(-13, 18, -1),
    ["models/weapons/cw_pist_m1911.mdl"] = Vector(-7, 20, 0),
    ["models/weapons/w_pist_p228.mdl"] = Vector(-3, 20, -3),
    ["models/weapons/cw2_0_mach_para.mdl"] = Vector(-9, 6, -2),
    ["models/weapons/w_cw20_l85a2.mdl"] = Vector(-23, 17, -8),
    ["models/cw2/pistols/w_makarov.mdl"] = Vector(-4, 23, -2),
    ["models/weapons/w_pist_fiveseven.mdl"] = Vector(-4, 20, -4),
    ["models/weapons/w_eq_flashbang.mdl"] = Vector(5, 23, -1),
    ["models/weapons/w_cw_fraggrenade_thrown.mdl"] = Vector(3, 23, -1),
    ["models/weapons/w_eq_smokegrenade.mdl"] = Vector(5, 23, -1),
    ["models/weapons/cw2_super_shorty.mdl"] = Vector(-11, 15, -2)}

function gcModelPanel:GetBackgroundColor()
    return 255, 255, 255, 255
end

function gcModelPanel:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(40, 40, 40, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    local r, g, b, a = self:GetBackgroundColor()

    surface.SetDrawColor(r, g, b, a)
    surface.DrawRect(1, 1, w - 2, h - 2)

    if IsValid(self.Entity) and self.Entity.shouldDraw and GAMEMODE.LoadWepModels then
        local x, y = self:LocalToScreen( 0, 0 )

        self:LayoutEntity(self.Entity)

        local ang = self.aLookAngle
        if (!ang) then
            ang = (self.vLookatPos - self.vCamPos):Angle()
        end

        cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)
        cam.IgnoreZ( true )

        render.SuppressEngineLighting(true)
        render.SetLightingOrigin(self.Entity:GetPos())
        render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
        render.SetColorModulation(self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255)
        render.SetBlend((self:GetAlpha() / 255) * (self.colColor.a / 255))

        for i = 0, 6 do
            local col = self.DirectionalLight[i]
            if (col) then
                render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
            end
        end

        self:DrawModel()

        render.SuppressEngineLighting(false)
        cam.IgnoreZ(false)
        cam.End3D()
    end
end

function gcModelPanel:Draw2D(w, h)
end

function gcModelPanel:SetDistance()
    if self.Entity then
        self.Entity.shouldDraw = true

        mdl = self.Entity:GetModel()

        if self.modelReang[mdl] then
            self.Entity:SetAngles(self.modelReang[mdl])
        end

        if self.modelRepos[mdl] then
            self.Entity:SetPos(self.modelRepos[mdl])
        else
            self.Entity:SetPos(Vector(-6, 13.5, -1))
        end

        self:SetCamPos(Vector(0, 35, 0))
        self:SetLookAt(Vector(0, 0, 0))
        self:SetFOV(90)
    end
end

function gcModelPanel:LayoutEntity()
end

vgui.Register("GCModelPanel", gcModelPanel, "DModelPanel")

local gcWeaponPanel = {}
gcWeaponPanel.magIcon = surface.GetTextureID("ground_control/hud/mag")

function gcWeaponPanel:SetWeapon(weaponTable, id)
    self.weaponID = id
    local weaponData = weaponTable[id].weaponObject

    if weaponData then
        -- Too much of a performance hit. Lock it behind a client convar
        if GAMEMODE.LoadWepModels then
            self:SetModel(weaponData.WorldModel)
            self:SetDistance()
        end
        self.IconLetter = weaponData.IconLetter
        if weaponData.SelectIcon then
            self.SelectIcon = weaponData.SelectIcon
        else
            -- See if there's an appropriate icon
            self.SelectIcon = surface.GetTextureID("vgui/inventory/" .. weaponData.ClassName)
        end
    end
end

function gcWeaponPanel:SetConVar(cvar, isPrimary)
    self.ConVar = cvar
    self.isPrimary = isPrimary
end

function gcWeaponPanel:SetDescboxType(type)
    self.descboxType = type
end

function gcWeaponPanel:OnMousePressed(bind)
    local ply = LocalPlayer()
    local imaginaryCost = nil
    local weaponData = GAMEMODE:GetWeaponData(self.weaponID, self.isPrimary)
    if self.isPrimary then
        imaginaryCost = GAMEMODE:GetImaginaryLoadoutCost(ply, weaponData.weaponObject.pointCost)
    elseif self.isPrimary != nil and !self.isPrimary then
        imaginaryCost = GAMEMODE:GetImaginaryLoadoutCost(ply, nil, weaponData.weaponObject.pointCost)
    else
        imaginaryCost = GAMEMODE:GetImaginaryLoadoutCost(ply, nil, nil, weaponData.weaponObject.pointCost)
    end
    local canSelect = imaginaryCost <= ply:GetCurrentLoadoutPoints()
    if bind == MOUSE_LEFT and canSelect then
        GAMEMODE:saveWeaponLoadout(nil, self.isPrimary, self.ConVar)
        GAMEMODE:setCurrentWeaponLoadout(weaponData.weaponObject)
        GAMEMODE:loadWeaponLoadout(weaponData.weaponObject)
        RunConsoleCommand(self.ConVar, self.weaponID)

        if self.isPrimary then
            GAMEMODE.PrimaryWeaponDisplay:UpdateWeapon(self.weaponID)
        elseif self.isPrimary == false then
            GAMEMODE.SecondaryWeaponDisplay:UpdateWeapon(self.weaponID)
        end
    elseif bind == MOUSE_RIGHT then
        RunConsoleCommand(self.ConVar, 0)

        if self.isPrimary then
            GAMEMODE.PrimaryWeaponDisplay:RemoveWeapon()
        elseif self.isPrimary == false then
            GAMEMODE.SecondaryWeaponDisplay:RemoveWeapon()
        end
    end
    if !canSelect then
        ply:ComplainAboutLoadout(weaponData.weaponObject.PrintName)
    end
end

function gcWeaponPanel:GetBackgroundColor()
    if GetConVar(self.ConVar):GetInt() == self.weaponID then
        return GAMEMODE.HUD_COLORS.ecru:Unpack()
    else
        if self:IsHovered() then
            return GAMEMODE.HUD_COLORS.brass:Unpack()
        end
    end

    return 150, 150, 150, 255
end

function gcWeaponPanel:OnCursorEntered()
    local w, h = self:GetSize()
    local x, y = self:LocalToScreen(0, 0)

    if !IsValid(self.weaponStats) then
        if self.descboxType == 1 then
            -- local w, h = self:GetSize()
            self.weaponStats = vgui.Create("GCWeaponStats")
            self.weaponStats:SetSize(250, 185)
            self.weaponStats:SetPos(x + w, y + h)
            self.weaponStats:SetWeapon(self.weaponID, self.isPrimary)
            --self.weaponStats:SetZPos(110)
            self.weaponStats:SetDrawOnTop(true)
            self.weaponStats:SetThoroughDescription(true)
            self.weaponStats:SetBarGap(110)
            self.weaponStats:AdjustBarSizeReduction()
            GAMEMODE:ClampVGUIPosition(self.weaponStats)
        else
            self.weaponStats = vgui.Create("GCGenericDescbox")
            self.weaponStats:SetSize(250, 170)
            self.weaponStats:SetPos(x + w, y + h)
            self.weaponStats:SetDrawOnTop(true)
            local weaponData = GAMEMODE:GetWeaponData(self.weaponID, self.isPrimary)
            for key, entry in ipairs(weaponData.description) do
                self.weaponStats:AddText(entry)
            end
        end
    end
end

function gcWeaponPanel:RemoveWeaponStats()
    if self.weaponStats then
        self.weaponStats:Remove()
        self.weaponStats = nil
    end
end

function gcWeaponPanel:OnCursorExited(w, h)
    self:RemoveWeaponStats()
end

function gcWeaponPanel:PaintOver()
    local w, h = self:GetSize()

    local wepData = GAMEMODE:GetWeaponData(self.weaponID, self.isPrimary)
    if !wepData then return end

    local wepObject = wepData.weaponObject

    cam.IgnoreZ(true)

    if !GAMEMODE.LoadWepModels then
        if self.IconLetter then
            draw.ShadowText(self.IconLetter, "GroundControl_SelectIcons", w * 0.1, h * 0.1, GAMEMODE.HUD_COLORS.white, backColor, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        elseif self.SelectIcon then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetTexture(self.SelectIcon)
            surface.DrawTexturedRect(w * 0.125, h * 0.125, w * 0.75, h * 0.75)
        end
    end

    if !wepData.hideMagIcon then
        surface.SetTexture(self.magIcon)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(w - 16, h - 17, 16, 16)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(w - 17, h - 18, 16, 16)
    end

    cam.IgnoreZ(false)

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    local name = wepObject and wepObject.PrintName or "None selected"
    local ammo = wepObject and wepObject.Primary.Ammo or "None selected"
    local magSize = wepObject and ("x" .. wepObject.Primary.ClipSize) or ""
    local pointCost = wepObject and wepObject.pointCost .. "pts" or ""

    draw.ShadowText(name, "CW_HUD16", 5, 10, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.ShadowText(pointCost, "CW_HUD16", w - 5, 10, White, Black, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    if !wepData.hideMagIcon then
        draw.ShadowText(ammo, "CW_HUD16", 5, h - 10, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.ShadowText(magSize, "CW_HUD16", w - 16, h - 10, White, Black, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

function gcWeaponPanel:Hide()
    self.BaseClass.Hide(self)
    self:RemoveWeaponStats()
end

function gcWeaponPanel:OnRemove()
    if self.weaponStats then
        self.weaponStats:Remove()
        self.weaponStats = nil
    end
end

vgui.Register("GCWeaponPanel", gcWeaponPanel, "GCModelPanel")

GM.ImportantTexture = surface.GetTextureID("ground_control/hud/important")

local curWeaponPanel = {}
curWeaponPanel.randomOffset = 0

function curWeaponPanel:Init()
    self.weaponStats = vgui.Create("GCWeaponStats", self:GetParent())
    self.weaponStats:SetSize(200, 65)
    self.weaponStats:SetPos(0, 0)
    self.availableAttachments = {}
end

function curWeaponPanel:Show()
    self.BaseClass.Show(self)
    self:UpdateAvailableAttachments()
end

function curWeaponPanel:UpdateAvailableAttachments()
    self.availableAttachments = {}

    -- get all these checks out the way
    if !self.weaponData then
        return
    end

    local weaponObject = self.weaponData.weaponObject

    if !weaponObject.Attachments then
        return
    end

    local ply = LocalPlayer()
    local ownedAttachments = ply.ownedAttachments
    local cash = ply.cash or 0

    for categoryID, data in pairs(weaponObject.Attachments) do
        for key, attachmentID in ipairs(data.atts) do
            if CustomizableWeaponry.registeredAttachmentsSKey[attachmentID] then
                local price = CustomizableWeaponry.registeredAttachmentsSKey[attachmentID].price

                if !ownedAttachments[attachmentID] and price and cash >= price then
                    self.availableAttachments[#self.availableAttachments + 1] = attachmentID
                end
            end
        end
    end
end

function curWeaponPanel:setRandomColorOffset(offset)
    self.randomOffset = offset
end

function curWeaponPanel:PaintOver()
    self.BaseClass.PaintOver(self)

    if #self.availableAttachments > 0 then
        cam.IgnoreZ(true)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(5, 25, 16, 16)

            surface.SetTexture(GAMEMODE.ImportantTexture)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(5, 25, 16, 16)
        cam.IgnoreZ(false)
    end
end

function curWeaponPanel:GetBackgroundColor()
    if self:IsHovered() then
        return GAMEMODE.HUD_COLORS.brass:Unpack()
    end

    if #self.availableAttachments > 0 and !self.acknowledged then
        local flash = math.flash(CurTime() + self.randomOffset, 0.6)

        local r = Lerp(flash, 135, 82)
        local g = Lerp(flash, 173, 105)
        local b = Lerp(flash, 229, 140)

        return r, g, b, 255
    end

    return 150, 150, 150, 255
end

function curWeaponPanel:Hide()
    self.BaseClass.Hide(self)
    self:RemoveDescBox()
end

function curWeaponPanel:OnRemove()
    self:RemoveDescBox()
end

function curWeaponPanel:OnCursorEntered()
    local w, h = self:GetSize()

    if !self.descBox and #self.availableAttachments > 0 then
        local x, y = self:LocalToScreen(0, 0)

        self.descBox = vgui.Create("GCGenericDescbox")
        self.descBox:InsertText("You have enough money to buy the following attachments:", "CW_HUD24", 0)

        for key, attID in ipairs(self.availableAttachments) do
            local data = CustomizableWeaponry.registeredAttachmentsSKey[attID]
            local spacing = 2

            if key == #self.availableAttachments then
                spacing = 15
            end

            self.descBox:InsertText(data.displayName .. " ($" .. data.price .. ")", "CW_HUD20", spacing)
        end

        self.descBox:SetPos(x, y + h + 5)
        self.descBox:SetZPos(10000)
        self.descBox:SetDrawOnTop(true)

        self.descBox:InsertText("Click to begin purchase.", "CW_HUD28", 0, GAMEMODE.HUD_COLORS.limeYellow)
        self.acknowledged = true
    end
end

function curWeaponPanel:OnCursorExited(w, h)
    self:RemoveDescBox()
end

function curWeaponPanel:RemoveDescBox()
    if self.descBox then
        self.descBox:Remove()
        self.descBox = nil
    end
end

function curWeaponPanel:SetPos(x, y)
    self.BaseClass.SetPos(self, x, y)
    self:updateStatsPosition()
end

function curWeaponPanel:SetSize(w, h)
    self.BaseClass.SetSize(self, w, h)
    self:updateStatsPosition()
end

function curWeaponPanel:updateStatsPosition()
    local x, y = self:GetPos()
    local w, _ = self:GetSize()

    self.weaponStats:SetPos(x + w + 10, y)
end

function curWeaponPanel:SetConVar(cvar, isPrimary)
    self.ConVar = cvar
    self.isPrimary = isPrimary
    self:UpdateWeapon()
end

function curWeaponPanel:UpdateWeapon(wepId)
    local targetTable = GAMEMODE.PrimaryWeapons

    if !self.isPrimary then
        targetTable = GAMEMODE.SecondaryWeapons
    end

    wepId = wepId or GetConVar(self.ConVar):GetInt()

    if !wepId or wepId == 0 then
        self:RemoveWeapon()
        return
    end

    local targetWeapon = targetTable[wepId]

    -- re-selecting the same weapon
    if targetWeapon == self.weaponData then
        return
    end

    self.weaponData = targetWeapon

    if !self.weaponData then
        return
    end

    self.weaponID = wepId
    if GAMEMODE.LoadWepModels then
        self:SetModel(self.weaponData.weaponObject.WorldModel)
        self:SetDistance()
        self.Entity.shouldDraw = true
    end

    self.IconLetter = self.weaponData.weaponObject.IconLetter
    if self.weaponData.weaponObject.SelectIcon then
        self.SelectIcon = self.weaponData.weaponObject.SelectIcon
    else
        -- See if there's an appropriate icon
        self.SelectIcon = surface.GetTextureID("vgui/inventory/" .. self.weaponData.weaponObject.ClassName)
    end
    self.weaponStats:SetWeapon(self.weaponID, self.isPrimary)
    self.acknowledged = false

    self:UpdateAvailableAttachments()
end

function curWeaponPanel:RemoveWeapon()
    if self.Entity then
        self.Entity.shouldDraw = false
    end

    self.weaponStats:RemoveWeapon()
    self.weaponData = nil
    self.weaponObject = nil
    self.weaponID = nil
    self.acknowledged = true
    self.IconLetter = nil
    self.SelectIcon = nil
    self:UpdateAvailableAttachments()
end

function curWeaponPanel:OnMousePressed(bind)
    if self.weaponData then
        local wepClass = self.weaponData.weaponObject

        if wepClass and table.Count(wepClass.Attachments) > 0 then
            GAMEMODE:setCurrentWeaponLoadout(self.weaponData.weaponObject)
            GAMEMODE:loadWeaponLoadout(self.weaponData.weaponObject)

            GAMEMODE:closeLoadoutMenu()

            local frame = vgui.Create("GCFrame")
            frame:SetTitle(self.weaponData.weaponObject.PrintName .. " - customization")
            frame:SetDraggable(false, false)
            frame.alpha = 220
            frame:SetZPos(100)
            --frame:SetDrawOnTop(true)

            local curYPos = 30
            local curXPos = 5
            local elementSize = 60
            local elementXGap = 5
            local elementYGap = 30
            local maxWidth = 350

            for category, data in pairs(wepClass.Attachments) do
                curXPos = 5

                local label = vgui.Create("DLabel", frame)
                label:SetText(data.header)
                label:SetPos(5, curYPos - 10)
                label:SetTextColor(GAMEMODE.HUD_COLORS.white)
                label:SetFont("CW_HUD32")
                label:SizeToContents()

                for key, attName in ipairs(data.atts) do
                    local attachmentOption = vgui.Create("GCAttachmentSelection", frame)
                    attachmentOption:SetPos(curXPos, 20 + curYPos)
                    attachmentOption:SetAttachment(attName, self.weaponData, self.isPrimary)
                    attachmentOption:SetSize(elementSize, elementSize)
                    attachmentOption:SetCategory(category)

                    curXPos = curXPos + elementSize + elementXGap
                end

                maxWidth = math.max(maxWidth, curXPos)
                curYPos = curYPos + elementSize + elementYGap
            end

            frame:SetSize(maxWidth, curYPos)
            frame:Center()

            frame.PostRemove = function(selfie)
                GAMEMODE:toggleLoadoutMenu()
            end

            local cashDisplay = vgui.Create("GCCashDisplay", frame)
            cashDisplay:SetPos(maxWidth - 200, 25)
            cashDisplay:SetSize(200, 30)
        end
    end
end

vgui.Register("GCCurWeaponPanel", curWeaponPanel, "GCWeaponPanel")

local weaponStats = {}
weaponStats.barGap = 70
weaponStats.barSizeReduction = 40

function weaponStats:Init()
    self.largestTextSize = 0
end

function weaponStats:SetWeapon(id, isPrimary)
    if !id then
        self:RemoveWeapon()
        return
    end
    self.isPrimary = isPrimary
    self.weaponID = id
    self.weaponObject = GAMEMODE:GetWeaponData(self.weaponID, self.isPrimary).weaponObject

    local targetTable = nil

    if self.weaponObject.isPrimaryWeapon then
        targetTable = BestPrimaryWeapons
    else
        targetTable = BestSecondaryWeapons
    end

    self.displayRecoil = self.weaponObject.GCRecoil
    self.displaySpread = self.weaponObject.AimSpread
    self.displayFireDelay = self.weaponObject.FireDelay
    self.displayDamage = self.weaponObject.Damage
    self.displayShots = self.weaponObject.Shots

    self.bestWeaponTable = targetTable
end

function weaponStats:RemoveWeapon()
    self.displayRecoil = 0
    self.displaySpread = 0
    self.displayFireDelay = 0
    self.displayDamage = 0
    self.displayShots = 0

    self.weaponObject = nil
end

function weaponStats:SetThoroughDescription(should)
    self.thoroughDescription = should
end

function weaponStats:SetBarGap(gap)
    self.barGap = gap
end

function weaponStats:SetBarSizeReduction(size)
    self.barSizeReduction = size
end

function weaponStats:AdjustBarSizeReduction()
    self:getLargestTextSize(math.Round(self.weaponObject.weight, 2) .. "KG")
    self:getLargestTextSize(math.Round(self.weaponObject.magWeight, 2) .. "KG")
    self.barSizeReduction = math.max(self.largestTextSize + 10, 37)
end

function weaponStats:getTextSize(text)
    surface.SetFont("CW_HUD16")
    return surface.GetTextSize(text)
end

function weaponStats:getLargestTextSize(text)
    local x, _ = self:getTextSize(text)
    self.largestTextSize = math.max(self.largestTextSize, x)
end

function weaponStats:Paint()
    local w, h = self:GetSize()
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    surface.SetDrawColor(0, 0, 0, 210)
    surface.DrawRect(1, 1, w - 2, h - 2)

    local wepClass = self.weaponObject
    local targetTable = self.bestWeaponTable

    if wepClass then
        self:DrawStatBar("Damage", math.Round(self.displayDamage * GetConVar("gc_damage_multiplier"):GetFloat()) .. "x" .. self.displayShots, self.displayDamage * self.displayShots, targetTable.damage, 10, w)
        self:DrawStatBar("Recoil", "x" .. math.Round(self.displayRecoil, 1), self.displayRecoil, targetTable.recoil, 25, w)
        self:DrawStatBar("Accuracy", math.Round(100 - self.displaySpread * 1000) .. "%", targetTable.aimSpread, self.displaySpread, 40, w)
        self:DrawStatBar("Firerate", math.Round(60 / self.displayFireDelay), targetTable.firerate, self.displayFireDelay, 55, w)
    end

    if self.thoroughDescription then
        self:DrawStatBar("Hip accuracy", 100 - math.Round(wepClass.HipSpread * 1000) .. "%", targetTable.hipSpread, wepClass.HipSpread, 70, w)
        self:DrawStatBar("Mobility", math.Round(100 - wepClass.VelocitySensitivity / 3 * 100) .. "%", targetTable.velocitySensitivity, wepClass.VelocitySensitivity, 85, w)
        self:DrawStatBar("Spread per shot", math.Round(wepClass.SpreadPerShot * 1000, 1) .. "%", wepClass.SpreadPerShot, targetTable.spreadPerShot, 100, w)
        self:DrawStatBar("Max spread", math.Round(wepClass.MaxSpreadInc * 1000, 1) .. "%", wepClass.MaxSpreadInc, targetTable.maxSpreadInc, 115, w)
        self:DrawStatBar("Movement speed", GetConVar("gc_base_run_speed"):GetInt() - wepClass.SpeedDec, targetTable.speedDec, wepClass.SpeedDec, 130, w)
        self:DrawStatBar("Weapon weight", math.Round(wepClass.weight, 2) .. "KG", wepClass.weight, targetTable.weight, 145, w)
        self:DrawStatBar("Mag weight", math.Round(wepClass.magWeight, 2) .. "KG", wepClass.magWeight, targetTable.magWeight, 160, w)
        self:DrawStatBar("Penetration", GAMEMODE:GetAmmoPen(wepClass.Primary.Ammo, wepClass.penMod), GAMEMODE:GetAmmoPen(wepClass.Primary.Ammo, wepClass.penMod), targetTable.penetrationValue, 175, w)
    end
end

function weaponStats:DrawStatBar(baseText, postBarText, barVar1, barVar2, y, w)
    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    draw.ShadowText(baseText, "CW_HUD16", 5, y, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    local barPos = self.barGap
    local barSize = w - self.barGap - self.barSizeReduction

    self:DrawBaseBar(barPos, y - 6, barSize, 12, barVar1, barVar2)

    draw.ShadowText(postBarText, "CW_HUD16", barPos + barSize + 5, y, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function weaponStats:DrawBaseBar(x, y, w, h, min, max)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(x, y, w, h)

    surface.SetDrawColor(40, 40, 40, 255)
    surface.DrawRect(x + 1, y + 1, w - 2, h - 2)

    self:DrawFill(x + 2, y + 2, w - 4, h - 4, min, max)
end

function weaponStats:DrawFill(x, y, w, h, min, max)
    local percentage = math.min(min / max, 1)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(x, y, w * percentage, h)
end

vgui.Register("GCWeaponStats", weaponStats, "DPanel")

local weightBar = {}

function weightBar:Init()
end

function weightBar:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    surface.SetDrawColor(50, 50, 50, 255)
    surface.DrawRect(1, 1, w - 2, h - 2)

    local ply = LocalPlayer()
    local curWeight = GAMEMODE:CalculateImaginaryWeight(ply)
    local weightPercentage = math.min(1, curWeight / GAMEMODE.MAX_WEIGHT)

    surface.SetDrawColor(213, 213, 213, 255)
    surface.DrawRect(2, 2, (w - 4) * weightPercentage, h - 4)

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    draw.ShadowText("Stamina drain: +" .. math.Round((ply:GetStaminaDrainWeightModifier(curWeight) - 1) * 100, 1) .. "%", "CW_HUD16", 5, h * 0.5 - 1, GAMEMODE.HUD_COLORS.lightRed, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.ShadowText("Noise factor: +" .. math.Round(ply:GetWeightFootstepNoiseAffector(curWeight), 1), "CW_HUD16", w - 5, h * 0.5 - 1, GAMEMODE.HUD_COLORS.lightRed, Black, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    draw.ShadowText("Weight: " .. math.Round(curWeight, 2) .. "/" .. GAMEMODE.MAX_WEIGHT .. "KG", "CW_HUD16", w * 0.5, h * 0.5 - 1, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function weightBar:OnCursorEntered()
    if !IsValid(self.descBox) then
        local _, h = self:GetSize()
        local x, y = self:LocalToScreen(0, 0)
        self.descBox = vgui.Create("GCGenericDescbox")
        self.descBox:InsertText("The weight of your current loadout.", "CW_HUD28", 0)
        self.descBox:InsertText("A high weight will increase movement noise and stamina drain from sprinting and jumping.", "CW_HUD20", 0)
        self.descBox:InsertText("You can always deselect primary/secondary/tertiary weapons by right-clicking on them.", "CW_HUD20", 0)

        self.descBox:SetPos(x, y + h + 5)
        self.descBox:SetZPos(10000)
        self.descBox:SetDrawOnTop(true)
    end
end

function weightBar:OnCursorExited(w, h)
    self:RemoveDescBox()
end

function weightBar:RemoveDescBox()
    if self.descBox then
        self.descBox:Remove()
        self.descBox = nil
    end
end

function weightBar:OnRemove()
    self:RemoveDescBox()
end

vgui.Register("GCWeightBar", weightBar, "DPanel")

local attachmentSelection = {}

function attachmentSelection:Init()

end

function attachmentSelection:CanAttachSpecificAttachmnent(attachmentName)
    attachmentName = attachmentName or self.attachmentName
    if CustomizableWeaponry.registeredAttachmentsSKey[attachmentName] then
        local targetTable = nil

        if self.isPrimary then
            targetTable = GAMEMODE.ImaginaryPrimaryAttachments
        else
            targetTable = GAMEMODE.ImaginarySecondaryAttachments
        end

        local can, result, data = self.weaponData.processedWeaponObject:canAttachSpecificAttachment(attachmentName, LocalPlayer(), nil, targetTable, LocalPlayer().ownedAttachments)

        if !can then
            return false, result, data
        end

        return true
    end
end

function attachmentSelection:GetBackgroundColor()
    if self.isLocked then
        return 255, 104, 104, 255
    end

    if !self:CanAttachSpecificAttachmnent() then
        return 255, 255, 125, 255
    end

    local cvarTable = self.isPrimary and GAMEMODE.PrimaryAttachmentStrings or GAMEMODE.SecondaryAttachmentStrings

    -- since we can select attachments in whatever way we wish, we need to iterate over all attachment cvars and check what their values are
    for key, cvarString in ipairs(cvarTable) do
        local attValue = GetConVar(cvarString):GetString()

        if attValue == self.attachmentName then
            return GAMEMODE.HUD_COLORS.ecru:Unpack()
        end
    end

    if self:IsHovered() then
        return GAMEMODE.HUD_COLORS.brass:Unpack()
    end

    return 0, 0, 0, 200
end

function attachmentSelection:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    self.isLocked = self:IsLocked()

    surface.SetDrawColor(self:GetBackgroundColor())
    surface.DrawRect(1, 1, w - 2, h - 2)

    cam.IgnoreZ(true)
        if self.isLocked then
            surface.SetDrawColor(100, 100, 100, 255)
        else
            surface.SetDrawColor(255, 255, 255, 255)
        end
        if !self.icon then
            surface.SetTexture(9)
        else
            surface.SetTexture(self.icon)
        end
        surface.DrawTexturedRect(1, 1, w - 2, h - 2)
    cam.IgnoreZ(false)

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
    draw.ShadowText(self.displayText, "CW_HUD16", 3, 8, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    if self.isLocked then
        draw.ShadowText("$" .. self.attachmentData.price, "CW_HUD16", 3, h - 10, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if self:IsHovered() then
        self:createInfoBox()
    else
        self:RemoveDescBox()
    end
end

function attachmentSelection:createInfoBox()
    if self.attachmentData and !IsValid(self.descBox) then
        local w, h = self:GetSize()
        local x, y = self:LocalToScreen(0, 0)
        self.descBox = vgui.Create("GCGenericDescbox")
        self.descBox:InsertText(self.attachmentData.displayName, "CW_HUD28", 0)
        self.descBox:SetDrawOnTop(true)

        if self:IsLocked() then
            self.descBox:InsertText("Click to purchase for " .. self.attachmentData.price .. "$", "CW_HUD20", 10)
        else
            if !self:IsAttachmentUsed(self.attachmentName) then
                local can, result, data = self:CanAttachSpecificAttachmnent()

                if !can then
                    if result == -4 or result == -6 then -- missing attachment
                        local baseText = "Can't attach, requires: "

                        if data then
                            if result == -4 then
                                for key, attName in ipairs(data) do
                                    baseText = baseText .. CustomizableWeaponry.registeredAttachmentsSKey[attName].displayNameShort

                                    if key != #data then
                                        baseText = baseText .. "/"
                                    end
                                end
                            else
                                local total = table.Count(data)
                                local cur = 0

                                for attName, etc in pairs(data) do
                                    cur = cur + 1
                                    baseText = baseText .. CustomizableWeaponry.registeredAttachmentsSKey[attName].displayNameShort

                                    if cur != total then
                                        baseText = baseText .. "/"
                                    end
                                end
                            end
                        end

                        self.descBox:InsertText(baseText, "CW_HUD20", 10)
                    elseif result == -3 or result == -5 then -- incompatibility with other attachment
                        if result == -5 then
                            self.descBox:InsertText("Can't attach, conflicts with: " .. CustomizableWeaponry.registeredAttachmentsSKey[data].displayNameShort, "CW_HUD20", 10)
                        end
                    end
                else
                    self.descBox:InsertText("Left-click to assign attachment.", "CW_HUD20", 10)
                end
            else
                self.descBox:InsertText("Right-click to un-assign attachment.", "CW_HUD20", 10)
            end
        end

        self.descBox:SetText(self.attachmentData.description)

        local _, newHeight = self.descBox:GetSize()

        if y + newHeight + h > ScrH() then -- if we don't have enough space vertically, we align it to bottom
            y = ScrH() - newHeight
        else
            y = y + h
        end

        self.descBox:SetPos(x + w, y)
        self.descBox:SetZPos(101)

        GAMEMODE.activeAttachmentSelectionHover = self
    end
end

function attachmentSelection:recreateInfoBox()
    if IsValid(self.descBox) then
        self.descBox:Remove()
    end

    self:createInfoBox()
end

function attachmentSelection:OnMousePressed(bind)
    if self:IsLocked() then
        RunConsoleCommand("gc_buy_attachment", self.attachmentName)
    else
        local attSlot = self:IsAttachmentUsed(self.attachmentName)

        if attSlot then
            if bind == 108 then
                RunConsoleCommand(attSlot, "")

                local isPrimary = self.isPrimary

                timer.Simple(0, function()
                    GAMEMODE:BuildImaginaryAttachments(self.isPrimary)
                    GAMEMODE:saveWeaponLoadout(nil, isPrimary, isPrimary and "gc_primary_weapon" or "gc_secondary_weapon")
                    self:RemoveDescBox()
                end)
            end
        else
            if self:CanAttachSpecificAttachmnent() then
                self:OpenAttachmentAssignmentMenu()
                self:RemoveDescBox()
            end
        end
    end
end

function attachmentSelection:IsLocked()
    return !LocalPlayer().ownedAttachments[self.attachmentName] and self.attachmentData and self.attachmentData.price
end

function attachmentSelection:OpenAttachmentAssignmentMenu()
    local cvarNames = self.isPrimary and GAMEMODE.PrimaryAttachmentStrings or GAMEMODE.SecondaryAttachmentStrings
    self:GetParent():Hide()

    local slotFrame = vgui.Create("GCFrame")
    slotFrame:SetTitle("Assign attachment")
    slotFrame:SetSize(100, 100)
    slotFrame:SetDraggable(false, false)
    slotFrame.PostRemove = function(selfie)
        self:GetParent():Show()
    end

    slotFrame:SetZPos(100)
    --slotFrame:SetDrawOnTop(true)

    local height = 110
    local maxW = 250
    local curW = 0
    local elementSize = 90
    local gapSize = 5

    for key, cvarName in ipairs(cvarNames) do
        local assignSlot = vgui.Create("GCAttachmentAssignment", slotFrame)
        assignSlot:SetConVar(cvarName)
        assignSlot:SetSlot(key)
        assignSlot:SetPos(5 + curW, 30)
        assignSlot:SetDesiredAttachment(self.attachmentName, self.weaponData)
        assignSlot:SetSize(80, 105)
        assignSlot:SetIconSize(80)
        assignSlot:SetCategory(self.category)
        assignSlot:SetZPos(100)
        assignSlot:SetSlotID(key)

        curW = curW + 80 + gapSize
        maxW = math.max(maxW, curW)
    end

    local expBar = vgui.Create("GCExperienceBar", slotFrame)
    expBar:SetPos(5, 140)
    expBar:SetSize(maxW - gapSize, 40)

    slotFrame:SetSize(maxW + gapSize, 185)
    slotFrame:Center()
end

function attachmentSelection:SetAttachment(attName, weaponData, isPrimary)
    self.attachmentName = attName
    self.attachmentData = CustomizableWeaponry.registeredAttachmentsSKey[attName]
    self.weaponData = weaponData

    if isPrimary != nil then
        self.isPrimary = isPrimary
    end

    self:UpdateDisplay()
    self:RemoveDescBox()
end

function attachmentSelection:UpdateDisplay()
    if self.attachmentData then
        self.icon = self.attachmentData.displayIcon
        self.displayText = self.attachmentData.displayNameShort
    else
        self.icon = nil
        self.displayText = "None"
    end
end

function attachmentSelection:RemoveDescBox()
    if self.descBox then
        self.descBox:Remove()
        self.descBox = nil
    end
end

function attachmentSelection:OnRemove()
    self:RemoveDescBox()
end

function attachmentSelection:IsAttachmentUsed(attName)
    local desiredCvars = nil

    if self.isPrimary then
        desiredCvars = GAMEMODE.PrimaryAttachmentStrings
    else
        desiredCvars = GAMEMODE.SecondaryAttachmentStrings
    end

    for key, value in ipairs(desiredCvars) do
        if GetConVar(value):GetString() == attName then -- if we already have this attachment assigned, don't do anything
            return value
        end
    end

    return false
end

function attachmentSelection:IsCategoryUsed(category)
    local desiredCvars = nil

    if self.isPrimary then
        desiredCvars = GAMEMODE.PrimaryAttachmentStrings
    else
        desiredCvars = GAMEMODE.SecondaryAttachmentStrings
    end

    for key, cvarName in ipairs(desiredCvars) do
        local slotAttachment = GetConVar(cvarName):GetString()

        for attKey, value in pairs(self.weaponData.weaponObject.Attachments[category].atts) do
            if value == slotAttachment then
                return cvarName
            end
        end
    end

    return false
end

function attachmentSelection:SetCategory(category)
    self.category = category
end

vgui.Register("GCAttachmentSelection", attachmentSelection, "DPanel")

local attachmentAssignment = {}
attachmentAssignment.iconSize = 70

function attachmentAssignment:Init()

end

function attachmentAssignment:SetConVar(cvar)
    self.cvarName = cvar

    self:SetAttachment(GetConVar(self.cvarName):GetString())
end

function attachmentAssignment:SetSlotID(id)
    self.slotId = id
end

function attachmentAssignment:SetDesiredAttachment(attName, weaponData)
    self.desiredAttachment = attName
    self.weaponData = weaponData
    self.isPrimary = weaponData.weaponObject.isPrimaryWeapon
end

function attachmentAssignment:SetSlot(slot)
    self.slot = slot
    self.slotString = "Slot " .. slot
end

function attachmentAssignment:SetIconSize(size)
    self.iconSize = size
end

function attachmentAssignment:CanAssignToSlot(attachmentName)
    attachmentName = attachmentName or self.desiredAttachment

    if !self:IsSlotUnlocked() then
        return false
    end

    local usedAtt = self:IsAttachmentUsed(self.desiredAttachment)

    if usedAtt then
        return false
    end

    if !self:IsCategoryValid() then
        return false
    end

    return true
end

function attachmentAssignment:IsCategoryValid()
    if !self.weaponData then
        return true
    end

    local slotCategory = self:IsCategoryUsed(self.category)

    if slotCategory and self.cvarName != slotCategory then
        return false
    end

    return true
end

function attachmentAssignment:OnMousePressed(bind)
    if bind == 107 then
        -- local desiredCvars = nil

        if self:CanAssignToSlot(self.desiredAttachment) then
            RunConsoleCommand(self.cvarName, self.desiredAttachment)

            local isPrimary = self.isPrimary
            self:GetParent():Remove()

            timer.Simple(0, function()
                GAMEMODE:BuildImaginaryAttachments(isPrimary)
                GAMEMODE:saveWeaponLoadout(nil, isPrimary, isPrimary and "gc_primary_weapon" or "gc_secondary_weapon")
            end)
        end
    else
        self.category = nil
        RunConsoleCommand(self.cvarName, "")
        self:SetAttachment(self.cvarName)

        local isPrimary = self.isPrimary

        timer.Simple(0, function()
            GAMEMODE:BuildImaginaryAttachments(isPrimary)
            GAMEMODE:saveWeaponLoadout(nil, isPrimary, isPrimary and "gc_primary_weapon" or "gc_secondary_weapon")
        end)
    end
end

function attachmentAssignment:IsSlotUnlocked()
    return LocalPlayer():isAttachmentSlotUnlocked(self.slotId - GAMEMODE.LockedAttachmentSlots)
end

function attachmentAssignment:GetBackgroundColor()
    if !self:IsSlotUnlocked() then
        return GAMEMODE.HUD_COLORS.bittersweet:Unpack()
    end

    if self:IsHovered() then
        return GAMEMODE.HUD_COLORS.brass:Unpack()
    end

    return 0, 0, 0, 200
end

function attachmentAssignment:OnRemove()
    self:RemoveDescBox()
end

function attachmentAssignment:Paint()
    local w, h = self:GetSize()

    self.validCategory = self:IsCategoryValid()

    surface.SetDrawColor(0, 20, 0, 255)
    surface.DrawOutlinedRect(0, 20, self.iconSize, self.iconSize)

    surface.SetDrawColor(self:GetBackgroundColor())
    surface.DrawRect(1, 21, self.iconSize - 2, self.iconSize - 2)

    if self.icon then
        cam.IgnoreZ(true)
            if self.isLocked then
                surface.SetDrawColor(100, 100, 100, 255)
            elseif !self.validCategory then
                surface.SetDrawColor(50, 50, 50, 255)
            else
                if self.validCategory then
                    surface.SetDrawColor(GAMEMODE.HUD_COLORS.brass:Unpack())
                else
                    surface.SetDrawColor(255, 255, 255, 255)
                end
            end

            surface.SetTexture(self.icon)
            surface.DrawTexturedRect(1, 21, self.iconSize - 2, self.iconSize - 2)
        cam.IgnoreZ(false)
    end

    if self:IsHovered() then
        if !self.descBox then
            local x, y = self:LocalToScreen(0, 0)
            self.descBox = vgui.Create("GCGenericDescbox")
            self.descBox:SetDrawOnTop(true)

            if !self:IsSlotUnlocked() then
                self.descBox:InsertText("Slot locked, can't assign to it.", "CW_HUD28", 0)
            else
                if self.attachmentData then
                    self.descBox:InsertText(self.attachmentData.displayName, "CW_HUD28", 0)

                    if !self:CanAssignToSlot() then
                        self.descBox:InsertText("Can't assign to this slot - desired category already in use.", "CW_HUD20", 0)
                    else
                        self.descBox:InsertText("Left-click to re-assign slot.", "CW_HUD20", 0)
                    end

                    self.descBox:InsertText("Right-click to un-assign slot.", "CW_HUD20", 10)
                    self.descBox:SetText(self.attachmentData.description)
                else
                    if !self:CanAssignToSlot() then
                        self.descBox:InsertText("Can't assign to this slot - desired category already in use.", "CW_HUD20", 0)
                    else
                        self.descBox:InsertText("Left-click to assign slot.", "CW_HUD20", 0)

                        -- if self.attachmentData then
                        --     self.descBox:SetText(self.attachmentData.description)
                        -- end
                    end
                end
            end

            self.descBox:UpdateSize()

            self.descBox:SetPos(x + w, y + h)
            self.descBox:SetZPos(101)
        end
    else
        self:RemoveDescBox()
    end

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
    draw.ShadowText(self.displayText, "CW_HUD16", 3, 30, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.ShadowText(self.slotString, "CW_HUD20", 3, 10, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("GCAttachmentAssignment", attachmentAssignment, "GCAttachmentSelection")

local loadoutPoints = {}

function loadoutPoints:Init()
end

function loadoutPoints:Paint()
    local w, h = self:GetSize()

    local ply = LocalPlayer()
    local curCost = GAMEMODE:GetImaginaryLoadoutCost(ply)

    surface.SetDrawColor(100, 213, 100, 255)

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    draw.ShadowText("Loadout cost: " .. curCost .. "/" .. ply:GetCurrentLoadoutPoints(), "CW_HUD20", 10, h * 0.5 - 5, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function loadoutPoints:OnCursorEntered()
    if !IsValid(self.descBox) then
        local _, h = self:GetSize()
        local x, y = self:LocalToScreen(0, 0)
        self.descBox = vgui.Create("GCGenericDescbox")
        self.descBox:InsertText("The cost of your current loadout.", "CW_HUD28", 0)
        self.descBox:InsertText("Your weapons and gear are not free.", "CW_HUD20", 0)
        self.descBox:InsertText("The better you perform, the more your kit can cost.", "CW_HUD20", 0)

        self.descBox:SetPos(x, y + h + 5)
        self.descBox:SetZPos(10000)
        self.descBox:SetDrawOnTop(true)
    end
end

function loadoutPoints:OnCursorExited(w, h)
    self:RemoveDescBox()
end

function loadoutPoints:RemoveDescBox()
    if self.descBox then
        self.descBox:Remove()
        self.descBox = nil
    end
end

function loadoutPoints:OnRemove()
    self:RemoveDescBox()
end

vgui.Register("GCLoadoutCost", loadoutPoints, "DPanel")

local genericDescbox = {}
genericDescbox.font = "CW_HUD20"
genericDescbox.alpha = 220

function genericDescbox:Init()
    self.allText = {}
    self.highest = 0
    self.widest = 0
end

function genericDescbox:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    surface.SetDrawColor(0, 0, 0, self.alpha)
    surface.DrawRect(1, 1, w - 2, h - 2)

    local Black = GAMEMODE.HUD_COLORS.black

    for key, textEntry in ipairs(self.allText) do
        draw.ShadowText(textEntry.t, textEntry.font, 5, textEntry.y + 5, textEntry.c, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

function genericDescbox:SetFont(font)
    self.font = font
end

function genericDescbox:AddText(textEntry)
    local newText = {
        t = textEntry.t or textEntry.text,
        c = textEntry.c or textEntry.color,
        font = textEntry.font or self.font,
        y = textEntry.y or self.highest
    }

    if textEntry.formatFunc then
        newText.t = textEntry.formatFunc(newText.t)
    end

    table.insert(self.allText, newText)

    surface.SetFont(newText.font)
    local w, h = surface.GetTextSize(textEntry.t)

    self.highest = self.highest + h + (textEntry.offset or 0)
    self.widest = math.max(self.widest, w)

    self:UpdateSize()

    return w, h
end

function genericDescbox:InsertText(text, font, offset, color)
    color = color or GAMEMODE.HUD_COLORS.white
    self:AddText({t = text, c = color, font = font or "CW_HUD20", offset = offset or 10})
end

function genericDescbox:SetText(text)
    for key, value in ipairs(text) do
        self:AddText(value)
    end

    GAMEMODE:ClampVGUIPosition(self)
end

function genericDescbox:UpdateSize()
    self:SetSize(self.widest + 10, self.highest + 10)
end

function genericDescbox:PositionBelow(element)
    local x, y = element:LocalToScreen(0, 0)
    local w, h = element:GetSize()
    self:SetPos(x + w, y + h)
end

vgui.Register("GCGenericDescbox", genericDescbox, "Panel")

local roundOver = {}
roundOver.bottomText = "Starting a new round in "
roundOver.font = "CW_HUD24"

function roundOver:Init()
    self.alpha = 0
    self.existTime = 0

    if IsValid(GAMEMODE.lastPopup) then
        GAMEMODE.lastPopup:Remove()
    end
end

function roundOver:SetWinningTeam(winTeam)
    self.winningTeam = winTeam
    self.winningTeamName = team.GetName(winTeam) .. " has won the round!"
    self:stretchToText(self.winningTeamName)
end

function roundOver:SetTopText(text)
    self.winningTeamName = text
    self:stretchToText(self.winningTeamName)
end

function roundOver:SetBottomText(text)
    self.bottomText = text
    self:stretchToText(self:GetFinalBottomText())
end

function roundOver:GetFinalBottomText()
    return self.bottomText .. math.ceil(self.existTime + 1 - CurTime()) .. " second(s)"
end

function roundOver:SetRestartTime(time)
    self.existTime = CurTime() + time - 1
end

function roundOver:Paint()
    if CurTime() > self.existTime then
        self.alpha = math.Approach(self.alpha, 0, FrameTime() * 8)

        if self.alpha == 0 then
            self:Remove()
            return
        end
    else
        self.alpha = math.Approach(self.alpha, 1, FrameTime() * 5)
    end

    local w, h = self:GetSize()

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
    White.a = 255 * self.alpha
    Black.a = 255 * self.alpha

    surface.SetDrawColor(0, 0, 0, 150 * self.alpha)
    surface.DrawRect(0, 0, w, h)

    draw.ShadowText(self.winningTeamName, "CW_HUD24", w * 0.5, 12, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText(self:GetFinalBottomText(), "CW_HUD24", w * 0.5, h - 12, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    White.a = 255
    Black.a = 255
end

vgui.Register("GCRoundOver", roundOver, "GCGenericPopup")

local roundPrepare = {}

function roundPrepare:Init()
    self.alpha = 0
    self.existTime = 0
end

function roundPrepare:SetPrepareTime(time)
    self.existTime = CurTime() + time - 1
end

function roundPrepare:Paint()
    if CurTime() > self.existTime then
        self.alpha = math.Approach(self.alpha, 0, FrameTime() * 8)

        if self.alpha == 0 then
            self:Remove()
            return
        end
    else
        self.alpha = math.Approach(self.alpha, 1, FrameTime() * 5)
    end

    local w, h = self:GetSize()

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
    White.a = 255 * self.alpha
    Black.a = 255 * self.alpha

    surface.SetDrawColor(0, 0, 0, 150 * self.alpha)
    surface.DrawRect(0, 0, w, h)

    draw.ShadowText("Prepare for new round", "CW_HUD24", w * 0.5, 12, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText("Round starts in " .. math.ceil(self.existTime + 1 - CurTime()) .. " second(s)", "CW_HUD24", w * 0.5, h - 12, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    White.a = 255
    Black.a = 255
end

vgui.Register("GCRoundPreparation", roundPrepare, "Panel")

local gcNumberWang = {}

function gcNumberWang:Init()
end

function gcNumberWang:CanChangeValue()
    return true
end

function gcNumberWang:SetConVar(cvar)
    self.cvar = cvar
    self:SetValue(GetConVar(self.cvar):GetInt())
end

function gcNumberWang:OnValueChanged(ind, val)
    if self.cvar and self:CanChangeValue() then
        RunConsoleCommand(self.cvar, ind)
    end
end

function gcNumberWang:OnEnter()
    local finalBandage = math.Clamp(tonumber(self:GetValue() or 0), self:GetMin(), self:GetMax())
    RunConsoleCommand(self.cvar, finalBandage)

    self:SetValue(finalBandage)
    self:SetText(finalBandage)
end

vgui.Register("GCNumberWang", gcNumberWang, "DNumberWang")

local gcExperienceBar = {}

function gcExperienceBar:Init()
end

function gcExperienceBar:Paint()
    local w, h = self:GetSize()
    local ply = LocalPlayer()
    local canUnlockMore = ply:canUnlockMoreSlots()
    local nextSlotPrice = ply:getNextAttachmentSlotPrice()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, w, 20)

    surface.SetDrawColor(40, 40, 40, 255)
    surface.DrawRect(2, 2, w - 4, 16)

    local progress = 0

    if canUnlockMore then
        progress = ply.experience / nextSlotPrice
    else
        progress = 1
    end

    surface.SetDrawColor(216, 255, 225, 255)
    surface.DrawRect(3, 3, (w - 6) * progress, 14)

    local expDisplay, helperText = nil, nil

    if !canUnlockMore then
        expDisplay = ply:getNextAttachmentSlotPrice(GAMEMODE.LockedAttachmentSlots)
        nextSlotPrice = expDisplay
        helperText = "All locked slots unlocked."
    else
        expDisplay = ply.experience
        helperText = "Unlock more slots by playing cooperatively."
    end

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
    draw.ShadowText(expDisplay .. "/" .. nextSlotPrice .. " EXP", "CW_HUD16", w * 0.5, 9, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText(helperText, "CW_HUD20", w * 0.5, h - 10, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("GCExperienceBar", gcExperienceBar, "DPanel")

local gcCashDisplay = {}
gcCashDisplay.maxDisplayCash = 100000

function gcCashDisplay:Init()
end

function gcCashDisplay:Paint()
    local w, h = self:GetSize()
    local cash = LocalPlayer().cash

    draw.ShadowText("Cash $" .. (cash > self.maxDisplayCash and (self.maxDisplayCash .. "+") or cash), "CW_HUD28", w - 5, h * 0.5, GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

vgui.Register("GCCashDisplay", gcCashDisplay, "DPanel")

local gcArmorDisplay = {}
gcArmorDisplay.min = 0

function gcArmorDisplay:Init()
    self.pos = 1
end

function gcArmorDisplay:SetArmorDisplayed(armorData)
    self.armorData = armorData
end

function gcArmorDisplay:SetCategory(category)
    self.category = category
end

function gcArmorDisplay:SetConVar(cvarName)
    self.cvar = cvarName
    self.pos = GetConVar(self.cvar):GetInt()
    self:SetMax(#GAMEMODE.Armor[self.category])
    self:UpdateArmor()
end

function gcArmorDisplay:UpdateArmor(direction)
    direction = direction or 0
    self.pos = math.Clamp(self.pos + direction, self.min, self.max)
    local canSelect = nil
    local ply = LocalPlayer()
    if self.category == "vest" then
        canSelect = GAMEMODE:GetImaginaryLoadoutCost(LocalPlayer(), nil, nil, nil, GAMEMODE:GetArmorCost("vest", self.pos)) <= ply:GetCurrentLoadoutPoints()
    elseif self.category == "helmet" then
        canSelect = GAMEMODE:GetImaginaryLoadoutCost(LocalPlayer(), nil, nil, nil, nil, GAMEMODE:GetArmorCost("helmet", self.pos)) <= ply:GetCurrentLoadoutPoints()
    end
    if canSelect then
        RunConsoleCommand(self.cvar, self.pos)
    else
        LocalPlayer():ComplainAboutLoadout(GAMEMODE.Armor[self.category][self.pos].displayName)
    end
    self:SetArmorDisplayed(GAMEMODE.Armor[self.category][self.pos])
end

function gcArmorDisplay:SetMin(min)
    self.min = min
end

function gcArmorDisplay:SetMax(max)
    self.max = max
end

function gcArmorDisplay:CreateButtons()
    local x, y = self:GetPos()
    local w, h = self:GetSize()

    local midY = y + h * 0.5
    local parent = self:GetParent()

    local back = vgui.Create("GCArmorSelection", parent)
    back:SetPos(x - 25, midY - 10)
    back:SetSize(20, 20)
    back:SetDisplayParent(self)
    back:SetDirection(-1)

    local forward = vgui.Create("GCArmorSelection", parent)
    forward:SetPos(x + w + 5, midY - 10)
    forward:SetSize(20, 20)
    forward:SetDisplayParent(self)
    forward:SetDirection(1)
end

function gcArmorDisplay:RemoveDescBox()
    if self.descBox then
        self.descBox:Remove()
        self.descBox = nil
    end
end

function gcArmorDisplay:OnRemove()
    self:RemoveDescBox()
end

function gcArmorDisplay:OnCursorEntered()
    if !IsValid(self.descBox) then
        self.descBox = vgui.Create("GCGenericDescbox")
        self.descBox:SetDrawOnTop(true)

        if self.armorData then
            local tempTbl = {}
            for key, value in pairs(table.GetKeys(self.armorData.protectionAreas)) do table.insert(tempTbl, value) end
            table.sort(tempTbl)
            local protectZonesArr = {}
            for key, value in pairs(tempTbl) do
                if value == 1 then table.insert(protectZonesArr, "Head")
                elseif value == 2 then table.insert(protectZonesArr, "Thorax")
                elseif value == 3 then table.insert(protectZonesArr, "Abdomen")
                elseif value == 4 then table.insert(protectZonesArr, "Left Arm")
                elseif value == 5 then table.insert(protectZonesArr, "Right Arm")
                elseif value == 6 then table.insert(protectZonesArr, "Left Leg")
                elseif value == 7 then table.insert(protectZonesArr, "Right Leg")
                else print("got weird hitgroup enum " .. value)
                end
            end
            local protectZones = table.concat(protectZonesArr, ", ")
            self.descBox:InsertText(self.armorData.displayName, "CW_HUD28", 0)
            self.descBox:InsertText(self.armorData.description, "CW_HUD20", 0)
            self.descBox:InsertText("Weight: " .. self.armorData.weight .. "KG", "CW_HUD16", 0)
            self.descBox:InsertText("Max penetration value: " .. self.armorData.protection, "CW_HUD16", 0)
            self.descBox:InsertText("Blunt trauma reduction: " .. math.Round(self.armorData.damageDecrease * 100, 1) .. "%", "CW_HUD16", 0)
            self.descBox:InsertText("Penetrated damage reduction: " .. math.Round(self.armorData.damageDecreasePenetrated * 100, 1) .. "%", "CW_HUD16", 0)
            self.descBox:InsertText("Protected areas: " .. protectZones, "CW_HUD16", 0)
            self.descBox:InsertText("Durability: " .. self.armorData.durability, "CW_HUD16", 0)
        else
            if self.category == "vest" then
                self.descBox:InsertText("No armor vest equipped.", "CW_HUD20", 0)
                self.descBox:InsertText("Bleeding will occur from any shot.", "CW_HUD20", 0)
            elseif self.category == "helmet" then
                self.descBox:InsertText("No helmet equipped.", "CW_HUD20", 0)
                self.descBox:InsertText("Headshots are almost certainly fatal.", "CW_HUD20", 0)
            end
        end

        self.descBox:PositionBelow(self)
    end
end

function gcArmorDisplay:OnCursorExited()
    self:RemoveDescBox()
end

function gcArmorDisplay:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, w, h)

    if self:IsHovered() then
        surface.SetDrawColor(GAMEMODE.HUD_COLORS.ecru:Unpack())
    else
        surface.SetDrawColor(45, 45, 45, 255)
    end

    surface.DrawRect(1, 1, w - 2, h - 2)

    if self.armorData then
        surface.SetTexture(self.armorData.icon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(1, 1, w - 2, h - 2)
        local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
        draw.ShadowText(self.armorData.pointCost .. "pts" or "", "CW_HUD16", w - 5, 10, White, Black, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("GCArmorDisplay", gcArmorDisplay, "DPanel")

local gcArmorSelection = {}
gcArmorSelection.min = 0

function gcArmorSelection:Init()
end

function gcArmorSelection:SetDisplayParent(parent)
    self.displayParent = parent
end

function gcArmorSelection:SetDirection(dir)
    self.direction = dir
end

function gcArmorSelection:OnMousePressed(bind)
    self.displayParent:UpdateArmor(self.direction)
end

function gcArmorSelection:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, w, h)

    if self:IsHovered() then
        surface.SetDrawColor(194, 178, 128, 255)
    else
        surface.SetDrawColor(45, 45, 45, 255)
    end

    surface.DrawRect(1, 1, w - 2, h - 2)

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    if self.direction < 0 then
        draw.ShadowText("<", "CW_HUD20", w * 0.5, 10, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        draw.ShadowText(">", "CW_HUD20", w * 0.5, 10, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("GCArmorSelection", gcArmorSelection, "DPanel")

local gcGenericPopup = {}
gcGenericPopup.alpha = 0
gcGenericPopup.font = "CW_HUD24"

function gcGenericPopup:Init()
    self.alpha = 0
    self.existTime = 0

    if IsValid(GAMEMODE.lastPopup) then
        GAMEMODE.lastPopup:Remove()
    end
end

function gcGenericPopup:SetExistTime(time)
    self.existTime = CurTime() + time
end

function gcGenericPopup:stretchToText(text)
    surface.SetFont(self.font)
    local x, y = surface.GetTextSize(text)
    x = x + 10
    y = y + 10
    local w = self:GetWide()
    local h = self:GetTall()

    if x > w then
        self:SetWide(x)
        self:CenterHorizontal()
    end

    if y > h then
        self:SetTall(y)
        self:CenterVertical()
    end
end

function gcGenericPopup:SetText(top, bottom)
    self.topText = top
    self.bottomText = bottom

    self:stretchToText(self.topText)
    self:stretchToText(self.bottomText)
end

function gcGenericPopup:Paint()
    if CurTime() > self.existTime then
        self.alpha = math.Approach(self.alpha, 0, FrameTime() * 8)

        if self.alpha == 0 then
            self:Remove()
            return
        end
    else
        self.alpha = math.Approach(self.alpha, 1, FrameTime() * 5)
    end

    local w, h = self:GetSize()

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black
    White.a = 255 * self.alpha
    Black.a = 255 * self.alpha

    surface.SetDrawColor(0, 0, 0, 150 * self.alpha)
    surface.DrawRect(0, 0, w, h)

    draw.ShadowText(self.topText, self.font, w * 0.5, 12, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if self.bottomText then
        draw.ShadowText(self.bottomText, self.font, w * 0.5, h - 12, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    White.a = 255
    Black.a = 255
end

vgui.Register("GCGenericPopup", gcGenericPopup, "DPanel")

local gcTraitPanel = {}

function gcTraitPanel:SetConVar(cvar)
    self.convar = cvar
end

function gcTraitPanel:SetTrait(data)
    self.traitData = data
    self.traitTexture = data.textureID
end

function gcTraitPanel:SetTraitID(id)
    self.traitID = id
end

function gcTraitPanel:OnMousePressed(bind)
    local ply = LocalPlayer()

    if !ply:HasTrait(self.traitData.id) then
        RunConsoleCommand("gc_buy_trait", self.traitData.id)
    else
        if bind == 108 then
            RunConsoleCommand("gc_buy_trait", self.traitData.id)
        else
            self:Select()
        end
    end
end

function gcTraitPanel:IsTraitActive()
    return GetConVar(self.convar):GetInt() == self.traitID
end

function gcTraitPanel:Select()
    RunConsoleCommand(self.convar, self.traitID)

    timer.Simple(0, function()
        if self:IsValid() then
            self:OnCursorExited()
            self:OnCursorEntered()
        end
    end)
end

function gcTraitPanel:GetBackgroundColor()
    local ply = LocalPlayer()

    if !ply.traits or !ply.traits[self.traitData.id] then
        return 255, 150, 150, 255
    end

    if self:IsTraitActive() then
        return GAMEMODE.HUD_COLORS.ecru:Unpack()
    else
        if self:IsHovered() then
            return GAMEMODE.HUD_COLORS.brass:Unpack()
        end
    end

    return 150, 150, 150, 255
end

function gcTraitPanel:OnCursorEntered()
    local w, h = self:GetSize()
    local x, y = self:LocalToScreen(0, 0)

    if !IsValid(self.descBox) then
        local ply = LocalPlayer()

        self.descBox = vgui.Create("GCGenericDescbox")
        self.descBox:SetSize(250, 170)
        self.descBox:SetPos(x + w, y + h)
        self.descBox:SetDrawOnTop(true)

        local traitLevel = ply.traits and ply.traits[self.traitData.id] or 0
        local active = self:IsTraitActive()

        if traitLevel > 0 and !active then
            self.descBox:InsertText(self.traitData.display .. " (Inactive)", "CW_HUD28", 0)
            self.descBox:InsertText("This trait is inactive, left-click to activate it.", "CW_HUD20", 0)
        else
            self.descBox:InsertText(self.traitData.display, "CW_HUD28", 0)
        end

        local levelText = "Level: " .. (traitLevel and traitLevel or 0) .. "/" .. self.traitData.maxLevel
        local unlockText = nil

        self.descBox:InsertText(levelText, "CW_HUD24", 10)

        if traitLevel < self.traitData.maxLevel then
            if traitLevel > 0 then
                unlockText = "Right-click to increase level for $" .. GAMEMODE:GetTraitPrice(self.traitData, traitLevel)
            else
                unlockText = "Left-click to unlock specialization for $" .. GAMEMODE:GetTraitPrice(self.traitData, 0)
            end

            unlockText = unlockText .. " (you have $" .. ply.cash .. ")"
            self.descBox:InsertText(unlockText, "CW_HUD20")
        end

        self.descBox:SetText(self.traitData.description)

        GAMEMODE.traitDescBox = self.descBox
    end
end

function gcTraitPanel:OnCursorExited()
    if self.descBox then
        self.descBox:Remove()
        self.descBox = nil
    end
end

function gcTraitPanel:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(w - 17, h - 18, 16, 16)

    surface.SetDrawColor(40, 40, 40, 255)
    surface.DrawOutlinedRect(0, 0, w, h)

    local r, g, b, a = self:GetBackgroundColor()

    surface.SetDrawColor(r, g, b, a)
    surface.DrawRect(1, 1, w - 2, h - 2)

    surface.SetTexture(self.traitTexture)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(-1, -1, w, h)

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawTexturedRect(0, 0, w, h)
end

function gcTraitPanel:OnRemove()
    if self.descBox then
        self.descBox:Remove()
        self.descBox = nil
    end
end

vgui.Register("GCTraitPanel", gcTraitPanel, "DPanel")

local gcMVPDisplay = {}
-- one of: 16, 32, 64, 84, 128, 184 (as per wiki)
gcMVPDisplay.avatarImageSize = 64
gcMVPDisplay.mainTextFont = "CW_HUD28"
gcMVPDisplay.scoreTextFont = "CW_HUD20"

function gcMVPDisplay:SetPlayer(ply)
    self.player = ply

    local _, h = self:GetSize()

    self.avatarImage = vgui.Create("AvatarImage", self)
    self.avatarImage:SetSize(h - 4, h - 4)
    self.avatarImage:SetPos(2, 2)
    self.avatarImage:SetPlayer(ply, self.avatarImageSize)

    local gradientColors = GAMEMODE.RegisteredTeamData[ply:Team()].selectionColors

    local start, finish = gradientColors[1], gradientColors[2]
    self.startColor = Color(start.r, start.g, start.b, 200)
    self.finishColor = Color(finish.r, finish.g, finish.b, 200)
end

function gcMVPDisplay:SetMVPID(id)
    self.mvpID = id
    self.mvpData = mvpTracker.registeredDataByID[id]
end

-- this should be called last, when all the previous data (player object, MVP id) has been set
function gcMVPDisplay:SetScore(score)
    self.score = math.ceil(score)
    self.playerText = self.mvpData.name
    self.scoreText = self.player:Nick() .. " - " .. self.mvpData:formatText(self.score)
end

function gcMVPDisplay:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    draw.LinearGradient(h, 0, w - h - 1, h - 2, self.startColor, self.finishColor, draw.VERTICAL, w)

    local fontHeight = draw.GetFontHeight(gcMVPDisplay.mainTextFont)

    draw.ShadowText(self.playerText, self.mainTextFont, h + 4, 1, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.ShadowText(self.scoreText, self.scoreTextFont, h + 4, fontHeight - 2, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

vgui.Register("GCMVPDisplay", gcMVPDisplay, "DPanel")

local gcKillerDisplay = {}
gcKillerDisplay.mainTextFont = "CW_HUD28"
gcKillerDisplay.scoreTextFont = "CW_HUD20"
gcKillerDisplay.tkFont = "CW_HUD40"
gcKillerDisplay.avatarImageSize = 64
gcKillerDisplay.tkSpacing = 5

function gcKillerDisplay:Init()
end

-- should be called after setting the size
function gcKillerDisplay:SetKillData(killer, inflictorData, wasBleeding)
    self.killer = killer
    self.playerText = killer:Nick()
    self.killerText = "Unknown death cause"

    if inflictorData == "player" then
        local lply = LocalPlayer()

        if killer == lply then
            if wasBleeding then
                self.killerText = "Bled out!"
            else
                self.killerText = "Suicide!"
            end
        else
            self.teamKill = killer:Team() == lply:Team()

            if math.random(1, 100) <= 25 then
                self.killerText = "A headbutt, maybe?"
            end
        end
    else
        -- if the inflictor data is a table, then we try to display the PrintName variable if it has one
        if type(inflictorData) == "table" and inflictorData.PrintName then
            self.killerText = inflictorData.PrintName
        end
    end

    local _, h = self:GetSize()

    self.avatarImage = vgui.Create("AvatarImage", self)
    self.avatarImage:SetSize(h - 3, h - 3)
    self.avatarImage:SetPos(2, 2)
    self.avatarImage:SetPlayer(killer, self.avatarImageSize)

    local gradientColors = GAMEMODE.RegisteredTeamData[killer:Team()].selectionColors

    local start, finish = gradientColors[1], gradientColors[2]
    self.startColor = Color(start.r, start.g, start.b, 200)
    self.finishColor = Color(finish.r, finish.g, finish.b, 200)
end

function gcKillerDisplay:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)

    local White, Black = GAMEMODE.HUD_COLORS.white, GAMEMODE.HUD_COLORS.black

    draw.LinearGradient(h, 0, w - h - 1, h - 2, self.startColor, self.finishColor, draw.VERTICAL, w)

    local fontHeight = draw.GetFontHeight(gcMVPDisplay.mainTextFont)

    draw.ShadowText(self.playerText, self.mainTextFont, h + 4, 1, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.ShadowText(self.killerText, self.scoreTextFont, h + 4, fontHeight, White, Black, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- draw a separate element so that people can't fake TK reports as easily
    if self.teamKill then
        DisableClipping(true)
            surface.SetDrawColor(0, 0, 0, 230)
            surface.DrawRect(w + self.tkSpacing, 0, h, h)
            draw.ShadowText("TK", self.tkFont, w + self.tkSpacing + h * 0.5, 1 + h * 0.5 - draw.GetFontHeight(self.tkFont) * 0.5, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CETER)
        DisableClipping(false)
    end
end

vgui.Register("GCKillerDisplay", gcKillerDisplay, "DPanel")