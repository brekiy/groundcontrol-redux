GM.gametypeRequest = 0
GM.lastStamina = 0
GM.breatheSoundIntensity = 1
GM.breatheSoundChangeUp = 0
GM.breatheSoundChangeDown = 0
GM.breatheSoundChangeMax = 0.1
GM.breatheSoundChange = 0.02
GM.breatheSoundChangeAmount = 0
GM.lowestBreatheSoundIntensity = 0.73

function GM:Think()
    if !self.curGametypeID and CurTime() > self.gametypeRequest then
        RunConsoleCommand("gc_request_gametype")
        self.gametypeRequest = CurTime() + 1
    end

    local ply = LocalPlayer()
    local alive = ply:Alive()

    local curAdrenaline = ply.adrenaline or 0
    local adrenalineData = self.AdrenalineData
    local curTime = CurTime()

    adrenalineData.currentVal = math.Approach(adrenalineData.currentVal, curAdrenaline, FrameTime() * adrenalineData.approachRate)

    if alive then
        if adrenalineData.currentVal >= 0.25 and curTime > adrenalineData.soundTime then
            local delay = 0.8 - (adrenalineData.currentVal - 0.25) * 0.5
            local volume = 60 + (adrenalineData.currentVal - 0.25) * 33
            local pitch = 100 + (adrenalineData.currentVal - 0.25) * 25

            adrenalineData.soundTime = curTime + delay
            ply:EmitSound("ground_control/player/hbeat.mp3", volume, pitch)
            self.tipController:handleEvent("HIGH_ADRENALINE")
        end

        if ply.stamina <= 60 then
            local staminaData = self.StaminaData

            if curTime > staminaData.soundTime then
                local lastStamina = self.lastStamina
                self.lastStamina = ply.stamina

                if ply.stamina < lastStamina then -- if we're gaining stamina or it remains the same, then we will begin decreasing the sound of the breathing so that it's !super annoying when you are low on health
                    self.breatheSoundChangeUp = math.Approach(self.breatheSoundChangeUp, self.breatheSoundChangeMax, self.breatheSoundChange)
                    self.breatheSoundChangeDown = math.Approach(self.breatheSoundChangeDown, 0, self.breatheSoundChange)

                    self.breatheSoundIntensity = math.Approach(self.breatheSoundIntensity, 1, self.breatheSoundChangeUp)
                else
                    self.breatheSoundChangeUp = math.Approach(self.breatheSoundChangeUp, 0, self.breatheSoundChange)
                    self.breatheSoundChangeDown = math.Approach(self.breatheSoundChangeDown, self.breatheSoundChangeMax, self.breatheSoundChange)

                    self.breatheSoundIntensity = math.Approach(self.breatheSoundIntensity, self.lowestBreatheSoundIntensity, self.breatheSoundChangeDown)
                end

                local difference = (60 - ply.stamina) / 60
                local volume = Lerp(difference, staminaData.minVolume, staminaData.maxVolume)
                local delay = Lerp(difference, staminaData.maxSoundTime, staminaData.minSoundTime)

                ply:EmitSound("ground_control/player/sprint" .. math.random(1, 5) .. ".mp3", volume * self.breatheSoundIntensity, 100)
                staminaData.soundTime = curTime + delay
            end
        end

        self:attemptRestoreMovementSpeed(ply)
    else
        self.RadioSelection.active = false
    end

    if self.curGametype and self.curGametype.think then
        self.curGametype:think()
    end
end