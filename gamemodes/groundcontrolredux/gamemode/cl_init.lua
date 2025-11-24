GM.BleedData = {alpha = 0, targetAlpha = 20, approachRate = 100, lastPulse = 0, pulseInterval = 1}
GM.AdrenalineData = {currentVal = 0, soundTime = 0, approachRate = 0.25, soundDelay = 1}
GM.StaminaData = {alpha = 0, approachRate = 10, soundTime = 0, minSoundTime = 1.2, maxSoundTime = 1.5, minVolume = 30, maxVolume = 60}
GM.DeadPeriodState = 0
GM.DeadState = 0
GM.ObjectiveEntities = {}
GM.DrawEntities = {}

include("shared.lua")
include("sh_mixins.lua")
include("cl_hud.lua")
include("cl_weapon_selection_hud.lua")
include("cl_loop.lua")
include("cl_view.lua")
-- include("cl_player.lua")
include("sh_action_to_key.lua")
include("sh_keybind.lua")
include("sh_player_adrenaline.lua")
include("sh_player_bleeding.lua")
include("sh_player_stamina.lua")
include("sh_player_weight.lua")
include("sh_player_loadout_points.lua")
include("sh_player_gadgets.lua")
include("sh_player_cash.lua")
include("sh_player_armor.lua")
include("sh_attachments.lua")
include("cl_attachments.lua")
include("sh_loadout.lua")
include("sh_team.lua")
include("sh_radio.lua")
include("cl_net_msgs.lua")
include("cl_player_adrenaline.lua")
include("cl_gui.lua")
include("cl_team.lua")
include("cl_screen.lua")
include("sh_events.lua")
include("cl_scoreboard.lua")
include("cl_voting.lua")
include("sh_gametypes.lua")
include("cl_music_handler.lua")
include("sh_player_traits.lua")
include("cl_render.lua")
include("cl_voice_selection.lua")
include("sh_timelimit.lua")
include("cl_timelimit.lua")
include("sh_general.lua")
include("sh_tip_controller.lua")
-- include("cl_gametypes.lua")
include("sh_announcer.lua")
include("sh_footsteps.lua")
include("cl_status_display.lua")
include("sh_mvp_tracking.lua")
include("cl_killcount.lua")
include("sh_config.lua")
include("cl_config.lua")

GM.TeamSelectionKey = "gm_showhelp"
GM.LoadoutMenuKey = "gm_showteam"
GM.RadioMenuKey = "gm_showspare1"

function GM:InitPostEntity()
    local ply = LocalPlayer()
    ply.cash = ply.cash or 0
    ply:spawn()
    ply:ResetGadgetData()
    ply:resetAttachmentData()
    ply:ResetTraitData()

    self:postInitEntity()

    RunConsoleCommand("cw_customhud_ammo", "1")
    ply:SetHullDuck(self.DuckHullMin, self.DuckHullMax)
    ply:SetViewOffsetDucked(self.ViewOffsetDucked)

    self.tipController:LoadShownTips()
end

-- function GM:Tick()
-- 	self.localPlayer = LocalPlayer()

-- 	if self.localPlayer and IsValid(self.localPlayer) then
-- 		self.localPlayerTeam = self.localPlayer:Team()
-- 	end
-- end

local PLAYER = FindMetaTable("Player")

function PLAYER:spawn()
    local ply = LocalPlayer()
    ply:UpdateLoadoutPoints()
    ply:ResetBleedData()
    ply:ResetAdrenalineData()
    ply:ResetStaminaData()
    ply:ResetWeightData()
    GAMEMODE:RemoveAllStatusEffects()

    RunConsoleCommand("cw_freeaim_autocenter", 1)
    RunConsoleCommand("cw_freeaim_autocenter_time", 0.650000)
    RunConsoleCommand("cw_freeaim_center_mouse_impendance", 0.3)
    RunConsoleCommand("cw_freeaim_lazyaim", 0.03)
    RunConsoleCommand("cw_freeaim_yawlimit", 15)

    timer.Simple(1, function()
        for key, tipId in ipairs(GAMEMODE.tipController.genericTips) do
            local result = GAMEMODE.tipController:HandleTipEvent(tipId)

            if result == false or result == true then
                break
            end
        end
    end)
end

-- called upon the start of a new round
function GM:RoundPreparation(preparationTime)
    self:ResetAllStatusEffects()
    LocalPlayer():spawn()
    self:createRoundPreparationDisplay(preparationTime)
    self:DestroyMVPPanel()
end

-- called upon the end of a round
function GM:ResetRoundData()
    self:ResetTimeLimit()

    if GAMEMODE.curGametype.ResetRoundData then
        GAMEMODE.curGametype:ResetRoundData()
    end
end

function GM:ClearObjectiveEntities()
    self.ObjectiveEntities = {}
end

function GM:onLocalPlayerHurt(data, localPlayer)
    local damage = localPlayer:Health() - data.health
    self:playHurtEffect(damage)
end

-- 'data' is the data provided in the entity_killed event, called when you die
function GM:onLocalPlayerDied(data)
    local ply = LocalPlayer()

    self:RemoveAllStatusEffects()
    ply:ResetBleedData()
    ply:ResetAdrenalineData()
    ply:ResetStaminaData()
    ply:ResetWeightData()
