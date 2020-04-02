AddCSLuaFile()
AddCSLuaFile("cl_radio.lua")

if CLIENT then
    include("cl_radio.lua")
end

if SERVER then
    GM.HUDColors = {} -- just a dummy table
end

GM.RadioCommands = {}
GM.RadioCommandsById = {}
GM.VisibleRadioCommands = {}
GM.VoiceVariants = {}
GM.RadioCategories = {}
GM.VoiceVariantsById = {}

GM.VisibleVoiceVariants = {}
GM.VisibleVoiceVariantsById = {}

if SERVER then
    GM.MarkedSpots = {}
    
    function GM:markSpot(pos, marker, radioData)
        local markTeam = marker:Team()
        
        self.MarkedSpots[markTeam] = self.MarkedSpots[markTeam] or {}
        self:sanitiseMarkedSpots(markTeam)
        
        table.insert(self.MarkedSpots[markTeam], {position = pos, marker = marker, displayTime = CurTime() + radioData.displayTime, radioData = radioData})
    end
    
    function GM:sanitiseMarkedSpots(desiredTeam)
        local data = self.MarkedSpots[desiredTeam]
        local removeIndex = 1
        
        for i = 1, #data do
            local current = data[removeIndex]
            
            if CurTime() > current.displayTime or not IsValid(current.marker) then
                table.remove(data, removeIndex)
            else
                removeIndex = removeIndex + 1
            end
        end
    end
end

