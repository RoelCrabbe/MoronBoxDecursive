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

function MBD_GetClassColoredName(unit)
    local classColors = {
        ["Warrior"] = "|cffC79C6E",
        ["Hunter"] = "|cffABD473",
        ["Mage"] = "|cff69CCF0",
        ["Rogue"] = "|cffFFF569",
        ["Warlock"] = "|cff9482C9",
        ["Druid"] = "|cffFF7D0A",
        ["Shaman"] = "|cff0070DE",
        ["Priest"] = "|cffFFFFFF",
        ["Paladin"] = "|cffF58CBA",
    }

    local unitClass = UnitClass(unit)
    local unitName = UnitName(unit)
    local color = classColors[unitClass] or "|cffFFFFFF" -- Default to white if class not found

    return color..unitName.."|r"
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