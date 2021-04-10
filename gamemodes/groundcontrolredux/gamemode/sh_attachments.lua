AddCSLuaFile()

GM.MaxAttachments = 6 -- maximum attachments per weapon
GM.DefaultAttachmentPrice = 2000
GM.PrimaryAttachmentString = "gc_primary_attachment_"
GM.SecondaryAttachmentString = "gc_secondary_attachment_"

GM.LockedAttachmentSlots = 3 -- amount of locked slots
GM.BaseLockedSlotPrice = 3000 -- base price of any locked slot (in experience, not cash)
GM.PriceIncreasePerSlot = 1000 -- how much it's price increases per slot (ie. at 1000 first slot will cost 4000, second will cost 5000, third 6000)

GM.PrimaryAttachmentStrings = {}
GM.SecondaryAttachmentStrings = {}

--[[ here's how I decided to price attachments:

    SIGHTS, SHARED ATTACHMENTS and SUPPRESSORS are the least expensive, but their price 
    depends on the magnification level they provide as well as their downsides (no downsides = more expensive)
    AMMO is in the middle in terms of price
    WEAPON-SPECIFIC MODS are most expensive, unless their role is not significant (ie. stocks)
    
]]--

GM.attachmentPrices = {
    am_416barrett = 1500,
    am_45lc = 1500,
    am_4borebs = 1500,
    am_4borehp = 1500,
    am_7n31 = 1500,
    am_birdshot = 1500,
    am_flechette410 = 1500,
    am_flechetterounds = 1500,
    am_flechetterounds2 = 1500, -- for whatever reason these decrease damage by 25% more, not my problem though
    am_m79_ammo = 1500,
    am_magnum = 1500,
    am_matchgrade = 1500,
    am_rifledslugs = 1500,
    am_shortbuck = 1500,
    am_slugrounds = 1500,
    am_slugrounds2k = 1500,
    am_slugroundsneo = 1500,
    am_sp7 = 1000, -- not free, optional part of PM
    bg_3006extmag = 1500,
    bg_38 = 1250,
    bg_4inchsw29 = 1250,
    bg_6inchsw29 = 1500,
    bg_ak74_rpkbarrel = 800,
    bg_ak74_ubarrel = 800, -- cheap, since it's a variant of the AK-74
    bg_ak74foldablestock = 1000,
    bg_ak74heavystock = 1250,
    bg_ak74rpkmag = 1500,
    bg_ar1560rndmag = 2000,
    bg_ar15heavystock = 1250,
    bg_ar15sturdystock = 1000,
    bg_asval = 2000, -- expensive, big powerspike over vss
    bg_asval_20rnd = 1000,
    bg_asval_30rnd = 1500,
    bg_bentbolt = false, -- the real cost is for the swaggy PU scope
    bg_bipod = 1500,
    bg_cbstock = 1250,
    bg_cz52compact = 1250,
    bg_cz52ext = 1000,
    bg_deagle_compensator = 1000,
    bg_deagle_extendedbarrel = 1000,
    bg_delislescope = 1250,
    bg_dsmag = 1250,
    bg_foldsight = false,
    bg_g18_30rd_mag = 1250,
    bg_hcarfoldsight = false,
    bg_judgelong = 1000,
    bg_judgelonger = 1250,
    bg_long38 = 1250,
    bg_longbarrel = 800, -- cheap, since it's a variant of the AR-15
    bg_longbarrelmr96 = 1000,
    bg_longris = 1500,
    bg_m79_shortbarrel = 500,
    bg_m79_shortstock = 500,
    bg_mac11_extended_barrel = 1000,
    bg_mac11_unfolded_stock = false, -- free, since you can unfold it on your own (unlike payday 2 lmao)
    bg_magpulhandguard = 1000,
    bg_makarov_extmag = 1000,
    bg_makarov_pb_suppressor = false, -- free, part of PB
    bg_makarov_pb6p9 = 800, -- cheap, a variant of the PM
    bg_makarov_pm_suppressor = 1000, -- not free, optional part of PM
    bg_makpb6 = 800,
    bg_makpbsup = false,
    bg_makpmext = 1000,
    bg_makpmm = 800,
    bg_makpmm12rnd = 1000,
    bg_makpmmext = 1000,
    bg_mdemag = 1250,
    bg_medium38 = 1000,
    bg_mncarbinebody = 1000,
    bg_mncustombody = 1500,
    bg_mnobrezbody = 800,
    bg_mp5_kbarrel = 800, -- cheap, since it's a variant of the MP5
    bg_mp5_sdbarrel = 1500,
    bg_mp530rndmag = 1000,
    bg_nostock = 800, -- cheap, since it's a variant of the MP5
    bg_ots_extmag = 1000,
    bg_pkm_barrel = 800,
    bg_pkm_bipod = 1000,
    bg_pkm_bipod_on_pkp = 1000,
    bg_pkm_handle = 800,
    bg_pkp_100_mag = 1000,
    bg_pkp_nostock = 1000,
    bg_pkp_pkm_stock = 800,
    bg_pkp_short_barrel = 1500,
    bg_r8rail = 1250,
    bg_regularbarrel = 1000,
    bg_retractablestock = 1000,
    bg_ris = 1250,
    bg_rugerext = 1250,
    bg_sg1scope = 1500,
    bg_short38 = 1000,
    bg_sksbayonetfold = false, -- purely cosmetic
    bg_sksbayonetunfold = false, -- ditto
    bg_skspuscope = 1500,
    bg_sr3m = 2000, -- expensive, big powerspike over vss
    bg_vss_foldable_stock = 1000,
    kry_docter_sight = 1000,
    kry_vz61_foregrip = 1500,
    kry_vz61_likeaboss = false,
    kry_vz61_stock_open = false,
    md_acog = 1500, -- pretty big jump in price due to: 1. 4x magnification 2. back up sights, effectively making it a 2-in-1
    md_aimpoint = 1000, -- as expensive as a micro T1 due to it providing a bigger FOV zoom
    md_ak101 = 2000,
    md_anpeq15 = 1500,
    md_avt40 = 2000,
    md_bfstock = 1250,
    md_bipod = 1000,
    md_cblongbarrel = 1250,
    md_cblongerbarrel = 1500,
    md_cobram2 = 1000,
    md_cobram22 = 1000,
    md_cz52barrel = 1250,
    md_cz52chrome = false,
    md_cz52silver = false,
    md_dank = 1250, -- ??? wtf are these
    md_dank1 = 1250,
    md_dank2 = 1250,
    md_dank3 = 1250,
    md_dank4 = 1250,
    md_dank5 = 1250,
    md_elcan = 1250,
    md_eotech = 800,
    md_extmag22 = 800,
    md_fas2_aimpoint = 1000,
    md_fas2_eotech = 800,
    md_fchoke = 1250,
    md_foregrip = 1500,
    md_gemtechmm = 1500,
    md_griplaser = 1500,
    md_ins2_suppressor_ins = 1500,
    md_insight_x2 = 1500,
    md_khr_ins2ws_acog = 1500,
    md_kobra = 800,
    md_lightbolt = 1500,
    md_m203 = 2000,
    md_m2carbine = 1500,
    md_m98b_scope = 1500,
    md_makeshift = 800,
    md_mchoke = 1250,
    md_microt1 = 1000, -- "eotech is cheaper than a micro t1? what gives?", the Micro T1 has no mobility decrease, that's why
    md_microt1kh = 1000,
    md_mnbrandnew1 = false, -- skins
    md_mnbrandnew2 = false,
    md_mnolddark = false,
    md_muzl = 1250,
    md_nightforce_nxs = 1500,
    md_nxs = 1500,
    md_pbs1 = 1500,
    md_pbs12 = 1500,
    md_pr2 = 1500,
    md_pr3 = 1500,
    md_prextmag = 1500,
    md_pso1 = 1500,
    md_rmr = 1000,
    md_rugersup = 1000,
    md_saker = 1500,
    md_saker222 = 1500,
    md_schmidt_shortdot = 1500,
    md_shortdot = 1500,
    md_tritiumis = 800,
    md_tritiumispb = 800,
    md_tritiumispmm = 800,
    md_tundra9mm = 1000,
    md_tundra9mm2 = 1000,
    md_uecw_csgo_acog = 1500,
    odec3d_barska_sight = 1000,
    odec3d_cmore_kry = 1000
}