function GM:registerRadioVoiceVariant(voiceID, display, texture, redPlayerModel, bluePlayerModel, invisible, requiresSubtitles)
    local voiceData = {}
    voiceData.id = voiceID
    voiceData.display = display
    voiceData.numId = #self.VoiceVariants + 1
    voiceData.redPlayerModel = redPlayerModel
    voiceData.bluePlayerModel = bluePlayerModel
    voiceData.invisible = invisible
    voiceData.requiresSubtitles = requiresSubtitles
    
    if CLIENT and voiceData.texture then
        voiceData.texture = surface.GetTextureID(texture)
    end
    
    self.VoiceVariants[#self.VoiceVariants + 1] = voiceData
    self.VoiceVariantsById[voiceID] = voiceData
    
    if not invisible then
        self.VisibleVoiceVariants[#self.VisibleVoiceVariants + 1] = voiceData
        self.VisibleVoiceVariantsById[voiceID] = voiceData
    end
end

function GM:getVoiceModel(ply)
    local voiceData = self.VoiceVariants[ply.voiceVariant]
    local teamID = ply:Team()
    local model = nil
    
    if teamID == TEAM_RED then
        model = voiceData.redPlayerModel
    else
        model = voiceData.bluePlayerModel
    end
    
    if type(model) == "table" then
        model = model[math.random(1, #model)]
    end
    
    return model
end

GM:registerRadioVoiceVariant("us", "US", nil, "models/player/swat.mdl", "models/player/leet.mdl")
GM:registerRadioVoiceVariant("aus", "AUS", nil, "models/player/urban.mdl", "models/player/guerilla.mdl")
GM:registerRadioVoiceVariant("rus", "RUS", nil, "models/player/riot.mdl", "models/player/phoenix.mdl", false, true)
GM:registerRadioVoiceVariant("bandlet", "Cheeki", nil, "models/player/bandit_backpack.mdl", "models/custom/stalker_bandit_veteran.mdl", true, true)
GM:registerRadioVoiceVariant("ghetto", "ghetto", nil, 
    {"models/player/group01/male_03.mdl", "models/player/group01/male_01.mdl"}, {"models/player/group01/male_03.mdl", "models/player/group01/male_01.mdl"}, true)
GM:registerRadioVoiceVariant("franklin", "Franklin", nil, 
    {"models/player/group01/male_03.mdl", "models/player/Eli.mdl", "models/player/group01/male_01.mdl"}, {"models/player/group01/male_03.mdl", "models/player/Eli.mdl", "models/player/group01/male_01.mdl"}, true)
GM:registerRadioVoiceVariant("trevor", "Trevor", nil, 
    {"models/player/Group02/Male_04.mdl", "models/player/Group02/male_02.mdl", "models/player/Group01/male_07.mdl"}, {"models/player/Group02/Male_04.mdl", "models/player/Group02/male_02.mdl", "models/player/Group01/male_07.mdl"}, true)

function GM:registerRadioCommand(data)
    table.insert(self.RadioCommands[data.category].commands, data)
    self.RadioCommandsById[data.id] = data
end

-- call this method if you're adding a new voiceover and need to insert text and sounds into already-existing radio commands for that specific voiceover
function GM:addRadioCommandVariation(radioCommandID, voiceoverID, listOfEntries)
    local commandData = self.RadioCommandsById[radioCommandID]
    commandData.commands[voiceoverID] = listOfEntries
end

function GM:registerRadioCommandCategory(category, display, invisible)
    local structure = {commands = {}, display = display, invisible = invisible}
    self.RadioCommands[category] = structure
    self.RadioCategories[display] = category
    
    if not invisible then
        self.VisibleRadioCommands[category] = structure
    end
end

GM:registerRadioCommandCategory(1, "Combat")
GM:registerRadioCommandCategory(2, "Reply")
GM:registerRadioCommandCategory(3, "Orders")
GM:registerRadioCommandCategory(4, "Status")
GM:registerRadioCommandCategory(9, "special", true)

-- {sound = "ground_control/radio/aus/.mp3", text = ""}

local command = {}
command.id = "enemy_spotted"
command.tipId = "MARK_ENEMIES"
command.variations = {us = {{sound = "ground_control/radio/us/contact.mp3", text = "Contact!"}, 
    {sound = "ground_control/radio/us/contacts.mp3", text = "Contacts!"}, 
    {sound = "ground_control/radio/us/enemyinfantryspotted.mp3", text = "Enemy infantry spotted!"}, 
    {sound = "ground_control/radio/us/enemymovementspotted.mp3", text = "Enemy movement spotted!"}, 
    {sound = "ground_control/radio/us/enemymovementspotted2.mp3", text = "Enemy movement spotted!"}, 
    {sound = "ground_control/radio/us/enemyoverthere.mp3", text = "Enemy over there!"}, 
    {sound = "ground_control/radio/us/enemyrightthere.mp3", text = "Enemy right there!"}, 
    {sound = "ground_control/radio/us/enemyspotted.mp3", text = "Enemy spotted!"}, 
    {sound = "ground_control/radio/us/enemyspotted2.mp3", text = "Enemy spotted!"}, 
    {sound = "ground_control/radio/us/tangospotted.mp3", text = "Tango spotted!"}, 
    {sound = "ground_control/radio/us/tangospotted2.mp3", text = "Tango spotted!"}, 
    {sound = "ground_control/radio/us/ihaveeyesonenemytroops.mp3", text = "I have eyes on enemy troops!"}},
    
    aus = {{sound = "ground_control/radio/aus/contact.mp3", text = "Contact!"},
        {sound = "ground_control/radio/aus/enemymovement.mp3", text = "Enemy movement spotted!"},
        {sound = "ground_control/radio/aus/enemysighted.mp3", text = "Oi, enemy sighted!"},
        {sound = "ground_control/radio/aus/enemyspotted.mp3", text = "Enemy spotted!"},
        {sound = "ground_control/radio/aus/iseethem.mp3", text = "I see them!"},
        {sound = "ground_control/radio/aus/hostiles.mp3", text = "Hostiles!"},
        {sound = "ground_control/radio/aus/theresenemiesoverthere.mp3", text = "There's enemies over there!"},
        {sound = "ground_control/radio/aus/watchoutmate.mp3", text = "Watch out, mate, enemies spotted!"},
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/atanda.mp3", text = "Атанда!"},
        {sound = "ground_control/radio/bandlet/gondurasi.mp3", text = "Гондурасы!"},
        {sound = "ground_control/radio/bandlet/pacani_atas.mp3", text = "Пацаны, атас!"},
        {sound = "ground_control/radio/bandlet/stvoly_dostavaite_pocani.mp3", text = "Стволы доставайте, пацаны!"},
        {sound = "ground_control/radio/bandlet/volyni_k_boju.mp3", text = "Волыны к бою!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/enemyspotted1.mp3", text = "Враг."},
        {sound = "ground_control/radio/rus/enemyspotted2.mp3", text = "Враг!"},
        {sound = "ground_control/radio/rus/enemyspotted3.mp3", text = "Враг."},
        {sound = "ground_control/radio/rus/enemyspotted4.mp3", text = "Пиндос!"},
        {sound = "ground_control/radio/rus/enemyspotted5.mp3", text = "Фраер."},
        {sound = "ground_control/radio/rus/enemyspotted6.mp3", text = "Фраер!"},
        {sound = "ground_control/radio/rus/enemyspotted7.mp3", text = "Враг прямо."},
        {sound = "ground_control/radio/rus/enemyspotted8.mp3", text = "Враг прямо!"},
        {sound = "ground_control/radio/rus/enemyspotted9.mp3", text = "Вижу врага."},
        {sound = "ground_control/radio/rus/enemyspotted10.mp3", text = "Вижу врага!"},
        {sound = "ground_control/radio/rus/enemyspotted11.mp3", text = "Пасу пиндоса!"},
        {sound = "ground_control/radio/rus/enemyspotted12.mp3", text = "Контакт."},
        {sound = "ground_control/radio/rus/enemyspotted13.mp3", text = "Контакт."},
        {sound = "ground_control/radio/rus/enemyspotted14.mp3", text = "Контакт!"},
    },

    franklin = {
        {sound = "ground_control/radio/franklin/enemy_spotted1.ogg", text = "Down there!"},
        {sound = "ground_control/radio/franklin/enemy_spotted2.ogg", text = "You see that!?"},
        {sound = "ground_control/radio/franklin/enemy_spotted3.ogg", text = "There!"},
        {sound = "ground_control/radio/franklin/enemy_spotted4.ogg", text = "Man, you ugly as a motherfucker."},
        {sound = "ground_control/radio/franklin/enemy_spotted5.ogg", text = "Damn, the popo, shit!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/enemy_spotted1.ogg", text = "Look behind you, genius!"},
        {sound = "ground_control/radio/trevor/enemy_spotted2.ogg", text = "In this light, you look seriously inbred."},
        {sound = "ground_control/radio/trevor/enemy_spotted3.ogg", text = "How are you allowed to walk the streets, moron?"}
    }
}
    
command.onScreenText = "Enemy spotted"
command.onScreenColor = GM.HUDColors.lightRed
command.menuText = "Enemy spotted"
command.displayTime = 5
command.category = GM.RadioCategories.Combat
command.killRangeReward = 256 -- how close enemies have to be to the marked spot for the marker to receive points for marking the spot
command.cashReward = 10
command.expReward = 20    

local traceData = {}
traceData.mask = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_DEBRIS, CONTENTS_MONSTER, CONTENTS_HITBOX, CONTENTS_WATER)

function command:onPlayerDeath(victim, attacker, data)
    local victimTeam = victim:Team()
    local attackerTeam = attacker:Team()
    local marker = data.marker
    local markerTeam = marker:Team()
    
    if markerTeam == attackerTeam then
        if victimTeam ~= markerTeam and attacker ~= marker then
            local dist = victim:GetPos():Distance(data.position)
            
            if dist <= self.killRangeReward then
                marker:addCurrency(self.cashReward, self.expReward, "SPOT_KILL")
                GAMEMODE:trackRoundMVP(marker, "spotting", 1)
            end
        end
    end
end
    
function command:send(ply, commandId, category)
    traceData.start = ply:GetShootPos()
    traceData.endpos = traceData.start + ply:GetAimVector() * 4096
    traceData.filter = ply
    
    local trace = util.TraceLine(traceData)
    
    if not trace.HitSky then
        GAMEMODE:markSpot(trace.HitPos, ply, self)
        
        for key, obj in pairs(team.GetPlayers(ply:Team())) do
            GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, trace.HitPos)
        end
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "enemy_down"
command.variations = {
    us = {
        {sound = "ground_control/radio/us/enemydown.mp3", text = "Enemy down."}, 
        {sound = "ground_control/radio/us/tangodown.mp3", text = "Tango down."},  
        {sound = "ground_control/radio/us/killconfirmed.mp3", text = "Kill confirmed."}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/contactdown.mp3", text = "Contact down!"},
        {sound = "ground_control/radio/aus/contactsdead.mp3", text = "Contact's dead!"},
        {sound = "ground_control/radio/aus/enemydown.mp3", text = "Enemy down."}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/na_havaj_suka.mp3", text = "На, хавай, сука!"},
        {sound = "ground_control/radio/bandlet/na_tebe.mp3", text = "На тебе!"},
        {sound = "ground_control/radio/bandlet/poluchi_suka.mp3", text = "Получи, сука!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/enemydown1.mp3", text = "Враг убит."},
        {sound = "ground_control/radio/rus/enemydown2.mp3", text = "Враг уничтожен."},
        {sound = "ground_control/radio/rus/enemydown3.mp3", text = "Враг нейтрализован."},
        {sound = "ground_control/radio/rus/enemydown4.mp3", text = "Прихлопнул."},
        {sound = "ground_control/radio/rus/enemydown5.mp3", text = "Прищучил падлу."},
        {sound = "ground_control/radio/rus/enemydown6.mp3", text = "Готов."},
        {sound = "ground_control/radio/rus/enemydown7.mp3", text = "Готов!"},
        {sound = "ground_control/radio/rus/enemydown8.mp3", text = "Хэ, мамку ебал."},
        {sound = "ground_control/radio/rus/enemydown9.mp3", text = "На, хавай, сука!"},
        {sound = "ground_control/radio/rus/enemydown10.mp3", text = "Хээ, трубу вертел"},
        {sound = "ground_control/radio/rus/enemydown11.mp3", text = "А, скопытился, падла?!"},
    },

    franklin = {
        {sound = "ground_control/radio/franklin/enemy_down1.ogg", text = "Yeah, you have a nice day."},
        {sound = "ground_control/radio/franklin/enemy_down2.ogg", text = "Goodnight!"},
        {sound = "ground_control/radio/franklin/enemy_down3.ogg", text = "I guess that settles that."}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/enemy_down1.ogg", text = "Fuckin' fuck."},
        {sound = "ground_control/radio/trevor/enemy_down2.ogg", text = "Didn't even put up a fight!"},
        {sound = "ground_control/radio/trevor/enemy_down3.ogg", text = "Still in my prime!."}
    }
}

command.menuText = "Enemy down"
command.category = GM.RadioCategories.Combat
command.onScreenText = "Enemy down"
command.onScreenColor = GM.HUDColors.green
command.displayTime = 6
command.cashReward = 5
command.expReward = 5


function command:send(ply, commandId, category)
    if ply.lastKillData.position and CurTime() < ply.lastKillData.time then
        for key, obj in pairs(team.GetPlayers(ply:Team())) do
            GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, ply.lastKillData.position)
        end
        
        if team.GetAlivePlayers(ply:Team()) > 1 and not GAMEMODE.RoundOver then -- only give the reward if there's at least one player alive or the round hasn't ended yet
            ply:addCurrency(self.cashReward, self.expReward, "REPORT_ENEMY_DEATH")
        end
        
        ply:resetLastKillData()
    else
        for key, obj in pairs(team.GetPlayers(ply:Team())) do
            GAMEMODE:sendRadio(ply, obj, category, commandId)
        end
    end
    
    ply:sendKillConfirmations()
end

local worldSpawn = Vector(0, 0, 0)

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    
    if markPos ~= worldSpawn then
        GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
    end
end

GM:registerRadioCommand(command)

local command = {}
command.id = "affirmative"
command.variations = {
    us = {
        {sound = "ground_control/radio/us/affirmative.mp3", text = "Affirmative."}, 
        {sound = "ground_control/radio/us/copythat.mp3", text = "Copy that."}, 
        {sound = "ground_control/radio/us/icopy.mp3", text = "I copy."}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/affirmative.mp3", text = "Affirmative."},
        {sound = "ground_control/radio/aus/copythat.mp3", text = "Copy that."},
        {sound = "ground_control/radio/aus/righto.mp3", text = "Right-o."},
        {sound = "ground_control/radio/aus/soundsgood.mp3", text = "Sounds good."},
        {sound = "ground_control/radio/aus/gotcha.mp3", text = "Gotcha."}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/a_nu_chiki_briki_i_v_damki.mp3", text = "А ну чики-брики, и в дамки!"},
        {sound = "ground_control/radio/bandlet/a_nu_davaj_davaj.mp3", text = "А ну давай, давай!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/affirmative1.mp3", text = "Понял."},
        {sound = "ground_control/radio/rus/affirmative2.mp3", text = "Принято."},
        {sound = "ground_control/radio/rus/affirmative3.mp3", text = "Так-точно."},
        {sound = "ground_control/radio/rus/affirmative4.mp3", text = "Окей."},
        {sound = "ground_control/radio/rus/affirmative5.mp3", text = "Выполняю."}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/affirmative1.ogg", text = "Fo' sho', les go."},
        {sound = "ground_control/radio/franklin/affirmative2.ogg", text = "Hell yeah."},
        {sound = "ground_control/radio/franklin/affirmative3.ogg", text = "It's cool."}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/affirmative1.ogg", text = "Ooh, if you say so."},
        {sound = "ground_control/radio/trevor/affirmative2.ogg", text = "Okay. Let's do this."},
        {sound = "ground_control/radio/trevor/affirmative3.ogg", text = "Yeah."}
    }
}

command.menuText = "Affirmative"
command.category = GM.RadioCategories.Reply

GM:registerRadioCommand(command)

local command = {}
command.id = "negative"
command.variations = {us = {{sound = "ground_control/radio/us/nocando.mp3", text = "No can do."}, 
    {sound = "ground_control/radio/us/negative.mp3", text = "Negative."}, 
    {sound = "ground_control/radio/us/negative2.mp3", text = "Negative."}, 
    {sound = "ground_control/radio/us/nope.mp3", text = "Nope."}},
    
    aus = {
        {sound = "ground_control/radio/aus/nah.mp3", text = "Nah."},
        {sound = "ground_control/radio/aus/nahmate.mp3", text = "Nah, mate."},
        {sound = "ground_control/radio/aus/no.mp3", text = "No."},
        {sound = "ground_control/radio/aus/nocando.mp3", text = "No can do."}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/ty_che_baklan.mp3", text = "Ты чё, баклан?"},
        {sound = "ground_control/radio/bandlet/ne_nu_ja_ne_ponial_mlia.mp3", text = "Не ну, я не понял, мля!"},
        {sound = "ground_control/radio/bandlet/sovsem_ohirel.mp3", text = "Совсем охерел?"},
        {sound = "ground_control/radio/bandlet/suka.mp3", text = "Сука!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/negative1.mp3", text = "Нет."},
        {sound = "ground_control/radio/rus/negative2.mp3", text = "Никак нет."},
        {sound = "ground_control/radio/rus/negative3.mp3", text = "Отставить."},
        {sound = "ground_control/radio/rus/negative4.mp3", text = "Пошёл ты."}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/negative1.ogg", text = "Man, screw this."},
        {sound = "ground_control/radio/franklin/negative2.ogg", text = "Oh, for fuck's sake!"},
        {sound = "ground_control/radio/franklin/negative3.ogg", text = "Ey, stop doin' that shit!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/negative1.ogg", text = "Twat."},
        {sound = "ground_control/radio/trevor/negative2.ogg", text = "Does barking orders make you excited?"},
        {sound = "ground_control/radio/trevor/negative3.ogg", text = "Don't be ridiculous."}
    }
}

command.menuText = "Negative"
command.category = GM.RadioCategories.Reply

GM:registerRadioCommand(command)

local command = {}
command.variations = {
    us = {
        {sound = "ground_control/radio/us/muchappreciated.mp3", text = "Much appreciated."}, 
        {sound = "ground_control/radio/us/thanks.mp3", text = "Thanks."},
        {sound = "ground_control/radio/us/thankyou.mp3", text = "Thank you."},
        {sound = "ground_control/radio/us/appreciated.mp3", text = "Appreciated."}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/cheersmate.mp3", text = "Cheers, mate."},
        {sound = "ground_control/radio/aus/cheersmatey.mp3", text = "Cheers, matey."},
        {sound = "ground_control/radio/aus/thanksman.mp3", text = "Thanks, man."},
        {sound = "ground_control/radio/aus/thanksmate.mp3", text = "Thanks, mate."},
        {sound = "ground_control/radio/aus/thankyou.mp3", text = "Thank you."}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/a_nu_chiki_briki_i_v_damki.mp3", text = "А ну чики-брики, и в дамки!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/thanks1.mp3", text = "Спасибо."},
        {sound = "ground_control/radio/rus/thanks2.mp3", text = "Спасибо."},
        {sound = "ground_control/radio/rus/thanks3.mp3", text = "Благодарю."},
        {sound = "ground_control/radio/rus/thanks4.mp3", text = "Спасибо, братан."},
        {sound = "ground_control/radio/rus/thanks5.mp3", text = "Спасибо, братан."}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/thanks1.ogg", text = "Thank you for that."},
        {sound = "ground_control/radio/franklin/thanks2.ogg", text = "That's cool, homie, thanks."},
        {sound = "ground_control/radio/franklin/thanks3.ogg", text = "Yeah, thanks a lot."}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/thanks1.ogg", text = "Thank you."},
        {sound = "ground_control/radio/trevor/thanks2.ogg", text = "Thank you."},
        {sound = "ground_control/radio/trevor/thanks3.ogg", text = "Why, thank you."}
    }
}

command.menuText = "Thanks"
command.id = "thanks"
command.category = GM.RadioCategories.Reply

GM:registerRadioCommand(command)

local command = {}
command.variations = {us = {
        {sound = "ground_control/radio/us/waitforme.mp3", text = "Wait for me!"}, 
        {sound = "ground_control/radio/us/holdup.mp3", text = "Hold up!"},
        {sound = "ground_control/radio/us/holdit.mp3", text = "Hold it!"},
        {sound = "ground_control/radio/us/heywaitforme.mp3", text = "Hey, wait for me!"},
    },
    
    aus = {
        {sound = "ground_control/radio/aus/oiholdup.mp3", text = "Oi, hold up!"},
        {sound = "ground_control/radio/aus/wait.mp3", text = "Wait!"},
        {sound = "ground_control/radio/aus/waitforme.mp3", text = "Wait for me, mate!"},
        {sound = "ground_control/radio/aus/waitup.mp3", text = "Wait up!"}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/aa_suki.mp3", text = "Аа, суки!"},
        {sound = "ground_control/radio/bandlet/tvoju_matj.mp3", text = "Твою мать!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/wait1.mp3", text = "Э, погоди!"},
        {sound = "ground_control/radio/rus/wait2.mp3", text = "Постой!"},
        {sound = "ground_control/radio/rus/wait3.mp3", text = "Подожди!"},
        {sound = "ground_control/radio/rus/wait4.mp3", text = "Эй, тормозни!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/thanks1.ogg", text = "Thank you for that."},
        {sound = "ground_control/radio/franklin/thanks2.ogg", text = "That's cool, homie, thanks."},
        {sound = "ground_control/radio/franklin/thanks3.ogg", text = "Yeah, thanks a lot."}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/thanks1.ogg", text = "Thank you."},
        {sound = "ground_control/radio/trevor/thanks2.ogg", text = "Thank you."},
        {sound = "ground_control/radio/trevor/thanks3.ogg", text = "Why, thank you."}
    }
}

command.menuText = "Wait for me"
command.id = "wait_for_me"
command.category = GM.RadioCategories.Reply

GM:registerRadioCommand(command)

local command = {}
command.variations = {
    us = {
        {sound = "ground_control/radio/us/moving.mp3", text = "Moving!"}, 
        {sound = "ground_control/radio/us/onmyway.mp3", text = "On my way!"},
        {sound = "ground_control/radio/us/onmyway2.mp3", text = "On my way!"}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/immoving.mp3", text = "I'm moving."},
        {sound = "ground_control/radio/aus/imonmyway.mp3", text = "I'm on my way."},
        {sound = "ground_control/radio/aus/onmyway.mp3", text = "On my way."}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/ne_tremsia_kodla_ne_tremsia.mp3", text = "Не трёмся кодла, не трёмся!"},
        {sound = "ground_control/radio/bandlet/nu_podorvali_pocani.mp3", text = "Ну, подорвали, пацаны!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/moving1.mp3", text = "Иду."},
        {sound = "ground_control/radio/rus/moving2.mp3", text = "В пути."},
        {sound = "ground_control/radio/rus/moving3.mp3", text = "Иду, иду."},
        {sound = "ground_control/radio/rus/moving4.mp3", text = "Я уже иду."},
        {sound = "ground_control/radio/rus/moving5.mp3", text = "Я уже в пути."},
        {sound = "ground_control/radio/rus/moving6.mp3", text = "Топаю."}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/moving1.ogg", text = "Hold up, I got this."},
        {sound = "ground_control/radio/franklin/moving2.ogg", text = "Gettin' there."},
        {sound = "ground_control/radio/franklin/moving3.ogg", text = "Get out of my way! I'm moving."}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/moving1.ogg", text = "Coming through."},
        {sound = "ground_control/radio/trevor/moving2.ogg", text = "Get out of the way! I'm moving."},
        {sound = "ground_control/radio/trevor/moving3.ogg", text = "Let's go, let's go!"}
    }
}

command.menuText = "Moving"
command.id = "moving"
command.category = GM.RadioCategories.Reply

GM:registerRadioCommand(command)

local command = {}
command.variations = {us = {{sound = "ground_control/radio/us/suppressthisposition.mp3", text = "Suppress this position!"}, 
    {sound = "ground_control/radio/us/weneedtosuppressthisposition.mp3", text = "We need to suppress this position!"}},
    
    aus = {
        {sound = "ground_control/radio/aus/ineedfireonthatposition.mp3", text = "I need fire on that position!"},
        {sound = "ground_control/radio/aus/suppressthatposition.mp3", text = "Suppress that position!"},
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/nachinaem_heriachitj_kogda_sam_skazhu.mp3", text = "Начинаем херячить когда сам скажу!"},
        {sound = "ground_control/radio/bandlet/kak_majaknu_valim_kozlov_nafig_vse_vsosali.mp3", text = "Как маякну валим козлов нафиг, все всосали?"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/suppress1.mp3", text = "Дави, дави уродов!"},
        {sound = "ground_control/radio/rus/suppress2.mp3", text = "Подавить огневую точку!"},
        {sound = "ground_control/radio/rus/suppress3.mp3", text = "Открыть шквальный огонь!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/suppress1.ogg", text = "Stay down, cops! Yo, suppress them!"},
        {sound = "ground_control/radio/franklin/suppress2.ogg", text = "Stay the fuck down, cops! Yo, suppress them!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/suppress1.ogg", text = "Off with the aliens. Suppress them!"},
        {sound = "ground_control/radio/trevor/suppress2.ogg", text = "Let's have some sophisticated fun! Suppress them!"},
        {sound = "ground_control/radio/trevor/suppress3.ogg", text = "You're gone, pal, gone! Shoot him!"}
    }
}
    
command.onScreenText = "Suppress"
command.id = "suppress"
command.onScreenColor = GM.HUDColors.blue
command.menuText = "Suppress this position"
command.displayTime = 5
command.category = GM.RadioCategories.Orders
    
function command:send(ply, commandId, category)
    traceData.start = ply:GetShootPos()
    traceData.endpos = traceData.start + ply:GetAimVector() * 4096
    traceData.filter = ply
    
    local trace = util.TraceLine(traceData)
    
    if not trace.HitSky then
        for key, obj in pairs(team.GetPlayers(ply:Team())) do
            GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, trace.HitPos)
        end
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "defend"
command.variations = {us = {{sound = "ground_control/radio/us/defendthisposition.mp3", text = "Defend this position."}, 
    {sound = "ground_control/radio/us/weneedtodefendthisposition.mp3", text = "We need to defend this position."}},

    aus = {
        {sound = "ground_control/radio/aus/holdhere.mp3", text = "Alright, hold here."},
        {sound = "ground_control/radio/aus/letslookafterthispoint.mp3", text = "Let's look after this point."},
        {sound = "ground_control/radio/aus/setupcamp.mp3", text = "Set up camp right here."},
        {sound = "ground_control/radio/aus/weneedtodefendthisposition.mp3", text = "We need to defend this position."},
        {sound = "ground_control/radio/aus/weneedtoprotectthispoint.mp3", text = "We need to protect this point."}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/burkalo_na_temechko_zyrytj_v_oba_scha_nabegut.mp3", text = "Буркало на темечко, зырить в обя - ща набегут!"},
        {sound = "ground_control/radio/bandlet/vse_na_streme_i_neher_lybu_davitj_rano.mp3", text = "Все на стремё, и нехер лыбу давить - рано!"}
    },

    rus = {
        {sound = "ground_control/radio/rus/defend1.mp3", text = "Защищаем позицию."},
        {sound = "ground_control/radio/rus/defend2.mp3", text = "Занять оборону!"},
        {sound = "ground_control/radio/rus/defend3.mp3", text = "Занять огневые точки."},
        {sound = "ground_control/radio/rus/defend4.mp3", text = "Круговая оборона!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/defend1.ogg", text = "Ey, let's do this thing, bitch! Protect this spot!"},
        {sound = "ground_control/radio/franklin/defend2.ogg", text = "Help me, come on! Protect this spot!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/defend1.ogg", text = "Slow down. Defend here!"},
        {sound = "ground_control/radio/trevor/defend2.ogg", text = "Keep your head down, protect this position!"},
        {sound = "ground_control/radio/trevor/defend3.ogg", text = "Stay down, defend this place!"}
    }
}
    
command.onScreenText = "Defend"
command.onScreenColor = GM.HUDColors.blue
command.menuText = "Defend this position"
command.displayTime = 5
command.category = GM.RadioCategories.Orders
    
function command:send(ply, commandId, category)
    traceData.start = ply:GetShootPos()
    traceData.endpos = traceData.start + ply:GetAimVector() * 4096
    traceData.filter = ply
    
    local trace = util.TraceLine(traceData)
    
    if not trace.HitSky then
        for key, obj in pairs(team.GetPlayers(ply:Team())) do
            GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, trace.HitPos)
        end
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "followme"
command.variations = {us = {{sound = "ground_control/radio/us/followme.mp3", text = "Follow me."},
    {sound = "ground_control/radio/us/onme.mp3", text = "On me."}},

    aus = {
        {sound = "ground_control/radio/aus/comewithme.mp3", text = "Come with me, mate."},
        {sound = "ground_control/radio/aus/matefollowme.mp3", text = "Mate, follow me."},
        {sound = "ground_control/radio/aus/oicomewithme.mp3", text = "Oi, come with me."}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/podorvalis_i_za_mnoi.mp3", text = "Подорвались, и за мной!"},
        {sound = "ground_control/radio/bandlet/kandehaem_veselee.mp3", text = "Кандёхаем веселее!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/follow1.mp3", text = "За мной."},
        {sound = "ground_control/radio/rus/follow2.mp3", text = "Пошли за мной."},
        {sound = "ground_control/radio/rus/follow3.mp3", text = "Все за мной!"},
        {sound = "ground_control/radio/rus/follow4.mp3", text = "Давай, давай, за мной!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/followme1.ogg", text = "Come on!"},
        {sound = "ground_control/radio/franklin/followme2.ogg", text = "Come on!"},
        {sound = "ground_control/radio/franklin/followme3.ogg", text = "Come on!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/followme1.ogg", text = "Come on!"},
        {sound = "ground_control/radio/trevor/followme2.ogg", text = "Clock is ticking! Follow me!"},
        {sound = "ground_control/radio/trevor/followme3.ogg", text = "Come on, people!"}
    }
}
    
