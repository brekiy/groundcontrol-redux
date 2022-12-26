local GC_HUD16 = "GC_HUD16"
local clr, rect, orect, stext, lgrad = surface.SetDrawColor, surface.DrawRect, surface.DrawOutlinedRect, draw.ShadowText, draw.LinearGradient

local addScoreSizes = {400, 250, 800, 500, 398, 20, 1, 10, 240, 230, 260, 310, 370, 390, 170, 140, 90, 30, 239, 21, 40, 50, 340, 255, 249, 430}
local scoreSizes = {}

local function _GS(size)
    return scoreSizes[size]
end

function GM:setupScoreboardSizes()
    scoreSizes = {}

    for i = 1, #addScoreSizes do
        local size = addScoreSizes[i]
        scoreSizes[size] = _S(size)
    end
end

GM:setupScoreboardSizes()

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

local scorePanel = {}

function scorePanel:Init()
    self.redInfoPanel = vgui.Create("GCScoreboardTeamInfoPanel", self)
    self.blueInfoPanel = vgui.Create("GCScoreboardTeamInfoPanel", self)

    self.redInfoPanel:setTeam(TEAM_RED)
    self.blueInfoPanel:setTeam(TEAM_BLUE)

    self.redTeamList = vgui.Create("GCScoreboardPlayerList", self)
    self.blueTeamList = vgui.Create("GCScoreboardPlayerList", self)
end

function scorePanel:OnSizeChanged(w, h)
    self.redTeamList:SetSize(w * 0.5, h)
    self.blueTeamList:SetSize(w * 0.5, h)

    self.redTeamList:SetPos(w * 0.5, _S(21))
    self.blueTeamList:SetPos(0, _S(21))

    self.redInfoPanel:SetSize(w * 0.5 - _S(2), _S(20))
    self.blueInfoPanel:SetSize(w * 0.5 - _S(2), _S(20))

    self.redInfoPanel:SetPos(w * 0.5 + _S(1), 0)
    self.blueInfoPanel:SetPos(_S(1), 0)
end

function scorePanel:Paint()
    surface.SetDrawColor(0, 0, 0, 75)
    self:DrawFilledRect()
end

function scorePanel:doLayout()
    self.redTeamList:setTeam(TEAM_RED)
    self.blueTeamList:setTeam(TEAM_BLUE)
end

vgui.Register("GCScoreboardPanel", scorePanel)

------------------------------------
-- team player list
------------------------------------

local scorePlayerList = {}

function scorePlayerList:setTeam(teamID, skipNow)
    self.team = teamID
    self.teamPlayers = GAMEMODE:sortScoreboardPlayers(teamID)

    if not skipNow then
        self.teamPlayersNow = GAMEMODE:sortScoreboardPlayers(teamID, self.teamPlayersNow)
    end

    self:createPlayerElements()
end

function scorePlayerList:Think()
    table.Empty(self.teamPlayersNow)

    -- recreate elements if team members change
    -- too lazy to write a more sophisticated "remove element, create element" thing, so just eat this instead, I don't give a fuck
    -- but the checking for when a player's team changes is fucking ugly
    -- imagine if gmod had a shared hook for when a player's team changes... a man can dream (this gamemode was initially released in 2016 and as of today (December 27 2022) no such hook has been added lol)
    GAMEMODE:sortScoreboardPlayers(self.team, self.teamPlayersNow)

    if self:isLayoutDifferent() then
        self:setTeam(self.team, true)
    end
end

function scorePlayerList:isLayoutDifferent()
    GAMEMODE:sortScoreboardPlayers(self.team, self.teamPlayersNow)

    -- if the current player count is not the same, then the layout has changed, so stop here
    if #self.teamPlayersNow ~= #self.teamPlayers then
        return true
    end

    for key, obj in ipairs(self.teamPlayersNow) do
        if obj ~= self.teamPlayers[key] then -- cheap and simple, just compare whether the players are the same in both lists, and if they aren't - return true
            return true
        end
    end

    return false
end

function scorePlayerList:createPlayerElements()
    local children = self:GetChildren()

    for i = #children, 1, -1 do -- rev loop just in case we skip over children
        children[i]:Remove()
    end

    local elemH, elemW = _S(20), self:GetWide() - _S(2)
    local elemY = _S(21)
    local x, y = _S(1), 0

    for i = 1, #self.teamPlayers do
        local elem = vgui.Create("GCScoreboardPlayerPanel", self)
        elem:SetSize(elemW, elemH)
        elem:setPlayer(self.teamPlayers[i], i)
        elem:setList(self)
        elem:SetPos(x, y)
        y = y + elemY
    end
end

function scorePlayerList:Paint()
end

vgui.Register("GCScoreboardPlayerList", scorePlayerList)

------------------------------------
-- info panel
------------------------------------

local scoreInfoPane = {}

scoreInfoPane.teamGradientColors = {
    [TEAM_RED] = {GM.ScoreboardColors.ColorRed1, GM.ScoreboardColors.ColorRed2},
    [TEAM_BLUE] = {GM.ScoreboardColors.ColorBlue1, GM.ScoreboardColors.ColorBlue2}
}

function scoreInfoPane:setTeam(teamID)
    self.team = teamID
    self.teamName = team.GetName(teamID)
    self.colorPackage = self.teamGradientColors[teamID]
