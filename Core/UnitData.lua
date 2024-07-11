-------------------------------------------------------------------------------
-- Get Unit functionalties {{{
-------------------------------------------------------------------------------

function MBD_GetUnitArray()

    if not MBD.Session.Group.Invalid then
        return
    end

    MBD.Session.Group.InternalPrioList = { }
    MBD.Session.Group.InternalSkipList = { }
    MBD.Session.Group.Unit_Array = { }
    MBD.Session.Group.SortingTable = { }

    local SortIndex = 1

    for _, name in MoronBoxDecursive_Options.PriorityList do
        local unit = MBD_NameToUnit(name)
        if unit then
            MBD.Session.Group.InternalPrioList[name] = unit
            MBD.Session.Group.Unit_Array[name] = unit
            MBD_AddToSort(unit, SortIndex)
            SortIndex = SortIndex + 1
        end
    end

    for _, name in MoronBoxDecursive_Options.SkipList do
        local unit = MBD_NameToUnit(name)
        if unit then
            MBD.Session.Group.InternalSkipList[name] = unit
        end
    end

    if not MBD_IsInSkipOrPriorList(MBD.Session.PlayerName) then
        MBD.Session.Group.Unit_Array[MBD.Session.PlayerName] = "player"
        MBD_AddToSort("player", SortIndex)
        SortIndex = SortIndex + 1
    end

    for i = 1, 4 do
        if UnitExists("party"..i) then
            local name = UnitName("party" .. i) or "party" .. i
            if not MBD_IsInSkipOrPriorList(name) then
                MBD.Session.Group.Unit_Array[name] = "party"..i
                MBD_AddToSort("party"..i, SortIndex)
                SortIndex = SortIndex + 1
            end
        end
    end

    if GetNumRaidMembers() > 0 then

        local TempRaidTable = { }
        local CurrentGroup = 0

        for i = 1, GetNumRaidMembers() do
            local rName, _, rGroup = GetRaidRosterInfo(i)

            if CurrentGroup == 0 and rName == MBD.Session.PlayerName then
                CurrentGroup = rGroup
            end

            if CurrentGroup ~= rGroup and not MBD_IsInSkipOrPriorList(rName) then
                TempRaidTable[i] = { }

                if (not rName) then
                    rName = rGroup.."unknown"..i
                end

                TempRaidTable[i] = {
                    rName = rName,
                    rGroup = rGroup,
                    rIndex = i
                }
            end
        end

        for _, raidMember in TempRaidTable do

            if raidMember.rGroup > CurrentGroup then

                MBD.Session.Group.Unit_Array[raidMember.rName] = "raid"..raidMember.rIndex
                MBD_AddToSort("raid"..raidMember.rIndex, raidMember.rGroup * 100 + SortIndex)
                SortIndex = SortIndex + 1

            elseif raidMember.rGroup < CurrentGroup then

                MBD.Session.Group.Unit_Array[raidMember.rName] = "raid"..raidMember.rIndex
                MBD_AddToSort("raid"..raidMember.rIndex, raidMember.rGroup * 100 + 1000 + SortIndex)
                SortIndex = SortIndex + 1
            end
        end

        SortIndex = SortIndex + 8 * 100 + 1000 + 1
    end

    local TempTable = { }

    for _, v in pairs(MBD.Session.Group.Unit_Array) do
        table.insert(TempTable, v)
    end

    MBD.Session.Group.Unit_ArrayByName = MBD.Session.Group.Unit_Array
    MBD.Session.Group.Unit_Array = TempTable
    MBD.Session.Group.Invalid = false

    table.sort(MBD.Session.Group.Unit_Array, function(a, b) return MBD.Session.Group.SortingTable[a] < MBD.Session.Group.SortingTable[b] end)
end

function MBD_IsInSkipOrPriorList(Name)
    return MBD.Session.Group.InternalSkipList[Name] or MBD.Session.Group.InternalPrioList[Name] or false
end

function MBD_AddToSort(Unit, Index)
    if MoronBoxDecursive_Options.CheckBox.Random_Order and not MBD.Session.Group.InternalPrioList[UnitName(Unit)] and not UnitIsUnit(Unit, "player") then
        Index = math.random(1, 3000)
    end

    MBD.Session.Group.SortingTable[Unit] = Index
end

-------------------------------------------------------------------------------
-- Scanning functionalties {{{
-------------------------------------------------------------------------------

function MBD_ScanUnit(Unit, Index)

    local AllUnitDebuffs = { }
    local _, UnitClass = UnitClass(Unit)
    AllUnitDebuffs = MBD_GetUnitDebuffAll(Unit)

    for dBuffName, dBuffParams in AllUnitDebuffs do

        if MBD_IGNORELIST[dBuffName] then
            return false
        end

        if MBD_SKIP_LIST[dBuffName] then
            break
        end

        if MBD.Session.InCombat and MBD_SKIP_BY_CLASS_LIST[UnitClass] and MBD_SKIP_BY_CLASS_LIST[UnitClass][dBuffName] then
            break
        end

        if dBuffParams.dBuffType and dBuffParams.dBuffType ~= "" then
            if dBuffParams.dBuffType == MBD_MAGIC then
                if UnitIsCharmed(Unit) and MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic then
                    MBD_UpdateLiveDisplay(Index, Unit, dBuffParams)
                    return true
                elseif not UnitIsCharmed(Unit) and MBD.Session.Spells.Magic.Can_Cure_Magic then
                    MBD_UpdateLiveDisplay(Index, Unit, dBuffParams)
                    return true
                end
            elseif dBuffParams.dBuffType == MBD_DISEASE and MBD.Session.Spells.Disease.Can_Cure_Disease then
                MBD_UpdateLiveDisplay(Index, Unit, dBuffParams)
                return true
            elseif dBuffParams.dBuffType == MBD_POISON and MBD.Session.Spells.Poison.Can_Cure_Poison then
                MBD_UpdateLiveDisplay(Index, Unit, dBuffParams)
                return true
            elseif dBuffParams.dBuffType == MBD_CURSE and MBD.Session.Spells.Curse.Can_Cure_Curse then
                MBD_UpdateLiveDisplay(Index, Unit, dBuffParams)
                return true
            end
        end
    end
    return false
end

function MBD_SpellCastFailed()
    if (MBD.Session.CastingOn and not (UnitIsUnit(MBD.Session.CastingOn, "player"))) then
        MBD.Session.Blacklist.List[MBD.Session.CastingOn] = nil
        MBD.Session.Blacklist.List[MBD.Session.CastingOn] = MoronBoxDecursive_Options.Slider.Seconds_On_Blacklist
        MBD.Session.Blacklist.CleanList[MBD.Session.CastingOn] = true
    end
end