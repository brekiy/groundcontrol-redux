
--[[

    TODO:
        DONE 3/2/19 @ ??:?? (-) Detectives drop health stations
        DONE 3/6/19 @ ??:?? (-) Enable bots' pathing to and using health stations.
        DONE 3/6/19 @ ??:?? (-) Check if Detectives currently buy UMP
        DONE 3/6/19 @ ??:?? (-) Make bots occasionally RDM based on the ConVar.
        DONE 3/6/19 @ ??:?? (-) Add RDM ConVar to GUI.
        DONE 3/6/19 @ ??:?? (-) Allow bots to spot C4
        DONE 3/8/19 @ 1:02 AM (-) Chats should be based upon the bots' personalities.
        DONE 3/8/19 @ 4:05 PM (-) Traitors should always know where C4 is and avoid it.
        IMPOSSIBLE (-) Disguisers should have an effect
        IMPOSSIBLE (-) Radios should have an effect

        (-) Allow Human KOS messages :  refer to KOSRequests table
        (-) Optional C4, off by default

    bot crate destroying is broken
]]


local HEALTHSTATION = "weapon_ttt_health_station"
local UMP = "weapon_ttt_stungun"

print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
print()
print("TTT Bots Rework is initializing.")
print()
print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

include("ttt_bot_profiles.lua")
include("ttt_bot_chat.lua")

util.AddNetworkString( "RequestAddBots" )
util.AddNetworkString( "RequestKickBots" )
util.AddNetworkString( "ClientDisplayInfo" )
util.AddNetworkString( "RequestMenu" )
util.AddNetworkString( "RequestAddCustomBot" )

local Meta = FindMetaTable("Player")
profiles = bot_profiles

local DIFF = 1 // 4 / 4

local KOSRequests = {} -- a list of player-called KOS requests.

local tttlogs = {} -- logs of users shooting near other players or attacking other players
local crates = {} -- list of all crates on the map (depricated)
local traitors = {} -- table of known traitors for this round.
local innocents = {}
local bombspots = {}
local sniperspots = {}
local sus = {}
local tbombs = {} // list of bombs for TRAITORS ONLY
local bombs = {}
local massinit = true -- obsolete, however im keeping it here just in case something breaks when I take it out
local corpses = {}
local rdmer = nil

local roundPlans = {}

--[[local traitorPlans = {
    ["Bomb Blitz"] = {
        planter = true, // is a planter going to be picked
        massMult = 2.5, // massacre wait time multiplier
        waveDelay = 0, // delay inbetween chosen bots
        wavePct = 1 // percent of traitors chosen to attack
    },
    ["Blitz"] = {
        planter = false,
        massMult = 0.5,
        waveDelay = 0,
        wavePct = 1
    },
    ["Bomb OAAT"] = { // Bomb and send One At A Time
        planter = true,
        massMult = 2.5,
        waveDelay = 10,
        wavePct = 0.01
    },
    ["OAAT"] = { // Bomb and send One At A Time
        planter = false,
        massMult = 0.5,
        waveDelay = 10,
        wavePct = 0.01
    }
}]]

local personalities = {
    { -- 0, nbghserd
        hide=true,
        groups=false,
        mean=true,
        tgtspd = 2,
        ump=true
    },
    { -- 1, mean teamer
        hide=false,
        groups=true,
        mean=true,
        tgtspd = 1
    },
    { -- 2, semi nbghserd
        hide=false,
        snipes = true,
        groups=false,
        mean=false,
        tgtspd = 1.5,
        ump=true
    },
    { -- 3, team player
        hide=false,
        groups=true,
        mean=false,
        snipes=true,
        tgtspd = 1
    }
}

