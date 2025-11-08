GM.CashPerAssist = 50 -- depends on damage dealt, if you dealt 99.9% damage, you'll get 50$
GM.ExpPerAssist = 40

GM.MinHealthForCloseCall = 25
GM.MinHealthForSave = 25
GM.SaveEventTimeWindow = 5

GM.SendCurrencyAmount = {cash = nil, exp = nil}

CreateConVar("gc_proximity_voicechat", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}) -- if set to 1, nearby enemies will be able to hear other enemies speak
CreateConVar("gc_proximity_voicechat_distance", 256, {FCVAR_ARCHIVE, FCVAR_NOTIFY}) -- distance in source units within which players will hear other players
CreateConVar("gc_proximity_voicechat_global", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}) -- if set to 1, everybody, including your team mates and your enemies, will only hear each other within the distance specified by gc_proximity_voicechat_distance
CreateConVar("gc_proximity_voicechat_directional", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}) -- if set to 1, voice chat will be directional 3d sound (as described in the gmod wiki)
CreateConVar("gc_invincibility_time_period", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}) -- how long should the player be invincible for after spawning (for anti spawn killing in gametypes like urban warfare)
CreateConVar("gc_team_damage", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}) -- friendly fire enable

GM:RegisterAutoUpdateConVar("gc_proximity_voicechat", function(cvarName, oldValue, newValue)
    newValue = tonumber(newValue)
    GAMEMODE.proximityVoiceChat = newValue >= 1
end)

GM:RegisterAutoUpdateConVar("gc_proximity_voicechat_distance", function(cvarName, oldValue, newValue)
    newValue = tonumber(newValue)
    GAMEMODE.proximityVoiceChatDistance = newValue
end)

GM:RegisterAutoUpdateConVar("gc_proximity_voicechat_global", function(cvarName, oldValue, newValue)
    newValue = tonumber(newValue)
    GAMEMODE.proximityVoiceChatGlobal = newValue >= 1
end)

GM:RegisterAutoUpdateConVar("gc_proximity_voicechat_directional", function(cvarName, oldValue, newValue)
    newValue = tonumber(newValue)
    GAMEMODE.proximityVoiceChatDirectional3D = newValue >= 1
end)

GM:RegisterAutoUpdateConVar("gc_invincibility_time_period", function(cvarName, oldValue, newValue)
    newValue = tonumber(newValue)
    GAMEMODE.postSpawnInvincibilityTimePeriod = newValue or 3
end)

GM:RegisterAutoUpdateConVar("gc_team_damage", function(cvarName, oldValue, newValue)
    newValue = tonumber(newValue)
    GAMEMODE.noTeamDamage = newValue <= 0
end)

local PLAYER = FindMetaTable("Player")

function GM:PlayerInitialSpawn(ply)
    ply:ResetSpawnData()

    ply:SetTeam(TEAM_SPECTATOR)
    ply:KillSilent()
    ply:resetSpectateData()

    ply:LoadAttachments()
    ply:LoadCash()
    ply:LoadExperience()
    ply:LoadUnlockedAttachmentSlots()
    ply:LoadTraits()
    ply.lastDataRequest = 0
    ply.invincibilityPeriod = 0
    ply:SetNWInt("GC_SCORE", 0)
    ply:ResetLoadoutPoints()
    ply:SetDTFloat(0, 1) -- movement speed multiplier
    ply:SetDTFloat(1, 0) -- delay for movement speed multiplier reset
    ply.attackedBy = {}

    ply:initLastKillData()

    self:checkVoteStatus(ply)
    self:SendTimeLimit(ply)
    ply:SendGameType()

    if self.curGametype.PlayerInitialSpawn then
        self.curGametype:PlayerInitialSpawn(ply)
    end
end

function GM:PlayerAuthed(ply, steamID, uniqueID)
    self:verifyPunishment(ply)
end

local ZeroVector = Vector(0, 0, 0)

