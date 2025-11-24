local PLAYER = FindMetaTable("Player")

function PLAYER:UnlockAttachment(attachmentName)
    if !self.ownedAttachments then
        RunConsoleCommand("gc_request_data")
        return
    end

    self.ownedAttachments[attachmentName] = true

    if IsValid(GAMEMODE.activeAttachmentSelectionHover) then
        GAMEMODE.activeAttachmentSelectionHover:recreateInfoBox()
    end
end

function PLAYER:resetAttachmentData()
    self.ownedAttachments = {}
end

net.Receive("GC_ATTACHMENTS", function(len)
    LocalPlayer().ownedAttachments = net.ReadTable()
end)

net.Receive("GC_UNLOCK_ATTACHMENT", function (a, b)
    LocalPlayer():UnlockAttachment(net.ReadString())
end)