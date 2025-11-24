GM.RoundsPerMap = GetConVar("gc_default_rounds_per_map"):GetInt()
GM.RoundsPlayed = 0
GM.MaxMapsPerPick = 9
GM.MaxGameTypesPerPick = 9

GM.TrashDealingMethods = { -- how to deal with trash props (small props with a small weight that the player collides with and then everything goes to fuck)
    REMOVE = 1, -- will remove them
    COLLISION = 2 -- will set the collision group to debris (does not collide with the player)
}

GM.DealWithTrash = GM.TrashDealingMethods.COLLISION
GM.TrashPropMaxWeight = 2 -- max weight of a prop to be considered trash

GM.VoteMapVoteID = "votemap"
GM.VoteGametypeVoteId = "votegametype"

function GM:TrackRoundMVP(player, id, amount)
    self.MVPTracker:trackID(player, id, amount)
end

function GM:dealWithTrashProps()
    if self.DealWithTrash == self.TrashDealingMethods.REMOVE then
        self:removeTrashProps(ents.FindByClass("prop_physics"))
        self:removeTrashProps(ents.FindByClass("prop_physics_multiplayer"))
    elseif self.DealWithTrash == self.TrashDealingMethods.COLLISION then
        self:makeDebrisMovetypeForTrash(ents.FindByClass("prop_physics"))
        self:makeDebrisMovetypeForTrash(ents.FindByClass("prop_physics_multiplayer"))
    end
end

function GM:removeTrashProps(entList)
    for k, v in pairs(entList) do
        local phys = v:GetPhysicsObject()

        if IsValid(phys) and phys:GetMass() <= self.TrashPropMaxWeight then
            SafeRemoveEntity(v)
        end
    end
end

function GM:makeDebrisMovetypeForTrash(entList)
    for k, v in pairs(entList) do
        local phys = v:GetPhysicsObject()

        if IsValid(phys) and phys:GetMass() <= self.TrashPropMaxWeight then
            v:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        end
    end
end

-- this is the default round over check, for gametypes with no player respawns
function GM:CheckRoundOverPossibility(teamId, ignoreDisplay)
    if !self.RoundOver then
        local playerCount = player.GetCount()

        if playerCount < 2 then -- don't do anything if we only have 2 players
            if playerCount == 0 then -- if everyone disconnected, reset rounds played
                self.RoundsPlayed = 0
            end

            return
        end

        local redMembers = team.GetPlayers(TEAM_RED)
        local blueMembers = team.GetPlayers(TEAM_BLUE)
        if #redMembers == 0 or #blueMembers == 0 then -- if neither team has AT LEAST ONE member, we don't restart rounds at all
            return
        end

        if self.RoundsPlayed > 0 then
            local winner = nil

            if self:countLivingPlayers(TEAM_RED) == 0 then
                winner = TEAM_BLUE
            end

            if self:countLivingPlayers(TEAM_BLUE) == 0 then
                winner = TEAM_RED
            end

            if winner then
                self:EndRound(winner)
            end
        else
            self:EndRound(nil)
        end
        if teamId and !ignoreDisplay then
            self:CreateLastManStandingDisplay(teamId)
        end
    end
end

function GM:canRestartRound()
    if GetConVar("gc_randomly_pick_gametype_and_map"):GetBool() then
        return self.RoundsPlayed < self.RoundsPerMap - 1
    end

    return true
end

function GM:EndRound(winningTeam)
    if self.RoundOver then -- we're already restarting a round wtf
        return
    end

    hook.Call("GroundControlPreRoundEnded", nil, winningTeam)
    self.RoundOver = true

    print("[GROUND CONTROL] ROUND HAS ENDED, WINNING TEAM ID: ", winningTeam)
    local lastRound = self.RoundsPlayed >= self.RoundsPerMap
    local canRestart = self:canRestartRound()
    local randomMapAndGametype = GetConVar("gc_randomly_pick_gametype_and_map"):GetBool()
    local canPickRandomMapAndGametype = !canRestart and randomMapAndGametype
    local actionToSend = nil

    if canPickRandomMapAndGametype then
        actionToSend = self.RoundOverAction.RANDOM_MAP_AND_GAMETYPE
    else
        actionToSend = self.RoundOverAction.NEW_ROUND
    end

    if !winningTeam then
        net.Start("GC_GAME_BEGIN")
        net.Broadcast()
    else
        for key, obj in ipairs(team.GetPlayers(winningTeam)) do
            obj:AddCurrency("WON_ROUND")
        end

        net.Start("GC_ROUND_OVER")
        net.WriteInt(winningTeam, 8)
        net.WriteInt(actionToSend, 8)
        net.Broadcast()
    end

    self.MVPTracker:sendMVPList()

    if self.curGametype.OnRoundEnded then
        self.curGametype:OnRoundEnded(winningTeam)
    end

    if canRestart then
        timer.Simple(self.RoundRestartTime, function()
            if self.nextVotedMap then
                game.ConsoleCommand("changelevel " .. self.nextVotedMap .. "\n")
            else
                self:RestartRound()
            end
        end)
    else
        if canPickRandomMapAndGametype then
            timer.Simple(self.RoundRestartTime, function()
                self:RandomlyPickGametypeAndMap()
            end)
        end
    end


    if lastRound then -- start a vote for the next map if possible
        if !canPickRandomMapAndGametype and !self.nextVotedMap then
            self:startVoteMap()
        end
    else
        print("Can pick random map/gametype?", canPickRandomMapAndGametype)
        if self.RoundsPlayed == self.RoundsPerMap - 1 and self:GametypeVotesEnabled() and !canPickRandomMapAndGametype then -- start a vote for next gametype if we're on the second last round
            self:startGameTypeVote()
        end

        self.RoundsPlayed = self.RoundsPlayed + 1
        self:saveCurrentGametype()
    end

    hook.Call("GroundControlPostRoundEnded", nil, winningTeam)

    self.MVPTracker:resetAllTrackedIDs()
