DCR_INVISIBLE_LIST = {
    ["Prowl"]       = true,
    ["Stealth"]     = true,
    ["Shadowmeld"]  = true,
}

-- this causes the target to be ignored!!!!
DCR_IGNORELIST = {
    ["Banish"]      	= true,
    ["Phase Shift"] 	= true,
	["Mind Control"]	= true,
	["Will of Hakkar"]  = true,
	["Cause Insanity"]  = true,
	["True Fulfillment"] = true,
	["Consuming Shadows"] = true,
	["Shadow Command"] = true,
	["Brood Power: Bronze"] = true,
	["Brood Power: Blue"] = true
};

-- ignore this effect
DCR_SKIP_LIST = {
    ["Dreamless Sleep"] = true,
    ["Greater Dreamless Sleep"] = true,
    ["Mind Vision"] = true,
    ["Mutating Injection"] = true,
	["Incite Flames"] = true,
};

-- ignore the effect bassed on the class

DCR_SKIP_BY_CLASS_LIST = {
	[DCR_CLASS_WARRIOR] = {
		["Ancient Hysteria"]   = true,
		["Ignite Mana"]        = true,
		["Tainted Mind"]       = true,
		["Curse of Tongues"]   = true,
	};
	[DCR_CLASS_ROGUE] = {
		["Silence"]            = true;
		["Ancient Hysteria"]   = true,
		["Ignite Mana"]        = true,
		["Tainted Mind"]       = true,
		["Curse of Tongues"]   = true,
	};
	[DCR_CLASS_HUNTER] = {
		["Magma Shackles"]     = true,
		["Curse of Tongues"]   = true,
	};
	[DCR_CLASS_MAGE] = {
		["Magma Shackles"]     = true,
		["Detect Magic"] 	   = true
	};
};