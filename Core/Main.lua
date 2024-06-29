-------------------------------------------------------------------------------
-- variables {{{
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- The stored variables {{{
-------------------------------------------------------------------------------
Dcr_Saved = {
    -- this is the items that are stored...

    Dcr_Print_DEBUG_bis = false;

    -- this is the priority list of people to cure
    PriorityList = { };

    -- this is the people to skip
    SkipList = { };

    -- this is wether or not to show the "live" list	
    Hide_LiveList = false;

    -- This will turn on and off the sending of messages to the default chat frame
    Print_ChatFrame = false;

    -- this will send the messages to a custom frame that is moveable	
    Print_CustomFrame = true;

    -- this will disable error messages
    Print_Error = true;

    -- check for abolish before curing poison or disease
    Check_For_Abolish = true;

    -- this is "fix" for the fact that rank 1 of dispell magic does not always remove
    -- the high level debuffs properly. This carrys over to other things.
    AlwaysUseBestSpell = true;

    -- should we do the orders randomly?
    Random_Order = false;

    -- should we scan pets
    Scan_Pets = true;

    -- should we ignore stealthed units
    Ingore_Stealthed = false;

    -- how many to show in the livelist
    Amount_Of_Afflicted = 5;

    -- how many seconds to "black list" someone with a failed spell
    CureBlacklist	= 5.0;

    -- how often to poll for afflictions in seconds
    ScanTime = 0.2;

    -- Are prio list members protected from blacklisting?
    DoNot_Blacklist_Prio_List = false;


    -- Display text above in the custom frame
    CustomeFrameInsertBottom = false;

    -- Disable tooltips in affliction list
    AfflictionTooltips = true;

    -- Reverse LiveList Display
    ReverseLiveDisplay = false;

    -- Hide everything but the livelist
    Hidden = false;

    -- if true then the live list will show only if the main window is shown
    LiveListTied = false;
    
    -- allow to changes the default output window
    Dcr_OutputWindow = DEFAULT_CHAT_FRAME;

    -- cure order list
    CureOrderList = {
	[1] = DCR_MAGIC,
	[2] = DCR_CURSE,
	[3] = DCR_POISON,
	[4] = DCR_DISEASE
    }


}; -- // }}}