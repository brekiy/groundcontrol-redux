AddCSLuaFile("cl_team.lua")
include("sh_team.lua")

GM.TeamModels = {}

concommand.Add("gc_attempt_join_team", function(ply, com, data)
    local team = data[1]

    if !team then
        return
    end

    team = tonumber(team)
    local join = GAMEMODE:CanJoinTeam(ply, team)

    if join == true then
        GAMEMODE:AttemptJoinTeam(ply, team)

        net.Start("GC_TEAM_SELECTION_SUCCESS")
        net.WriteUInt(team, 8)
        net.Send(ply)
    elseif join == false then
        net.Start("GC_RETRYTEAMSELECTION")
        net.Send(ply)
    end
end)

function GM:addTeamModel(teamId, model)
    self.TeamModels[teamId] = self.TeamModels[teamId] or {}
    table.insert(self.TeamModels[teamId], model)
end

function GM:getRandomTeamModel(teamId)
    local models = self.TeamModels[teamId]
    return models[math.random(1, #models)]
end

GM:addTeamModel(TEAM_RED, "models/player/riot.mdl")
GM:addTeamModel(TEAM_RED, "models/player/swat.mdl")
GM:addTeamModel(TEAM_RED, "models/player/urban.mdl")
GM:addTeamModel(TEAM_RED, "models/player/gasmask.mdl")
GM:addTeamModel(TEAM_RED, "models/custom/stalker_bandit_veteran.mdl")


GM:addTeamModel(TEAM_BLUE, "models/player/leet.mdl")
GM:addTeamModel(TEAM_BLUE, "models/player/guerilla.mdl")
GM:addTeamModel(TEAM_BLUE, "models/player/arctic.mdl")
GM:addTeamModel(TEAM_BLUE, "models/player/phoenix.mdl")
GM:addTeamModel(TEAM_BLUE, "models/player/bandit_backpack.mdl")


local PLAYER = FindMetaTable("Player")

function PLAYER:joinTeam(teamId)
    self:SetTeam(teamId) -- welp

    if GAMEMODE.curGametype.PlayerJoinTeam then
        GAMEMODE.curGametype:PlayerJoinTeam(self, teamId)
    end

    if GAMEMODE.curGametype.spawnDuringPreparation and GAMEMODE:IsPreparationPeriod() then
        self:Spawn()
    end

    GAMEMODE:ResetKillcountData()
end

function PLAYER:autobalancedSwitchTeam(teamId)
    self:SetTeam(teamId)
    net.Start("GC_AUTOBALANCED_TO_TEAM")
    net.WriteInt(teamId, 16)
    net.Send(self)
    GAMEMODE:ResetKillcountData()
end