local nav = navmesh.GetAllNavAreas()
for _i,_v in pairs(nav) do
    local spots = _v:GetHidingSpots()
    for i,v in pairs(spots) do
        bombspots[#bombspots+1] = v
    end

    local spts = _v:GetExposedSpots()
    for i,v in pairs(spts) do
        sniperspots[#sniperspots+1] = v
    end
end

local DISABLEHIDING = 0
local ROAMWALK = 1
local WPM = 20
local roundIsActive = true

function Meta:UseHealthStation(cmd)
    local bot = self;
    local hs = nil;
    local ver = 99999
    for i,v in pairs(ents.GetAll()) do
        if v:GetClass() == "ttt_health_station" then
            if v:Visible(bot) and v:GetPos():Distance(bot:GetPos()) < ver then
                hs = v;
                ver = v:GetPos():Distance(bot:GetPos())
            end
        end
    end
    if (hs != nil) then
        if (bot:FollowPath(cmd,hs:GetPos()+Vector(0, 0, 10),1000,0.2,300)) then
            bot:LookAt(hs:GetPos(), cmd, 0.2)
            cmd:SetButtons(IN_USE)
            //hs:Use(bot)
        end
        return true
    end
    return false
end

function Meta:IsKnownTraitor()
    for i,v in pairs(traitors) do
        if v == self then return true end
    end
    return false
end

/*
local function WasShootingJustified(log) -- EXPERIMENTAL VERSION
    local just = false
    local atk = log.attacker
    local vic = log.victim
    local time = log.timestamp
    local near = log.nearply
    local hurt = log.hurt
    if hurt == nil then hurt = false end
    local caseid = #tttlogs+1
    --[[
        A shooting is only justified when:
            1. The victim is a known traitor.
            2. The victim randomly shot within 8 seconds.
            3. The victim shot next to another user within 16 seconds.
            4. The victim shot somebody within 64 seconds.
        A shooting is never justified when:
            1. The victim was a detective.
            2. The victim was a proven innocent.
        A shooting is always justified when:
            1. The attacker is a proven traitor.
    ]]
    if near then
        for i,v in pairs(tttlogs) do
            local vatk = v.attacker
            if vatk == vic then
                if !v.nearply then
                    if (CurTime()-v.timestamp < 8) then -- if they shot for no reason within 8 seconds, then it's okay to kill the victim.
                        just = true 
                    end
                else
                    if (CurTime()-v.timestamp < 16) then -- if they shot next to a player within 16 seconds from now, then it's ok
                        just = true
                    end
                end
                if hurt then
                    if (CurTime()-v.timestamp < 64) then -- if they shot another player within a minute then it is just
                        just = true
                    end
                end
            end
            if v.justified then just = false end
        end
        if vic:IsKnownTraitor() then just = true end
        if vic:GetRoleString() == "detective" then just = false end
        if vic:IsPlayerProven() then just = false end
    end
    if atk:IsKnownTraitor() then just = false end
    log.justified = just
    return log
end*/

local function WasShootingJustified(log) -- Non-experimental version
    if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    local just = false
    local atk = log.attacker -- player: who was the engager?
    local vic = log.victim -- player or nil: who was effected?
    local time = log.timestamp -- float: what time did it happen?
    local near = log.nearply -- bool: was it near a player?
    local hurt = log.hurt -- bool: was someone hurt?
    if vic != nil then
        just = vic.guilty
    else
        just = false 
    end

    if just == false and vic != nil then atk.guilty = true end
    if vic != nil then
        if vic:IsKnownTraitor() then vic.guilty = true; just = true end
        if vic:GetRoleString() == "detective" then just = false; atk.guilty = true end
        if vic.shoot == nil then vic.shoot = 0 end
        if vic.shoot > 0 and vic:GetRoleString() == "traitor" then just = true; end
    end
    if atk:GetRoleString() == "detective" then just = true; end
    --print(atk,vic,time,near,hurt,"just: ",just)
    log.justified = just
    return log
    -- log.hurt
    -- log.nearply
    -- log.attacker
    -- log.victim (nil?)
end

function Meta:IsPlayerProven()
    for i,v in pairs(innocents) do
        if v == self then return true end
    end
    return false
end

function Meta:InitializeBot(profile)
    local bot = self
    local name = bot:Nick()
    bot.profile = profile -- the bot profile
    bot.massinit = false // a boolean determining whether or not the traitor bot is to go on a rampage
    bot.personality = profile.personality // the personality # from the bots profile
    bot.accuracy = profile.accuracy // the accuracy from the bots profile
    bot.nav = ents.Create("ttt_bots_nextbot") // create the nav
    bot.nav:SetOwner(bot) // set the owner so it doesnt ocllide
    bot.nav:Spawn() // spawn the nav into the world
    bot.target = nil // who the bot is shooting at or attacking with a melee
    bot.lastseen = Vector(0,0,0) // the last position that the target was seen at
    bot.hidemode = false // determines if the bot is actively searching for a hiding spot
    bot.crouch = false // is the bot crouching?
    bot.jump = false // is the bot jumping?
    bot.roam = Vector(0,0,0) // the roam vector of the bot
    bot.willroam = true // if the bot will roam around or not
    bot.armed = false // if the bot has a gun
    bot.use = 0 // when 0, the bot can interact with doors
    bot.touse = false
    bot.tilt = 1.00 // accuracy modifier based on win/loss ratio of this bot.
    timer.Create("usetimer of bot "..bot:Nick(), 1, 0, function()
        if !IsValid(bot) then timer.Destroy("usertimer of bot "..name) return end
        bot.use = math.max(0,bot.use-1)
    end)
    bot.hidingspots = bot.nav:FindSpots({type='hiding',radius=99999})
end

function Meta:BotSay(text,tea) -- adds a typing delay for the bots, add cmd to make bot stop to type
    if self.chatting == nil then
        local t = string.len(text)
        t = tonumber(t)
        self.chatting = true
        timer.Simple(t/WPM, function()
            if self:Health() > 0 and !self:IsSpec() then
                if (GetConVar("ttt_bot_enable_chat"):GetInt() == 1) then
                    self:Say(text,tea)
                end
            end
            self.chatting = nil
        end)
    end
end

function Meta:IsLookingNear( target )
    local ply = self
    local targetVec = target:GetPos()
    --print(target:Nick(),ply:VisibleVec(target:EyePos()), ply:GetAimVector():Dot( ( targetVec - ply:GetPos() + Vector( 70 ) ):GetNormalized() )," | ",(ply:VisibleVec(target:EyePos()) and ply:GetAimVector():Dot( ( targetVec - ply:GetPos() + Vector( 70 ) ):GetNormalized() ) > 0.94))
    return (ply:VisibleVec(target:EyePos()) and ply:GetAimVector():Dot( ( targetVec - ply:GetPos() + Vector( 70 ) ):GetNormalized() ) > 0.90)
end

function Meta:ClosestLook(thresh) -- percentage
    local ply = self
    local highest = 0
    local _target = nil
    for i,target in pairs(player.GetAll()) do
        if target != ply then
            local targetVec = target:GetPos()
            local numb = ply:GetAimVector():Dot( ( targetVec - ply:GetPos() + Vector( 70 ) ):GetNormalized() )
            local look = (ply:VisibleVec(target:EyePos()) and numb > thresh)
            if look and numb > highest then
                highest = numb
                _target = target
            end
        end
    end
    if highest > thresh then
        return _target
    else
        return nil
    end
end

local rand = math.random(0,100)
local DOORS = {}

local chosendetective = nil

local function detectiveBuy()
    local detectives = GetDetectiveBots()
    for i,bot in pairs(detectives) do
        if personalities[bot.personality+1].ump then
            local g = bot:Give("weapon_ttt_stungun")
            bot.override = g
        else
            local g = bot:Give("weapon_ttt_health_station")
            bot.override = g
            //print("Does the bot have it?",bot:HasWeapon("weapon_ttt_health_station"))
        end
    end
end

local function detectiveTeamWork() -- called on round start
    local detectives = GetDetectiveBots()

    for i,bot in pairs(detectives) do
        if personalities[bot.personality+1].ump then
            bot:Give("weapon_ttt_stungun")
        else
            //bot:Give("weapon_ttt_health_station")
        end
    end
    if GetConVar("ttt_bot_detective_teamwork"):GetBool() then

        if #detectives > 0 then
            chosendetective = table.Random(detectives)
            chosendetective:BotSay("Detectives, follow me.")
        end
    end
end

function Meta:detectiveCoordinate(cmd) -- called every frame
    if GetConVar("ttt_bot_detective_teamwork"):GetBool() then
        local bot = self
        local isleader = (self == chosendetective)
        local leader = chosendetective
        if leader == nil then
            chosendetective = bot
            leader = bot
            chosendetective:BotSay("Detectives, follow me.")
        end
        if leader != nil and IsValid(leader) then
            if leader:Health() <= 0 then
                chosendetective = bot
                leader = bot
                chosendetective:BotSay("Detectives, follow me.")
            end
            if !isleader then -- if not leader
                bot:FollowPath(cmd,leader:GetPos(),1000,0.2,200)
                else -- if is leader
                bot.willroam = true
            end
        end
    end
end

function Meta:GetInnocentExposure() -- return no. of innocents that are near this ply
    local no = 0
    for i,v in pairs(GetNonTraitors()) do
        if v != self and v:Health() > 0 then
            if v:Visible(self) then
                no = no + 1
            end
        end
    end
    return no
end

local planter = nil
function initiateMassacre()
    --massinit = true
    for i,v in pairs(GetTraitorBots()) do
        //print(v:Nick().." is a traitor and will attack "..30*personalities[v.personality+1].tgtspd.." seconds into the round.")
        timer.Simple(30*personalities[v.personality+1].tgtspd, function()
            if IsValid(v) then
                v.massinit = true
                if planter != v then
                    if v.target == nil then
                        --print("massacrer "..v:Nick(),v.personality)
                        if v.personality == 0 or v.personality == 3 then
                            -- select a random target regardless of circumstance
                            v.target = table.Random(GetNonTraitors())
                            //v.noshoot = true
                        else
                            -- attempt to find a more covert target
                            for _i,tar in pairs(GetNonTraitors()) do
                                if tar:GetInnocentExposure() < 2 then
                                    v.target = tar
                                    //v.noshoot = true
                                end
                            end
                            if v.target == nil then -- in case there are no players alone
                                v.target = table.Random(GetNonTraitors())
                                //v.noshoot = true
                            end
                        end
                    end
                end
            end
        
        end)
    end
    /*timer.Simple(15, function()
        if roundIsActive then
            for i,v in pairs(GetTraitorBots()) do
                v.noshoot = nil
            end
        end
    end)*/
end
local nav = nil
hook.Add("TTTBeginRound", "TTTBotBeginRound", function()
    tttlogs = {}
    sus = {}
    rand = math.random(0,100)
    innocents = {}
    traitors = {}
    corspes = {}
    bombs = {}
    tbombs = {}
    roundIsActive = true
    if GetConVar("ttt_bot_rdm"):GetInt() == 1 then
        rdmer = table.Random(GetInnocentBots())
        repeat
            rdmer.target = table.Random(GetInnocentBots())
        until rdmer.target != rdmer
        rdmer.noshoot = nil
        rdmer.guilty = true // imperative : you don't want players to shoot the rdmer and get killed for it
        timer.Simple(6, function() if IsValid(rdmer) then traitors[#traitors+1] = rdmer end end)
        
        //print(rdmer:Nick().. " has been set to rdm "..rdmer.target:Nick())
    end
    if (rand < 30) then
        if GetConVar("ttt_bot_plant_bombs"):GetInt() == 1 then
            planter = table.Random(GetTraitorBots())
        end
    else
        planter = nil
    end

    if nav == nil then
        nav = navmesh.GetAllNavAreas()
        for _i,_v in pairs(nav) do
            local spots = _v:GetHidingSpots()
            for i,v in pairs(spots) do
                bombspots[#bombspots+1] = v
            end

            local spts = _v:GetExposedSpots()
            for i,v in pairs(spts) do
                sniperspots[#sniperspots+1] = v
            end
        end
    end
    
    for i,bot in pairs(player.GetBots()) do
        bot.massinit = false
        bot.c4 = false
        bot.target = nil
        bot.willroam = true
        bot.guilty = false
        bot.sniping = false
        bot.variation = math.random(1,100)
        bot.sniperspot = table.Random(sniperspots)
        if bot:HasWeapon("weapon_zm_rifle") and personalities[tonumber(bot.personality)+1].snipes and bot:GetRoleString() == "innocent" then
            bot.willroam = false 
            bot.sniping = true
        end
        --bot.target = table.Random(player.GetBots())
    end
    for i,ply in pairs(player.GetAll()) do
        ply.sus = 0
        ply.shoot = 0
    end

    
    detectiveBuy()
    detectiveTeamWork()
    initiateMassacre()
    --timer.Simple(25, function() if roundIsActive then initiateMassacre(); end end)
end)

hook.Add("TTTEndRound", "TTTBotEndRound", function(result)
    tttlogs = {}
    sus = {}
    innocents = {}
    traitors = {}
    corpses = {}
    bombs = {}
    tbombs = {}
    roundIsActive = false
    
    
    for i,bot in pairs(player.GetBots()) do
        bot.massinit = false
        bot.c4 = nil
        if result == WIN_TRAITOR then
            if bot:GetRoleString() == "traitor" then
                bot.tilt = bot.tilt + 0.03
            else
                bot.tilt = bot.tilt - 0.05
            end
        else
            if bot:GetRoleString() == "innocent" then
                bot.tilt = bot.tilt + 0.03
            else
                bot.tilt = bot.tilt - 0.05
            end
        end
        if (bot.tilt > 3) then bot.tilt = 3 end
        if bot.tilt < 0.2 then bot.tilt = 0.2 end
        bot.target = nil
    end
end)

function Meta:PlantC4(cmd)
    local bot = self
    if bot.c4 then return true end
    local down = false
    local cfour = nil
    for i,CFour in pairs(ents.GetAll()) do
        if CFour:GetClass() == "ttt_c4" then
            if VecDist(CFour:GetPos(),bot:GetPos()) < 300 then
                /*CFour:SetArmed(true) -- arm the c4
                bot.c4 = true
                break*/
                down = true
                cfour = CFour
                tbombs[#tbombs+1] = CFour
            end
        end
    end
    if down == false then
        if bot:HasWeapon("weapon_ttt_c4") then
            bot:SelectWeapon("weapon_ttt_c4")
            cmd:SetButtons(IN_ATTACK)
        else
            bot:Give("weapon_ttt_c4")
        end
    else
        cfour:Arm(bot, 45)
        bot.c4 = true
        bot:BotSay(ttt_bot_gchat(bot.personality,"c4plant","err"),true)        
        return true 
    end
    return false
end

function Meta:MoveToBombSpot(cmd)
    local bspot = nil
    local d = 999999
    local spots = table.Copy(bombspots) 
    //PrintTable(spots)

    for i,v in pairs(spots) do
        local e = true
        for x,y in pairs(GetNonTraitors()) do
            if y:VisibleVec(v) then
                e = false
            end
        end
        if e then
            if bspot == nil then
                bspot = v
            else
                if (math.Distance(self:GetPos().x, self:GetPos().y, v.x, v.y) < d) then
                    d = math.Distance(self:GetPos().x, self:GetPos().y, v.x, v.y)
                    bspot = v
                end
            end
        end
    end
    if bspot != nil then
        if(self:FollowPath(cmd,bspot+Vector(0,0,100),1000,0.08,280)) then
            if (self:PlantC4(cmd)) then
                self.willroam = true
                planter = nil
            end
        else
            if self.armed == false then
                cmd:SelectWeapon(self:GetWeaponByClass("weapon_zm_improvised"))
            else
                cmd:SelectWeapon(self:getBotWeapon())
            end
        end
    end
end

function Meta:AttackFunction(cmd)
    local bot = self
    //if (rdmer == bot) then
        //if bot.target == nil then
            //bot.target = table.Random(GetInnocentBots())
        //end
    //end
    if IsValid(bot.target) == false then bot.target = nil return end
    if bot.target:Health() <= 0 then bot.target = nil return end
    if bot.target == bot then bot.target = nil return end
    if bot.target:IsSpec() then bot.target = nil return end
    if ((bot:IsLookingNear(bot.target) or VecDist(bot:GetPos(),bot.target:GetPos()) < 100) or (bot:GetRoleString() == "traitor" and bot:IsLookingNear(bot.target))) and bot.noshoot == nil then
        cmd:SetButtons(IN_ATTACK)
        cmd:SetForwardMove(0)
    end
    if not bot:Visible(bot.target) then
        if bot:GetRoleString() == 'innocent' then
            bot:FollowPath(cmd, bot.lastseen, 1000, 0.1, 100)
        else
            bot.lastseen = bot.target:GetPos()
            local rang = bot:FollowPath(cmd, bot.lastseen, 1000, 0.1, 100)
            if (rang) then -- oh no I lost the man!
                bot.target = nil 
            end
        end
    else
        local aim = Vector(math.random(-20, 20)/(bot.accuracy*bot.tilt),math.random(-20, 20)/(bot.accuracy*bot.tilt),(math.random(-20, 20)/(bot.accuracy*bot.tilt))-10)
        if bot.noshoot == nil then
            bot:LookAt(bot.target:GetPos()+aim,cmd,math.Remap(DIFF, 1, 8, 0.125, 0.40))
            if bot:GetActiveWeapon():GetClass() == "weapon_zm_improvised" then
                cmd:SetForwardMove(1000)
            else
                cmd:SetForwardMove(0)
            end
        end
    end
end

function AddKnownTraitor(ply)
    if not ply:HasEquipmentItem(EQUIP_DISGUISE) then
        if !ply:IsKnownTraitor() then
            traitors[#traitors+1] = ply
            for i,v in pairs(player.GetHumans()) do
                v:ChatPrint("KOS on "..ply:Nick())
            end
        end
    end
end

function OnLogCreated(log)
    if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    local callout = false
    for i,bot in pairs(player.GetBots()) do
        if log.attacker != bot then
            if log.nearply then
                if bot:Visible(log.attacker) or bot:Visible(log.victim) then
                    if !log.justified then
                        if bot.target == nil and bot:GetRoleString() != "traitor" then
                            if bot != log.victim then
                                bot.target = log.attacker
                                local cha = ttt_bot_gchat(bot.personality,"kos",log.attacker:Nick())
                                if (not callout) then
                                    callout = true
                                    bot:BotSay(cha)
                                end
                                local t = string.len(cha)
                                timer.Simple(t/WPM, function()
                                    if bot:Health() > 0 then
                                        AddKnownTraitor(log.attacker)
                                    end
                                end)
                            --[[else // If the log's victim is the bot, then do this:
                                timer.Simple(240/WPM, function() // The bots have an impaired reaction time when they're all alone so that players can kill them significantly easier.
                                    if bot:Health() > 0 then // They still, however, will not call them out when they're alone because that would make it almost impossible to subdue them.
                                        bot.target = log.attacker
                                    end
                                end)]]
                            end
                            
                        end
                    end
                end
            else
                if bot:Visible(log.attacker) then
                    local tolog = true

                    for i,v in pairs(sus) do
                        if v.user == log.attacker then
                            if CurTime()-v.time <= 1 then
                                tolog = false
                            end
                        end
                    end
                    if tolog and log.attacker:GetRoleString() != "detective" then
                        local _l = true
                        if log.attacker:IsBot() then
                            if log.attacker.target != nil then
                                if log.attacker.target.guilty then
                                    _l = false
                                end
                            end
                        end
                        if _l then
                            local s = {
                                user = log.attacker,
                                time = CurTime()
                            }
                            sus[#sus+1] = s
                            local phra = ttt_bot_gchat(bot.personality, "suson", log.attacker:Nick())
                            local len = #phra
                            timer.Simple(len/WPM, function()
                                if bot:Health() > 0 and !bot:IsSpec() then
                                    log.attacker.sus = log.attacker.sus + 1
                                end
                            end)
                            if roundIsActive then
                                if log.attacker.sus == 3 then
                                    if not log.attacker:HasEquipmentItem(EQUIP_DISGUISE) then
                                        bot:BotSay(phra)
                                    end
                                end
                                if log.attacker.sus >= 4 then
                                    AddKnownTraitor(log.attacker)
                                    if not log.attacker:HasEquipmentItem(EQUIP_DISGUISE) then
                                        bot:BotSay(ttt_bot_gchat(bot.personality, "kos", log.attacker:Nick()))
                                    else
                                        bot.target = log.attacker
                                    end

                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

hook.Add("PlayerHurt", "TTTBotHurt", function(vic,atk)
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    if atk:IsPlayer() then
        local log = {
            attacker = atk,
            victim = vic,
            timestamp = CurTime(),
            nearply = !(vic == nil),
            hurt = true
        }
        log = WasShootingJustified(log)
        OnLogCreated(log)
        tttlogs[#tttlogs+1] = log
    end

    if vic:IsPlayer() and atk:IsPlayer() and (not vic:IsSpec()) and (not atk:IsSpec()) then -- self defense portion
        if vic:IsBot() and vic:Visible(atk) then
            timer.Simple(160/WPM, function() // The bots have an impaired reaction time when they're all alone so that players can kill them significantly easier.
                if IsValid(vic) then
                    if vic:Health() > 0 then // They still, however, will not call them out when they're alone because that would make it almost impossible to subdue them.
                        vic.target = atk
                    end
                end
            end)
        end
    end

end)

hook.Add("EntityFireBullets", "TTTBotLogAdder", function(ply, bulletdata)
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    if !ply:IsPlayer() then return end
    if !roundIsActive then return end
    local weap = ply:GetActiveWeapon()
    if weap == nil then return end
    if weap.IsSilent then return end
    if ply.shoot == nil then ply.shoot = 0 end
    ply.shoot = ply.shoot + 1
    local vic = ply:ClosestLook(0.96)
    --if (vic != nil) then vic = v end
    --print(vic)
    local log = {
        attacker = ply,
        victim = vic,
        timestamp = CurTime(),
        nearply = !(vic == nil)
    }
    --print(ply:Nick() .." has been noted for shooting/shooting near:",vic)
    log = WasShootingJustified(log)
    OnLogCreated(log)
    tttlogs[#tttlogs+1] = log
end)

timer.Create("TTTBotsOpenDoors", 2, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    for b, bot in pairs(player.GetBots()) do
        if bot.lastPos == nil then return end
        for i, v in pairs(DOORS) do
            if bot:GetEyeTrace().Entity == v then
                bot.use = 2
                bot.touse = true
            --if (VecDist(bot:GetPos(),v:GetPos()) < 150) and (VecDist(bot.lastPos,bot:GetPos()) < 40) and (bot.toggle == false) then
                --v:Fire("Toggle","",0)
                --bot.toggle = true
            --end
            end
        end
    end
end)

timer.Create("TTTBotsPreventPreroundMassacre", 1, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    if not roundIsActive then
        for b, bot in pairs(player.GetBots()) do
            bot.target = nil
        end
    end
end)


timer.Create("TTTBotsSetLastPos", 1, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    for b, bot in pairs(player.GetBots()) do
        bot.lastPos = bot:GetPos()
        bot.toggle = false
        bot.crouch = false
        bot.jump = false
    end
end)

timer.Create("TTTBotsGetDoors", 2, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    DOORS = {}
    for b, v in pairs(ents.GetAll()) do
        if (v:GetClass() == "func_door") or (v:GetClass() == "prop_door_rotating") or (v:GetClass() =="func_door_rotating") then
            DOORS[#DOORS+1] = v
        end
    end
end)

function VecDist(v1,v2)
    return v1:Distance(v2)
    //return math.Dist(v1.x,v1.y,v2.x,v2.y)
end

local function addbot(prof, c, p)
    local profile = {}
    local _x = false
    if (prof != nil) then
        if IsValid(prof) then
        if prof:IsPlayer() then prof = nil end
        end
    end
    local n = -1
    if (p != nil) then
        if p[1] != nil then
            n = tonumber(p[1])
            
        end
    end
    local i = 1;
    repeat
        i = i + 1
        if prof == nil then
            repeat
                profile = table.Random(profiles)
                local x = false 
                for i,v in pairs(player.GetAll()) do
                    if v:Nick() == profile.name then
                        x = true
                        break
                    end
                end
                _x = not x
            until _x == true
        else
            profile = prof
        end
        local bot = player.CreateNextBot(profile.name)
        if bot != nil then
            bot:InitializeBot(profile)
        end
    until i > n
end

hook.Add("TTTOnCorpseCreated","TerrorbotCorpseCreated",function(corpse)
    table.insert(corpses,corpse)
    //PrintTable(corpses)
end)


timer.Create("TTTBotCorpseSearcher",1,0,function()
    if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    for i,bot in pairs(player.GetBots()) do
        if bot.target == nil && bot:GetRoleString() != "traitor" && bot:Health() > 0 and bot.corpse == nil then
            for ind,corpse in pairs(corpses) do
                if corpse != NULL then
                    if corpse == NULL then return end
                    if bot == NULL then return end
                    if corpse:IsValid() == false then return end
                    if bot:Visible(corpse) then
                        bot.willroam = false
                        bot.corpse = corpse
                        -- :FollowPath(cmd,leader:GetPos(),1000,0.2,200)
                        --[[if (withinRange) then
                            CORPSE.ShowSearch(bot,corpse,false,false)
                            table.RemoveByValue(corpses,corpse)
                            bot.willroam = true
                            bot.corpse = nil
                        end]]
                        --print(v:Nick())
                    end
                end
            end
        end
    end
end) 


net.Receive( "RequestAddBots", function( len, ply )
    local n = net.ReadInt(32)
    if ply:IsSuperAdmin() then
        for i = 1, n do
            addbot()
        end
    end
end )

net.Receive( "RequestAddCustomBot", function( len, ply )
    local n = net.ReadTable()
    if ply:IsSuperAdmin() then
        local a = true
        for i,v in pairs(player.GetAll()) do
            if v:Nick() == n.name then a = false end
        end
        if a then
            addbot(n)
        else
            ply:ChatPrint("Attempt failed: You can't add a bot named exactly like a player currently in the game.")
        end
    end
end )
local function updateQuota()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    local quota = GetConVar("ttt_bot_quota"):GetInt()
    if quota > 0 then
        local bots = #player.GetBots()
        local plys = #player.GetAll()
        if quota < plys then // if there are more players than the quota
            // if there are any bots, remove 1 of them
            if bots > 0 then
                player.GetBots()[1]:Kick("Quota reached; kicking bot")
            end
        elseif quota > plys then // if there are less players than the quota
            // add a bot!
            addbot()
        end
    end
end
timer.Create("TTTBotUpdateQuota", 1, 0, updateQuota)

net.Receive( "RequestKickBots", function( len, ply )
    local n = net.ReadInt(32)
    local plys = player.GetBots()
    if #player.GetBots() == 0 then return end
    if ply:IsSuperAdmin() then
        for i = 1, n do
            local bot = table.Random(plys)
            table.RemoveByValue(plys, bot)
            if bot != nil then
                bot:Kick("Kicked thru TTT Bot Menu")
            end
        end
    end
end )

hook.Add("PlayerDisconnected","TTTBotPlayerDisconnected",function(ply)
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    if ply:IsPlayer() and not ply:IsBot() then
        updateQuota()
    end
end)

hook.Add("PlayerInitialSpawn", "TTTBotInitSpawn", function(ply)
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    ply.sus = 0
    ply.shoot = 0
    local n = ply:Nick()
    timer.Create(ply:Nick().." shoot timer", 2, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
        if !IsValid(ply) then timer.Destroy(n.." shoot timer") return end
        ply.shoot = math.max(0,ply.shoot-1)
    end)
    if ply:IsPlayer() and not ply:IsBot() then
        updateQuota()
    end
end)

-- [[ BOT FUNCTIONALITY MODIFIERS ]]
if !ConVarExists("ttt_bot_difficulty") then
    CreateConVar("ttt_bot_difficulty", 4, 1, "1 = super easy, 2 = easier, 3 = easy, 4 = normal, 5 = harder, 6 = difficult, 7 = very difficult, 8 = veteran")
end
if !ConVarExists("ttt_bot_plant_bombs") then
    CreateConVar("ttt_bot_plant_bombs", 0, 1, "0 = bots cannot plant bombs, 1 = bots can plant bombs")
end
if !ConVarExists("ttt_bot_enable_chat") then
    CreateConVar("ttt_bot_enable_chat", 1, 1, "set to any value but 1 to diable chat. (does not disable the kos feature)")
end
if !ConVarExists("ttt_bot_detective_teamwork") then
    CreateConVar("ttt_bot_detective_teamwork", 0, 1, "do detectives group together? off by default")
end
if !ConVarExists("ttt_bot_quota") then
    CreateConVar("ttt_bot_quota", 0, 1, "fill however many total server slots at all times.. removes or adds bots if necessary")
end
if !ConVarExists("ttt_bot_disable_hiding") then
    CreateConVar("ttt_bot_disable_hiding", 1, 1, "set to 1 to disable the hiding functionality of bot personality 0.")
end
if !ConVarExists("ttt_bot_roamwalk") then
    CreateConVar("ttt_bot_roamwalk", 1, 1, "do bots walk when roaming?")
end
if !ConVarExists("ttt_bot_nav_debug") then
    CreateConVar("ttt_bot_nav_debug", 0, 1, "set to 1 to enable displaying of paths from bot navigators.")
end
if !ConVarExists("ttt_bot_wpm") then
    CreateConVar("ttt_bot_wpm", 20, 1, "Words Per Minute typing speed of bots: this variable is internally multiplied by the bot difficulty convar")
end
if !ConVarExists("ttt_bot_rdm") then
    CreateConVar("ttt_bot_rdm", 0, 1, "Do troll bots RDM non-players? Adds to the chaos factor + gives the traitors a chance to win!")
end
concommand.Add("ttt_bot_add", addbot)
concommand.Add("ttt_bot_gennewnavmesh", function(ply)
    if IsValid(ply) then
        if ply:IsSuperAdmin() then
            ply:ConCommand("sv_cheats 1")
            ply:ConCommand("nav_mark_walkable")
            ply:ConCommand("nav_generate")
        end
    else
        print("I'm sorry, however you must be a superadmin & in-game for this command to have any effect.")
    end
end)

timer.Create("ConVarUpdateTTTBots", 2, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    DIFF = math.max(1,math.min(8,GetConVar("ttt_bot_difficulty"):GetInt())) / 4 // ( if CVAR < 1 , then 1; if CVAR > 8, then 8. ) / 4

    DISABLEHIDING = GetConVar("ttt_bot_disable_hiding"):GetInt()
    ROAMWALK = GetConVar("ttt_bot_roamwalk"):GetInt()
    WPM = math.abs(GetConVar("ttt_bot_wpm"):GetInt()*GetConVar("ttt_bot_difficulty"):GetInt())

end)

--[[]]

hook.Add("PlayerSay", "TTTBotPlayerSay", function(ply,txt)
    if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    if ply:IsSuperAdmin() then
        if string.sub(txt, 0, 7) == "!addbot" then
            local n = tonumber(string.sub(txt,8))
            if n != nil then
                for i = 1, n do addbot() end
                return false
            end
        end
        if txt == "!addbot" then addbot() end
    end
    if string.lower(txt) == "!botmenu" then
        if game.MaxPlayers() > 1 then
            net.Start("RequestMenu")
            net.Send(ply)
            return false
        else
            ply:ChatPrint("You are not in a server! Bots require player slots!")
            Error("Attempt to access bot menu without being in server with more than 1 player slot")
            return false
        end
    end
end)

LERP = 0.0

function Meta:generateWanderPos(maxVisPlayers)
    local ply = self
    local pos;
    repeat
        pos = Vector(math.random(-10000,10000),math.random(-10000,10000),math.random(-10000,10000))
        local dangerous = false
        for i,v in pairs(bombs) do
            if not IsValid(v) then
                table.remove(bombs, i)
            end
        end
        for i,v in pairs(tbombs) do
            if not IsValid(v) then
                table.remove(bombs, i)
            end
        end
        for i,v in pairs(bombs) do // 750
            if IsValid(v) then
                if v:GetPos():Distance(pos) < 750 then
                    dangerous = true
                end
            end
        end
        if (ply:GetRoleString() == "traitor") then
            for i,v in pairs(tbombs) do // 750
                if IsValid(v) then
                    if v:GetPos():Distance(pos) < 750 then
                        dangerous = true
                    end
                end
            end
        end
        -- todo: maxvisplayers
    until util.IsInWorld(pos) and (not dangerous)
    return pos
end

function Meta:LookAt(pos, cmd, ler) -- goal is a Vector
    local ownpos = self:GetPos() -- or Vector(0,0,0)
    local xdiff = pos.x - ownpos.x
    local ydiff = pos.y - ownpos.y
    local zdiff = pos.z - ownpos.z
    local xydist = math.Distance(pos.x,pos.y,ownpos.x,ownpos.y)
    //local xydist = pos:Distance(ownpos)
    yaw = math.deg(math.atan2(ydiff,xdiff))
    pitch = math.deg(math.atan2(-zdiff,xydist))
    if ler == nil then ler = LERP end
    --if move == true then
    if (cmd == nil or cmd == NULL or not IsValid(cmd)) then 
        --ErrorNoHalt( "Bot attempted to call Meta:LookAt() without supplying a real 'cmd' variable!\n Role: " )
    end
    if (istarget == nil) then
        cmd:SetViewAngles(LerpAngle( ler, cmd:GetViewAngles(), Angle(pitch,yaw,0)))
    --end
    --if eyes == true then
        self:SetEyeAngles(LerpAngle( ler, self:EyeAngles(), Angle(pitch,yaw,0))) 
    --end


    end
end

--[[
    :FollowPath(
        cmd,
        goal,
        speed,
        turnspeed,
        stopatdist
    )
]]
function Meta:FollowPath( -- returns if the bot is within stopatdist of the goal
    cmd, -- the bot's cmd
    goal, -- goal VECTOR of the path
    speed, -- the speed the bot should move at, can be negative
    turnspeed, -- the lerping factor which is a decimal 0 thu 1 whereas 1 is instant and 0 is no change
    stopatdist, -- if the bot is a certain distance from "goal" ***AND has a valid line-of-sight to it***, then do not move the bot. (doesn't factor in height difference)
    nosee
)
    local see = !nosee
    --[[if goal == nil then return end
    if cmd == nil then return end
    if speed == nil then return end
    if turnspeed == nil then return end
    if spotatdist == nil then return end]]
    local nav = self.nav
    nav.PosGen = goal
    if nav.P == nil then return end
    --print(#nav.P:GetAllSegments())
    local bot = self
    local look = nav.P:GetAllSegments() -- get segments of path
    local targ = nil -- vector
    if look != nil then -- if there are segments
        if look[2] != nil then -- if there is a second segment
            targ = look[2] -- targ is set to the second segment
            --[[if look[3] != nil then
                if math.Dist(self:GetPos().x,self:GetPos().y,look[3].pos.y,look[3].pos.y) < 100 then
                    targ = look[3]
                end
            end]]
            if targ.type == 0 then -- is the segment a normal walk segment
                targ = Vector(targ.pos.x,targ.pos.y,bot:GetPos().z) -- set to move towards the segment position
                if VecDist(targ,bot:GetPos()) < 10 then
                    if look[3] != nil then
                        targ = Vector(look[3].pos.x,look[3].pos.y,bot:GetPos().z)
                    end
                end
            elseif targ.type == 1 then -- is the segment NOT a normal walk segment
                targ = look[2] -- try the 4th segment
                bot.jump = true
                if targ != nil then -- does the 4th segment exist
                    //targ = Vector(targ.pos.x,targ.pos.y,bot:GetPos().z) -- the targ position 
                    //targ = Vector(look[4].pos.x,look[4].pos.y,bot:GetPos().z)
                    targ = bot:GetPos()+(bot:GetAimVector()*1000)
                    cmd:SetForwardMove(speed)
                    self:LookAt(targ,cmd,turnspeed)
                    return
                    //pl:SetVelocity( pl:GetAimVector() * 1000 )
                end
            else
                bot.jump = true
                //bot.crouch = true
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
        if (goal:Distance(self:GetPos()) < stopatdist and self:VisibleVec(goal+Vector(0,0,math.random(0, 25)))) then
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

function Meta:IsSlotEmpty( slot )
    local ply = self
    slot = slot - 1 -- take away 1 from the slot number you want since it starts from 0
    local weptbl = ply:GetWeapons() -- get all the weapons the player has
    for k, v in pairs( weptbl ) do -- loop through them
        if v:GetSlot() == slot then return false end -- check if the slot is the slot you wanted to check, if it is, return false
    end
    return true -- otherwise return true
end

function Meta:getBotWeapon( )
    local ply = self

    local weptbl = ply:GetWeapons() -- get all the weapons the player has

    if (ply.overrride != nil) then return ply.override end

    for k, v in pairs( weptbl ) do -- loop through them
        
        if (v.Kind == WEAPON_PISTOL || v.Kind == WEAPON_HEAVY) then return v end -- check if the slot is the slot you wanted to check, if it is, return false
    end

    return nil
end

function Meta:isBotArmed()
    return self:getBotWeapon() != nil
end

function Meta:MoveToHidingSpot(cmd, crouch) -- crouch cannot be nil if the bot should crouch
    if DISABLEHIDING == 0 then
        local hide = nil
        local d = 999999
        local spots = self.hidingspots
        for i,v in pairs(spots) do
            if hide == nil then
                hide = v.vector
            else
                if math.Distance(self:GetPos().x, self:GetPos().y, v.vector.x, v.vector.y) < d then
                    d = math.Distance(self:GetPos().x, self:GetPos().y, v.vector.x, v.vector.y)
                    hide = v.vector
                end
            end
        end
        if hide != nil then
            if(self:FollowPath(cmd,hide,1000,0.08,80) and crouch != nil) then -- if within rad and it's supposed to crouch
                cmd:SetButtons(IN_DUCK)
                cmd:SetForwardMove(0)
            end
        end
    end
end

function Meta:GetWeaponByClass(class)
    for i,v in pairs(self:GetWeapons()) do
    if v:GetClass() == class then return v end
    end
end

timer.Create("TTTBotWandering", 1, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    for i,bot in pairs(player.GetBots()) do
        if bot.roamsecs == nil then
            bot.roamsecs = 0
        end
        bot.roamsecs = bot.roamsecs + 1
        if bot.roam != nil then
            if math.Dist(bot.roam.x,bot.roam.y,bot:GetPos().x,bot:GetPos().y) < 200 then
                bot.roam = bot:generateWanderPos()
                bot.roamsecs = 1
            end
        else
            bot.roam = bot:generateWanderPos()
            bot.roamsecs = 1
        end
        if bot.roamsecs >= 6 then
            bot.roam = bot:generateWanderPos()
            bot.roamsecs = 1

        end
    end
end)
local guns = {}

timer.Create("TTTGunLister", 1, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    guns = {}
    for i,weapon in pairs(ents.GetAll()) do
        if weapon:IsWeapon() then
            if weapon.Kind == WEAPON_HEAVY || weapon.Kind == WEAPON_PISTOL then
                if (weapon:GetOwner() == NULL) then
                    guns[#guns+1] = weapon
                end
            end
        end
    end
end)


function Meta:CanWander()
    return (self:isBotArmed() and (self.target == nil))
end

function Meta:GetNearestGun()
    local g = nil 
    local d = 9999999
    for i,gun in pairs(guns) do
        if gun == NULL then return nil end
        if !gun:IsValid() then return nil end
        local _d = gun:GetPos():Distance(self:GetPos())//VecDist(gun:GetPos(),self:GetPos())
        if _d < d then
            g = gun
            d = _d
        end
    end
    return g
end

timer.Create("TTTBotCrates", 1, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    crates = {}
    for i,v in pairs(ents.GetAll()) do
        local model = v:GetModel()
        if model != nil then
           if string.find(model, "wood_crate") != nil then
                crates[#crates+1] = v
           end
        end
    end
end)

function Meta:AttackCrates(cmd)
    --local d = 9999999999
    local t = nil
    if self.target != nil then self.attackingcrate = false return false end
    for i,v in pairs(crates) do
        if v != NULL and IsValid(v) then
            if self:Visible(v) and self:GetPos():Distance(v:GetPos()) < 75 then t = v break end
        end
    end
    if t != nil then
        self.attackingCrate = true
        self:SelectWeapon("weapon_zm_improvised")
        if (self:FollowPath(cmd, t:GetPos()+Vector(0,0,50), 1000, 0.15, 64*1.3,true)) then
            self:LookAt(t:GetPos()-Vector(0,0,50),cmd,0.3)
            //self.crouching = true
            cmd:SetButtons(IN_ATTACK, IN_DUCK, IN_FORWARD)
        end
        return true
    end
    return false
end


function GetDetectiveBots()
    local bots = {}
    for i,v in pairs(player.GetBots()) do
        if v:GetRoleString() == "detective" and v:Health() > 0 and !v:IsSpec() then
            bots[#bots+1] = v
        end
    end
    return bots
end

function GetTraitorBots()
    local bots = {}
    for i,v in pairs(player.GetBots()) do
        if v:GetRoleString() == "traitor" and v:Health() > 0 and !v:IsSpec() then
            bots[#bots+1] = v
        end
    end
    return bots

end

function GetInnocentBots()
    local bots = {}
    for i,v in pairs(player.GetBots()) do
        if v:GetRoleString() == "innocent" and v:Health() > 0 and !v:IsSpec() then
            bots[#bots+1] = v
        end
    end
    return bots

end

function GetNonTraitors()
    local bots = {}
    for i,v in pairs(player.GetAll()) do
        if v:GetRoleString() != "traitor" and v:Health() > 0 and !v:IsSpec() then
            bots[#bots+1] = v
        end
    end
    return bots
end


function Meta:TargetStart(cmd)
    local bot = self
    bot.attackingCrate = false
    if planter == bot then
        local cra = bot:AttackCrates(cmd)
        if not cra then
            bot:MoveToBombSpot(cmd)
        end
        bot.willroam = false
        bot.target = nil
    end
    if bot:GetActiveWeapon() == NULL then return end
    if bot:GetActiveWeapon():GetPrimaryAmmoType() != nil then
        bot:GiveAmmo( 9999, bot:GetActiveWeapon():GetPrimaryAmmoType(), false )
    end
    if bot.target != nil then
        if bot:Visible(bot.target) then
            bot.lastseen = bot.target:GetPos()
        end
    end

    if bot.roam != nil and bot:CanWander() and bot.willroam then
        
        _zz = not bot:AttackCrates(cmd)
                    
        if _zz then
            if ROAMWALK then
                bot:FollowPath(cmd, bot.roam, 200, 0.1, 300)
            else
                bot:FollowPath(cmd, bot.roam, 1000, 0.1, 300)
            end
        end
    end
    if bot:GetRoleString() == "detective" then
        if GetConVar("ttt_bot_detective_teamwork") ~= nil then
            if GetConVar("ttt_bot_detective_teamwork"):GetBool() then
                bot.willroam = false
                bot:detectiveCoordinate(cmd)
            end
        end
    end
    if bot:isBotArmed() == false and bot.target == nil then
        if self:GetNearestGun() != nil then
            bot:FollowPath(cmd, self:GetNearestGun():GetPos(), 1000, 0.15, 1)
            return
        end
    end
    if bot.target == nil and bot:GetRoleString() == "traitor" and bot.massinit and planter != bot then
        bot.target = table.Random(GetNonTraitors()) -- traitor picks a new target
    end
    if bot.target != nil then
        --[[if !bot:Visible(bot.target) then
            bot:FollowPath(cmd,self.lastseen, 1000, 0.2, 0)
        else
            bot:LookAt(bot.target:GetPos(),cmd,0.25)
        end]]
        bot:AttackFunction(cmd)

        if bot.target == NULL or !IsValid(bot.target) then bot.target = nil return end
        if bot == NULL then return end

        if VecDist(bot:GetPos(), bot.lastseen) < 64
         and not bot:Visible(bot.target) then
            bot.target = nil
        end

    end

end

local function startcmd(bot,cmd)
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    if bot:IsBot() == false then return end
    cmd:ClearButtons()
    bot.attackingCrate = false
    if IsValid(bot.target) then
        if bot.target:Health() <= 0 then
            bot.target = nil
        end
    else
        bot.target = nil
    end

    if bot.chatting then return end

    if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    if bot.nav:IsValid() == false then
        bot.nav = ents.Create("ttt_bots_nextbot") // create the nav
        bot.nav:SetOwner(bot) // set the owner so it doesnt collide
        bot.nav:Spawn() // spawn the nav into the world
    end
    local role = bot:GetRoleString()
    bot.armed = bot:isBotArmed()
    if bot:Health() > 0 then
        bot.nav:SetPos(bot:GetPos())
    else
        bot.nav:SetPos(Vector(0,0,50))
    end

    if bot:Health() <= 0 then return end
    if bot:GetWeaponByClass("weapon_zm_improvised") == NULL then return end
    if bot:GetWeaponByClass("weapon_zm_improvised") == nil then return end
    if bot:GetWeaponByClass("weapon_ttt_unarmed") == NULL then return end
    if bot:GetWeaponByClass("weapon_ttt_unarmed") == nil then return end
    if !IsValid(bot:GetWeaponByClass("weapon_zm_improvised")) then return end
    
    if bot.jump == true then
        if bot.crouch == true then
            cmd:SetButtons(IN_DUCK,IN_JUMP)
            else
            cmd:SetButtons(IN_JUMP)
        end
        else
        if bot.crouch == true then
            cmd:SetButtons(IN_DUCK)
        end

    end
    if bot.touse == true then
        cmd:SetButtons(IN_USE)
        bot.touse = false
    end


    --if bot:GetActiveWeapon():GetSlot() == 1 or bot:GetActiveWeapon():GetSlot() == 2 then -- slots 2 or 3
    if bot:GetActiveWeapon() != NULL then
        if bot:GetActiveWeapon():Clip1() == 0 then
            cmd:SetButtons(IN_RELOAD)
            return
        end
    end
    --end


    if bot.willroam == false and bot.sniping and bot.target == nil then
        bot:FollowPath(
            cmd,
            bot.sniperspot,
            1000,
            0.2,
            64
        )
    end

    bot:TargetStart(cmd)
    if bot.variation == nil then bot.variation = math.random(1,100) end

    --if !bot.attackingCrate then
    
    local cont = true
    if IsValid(bot.override) and !bot.attackingCrate then
        if bot.override:GetClass() == HEALTHSTATION then
            cont = false
            bot:SelectWeapon(bot.override:GetClass())
            cmd:SetButtons(IN_ATTACK)
        end
        if bot.override:GetClass() == UMP then
            cont = false
            bot:SelectWeapon(bot.override:GetClass())
        end
        else
        bot.override = nil
    end
    if cont then
        if bot.armed == false and bot.noweaponswitch == nil then
            cmd:SelectWeapon(bot:GetWeaponByClass("weapon_zm_improvised"))
        else
            if (planter != bot and bot.attackingCrate == false and bot.noweaponswitch == nil) then
                cmd:SelectWeapon(bot:getBotWeapon())
            end
        end
    end
    --end
    local person = personalities[bot.profile.personality+1]
    if person.hide == true and bot.armed and bot:GetRoleString() != "traitor" and bot.variation <= 50 then
        bot:MoveToHidingSpot(cmd,true)
    end

    if bot.corpse != nil then
        if IsValid(bot.corpse) then
            local withinRange = bot:FollowPath(cmd,bot.corpse:GetPos(),1000,0.2,120)
            if (withinRange) then
                CORPSE.ShowSearch(bot,bot.corpse,false,false)
                table.RemoveByValue(corpses,bot.corpse)
                
                bot.willroam = false
                timer.Simple(1, function() if IsValid(bot) then bot.willroam = true end end )
                bot.corpse = nil
            end
        else
            bot.corpse = nil
        end
    end

    --[[if bot:HasWeapon("weapon_ttt_health_station") then
        bot:SelectWeapon("weapon_ttt_health_station")
        cmd:SetButtons(IN_ATTACK)
    end]]
    if bot:Health() < bot:GetMaxHealth() and not bot:IsSpec() and bot.target == nil and roundIsActive then
        
        if (bot:UseHealthStation(cmd)) then
            bot.willroam = false
        end
    else
        bot.willroam = true
    end

    if bot.attackingCrate then
        //cmd:SetButtons(IN_FORWARD, IN_ATTACK, IN_DUCK)
    end
end

--[[hook.Add( "PlayerCanPickupWeapon", "TTTBotsWeapon", function( ply, wep )
end)]]

hook.Add("PlayerSpawn", "TTTBotsSpawn", function(bot)
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    if bot:IsBot() then
        if bot.nav != nil then
            if bot.nav:IsValid() then
                bot.nav:Remove()
            end
            bot.nav = ents.Create("ttt_bots_nextbot") // create the nav
            bot.nav:SetOwner(bot) // set the owner so it doesnt ocllide
            bot.nav:Spawn() // spawn the nav into the world
        else
            bot.nav = ents.Create("ttt_bots_nextbot") // create the nav
            bot.nav:SetOwner(bot) // set the owner so it doesnt ocllide
            bot.nav:Spawn() // spawn the nav into the world
        end
    end
end)

hook.Add("StartCommand", "TTTBotStartCommand", startcmd)

timer.Create("TTTBotSillyChat", 20, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    --for i,v in pairs(player.GetBots()) do
    local v = table.Random(player.GetBots())
    if v != nil then
        if v:Health() > 0 then
            v:BotSay(ttt_bot_gchat(v.personality, "silly", table.Random(player.GetBots()):Nick()))
        end
    end
end)


timer.Create("TTTBotsHuntTraitors", 1, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    for i,v in pairs(player.GetBots()) do
        if v:GetRoleString() != "traitor" and v:Health() > 0 then
            for i, traitor in pairs(traitors) do
                if IsValid(traitor) then
                    if traitor:Health() > 0 and !traitor:IsSpec() then
                        if v:Visible(traitor) then
                            if v.chatspot == nil then
                                if v.target == nil then
                                    v.target = traitor
                                    if math.random(1,3) == 1 then
                                        v:BotSay(ttt_bot_gchat(v.personality, "traitor_spotted", traitor:Nick()))
                                    end
                                end
                                v.chatspot = 1
                                timer.Simple(5+math.random(-2,10), function()
                                    if !IsValid(v) then return end
                                    v.chatspot = nil
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

function Meta:GetViewers()
    local bot = self
    local bots = {}
    for i,v in pairs(player.GetAll()) do
        if v:Visible(bot) then
            table.Add(v, bots)
        end
    end
    return bots
end

function Meta:GetInnoViewers()
    local bot = self
    local bots = {}
    for i,v in pairs(player.GetAll()) do
        if v:Visible(bot) and v:GetRoleString() ~= "traitor" then
            //print(v:Nick(),bot:Nick())
            if v:Nick() != bot:Nick() then
                bots[#bots+1] = v
            end
        end
    end
    return bots
end

timer.Create("TTTDetectTraitorWeapons", 1, 0, function()
    if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end

    if roundIsActive then
        for i,bot in pairs(player.GetAll()) do
            if bot:GetRoleString() != "traitor" and not bot:IsSpec() then
                --[[ DETECT BOMBS ON THE GROUND ]]
                for i,v in pairs(ents.GetAll()) do
                    if v:GetClass() == "ttt_c4" then
                        if bot:Visible(v) then
                            local c = true
                            for x,y in ipairs(bombs) do
                                if (y == v) then
                                    c = false
                                end
                            end
                            if (c) then
                                if bot:IsBot() then
                                    bot:BotSay(ttt_bot_gchat(bot.personality, "c4spotted", "{DELETE THIS}"))
                                end
                                bombs[#bombs+1] = v
                            end
                        end
                    end
                end
            end
            if bot:GetRoleString() == "traitor" and not bot:IsSpec() then
                wep = bot:GetActiveWeapon()

                

                if (wep) then
                    --PrintTable(wep.CanBuy)
                    if wep.CanBuy then
                        //PrintTable(wep.CanBuy)
                        if wep.CanBuy[1] == ROLE_TRAITOR then
                            local callout = false
                            //print("traitor", #bot:GetInnoViewers())
                            for _i,v in pairs(bot:GetInnoViewers()) do
                                bot.guilty = true
                                if (v.target == nil and v:IsBot()) then
                                    if not callout then
                                        if not bot:HasEquipmentItem(EQUIP_DISGUISE) then
                                            local chat = ttt_bot_gchat(v.personality, "traitor_spotted", bot:Nick())
                                            v:BotSay(chat)
                                            
                                            timer.Simple(string.len(chat), function()
                                                AddKnownTraitor(bot)
                                            end)
                                            callout = true
                                        end
                                    end
                                    bot.target = bot
                                end
                            end
                        end
                    end
                end
            end
            --------------------
            --------------------
            --------------------
            for m,view in pairs(player.GetBots()) do
                if bot:Visible(view) and view:IsSpec() == false then
                    if view:GetRoleString() == "traitor" then
                        --if view:GetActiveWeapon()
                        wep = view:GetActiveWeapon()
                        if (wep) then
                            if wep.CanBuy == { ROLE_TRAITOR } then
                            -- experimental ::: 
                                if not view:HasEquipmentItem(EQUIP_DISGUISE) then
                                    bot.target = view
                                    local cha = ttt_bot_gchat(bot.personality,"kos",view:Nick())
                                    bot:BotSay(cha)
                                    local t = string.len(cha)
                                    timer.Simple(t/WPM, function()
                                        if bot:Health() > 0 then
                                            AddKnownTraitor(view)
                                        end
                                    end)         
                                end

                            end
                        end
                    end
                end
            end
        end
    end
end)

timer.Create("ClientDisplayInfoTTTBots", 1, 0, function()
if gmod.GetGamemode().Name != "Trouble in Terrorist Town" then return end
    local p0 = 0
    local p1 = 0
    local p2 = 0
    local p3 = 0
    for i,v in pairs(player.GetBots()) do
        local per = v.personality
        if per == 0 then p0 = p0 + 1 end
        if per == 1 then p1 = p1 + 1 end
        if per == 2 then p2 = p2 + 1 end
        if per == 3 then p3 = p3 + 1 end
    end
    local tab = {
        ["per0"] = p0,
        ["per1"] = p1,
        ["per2"] = p2,
        ["per3"] = p3,
        ["wpm"] = GetConVar("ttt_bot_wpm"):GetInt(),
        ["diff"] = GetConVar("ttt_bot_difficulty"):GetInt(),
        ["hide"] = GetConVar("ttt_bot_disable_hiding"):GetInt(),
        ["rdm"] = GetConVar("ttt_bot_rdm"):GetInt(),
        ["plant"] = GetConVar("ttt_bot_plant_bombs"):GetInt(),
        ["chat"] = GetConVar("ttt_bot_enable_chat"):GetInt()
    }
    net.Start("ClientDisplayInfo")
    net.WriteTable(tab)
    net.Send(player.GetHumans())
end)