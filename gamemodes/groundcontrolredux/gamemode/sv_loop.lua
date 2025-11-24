function GM:Think()
    if self.curGametype.Think then
        self.curGametype:Think()
    end

    local curTime = CurTime()
    local frameTime = FrameTime()
    local traits = self.Traits

    for _, ply in player.Iterator() do
        if ply:Alive() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED then
            if ply:OnGround() then
                -- ply.curMaxStamina = ply:GetMaxStamina()
                -- local maxStamina = math.min(ply.curMaxStamina, self.MinStaminaFromSprinting)
                local walkSpeed, velocity = ply:GetWalkSpeed(), ply:GetVelocity()

                velocity.z = 0
                local length = velocity:Length()

                -- should only drain stamina when our current stamina is lower than our max stamina
                if ply.stamina > self.MinStaminaFromSprinting and length >= walkSpeed * 1.15 then
                    if curTime > ply.staminaDrainTime then
                        ply:DrainStamina()
                    end
                else
                    if ply.stamina < ply:GetMaxStamina() and curTime > ply.staminaRegenTime then
                        ply:RegenStamina()
                    end
                end
            end

            if ply.bleeding then
                if ply:shouldBleed() then
                    ply:bleed()
                end

                ply:DelayHealthRegen()
                ply:IncreaseAdrenalineDuration(1, 1)
            else
                if ply.regenPool > 0 and curTime > ply.regenDelay then
                    ply:RegenHealth()
                end
            end

            if ply.adrenalineIncreaseSpeed != 1 and curTime > ply.adrenalineSpeedHold then
                ply.adrenalineIncreaseSpeed = math.Approach(ply.adrenalineIncreaseSpeed, 1, self.ADRENALINE_MOVEAFFECTOR_FADE_OUT_SPEED * frameTime)
            end

            self:attemptRestoreMovementSpeed(ply)

            ply.adrenalineDuration = math.max(ply.adrenalineDuration - frameTime, 0)

            if ply.adrenalineDuration == 0 then
                if ply.adrenaline > 0 then
                    ply:SetAdrenaline(ply.adrenaline - frameTime * self.ADRENALINE_FADE_OUT_SPEED)
                end
            else
                ply:SetAdrenaline(ply.adrenaline + self.AdrenalineFadeInPerSec * frameTime * ply.adrenalineIncreaseSpeed)
            end

            for traitKey, traitConfig in ipairs(ply.currentTraits) do
                local traitData = traits[traitConfig[1]][traitConfig[2]]

                if traitData.think then
                    traitData:Think(ply, curTime)
                end
            end
        end
    end
end