end

local ttf = team.TotalFrags

function scoreInfoPane:OnSizeChanged()
    self.halfH = self:GetTall() * 0.5
end

function scoreInfoPane:Paint()
    local clrs = GAMEMODE.ScoreboardColors

    lgrad(0, 0, self:GetWide(), self:GetTall(), self.colorPackage[1], self.colorPackage[2], draw.VERTICAL)

    local scaled10, scaled50, scaled230, scaled260, scaled310, scaled370, scaled400 = _GS(10), _GS(50), _GS(230), _GS(260), _GS(310), _GS(370), _GS(430)
    draw.ShadowText("RED", GC_HUD16, scaled10, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.ShadowText(ttf(TEAM_RED), GC_HUD16, scaled50, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.ShadowText("K", GC_HUD16, scaled230, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText("D", GC_HUD16, scaled260, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText("SCORE", GC_HUD16, scaled310, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText("PING", GC_HUD16, scaled370, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText("MIC", GC_HUD16, scaled400, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("GCScoreboardTeamInfoPanel", scoreInfoPane)


------------------------------------
-- player panel
------------------------------------

local scorePlayerPane = {}
scorePlayerPane.teamColors = {
    [TEAM_RED] = Color(216, 110, 60, 200),
    [TEAM_BLUE] = Color(88, 111, 158, 200)
}

function scorePlayerPane:Init()
end

function scorePlayerPane:setPlayer(ply, num)
    self.ply = ply
    local plyTeam = ply:Team()
    self.num = num
    self.isLocal = ply == LocalPlayer()

    if not self.isLocal then
        self.micButton = vgui.Create("GCScoreboardPlayerMic", self)
        self.micButton:setPlayer(ply)
        self:adjustMicSize()
    end

    self.myTeam = plyTeam == LocalPlayer():Team()
    self.plyColor = self.teamColors[plyTeam]

    local n = ply:Nick()
    self.nick = #n <= 21 and n or sleft(n, 21) .. "..."
end

function scorePlayerPane:setList(list)
    self.list = list
end

function scorePlayerPane:OnSizeChanged()
    self.halfH = self:GetTall() * 0.5
    self:adjustMicSize()
end

function scorePlayerPane:adjustMicSize()
    if self.micButton then
        self.micButton:SetSize(self:GetTall() - _S(4), self:GetTall() - _S(4))
        self.micButton:SetPos(self:GetWide() - self.micButton:GetWide() - _S(19), _S(2))
    end
end

function scorePlayerPane:Paint()
    local ply = self.ply

    if not IsValid(ply) then return end

    local clrs = GAMEMODE.ScoreboardColors

    local scaled10, scaled239, scaled230, scaled260, scaled370, scaled310, scaled40, scaled1 = _GS(10), _GS(239), _GS(230), _GS(260), _GS(370), _GS(310), _GS(40), _GS(1), _GS(398), _GS(20)

    local white = clrs.ColorWhite
    white.r = 255
    white.g = 255
    white.b = 255

    if self.isLocal then
        lgrad(0, 0, self:GetWide(), self:GetTall(), clrs.ColorGray1, clrs.ColorGray2, draw.VERTICAL)
    else
        clr(self.plyColor.r, self.plyColor.g, self.plyColor.b, self.plyColor.a)
        rect(0, 0, self:GetWide(), self:GetTall())
    end

    if self.myTeam and not ply:Alive() then
        white.r = 150
        white.g = 150
        white.b = 150
    end

    draw.ShadowText(self.num, GC_HUD16, scaled10, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.ShadowText(self.nick, GC_HUD16, scaled40, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.ShadowText(ply:Frags(), GC_HUD16, scaled230, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText(ply:Deaths(), GC_HUD16, scaled260, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText(ply:GetNWInt("GC_SCORE"), GC_HUD16, scaled310, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.ShadowText(ply:Ping(), GC_HUD16, scaled370, self.halfH, clrs.ColorWhite, clrs.ColorBlack, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    white.r = 255
    white.g = 255
    white.b = 255
end

vgui.Register("GCScoreboardPlayerPanel", scorePlayerPane)

------------------------------------
-- mute button
------------------------------------

local scorePlayerMic = {}

function scorePlayerMic:setPlayer(ply)
    self.ply = ply
end

function scorePlayerMic:OnSizeChanged()
    self.in1 = _S(3)
    self.inW, self.inH = self:GetWide() - self.in1 * 2, self:GetTall() - self.in1 * 2
end

function scorePlayerMic:Paint()
    if not IsValid(self.ply) then return end

    local w, h = self:GetWide(), self:GetTall()

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)

    if not self.ply:IsMuted() then
        if self:IsHovered() then
            surface.SetDrawColor(123, 216, 160, 255)
        else
            surface.SetDrawColor(79, 140, 104, 255)
        end

        surface.DrawRect(self.in1, self.in1, self.inW, self.inH)
    end
end

function scorePlayerMic:OnMousePressed()
    if IsValid(self.ply) then
        self.ply:SetMuted(not self.ply:IsMuted())
    end
end

vgui.Register("GCScoreboardPlayerMic", scorePlayerMic)
