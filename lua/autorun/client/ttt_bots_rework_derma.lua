local info = {
    ["per0"] = 0,
    ["per1"] = 0,
    ["per2"] = 0,
    ["per3"] = 0,
    ["wpm"] = 0,
    ["diff"] = 0,
    ["hide"] = 0,
    ["rdm"] = 0,
}

net.Receive("ClientDisplayInfo", function()
    info = net.ReadTable()
end)

local maxplys = game.MaxPlayers()

local settings = {
    {
        ["Tracker"] = "wpm",
        ["Config Name"] = "ttt_bot_wpm",
        ["Display Name"] = "Bot Typing Speed",
        ["Description"] = "This value is essentially the reaction speed of the bots \n (Please note this value is internally multiplied by the difficulty)"
    },
    {
        ["Tracker"] = "diff",
        ["Config Name"] = "ttt_bot_difficulty",
        ["Display Name"] = "Bot Difficulty",
        ["Description"] = "This is a number from one to eight (1-8).\n 1=super easy, 2=easier, 3=sorta easy, 4=normal,\n 5=sorta hard, 6=difficult, 7=veteran, 8=godlike"
    },
    {
        ["Tracker"] = "plant",
        ["Config Name"] = "ttt_bot_plant_bombs",
        ["Display Name"] = "Plant C4",
        ["Description"] = "Enables/Disables planting bombs.\nFeature doesn't work properly sometimes.",
        ["Checkbox"] = true
    },
    {
        ["Tracker"] = "hide",
        ["Config Name"] = "ttt_bot_disable_hiding",
        ["Display Name"] = "Enable Hiding",
        ["Description"] = "Should bots be able to hide?\n This could potentially break the flow of the game.",
        ["Checkbox"] = true
    },
    {
        ["Tracker"] = "rdm",
        ["Config Name"] = "ttt_bot_rdm",
        ["Display Name"] = "Enable \"Bot vs Bot\" RDM",
        ["Description"] = "Should bots sometimes randomly target each other?\n This feature was added to allow an easier life for traitors\n...and more painful for yours.",
        ["Checkbox"] = true
    },
    {
        ["Tracker"] = "chat",
        ["Config Name"] = "ttt_bot_enable_chat",
        ["Display Name"] = "Enable Bot Chat",
        ["Description"] = "Bots will talk in chat if enabled. If disbled, the only\nthing that this addon outputs in chat is \"KOS on ____\"",
        ["Checkbox"] = true
    }
}