command.menuText = "Follow me"
command.category = GM.RadioCategories.Orders

GM:registerRadioCommand(command)

local command = {}
command.id = "needmedic"
command.tipId = "HEAL_TEAMMATES"
command.variations = {
    us = {
        {sound = "ground_control/radio/us/ineedamedic.mp3", text = "I need a medic!"},
        {sound = "ground_control/radio/us/ineedamedic2.mp3", text = "I need a medic!"}
    },

    aus = {
        {sound = "ground_control/radio/aus/fuckineedadoctor.mp3", text = "Fuck, I need a doctor!"},
        {sound = "ground_control/radio/aus/ineedamedic.mp3", text = "I need a medic!"},
        {sound = "ground_control/radio/aus/medic.mp3", text = "Medic!"},
        {sound = "ground_control/radio/aus/medicoverhere.mp3", text = "Medic, over here!"}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/a_eb.mp3", text = "А, ёб!"},
        {sound = "ground_control/radio/bandlet/tvoju_matj.mp3", text = "Твою мать!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/medic1.mp3", text = "Врач, мне нужен врач!"},
        {sound = "ground_control/radio/rus/medic2.mp3", text = "Врача сюда!"},
        {sound = "ground_control/radio/rus/medic3.mp3", text = "Врача мне, быстро!"},
        {sound = "ground_control/radio/rus/medic4.mp3", text = "Меня зацепили!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/needmedic1.ogg", text = "Ah, crap! That hurt!"},
        {sound = "ground_control/radio/franklin/needmedic2.ogg", text = "Agh, somethin' don't feel too good!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/needmedic1.ogg", text = "Oowwhhhhhhhhh, mother!"},
        {sound = "ground_control/radio/trevor/needmedic2.ogg", text = "Ugh, that hurts!"},
        {sound = "ground_control/radio/trevor/needmedic3.ogg", text = "Oh, man I'm fucked!"}
    }
}

