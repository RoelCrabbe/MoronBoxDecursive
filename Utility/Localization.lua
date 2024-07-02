-------------------------------------------------------------------------------
-- English Language {{{
-------------------------------------------------------------------------------

MBD_TITLE = "MoronBoxDecursive"
MBD_AUTHOR = 'MoRoN'
MBD_HIDE = 'Close'
MBD_EXIT = "Get lost!"
MBD_MINIMAPHOVER = "Click to show/hide the option frame."

MBD_DISEASE = 'Disease'
MBD_MAGIC   = 'Magic'
MBD_POISON  = 'Poison'
MBD_CURSE   = 'Curse'
MBD_CHARMED = 'Charm'

MBD_CLASS_DRUID   = "Druid"
MBD_CLASS_HUNTER  = "Hunter"
MBD_CLASS_MAGE    = "Mage"
MBD_CLASS_PALADIN = "Paladin"
MBD_CLASS_PRIEST  = "Priest"
MBD_CLASS_ROGUE   = "Rogue"
MBD_CLASS_SHAMAN  = "Shaman"
MBD_CLASS_WARLOCK = "Warlock"
MBD_CLASS_WARRIOR = "Warrior"

-- Option Frame -- 

MBD_TIMEONBLACKLISTSLIDER = "Time on Blacklist: $p Sec"
MBD_SCANFREQUENCYSLIDER = "Update Every: $p Sec"

MBD_ABOLISHCHECK       = "Check for Abolish:"
MBD_ALWAYSBESTSPELL    = "Always Highest Spell Rank:"
MBD_CURERANDOMORDER    = "Cure in Random Order:"

-- Spell Configure -- 

MBD_SPELL_CURE_DISEASE        = 'Cure Disease'
MBD_SPELL_ABOLISH_DISEASE     = 'Abolish Disease'
MBD_SPELL_PURIFY              = 'Purify'
MBD_SPELL_CLEANSE             = 'Cleanse'
MBD_SPELL_DISPELL_MAGIC       = 'Dispel Magic'
MBD_SPELL_CURE_POISON         = 'Cure Poison'
MBD_SPELL_ABOLISH_POISON      = 'Abolish Poison'
MBD_SPELL_REMOVE_LESSER_CURSE = 'Remove Lesser Curse'
MBD_SPELL_REMOVE_CURSE        = 'Remove Curse'
MBD_SPELL_PURGE               = 'Purge'
MBD_PET_FEL_CAST              = "Devour Magic"
MBD_PET_DOOM_CAST             = "Dispel Magic"

MBD_INVISIBLE_LIST = {
    ["Prowl"]       = true,
    ["Stealth"]     = true,
    ["Shadowmeld"]  = true,
}

MBD_IGNORELIST = {
    ["Banish"]      	    = true,
    ["Phase Shift"] 	    = true,
	["Mind Control"]	    = true,
	["Will of Hakkar"]      = true,
	["Cause Insanity"]      = true,
	["True Fulfillment"]    = true,
	["Consuming Shadows"]   = true,
	["Brood Power: Bronze"] = true,
	["Brood Power: Blue"]   = true,
}

MBD_SKIP_LIST = {
    ["Dreamless Sleep"]         = true,
    ["Greater Dreamless Sleep"] = true,
    ["Mind Vision"]             = true,
    ["Mutating Injection"]      = true,
	["Incite Flames"]           = true,
}

MBD_SKIP_BY_CLASS_LIST = {
    [MBD_CLASS_WARRIOR] = {
        ["Ancient Hysteria"]   = true,
        ["Ignite Mana"]        = true,
        ["Tainted Mind"]       = true,
        ["Curse of Tongues"]   = true,
    },
    [MBD_CLASS_ROGUE] = {
        ["Silence"]            = true,
        ["Ancient Hysteria"]   = true,
        ["Ignite Mana"]        = true,
        ["Tainted Mind"]       = true,
        ["Curse of Tongues"]   = true,
    },
    [MBD_CLASS_HUNTER] = {
        ["Magma Shackles"]     = true,
        ["Curse of Tongues"]   = true,
    },
    [MBD_CLASS_MAGE] = {
        ["Magma Shackles"]     = true,
    }
}

MBD_ADDONLOADED = "Has been successfully loaded."
MBD_ADDONDISABLED = "Addon has been disabled! Be sure to ReloadUI."

MBD_DISABLEADDON = {
    [MBD_CLASS_ROGUE] = true,
    [MBD_CLASS_WARRIOR] = true,
    [MBD_CLASS_HUNTER] = true,
    [MBD_CLASS_WARLOCK] = true
}