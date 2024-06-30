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
    };
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
-- The stored variables {{{
-------------------------------------------------------------------------------