command.menuText = "Need medic"
command.category = GM.RadioCategories.Combat
command.onScreenText = "Need medic"
command.onScreenColor = GM.HUDColors.blue
command.displayTime = 5

function command:send(ply, commandId, category)
    local ourPos = ply:GetPos()
    ourPos.z = ourPos.z + 32
    
    for key, obj in pairs(team.GetPlayers(ply:Team())) do
        GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, ourPos)
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "needammo"
command.tipId = "RESUPPLY_TEAMMATES"
command.variations = {us = {{sound = "ground_control/radio/us/ineedammo.mp3", text = "I need ammo!"}, 
        {sound = "ground_control/radio/us/ineedsomeammo.mp3", text = "I need some ammo!"},
        {sound = "ground_control/radio/us/imrunninglowonammo.mp3", text = "I'm running low on ammo!"}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/doesanyonehaveanyammo.mp3", text = "Does anyone have any ammo?"},
        {sound = "ground_control/radio/aus/ineedammo.mp3", text = "I need ammo!"},
        {sound = "ground_control/radio/aus/runningdry.mp3", text = "I'm running dry, oi, chuck me a mag!"}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/mlia_nu_on_voobsce_pustoj.mp3", text = "Мля, ну он вообще пустой!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/ammo1.mp3", text = "Мне нужны патроны!"},
        {sound = "ground_control/radio/rus/ammo2.mp3", text = "Патроны кончились!"},
        {sound = "ground_control/radio/rus/ammo3.mp3", text = "Давай боекомплект!"},
        {sound = "ground_control/radio/rus/ammo4.mp3", text = "Боеприпасы кончились!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/needammo1.ogg", text = "I'm outta ammo!"},
        {sound = "ground_control/radio/franklin/needammo2.ogg", text = "I'm out! Need bullets!"},
        {sound = "ground_control/radio/franklin/needammo3.ogg", text = "I'm out! Need ammo!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/needammo1.ogg", text = "I'm out! Need ammo!"},
        {sound = "ground_control/radio/trevor/needammo2.ogg", text = "Gun's empty!"},
        {sound = "ground_control/radio/trevor/needammo3.ogg", text = "Outta bullets!"}
    }
}

