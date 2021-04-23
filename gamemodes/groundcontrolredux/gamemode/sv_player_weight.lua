include("sh_player_weight.lua")


CustomizableWeaponry.callbacks:addNew("postFire", "GroundControl_postFire", function(wep)
    wep:GetOwner():SetWeight(wep:GetOwner():CalculateWeight())
end)