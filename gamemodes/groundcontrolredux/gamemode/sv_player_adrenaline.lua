include("sh_player_adrenaline.lua")

GM.MAX_ADRENALINE_MULTIPLIER = 3
GM.ADRENALINE_MOVEAFFECTOR_FADE_OUT_SPEED = 0.75 -- speed at which the adrenaline's increase speed fades out
GM.ADRENALINE_FADE_OUT_SPEED = 0.05 -- how much adrenaline to fade out when not being suppressed every second
GM.AdrenalineFadeInPerSec = 0.2 -- 0.2 is 20%, 1 is max
GM.MinimumSuppressionRange = 100
GM.StartingSuppressionRange = 80
GM.MaximumSuppressionRange = 220
GM.MaximumSuppressionDuration = 3 -- how long suppression can hold on it's own

local PLAYER = FindMetaTable("Player")

function PLAYER:Suppress(duration, speedChange)
    local newDuration = CurTime() + duration

    self.adrenalineDuration = math.Clamp(self.adrenalineDuration + duration * self.adrenalineIncreaseMultiplier, 0, GAMEMODE.MaximumSuppressionDuration * self.maxAdrenalineDurationMultiplier)
    self.adrenalineSpeedHold = math.max(self.adrenalineDuration, newDuration)
    self.adrenalineIncreaseSpeed = math.Clamp(self.adrenalineSpeedHold + speedChange, 1, GAMEMODE.MAX_ADRENALINE_MULTIPLIER)
end

function PLAYER:increaseAdrenalineDuration(amountBy, max)
    max = max or GAMEMODE.MaximumSuppressionDuration
    max = math.max(max, self.adrenalineDuration)

    self.adrenalineDuration = math.Clamp(self.adrenalineDuration, 0, max)
end

if !FULL_INIT and SERVER then
    -- physical bullets mess with this right now due to having no effective range, could maybe change this to use damage?
    CustomizableWeaponry.callbacks:addNew("bulletCallback", "GroundControl_bulletCallback", function(wep, ply, traceResult, dmgInfo)
        local effectiveRange = wep.EffectiveRange
        local rangeInMeters = (effectiveRange or 90) / 39.37 -- convert back to meters
        local suppressionRange = math.Clamp(GAMEMODE.StartingSuppressionRange + rangeInMeters * 0.2, GAMEMODE.MinimumSuppressionRange, GAMEMODE.MaximumSuppressionRange)
        local suppressionSpeedChange = rangeInMeters * 0.0002
        local suppressionDuration = 0.1 + rangeInMeters * 0.0005

        for key, object in pairs(ents.FindInSphere(traceResult.HitPos, suppressionRange)) do
            if object:IsPlayer() and object:Alive() and object:CanSuppress(ply) then
                object:Suppress(suppressionDuration, suppressionSpeedChange)
            end
        end
    end)
end
