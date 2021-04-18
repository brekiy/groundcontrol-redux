include("shared.lua")

-- local baseFont = "CW_HUD72"

function ENT:Initialize()
    GAMEMODE:addObjectiveEntity(self)
    -- surface.SetFont(baseFont)
    -- self.baseHorSize, self.vertFontSize = surface.GetTextSize(self.PrintName)
    -- self.baseHorSize = self.baseHorSize < 600 and 600 or self.baseHorSize
    -- self.baseHorSize = self.baseHorSize + 20
    -- self.halfBaseHorSize = self.baseHorSize * 0.5
    -- self.halfVertFontSize = self.vertFontSize * 0.5
end

-- ENT.displayDistance = 256 -- the distance within which the contents of the box will be displayed
-- ENT.upOffset = Vector(0, 0, 30)

-- local white, black = Color(255, 255, 255, 255), Color(0, 0, 0, 255)
-- local horizontalBoundary, verticalBoundary = 75, 75
-- local point = surface.GetTextureID("ground_control/hud/point_of_interest")

function ENT:Draw()
end

function ENT:Think()
end