for i = 1, GM.MaxAttachments do
    CreateClientConVar(GM.PrimaryAttachmentString .. i, "0", true, true)
    table.insert(GM.PrimaryAttachmentStrings, GM.PrimaryAttachmentString .. i)
    
    CreateClientConVar(GM.SecondaryAttachmentString .. i, "0", true, true)
    table.insert(GM.SecondaryAttachmentStrings, GM.SecondaryAttachmentString .. i)
end

function GM:getFreeSlotCount()
    return self.MaxAttachments - self.LockedAttachmentSlots
end

function GM:registerAttachment(data)
    local attData = CustomizableWeaponry.registeredAttachmentsSKey[data.attachmentName]
    attData.price = data.price
    attData.unlockedByDefault = data.unlockedByDefault
end
-- PrintTable(CustomizableWeaponry.registeredAttachmentsSKey)
function GM:setAttachmentPrice(attachmentName, desiredPrice)
    CustomizableWeaponry.registeredAttachmentsSKey[data.attachmentName].price = desiredPrice
end

for key, value in pairs(CustomizableWeaponry.registeredAttachmentsSKey) do -- iterate over the attachments
    if value.price == nil then -- check which ones don't have a price set on them, and set the default price (specifically a nil check, since if the price is 'false', it'll still get set to DefaultAttachmentPrice)
        value.price = GM.DefaultAttachmentPrice
    end
