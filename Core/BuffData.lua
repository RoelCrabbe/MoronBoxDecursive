-------------------------------------------------------------------------------
-- Scanning Frame {{{
-------------------------------------------------------------------------------

local MBD_ScanningTooltip = CreateFrame("GameTooltip", "MBD_ScanningTooltip", nil, "GameTooltipTemplate")
MBD_ScanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-------------------------------------------------------------------------------
-- Buffing functionalties {{{
-------------------------------------------------------------------------------

function MBD_GetUnitdBuffName(Unit, i, DebuffTexture)
    local dBuffName

    if not MBD.Session.Debuff.Cache[DebuffTexture] then

        MBD_ScanningTooltipTextLeft1:SetText("")
        MBD_ScanningTooltip:SetUnitDebuff(Unit, i)
        dBuffName = MBD_ScanningTooltipTextLeft1:GetText()

        if not dBuffName or dBuffName == "" then
            return false
        else
            MBD.Session.Debuff.Time = MBD.Session.Debuff.Cache_LifeTime
            MBD.Session.Debuff.Cache[DebuffTexture] = dBuffName
        end
    else
        dBuffName = MBD.Session.Debuff.Cache[DebuffTexture]
    end

    MBD.Session.Debuff.Cache_life = MBD.Session.Debuff.Cache_LifeTime
    return dBuffName
end

function MBD_CheckUnitStealth(Unit)
	for BuffName in MBD_INVISIBLE_LIST do
	    if MBD_CheckUnitForBuff(Unit, BuffName) then
            return true
	    end
	end
    return false
end

-------------------------------------------------------------------------------
-- Debuffing functionalities {{{
-------------------------------------------------------------------------------

function MBD_CheckUnitForBuff(Unit, BuffNameToCheck)
    local buffIndex = 1
    local buffTexture, buffName

    while true do
        buffTexture = UnitBuff(Unit, buffIndex)

        if not buffTexture then
            break
        end

        if not MBD.Session.Buff.Cache[buffTexture] then

            MBD_ScanningTooltipTextLeft1:SetText("")
            MBD_ScanningTooltip:SetUnitBuff(Unit, buffIndex)
            buffName = MBD_ScanningTooltipTextLeft1:GetText()

            if buffName and buffName ~= "" then
                MBD.Session.Buff.Time = MBD.Session.Buff.Cache_LifeTime
                MBD.Session.Buff.Cache[buffTexture] = buffName
            end
        else
            buffName = MBD.Session.Buff.Cache[buffTexture]
        end

        if buffIndex > 1 then 
            MBD.Session.Buff.Time = MBD.Session.Buff.Cache_LifeTime
        end

        if buffName == BuffNameToCheck then
            return true
        end

        buffIndex = buffIndex + 1
    end
    return false
end

function MBD_GetUnitDebuff(Unit, i)

    local dBuffTexture, dBuffApplications, dBuffType = UnitDebuff(Unit, i)

    if (dBuffTexture) then
	    dBuffName = MBD_GetUnitdBuffName(Unit, i, dBuffTexture)
	    return dBuffName, dBuffType, dBuffApplications, dBuffTexture
    else
	    return false, false, false, false
    end
end

function MBD_GetUnitDebuffAll(Unit)

    local dBuffTexture, dBuffApplications, dBuffType, dBuffName, i
    local ThisUnitDebuffs = { }
    local i = 1

    while (true) do
	    dBuffName, dBuffType, dBuffApplications, dBuffTexture = MBD_GetUnitDebuff(Unit, i)

        if (not dBuffName) then
            break
        end

        ThisUnitDebuffs[dBuffName] = { }
        ThisUnitDebuffs[dBuffName].dBuffTexture	= dBuffTexture
        ThisUnitDebuffs[dBuffName].dBuffApplications = dBuffApplications
        ThisUnitDebuffs[dBuffName].dBuffType	= dBuffType
        ThisUnitDebuffs[dBuffName].dBuffName	= dBuffName
        ThisUnitDebuffs[dBuffName].index		= i

        i = i + 1
    end
    return ThisUnitDebuffs
end

function MBD_CheckSpellName(Id, BookType, SpellName)
    if Id ~= 0 then
        local FoundSpellName, SpellRank = GetSpellName(Id, BookType)
        if SpellName ~= FoundSpellName then
            return false
        end
    end
    return true
end