command.menuText = "Need ammo"
command.category = GM.RadioCategories.Combat
command.onScreenText = "Need ammo"
command.onScreenColor = GM.HUDColors.limeYellow
command.displayTime = 5

function command:send(ply, commandId, category)
    local ourPos = ply:GetPos()
    ourPos.z = ourPos.z + 32
    
    for key, obj in pairs(team.GetPlayers(ply:Team())) do
        GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, ourPos)
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "needhelp"
command.tipId = "HELP_TEAMMATES"
command.variations = {us = {{sound = "ground_control/radio/us/ineedsomehelphere.mp3", text = "I need some help here!"},
        {sound = "ground_control/radio/us/ineedsomehelpoverhere.mp3", text = "I need some help over here!"}
    },

    aus = {
        {sound = "ground_control/radio/aus/givemeahand.mp3", text = "Oi, give me a hand!"},
        {sound = "ground_control/radio/aus/helpmemate.mp3", text = "Help me, mate!"},
        {sound = "ground_control/radio/aus/oihelpme.mp3", text = "Oi, help me!"}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/gde_ty_voobsce_uviaz_nas_tut_schas_konchiat.mp3", text = "Где ты вообще увяз?! Нас тут сейчас кончат!"},
        {sound = "ground_control/radio/bandlet/my_schas_zagnemsa_bratan_cheshi_k_nam.mp3", text = "Мы сейчас загнёмся, братан, чеши к нам!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/help1.mp3", text = "Нужна помощь!"},
        {sound = "ground_control/radio/rus/help2.mp3", text = "Нужна подмога."},
        {sound = "ground_control/radio/rus/help3.mp3", text = "Нужна помощь!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/help1.ogg", text = "Help me!"},
        {sound = "ground_control/radio/franklin/help2.ogg", text = "No! No! No! Help me!"},
        {sound = "ground_control/radio/franklin/help3.ogg", text = "Gimme some help!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/help1.ogg", text = "Can I get some help!?"},
        {sound = "ground_control/radio/trevor/help2.ogg", text = "Ladies! Can I get a hand here?"},
        {sound = "ground_control/radio/trevor/help3.ogg", text = "Hey! Help me!"}
    }
}

