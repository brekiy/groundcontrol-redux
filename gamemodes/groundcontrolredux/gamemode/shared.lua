include("sh_sounds.lua")
include("sh_convars.lua")

GM.Version = "v1.5.4"

GM.Name     = "Ground Control Redux"
GM.Author     = "brekiy"
GM.Email     = "N/A"
GM.Website     = "N/A"

GM.MainDataDirectory = "ground_control" -- I'd like to change this but this would wipe server progress

-- GM.BaseRunSpeed = GetConVar("gc_base_run_speed"):GetInt()
-- GM.BaseWalkSpeed = GetConVar("gc_base_walk_speed"):GetInt()
GM.CrouchedWalkSpeed = 0.6
GM.CurrentMap = game.GetMap()
GM.RoundRestartTime = 10 -- how much time to restart a round after it has ended
GM.RoundPreparationTime = 15 -- time it takes for the round to start
GM.RoundLoadoutTime = 25 -- for how long can we pick our loadout at the start of a new round
GM.LoadoutDistance = 256 -- max distance within which we can still change our loadout
GM.DeadPeriodTime = 5 -- how much time we will have to spend until we're able to spectate our teammates after dying
GM.PreparationTime = 0
GM.StaminaPerJump = 5
GM.StaminaPerJumpBaselineNoWeightPenalty = 5 -- if our weight does not exceed this much we don't get an extra stamina drain penalty from jumping
GM.StaminaPerJumpWeightIncrease = 0.8 -- per each kilogram we will drain this much extra stamina when our weight exceeds StaminaPerJumpBaselineNoWeightPenalty
GM.NotOnGroundRecoilMultiplier = 1.5
GM.NotOnGroundSpreadMultiplier = 4
GM.JumpStaminaRegenDelay = 1
GM.MaxHealth = 100
GM.VotePrepTime = 5
GM.VoteTime = GM.VotePrepTime + 20
GM.HeavyLandingVelocity = 500
GM.HeavyLandingVelocityToWeight = 0.03 -- multiply velocity by this much, if the final value exceeds our weight, then it is considered a heavy landing and will make extra noise
GM.CurMap = string.lower(game.GetMap())
-- GM.VotedPlayers = {}

GM.RoundOverAction = {
    NEW_ROUND = 1,
    RANDOM_MAP_AND_GAMETYPE = 2
}

GM.KnifeWeaponClass = "cw_extrema_ratio_official"

GM.StandHullMin = Vector(-16, -16, 0)
GM.StandHullMax = Vector(16, 16, 72)

GM.DuckHullMin = Vector(-16, -16, 0)
GM.DuckHullMax = Vector(16, 16, 46)
GM.ViewOffsetDucked = Vector(0, 0, 40)

-- if you wish to force-enable free aim, set this variable to true
-- beware that during playtests I noticed a weird thing - when free aim is forced on, people play much, MUCH slower and in general the gamemode turns into a campfest
GM.FORCE_FREE_AIM = false

-- parity for everyone - force complex telescopics (this could hurt the FPS on a lot of people's systems, but we'll see how this goes, if people complain I will probably disable this)
-- simple telescopics are a lot easier to use gameplay-wise, and they provide an advantage over those that use complex telescopics
-- because they disorient much less than complex telescopics (aiming through PIP is a pain in the ass, especially on close ranges, since it disorients like crazy, on the flip side - it's like that IRL too)
-- so to make things fair, I am forcing complex telescopics
GM.FORCE_COMPLEX_TELESCOPICS = true

GM.SidewaysSprintSpeedAffector = 0.1 -- if we're sprinting sideways + forward, we take a small hit to our movement speed
GM.OnlySidewaysSprintSpeedAffector = 0.25 -- if we're sprinting only sideways (not forward + sideways), then we take a big hit to our movement speed
GM.BackwardsSprintSpeedAffector = 0.25 -- if we're sprinting backwards, we take a big hit to our movement speed

GM.MaxLadderMovementSpeed = 20 -- how fast should the player move when using a ladder


-- configure CW 2.0, please don't change this (unless you know what you're doing)
CustomizableWeaponry.canOpenInteractionMenu = true
CustomizableWeaponry.customizationEnabled = true
CustomizableWeaponry.useAttachmentPossessionSystem = true
CustomizableWeaponry.playSoundsOnInteract = true
CustomizableWeaponry.physicalBulletsEnabled = false -- physical bullets for cw 2.0, unfortunately
CustomizableWeaponry.suppressOnSpawnAttachments = true
-- Override this from the weapon base to toss our special ground control frag grenade
function CustomizableWeaponry.quickGrenade:createThrownGrenade(player)
    local pos = player:GetShootPos()
    local offset = CustomizableWeaponry.quickGrenade:getThrowOffset(player)
    local eyeAng = player:EyeAngles()
    -- local forward = eyeAng:Forward()

    local nade = ents.Create("gc_cw_grenade_thrown")
    nade:SetPos(pos + offset)
    nade:SetAngles(eyeAng)
    nade:Spawn()
    nade:Activate()
    nade:Fuse(3)
    nade:SetOwner(player)

    return nade
