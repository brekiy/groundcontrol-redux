local PLAYER = FindMetaTable("Player")

GM.SpectateablePlayers = {}

function PLAYER:resetSpectateData()
    self.spectatedPlayers = {}
    self.spectateDelay = 0
    self.currentSpectateEntity = nil
    self.spectatedCamera = self.spectatedCamera or OBS_MODE_CHASE
end

-- take a bool whether to go back or not
-- TODO (brekiy): actually make the bool work
function PLAYER:spectateNext(goBack)
    local wasFound = false
    local alivePlayers = 0
    local teamPlayers = nil

    local myTeam = self:Team()

    if myTeam == TEAM_SPECTATOR then
        teamPlayers = select(2, player.Iterator())
    else
        teamPlayers = team.GetPlayers(self:Team())
    end

    -- local teamPlayerCount = #teamPlayers
    -- PrintTable(self.spectatedPlayers)
    for _, ply in ipairs(teamPlayers) do
        if ply:Alive() then
            if !self.spectatedPlayers[ply] then
                self.spectatedPlayers[ply] = true
                self:SetSpectateTarget(ply)
                wasFound = true

                break
            end

            alivePlayers = alivePlayers + 1
        end
    end

    if !wasFound and alivePlayers > 0 then
        self:resetSpectateData()
        self:spectateNext(goBack)
    end
end

function PLAYER:reSpectate()
    self:resetSpectateData()
    self:spectateNext(false)
end

function PLAYER:isSpectateTargetValid()
    return IsValid(self.currentSpectateEntity)
end

function PLAYER:delaySpectate(time)
    self.spectateDelay = CurTime() + time
end

function PLAYER:attemptSpectate(goBack)
    if self:Alive() or CurTime() < self.spectateDelay then
        return
    end

    self:spectateNext(goBack)
end

function PLAYER:changeSpectateCamera()
    if self.spectatedCamera == OBS_MODE_CHASE then
        self.spectatedCamera = OBS_MODE_IN_EYE
    elseif self.spectatedCamera == OBS_MODE_IN_EYE then
        self.spectatedCamera = OBS_MODE_CHASE
    end
    self:Spectate(self.spectatedCamera)
end

concommand.Add("gc_spectate_next", function(ply, com, args)
    ply:attemptSpectate()
end)

-- concommand.Add("gc_spectate_perspective", function(ply, com, args)
--     ply:changeSpectateCamera()
-- end)