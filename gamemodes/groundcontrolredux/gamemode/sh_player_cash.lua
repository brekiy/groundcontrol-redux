AddCSLuaFile()

GM.CashAmount = {cash = nil} -- instead of creating a new table every time we send an "enemy killed" event to the player with the amount of $$$ he got, we instead create one static table
local PLAYER = FindMetaTable("Player")

function PLAYER:AddCash(amount, event)
    self.cash = self.cash or 0

    self.cash = math.max(self.cash + amount, 0)
    self:SendCash()

    if SERVER then
        self:SaveCash()

        if event then
            GAMEMODE.CashAmount.cash = amount
            GAMEMODE:sendEvent(self, event, GAMEMODE.CashAmount)
        end
    end
end

function PLAYER:RemoveCash(amount)
    self.cash = self.cash - amount
    self:SendCash()

    if SERVER then
        self:SaveCash()
    end
end

function PLAYER:SetCash(amount)
    self.cash = amount
    self:SendCash()

    if SERVER then
        self:SaveCash()
    end
end

function PLAYER:SendCash()
    if SERVER then
        net.Start("GC_CASH")
        net.WriteInt(self.cash, 32)
        net.Send(self)
    end
end