end

-- CW 2.0 configuration over

function GM:Initialize()
    self.BaseClass.Initialize(self)
end

if CLIENT then
    CustomizableWeaponry.callbacks:addNew("suppressHUDElements", "GroundControl_suppressHUDElements", function(self)
        return true, true, false -- 3rd argument is whether the weapon interaction menu should be hidden
    end)
end

CustomizableWeaponry.ITEM_PACKS_TOP_COLOR = Color(0, 0, 0, 230)

FULL_INIT = true

CustomizableWeaponry.callbacks:addNew("calculateAccuracy", "GroundControl_calculateAccuracy", function(self)
    local hipMod, aimMod = self:GetOwner():getAdrenalineAccuracyModifiers()
    local hipMult, aimMult, maxSpread = 1, 1, 1

    if !self:GetOwner():OnGround() then
        local mult = GAMEMODE.NotOnGroundSpreadMultiplier
        hipMult, aimMult, maxSpread = mult, mult, mult -- if we aren't on the ground, we get a huge spread increase
    end

    hipMult = hipMult * hipMod
    aimMult = aimMult * aimMod

    return aimMult, hipMult, maxSpread
end)

CustomizableWeaponry.callbacks:addNew("calculateRecoil", "GroundControl_calculateRecoil", function(self, modifier)
    if !self:GetOwner():OnGround() then
        modifier = modifier * GAMEMODE.NotOnGroundRecoilMultiplier -- if we aren't on the ground, we get a huge recoil increase
    end

    return modifier
end)

CustomizableWeaponry.callbacks:addNew("preFire", "GroundControl_preFire", function(self)
    return CurTime() < GAMEMODE.PreparationTime
end)

CustomizableWeaponry.callbacks:addNew("forceFreeAim", "GroundControl_forceFreeAim", function(self)
    return GetConVar("gc_force_free_aim"):GetBool()
end)

CustomizableWeaponry.callbacks:addNew("forceComplexTelescopics", "GroundControl_forceComplexTelescopics", function(self)
    return GetConVar("gc_force_pip_scopes"):GetBool()
end)

CustomizableWeaponry.callbacks:addNew("preventAttachment", "GroundControl_preventAttachment", function(self, attachmentList, currentAttachmentIndex, currentAttachmentCategory, currentAttachment)
    local desiredAttachments = 0

    for key, category in pairs(self.Attachments) do
        if category == currentAttachmentCategory then
            if !category.last then
                desiredAttachments = desiredAttachments + 1
            end
        else
            if category.last then
                desiredAttachments = desiredAttachments + 1
            end
        end
    end

    return desiredAttachments > self:GetOwner():getUnlockedAttachmentSlots()
end)

CustomizableWeaponry.callbacks:addNew("disableInteractionMenu", "GroundControl_disableInteractionMenu", function(self)
    if GAMEMODE.curGametype.canHaveAttachments and !GAMEMODE.curGametype:canHaveAttachments(self:GetOwner()) then
        return true
    end

    return !GAMEMODE:isPreparationPeriod()
end)

