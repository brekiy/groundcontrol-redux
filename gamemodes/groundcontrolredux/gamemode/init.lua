--[[
    if you're looking through code in hopes of finding backdoors/etc - rest assured there are none
    if you find some weird console commands that do weird stuff (like adjust health, or set a team for all players or whatever) please let me know, it's debug code that I have forgotten to remove
    thank you for understanding!
]]--

GM.AutoUpdateConVars = {}
GM.defaultDoorMoveSpeed = 200 -- the default door move speed to set

CreateConVar("gc_door_move_speed", GM.defaultDoorMoveSpeed, {FCVAR_ARCHIVE, FCVAR_NOTIFY}) -- time in seconds that a player can remain without any input before we kick him out


function GM:RegisterAutoUpdateConVar(cvarName, onChangedCallback)
    self.AutoUpdateConVars[cvarName] = onChangedCallback

    cvars.AddChangeCallback(cvarName, onChangedCallback)
end

function GM:performOnChangedCvarCallbacks()
    for cvarName, callback in pairs(self.AutoUpdateConVars) do
        local curValue = GetConVar(cvarName)
        local finalValue = curValue:GetInt() or curValue:GetFloat() or curValue:GetString() -- we don't know whether the callback wants a string or a number, so if we can get a valid number from it, we will use that if we can't, we will use a string value

        callback(cvarName, finalValue, finalValue)
    end
end

GM:RegisterAutoUpdateConVar("gc_door_move_speed", function(cvarName, oldValue, newValue)
    GAMEMODE:AdjustDoorSpeeds()
end)

GM.doorClasses = {"func_door_rotating", "prop_door_rotating"}

function GM:AdjustDoorSpeeds()
    local newSpeed = GetConVar("gc_door_move_speed"):GetString()

    for i = 1, #self.doorClasses do
        local class = self.doorClasses[i]

        for key, obj in ipairs(ents.FindByClass(class)) do
            obj:SetKeyValue("Speed", newSpeed)
        end
    end
end


include("sh_mixins.lua")

include("sv_player_bleeding.lua")
include("sv_player_adrenaline.lua")
include("sv_player_stamina.lua")
include("sv_player_health_regen.lua")
include("sv_general.lua")

