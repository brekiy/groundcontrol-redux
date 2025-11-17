function GM:SortPlayers(teamEnum)
    local players = team.GetPlayers(teamEnum)
    local sorted = {}

    for _, player1 in ipairs(players) do
        local score1, nick1, deaths1 = player1:GetNWInt("GC_SCORE"), player1:Name(), player1:Deaths()
        local slot = #players

        for _, player2 in ipairs(players) do
            if player1 != player2 then
                local score2, nick2, deaths2 = player2:GetNWInt("GC_SCORE"), player2:Name(), player2:Deaths()

                if score1 > score2 then
                    slot = slot - 1
                elseif score1 == score2 then
                    if deaths1 < deaths2 then
                        slot = slot - 1
                    elseif deaths1 == deaths2 then
                        if nick1 < nick2 then
                            slot = slot - 1
                        end
                    end
                end
            end
        end

        sorted[slot] = player1
    end

    return sorted
end

function GM:ScoreboardShow()
    self:CreateScoreboard()
end

function GM:ScoreboardHide()
    self:DestroyScoreboard()
end

GM.ScoreboardColors = {
    ColorWhite = Color(255, 255, 255, 255),
    ColorBlack = Color(0, 0, 0, 255),
    ColorBlue1 = Color(33, 184, 255, 255),
    ColorBlue2 = Color(58, 120, 255, 255),
    ColorRed1 = Color(255, 122, 61, 255),
    ColorRed2 = Color(255, 0, 0, 255),
    ColorGray1 = Color(213, 213, 213, 150),
    ColorGray2 = Color(170, 170, 170, 150)
}

local gcScoreboardFrame = {}

function gcScoreboardFrame:Update()
    if IsValid(self.BluePanel) then
        self.BluePanel:Update()
    end

    if IsValid(self.RedPanel) then
        self.RedPanel:Update()
    end
end

function gcScoreboardFrame:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 75)
    surface.DrawRect(0, 0, w, h)

    return true
end

function gcScoreboardFrame:PerformLayout(w, h)
    self.BluePanel:SetSize(w / 2, h)
    self.RedPanel:SetSize(w / 2, h)
    self.RedPanel:SetPos(w / 2, 0)
end

vgui.Register("GCScoreboardFrame", gcScoreboardFrame, "DPanel")

local ROW_HEIGHT_RATIO = 0.045

local gcScoreboardTeamColumn = {}
AccessorFunc(gcScoreboardTeamColumn, "Team", "Team", FORCE_NUMBER)

function gcScoreboardTeamColumn:Init()
    self.PlayerRows = {}
end

function gcScoreboardTeamColumn:Update()
    for _, panel in ipairs(self.PlayerRows) do
        if not IsValid(panel) then
            continue
        end

        panel:Remove()
    end

    if not self.Team then
        return
    end

    for index, ply in ipairs(GAMEMODE:SortPlayers(self.Team)) do
        local row = vgui.Create("GCScoreboardPlayer", self)
        row:SetPlayer(ply)
        row:SetPlayerIndex(index)
        row:SetTeam(self.Team)

        self.PlayerRows[index] = row
    end
end

function gcScoreboardTeamColumn:Paint(w, h)
end

function gcScoreboardTeamColumn:PerformLayout(w, h)
    local rHeight = math.floor(h * ROW_HEIGHT_RATIO)

    if IsValid(self.TitleBar) then
        self.TitleBar:SetSize(w, rHeight)
    end

    for index, row in ipairs(self.PlayerRows) do
        row:SetSize(w, rHeight)
        row:SetPos(0, rHeight * index)
    end
end

vgui.Register("GCScoreboardTeamColumn", gcScoreboardTeamColumn, "DPanel")

local CW_HUD16 = "CW_HUD16"
local PADDING = 4
local ALIVE_FORMAT = "ALIVE: %i"

local gcScoreboardTitleBar = {}
AccessorFunc(gcScoreboardTitleBar, "Team", "Team", FORCE_NUMBER)