command.menuText = "Need help"
command.category = GM.RadioCategories.Status
command.onScreenText = "Need help"
command.onScreenColor = GM.HUDColors.blue
command.displayTime = 5

function command:send(ply, commandId, category)
    local ourPos = ply:GetPos()
    ourPos.z = ourPos.z + 32
    
    for key, obj in pairs(team.GetPlayers(ply:Team())) do
        GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, ourPos)
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "pinneddown"
command.variations = {us = {{sound = "ground_control/radio/us/impinneddown.mp3", text = "I'm pinned down!"},
        {sound = "ground_control/radio/us/impinneddown2.mp3", text = "I'm pinned down!"}
    },

    aus = {
        {sound = "ground_control/radio/aus/theyreontome.mp3", text = "They're on to me, mate!"},
        {sound = "ground_control/radio/aus/theyreshootingatme.mp3", text = "They're shooting at me!"},
        {sound = "ground_control/radio/aus/iampinneddown.mp3", text = "I am pinned down, fuck me!"}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/gde_ty_voobsce_uviaz_nas_tut_schas_konchiat.mp3", text = "Где ты вообще увяз?! Нас тут сейчас кончат!"},
        {sound = "ground_control/radio/bandlet/my_schas_zagnemsa_bratan_cheshi_k_nam.mp3", text = "Мы сейчас загнёмся, братан, чеши к нам!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/pinned1.mp3", text = "Зажали суки, где помощь?!"},
        {sound = "ground_control/radio/rus/pinned2.mp3", text = "Мне нужна подмога, бля!"},
        {sound = "ground_control/radio/rus/pinned3.mp3", text = "Меня зажали, где помощь?!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/pinned1.ogg", text = "I need some backup!"},
        {sound = "ground_control/radio/franklin/pinned2.ogg", text = "Man, this is really not relaxing!"},
        {sound = "ground_control/radio/franklin/pinned3.ogg", text = "Oh, fuck! Maybe this ain't so easy!"},
        {sound = "ground_control/radio/franklin/pinned4.ogg", text = "(Distressed noises)"},
    },

    trevor = {
        {sound = "ground_control/radio/trevor/pinned1.ogg", text = "(Distressed noises)"},
        {sound = "ground_control/radio/trevor/pinned2.ogg", text = "Oh me oh my fuckity fuck!"},
        {sound = "ground_control/radio/trevor/pinned3.ogg", text = "I'm so scared!"}
    }
}

