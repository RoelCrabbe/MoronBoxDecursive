-------------------------------------------------------------------------------
-- InterFace Frames {{{
-------------------------------------------------------------------------------

MBD = CreateFrame("Frame", "MBD", UIParent)

-------------------------------------------------------------------------------
-- The Stored Variables {{{
-------------------------------------------------------------------------------

MBD.DefaultOptions = {
    PriorityList = { },
    SkipList = { },
    Slider = {
		Seconds_On_Blacklist = 4,
		ScanFrequency = 0.4
	},
    CheckBox = {
		Check_For_Abolish = true,
		Always_Use_Best_Spell = true,
		Random_Order = true
	}
}

-------------------------------------------------------------------------------
-- DO NOT CHANGE {{{
-------------------------------------------------------------------------------

MBD.Session = {
    PlayerName = UnitName("player"),
	PlayerClass = UnitClass("player"),
    InCombat = nil,
    Elapsed = 0,
    CureOrderList = {
		[1] = MBD_MAGIC,
		[2] = MBD_CURSE,
		[3] = MBD_POISON,
		[4] = MBD_DISEASE
    },
    Spells = {
        HasSpells = false,
        Magic = {
            Magic_1 = { 0, "", "" },
            Magic_2 = { 0, "", "" },
            Can_Cure_Magic = false,
            Enemy_Magic_1 = { 0, "", "" },
            Enemy_Magic_2 = { 0, "", "" },
            Can_Cure_Enemy_Magic = false            
        },
        Disease = {
            Disease_1 = { 0, "", "" },
            Disease_2 = { 0, "", "" },
            Can_Cure_Disease = false            
        },
        Poison = {
            Poison_1 = { 0, "", "" },
            Poison_2 = { 0, "", "" },
            Can_Cure_Poison = false            
        },
        Curse = {
            Curse_1 = { 0, "", "" },
            Can_Cure_Curse = false            
        },
        Spell_Cooldown_Check = { 0, "", "" }
    }
}

-------------------------------------------------------------------------------
-- Core Event Code {{{
-------------------------------------------------------------------------------

do
    for _, event in {
        "ADDON_LOADED",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_LEAVING_WORLD",
        "PLAYER_ENTER_COMBAT",
        "PLAYER_LEAVE_COMBAT",
        "SPELLCAST_STOP",
        "UNIT_PET",
        "SPELLS_CHANGED",
        "LEARNED_SPELL_IN_TAB",
        "UI_ERROR_MESSAGE",
        "PARTY_MEMBERS_CHANGED",
        "PARTY_LEADER_CHANGED",
    } 
    do 
        MBD:RegisterEvent(event)
    end
end


function MBD:OnEvent()
    if ( event == "ADDON_LOADED" and arg1 == "MoronBoxDecursive" ) then
        
        MBD_SetupSavedVariables()
        MBD:CreateWindows()
        MBD_Configure()
    end
end

MBD:SetScript("OnEvent", MBD.OnEvent) 

function MBD:OnUpdate()

end

MBD:SetScript("OnUpdate", MBD.OnUpdate) 

function MBD_SetupSavedVariables()
    if not MoronBoxDecursive_Options then 
        MoronBoxDecursive_Options = MBD.DefaultOptions
    end
end

-------------------------------------------------------------------------------
-- Spell Configure {{{
-------------------------------------------------------------------------------

function MBD_Configure()

    MBD.Session.Spells.HasSpells = false
    MBD.Session.Spells.Magic.Magic_1 = { 0, "", "" }
    MBD.Session.Spells.Magic.Magic_2 = { 0, "", "" }
    MBD.Session.Spells.Magic.Can_Cure_Magic = false
    MBD.Session.Spells.Magic.Enemy_Magic_1 = { 0, "", "" }
    MBD.Session.Spells.Magic.Enemy_Magic_2 = { 0, "", "" }
    MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic = false
    MBD.Session.Spells.Disease.Disease_1 = { 0, "", "" }
    MBD.Session.Spells.Disease.Disease_2 = { 0, "", "" }
    MBD.Session.Spells.Disease.Can_Cure_Disease = false
    MBD.Session.Spells.Poison.Poison_1 = { 0, "", "" }
    MBD.Session.Spells.Poison.Poison_2 = { 0, "", "" }
    MBD.Session.Spells.Poison.Can_Cure_Poison = false
    MBD.Session.Spells.Curse.Curse_1_1 = { 0, "", "" }
    MBD.Session.Spells.Curse.Can_Cure_Curse = false

    local DecurseSpellArray = {
        [MBD_SPELL_CURE_DISEASE] = true,
        [MBD_SPELL_ABOLISH_DISEASE] = true,
        [MBD_SPELL_PURIFY] = true,
        [MBD_SPELL_CLEANSE] = true,
        [MBD_SPELL_DISPELL_MAGIC] = true,
        [MBD_SPELL_CURE_POISON] = true,
        [MBD_SPELL_ABOLISH_POISON] = true,
        [MBD_SPELL_REMOVE_LESSER_CURSE] = true,
        [MBD_SPELL_REMOVE_CURSE] = true,
        [MBD_SPELL_PURGE] = true,
        [MBD_PET_FEL_CAST] = true,
        [MBD_PET_DOOM_CAST] = true
    }

    local i = 1
    local BookType = BOOKTYPE_SPELL
    local BreakLoop = false

    while not BreakLoop do
        while (true) do
            local spellName, spellRank = GetSpellName(i, BookType)

            if (not spellName) then
                if (BookType == BOOKTYPE_PET) then
                    BreakLoop = true
                    break
                end
                BookType = BOOKTYPE_PET
                i = 1
                break
            end

            if (DecurseSpellArray[spellName]) then

                MBD.Session.Spells.HasSpells = true
                MBD.Session.Spells.Cooldown_Check = {i, BookType};

                if spellName == MBD_SPELL_CURE_DISEASE or spellName == MBD_SPELL_ABOLISH_DISEASE or
                    spellName == MBD_SPELL_PURIFY or spellName == MBD_SPELL_CLEANSE then
                    MBD.Session.Spells.Disease.Can_Cure_Disease = true
                    if spellName == MBD_SPELL_CURE_DISEASE or spellName == MBD_SPELL_PURIFY then
                        MBD.Session.Spells.Disease.Disease_1 = {i, BookType, spellName}
                    else
                        MBD.Session.Spells.Disease.Disease_2 = {i, BookType, spellName}
                    end
                end
     
                if spellName == MBD_SPELL_CURE_POISON or spellName == MBD_SPELL_ABOLISH_POISON or
                    spellName == MBD_SPELL_PURIFY or spellName == MBD_SPELL_CLEANSE then
                    MBD.Session.Spells.Poison.Can_Cure_Poison = true
                    if spellName == MBD_SPELL_CURE_POISON or spellName == MBD_SPELL_PURIFY then
                        MBD.Session.Spells.Poison.Poison_1 = {i, BookType, spellName}
                    else
                        MBD.Session.Spells.Poison.Poison_2 = {i, BookType, spellName}
                    end
                end
     
                if spellName == MBD_SPELL_REMOVE_CURSE or spellName == MBD_SPELL_REMOVE_LESSER_CURSE then
                    MBD.Session.Spells.Curse.Can_Cure_Curse = true
                    MBD.Session.Spells.Curse.Curse_1_1 = {i, BookType, spellName}
                end
     
                if spellName == MBD_SPELL_DISPELL_MAGIC or spellName == MBD_SPELL_CLEANSE or 
                    spellName == MBD_PET_FEL_CAST or spellName == MBD_PET_DOOM_CAST then
                    MBD.Session.Spells.Magic.Can_Cure_Magic = true
                    if spellName == MBD_SPELL_CLEANSE or spellRank == MBD_SPELL_RANK_1 then
                        MBD.Session.Spells.Magic.Magic_1 = {i, BookType, spellName}
                    else
                        MBD.Session.Spells.Magic.Magic_2 = {i, BookType, spellName}
                    end
                end
     
                if spellName == MBD_SPELL_DISPELL_MAGIC or spellName == MBD_SPELL_PURGE or 
                    spellName == MBD_PET_FEL_CAST or spellName == MBD_PET_DOOM_CAST then
                    MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic = true
                    if spellRank == MBD_SPELL_RANK_1 then
                        MBD.Session.Spells.Magic.Enemy_Magic_1 = {i, BookType, spellName}
                    else
                        MBD.Session.Spells.Magic.Enemy_Magic_2 = {i, BookType, spellName}
                    end
                end
            end

            i = i + 1
        end
    end

    MBD_VerifyOrderList()
    -- PrintSpells()
end

function MBD_VerifyOrderList()
    
    local i, j = 0, 0
    local TempTable = {}
    local SecTempTable = {}

    for i = 1, 4 do
        if MBD.Session.CureOrderList[i] and not MBD_tcheckforval(TempTable, MBD.Session.CureOrderList[i]) then
            TempTable[i] = MBD.Session.CureOrderList[i]
        end
    end

    if not MBD_tcheckforval(TempTable, MBD_MAGIC) then 
        table.insert(TempTable, MBD_MAGIC)
    end

    if not MBD_tcheckforval(TempTable, MBD_CURSE) then 
        table.insert(TempTable, MBD_CURSE)
    end

    if not MBD_tcheckforval(TempTable, MBD_POISON) then
        table.insert(TempTable, MBD_POISON)
    end

    if not MBD_tcheckforval(TempTable, MBD_DISEASE) then 
        table.insert(TempTable, MBD_DISEASE)
    end

    MBD.Session.CureOrderList = TempTable
end

function PrintSpells()
    -- Print Magic Spells
    if MBD.Session.Spells.Magic.Magic_1[1] and MBD.Session.Spells.Magic.Magic_2[1] then
        Print("Magic Spells:")
        Print("  Magic Spell 1: " .. MBD.Session.Spells.Magic.Magic_1[1])
        Print("  Magic Spell 1: " .. MBD.Session.Spells.Magic.Magic_1[2])
        Print("  Magic Spell 1: " .. MBD.Session.Spells.Magic.Magic_1[3])
        Print("  Magic Spell 2: " .. MBD.Session.Spells.Magic.Magic_2[1])
        Print("  Magic Spell 2: " .. MBD.Session.Spells.Magic.Magic_2[2])
        Print("  Magic Spell 2: " .. MBD.Session.Spells.Magic.Magic_2[3])
        Print("  Can Cure Magic: " .. tostring(MBD.Session.Spells.Magic.Can_Cure_Magic))
    end

    -- Print Enemy Magic Spells if they exist
    if MBD.Session.Spells.Magic.Enemy_Magic_1[1] and MBD.Session.Spells.Magic.Enemy_Magic_2[1] then
        Print("Enemy Magic Spells:")
        Print("  Enemy Magic Spell 1: " .. MBD.Session.Spells.Magic.Enemy_Magic_1[1])
        Print("  Enemy Magic Spell 1: " .. MBD.Session.Spells.Magic.Enemy_Magic_1[2])
        Print("  Enemy Magic Spell 1: " .. MBD.Session.Spells.Magic.Enemy_Magic_1[3])
        Print("  Enemy Magic Spell 2: " .. MBD.Session.Spells.Magic.Enemy_Magic_2[1])
        Print("  Enemy Magic Spell 2: " .. MBD.Session.Spells.Magic.Enemy_Magic_2[2])
        Print("  Enemy Magic Spell 2: " .. MBD.Session.Spells.Magic.Enemy_Magic_2[3])
        Print("  Can Cure Enemy Magic: " .. tostring(MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic))
    end

    -- Print Disease Spells if they exist
    if MBD.Session.Spells.Disease.Disease_1[1] and MBD.Session.Spells.Disease.Disease_2[1] then
        Print("Disease Spells:")
        Print("  Disease Spell 1: " .. MBD.Session.Spells.Disease.Disease_1[1])
        Print("  Disease Spell 1: " .. MBD.Session.Spells.Disease.Disease_1[2])
        Print("  Disease Spell 1: " .. MBD.Session.Spells.Disease.Disease_1[3])
        Print("  Disease Spell 2: " .. MBD.Session.Spells.Disease.Disease_2[1])
        Print("  Disease Spell 2: " .. MBD.Session.Spells.Disease.Disease_2[2])
        Print("  Disease Spell 2: " .. MBD.Session.Spells.Disease.Disease_2[3])
        Print("  Can Cure Disease: " .. tostring(MBD.Session.Spells.Disease.Can_Cure_Disease))
    end

    -- Print Poison Spells if they exist
    if MBD.Session.Spells.Poison.Poison_1[1] and MBD.Session.Spells.Poison.Poison_2[1] then
        Print("Poison Spells:")
        Print("  Poison Spell 1: " .. MBD.Session.Spells.Poison.Poison_1[1])
        Print("  Poison Spell 1: " .. MBD.Session.Spells.Poison.Poison_1[2])
        Print("  Poison Spell 1: " .. MBD.Session.Spells.Poison.Poison_1[3])
        Print("  Poison Spell 2: " .. MBD.Session.Spells.Poison.Poison_2[1])
        Print("  Poison Spell 2: " .. MBD.Session.Spells.Poison.Poison_2[2])
        Print("  Poison Spell 2: " .. MBD.Session.Spells.Poison.Poison_2[3])
        Print("  Can Cure Poison: " .. tostring(MBD.Session.Spells.Poison.Can_Cure_Poison))
    end

    -- Print Curse Spells if they exist
    if MBD.Session.Spells.Curse.Curse_1[1] then
        Print("Curse Spells:")
        Print("  Curse Spell: " .. MBD.Session.Spells.Curse.Curse_1[1])
        Print("  Curse Spell: " .. MBD.Session.Spells.Curse.Curse_1[2])
        Print("  Curse Spell: " .. MBD.Session.Spells.Curse.Curse_1[3])
        Print("  Can Cure Curse: " .. tostring(MBD.Session.Spells.Curse.Can_Cure_Curse))
    end
end

