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

function MBD_IsInSkipOrPriorList(name)
    if MBD.Session.Group.InternalSkipList[name] then
        return true
    end
    if MBD.Session.Group.InternalPrioList[name] then
        return true
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
            color = "|cFF6495ED"
        elseif dBuffType == "Poison" then
            color = "|cFF32CD32"
        elseif dBuffType == "Disease" then
            color = "|cFFFFD700"
        elseif dBuffType == "Curse" then
            color = "|cFF8A2BE2"
        end
        return color..afflictionText.."|r"
    else
        return afflictionText
    end
end