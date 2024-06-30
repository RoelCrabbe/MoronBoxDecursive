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