if CLIENT then
    local sidewaysHoldingStates = {
        [0] = true, -- CW_IDLE
        [1] = true, -- CW_RUNNING
        [2] = true, -- CW_AIMING
        [4] = true -- CW_CUSTOMIZE
    }

    local zeroVector = Vector(0, 0, 0)
    local downwardsVector = Vector(0, 0, 0)
    local downwardsAngle = Vector(-30, 0, -45)

    CustomizableWeaponry.callbacks:addNew("adjustViewmodelPosition", "GroundControl_adjustViewmodelPosition", function(self, targetPos, targetAng)
        local gametype = GAMEMODE.curGametype
        local wepClass = self:GetClass()

        if gametype.name == "ghettodrugbust" and gametype.gangTeam == LocalPlayer():Team() and gametype.sidewaysHoldingWeapons[wepClass] then
            if sidewaysHoldingStates[self.dt.State] and !self:isReloading() and !self.isKnife then
                if self.dt.State != CW_CUSTOMIZE then
                    if self.dt.State != CW_RUNNING and self.dt.State != CW_AIMING then
                        targetAng = targetAng * 1
                        targetAng.z = targetAng.z - 90
                    end

                    if self.dt.State == CW_RUNNING then
                        targetPos = downwardsVector
                        targetAng = downwardsAngle
                    elseif self.dt.State != CW_AIMING then
                        targetPos = targetPos * 1
                        targetPos.z = targetPos.z - 3
                        targetPos.x = targetPos.x - 4
                    end
                end

                local vm = self.CW_VM
                local bones = gametype.sidewaysHoldingBoneOffsets[wepClass]

                if bones then
                    for boneName, offsets in pairs(bones) do
                        offsets.current = LerpVectorCW20(FrameTime() * 15, offsets.current, offsets.target)
                        local bone = vm:LookupBone(boneName)
                        vm:ManipulateBonePosition(bone, offsets.current)
                    end
                end
            else
                local bones = gametype.sidewaysHoldingBoneOffsets[wepClass]

                if bones then
                    local vm = self.CW_VM

                    for boneName, offsets in pairs(bones) do
                        offsets.current = LerpVectorCW20(FrameTime() * 15, offsets.current, zeroVector)
                        local bone = vm:LookupBone(boneName)
                        vm:ManipulateBonePosition(bone, offsets.current)
                    end
                end
            end
        end

        return targetPos, targetAng
    end)

    GM.attachmentSlotDisplaySize = 60
    GM.attachmentSlotSpacing = 5

    CustomizableWeaponry.callbacks:addNew("drawToHUD", "GroundControl_drawToHUD", function(self)
        if self.dt.State == CW_CUSTOMIZE then
            if !self:GetOwner().unlockedAttachmentSlots then
                RunConsoleCommand("gc_request_data")
            else
                local availableSlots = self:GetOwner():getUnlockedAttachmentSlots()
                local overallSize = (GAMEMODE.attachmentSlotDisplaySize + GAMEMODE.attachmentSlotSpacing)
                local baseX = ScrW() * 0.5 - overallSize * availableSlots * 0.5
                local baseY = 90

                for i = 1, availableSlots do
                    local x = baseX + (i - 1) * overallSize

                    surface.SetDrawColor(0, 0, 0, 150)
                    surface.DrawRect(x, baseY, GAMEMODE.attachmentSlotDisplaySize, GAMEMODE.attachmentSlotDisplaySize)
                end

                local curPos = 1

                for key, category in pairs(self.Attachments) do
                    if category.last then
                        local x = baseX + (curPos - 1) * overallSize

                        local curAtt = category.atts[category.last]
                        local attData = CustomizableWeaponry.registeredAttachmentsSKey[curAtt]

                        surface.SetDrawColor(200, 255, 200, 255)
                        surface.DrawRect(x, baseY - 5, GAMEMODE.attachmentSlotDisplaySize, 5)

                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetTexture(attData.displayIcon)
                        surface.DrawTexturedRect(x + 2, baseY + 2, GAMEMODE.attachmentSlotDisplaySize - 4, GAMEMODE.attachmentSlotDisplaySize - 4)

                        curPos = curPos + 1
                    end
                end

                for i = 1, availableSlots do
                    local x = baseX + (i - 1) * overallSize

                    draw.ShadowText("Slot " .. i, GAMEMODE.AttachmentSlotDisplayFont, x + GAMEMODE.attachmentSlotDisplaySize - 5, baseY + GAMEMODE.attachmentSlotDisplaySize, self.HUDColors.white, self.HUDColors.black, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                end

                draw.ShadowText("Used slots " .. curPos - 1 .. "/" .. availableSlots , GAMEMODE.AttachmentSlotDisplayFont, ScrW() * 0.5, baseY + GAMEMODE.attachmentSlotDisplaySize + 20, self.HUDColors.white, self.HUDColors.black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        end
    end)
end

hook.Add("CW20HasAttachment", "GroundControl.CW20HasAttachment", function(ply, attachmentID, attList)
    return ply:hasUnlockedAttachment(attachmentID)
end)

hook.Add("AdjustMouseSensitivity", "GCR OverrideAimSens", function(wpnSens)
    -- This code was taken straight from the base - override it to stop scopes and attachments from slowing your sens to a crawl
    local ply = LocalPlayer()
    if ply and ply:Alive() then
        local plyWep = ply:GetActiveWeapon()
        local plyWepTable = plyWep:GetTable()
        if plyWep and plyWepTable then
            local sensitivity = 1
            local mod = math.Clamp(plyWepTable.OverallMouseSens or 1, 0.1, 1) -- !lower than 10% and !higher than 100% (in case someone uses atts that increase handling)
            local freeAimMod = 1

            if plyWep.freeAimOn and !plyWep.dt.BipodDeployed then
                local dist = math.abs(plyWep:getFreeAimDotToCenter())

                local mouseImpendance = GetConVar("cw_freeaim_center_mouse_impendance"):GetFloat()
                freeAimMod = 1 - (mouseImpendance - mouseImpendance * dist)
            end

            if plyWep.dt and plyWep.dt.State == CW_RUNNING and plyWepTable.RunMouseSensMod then
                return plyWepTable.RunMouseSensMod * mod
            end

            if plyWep.dt and plyWep.dt.State == CW_AIMING then
                -- if we're aiming and our aiming position is that of the sight we have installed - decrease our mouse sensitivity
                if (plyWepTable.OverrideAimMouseSens and plyWepTable.AimPos == plyWepTable.ActualSightPos) and
                (plyWep.dt.M203Active and CustomizableWeaponry.grenadeTypes:canUseProperSights(plyWepTable.Grenade40MM) or !plyWep.dt.M203Active) then
                    sensitivity = plyWepTable.OverrideAimMouseSens
                end

                sensitivity = math.Clamp(sensitivity - plyWepTable.ZoomAmount / 100, 0.1, 1)
            end

            sensitivity = sensitivity * mod
            sensitivity = sensitivity * freeAimMod
            sensitivity = math.Clamp(sensitivity, 0.3, 1) -- clamp final sens
            return sensitivity
        end
    end
end)

if SERVER then
    CustomizableWeaponry.callbacks:addNew("finalizePhysicalBullet", "GroundControl_finalizePhysicalBullet", function(self, bulletStruct)
        bulletStruct.penetrationValue = self.penetrationValue
    end)
end


function GM:OnPlayerHitGround(ply)
    ply:SetDTFloat(0, math.Clamp(ply:GetDTFloat(0) - 0.25, 0.5, 1))
    ply:SetDTFloat(1, CurTime() + 0.25)

    local vel = ply:GetVelocity()
    local len = vel:Length()
    local weightCorrelation = math.max(0, self.MaxWeight - len * self.HeavyLandingVelocityToWeight)

    if ply.weight >= weightCorrelation then
        ply:EmitSound("npc/combine_soldier/gear" .. math.random(3, 6) .. ".wav", 70, math.random(95, 105))
    end
end

function GM:attemptRestoreMovementSpeed(ply)
    if CurTime() > ply:GetDTFloat(1) then
        ply:SetDTFloat(0, math.Clamp(ply:GetDTFloat(0) + FrameTime(), 0, 1))
    end
end

function GM:PlayerStepSoundTime(ply, iType, bWalking)
    local len = ply:GetVelocity():Length()
    ply.StepLen = len
    local steptime =  math.Clamp(450 - len * 0.5, 100, 500)

    if ( iType == STEPSOUNDTIME_ON_LADDER ) then
        steptime = 450
    elseif ( iType == STEPSOUNDTIME_WATER_KNEE ) then
        steptime = 600
    end

    if ply:Crouching() then
        steptime = steptime + 50
    end

    return steptime
end

function GM:isPreparationPeriod()
    return CurTime() < self.PreparationTime
end

function GM:Move(ply, moveData)
    if !ply:Alive() or ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then
        return
    end

    if CurTime() < self.PreparationTime then
        moveData:SetMaxSpeed(0)
        local velocity = moveData:GetVelocity()
        velocity.x = 0
        velocity.y = 0
        moveData:SetVelocity(velocity)
        moveData:SetMaxClientSpeed(0)

        return
    end

    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.CW20Weapon and wep:isPlayerProne() then
        return
    end

    if SERVER then
        local jumpDown = ply:GetCurrentCommand():KeyDown(IN_JUMP)
        local onGround = ply:OnGround()

        if jumpDown then -- sure way to get whether the player jumped (ply:KeyDown(IN_JUMP) can be bypassed by simply running the command, !by pressing the key bound to the jump key)
            if onGround and ply.hasReleasedJumpKey then
                ply:setStamina(ply.stamina - ply:getJumpStaminaDrain()) -- fuck your bunnyhopping
                ply:delayStaminaRegen(self.JumpStaminaRegenDelay)
                ply.hasReleasedJumpKey = false
                --ply:EmitSound()
            end
        else
            if onGround then
                ply.hasReleasedJumpKey = true
            end
        end
    end

    ws, rs = ply:GetWalkSpeed(), ply:GetRunSpeed()
    -- for some reason the value returned by GetMaxSpeed is equivalent to player's run speed - 30
    local adrenalineModifier = 1 + ply:getRunSpeedAdrenalineModifier()
    local runSpeed = (GetConVar("gc_base_run_speed"):GetInt() - ply:getStaminaRunSpeedModifier() - ply:getWeightRunSpeedModifier()) * adrenalineModifier * ply:GetDTFloat(0)
    ply:SetRunSpeed(runSpeed)

    if ply:KeyDown(IN_SPEED) and !ply:Crouching() then
        local finalMult = 1

        if ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) then
            if ply:KeyDown(IN_FORWARD) then
                finalMult = finalMult - self.SidewaysSprintSpeedAffector
            else
                finalMult = finalMult - self.OnlySidewaysSprintSpeedAffector
            end
        end

        if ply:KeyDown(IN_BACK) then
            finalMult = finalMult - self.BackwardsSprintSpeedAffector
        end

        local finalRunSpeed = math.max(math.min(moveData:GetMaxSpeed(), runSpeed) * finalMult, GetConVar("gc_base_walk_speed"):GetInt())

        moveData:SetMaxSpeed(finalRunSpeed)
        moveData:SetMaxClientSpeed(finalRunSpeed)
    end
end

local PLAYER = FindMetaTable("Player")

function PLAYER:resetSpawnData()
    self.spawnWait = 0
end

function PLAYER:setSpectateTarget(target)
    self.currentSpectateEntity = target

    if SERVER then
        self:Spectate(self.spectatedCamera)
        self:SpectateEntity(target)

        net.Start("GC_SPECTATE_TARGET")
        net.WriteEntity(target)
        net.Send(self)
    end
end

function AccessorFuncDT(tbl, varname, name)
   tbl["Get" .. name] = function(s) return s.dt and s.dt[varname] end
   tbl["Set" .. name] = function(s, v) if s.dt then s.dt[varname] = v end end
end

function GM:didPlyVote(ply)
    local result = self.VotedPlayers[ply:SteamID64()]
    if result == nil then result = false end
    return result
end