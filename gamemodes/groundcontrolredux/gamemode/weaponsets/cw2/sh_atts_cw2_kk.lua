AddCSLuaFile()

function GM:RegisterAttsCW2KK()
    -- Attachments (only register stuff that isn't going to be left at default 2k price)
    -- idk why but knifekitty made these colorways reduce recoil lol
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_glock_atts",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_scar_skin",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_aimpoint",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_anpeq15",
        price = 1500,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_bipod",
        price = 1500,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_bs",
        price = 0,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_acog",
        price = 1500,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_barska",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_cmore",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_compm4s",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_eotechxps",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_microt1",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_pgo7",
        price = 1250,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_sureshot",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_cstm_susat",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_elcan",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_eotech",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_flashlight_v6",
        price = 0,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_fl_kombo",
        price = 1500,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_fnfal_skins",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_galil_sar",
        price = 1000,
    })
    self:RegisterAttachment({
        attachmentName = "kk_ins2_gl_gp25",
        price = 1000,
    })

    local kk_ins2_gl_m203 = {
        attachmentName = "kk_ins2_gl_m203",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_gl_m203)

    local kk_ins2_gl_m320 = {
        attachmentName = "kk_ins2_gl_m320",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_gl_m320)

    local kk_ins2_gp25_ammo = {
        attachmentName = "kk_ins2_gp25_ammo",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_gp25_ammo)

    local kk_ins2_hoovy = {
        attachmentName = "kk_ins2_hoovy",
        price = 1250,
    }
    self:RegisterAttachment(kk_ins2_hoovy)

    local kk_ins2_kobra = {
        attachmentName = "kk_ins2_kobra",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_kobra)

    local kk_ins2_lam = {
        attachmentName = "kk_ins2_lam",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_lam)

    local kk_ins2_m6x = {
        attachmentName = "kk_ins2_m6x",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_m6x)

    local kk_ins2_magnifier = {
        attachmentName = "kk_ins2_magnifier",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_magnifier)

    local kk_ins2_mag_fal_30 = {
        attachmentName = "kk_ins2_mag_fal_30",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_mag_fal_30)

    local kk_ins2_mag_galil_75 = {
        attachmentName = "kk_ins2_mag_galil_75",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_mag_galil_75)

    local kk_ins2_mag_m1911_15 = {
        attachmentName = "kk_ins2_mag_m1911_15",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_mag_m1911_15)

    local kk_ins2_mag_m45_15 = {
        attachmentName = "kk_ins2_mag_m45_15",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_mag_m45_15)

    local kk_ins2_mag_makarov_15 = {
        attachmentName = "kk_ins2_mag_makarov_15",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_mag_makarov_15)

    local kk_ins2_mag_m1a1_30 = {
        attachmentName = "kk_ins2_mag_m1a1_30",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_mag_m1a1_30)

    local kk_ins2_c96_barrel_lng = {
        attachmentName = "kk_ins2_c96_barrel_lng",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_c96_barrel_lng)

    local kk_ins2_gl_ggg = {
        attachmentName = "kk_ins2_gl_ggg",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_gl_ggg)

    local kk_ins2_gl_m7 = {
        attachmentName = "kk_ins2_gl_m7",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_gl_m7)

    local kk_ins2_mag_c96_40 = {
        attachmentName = "kk_ins2_mag_c96_40",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_mag_c96_40)

    local kk_ins2_mag_thom_30 = {
        attachmentName = "kk_ins2_mag_thom_30",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_mag_thom_30)

    local kk_ins2_mag_thom_50 = {
        attachmentName = "kk_ins2_mag_thom_50",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_mag_thom_50)

    local kk_ins2_mag_ppsh_71 = {
        attachmentName = "kk_ins2_mag_ppsh_71",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_mag_ppsh_71)

    local kk_ins2_mosin_so = {
        attachmentName = "kk_ins2_mosin_so",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_mosin_so)

    local kk_ins2_op_mag_m4_50 = {
        attachmentName = "kk_ins2_op_mag_m4_50",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_op_mag_m4_50)

    local kk_ins2_pbs1 = {
        attachmentName = "kk_ins2_pbs1",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_pbs1)

    local kk_ins2_pbs5 = {
        attachmentName = "kk_ins2_pbs5",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_pbs5)

    local kk_ins2_po4 = {
        attachmentName = "kk_ins2_po4",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_po4)

    local kk_ins2_revolver_mag = {
        attachmentName = "kk_ins2_revolver_mag",
        price = 1250,
    }
    self:RegisterAttachment(kk_ins2_revolver_mag)

    local kk_ins2_rpk_sopmod = {
        attachmentName = "kk_ins2_rpk_sopmod",
        price = 2000,
    }
    self:RegisterAttachment(kk_ins2_rpk_sopmod)

    local kk_ins2_sawnoff_generic = {
        attachmentName = "kk_ins2_sawnoff_generic",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_sawnoff_generic)

    local kk_ins2_scope_enfield = {
        attachmentName = "kk_ins2_scope_enfield",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_scope_enfield)

    local kk_ins2_scope_m73 = {
        attachmentName = "kk_ins2_scope_m73",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_scope_m73)

    local kk_ins2_scope_m82 = {
        attachmentName = "kk_ins2_scope_m82",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_scope_m82)

    local kk_ins2_scope_nam_colt = {
        attachmentName = "kk_ins2_scope_nam_colt",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_scope_nam_colt)

    local kk_ins2_scope_nam_pso = {
        attachmentName = "kk_ins2_scope_nam_pso",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_scope_nam_pso)

    local kk_ins2_scope_zf4 = {
        attachmentName = "kk_ins2_scope_zf4",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_scope_zf4)

    local kk_ins2_scope_zf41 = {
        attachmentName = "kk_ins2_scope_zf41",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_scope_zf41)

    local kk_ins2_sights_base = {
        attachmentName = "kk_ins2_sights_base",
        price = 0,
    }
    self:RegisterAttachment(kk_ins2_sights_base)

    local kk_ins2_sights_cstm = {
        attachmentName = "kk_ins2_sights_cstm",
        price = 0,
    }
    self:RegisterAttachment(kk_ins2_sights_cstm)

    local kk_ins2_suppressor_ins = {
        attachmentName = "kk_ins2_suppressor_ins",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_suppressor_ins)

    local kk_ins2_suppressor_pistol = {
        attachmentName = "kk_ins2_suppressor_pistol",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_suppressor_pistol)

    local kk_ins2_suppressor_sec = {
        attachmentName = "kk_ins2_suppressor_sec",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_suppressor_sec)

    local kk_ins2_suppressor_shotgun = {
        attachmentName = "kk_ins2_suppressor_shotgun",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_suppressor_shotgun)

    local kk_ins2_suppressor_sterling = {
        attachmentName = "kk_ins2_suppressor_sterling",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_suppressor_sterling)

    local kk_ins2_vertgrip = {
        attachmentName = "kk_ins2_vertgrip",
        price = 1500,
    }
    self:RegisterAttachment(kk_ins2_vertgrip)

    local kk_ins2_ww2_bolt = {
        attachmentName = "kk_ins2_ww2_bolt",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_ww2_bolt)

    local kk_ins2_ww2_knife = {
        attachmentName = "kk_ins2_ww2_knife",
        price = 500,
    }
    self:RegisterAttachment(kk_ins2_ww2_knife)

    local kk_ins2_ww2_knife_fat = {
        attachmentName = "kk_ins2_ww2_knife_fat",
        price = 500,
    }
    self:RegisterAttachment(kk_ins2_ww2_knife_fat)

    local kk_ins2_ww2_nade_jackit = {
        attachmentName = "kk_ins2_ww2_nade_jackit",
        price = 500,
    }
    self:RegisterAttachment(kk_ins2_ww2_nade_jackit)

    local kk_ins2_ww2_sling = {
        attachmentName = "kk_ins2_ww2_sling",
        price = 500,
    }
    self:RegisterAttachment(kk_ins2_ww2_sling)

    local kk_ins2_ww2_stripper = {
        attachmentName = "kk_ins2_ww2_stripper",
        price = 1000,
    }
    self:RegisterAttachment(kk_ins2_ww2_stripper)
end