function gcScoreboardTitleBar:Paint(w, h)
    local colors = GAMEMODE.ScoreboardColors
    local color1, color2 =
        self.Team == TEAM_RED and colors.ColorRed1 or colors.ColorBlue1,
        self.Team == TEAM_RED and colors.ColorRed2 or colors.ColorBlue2

    surface.SetDrawColor(color1)
    surface.DrawRect(0, 0, w, h)
    draw.LinearGradient(0, 0, w, h, color1, color2, draw.VERTICAL)

    surface.SetFont(CW_HUD16)
    local textHeight = select(2, surface.GetTextSize("ALLCAPS"))
    local vertCenter = h * 0.5 - textHeight * 0.5

    draw.ShadowText(self.Team == TEAM_RED and "RED" or "BLUE", CW_HUD16, PADDING + 6, vertCenter, colors.ColorWhite, colors.ColorBlack, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.ShadowText(team.TotalFrags(self.Team), CW_HUD16, PADDING + 50, vertCenter, colors.ColorWhite, colors.ColorBlack, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.ShadowText("K", CW_HUD16, PADDING + 230, vertCenter, colors.ColorWhite, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.ShadowText("D", CW_HUD16, PADDING + 260, vertCenter, colors.ColorWhite, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.ShadowText("SCORE", CW_HUD16, PADDING + 310, vertCenter, colors.ColorWhite, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.ShadowText("PING", CW_HUD16, PADDING + 370, vertCenter, colors.ColorWhite, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    -- GM.AlivePlayers seems to be broken in some way (afxnatic)
    -- if LocalPlayer():Team() == self.Team then
    --     draw.ShadowText(string.format(ALIVE_FORMAT, GAMEMODE.AlivePlayers[self.Team] or 0), CW_HUD16, PADDING + 140, vertCenter, colors.ColorWhite, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    -- end

    return true
end

vgui.Register("GCScoreboardTitleBar", gcScoreboardTitleBar, "DPanel")

local gcScoreboardPlayer = {}
AccessorFunc(gcScoreboardPlayer, "Player", "Player")
AccessorFunc(gcScoreboardPlayer, "PlayerIndex", "PlayerIndex", FORCE_NUMBER)
AccessorFunc(gcScoreboardPlayer, "Team", "Team", FORCE_NUMBER)

function gcScoreboardPlayer:Init()
    self.TextColor = Color(255, 255, 255, 255)
end

local TEAM_GRADIENTS = {
    [TEAM_RED] = Color(255, 143, 91, 150),
    [TEAM_BLUE] = Color(40, 66, 124, 150)
}

function gcScoreboardPlayer:Paint(w, h)
    if not IsValid(self.Player) then
        return true
    end

    local lp = LocalPlayer()
    local n = self.Player:Nick()
    local colors = GAMEMODE.ScoreboardColors

    if self.Player == lp then
        -- HACK: If we provide 0 for our starting Y-coordinate, there's an annoying 1-pixel gap above the player panel.
        draw.LinearGradient(0, -1, w, h, colors.ColorGray1, colors.ColorGray2, draw.VERTICAL)
    else
        surface.SetDrawColor(TEAM_GRADIENTS[self.Team]:Unpack())
        surface.DrawRect(0, 0, w, h)
    end

    local yourTeam = lp:Team()

    if yourTeam == self.Team and !self.Player:Alive() then
        self.TextColor.r = 150
        self.TextColor.g = 150
        self.TextColor.b = 150
    end

    surface.SetFont(CW_HUD16)
    local textHeight = select(2, surface.GetTextSize("ALLCAPS"))
    local vertCenter = h * 0.5 - textHeight * 0.5

    draw.ShadowText(self.PlayerIndex, CW_HUD16, PADDING + 10, vertCenter, self.TextColor, colors.ColorBlack, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.ShadowText(#n <= 21 and n or string.Left(n, 21) .. "...", CW_HUD16, PADDING + 40, vertCenter, self.TextColor, colors.ColorBlack, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.ShadowText(self.Player:Frags(), CW_HUD16, PADDING + 230, vertCenter, self.TextColor, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.ShadowText(self.Player:Deaths(), CW_HUD16, PADDING + 260, vertCenter, self.TextColor, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.ShadowText(self.Player:GetNWInt("GC_SCORE"), CW_HUD16, PADDING + 310, vertCenter, self.TextColor, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.ShadowText(self.Player:Ping(), CW_HUD16, PADDING + 370, vertCenter, self.TextColor, colors.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    self.TextColor.r = 255
    self.TextColor.g = 255
    self.TextColor.b = 255

    return true
end

vgui.Register("GCScoreboardPlayer", gcScoreboardPlayer, "DPanel")

function GM:CreateScoreboard()
    if IsValid(self.ScoreboardPanel) then
        return
    end

    self.ScoreboardPanel = vgui.Create("GCScoreboardFrame")
    self.ScoreboardPanel:SetSize(800, 500)
    self.ScoreboardPanel:Center()

    self.ScoreboardPanel.BluePanel = vgui.Create("GCScoreboardTeamColumn", self.ScoreboardPanel)
    self.ScoreboardPanel.BluePanel:SetTeam(TEAM_BLUE)

    self.ScoreboardPanel.BluePanel.TitleBar = vgui.Create("GCScoreboardTitleBar", self.ScoreboardPanel.BluePanel)
    self.ScoreboardPanel.BluePanel.TitleBar:SetTeam(TEAM_BLUE)

    self.ScoreboardPanel.RedPanel = vgui.Create("GCScoreboardTeamColumn", self.ScoreboardPanel)
    self.ScoreboardPanel.RedPanel:SetTeam(TEAM_RED)

    self.ScoreboardPanel.RedPanel.TitleBar = vgui.Create("GCScoreboardTitleBar", self.ScoreboardPanel.RedPanel)
    self.ScoreboardPanel.RedPanel.TitleBar:SetTeam(TEAM_RED)

    -- Create the player panels
    self.ScoreboardPanel:Update()
end

function GM:DestroyScoreboard()
    if not IsValid(self.ScoreboardPanel) then
        return
    end

    self.ScoreboardPanel:Remove()
end

function GM:UpdateScoreboard()
    if not IsValid(self.ScoreboardPanel) then
        return
    end

    self.ScoreboardPanel:Update()
end

function GM:HUDDrawScoreBoard()
end