end

for attName, price in pairs(GM.attachmentPrices) do
    local attData = CustomizableWeaponry.registeredAttachmentsSKey[attName]
    if attData ~= nil then attData.price = price end
end

local PLAYER = FindMetaTable("Player")

function PLAYER:hasUnlockedAttachment(attachmentName)
    local attData = CustomizableWeaponry.registeredAttachmentsSKey[attachmentName]
    
    if not attData then
        return false
    end
    
    if not attData.price or attData.price < 0 then -- first we check whether the attachment is free by default
        return true
    end
    
    return self.ownedAttachments[attachmentName] 
end

function PLAYER:getNextAttachmentSlotPrice(slot)
    slot = slot or self.unlockedAttachmentSlots + 1
    
    local freeSlots = GAMEMODE:getFreeSlotCount()
    local slotPrice = GAMEMODE.BaseLockedSlotPrice + slot * GAMEMODE.PriceIncreasePerSlot
    
    return slotPrice
end

function PLAYER:getUnlockedAttachmentSlots()
    return math.Clamp(GAMEMODE:getFreeSlotCount() + self.unlockedAttachmentSlots, 0, GAMEMODE.MaxAttachments)
end

function PLAYER:canUnlockMoreSlots()
    return self:getUnlockedAttachmentSlots() < GAMEMODE.MaxAttachments
end

function PLAYER:isAttachmentSlotUnlocked(slot)
    return self.unlockedAttachmentSlots >= slot
end

function PLAYER:canUnlockAttachmentSlot()
    return self.experience >= self:getNextAttachmentSlotPrice()
end

function PLAYER:setUnlockedAttachmentSlots(slotAmount)
    self.unlockedAttachmentSlots = slotAmount
    
    if SERVER then
        self:sendUnlockedAttachmentSlots()
    end
end

function PLAYER:getAvailableAttachmentSlotCount()
    return self.unlockedAttachmentSlots + GAMEMODE:getFreeSlotCount()
end

function PLAYER:setExperience(exp)
    if SERVER then
        if not self:canUnlockMoreSlots() then
            return
        end
    
        self.experience = exp
        self:checkForAttachmentSlotUnlock()
        self:saveExperience()
        self:sendExperience()
    else
        self.experience = exp
    end
end