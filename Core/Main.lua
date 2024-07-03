-------------------------------------------------------------------------------
-- InterFace Frames {{{
-------------------------------------------------------------------------------

MBD = CreateFrame("Frame", "MBD", UIParent)
local AddonInitializer = CreateFrame("Frame", nil)

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
	},
}

-------------------------------------------------------------------------------
-- DO NOT CHANGE {{{
-------------------------------------------------------------------------------

MBD.Session = {
    PlayerName = UnitName("player"),
	PlayerClass = UnitClass("player"),
    CastingOn = nil,
    InCombat = nil,
    Elapsed = 0,
    Amount_Of_Afflicted = 5,
    Reconfigure = {
        Enable = false,
        Time = 0,
        Delay = 1
    },
    CureOrderList = {
		[1] = MBD_MAGIC,
		[2] = MBD_CURSE,
		[3] = MBD_POISON,
		[4] = MBD_DISEASE
    },
    Curing_Functions = { },
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
        Cooldown_Check = { 0, "", "" }
    },
    Blacklist = {
        List = { },
        CleanList = { }
    },
    Group = {
        Invalid = false,
        InternalPrioList = { },
        InternalSkipList = { },
        SortingTable = { },
        Unit_Array = { },
        Unit_ArrayByName = { }
    },
    Target = {
        Restore = true,
        AlreadyCleanning = false,
    },
    Debuff = {
        Cache = { },
        Cache_LifeTime = 30,
        Time = 0
    },
    Buff = {
        Cache = { },
        Cache_LifeTime = 30,
        Time = 0
    },
    Display = {
        Time = 0
    },
    AddonLoader = {
        Cooldown = 2.5
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
        "SPELLS_CHANGED",
        "LEARNED_SPELL_IN_TAB",
        "UI_ERROR_MESSAGE",
        "PARTY_MEMBERS_CHANGED",
        "PARTY_LEADER_CHANGED",
        "PLAYER_REGEN_ENABLED",
        "PLAYER_REGEN_DISABLED"
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
    
        AddonInitializer:SetScript("OnUpdate", AddonInitializer.OnUpdate)

    elseif ( event == "SPELLCAST_STOP" or event ==  "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" ) then

        MBD.Session.CastingOn = nil

	elseif ( event == "SPELLCAST_START" ) then


    elseif ( event == "UI_ERROR_MESSAGE" ) then

        if arg1 == SPELL_FAILED_LINE_OF_SIGHT or arg1 == SPELL_FAILED_BAD_TARGETS then
            MBD_SpellCastFailed()
        end

    elseif ( event == "LEARNED_SPELL_IN_TAB" ) then

		MBD_Configure()

    elseif ( event == "SPELLS_CHANGED" and arg1 == nil and not MBD.Session.Reconfigure.Enable ) then

        MBD.Session.Reconfigure.Enable = true

    elseif ( event == "PLAYER_REGEN_ENABLED" ) then

		MBD.Session.InCombat = nil

	elseif ( event == "PLAYER_REGEN_DISABLED" ) then

		MBD.Session.InCombat = true

    elseif ( event == "PLAYER_ENTERING_WORLD" or event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" ) then

		MBD.Session.Group.Invalid = true
    end
end

MBD:SetScript("OnEvent", MBD.OnEvent) 

function MBD:OnUpdate()
    MBD.Session.Elapsed = arg1

    if MBD.Session.Reconfigure.Enable then
        MBD.Session.Reconfigure.Time = MBD.Session.Reconfigure.Time + MBD.Session.Elapsed
        if ( MBD.Session.Reconfigure.Time >= MBD.Session.Reconfigure.Delay ) then
            MBD_ReConfigure()
            MBD.Session.Reconfigure.Time = 0
            MBD.Session.Reconfigure.Enable = false
        end
    end

    if ( MBD.Session.Debuff.Time ~= 0 ) then
        MBD.Session.Debuff.Time = MBD.Session.Debuff.Time - MBD.Session.Elapsed
        if (MBD.Session.Debuff.Time < 0) then
            MBD.Session.Debuff.Time = 0
            MBD.Session.Debuff.Cache = { }
        end
    end

    if ( MBD.Session.Buff.Time ~= 0 ) then
        MBD.Session.Buff.Time = MBD.Session.Buff.Time - MBD.Session.Elapsed
        if ( MBD.Session.Buff.Time < 0 ) then
            MBD.Session.Buff.Time = 0
            MBD.Session.Buff.Cache = { }
        end
    end

    for Unit in MBD.Session.Blacklist.List do
        MBD.Session.Blacklist.List[Unit] = MBD.Session.Blacklist.List[Unit] - MBD.Session.Elapsed
        if ( MBD.Session.Blacklist.List[Unit] < 0 ) then
            MBD.Session.Blacklist.List[Unit] = nil
        end
    end

    MBD.Session.Display.Time = MBD.Session.Display.Time - MBD.Session.Elapsed
    if (MBD.Session.Display.Time <= 0) then
        MBD.Session.Display.Time = MoronBoxDecursive_Options.Slider.ScanFrequency

        local Index = 1
        local TargetExists = false
        MBD_GetUnitArray()
        
        if UnitExists("target") and UnitIsFriend("target", "player") and UnitIsVisible("target") then
            TargetExists = true
            if MBD_ScanUnit("target", Index) then
                Index = Index + 1
            end
        end
        
        for _, unit in ipairs(MBD.Session.Group.Unit_Array) do
            if UnitIsVisible(unit) and (not (TargetExists and UnitIsUnit(unit, "target"))) and (not UnitIsCharmed(unit)) then
                if MBD_ScanUnit(unit, Index) then
                    Index = Index + 1
                end
            end
        end        
        
        MBD_HideAfflictedItemsFromIndex(Index)
    end
end

MBD:SetScript("OnUpdate", MBD.OnUpdate) 

function MBD_SetupSavedVariables()
    if not MoronBoxDecursive_Options then 
        MoronBoxDecursive_Options = MBD.DefaultOptions
    end
end

function AddonInitializer:OnUpdate()

    MBD.Session.AddonLoader.Cooldown = MBD.Session.AddonLoader.Cooldown - MBD.Session.Elapsed
    if MBD.Session.AddonLoader.Cooldown > 0 then return end

    MBD_PrintMessage(MBD_ADDONLOADED)

    if MBD_DISABLEADDON[MBD.Session.PlayerClass] then
        if GetAddOnInfo(MBD_TITLE) then
            DisableAddOn(MBD_TITLE)
            MBD_ErrorMessage(MBD_ADDONDISABLED)
        end
    end

    AddonInitializer:SetScript("OnUpdate", nil)
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
    MBD.Session.Spells.Curse.Curse_1 = { 0, "", "" }
    MBD.Session.Spells.Curse.Can_Cure_Curse = false
    MBD.Session.Curing_Functions = { }

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
                MBD.Session.Spells.Cooldown_Check = {i, BookType}

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
                    MBD.Session.Spells.Curse.Curse_1 = {i, BookType, spellName}
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

    MBD.Session.Curing_Functions = {
        MBD_Cure_Magic,
        MBD_Cure_Curse,
        MBD_Cure_Poison,
        MBD_Cure_Disease
    }

    MBD_VerifyOrderList()
end

function MBD_ReConfigure()

    if not MBD.Session.Spells.HasSpells then
        return
    end

    local magic = MBD.Session.Spells.Magic
    local diseases = MBD.Session.Spells.Disease
    local poisons = MBD.Session.Spells.Poison
    local curses = MBD.Session.Spells.Curse

    local DoNotReconfigure = true

    DoNotReconfigure = MBD_CheckSpellName(magic.Magic_1[1], magic.Magic_1[2], magic.Magic_1[3])
                      and MBD_CheckSpellName(magic.Magic_2[1], magic.Magic_2[2], magic.Magic_2[3])
                      and MBD_CheckSpellName(magic.Enemy_Magic_1[1], magic.Enemy_Magic_1[2], magic.Enemy_Magic_1[3])
                      and MBD_CheckSpellName(magic.Enemy_Magic_2[1], magic.Enemy_Magic_2[2], magic.Enemy_Magic_2[3])
                      and MBD_CheckSpellName(diseases.Disease_1[1], diseases.Disease_1[2], diseases.Disease_1[3])
                      and MBD_CheckSpellName(diseases.Disease_2[1], diseases.Disease_2[2], diseases.Disease_2[3])
                      and MBD_CheckSpellName(poisons.Poison_1[1], poisons.Poison_1[2], poisons.Poison_1[3])
                      and MBD_CheckSpellName(poisons.Poison_2[1], poisons.Poison_2[2], poisons.Poison_2[3])
                      and MBD_CheckSpellName(curses.Curse_1[1], curses.Curse_1[2], curses.Curse_1[3])

    if not DoNotReconfigure then
        MBD_Configure()
    end
end

function MBD_VerifyOrderList()
    
    local i, j = 0, 0
    local TempTable = { }
    local SecTempTable = { }

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

-------------------------------------------------------------------------------
-- Spell Cleaning {{{
-------------------------------------------------------------------------------

function MBD_Clean(UseThisTarget, SwitchToTarget)

    -----------------------------------------------------------------------
    -- Setup: Ensure spellcasting settings are appropriate
    -----------------------------------------------------------------------

    -- Reset autoSelfCast if it's enabled
    if GetCVar("autoSelfCast") == "1" then
        SetCVar("autoSelfCast", "0")
    end

    -- Check if spells are available configure if not
    if not MBD.Session.Spells.HasSpells then
        MBD_Configure()
        if not MBD.Session.Spells.HasSpells then
            return false
        end
    end

    MBD.Session.Target.Restore = true

    -- Switch to specified target if required
    if UseThisTarget and SwitchToTarget then
        TargetUnit(UseThisTarget)
        MBD.Session.Target.Restore = false
    end

    -- Prevent re-entry if already cleaning
    if MBD.Session.Target.AlreadyCleanning then
        return false
    end

    MBD.Session.Target.AlreadyCleanning = true
    SpellStopTargeting()

    -- Stop casting any current spell unless it's a pet spell
    if MBD.Session.Spells.Cooldown_Check[2] ~= "pet" then
        SpellStopCasting()
    end

    -- Check spell cooldown
    local _, cooldown = GetSpellCooldown(MBD.Session.Spells.Cooldown_Check[1], MBD.Session.Spells.Cooldown_Check[2])
    if cooldown ~= 0 then
        MBD.Session.Target.AlreadyCleanning = false
        return false
    end

    -----------------------------------------------------------------------
    -- Target Handling
    -----------------------------------------------------------------------

    local tEnemy = false
    local tName = nil
    local tCleaned = false
    MBD.Session.Blacklist.CleanList = { }
    MBD.Session.CastingOn = nil

    if UnitExists("target") then
        if UnitIsFriend("target", "player") and not UnitIsCharmed("target") then
            if not UseThisTarget or SwitchToTarget then
                tCleaned = MBD_CureUnit("target")
            end
            tName = UnitName("target")
        else
            tEnemy = true
            if UnitIsCharmed("target") then
                if not UseThisTarget or SwitchToTarget then
                    tCleaned = MBD_CureUnit("target")
                end
            end
        end
    end

    -----------------------------------------------------------------------
    -- Attempt to Clean Specific Target if Not Already Cleaned
    -----------------------------------------------------------------------

    if UseThisTarget and not SwitchToTarget and not tCleaned then
        if UnitIsVisible(UseThisTarget) then
            if MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic and UnitIsCharmed(UseThisTarget) then
                tCleaned = MBD_CureUnit(UseThisTarget)
            elseif not MBD_CheckUnitStealth(UseThisTarget) then
                tCleaned = MBD_CureUnit(UseThisTarget)
            end
        end
    end

    -----------------------------------------------------------------------
    -- Clean Party and Raid Members
    -----------------------------------------------------------------------

    if not tCleaned then

        MBD_GetUnitArray()
        
        -- Mind control first
        if MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic then
            for _, unit in ipairs(MBD.Session.Group.Unit_Array) do
                if not MBD.Session.Blacklist.List[unit] and UnitIsVisible(unit) and UnitIsCharmed(unit) then
                    if MBD_CureUnit(unit) then
                        tCleaned = true
                        break
                    end
                end
            end
        end

        -- Priority cleaning
        if not tCleaned then
            for _, unit in ipairs(MBD.Session.Group.Unit_Array) do
                if not MBD.Session.Blacklist.List[unit] and UnitIsVisible(unit) and not UnitIsCharmed(unit) and not MBD_CheckUnitStealth(unit) then
                    if MBD_HandlePriorityDebuffs(unit) then
                        tCleaned = true 
                        break
                    end
                end
            end
        end

        -- Normal cleaning
        if not tCleaned then
            for _, unit in ipairs(MBD.Session.Group.Unit_Array) do
                if not MBD.Session.Blacklist.List[unit] and UnitIsVisible(unit) and not UnitIsCharmed(unit) and not MBD_CheckUnitStealth(unit) then
                    if MBD_CureUnit(unit) then
                        tCleaned = true
                        break
                    end
                end
            end
        end

        -- Recheck blacklist
        if not tCleaned then
            for unit in pairs(MBD.Session.Blacklist.List) do
                if not MBD.Session.Blacklist.CleanList[unit] and UnitExists(unit) and UnitIsVisible(unit) and not MBD_CheckUnitStealth(unit) then
                    if MBD_CureUnit(unit) then
                        MBD.Session.Blacklist.List[unit] = nil
                        tCleaned = true
                        break
                    end
                end
            end
        end
    end

    -----------------------------------------------------------------------
    -- Restore Target or Clear It if Necessary
    -----------------------------------------------------------------------

    if not SwitchToTarget then
        if tEnemy then
            if not UnitIsEnemy("target", "player") then
                TargetUnit("playertarget")
            end
        elseif tName then
            if tName ~= UnitName("target") then
                TargetByName(tName)
            end
        else
            if UnitExists("target") then
                ClearTarget()
            end
        end
    end

    MBD.Session.Target.AlreadyCleanning = false
    return tCleaned
end 

function MBD_HandlePriorityDebuffs(Unit)

    local _, UnitClass = UnitClass(Unit)
    local AllUnitDebuffs = MBD_GetUnitDebuffAll(Unit)
    local tCleaned = false
    
    for dBuffName, _ in pairs(AllUnitDebuffs) do
        if MBD_PRIO_BY_CLASS_LIST[UnitClass] and MBD_PRIO_BY_CLASS_LIST[UnitClass][dBuffName] then
            if MBD_CureUnit(Unit) then
                tCleaned = true
                break
            end
        end
    end
    return tCleaned
end

function MBD_CureUnit(Unit)

    local MagicCount, DiseaseCount, PoisonCount, CurseCount = 0, 0, 0, 0
    local _, UnitClass = UnitClass(Unit)
    local AllUnitDebuffs = MBD_GetUnitDebuffAll(Unit)
    local Result = false
    
    for dBuffName, dBuffParams in AllUnitDebuffs do
        local shouldContinue = true

        if MBD_IGNORELIST[dBuffName] then
            return false
        end

        if MBD_SKIP_LIST[dBuffName] then
            shouldContinue = false
        end

        if MBD.Session.InCombat and MBD_SKIP_BY_CLASS_LIST[UnitClass] and MBD_SKIP_BY_CLASS_LIST[UnitClass][dBuffName] then
            shouldContinue = false
        end

        if shouldContinue then
            if dBuffParams.dBuffType and dBuffParams.dBuffType ~= "" then
                if dBuffParams.dBuffType == MBD_MAGIC then
                    MagicCount = MagicCount + dBuffParams.dBuffApplications + 1
                elseif dBuffParams.dBuffType == MBD_DISEASE then
                    DiseaseCount = DiseaseCount + dBuffParams.dBuffApplications + 1
                elseif dBuffParams.dBuffType == MBD_POISON then
                    PoisonCount = PoisonCount + dBuffParams.dBuffApplications + 1
                elseif dBuffParams.dBuffType == MBD_CURSE then
                    CurseCount = CurseCount + dBuffParams.dBuffApplications + 1
                end
            end
        end
    end

    local DecurseCount = {
        MagicCount = MagicCount,
        CurseCount = CurseCount,
        PoisonCount = PoisonCount,
        DiseaseCount = DiseaseCount
    }

    for i = 1, 4 do
        if MBD.Session.Curing_Functions[i] then
            local Result = MBD.Session.Curing_Functions[i](DecurseCount, Unit)
            if Result then
                break
            end
        end
    end
    return Result
end

function MBD_Cast_CureSpell(SpellID, Unit, AfflictionType, ClearCurrentTarget)
    
    local Name = UnitName(Unit)

    if SpellID[1] == 0 then
        return false
    end

    if SpellID[2] ~= BOOKTYPE_PET and not CheckInteractDistance(Unit, 4) then
        return false
    end

    if ClearCurrentTarget then
        if not UnitIsUnit("target", Unit) then
            ClearTarget()
        end
    elseif UnitIsFriend("player", "target") then
        if not UnitIsUnit("target", Unit) then
            ClearTarget()
        end
    end

    if SpellID[2] == BOOKTYPE_PET or SpellID[3] == MBD_SPELL_PURGE then
        TargetUnit(Unit)
    end

    MBD.Session.CastingOn = Unit
    CastSpell(SpellID[1], SpellID[2])

    if MBD.Session.Target.Restore and (SpellID[2] == BOOKTYPE_PET or SpellID[3] == MBD_SPELL_PURGE) then
        TargetUnit("playertarget")
    else
        if SpellIsTargeting() then
            SpellTargetUnit(Unit)
        end
    end

    if SpellIsTargeting() then
	    SpellStopTargeting()
    end
    return true
end

function MBD_Cure_Magic(Counts, Unit)

    if not (MBD.Session.Spells.Magic.Can_Cure_Magic or MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic) or Counts.MagicCount == 0 then
        return false
    end

    if MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic and UnitIsCharmed(Unit) and UnitCanAttack("player", Unit) then
        if MBD.Session.Spells.Magic.Enemy_Magic_2[1] ~= 0 and (MoronBoxDecursive_Options.CheckBox.Always_Use_Best_Spell or Counts.MagicCount > 1 or MBD.Session.Spells.Magic.Magic_1[1] == 0) then
            return MBD_Cast_CureSpell(MBD.Session.Spells.Magic.Enemy_Magic_2, Unit, MBD_CHARMED, true)
        else
            return MBD_Cast_CureSpell(MBD.Session.Spells.Magic.Enemy_Magic_1, Unit, MBD_CHARMED, true)
        end
    elseif MBD.Session.Spells.Magic.Can_Cure_Magic and not UnitCanAttack("player", Unit) then
        if MBD.Session.Spells.Magic.Magic_2[1] ~= 0 and (MoronBoxDecursive_Options.CheckBox.Always_Use_Best_Spell or Counts.MagicCount > 1 or MBD.Session.Spells.Magic.Magic_1[1] == 0) then
            return MBD_Cast_CureSpell(MBD.Session.Spells.Magic.Magic_2, Unit, MBD_MAGIC, MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic)
        else
            return MBD_Cast_CureSpell(MBD.Session.Spells.Magic.Magic_1, Unit, MBD_MAGIC, MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic)
        end
    end
    return false
end

function MBD_Cure_Curse(Counts, Unit)

    if not MBD.Session.Spells.Curse.Can_Cure_Curse or Counts.CurseCount == 0 then
        return false
    end

    if UnitIsCharmed(Unit) then
        return
    end

    if MBD.Session.Spells.Curse.Curse_1 ~= 0 then
        return MBD_Cast_CureSpell(MBD.Session.Spells.Curse.Curse_1, Unit, MBD_CURSE, false)
    end
    return false
end

function MBD_Cure_Poison(Counts, Unit)

    if not MBD.Session.Spells.Poison.Can_Cure_Poison or Counts.PoisonCount == 0 then
        return false
    end

    if UnitIsCharmed(Unit) then
        return
    end

    if MoronBoxDecursive_Options.CheckBox.Check_For_Abolish and MBD_CheckUnitForBuff(Unit, MBD_SPELL_ABOLISH_POISON) then
        return false
    end

    if MBD.Session.Spells.Poison.Poison_2[1] ~= 0 and (MoronBoxDecursive_Options.CheckBox.Always_Use_Best_Spell or Counts.PoisonCount > 1) then
        return MBD_Cast_CureSpell(MBD.Session.Spells.Poison.Poison_2, Unit, MBD_POISON, false)
    else
        return MBD_Cast_CureSpell(MBD.Session.Spells.Poison.Poison_1, Unit, MBD_POISON, false)
    end
end

function MBD_Cure_Disease(Counts, Unit)

    if not MBD.Session.Spells.Disease.Can_Cure_Disease or Counts.DiseaseCount == 0 then
        return false
    end

    if UnitIsCharmed(Unit) then
        return
    end

    if MoronBoxDecursive_Options.CheckBox.Check_For_Abolish and MBD_CheckUnitForBuff(Unit, MBD_SPELL_ABOLISH_DISEASE) then
        return false
    end

    if MBD.Session.Spells.Disease.Disease_2[1] ~= 0 and (MoronBoxDecursive_Options.CheckBox.Always_Use_Best_Spell or Counts.DiseaseCount > 1) then
        return MBD_Cast_CureSpell(MBD.Session.Spells.Disease.Disease_2, Unit, MBD_DISEASE, false)
    else
        return MBD_Cast_CureSpell(MBD.Session.Spells.Disease.Disease_1, Unit, MBD_DISEASE, false)
    end
end