function GM:PlayerSpawn(ply)
    local team = ply:Team()

    if team == TEAM_SPECTATOR then
        ply:KillSilent()
        return false
    end

    ply.currentTraits = ply.currentTraits and table.Empty(ply.currentTraits) or {}
    ply.armor = {}
    ply:UnSpectate()
    ply:SendAttachments()
    ply:SetHealth(100)
    ply:SetMaxHealth(100)
    ply:SetJumpPower(190)
    ply:SetWalkSpeed(GetConVar("gc_base_walk_speed"):GetInt())
    ply:SetRunSpeed(GetConVar("gc_base_run_speed"):GetInt())
    ply:resetSpectateData()
    ply:ResetSpawnData()
    ply:ResetBleedData()
    ply:ResetAdrenalineData()
    ply:ResetStaminaData()
    ply:ResetWeightData()
    ply:resetRadioData()
    ply:resetRecentVictimData()
    ply:ResetTrackedArmor()
    ply:ResetHealthRegenData()
    ply:UpdateLoadoutPoints()
    ply:SetBandages(ply:GetDesiredBandageCount())
    ply:SetCanZoom(false)
    ply:resetLastKillData()
    ply:SetCrouchedWalkSpeed(self.CrouchedWalkSpeed)
    ply:SetVelocity(ZeroVector) -- fixes movement prediction issues since upon round start we're supposed to stand still
    ply.hasLanded = true
    ply.canPickupWeapon = true
    ply.crippledArm = false
    ply.sustainedArmDamage = 0 -- regardless of which arm was hit
    ply:setInvincibilityPeriod(self.postSpawnInvincibilityTimePeriod)
    table.Empty(ply.attackedBy)
    ply:SetHullDuck(self.DuckHullMin, self.DuckHullMax)
    ply:SetViewOffsetDucked(self.ViewOffsetDucked)
    ply:ResetStatusEffects()
    ply:ResetKillcountData()

    local desiredVoice = nil

    if self.curGametype.voiceOverride then
        if self.curGametype.name == "ghettodrugbust" and team == self.curGametype.gangTeam then
            if math.random(1, 2) == 1 then
                desiredVoice = "franklin"
            else
                desiredVoice = "trevor"
            end
        else
            desiredVoice = self.curGametype.voiceOverride[team]
        end
    end

    if !desiredVoice then
        if !self:AttemptSetMemeRadio(ply) then
            desiredVoice = ply:GetInfoNum("gc_desired_voice", 0)

            if !desiredVoice or desiredVoice == 0 then
                ply.voiceVariant = self.VisibleVoiceVariants[math.random(1, #self.VisibleVoiceVariants)].numId
            else
                local data = self.VoiceVariants[math.Clamp(desiredVoice, 1, #self.VoiceVariants)]

                if data.invisible then -- can't trick me :)
                    ply.voiceVariant = self.VisibleVoiceVariants[1].numId
                else
                    ply.voiceVariant = data.numId
                end
            end
        end
    else
        ply.voiceVariant = self.VoiceVariantsById[desiredVoice].numId
    end

    ply:SetModel(self:getVoiceModel(ply))

    self:positionPlayerOnMap(ply)

    ply:giveLoadout()
    self:SendTimeLimit(ply)

    if self.curGametype.PlayerSpawn then
        self.curGametype:PlayerSpawn(ply)
    end

    ply:SetupHands()
    ply:Give(self.KnifeWeaponClass)

    return true
end

function GM:DoPlayerDeath(ply, attacker, dmgInfo)
    ply:dropWeaponNicely(nil, VectorRand() * 20, VectorRand() * 200)
    ply:EmitSound("GC_DEATH_SOUND")
    if IsValid(attacker) and attacker:IsPlayer() then
        if attacker:Team() != ply:Team() then
            attacker.lastKillData.position = ply:GetPos()
            attacker.lastKillData.time = CurTime() + 6

            attacker:AddFrags(1)
            ply:AddDeaths(1)
            attacker:AddCurrency("ENEMY_KILLED", ply)
            self:TrackRoundMVP(attacker, "kills", 1)
            attacker:checkForTeammateSave(ply)
            attacker:IncreaseKillcount(ply)

            if ply:LastHitGroup() == HITGROUP_HEAD then
                attacker:AddCurrency("HEADSHOT")
                self:TrackRoundMVP(attacker, "headshots", 1)
            end

            if self:countLivingPlayers(attacker:Team()) == 1 then
                attacker:AddCurrency("ONE_MAN_ARMY")
            end
        else
            if ply != attacker then
                attacker:AddCurrency("TEAMKILL", ply)
            end
        end

        local inflictor = dmgInfo:GetInflictor()

        if inflictor == attacker and inflictor != ply then -- if the inflictor matches the attacker, but it wasn't a suicide
            local wep = attacker:GetActiveWeapon()

            if IsValid(wep) then -- and the attacker has a valid weapon
                inflictor = wep -- we assume that the inflictor should be the weapon
                -- if wep.isPrimary != nil and !wep.isPrimary then
                --     self:TrackRoundMVP(attacker, "pistol_kills", 1)
                -- end
            end
        end

        net.Start("GC_KILLED_BY")
        net.WriteEntity(attacker)
        net.WriteString(inflictor:GetClass())
        net.WriteBool(ply.bleedInflictor != nil)
        net.Send(ply)

        local markedSpots = self.MarkedSpots[attacker:Team()]

        if markedSpots then
            self:sanitiseMarkedSpots(attacker:Team())

            for key, data in pairs(markedSpots) do
                if data.radioData.onPlayerDeath then
                    data.radioData:onPlayerDeath(ply, attacker, data)
                end
            end
        end

        if attacker:Team() != ply:Team() then -- don't hand out kill assists for team-kills done by the opposing team
            for obj, damageAmount in pairs(ply.attackedBy) do -- iterate over all players that attacked us and give them assist money
                if IsValid(obj) and ply != attacker and obj != attacker then
                    local percentage = damageAmount / ply:GetMaxHealth()
                    obj:AddCurrency("KILL_ASSIST", nil, math.ceil(percentage * self.CashPerAssist), math.ceil(percentage * self.ExpPerAssist))
                end
            end
        end
        AddDamageLogEntry(attacker, ply, dmgInfo, inflictor:GetClass(), true)
    end

    if self.curGametype.GCPlayerDeath then
        self.curGametype:GCPlayerDeath(ply, attacker, dmgInfo)
    end

    ply.spawnWait = CurTime() + 5
    ply:CreateRagdoll()
end

function GM:disableCustomizationMenu()
    for _, ply in player.Iterator() do
        local wep = ply:GetActiveWeapon()

        if IsValid(wep) and wep.CW20Weapon and wep.dt.State == CW_CUSTOMIZE then
            wep.dt.State = CW_IDLE
        end
    end
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if listener == talker then -- if the talker is the listener they can always hear themselves, so don't run any extra logic in such cases
        return true
    end

    if self.RoundOver or GetConVar("sv_alltalk"):GetBool() then
        return true
    end

    if listener:Alive() and !talker:Alive() then
        return false
    end

    local differentTeam = talker:Team() != listener:Team()
    local canUseDirectional = false

    if self.proximityVoiceChat then
        local tooFar = listener:GetPos():Distance(talker:GetPos()) > self.proximityVoiceChatDistance

        if self.proximityVoiceChatGlobal then
            -- if global proximity chat is on, we check whether we're close enough to anyone, and if we are too far - disable voice
            if tooFar then
                return false
            end
        else -- if it isn't on, we check for whether the talker is an enemy, and if he is, but he's too far - we can't hear them
            if differentTeam and tooFar then
                return false
            end

            if self.proximityVoiceChatDirectional3D then
                canUseDirectional = differentTeam -- directional sound should !be active if teammate players can hear each other across the whole map
            end
        end
    else
        if differentTeam then
            return false
        end
    end

    return true, canUseDirectional
end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
    if !IsValid(talker) then
        return true
    end

    if self.RoundOver then
        return true
    end

    if listener:Alive() and !talker:Alive() then
        return false
    end

    if teamOnly and listener:Team() != talker:Team() then
        return false
    end

    return true
end

function GM:PostPlayerDeath(ply)
    --self:CheckRoundOverPossibility()

    if ply:Team() != TEAM_SPECTATOR and self.curGametype.PostPlayerDeath then
        self.curGametype:PostPlayerDeath(ply)
    end

    ply:delaySpectate(self.DeadPeriodTime)
end

GM.HitgroupDamageModifiers = {
    [HITGROUP_HEAD] = 3.5,
    [HITGROUP_CHEST] = 1,
    [HITGROUP_STOMACH] = 0.65,
    [HITGROUP_LEFTARM] = 0.45,
    [HITGROUP_RIGHTARM] = 0.45,
    [HITGROUP_LEFTLEG] = 0.55,
    [HITGROUP_RIGHTLEG] = 0.55
}

-- clear hitbox indexes in this table if you don't want players to drop their primary weapons when they get hit in their arms
GM.DropPrimaryHitgroup = {
    [HITGROUP_LEFTARM] = true,
    [HITGROUP_RIGHTARM] = true
}

-- how much arm damage the player has to sustain in order to drop the weapon
GM.DropPrimarySustainedDamage = 40


function GM:ScalePlayerDamage(ply, hitGroup, dmgInfo)
    local attacker = dmgInfo:GetAttacker()
    local damage = dmgInfo:GetDamage()
    local differentTeam = nil
    local attackerIsValid = IsValid(attacker)

    if attackerIsValid and attacker:IsPlayer() then
        differentTeam = attacker:Team() != ply:Team()
    end

    -- player is still invincible after spawning, remove any damage done and don't do anything
    if attacker != ply and attacker:IsPlayer() and CurTime() < ply.invincibilityPeriod then
        dmgInfo:ScaleDamage(0)
        return
    end

    -- disable all team damage if the server is configured that way
    if attackerIsValid and !differentTeam and attacker != ply then
        if self.noTeamDamage or self.RoundOver then
            dmgInfo:ScaleDamage(0)
        else
            dmgInfo:ScaleDamage(GetConVar("gc_team_damage_scale"):GetFloat())
        end

        return
    end

    ply:SetStamina(ply.stamina - damage)
    ply:Suppress(4, 0.25)
    if IsValid(attacker) and attacker:IsPlayer() then
        local penValue = nil

        if ply.LAST_HIT_BY_PHYSBUL then -- support for physical bullets in CW 2.0
            penValue = ply.LAST_HIT_BY_PHYSBUL.penetrationValue
            ply.LAST_HIT_BY_PHYSBUL = nil
        else
            local wep = attacker:GetActiveWeapon()

            if wep then
                penValue = GAMEMODE:GetAmmoPen(wep.Primary.Ammo, wep.penMod)
            end
        end

        -- Pass the unscaled damage into the armor damage calc
        if attacker:Team() != ply:Team() then
            dmgInfo:ScaleDamage(GetConVar("gc_damage_multiplier"):GetFloat())
            attacker:storeRecentVictim(ply)
            ply:storeAttacker(attacker, dmgInfo)
            ply:processArmorDamage(dmgInfo, penValue, hitGroup, true)
        else
            -- Team damage does no bleeding if it penetrates
            ply:processArmorDamage(dmgInfo, penValue, hitGroup, false)
        end
    end

    local damageModifier = self.HitgroupDamageModifiers[hitGroup]

    if damageModifier then
        dmgInfo:ScaleDamage(damageModifier)
    end

    if self.DropPrimaryHitgroup[hitGroup] then
        ply.sustainedArmDamage = ply.sustainedArmDamage + dmgInfo:GetDamage()

        if ply.sustainedArmDamage >= self.DropPrimarySustainedDamage then -- if we sustain enough damage, we force-drop the weapon, but only if it's primary
            ply:crippleArm()
        end
    end

    if differentTeam then
        GAMEMODE:TrackRoundMVP(attacker, "damage", dmgInfo:GetDamage())
    end

    local traits = GAMEMODE.Traits

    for key, traitConfig in ipairs(ply.currentTraits) do
        local traitData = traits[traitConfig[1]][traitConfig[2]]

        if traitData.onTakeDamage then
            traitData:onTakeDamage(ply, dmgInfo, hitGroup)
        end
    end
end

function GM:PlayerSwitchFlashlight(ply)
    return true
end

function GM:SetupPlayerVisibility(ply, viewEnt)
    if IsValid(viewEnt) then
        AddOriginToPVS(viewEnt:GetShootPos())
    end
end

function GM:PlayerShouldTaunt(ply, act)
    return false
end

function GM:PlayerDeathThink(ply)
    if !self.curGametype then
        return "a"
    end

    if self.curGametype.canSpawn then
        return self.curGametype:canSpawn(ply)
    else
        if player.GetCount() < 2 and (ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_JUMP)) then
            ply:Spawn()
            return true
        end

        return self.canSpawn
    end

    --[[if CT > ply.spawnWait then
        if ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_JUMP) then
            ply:Spawn()
            return true
        end
    end

    return false]]--
end

function GM:PlayerDisconnected(ply)
    if self.curGametype.PlayerDisconnected then
        self.curGametype:PlayerDisconnected(ply)
    end

    self:RemovePlayerFromReportedDeadList(ply)

    for key, plyObj in pairs(team.GetPlayers(ply:Team())) do
        if plyObj.currentSpectateEntity == self then
            plyObj:attemptSpectate()
        end
    end
end

function PLAYER:crippleArm()
    if self.crippledArm then
        return
    end

    local wepDropped = false

    -- iterate through all the weapons and make the person drop his primary wep when he gets creyoppled
    for key, wep in ipairs(self:GetWeapons()) do
        if IsValid(wep) and wep.CW20Weapon and wep.isPrimaryWeapon and !wep.dropsDisabled then
            self:dropWeaponNicely(wep, VectorRand() * 20, VectorRand() * 200)
            wepDropped = true
        end
    end

    if wepDropped then
        self:SendTip("DROPPED_WEAPON")
    end

    self:SetStatusEffect("crippled_arm", true)
    self.crippledArm = true
    self:SetWeight(self:CalculateWeight())
end

function PLAYER:uncrippleArm()
    if self.crippledArm then
        self.crippledArm = false
        self:SetStatusEffect("crippled_arm", false)
        return true
    end

    return false
end


function PLAYER:dropWeaponNicely(wepObj, velocity, angleVelocity) -- velocity and angleVelocity is optional
    wepObj = wepObj or self:GetActiveWeapon()

    if IsValid(wepObj) and wepObj.dropsDisabled then
        return
    end
    -- TODO (brekiy): make this more general for other bases in the future
    local testPhysObj = ents.Create("cw_dropped_weapon")
    testPhysObj:setWeapon(wepObj)
    if testPhysObj:GetPhysicsObject() then
        local pos = self:EyePos()
        local ang = self:EyeAngles()

        pos = pos + ang:Right() * 6 + ang:Forward() * 40 - ang:Up() * 5

        CustomizableWeaponry:dropWeapon(self, wepObj, velocity, angleVelocity, pos, ang)
    else
        CustomizableWeaponry:dropWeapon(self)
    end
    testPhysObj:Remove()
end

function PLAYER:storeAttacker(attacker, dmgInfo)
    local pastDamage = self.attackedBy[attacker] or 0
    pastDamage = math.Clamp(pastDamage + dmgInfo:GetDamage(), 0, self:GetMaxHealth())

    self.attackedBy[attacker] = pastDamage
end

function PLAYER:storeRecentVictim(victim)
    self.recentVictim.object = victim
    self.recentVictim.timeWindow = CurTime() + GAMEMODE.SaveEventTimeWindow
end

function PLAYER:resetRecentVictimData()
    self.recentVictim = self.recentVictim or {}
    self.recentVictim.object = nil
    self.recentVictim.timeWindow = nil
end

function PLAYER:initLastKillData()
    self.lastKillData = {position = nil, time = 0}
end

function PLAYER:resetLastKillData()
    self.lastKillData.position = nil
    self.lastKillData.time = 0
end

function PLAYER:checkForTeammateSave(victim)
    local recentVictim = victim.recentVictim
    local victimObj = recentVictim.object

    if IsValid(victimObj) then -- make sure the person was attacking someone and it weren't us
        if victimObj != self and victimObj:Health() > 0 then
            if CurTime() < recentVictim.timeWindow then
                if victimObj:Health() <= GAMEMODE.MinHealthForSave then
                    self:AddCurrency("TEAMMATE_SAVED")
                else
                    self:AddCurrency("TEAMMATE_HELPED")
                end
            end
        else
            if self:Health() <= GAMEMODE.MinHealthForCloseCall and self:Alive() then
                self:AddCurrency("CLOSE_CALL")
            end
        end
    end
end

function PLAYER:AddCurrency(event, entity, cash, exp)
    local eventData = GAMEMODE:GetEventByName(event)
    cash = cash or eventData.cash
    exp = exp or eventData.exp
    if exp and cash then
        self:AddCash(cash)
        self:AddExperience(exp)

        GAMEMODE.SendCurrencyAmount.exp = exp
        GAMEMODE.SendCurrencyAmount.cash = cash

        if entity then
            GAMEMODE.SendCurrencyAmount.entity = entity:EntIndex()
        else
            GAMEMODE.SendCurrencyAmount.entity = nil
        end

        GAMEMODE:sendEvent(self, event, GAMEMODE.SendCurrencyAmount)
        return
    end

    if exp then
        self:AddExperience(exp, event)
    end

    if cash then
        self:AddCash(cash, event)
    end
end

function PLAYER:restoreHealth(amount)
    self:SetHealth(math.min(self:Health() + amount, self:GetMaxHealth()))
end

function PLAYER:sendPlayerData()
    self:SendCash()
    self:SendExperience()
    self:SendAttachments()
    self:SendUnlockedAttachmentSlots()
    self:sendTraits()
end

function PLAYER:setSpawnPoint(vec)
    self.spawnPoint = vec

    if GAMEMODE.LoadoutSelectTime then
        if GAMEMODE.curGametype.CanReceiveLoadout and !GAMEMODE.curGametype:CanReceiveLoadout(self) then
            return
        end

        net.Start("GC_LOADOUTPOSITION")
        net.WriteVector(vec)
        net.WriteFloat(GAMEMODE.LoadoutSelectTime)
        net.Send(self)
    end
end

function PLAYER:SendStatusEffect(id, state)
    net.Start("GC_STATUS_EFFECT")
    net.WriteString(id)
    net.WriteBool(state)
    net.Send(self)

    local statusEffect = GAMEMODE.StatusEffects[id]

    if !statusEffect.dontSend then
        -- I don't know whether the "send to players in list" not working bug was fixed yet, so I'll just iterate over the list and call net.Send individually
        for key, playerObject in ipairs(team.GetPlayers(self:Team())) do
            if playerObject != self then
                net.Start("GC_STATUS_EFFECT_ON_PLAYER")
                net.WriteEntity(self)
                net.WriteString(id)
                net.WriteBool(state)
                net.Send(playerObject)
            end
        end
    end
end

function PLAYER:setInvincibilityPeriod(time) -- used for anti-spawncamp systems
    self.invincibilityPeriod = CurTime() + time
end

function GM:PlayerSetHandsModel(ply, ent)
    local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
    local info = player_manager.TranslatePlayerHands(simplemodel)
    if info then
       ent:SetModel(info.model)
       ent:SetSkin(info.skin)
       ent:SetBodyGroups(info.body)
    end
 end

concommand.Add("gc_request_data", function(ply, com, args)
    if CurTime() < ply.lastDataRequest then
        return
    end

    ply:sendPlayerData()

    ply.lastDataRequest = CurTime() + 1
end)

concommand.Add("gc_assignbotstoteam", function(ply)
    for key, value in pairs(player.GetBots()) do
        value:SetTeam(math.random(TEAM_RED, TEAM_BLUE))
        value:ResetTrackedArmor()
        value:Spawn()
    end
end)

hook.Add("CW20_PickedUpCW20Weapon", "GC_CW20_PickedUpCW20Weapon", function(ply, droppedWeaponObject, newWeaponObject) -- newWeaponObject is the :Give'n weapon object
    for key, wepObj in ipairs(ply:GetWeapons()) do -- drop any matching weapons that aren't this one (we can only carry 1 primary)
        if wepObj != newWeaponObject and wepObj.Slot == newWeaponObject.Slot then
            ply:dropWeaponNicely(wepObj)
            ply.canPickupWeapon = false -- prevent weapon pickups until we finish assigning attachments to the weapon
            ply:SendTip("PICKUP_WEAPON")
        end
    end
end)

hook.Add("CW20_FinishedPickingUpCW20Weapon", "GC_CW20_FinishedPickingUpCW20Weapon", function(ply, newWeaponObject)
    ply.canPickupWeapon = true -- we did it, now we can pick up weapons again
end)

hook.Add("CW20_PreventCWWeaponPickup", "GC_CW20_PreventCWWeaponPickup", function(wepObj, ply)
    return !ply.canPickupWeapon or (ply.sustainedArmDamage >= GAMEMODE.DropPrimarySustainedDamage and weapons.GetStored(wepObj:GetWepClass()).isPrimaryWeapon)
end)