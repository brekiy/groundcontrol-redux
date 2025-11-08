net.Receive("GC_GADGETS", function(a, b)
    local ply = LocalPlayer()

    ply.gadgets = {}

    for _, value in ipairs(net.ReadTable()) do
        ply:AddGadget(value)
    end
end)