command.menuText = "Pinned down"
command.category = GM.RadioCategories.Status
command.onScreenText = "Pinned down"
command.onScreenColor = GM.HUDColors.red
command.displayTime = 5

function command:send(ply, commandId, category)
    local ourPos = ply:GetPos()
    ourPos.z = ourPos.z + 32
    
    for key, obj in pairs(team.GetPlayers(ply:Team())) do
        GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, ourPos)
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "approachingenemy"
command.variations = {us = {{sound = "ground_control/radio/us/approachingenemyposition.mp3", text = "Approaching enemy position!"},
        {sound = "ground_control/radio/us/closinginonenemyposition.mp3", text = "Closing in on enemy position!"}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/watchthisgonnagetthedroponthem.mp3", text = "Watch this, I'm gonna get the drop on them."},
        {sound = "ground_control/radio/aus/theyllneverknowwhathitem.mp3", text = "They'll never know what hit 'em."},
        {sound = "ground_control/radio/aus/imapproachingthecontacts.mp3", text = "I'm approaching the contacts!"},
        {sound = "ground_control/radio/aus/gonnamakeamove.mp3", text = "I'm gonna make a move on them!"},
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/scha_vseh_poreshu.mp3", text = "Сейчас всех порешу!"},
        {sound = "ground_control/radio/bandlet/ne_tremsia_kodla_ne_tremsia.mp3", text = "Не трёмся кодла, не трёмся!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/approaching1.mp3", text = "Подхожу к врагу."},
        {sound = "ground_control/radio/rus/approaching2.mp3", text = "Двигаюсь к врагу."},
        {sound = "ground_control/radio/rus/approaching3.mp3", text = "Приближаюсь к врагу."},
        {sound = "ground_control/radio/rus/approaching4.mp3", text = "Иду на контакт."},
        {sound = "ground_control/radio/rus/approaching5.mp3", text = "Иду на врага."},
        {sound = "ground_control/radio/rus/approaching6lel.mp3", text = "Иду на врага мамку."}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/approaching1.ogg", text = "Les' goooooooooo!"},
        {sound = "ground_control/radio/franklin/approaching2.ogg", text = "Gimme cover! I'm getting closer!"},
        {sound = "ground_control/radio/franklin/approaching3.ogg", text = "Let's move, come on! I'm moving up!"},
        {sound = "ground_control/radio/franklin/approaching4.ogg", text = "Yeah, look who's comin'!"},
    },

    trevor = {
        {sound = "ground_control/radio/trevor/approaching1.ogg", text = "Let's go! I'm moving up!"},
        {sound = "ground_control/radio/trevor/approaching2.ogg", text = "Let's go! I'm moving up!"}
    }
}

command.menuText = "Approaching enemy"
command.category = GM.RadioCategories.Status
command.onScreenText = "Approaching enemy"
command.onScreenColor = GM.HUDColors.limeYellow
command.displayTime = 5
command.radioWait = 2.5

function command:send(ply, commandId, category)
    local ourPos = ply:GetPos()
    ourPos.z = ourPos.z + 32
    
    for key, obj in pairs(team.GetPlayers(ply:Team())) do
        GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, ourPos)
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "fragout"
command.variations = {
    us = {{sound = "ground_control/radio/us/fragout.mp3", text = "Frag out!"},
        {sound = "ground_control/radio/us/fragout2.mp3", text = "Frag out!"},
        {sound = "ground_control/radio/us/throwingagrenade.mp3", text = "Throwing a grenade!"},
        {sound = "ground_control/radio/us/grenade.mp3", text = "Grenade!"}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/fragout.mp3", text = "Frag out!"},
        {sound = "ground_control/radio/aus/grenade.mp3", text = "Grenade!"},
        {sound = "ground_control/radio/aus/throwingafrag.mp3", text = "Throwing a frag!"},
        {sound = "ground_control/radio/aus/throwinggrenade.mp3", text = "Throwing grenade!"}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/kushaj_jablochko_suka.mp3", text = "Кушай яблочко, сука!"},
        {sound = "ground_control/radio/bandlet/limonchik_tebe_pindosina.mp3", text = "Лимончик тебе, пиндосина!"},
        {sound = "ground_control/radio/bandlet/na_suka_jablochko.mp3", text = "На, сука, яблочко!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/fragout1.mp3", text = "Граната пошла."},
        {sound = "ground_control/radio/rus/fragout2.mp3", text = "Лимонка."},
        {sound = "ground_control/radio/rus/fragout3.mp3", text = "Кидаю лимонку."},
        {sound = "ground_control/radio/rus/fragout4.mp3", text = "Кидаю лимонку!"},
        {sound = "ground_control/radio/rus/fragout5.mp3", text = "Граната."},
        {sound = "ground_control/radio/rus/fragout6.mp3", text = "Шухер!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/fragout1.ogg", text = "Hey, watch out! Throwin' a grenade!"},
        {sound = "ground_control/radio/franklin/fragout2.ogg", text = "Hey, look out! Throwin' a grenade!"},
        {sound = "ground_control/radio/franklin/fragout3.ogg", text = "Hey, look out! Throwin' a grenade!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/fragout1.ogg", text = "Let's go! I'm moving up!"},
        {sound = "ground_control/radio/trevor/fragout2.ogg", text = "Les' goooo!"},
        {sound = "ground_control/radio/trevor/fragout2.ogg", text = "No jokes now, asshole! Tossing a nade!"},
    }
}

