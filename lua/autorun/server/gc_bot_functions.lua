include("sv_gcbot_names.lua")
print("loading gc bot stuff wip")
concommand.Add("gc_bot_add", createGCBot)

function createGCBot()
    player.CreateNextBot(getBotName())
end