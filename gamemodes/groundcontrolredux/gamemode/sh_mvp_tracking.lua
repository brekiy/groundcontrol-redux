AddCSLuaFile()

GM.MVP_SLOTS = 3 -- how many MVP things to show (if available)

mvpTracker = {}
mvpTracker.mtindex = {__index = mvpTracker}
mvpTracker.registeredData = {}
mvpTracker.registeredDataByID = {}

function mvpTracker.new()
    local new = {}
    setmetatable(new, mvpTracker.mtindex)
    new:init()

    return new
end

function mvpTracker.registerData(data)
    table.insert(mvpTracker.registeredData, data)
    mvpTracker.registeredDataByID[data.id] = data
end

function mvpTracker:init()
    self.trackedIDs = {}
end

function mvpTracker:resetAllTrackedIDs()
    self.trackedIDs = {}
end

function mvpTracker:trackID(player, id, amount)
    self.trackedIDs[player] = self.trackedIDs[player] or {}
    self.trackedIDs[player][id] = (self.trackedIDs[player][id] or 0) + amount
end

local currentTrackerObject = nil

local function sortByWeight(a, b)
    return currentTrackerObject:getIDWeight(a.player, a.id) > currentTrackerObject:getIDWeight(b.player, b.id)
end

if CLIENT then
    GM.SizePerMVPEntry = 50
    GM.SpacingBetweenMVPEntries = 2
    GM.MVPPanelWidth = 400
    GM.MVPPanelBaseHeight = 26
    GM.MVPEntryBaseYPos = 26
    GM.MVPPanelBottomSpacing = 50

    function GM:setMVPPanel(panel)
        self.mvpPanel = panel
    end

    function GM:DestroyMVPPanel()
        if self.mvpPanel and self.mvpPanel:IsValid() then -- remove any previous MVP panels
            self.mvpPanel:Remove()
            self.mvpPanel = nil
        end
    end

    function mvpTracker:createMVPDisplayFromList(list)
        GAMEMODE:DestroyMVPPanel()

        local panelHeight = GAMEMODE.MVPPanelBaseHeight + (GAMEMODE.SizePerMVPEntry + GAMEMODE.SpacingBetweenMVPEntries) * #list

        local panel = vgui.Create("GCPanel")
        panel:SetFont("CW_HUD20")
        panel:SetText("Most Valuable Players")
        panel:SetSize(GAMEMODE.MVPPanelWidth, panelHeight)
        panel:CenterHorizontal()

        local x, _ = panel:GetPos()
        panel:SetPos(x, ScrH() - panelHeight - GAMEMODE.MVPPanelBottomSpacing)

        GAMEMODE:setMVPPanel(panel)

        local yPos = GAMEMODE.MVPEntryBaseYPos

        for key, data in ipairs(list) do
            if IsValid(data.player) then
                local mvp = vgui.Create("GCMVPDisplay", panel)
                mvp:SetPos(2, yPos)
                mvp:SetSize(GAMEMODE.MVPPanelWidth - 4, GAMEMODE.SizePerMVPEntry)
                mvp:SetPlayer(data.player)
                mvp:SetMVPID(data.id)
                mvp:SetScore(data.score)

                yPos = yPos + GAMEMODE.SpacingBetweenMVPEntries + GAMEMODE.SizePerMVPEntry
            end
        end
    end
end

function mvpTracker:sendMVPList()
    local list = self:buildMVPList()

    if #list > 0 then
        net.Start("GC_MVP")
            net.WriteTable(list)
        net.Broadcast()
    end
end

function mvpTracker:removeInvalidPlayers()
    for ply, data in pairs(self.trackedIDs) do
        if !IsValid(ply) then
            self.trackedIDs[ply] = nil
        end
    end
end

function mvpTracker:buildMVPList()
    self:removeInvalidPlayers() -- clean up from players that left the server/etc. while the round was still going and they were MVP

    local list = {}

    for key, data in ipairs(mvpTracker.registeredData) do
        local score, playerObject = self:getMostEntriesForID(data.id)

        if score != -math.huge then
            table.insert(list, {id = data.id, score = math.ceil(score), player = playerObject})
        end
    end

    -- sort em by highest score
    currentTrackerObject = self
    table.sort(list, sortByWeight)

    -- remove any redundant ones
    for i = GAMEMODE.MVP_SLOTS + 1, #list do
        list[i] = nil
    end

    return list
end

-- finds the MVP for a specific track ID
function mvpTracker:getMostEntriesForID(id)
    local highest = -math.huge
    local mvp = nil
    local data = mvpTracker.registeredDataByID[id]

    for ply, subList in pairs(self.trackedIDs) do
        local entries = subList[id]

        if entries and (!data.minimum or (data.minimum and entries >= data.minimum)) and (entries > highest) then
            highest = entries
            mvp = ply
        end
    end

    return highest, mvp
end

function mvpTracker:getIDEntries(ply, id)
    if self.trackedIDs[ply] then
        return self.trackedIDs[ply][id] or 0
    end

    return 0
end

function mvpTracker:getIDWeight(ply, id)
    return self.registeredDataByID[id].weight * self:getIDEntries(ply, id)
end

mvpTracker.registerData({
    id = "kills", -- id of the entry
    name = "Bounty Hunter", -- pretty name of the MVP entry
    text = "Most kills", -- description of the MVP entry
    formatText = function(self, amount) -- function to format the text with
        if amount == 1 then
            return "1 kill"
        end

        return amount .. " kills"
    end,
    weight = 100 -- weight is on a per entry basis (multiply entry count by weight)
})

mvpTracker.registerData({
    id = "headshots",
    name = "Boom, Headshot",
    text = "Most kills",
    formatText = function(self, amount)
        if amount == 1 then
            return "1 headshot"
        end

        return amount .. " headshots"
    end,
    weight = 30
})

mvpTracker.registerData({
    id = "damage",
    name = "Hit and Run",
    text = "Most damage",
    minimum = 100, -- minimum entries (weight) for this to be considered display-worthy
    formatText = function(self, amount)
        return amount .. " damage"
    end,
    weight = 1
})

mvpTracker.registerData({
    id = "spotting",
    name = "Spot-a-Boat",
    minimum = 2,
    text = "Most spot assists",
    formatText = function(self, amount)
        return amount .. " spot-assists"
    end,
    weight = 20
})

mvpTracker.registerData({
    id = "bandaging",
    name = "Field Medic",
    minimum = 2,
    text = "Most team bandaging",
    formatText = function(self, amount)
        return amount .. " bandages applied"
    end,
    weight = 20
})

mvpTracker.registerData({
    id = "resupply",
    name = "Ammo Mule",
    minimum = 40,
    text = "Most team resupplies",
    formatText = function(self, amount)
        return amount .. " rounds given"
    end,
    weight = 2
})

-- mvpTracker.registerData({
--     id = "pistol_kills",
--     name = "Hard Boiled",
--     minimum = 2,
--     text = "Most kills",
--     formatText = function(self, amount)
--         return amount .. " sidearm kills"
--     end,
--     weight = 100
-- })

mvpTracker.registerData({
    id = "objective",
    name = "Play the fucking objective",
    minimum = 1,
    text = "Most objectives achieved",
    formatText = function(self, amount)
        return amount .. " objectives"
    end,
    weight = 150
})

net.Receive("GC_MVP", function(a, b)
    local data = net.ReadTable()

    mvpTracker:createMVPDisplayFromList(data)
end)