end

-- 'data' is the same data from entity_killed, this is called when a player that dies
function GM:onPlayerDied(ply, data)
    if ply == LocalPlayer() then
        self:onLocalPlayerDied()
    else
        ply:ResetStatusEffects()
    end
end

function GM:AddObjectiveEntity(obj)
    table.insert(self.ObjectiveEntities, obj)
end

function GM:RemoveObjectiveEntity(obj)
    for key, otherObj in ipairs(self.ObjectiveEntities) do
        if obj == otherObj then
            table.remove(self.ObjectiveEntities, key)
            break
        end
    end
end

function GM:clearDrawEntities()
    self.DrawEntities = {}
end

function GM:AddDrawEntity(obj)
    table.insert(self.DrawEntities, obj)
end

function GM:RemoveDrawEntity(obj)
    for key, otherObj in ipairs(self.DrawEntities) do
        if obj == otherObj then
            table.remove(self.DrawEntities, key)
            break
        end
    end
end

function GM:resetVisualAdrenaline()
    local data = self.AdrenalineData
    data.currentVal = 0
    data.soundTime = 0
end

function GM:resetVisualStamina()
    local data = self.StaminaData
    data.alpha = 0
    data.soundTime = 0
end

function GM:SetLoadoutAvailabilityInfo(position, maxDuration)
    self.loadoutPosition = position
    self.loadoutDuration = maxDuration
end

function GM:handlePlayerRadioPress(ply, bind, pressed)
    if bind == "+attack2" then
        if self.RadioSelection.selectedCategory == 0 then
            self:ToggleRadio()
        else
            self.RadioSelection.selectedCategory = 0
        end
        return true
    end

    if bind:find("slot") then
        local selection = tonumber(bind:Right(1))

        if self.RadioSelection.selectedCategory == 0 and self.VisibleRadioCommands[selection] then
            self.RadioSelection.selectedCategory = selection
        elseif self.VisibleRadioCommands[self.RadioSelection.selectedCategory].commands[selection] then
            self:SelectRadioCommand(selection)
        end
        return true
    end
    return false
end

function GM:PlayerBindPress(ply, bind, pressed)
    if pressed then
        if self.DeadState == 3 then
            if bind == "+attack" then
                RunConsoleCommand("gc_spectate_next", false)
            -- elseif bind == "+attack2" then
            --     RunConsoleCommand("gc_spectate_next", true)
            -- elseif bind == "+jump" then
            --     RunConsoleCommand("gc_spectate_perspective")
            end
        end

        local wep = ply:GetActiveWeapon()

        if (IsValid(wep) and wep.CW20Weapon and wep.dt.State != CW_CUSTOMIZE) or !IsValid(wep) then
            if bind == self.TeamSelectionKey then
                RunConsoleCommand("gc_team_selection")
            elseif bind == self.LoadoutMenuKey then
                RunConsoleCommand("gc_loadout_menu")
            elseif bind == self.RadioMenuKey then
                RunConsoleCommand("gc_voice_menu")
            elseif bind == "undo" then
                RunConsoleCommand("use", self.KnifeWeaponClass)
            end
            if !self:isVoteActive() or (self:isVoteActive() and self:DidPlyVote(ply)) then
                if self.RadioSelection.active then
                    return self:handlePlayerRadioPress(ply, bind, pressed)
                elseif bind:find("slot") then
                    local selection = tonumber(bind:Right(1))

                    if self:showWeaponSelection(selection) then
                        ply:selectWeaponNicely(self.desiredWeaponToDraw)
                        return true
                    else
                        self:hideWeaponSelection()
                    end
                else
                    if bind == "invprev" then
                        self:cycleWeaponSelection(-1)
                    elseif bind == "invnext" then
                        self:cycleWeaponSelection(1)
                    elseif self:canSelectDesiredWeapon() then
                        if bind == "+attack" then
                            ply:selectWeaponNicely(self.desiredWeaponToDraw)
                            return true
                        elseif bind == "+attack2" then
                            self:hideWeaponSelection()
                        end
                    end
                end
            else
                if bind:find("slot") then
                    local selection = tonumber(bind:Right(1))

                    if self:attemptVote(selection) then
                        return true
                    end
                end
            end

            if self:performAction(bind) then
                return true
            end
        end
    end
end

function GM:HasDeadPeriodPassed()
    return CurTime() > self.deadPeriod
end

CustomizableWeaponry.callbacks:addNew("deployWeapon", "GroundControl_deployWeapon", function(self)
    if self.SpeedDec >= 20 then
        GAMEMODE.tipController:HandleTipEvent("FASTER_MOVEMENT")
    end
end)

CustomizableWeaponry.callbacks:addNew("postAttachAttachment", "GroundControl_postAttachAttachment", function(self, attCategory)
    local attachmentName = self.Attachments[attCategory].atts[self.Attachments[attCategory].last]

    if self.BackupSights and self.BackupSights[attachmentName] then
        GAMEMODE.tipController:HandleTipEvent("BACKUP_SIGHTS")
    end
end)

hook.Add("player_spawn", "GroundControl.player_spawn", function(data)
    local player = Player(data.userid)

    if IsValid(player) and player == LocalPlayer() then
        player:spawn()
    end
end)

gameevent.Listen("player_spawn")
