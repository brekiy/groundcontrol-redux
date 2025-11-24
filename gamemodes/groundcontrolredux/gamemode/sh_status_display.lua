-- status effects don't affect the player, these are only used for displaying them on the HUD

AddCSLuaFile()
AddCSLuaFile("cl_status_display.lua")

GM.StatusEffects = {}
GM.ActiveStatusEffects = {}

function GM:RegisterStatusEffect(data)
    self.StatusEffects[data.id] = data

    if CLIENT then
        data.texture = surface.GetTextureID(data.icon)
    end
end

GM:RegisterStatusEffect({
    id = "bleeding",
    icon = "ground_control/hud/status/bleeding_icon",
    text = "BLEEDING"
})

GM:RegisterStatusEffect({
    id = "crippled_arm",
    icon = "ground_control/hud/status/crippled_arm",
    text = "CRIPPLED"
})

GM:RegisterStatusEffect({
    id = "healing",
    icon = "ground_control/hud/status/healing",
    text = "RECOVERY",
    dontSend = true
})

-- add a status effect indicating that we're a medic
-- this is so that other people see who the medics are, to promote being healed by a medic over just bandaging yourself
GM:RegisterStatusEffect({
    id = "medic",
    icon = "ground_control/hud/status/healing",
    text = "MEDIC"
})


local PLAYER = FindMetaTable("Player")

-- set status effects for display on other players (!yourself), to see what's going on with your friends
function PLAYER:SetStatusEffect(statusEffect, state) -- on other players
    -- numeric for rendering (clientside), map for quick checks
    self.statusEffects = self.statusEffects or {numeric = {}, map = {}}

    if !state then
        for key, otherStatusEffect in ipairs(self.statusEffects.numeric) do
            if otherStatusEffect == statusEffect then
                table.remove(self.statusEffects.numeric, key)
                break
            end
        end

        self.statusEffects.map[statusEffect] = nil
    else

        -- make sure this effect isn't present yet
        if !self.statusEffects.map[statusEffect] then
            table.insert(self.statusEffects.numeric, statusEffect)
            self.statusEffects.map[statusEffect] = true
        end
    end

    if SERVER then
        self:SendStatusEffect(statusEffect, state)
    end
end

function PLAYER:ResetStatusEffects() -- on other players
    if !self.statusEffects then
        return
    end

    self.statusEffects.numeric = {}
    self.statusEffects.map = {}
end

function PLAYER:HasStatusEffect(statusEffect)
    return self.statusEffects and self.statusEffects.map[statusEffect]
end
