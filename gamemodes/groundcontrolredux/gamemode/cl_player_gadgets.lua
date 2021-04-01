net.Receive("GC_GADGETS", function(a, b)
    local ply = LocalPlayer()

    table.Empty(ply.gadgets)

    for key, value in pairs(net.ReadTable()) do
        ply:addGadget(value)
    end
end)