command.menuText = "Frag out"
command.category = GM.RadioCategories.special
command.tipId = "THROW_FRAGS"

GM:registerRadioCommand(command)

local command = {}
command.id = "clear"
command.variations = {
    us = {
        {sound = "ground_control/radio/us/clear.mp3", text = "Clear."},
        {sound = "ground_control/radio/us/sectorclear.mp3", text = "Sector clear."}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/clear.mp3", text = "Clear."},
        {sound = "ground_control/radio/aus/sectorclear.mp3", text = "Sector clear."},
        {sound = "ground_control/radio/aus/wereallgood.mp3", text = "We're all good, sector clear."},
        {sound = "ground_control/radio/aus/wereclear.mp3", text = "We're clear."},
        {sound = "ground_control/radio/aus/wereclearmate.mp3", text = "We're clear, mate."}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/naidem_na_meha_porezhem.mp3", text = "Найдем - на меха порежем!"},
        {sound = "ground_control/radio/bandlet/nu_gde_ty_zanikalsa.mp3", text = "Ну где ты заныкался?"},
        {sound = "ground_control/radio/bandlet/vyhodi_po_horoshemu.mp3", text = "Выходи по-хорошему!"},
        {sound = "ground_control/radio/bandlet/vyhodi_poliubomu_naidem.mp3", text = "Выходи, по-любому найдём!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/clear1.mp3", text = "Чисто."},
        {sound = "ground_control/radio/rus/clear2.mp3", text = "Все чисто."}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/areaclear1.ogg", text = "Any more of you marked? Nobody here, then."},
        {sound = "ground_control/radio/franklin/areaclear2.ogg", text = "You punkass bitches done, now! Place is empty!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/areaclear1.ogg", text = "Nobody's here, now stay focused."},
        {sound = "ground_control/radio/trevor/areaclear2.ogg", text = "No one's here. We lookin' for hookers?"},
        {sound = "ground_control/radio/trevor/areaclear2.ogg", text = "Wonderful. Yeah, my tax dollars hard at work. No cops."},
    }
}

command.menuText = "Area clear"
command.category = GM.RadioCategories.Status
command.onScreenText = "Area clear"
command.onScreenColor = GM.HUDColors.green
command.displayTime = 5

function command:send(ply, commandId, category)
    local ourPos = ply:GetPos()
    ourPos.z = ourPos.z + 32
    
    for key, obj in pairs(team.GetPlayers(ply:Team())) do
        GAMEMODE:sendMarkedSpot(category, commandId, ply, obj, ourPos)
    end
end

function command:receive(sender, commandId, category, data)
    local markPos = data:ReadVector()
    GAMEMODE:AddMarker(markPos, self.onScreenText, self.onScreenColor, self.displayTime)
end

GM:registerRadioCommand(command)

local command = {}
command.id = "flank"
command.variations = {
    us = {
        {sound = "ground_control/radio/us/getemfrombehind.mp3", text = "Get 'em from behind!"},
        {sound = "ground_control/radio/us/flankthem.mp3", text = "Flank them!"}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/getbehindthem.mp3", text = "Get behind them!"},
        {sound = "ground_control/radio/aus/getbehindthemmate.mp3", text = "Hey, get behind them, mate!"},
        {sound = "ground_control/radio/aus/oiflankem.mp3", text = "Oi, flank 'em!"}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/bystro_obhodi_obhodi_etu_sheluponj.mp3", text = "Быстро - обходи, обходи эту шелупонь!"},
        {sound = "ground_control/radio/bandlet/ne_mandrazhuj_pocani_obhodim.mp3", text = "Не мандражуй, пацаны, обходим!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/flank1.mp3", text = "Обходи, обходи!"},
        {sound = "ground_control/radio/rus/flank2.mp3", text = "Давай заходи с боку, сбоку!"},
        {sound = "ground_control/radio/rus/flank3.mp3", text = "С бока заходи!"},
        {sound = "ground_control/radio/rus/flank4.mp3", text = "Схади заходи, заходи сзади!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/flankthem1.ogg", text = "Let's move, come on! Get behind em!"},
        {sound = "ground_control/radio/franklin/flankthem2.ogg", text = "We creepin on someone or what? Flank them!"}
    },

    trevor = {
        {sound = "ground_control/radio/trevor/flankthem1.ogg", text = "Go, go go! Flank them!"},
        {sound = "ground_control/radio/trevor/flankthem2.ogg", text = "Let's go! Flank them!"}
    }
}

command.menuText = "Flank them"
command.category = GM.RadioCategories.Orders

GM:registerRadioCommand(command)

local command = {}
command.id = "move"
command.variations = {
    us = {
        {sound = "ground_control/radio/us/go.mp3", text = "Go!"},
        {sound = "ground_control/radio/us/gogogo.mp3", text = "Go, go, go!"},
        {sound = "ground_control/radio/us/move.mp3", text = "Move!"}
    },
    
    aus = {
        {sound = "ground_control/radio/aus/fuckingmove.mp3", text = "Fucking move!"},
        {sound = "ground_control/radio/aus/go.mp3", text = "Go!"},
        {sound = "ground_control/radio/aus/gogogo.mp3", text = "Go, go, go!"},
        {sound = "ground_control/radio/aus/move.mp3", text = "Move!"},
        {sound = "ground_control/radio/aus/moveit.mp3", text = "Move it!"}
    },
    
    bandlet = {
        {sound = "ground_control/radio/bandlet/a_nu_davaj_davaj.mp3", text = "А ну давай, давай!"},
        {sound = "ground_control/radio/bandlet/nu_podorvali_pocani.mp3", text = "Ну, подорвали, пацаны!"}
    },
    
    rus = {
        {sound = "ground_control/radio/rus/move1.mp3", text = "Пошли."},
        {sound = "ground_control/radio/rus/move2.mp3", text = "Вперед, вперед!"},
        {sound = "ground_control/radio/rus/move3.mp3", text = "Двигай!"}
    },

    franklin = {
        {sound = "ground_control/radio/franklin/move1.ogg", text = "Ey hurry the fuck up!"},
        {sound = "ground_control/radio/franklin/move2.ogg", text = "Hurry the hell up!"},
        {sound = "ground_control/radio/franklin/move3.ogg", text = "Ey hurry up dog, come on!"},
    },

    trevor = {
        {sound = "ground_control/radio/trevor/move1.ogg", text = "Go!"},
        {sound = "ground_control/radio/trevor/move2.ogg", text = "Move!"},
        {sound = "ground_control/radio/trevor/move3.ogg", text = "Move!"},
    }
}

command.menuText = "Move"
command.category = GM.RadioCategories.Orders

GM:registerRadioCommand(command)