end

function GM:startVoteMap()
    if self:canStartVote() then
        local _, data = self:GetGametypeFromConVar()
        local mapList = self:FilterExistingMaps(data.mapRotation)

        self:setupCurrentVote("Vote for the next map", mapList, player.GetAll(), self.MaxMapsPerPick, true, nil, function()
            local highestOption, _ = self:getHighestVote()
            self.nextVotedMap = highestOption.option
            local mapText = "Will switch to '" .. self.nextVotedMap .. "' at the end of this round."

            for _, ply in player.Iterator() do
                ply:ChatPrint(mapText)
            end
        end, self.VoteMapVoteID)

        hook.Call("GroundControlMapVoteStarted", nil, mapList, self.VoteID)
    end
end

GM.PreviousGametypeFile = "previous_gametype.txt"

-- doesn't actually remove the gametype, it just removes any mention of what the previous gametype from the file was,
-- in case you switch maps a lot and want to have all gametypes up for voting
-- bad name for the method though
function GM:RemoveCurrentGametype()
    file.Write(self.MainDataDirectory .. "/" .. self.PreviousGametypeFile, "")
end

function GM:saveCurrentGametype()
    file.Write(self.MainDataDirectory .. "/" .. self.PreviousGametypeFile, self.curGametype.name)
end

function GM:getPreviousGametype()
    local data = file.Read(self.MainDataDirectory .. "/" .. self.PreviousGametypeFile)

    if data then
        return data
    end
end

function GM:hasAtLeastOneMapForGametype(gametypeData)
    for key, map in ipairs(gametypeData.mapRotation) do
        if self:HasMap(map) then
            return true
        end
    end

    return false
end

function GM:startGameTypeVote()
    local possibilities = {}
    local prevGametype = self:getPreviousGametype()

    for key, gametype in ipairs(GAMEMODE.Gametypes) do
        if self.RemovePreviousGametype and prevGametype and prevGametype == gametype.name then -- this gametype was already played, so skip it
            continue
        end

        if self:hasAtLeastOneMapForGametype(gametype) then -- only insert the gamemode if there is at least 1 map available for it
            table.insert(possibilities, gametype.prettyName)
        end
    end

    self:setupCurrentVote("Vote for next game type", possibilities, player.GetAll(), self.MaxGameTypesPerPick, false, nil, function()
        local highestOption, _ = self:getHighestVote()

        self:SetGametypeCVarByPrettyName(highestOption.option)
    end, self.VoteGametypeVoteID)

    hook.Call("GroundControlGametypeVoteStarted", nil, possibilities, self.VoteID)
end

function GM:RestartRound()
    if !self.curGametype.noTeamBalance then
        self:BalanceTeams()
    end

    self.canSpawn = true
    game.CleanUpMap()
    self:dealWithTrashProps()
    self:AutoRemoveEntities()
    self:RunMapStartCallback()
    self:AdjustDoorSpeeds()

    if self.curGametype.RoundStart then
        self.curGametype:RoundStart()
    end

    self:setupRoundPreparation()

    for _, obj in player.Iterator() do
        obj:Spawn()
    end

    self.canSpawn = false
    self.RoundOver = false
    self:updateServerName()
    net.Start("GC_NEW_ROUND")
    net.Broadcast()

    self:ResetKillcountData()
end

function GM:setupLoadoutSelectionTime()
    self.LoadoutSelectTime = CurTime() + self.RoundLoadoutTime
end

function GM:setupRoundPreparation()
    if GetConVar("gc_print_damage_log"):GetBool() then
        PrintTable(self.DamageLog)
    end

    self.DamageLog = {}
    self.PreparationTime = CurTime() + self.RoundPreparationTime
    self:setupLoadoutSelectionTime()

    timer.Simple(self.RoundPreparationTime, function()
        self:disableCustomizationMenu()
    end)

    net.Start("GC_ROUND_PREPARATION")
    net.WriteFloat(self.PreparationTime)
    net.Broadcast()
end

function GM:countLivingPlayers(teamToCheck)
    local alive = 0

    for key, obj in pairs(team.GetPlayers(teamToCheck)) do
        if obj:Alive() then
            alive = alive + 1
        end
    end
    return alive
end

hook.Add("TFA_InspectVGUI_Start", "Kill TFA customization", function()
    return CurTime() < GAMEMODE.PreparationTime
end)
