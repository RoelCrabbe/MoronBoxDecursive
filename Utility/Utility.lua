-------------------------------------------------------------------------------
-- Table Settings {{{
-------------------------------------------------------------------------------

function MBD_tremovebyval(tab, val)
    local k, v
    for k, v in pairs(tab) do
        if v == val then
            table.remove(tab, k)
            return true
        end
    end
    return false
end

function MBD_tcheckforval(tab, val)
    local k, v
    for k, v in pairs(tab) do
        if v == val then
            return true
        end
    end
    return false
end

function MBD_NameToUnit(Name)

    if not Name then
        return false
    end
    
    if Name == UnitName("player") then
        return "player"
    elseif Name == UnitName("pet") then
        return "pet"
    end
    
    for i = 1, 4 do
        if Name == UnitName("party"..i) then
            return "party"..i
        elseif Name == UnitName("partypet"..i) then
            return "partypet"..i
        end
    end
    
    local numRaidMembers = GetNumGroupMembers()
    if numRaidMembers > 0 then
        for i = 1, numRaidMembers do
            local RaidName = GetRaidRosterInfo(i)
            if Name == RaidName then
                return "raid"..i
            elseif Name == UnitName("raidpet"..i) then
                return "raidpet"..i
            end
        end
    end
    return false
end

function MBD_GetClassColoredName(Unit)
    local _, Class = UnitClass(Unit)
    local UnitName = UnitName(Unit)
    local Color = RAID_CLASS_COLORS[Class] or { r = 1, g = 1, b = 1 }
    local ColorStr = string.format("|cff%02x%02x%02x", Color.r * 255, Color.g * 255, Color.b * 255)
    return ColorStr..UnitName.."|r"
end

function MBD_GetDebuffColored(dBuffType, afflictionText)
    if dBuffType then
        local color = ""
        if dBuffType == "Magic" then
            color = "|cFF3296FF"
        elseif dBuffType == "Poison" then
            color = "|cFF009600"
        elseif dBuffType == "Disease" then
            color = "|cFF966400"
        elseif dBuffType == "Curse" then
            color = "|cFF9600FF"
        end
        return color..afflictionText.."|r"
    else
        return afflictionText
    end
end

function MBD_PrintMessage(message) 
    DEFAULT_CHAT_FRAME:AddMessage("|cffC71585"..MBD_TITLE..": |cff00ff00"..message) 
end

function MBD_ErrorMessage(message) 
    DEFAULT_CHAT_FRAME:AddMessage("|cffC71585"..MBD_TITLE..": |cFFFF0000"..message) 
end

function MBD_SetDefaultValues()
	if MoronBoxDecursive_Options then
        MoronBoxDecursive_Options = MBD_DeepCopyTable(MBD.DefaultOptions)
        ReloadUI()
        return
	end
end

-------------------------------------------------------------------------------
-- Table Functions {{{
-------------------------------------------------------------------------------

function MBD_DeepCopyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[MBD_DeepCopyTable(orig_key)] = MBD_DeepCopyTable(orig_value)
        end
        setmetatable(copy, MBD_DeepCopyTable(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function MBD_SetPresetSettings(targetTable, presetTable)
    if type(targetTable) ~= "table" or type(presetTable) ~= "table" then
        return
    end

    for key, value in pairs(presetTable) do
        if type(value) == "table" then
            if type(targetTable[key]) ~= "table" then
                targetTable[key] = {}
            end
            MBD_SetPresetSettings(targetTable[key], value)
        else
            targetTable[key] = value
        end
    end
end