net.Receive("RequestMenu", function()
    PrintTable(info)
    local ply = LocalPlayer()
    if ply:IsSuperAdmin() then
        local Frame = vgui.Create( "DFrame" )
        Frame:SetPos( ScrW()/2-300, ScrH()/2-300 )
        Frame:SetSize( 600, 600 )
        Frame:SetTitle( "Easy TTT Bot Configuration Menu" )
        Frame:SetVisible( true )
        Frame:SetDraggable( true )
        Frame:ShowCloseButton( true )
        Frame:MakePopup()
        Frame.Paint = function(self,w,h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 0, 0, 20)
            surface.DrawRect(0, 0, w, 30)

            surface.SetDrawColor(255, 255, 255, 20)
            surface.DrawRect(0, 300, 200, 300)
        end

        local addone = vgui.Create("DButton", Frame)
        addone:SetText("Add 1 Preset Bot")
        addone:SetPos(10,40)
        addone:SetSize(100,34)
        addone.Paint = function(self,w,h)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0, 0, w, h)
        end
        addone.DoClick = function()
            net.Start("RequestAddBots")
            net.WriteInt(1, 32)
            net.SendToServer()
        end

        local kickone = vgui.Create("DButton", Frame)
        kickone:SetText("Remove 1 Bot")
        kickone:SetPos(120,40)
        kickone:SetSize(100,34)
        kickone.Paint = function(self,w,h)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0, 0, w, h)
        end
        kickone.DoClick = function()
            net.Start("RequestKickBots")
            net.WriteInt(1, 32)
            net.SendToServer()
        end

        local addone = vgui.Create("DButton", Frame)
        addone:SetText("Fill slots")
        addone:SetPos(10,84)
        addone:SetSize(100,34)
        addone.Paint = function(self,w,h)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0, 0, w, h)
        end
        addone.DoClick = function()
            net.Start("RequestAddBots")
            net.WriteInt(maxplys-(#player.GetAll()), 32)
            net.SendToServer()
        end

        local kickone = vgui.Create("DButton", Frame)
        kickone:SetText("Remove bots")
        kickone:SetPos(120,84)
        kickone:SetSize(100,34)
        kickone.Paint = function(self,w,h)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0, 0, w, h)
        end
        kickone.DoClick = function()
            net.Start("RequestKickBots")
            net.WriteInt(#player.GetBots(), 32)
            net.SendToServer()
        end

        local botcount = vgui.Create( "DLabel", Frame )
        botcount:SetPos( 40, 84+100 )
        botcount:SetSize(200,40)
        botcount.Paint = function(self,w,h)
            self:SetText("Number of bots: "..#player.GetBots())
        end


        local slotcount = vgui.Create( "DLabel", Frame )
        slotcount:SetPos( 40, 100+100 )
        slotcount:SetSize(200,40)
        slotcount.Paint = function(self,w,h)
            self:SetText("Empty slots: "..maxplys-(#player.GetAll()))
        end
        local scroll = vgui.Create("DScrollPanel", Frame)
        scroll:SetSize(300, 600)
        scroll:SetPos(300,20)

        for i,v in pairs(settings) do
            local FR = vgui.Create("DPanel")
            FR:SetSize(300, 110)
            FR:Dock(TOP)
            scroll:AddItem(FR)
            FR.Paint = function() 

            end
            local yval = 0//40+((i-1)*120)
            
            local label = vgui.Create( "DLabel", FR )
            label:SetPos( 0, yval)
            label:SetSize(200,40)
            label:SetText(v["Display Name"].." ("..v["Config Name"]..")")
            --------- same variable on purpose
            label = vgui.Create( "DLabel", FR )
            label:SetPos( 0, yval+30)
            label:SetSize(400,40)
            label:SetText(v["Description"])

            if v["Checkbox"] then
                local check = vgui.Create( "DCheckBox", FR )
                check:SetPos( 0, yval+70)
                check:SetSize(40,15)
                check:SetChecked(info[v["Tracker"]])
                check:SetConVar(v["Config Name"])
                check.Paint = function(self,w,h)
                    local chk = self:GetChecked()
                    local txt = ""
                    if chk then txt = "Enabled" else txt = "Disabled" end
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawRect(-10, 0, w+10, h)

                    surface.SetFont( "DermaDefault" )
                    if chk then
                        surface.SetTextColor( 0, 75, 0 )
                    else
                        surface.SetTextColor( 75, 0, 0 )
                    end
                    surface.SetTextPos( 0, 0 )
                    surface.DrawText( txt )
                end
            else
                local TextEntry = vgui.Create( "DTextEntry", FR )
                TextEntry:SetPos( 0, yval+70 )
                TextEntry:SetSize( 40, 15 )
                TextEntry:SetText(info[v["Tracker"]])
                TextEntry:SetConVar(v["Config Name"])
                TextEntry.Paint = function(self,w,h)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawRect(-15, 0, w+15, h)

                    surface.SetFont( "DermaDefault" )
                    surface.SetTextColor( 255, 0, 0 )
                    surface.SetTextPos( 0, 0 )
                    surface.DrawText( self:GetText() )
                end
            end
        end


        local customprof = {name = "Custom Bot", accuracy = 1, personalty = 1}

        local perso = vgui.Create( "DComboBox", Frame)
        perso:SetPos( 10, 150+300 )
        perso:SetSize( 150, 20 )
        perso:SetValue( "Bot Profile" )
        perso:AddChoice( "Loser / Nerd" )
        perso:AddChoice( "Troll / Edgelord" )
        perso:AddChoice( "Average Joe / Part-time furry" )
        perso:AddChoice( "Team Player / \"The Chad\"" )
        perso.OnSelect = function( panel, index, value )
            customprof.personality = index-1
        end

        local accur = vgui.Create( "DComboBox", Frame)
        accur:SetPos( 10, 200+300 )
        accur:SetSize( 150, 20 )
        accur:SetValue( "Accuracy Setting" )

        accur:AddChoice( "1: Absolutely Terrible" )
        accur:AddChoice( "2: Still Terrible" )
        accur:AddChoice( "3: Terrible" )
        accur:AddChoice( "4: Below Average" )
        accur:AddChoice( "5: Average" )
        accur:AddChoice( "6: Above Average" )
        accur:AddChoice( "7: Pretty Good" )
        accur:AddChoice( "8: Aimbot?" )

        accur.OnSelect = function( panel, index, value )
            customprof.accuracy = math.Remap(index, 1, 7, 0.5, 1.5)
        end

        local Label = vgui.Create( "DLabel", Frame )
        Label:SetPos( 10, 100+250 )
        Label:SetSize( 150,20 )
        Label:SetText("Custom Bot Creator")

        local TextEntry = vgui.Create( "DTextEntry", Frame )
        TextEntry:SetPos( 10, 100+300 )
        TextEntry:SetSize( 150,20 )
        TextEntry:SetText("Bot Name")

        TextEntry.Paint = function(self,w,h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(-15, 0, w+15, h)
            surface.SetFont( "DermaDefault" )
            surface.SetTextColor( 0, 0, 0 )
            surface.SetTextPos( 5, 0 )
            surface.DrawText( self:GetText() )
        end


        local addcustom = vgui.Create("DButton", Frame)
        addcustom:SetText("Add Custom Bot")
        addcustom:SetPos( 10, 550 )
        addcustom:SetSize( 150, 20 )
        addcustom.Paint = function(self,w,h)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0, 0, w, h)
        end
        addcustom.DoClick = function()
            customprof.name = TextEntry:GetText()
            net.Start("RequestAddCustomBot")
            net.WriteTable(customprof)
            net.SendToServer()
        end

        return false
    else
        ply:ChatPrint("You must be a superadmin to open the TTT Bot Menu.")
    end
end)