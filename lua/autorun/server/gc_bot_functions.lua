include("sv_gcbot_names.lua")

concommand.Add("gc_print_cur_weapon", function(ply, com, args)
    PrintTable(weapons.Get(ply:GetActiveWeapon():GetClass()))
end)

concommand.Add("gc_bot_add", function(ply, com, args)
    createGCBot()
end)
CreateConVar("gc_bot_nav_debug", 0, 1, "set to 1 to enable displaying of paths from bot navigators.")
function createGCBot()
    local bot = player.CreateNextBot(getBotName())
end
local Meta = FindMetaTable("Player")
local navareas = navmesh.GetAllNavAreas()
local sniperSpots = {}
for key, value in pairs(navareas) do
    local spots = value:GetExposedSpots()
    for spotKey, spotValue in pairs(spots) do
        sniperSpots[#sniperSpots + 1] = spotValue
    end
end

hook.Add("PlayerSpawn", "GCBotsSpawn", function(bot)
    if gmod.GetGamemode().Name != "Ground Control Redux" then return end
    if bot:IsBot() then
        if bot.nav != nil then
            if bot.nav:IsValid() then
                bot.nav:Remove()
            end
            bot.nav = ents.Create("gc_nextbot")
            bot.nav:SetOwner(bot)
            bot.nav:Spawn()
            bot.nav:SetPos(bot:GetPos())
        else
            bot.nav = ents.Create("gc_nextbot")
            bot.nav:SetOwner(bot)
            bot.nav:Spawn()
            bot.nav:SetPos(bot:GetPos())
        end
        -- print("assigned nextbot nav")
    end
end)

-- function capUrbanWarfare(bot)
--     local urbanWarfareCapZones = ents.FindByClass("gc_urban_warfare_capture_point")
--     PrintTable(urbanWarfareCapZones)
--     bot:MoveToPos(urbanWarfareCapZones[1])
-- end

-- timer.Create("GCBotUrbanWarfare", 1, 0, function()
--     if gmod.GetGamemode().Name != "Ground Control Redux" then return end

--     for i,bot in pairs(player.GetBots()) do
--         capUrbanWarfare(bot)
--     end
-- end)

hook.Add("StartCommand", "StartCommandExample", function( ply, cmd )
    if (!ply:IsBot() or !ply:Alive() or engine.ActiveGamemode() != "groundcontrolredux") then return end

    if ply.nav:IsValid() == false then
        ply.nav = ents.Create("gc_nextbot")
        ply.nav:SetOwner(ply)
        ply.nav:Spawn()
    end

    if ply:Health() > 0 then
        ply.nav:SetPos(ply:GetPos())
    else
        ply.nav:SetPos(Vector(0, 0, 50))
    end

    cmd:ClearMovement()
    cmd:ClearButtons()

    -- Bot has no enemy, try to find one
    if ( !IsValid( ply.target ) ) then
        -- Scan through all players and select one !dead
        for _, pl in player.Iterator() do
            -- Don't select dead players or self as enemies
            if ( !pl:Alive() or pl == ply or pl:Team() == ply:Team() ) then continue end
            ply.target = pl
        end
        -- TODO: Maybe add a Line Of Sight check so bots won't walk into walls to try to get to their target
        -- Or add path finding so bots can find their way to enemies
    end

    -- We failed to find an enemy, don't do anything
    if ( !IsValid( ply.target ) ) then return end

    -- Move forwards at the bots normal walking speed
    -- cmd:SetForwardMove( ply:GetRunSpeed() )

    -- Aim at our enemy
    if ( ply.target ) then
        cmd:SetViewAngles( ( ply.target:GetPos() - ply:GetShootPos() ):GetNormalized():Angle() )
    else
        cmd:SetViewAngles( ( ply.target:GetPos() - ply:GetShootPos() ):GetNormalized():Angle() )
    end
    ply:FollowPath(cmd, ply.target:GetPos(), 1000, 0.1, 100)
    -- Give the bot a crowbar if the bot doesn't have one yet
    -- if ( SERVER and !ply:HasWeapon( "weapon_crowbar" ) ) then ply:Give( "weapon_crowbar" ) end

    -- Select the crowbar
    -- cmd:SelectWeapon( ply:GetWeapon( "weapon_crowbar" ) )

    -- Hold Mouse 1 to cause the bot to attack
    cmd:SetButtons( IN_ATTACK )

    -- Enemy is dead, clear our enemy so that we may acquire a new one
    if ( !ply.target:Alive() ) then
        ply.target = nil
    end

end)

function Meta:FollowPath(cmd, goal, speed, turnspeed, stopatdist, nosee)
    local see = !nosee
    local nav = self.nav
    nav.PosGen = goal
    if nav.P == nil then return end
    local bot = self
    local look = nav.P:GetAllSegments() -- get segments of path
    local targ = nil -- vector
    if look != nil then -- if there are segments
        if look[2] != nil then -- if there is a second segment
            targ = look[2] -- targ is set to the second segment
            if targ.type == 0 then -- is the segment a normal walk segment
                targ = Vector(targ.pos.x,targ.pos.y,bot:GetPos().z) -- set to move towards the segment position
                if targ:Distance(bot:GetPos()) < 10 and look[3] != nil then
                    targ = Vector(look[3].pos.x,look[3].pos.y,bot:GetPos().z)
                end
            elseif targ.type == 1 then -- is the segment !a normal walk segment
                targ = look[2] -- try the 4th segment
                bot.jump = true
                if targ != nil then -- does the 4th segment exist
                    targ = bot:GetPos() + (bot:GetAimVector() * 1000)
                    cmd:SetForwardMove(speed)
                    self:LookAt(targ,cmd,turnspeed)
                    return
                end
            else
                bot.jump = true
                targ = Vector(targ.pos.x,targ.pos.y,bot:GetPos().z)
            end
        else
            targ = Vector(goal.x,goal.y,bot:GetPos().z)
        end
    else
        targ = goal
    end
    if targ == nil or goal == NULL then print("ERROR 0") return end
    self:LookAt(targ,cmd,turnspeed)
    if see then
        if (goal:Distance(self:GetPos()) < stopatdist and self:VisibleVec(goal + Vector(0,0,math.random(0, 25)))) then
            return true
        end
    else
        if (goal:Distance(self:GetPos()) < stopatdist) then
            return true
        end
    end
    cmd:SetForwardMove(speed)
    return false
end

function Meta:LookAt(pos, cmd, ler) -- goal is a Vector
    local ownpos = self:GetPos() -- or Vector(0,0,0)
    local xdiff = pos.x - ownpos.x
    local ydiff = pos.y - ownpos.y
    local zdiff = pos.z - ownpos.z
    local xydist = math.Distance(pos.x,pos.y,ownpos.x,ownpos.y)
    -- local xydist = pos:Distance(ownpos)
    yaw = math.deg(math.atan2(ydiff,xdiff))
    pitch = math.deg(math.atan2(-zdiff,xydist))
    if ler == nil then ler = LERP end
    -- if (cmd == nil or cmd == NULL or !IsValid(cmd)) then
        --ErrorNoHalt( "Bot attempted to call Meta:LookAt() without supplying a real 'cmd' variable!\n Role: " )
    -- end
    if (istarget == nil) then
        cmd:SetViewAngles(LerpAngle( ler, cmd:GetViewAngles(), Angle(pitch,yaw,0)))
        self:SetEyeAngles(LerpAngle( ler, self:EyeAngles(), Angle(pitch,yaw,0)))
    end
end