include("shared.lua")
include("sv_player.lua")
include("sv_loop.lua")
include("sh_keybind.lua")
include("sh_action_to_key.lua")
include("sh_events.lua")
include("sh_general.lua")
include("sv_player_weight.lua")
include("sv_player_loadout_points.lua")
include("sv_player_gadgets.lua")
include("sv_player_cash.lua")
include("sv_loadout.lua")
include("sv_attachments.lua")
include("sv_team.lua")
include("sv_starting_points.lua")
include("sv_radio.lua")
include("sv_downloads.lua")
include("sv_events.lua")
include("sv_rounds.lua")
include("sv_spectate.lua")
include("sv_player_armor.lua")
include("sv_voting.lua")
include("sv_maprotation.lua")
include("sv_gametypes.lua")
include("sv_votescramble.lua")
include("sv_player_traits.lua")
include("sv_timelimit.lua")
include("sv_custom_spawn_points.lua")
include("sv_remove_entities.lua")
include("sv_autobalance.lua")
include("sv_autodownload_map.lua")
include("sv_autopunish.lua")
include("sv_map_start_callbacks.lua")
include("sh_tip_controller.lua")
include("sh_entity_initializer.lua")
include("sh_announcer.lua")
include("sh_footsteps.lua")
include("sh_status_display.lua")
include("sh_mvp_tracking.lua")
include("sh_config.lua")
include("sv_config.lua")
include("sv_server_name_updater.lua")
include("sv_killcount.lua")
include("sv_net_strings.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
-- AddCSLuaFile("cl_player.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_loop.lua")
AddCSLuaFile("cl_view.lua")
AddCSLuaFile("cl_net_msgs.lua")
AddCSLuaFile("cl_gui.lua")
AddCSLuaFile("cl_screen.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_music_handler.lua")
AddCSLuaFile("cl_render.lua")
AddCSLuaFile("cl_voice_selection.lua")
AddCSLuaFile("cl_weapon_selection_hud.lua")
AddCSLuaFile("cl_config.lua")
AddCSLuaFile("cl_killcount.lua")

GM.MemeRadio = false -- hehe, set to true for very funny memes
GM.MVPTracker = mvpTracker.new()
GM.DamageLog = {} --- yoink from TTT

CustomizableWeaponry.canDropWeapon = false -- don't let the players be able to drop weapons using the cw_dropweapon console command

function GM:InitPostEntity()
    self:postInitEntity()
    self:SetGametype(self:GetGametypeFromConVar())
    self:AutoRemoveEntities()
    self:RunMapStartCallback()

    timer.Simple(1, function()
        self:resetStartingPoints()
    end)

    self:VerifyAutoDownloadMap()

    self:performOnChangedCvarCallbacks()
end

function GM:EntityTakeDamage(target, dmgInfo)
    dmgInfo:SetDamageForce(dmgInfo:GetDamageForce() * 0.35)

    if target:IsPlayer() then
        local attacker = dmgInfo:GetAttacker()

        if IsValid(attacker) then
            if !attacker:IsPlayer() then
                local owner = attacker:GetOwner() -- check whether they were hurt by an entity the owner of which is a player

                if IsValid(owner) and owner:IsPlayer() then
                    attacker = owner -- use the 'owner' as the attacker
                    print("attacker is owner ", attacker:Nick())
                end
            end

            if self.noTeamDamage and attacker:IsPlayer() and attacker:Team() == target:Team() and (attacker != target or self.RoundOver) then
                dmgInfo:ScaleDamage(0)
                return
            end
        end

        if attacker:IsPlayer() and attacker:Team() == target:Team() and self.AutoPunishEnabled then
            self:updateTeamDamageCount(attacker, math.min(target:Health(), dmgInfo:GetDamage()))
        end

        if target.currentTraits then
            local traits = GAMEMODE.Traits

            for key, traitConfig in ipairs(target.currentTraits) do
                local traitData = traits[traitConfig[1]][traitConfig[2]]

                if traitData.onTakeDamage then
                    traitData:onTakeDamage(target, dmgInfo)
                end
            end
        end
        if !dmgInfo:IsFallDamage() then
            local inflictor = dmgInfo:GetInflictor()

            -- if the inflictor matches the attacker, but it wasn't a suicide
            -- wtf is ply here?
            -- if inflictor == attacker and inflictor != ply then
            if inflictor == attacker then
                local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon()

                if IsValid(wep) then -- and the attacker has a valid weapon
                    inflictor = wep -- we assume that the inflictor should be the weapon
                end
            end
            AddDamageLogEntry(attacker, target, dmgInfo, inflictor:GetClass(), false)
        end
    end
end

-- we play a sound from a specific table instead
function GM:PlayerDeathSound()
    return true
end

-- wip
function AddDamageLogEntry(attacker, target, dmgInfo, wep, targetDied)
    local entryText = nil
    local targetNick = target:Nick()
    local attackerNick = nil
    if attacker and attacker:IsPlayer() then
        attackerNick = attacker:Nick()
    end
    if targetDied then
        if attacker and attacker:IsPlayer() and attacker != target then
            if attacker:Team() == target:Team() then
                entryText = Format("KILL: %s teamkilled %s with %s", attackerNick, targetNick, wep)
            else
                entryText = Format("KILL: %s killed %s with %s", attackerNick, targetNick, wep)
            end
        else
            entryText = Format("DEATH: %s bled out", targetNick)
        end
    elseif attacker and attacker:IsPlayer() then
        entryText = Format("HIT: %s shot %s with %s (%f dmg)", attackerNick, targetNick, wep, dmgInfo:GetDamage())
    end
    table.insert(GAMEMODE.DamageLog, entryText)
end

-- CSS fall damage approximation thanks to gmod wiki
function GM:GetFallDamage(ply, speed)
    return math.max(0, math.ceil(0.2418 * speed - 141.75))
end