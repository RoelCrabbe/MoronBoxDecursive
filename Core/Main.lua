-------------------------------------------------------------------------------
-- Variables {{{
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- The Stored Variables {{{
-------------------------------------------------------------------------------

Drc_Options = {

	Slider = {
		--
		Display_Amount_Of_Afflicted = 5; -- Opt

		Seconds_On_The_Blacklist = 4; -- Opt

		Seconds_Between_Scans = 0.3; -- Opt
		--
	},

	CheckBox = {
		--
		Active_Debug_Messages = true; -- Opt

		Check_For_Abolish = true; -- Opt

		Do_Not_Blacklist_Prio_List = false; -- Opt

		Always_Use_Best_Spell = true; -- Opt

		Random_Order = true; -- Opt

		Scan_Pets = false; -- Opt

		Ingore_Stealthed = false; -- Opt

		CustomeFrameInsertBottom = false; -- Test Anchor
		--
	},

	ActiveDecurse = {
		--
		CureMagic	= true;

		CurePoison	= true;

		CureDisease	= true;

		CureCurse	= true;
		--
	}
};

Dcr_Saved = { -- These are the items that are stored...

    PriorityList = { };

    SkipList = { };

	CureOrderList = {
		[1] = DCR_MAGIC,
		[2] = DCR_CURSE,
		[3] = DCR_POISON,
		[4] = DCR_DISEASE
    };
};

Drc_Settings = {

	HideButtons = false; -- MainMenu

	Hidden = false; -- MainMenu

	Dcr_OutputWindow = DEFAULT_CHAT_FRAME;
}

-------------------------------------------------------------------------------

local DCR_MAX_LIVE_SLOTS = 15;
local DCR_TEXT_LIFETIME = 3;

local DCR_ThisCleanBlaclisted = { };

local DCR_HAS_SPELLS		= false;

local DCR_SPELL_MAGIC_1		= {0, "", ""};
local DCR_SPELL_MAGIC_2		= {0, "", ""};
DCR_CAN_CURE_MAGIC = false;

local DCR_SPELL_ENEMY_MAGIC_1	= {0, "", ""};
local DCR_SPELL_ENEMY_MAGIC_2	= {0, "", ""};
DCR_CAN_CURE_ENEMY_MAGIC	= false;

local DCR_SPELL_DISEASE_1	= {0, "", ""};
local DCR_SPELL_DISEASE_2	= {0, "", ""};
DCR_CAN_CURE_DISEASE	= false;

local DCR_SPELL_POISON_1	= {0, "", ""};
local DCR_SPELL_POISON_2	= {0, "", ""};
DCR_CAN_CURE_POISON	= false;

local DCR_SPELL_CURSE		= {0, "", ""};
DCR_CAN_CURE_CURSE	= false;

local DCR_SPELL_COOLDOWN_CHECK	= {0, "", ""};

local Dcr_Casting_Spell_On = nil;
local Dcr_Blacklist_Array = { };

local DEBUFF_CACHE_LIFE = 30.0;
local Dcr_Debuff_Texture_to_name_cache = {};
local Dcr_Debuff_Texture_to_name_cache_life = 0.0;

local Dcr_Buff_Texture_to_name_cache = {};
local Dcr_Buff_Texture_to_name_cache_life = 0.0;

local Dcr_CheckingPET = false;
local Dcr_DelayedReconf = false;

Dcr_Groups_datas_are_invalid = false;

local InternalPrioList	    = { };
local InternalSkipList	    = { };
local Dcr_Unit_Array	    = { };
local Dcr_Unit_ArrayByName  = { };
local target_added = false;

local SortingTable = {};

local Dcr_CheckPet_Delay	= 2;
local Dcr_DelayedReconf_delay	= 1;

local Dcr_DelayedReconf_timer	= 0;
local Dcr_CheckPet_Timer	= 0;
local Dcr_SpellCombatDelay = 1;
local Dcr_Delay_Timer		= 0;

local last_DemonType = nil;
local curr_DemonType = nil;

local Dcr_AlreadyCleanning = false;
local Dcr_RestoreTarget = true;

local Dcr_CombatMode = false;

local Dcr_timeLeft = 0;

local Curing_functions = {};

Dcr_CureTypeCheckBoxes = {};

local RestorSelfAutoCastTimeOut = 1;
local RestorSelfAutoCast = false;

-------------------------------------------------------------------------------
-- The UI functions {{{
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- The printing functions {{{
-------------------------------------------------------------------------------

function MakePlayerName(name)
	return GetColors(name)
end

function MakeAfflictionName(name)
    if (name) then
        local color = ""
        if name == "Magic" then
            color = "|cFF6495ED" -- Blue
        elseif name == "Poison" then
            color = "|cFF32CD32" -- Green
        elseif name == "Disease" then
            color = "|cFFFFD700" -- Yellow
        elseif name == "Curse" then
            color = "|cFF8A2BE2" -- Purple
        end
        return color..DCR_LOC_AF_TYPE[name].."|r"
    else
        return ""
    end
end

function Dcr_Print(Message)
    if (Drc_Options.CheckBox.Active_Debug_Messages) then
		DecursiveTextFrame:AddMessage(Message, 1, 1, 1, 0.9);
    end
end 

function Dcr_ErrorMessage(message)
    local titleColor = "|cffC71585" -- This color code represents gold
    local errorMessageColor = "|cFFFF0000" -- This color code represents red

    DEFAULT_CHAT_FRAME:AddMessage(titleColor .. DCR_ADDON_NAME .. ": " .. errorMessageColor .. message)
end


function Dcr_PrintMessage(message)
    local titleColor = "|cffC71585" -- This color code represents gold
    local messageColor = "|cff00ff00" -- This color code represents green

    DEFAULT_CHAT_FRAME:AddMessage(titleColor .. DCR_ADDON_NAME .. ": " .. messageColor .. message)
end

-------------------------------------------------------------------------------

function Dcr_Hide(hide)

    if (hide==1 or (not hide and DecursiveMainBar:IsVisible())) then

		Drc_Settings.Hidden = true;
		DecursiveMainBar:Hide();
    else

		Drc_Settings.Hidden = false;
		DecursiveMainBar:ClearAllPoints();
		DecursiveMainBar:SetPoint("CENTER", UIParent, "TOP", 0, -100)
		DecursiveMainBar:Show();
    end

    if DecursiveMainBar:IsVisible() and DecursiveAfflictedListFrame:IsVisible() then
		DecursiveAfflictedListFrame:ClearAllPoints();
		DecursiveAfflictedListFrame:SetPoint("TOPLEFT", "DecursiveMainBar", "BOTTOMLEFT");
    else
		Drc_Settings.Dcr_OutputWindow:AddMessage(DCR_SHOW_MSG, 0.3, 0.5, 1);
    end
end

function Dcr_ShowHidePriorityListUI()
    if (DecursivePriorityListFrame:IsVisible()) then
		DecursivePriorityListFrame:Hide();
    else
		DecursivePriorityListFrame:Show();
    end
end

function Dcr_ShowHideSkipListUI()
    if (DecursiveSkipListFrame:IsVisible()) then
		DecursiveSkipListFrame:Hide();
    else
		DecursiveSkipListFrame:Show();
    end
end

function Dcr_ShowHideOptionsUI()
    if (DcrOptionsFrame:IsVisible()) then
		DcrOptionsFrame:Hide();
    else
		DcrOptionsFrame:Show();
		DcrOptionsFrame2:ClearAllPoints();
		DcrOptionsFrame2:SetPoint("TOPLEFT", "DcrOptionsFrame", "TOPRIGHT");
    end
end

function Dcr_ShowHideTextAnchor()
    if (DecursiveAnchor:IsVisible()) then
		DecursiveAnchor:Hide();
    else
		DecursiveAnchor:Show();
    end
end

function Dcr_ShowHideButtons(UseCurrentValue)

    local DecrFrame = "DecursiveMainBar";
    local buttons = {
		DecrFrame.."Priority",
		DecrFrame.."Skip",
		DecrFrame.."Options",
		DecrFrame.."Hide",
    }

    DCRframeObject = getglobal(DecrFrame);

    if (not UseCurrentValue) then
		Drc_Settings.HideButtons = (not Drc_Settings.HideButtons);
	end

	for _, ButtonName in buttons do
		Button = getglobal(ButtonName);

		if (Drc_Settings.HideButtons) then
			Button:Show();
			DCRframeObject.isLocked = 0;
		else
			Button:Hide();
			DCRframeObject.isLocked = 1;
		end
    end
end

function Dcr_ChangeTextFrameDirection(bottom)
    buton = DecursiveAnchorDirection;
    if (bottom) then
		DecursiveTextFrame:SetInsertMode("BOTTOM");
		buton:SetText("v");
    else
		DecursiveTextFrame:SetInsertMode("TOP");
		buton:SetText("^");
    end
end

function Dcr_AmountOfAfflictedSlider_OnShow()

    getglobal(this:GetName().."Text"):SetText(DCR_AMOUNT_AFFLIC..Drc_Options.Slider.Display_Amount_Of_Afflicted)
    getglobal(this:GetName().."Text"):SetPoint("BOTTOM", this, "TOP", 0, 5)

    this:SetMinMaxValues(1, 15)
    this:SetValueStep(1)
    this:SetValue(Drc_Options.Slider.Display_Amount_Of_Afflicted)
    
    getglobal(this:GetName().."Low"):Hide()
    getglobal(this:GetName().."High"):Hide()
    
    local minValueText = this:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minValueText:SetText("1")
    minValueText:SetPoint("CENTER", this, "LEFT", -5, 0)
    
    local maxValueText = this:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    maxValueText:SetText("15")
    maxValueText:SetPoint("CENTER", this, "RIGHT", 5, 0)
end

function Dcr_AmountOfAfflictedSlider_OnValueChanged()
    Drc_Options.Slider.Display_Amount_Of_Afflicted = this:GetValue();
    getglobal(this:GetName().."Text"):SetText(DCR_AMOUNT_AFFLIC..Drc_Options.Slider.Display_Amount_Of_Afflicted);
    getglobal(this:GetName().."Text"):SetPoint("BOTTOM", this, "TOP", 0, 5)
end

function Dcr_ScanTimeSlider_OnShow()

    getglobal(this:GetName().."Text"):SetText(DCR_SCAN_LENGTH..Drc_Options.Slider.Seconds_Between_Scans);
    getglobal(this:GetName().."Text"):SetPoint("BOTTOM", this, "TOP", 0, 5)

    this:SetMinMaxValues(0.1, 1);
    this:SetValueStep(0.1);
    this:SetValue(Drc_Options.Slider.Seconds_Between_Scans);

	getglobal(this:GetName().."Low"):Hide()
    getglobal(this:GetName().."High"):Hide()

	local minValueText = this:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minValueText:SetText("0.1")
    minValueText:SetPoint("CENTER", this, "LEFT", -8, 0)
    
    local maxValueText = this:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    maxValueText:SetText("1")
    maxValueText:SetPoint("CENTER", this, "RIGHT", 5, 0)
end

function Dcr_ScanTimeSlider_OnValueChanged()
    Drc_Options.Slider.Seconds_Between_Scans = this:GetValue() * 10;

    if (Drc_Options.Slider.Seconds_Between_Scans < 0) then
		Drc_Options.Slider.Seconds_Between_Scans = ceil(Drc_Options.Slider.Seconds_Between_Scans - 0.5)
    else
		Drc_Options.Slider.Seconds_Between_Scans = floor(Drc_Options.Slider.Seconds_Between_Scans + 0.5)
    end

    Drc_Options.Slider.Seconds_Between_Scans = Drc_Options.Slider.Seconds_Between_Scans / 10;
    getglobal(this:GetName().."Text"):SetText(DCR_SCAN_LENGTH..Drc_Options.Slider.Seconds_Between_Scans);
	getglobal(this:GetName().."Text"):SetPoint("BOTTOM", this, "TOP", 0, 5)
end

function Dcr_CureBlacklistSlider_OnShow()

    getglobal(this:GetName().."Text"):SetText(DCR_BLACK_LENGTH..Drc_Options.Slider.Seconds_On_The_Blacklist);
    getglobal(this:GetName().."Text"):SetPoint("BOTTOM", this, "TOP", 0, 5)

    this:SetMinMaxValues(1, 20);
    this:SetValueStep(0.1);
    this:SetValue(Drc_Options.Slider.Seconds_On_The_Blacklist);

	getglobal(this:GetName().."Low"):Hide()
    getglobal(this:GetName().."High"):Hide()

	local minValueText = this:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minValueText:SetText("1")
    minValueText:SetPoint("CENTER", this, "LEFT", -5, 0)
    
    local maxValueText = this:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    maxValueText:SetText("20")
    maxValueText:SetPoint("CENTER", this, "RIGHT", 7, 0)
end

function Dcr_CureBlacklistSlider_OnValueChanged()
    Drc_Options.Slider.Seconds_On_The_Blacklist = this:GetValue() * 10;

    if (Drc_Options.Slider.Seconds_On_The_Blacklist < 0) then
		Drc_Options.Slider.Seconds_On_The_Blacklist = ceil(Drc_Options.Slider.Seconds_On_The_Blacklist - 0.5)
    else
		Drc_Options.Slider.Seconds_On_The_Blacklist = floor(Drc_Options.Slider.Seconds_On_The_Blacklist + 0.5)
    end

    Drc_Options.Slider.Seconds_On_The_Blacklist = Drc_Options.Slider.Seconds_On_The_Blacklist / 10;
    getglobal(this:GetName().."Text"):SetText(DCR_BLACK_LENGTH..Drc_Options.Slider.Seconds_On_The_Blacklist);
	getglobal(this:GetName().."Text"):SetPoint("BOTTOM", this, "TOP", 0, 5)

end

function Dcr_On_CureOrderCheckBox_Update(CheckBox)

    if (CheckBox.CurePos ~= 0 and not CheckBox:GetChecked()) then

		CheckBox.CurePos = 0;

		Dcr_Tremovebyval(Dcr_Saved.CureOrderList, CheckBox.CureType);
		getglobal(CheckBox:GetName().."LText"):SetText("");
		Dcr_SetCureOrderList ();

    elseif ( CheckBox.CurePos == 0 and CheckBox:GetChecked()) then
	
		CheckBox.CurePos = table.getn(Dcr_Saved.CureOrderList) + 1;
		Dcr_Saved.CureOrderList[CheckBox.CurePos] = CheckBox.CureType;

		Dcr_SetCureOrderList ();
    end
end

function Dcr_SetCureOrderList ()

    local i;
    local j = 0;
    local CheckBox;
    local temp_table = {};
    Curing_functions = {};

    for i=1, 4 do
		if (Dcr_Saved.CureOrderList[i]) then
		
			CheckBox =  Dcr_CureTypeCheckBoxes[Dcr_Saved.CureOrderList[i]];
			j = j + 1;
			temp_table[j] = Dcr_Saved.CureOrderList[i];

			Curing_functions[j] = CheckBox.CureFunction;
			CheckBox.CurePos = j;

			getglobal(CheckBox:GetName().."LText"):SetText("|cFF00FF00"..j.."|r ");
		end
    end

    Dcr_Saved.CureOrderList = temp_table;
end

function VerifyOrderList ()

    local TempTable = {};
    local i;

    for i=1, 4 do
		if ( Dcr_Saved.CureOrderList[i] and not Dcr_Tcheckforval(TempTable, Dcr_Saved.CureOrderList[i])) then
			
			TempTable[i] = Dcr_Saved.CureOrderList[i];
		end
    end

    if (Drc_Options.ActiveDecurse.CureMagic	and	not Dcr_Tcheckforval(TempTable,   DCR_MAGIC	)) then 
		table.insert(TempTable, DCR_MAGIC);
    end

    if (Drc_Options.ActiveDecurse.CureCurse	and	not Dcr_Tcheckforval(TempTable,   DCR_CURSE	)) then 
		table.insert(TempTable, DCR_CURSE);
    end

    if (Drc_Options.ActiveDecurse.CurePoison    and	not Dcr_Tcheckforval(TempTable,   DCR_POISON	)) then
		table.insert(TempTable, DCR_POISON);
    end

    if (Drc_Options.ActiveDecurse.CureDisease   and	not Dcr_Tcheckforval(TempTable,   DCR_DISEASE	)) then 
		table.insert(TempTable, DCR_DISEASE);
    end

    Dcr_Saved.CureOrderList = TempTable;
end

function Dcr_Tremovebyval(tab, val)
    local k;
    local v;

    for k,v in tab do
		if(v==val) then
			table.remove(tab, k);
			return true;
		end
    end
    return false;
end

function Dcr_Tcheckforval(tab, val)
    local k;
    local v;
    for k,v in tab do
		if(v==val) then
			return true;
		end
    end
    return false;
end

function Dcr_ResetWindow()

    DecursiveMainBar:ClearAllPoints();
    DecursiveMainBar:SetPoint("CENTER", UIParent, "TOP", 0, -100)
    DecursiveMainBar:Show();

    DecursiveAfflictedListFrame:ClearAllPoints();
    DecursiveAfflictedListFrame:SetPoint("TOPLEFT", "DecursiveMainBar", "BOTTOMLEFT");
    DecursiveAfflictedListFrame:Show();

    DecursivePriorityListFrame:ClearAllPoints();
    DecursivePriorityListFrame:SetPoint("CENTER", "UIParent");

    DecursiveSkipListFrame:ClearAllPoints();
    DecursiveSkipListFrame:SetPoint("CENTER", "UIParent");

    DecursivePopulateListFrame:ClearAllPoints();
    DecursivePopulateListFrame:SetPoint("CENTER", "UIParent");

    DcrOptionsFrame:ClearAllPoints();
    DcrOptionsFrame:SetPoint("CENTER", "UIParent");

    DcrOptionsFrame2:ClearAllPoints();
    DcrOptionsFrame2:SetPoint("TOPLEFT", "DcrOptionsFrame", "TOPRIGHT");
end

function Dcr_ThisSetText(text)
    getglobal(this:GetName().."Text"):SetText(text);
end

function Dcr_PriorityListEntryTemplate_OnClick()
    local id = this:GetID();

    if (id) then
		if (this.Priority) then
			Dcr_RemoveIDFromPriorityList(id);
		else
			Dcr_RemoveIDFromSkipList(id);
		end
    end

    this.UpdateYourself = true;
end

function Dcr_PriorityListEntryTemplate_OnUpdate()
    if (this.UpdateYourself) then

		this.UpdateYourself = false;
		local baseName = this:GetName();
		local NameText = getglobal(baseName.."Name");

		local id = this:GetID();
		if (id) then
			local name

			if (this.Priority) then
				name = Dcr_Saved.PriorityList[id];
			else
				name = Dcr_Saved.SkipList[id];
			end

			if (name) then
				NameText:SetText(id.." - "..name);
			else
				NameText:SetText("Error - ID Invalid!");
			end
		else
			NameText:SetText("Error - No ID!");
		end
    end
end 

function Dcr_PriorityListFrame_OnUpdate()
    if (this.UpdateYourself) then

		this.UpdateYourself = false;
		Dcr_Groups_datas_are_invalid = true;
		local baseName = this:GetName();
		local up = getglobal(baseName.."Up");
		local down = getglobal(baseName.."Down");
		local size = table.getn(Dcr_Saved.PriorityList);

		if (size < 11 ) then
			this.Offset = 0;
			up:Hide();
			down:Hide();
		else
			if (this.Offset <= 0) then
				this.Offset = 0;
				up:Hide();
				down:Show();
			elseif (this.Offset >= (size - 10)) then
				this.Offset = (size - 10);
				up:Show();
				down:Hide();
			else
				up:Show();
				down:Show();
			end
		end

		local i;
		for i = 1, 10 do
			local id = ""..i;

			if (i < 10) then
				id = "0"..i;
			end

			local btn = getglobal(baseName.."Index"..id);
			btn:SetID( i + this.Offset);
			btn.UpdateYourself = true;

			if (i <= size) then
				btn:Show();
			else
				btn:Hide();
			end
		end
    end
end

function Dcr_SkipListFrame_OnUpdate()
    if (this.UpdateYourself) then

		this.UpdateYourself = false;
		Dcr_Groups_datas_are_invalid = true;
		local baseName = this:GetName();
		local up = getglobal(baseName.."Up");
		local down = getglobal(baseName.."Down");
		local size = table.getn(Dcr_Saved.SkipList);

		if (size < 11 ) then
			this.Offset = 0;
			up:Hide();
			down:Hide();
		else
			if (this.Offset <= 0) then
				this.Offset = 0;
				up:Hide();
				down:Show();
			elseif (this.Offset >= (size - 10)) then
				this.Offset = (size - 10);
				up:Show();
				down:Hide();
			else
				up:Show();
				down:Show();
			end
		end

		local i;
		for i = 1, 10 do
			local id = ""..i;

			if (i < 10) then
				id = "0"..i;
			end

			local btn = getglobal(baseName.."Index"..id);
			btn:SetID( i + this.Offset);
			btn.UpdateYourself = true;

			if (i <= size) then
				btn:Show();
			else
				btn:Hide();
			end
		end
    end
end

function Dcr_PopulateButtonPress() --{{{
    local addFunction = this:GetParent().addFunction;

    if (this.ClassType) then

		local _, pclass = UnitClass("player");
		if (pclass == this.ClassType) then
			addFunction("player");
		end

		_, pclass = UnitClass("party1");
		if (pclass == this.ClassType) then
			addFunction("party1");
		end

		_, pclass = UnitClass("party2");
		if (pclass == this.ClassType) then
			addFunction("party2");
		end

		_, pclass = UnitClass("party3");
		if (pclass == this.ClassType) then
			addFunction("party3");
		end

		_, pclass = UnitClass("party4");
		if (pclass == this.ClassType) then
			addFunction("party4");
		end
    end

    local max = GetNumRaidMembers();
    local i;

    if (max > 0) then
		for i = 1, max do
			local _, _, pgroup, _, _, pclass = GetRaidRosterInfo(i);

			if (this.ClassType) then
				if (pclass == this.ClassType) then
					addFunction("raid"..i);
				end
			end

			if (this.GroupNumber) then
				if (pgroup == this.GroupNumber) then
					addFunction("raid"..i);
				end
			end
		end
    end
end

function Dcr_AfflictedListFrame_OnUpdate(elapsed)

    if Drc_Options.Slider.Display_Amount_Of_Afflicted < 1 then
		Drc_Options.Slider.Display_Amount_Of_Afflicted = 1;
    elseif Drc_Options.Slider.Display_Amount_Of_Afflicted > DCR_MAX_LIVE_SLOTS then
		Drc_Options.Slider.Display_Amount_Of_Afflicted = DCR_MAX_LIVE_SLOTS;
    end

    Dcr_timeLeft = Dcr_timeLeft - elapsed;

    if (Dcr_timeLeft <= 0) then

		Dcr_timeLeft = Drc_Options.Slider.Seconds_Between_Scans;
		local Dcr_Unit_Array = Dcr_Unit_Array;
		local index = 1;
		local targetexists = false;
		Dcr_GetUnitArray();

		if (UnitExists("target") and UnitIsFriend("player", "target")) then
			if (UnitIsVisible("target")) then
				targetexists = true;
				if (Dcr_ScanUnit("target", index)) then
					index = index + 1;
				end
			end
		end

		if (DCR_CAN_CURE_ENEMY_MAGIC) then
			for _, unit in Dcr_Unit_Array do
				if (index > Drc_Options.Slider.Display_Amount_Of_Afflicted) then
					break;
				end

				if (UnitIsVisible(unit) and not (targetexists and UnitIsUnit(unit, "target"))) then
					if (UnitIsCharmed(unit)) then
						if (Dcr_ScanUnit(unit, index)) then
							index = index + 1;
						end
					end
				end
			end
		end

		for _, unit in Dcr_Unit_Array do
			if (index > Drc_Options.Slider.Display_Amount_Of_Afflicted) then
				break;
			end

			if (UnitIsVisible(unit) and not (targetexists and UnitIsUnit(unit, "target"))) then
				if (not UnitIsCharmed(unit)) then
					if (Dcr_ScanUnit(unit, index)) then
						index = index + 1;
					end
				end
			end
		end

		local i;
		for i = index, DCR_MAX_LIVE_SLOTS do
			local Index = i;

			local item = getglobal("DecursiveAfflictedListFrameListItem"..Index);
			item.unit = "player";
			item.debuff = 0;
			item:Hide();
		end
    end
end

function Dcr_ScanUnit(Unit, Index)

    local AllUnitDebuffs = {};
    AllUnitDebuffs = Dcr_GetUnitDebuffAll(Unit);

    for debuff_name, debuff_params in AllUnitDebuffs do
	
		if (DCR_IGNORELIST[debuff_name]) then
			return false;
		end

		if (DCR_SKIP_LIST[debuff_name]) then
			break;
		end

		if (UnitAffectingCombat("player")) then
			if (DCR_SKIP_BY_CLASS_LIST[UClass]) then
				if (DCR_SKIP_BY_CLASS_LIST[UClass][debuff_name]) then
					break;
				end
			end
		end

		if (debuff_params.debuff_type and debuff_params.debuff_type ~= "") then

			if (debuff_params.debuff_type == DCR_MAGIC and Drc_Options.ActiveDecurse.CureMagic) then

				if (UnitIsCharmed(Unit)) then
					if (DCR_CAN_CURE_ENEMY_MAGIC) then
						Dcr_UpdateLiveDisplay(Index, Unit, debuff_params);
					return true;
					end
				else
					if (DCR_CAN_CURE_MAGIC) then
						Dcr_UpdateLiveDisplay(Index, Unit, debuff_params);
					return true;
					end
				end

			elseif (debuff_params.debuff_type == DCR_DISEASE and Drc_Options.ActiveDecurse.CureDisease) then

				if (DCR_CAN_CURE_DISEASE) then
					Dcr_UpdateLiveDisplay(Index, Unit, debuff_params);
					return true;
				end

			elseif (debuff_params.debuff_type == DCR_POISON and Drc_Options.ActiveDecurse.CurePoison) then

				if (DCR_CAN_CURE_POISON) then
					Dcr_UpdateLiveDisplay(Index, Unit, debuff_params);
					return true;
				end

			elseif (debuff_params.debuff_type == DCR_CURSE and Drc_Options.ActiveDecurse.CureCurse) then

				if (DCR_CAN_CURE_CURSE) then
					Dcr_UpdateLiveDisplay(Index, Unit, debuff_params);
					return true;
				end
			end
		end
    end
    return false;
end

function Dcr_UpdateLiveDisplay(Index, Unit, debuff_params)

    local baseFrame = "DecursiveAfflictedListFrameListItem";

    local item = getglobal(baseFrame..Index);
    if (item.debuff == debuff_params.index and item.debuff_name == debuff_params.debuff_name and item.unit == Unit and item.DebuffApps == debuff_params.debuffApplications) then
		return
    end

    item.unit = Unit;
    item.debuff_name = debuff_params.debuff_name;
    item.debuff = debuff_params.index;
    item.DebuffApps = debuff_params.debuffApplications;

    getglobal(baseFrame..Index.."DebuffIcon"):SetTexture(debuff_params.DebuffTexture);
	getglobal(baseFrame..Index.."DebuffIcon"):SetTexCoord(0, 1, 0, 1);

    if (debuff_params.debuffApplications > 0) then
		getglobal(baseFrame..Index.."DebuffCount"):SetText(debuff_params.debuffApplications);
    else
		getglobal(baseFrame..Index.."DebuffCount"):SetText("");
    end

    getglobal(baseFrame..Index.."Name"):SetText(MakePlayerName(UnitName(Unit)));

    getglobal(baseFrame..Index.."Type"):SetText(MakeAfflictionName(debuff_params.debuff_type));

    getglobal(baseFrame..Index.."Affliction"):SetText(debuff_params.debuff_name);

    item:Show();

    item = getglobal(baseFrame..Index.."Debuff");
    item.unit = Unit;
    item.debuff = debuff_params.index;

    item = getglobal(baseFrame..Index.."ClickMe");
    item.unit = Unit;
    item.debuff = debuff_params.index;
end

function Dcr_AddTargetToPriorityList()
    DcrAddUnitToPriorityList("target");
end

function DcrAddUnitToPriorityList( unit)
    if (UnitExists(unit)) then
		if (UnitIsPlayer(unit)) then
			local name = (UnitName( unit));
			for _, pname in Dcr_Saved.PriorityList do
				if (name == pname) then
					return;
				end
			end
			table.insert(Dcr_Saved.PriorityList,name);
		end

		DecursivePriorityListFrame.UpdateYourself = true;
    end
end

function Dcr_RemoveIDFromPriorityList(id)
    table.remove( Dcr_Saved.PriorityList,id);
    DecursivePriorityListFrame.UpdateYourself = true;
end

function Dcr_ClearPriorityList()
    Dcr_Saved.PriorityList = {};
    DecursivePriorityListFrame.UpdateYourself = true;
end

function Dcr_AddTargetToSkipList()
    DcrAddUnitToSkipList("target");
end

function DcrAddUnitToSkipList(unit)
    if (UnitExists(unit)) then
		if (UnitIsPlayer(unit)) then

			local name = (UnitName( unit));
			for _, pname in Dcr_Saved.SkipList do
				if (name == pname) then
					return;
				end
			end

			table.insert(Dcr_Saved.SkipList,name);
			DecursiveSkipListFrame.UpdateYourself = true;
		end
    end
end

function Dcr_RemoveIDFromSkipList(id)
    table.remove( Dcr_Saved.SkipList,id);
    DecursiveSkipListFrame.UpdateYourself = true;
end

function Dcr_ClearSkipList()
    Dcr_Saved.SkipList = { };
    DecursiveSkipListFrame.UpdateYourself = true;
end

function Dcr_IsInPriorList(name)
    for _, PriorName in Dcr_Saved.PriorityList do
		if (PriorName == name) then
			return true;
		end
    end
    return false;
end

function Dcr_IsInSkipList(name)
    for _, SkipName in Dcr_Saved.SkipList do
		if (SkipName == name) then
			return true;
		end
    end
    return false
end

function Dcr_IsInSkipOrPriorList(name)
    if (InternalSkipList[name]) then
		return true;
    end

    if (InternalPrioList[name]) then
		return true;
    end
    return false;
end

-------------------------------------------------------------------------------
-- Init functions and configuration functions {{{
-------------------------------------------------------------------------------

StaticPopupDialogs["DCR_DISABLE_AUTOSELFCAST"] = {
	text = DCR_DISABLE_AUTOSELFCAST,
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		SetCVar("autoSelfCast", "0");
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	ShowAlert = 1,
};

function Dcr_DisableAddon()
    if GetAddOnInfo(DCR_ADDON_NAME) then
        DisableAddOn(DCR_ADDON_NAME)
        Dcr_ErrorMessage(DCR_ADDON_NAME..": Addon Has Been Disabled! Be Sure To ReloadUI.")
    end
end

local MBD_Post_Init = CreateFrame("Button", "MBD", UIParent)

MBD_Post_Init.Timer = GetTime()

function MBD_Post_Init:OnUpdate()
	if GetTime() - MBD_Post_Init.Timer < 2.7 then return end

	--------------------------------------------------------

	Dcr_PrintMessage("Has been succesfully loaded.")

	if (UnitClass("player") == "Rogue" or UnitClass("player") == "Warrior" or UnitClass("player") == "Hunter" or UnitClass("player") == "Warlock" or MB_mySpecc == "Feral") then
        Dcr_DisableAddon()
    end

	--------------------------------------------------------

	MBD_Post_Init:SetScript("OnUpdate", nil)
	MBD_Post_Init.Timer = nil
	MBD_Post_Init.OnUpdate = nil
end

function Dcr_Init()

	MBD_Post_Init:SetScript("OnUpdate", MBD_Post_Init.OnUpdate) -- >  Starts a second INIT after logging in

    if (Drc_Settings.Dcr_OutputWindow == nil or not Drc_Settings.Dcr_OutputWindow) then
		Drc_Settings.Dcr_OutputWindow = DEFAULT_CHAT_FRAME;
    end

    SLASH_DECURSIVE1 = DCR_MACRO_COMMAND;
    SlashCmdList["DECURSIVE"] = function(msg)
		Dcr_Clean();
    end

    SLASH_DECURSIVESHOW1 = DCR_MACRO_SHOW;
    SlashCmdList["DECURSIVESHOW"] = function(msg)
		Dcr_Hide(0);
    end

	DecursiveAfflictedListFrame:ClearAllPoints();
	DecursiveAfflictedListFrame:SetPoint("TOPLEFT", "DecursiveMainBar", "BOTTOMLEFT");
	DecursiveAfflictedListFrame:Show();
    
    if (Drc_Settings.Hidden) then
		DecursiveMainBar:Hide();
    else
		DecursiveMainBar:ClearAllPoints();
		DecursiveMainBar:SetPoint("CENTER", UIParent, "TOP", 0, -100)
		DecursiveMainBar:Show();
    end

    if (Drc_Options.CheckBox.Always_Use_Best_Spell == nil) then
		Drc_Options.CheckBox.Always_Use_Best_Spell = true;
    end

    if (Drc_Settings.HideButtons == nil) then
		Drc_Settings.HideButtons = false;
    end

    if (Drc_Options.ActiveDecurse.CureMagic == nil) then
		Drc_Options.ActiveDecurse.CureMagic = true;
    end

    if (Drc_Options.ActiveDecurse.CurePoison == nil) then
		Drc_Options.ActiveDecurse.CurePoison = true;
    end

    if (Drc_Options.ActiveDecurse.CureDisease == nil) then
		Drc_Options.ActiveDecurse.CureDisease = true;
    end

    if (Drc_Options.ActiveDecurse.CureCurse == nil) then
		Drc_Options.ActiveDecurse.CureCurse = true;
    end

    if (Dcr_Saved.CureOrderList == nil) then
		Dcr_Saved.CureOrderList = {
			[1] = DCR_MAGIC,
			[2] = DCR_CURSE,
			[3] = DCR_POISON,
			[4] = DCR_DISEASE
		}
    end

    Dcr_ShowHideButtons(true);

    Dcr_ChangeTextFrameDirection(Drc_Options.CheckBox.CustomeFrameInsertBottom);

    if (Drc_Options.CheckBox.Active_Debug_Messages) then
		DcrOptionsFrameAnchor:Enable();
    else
		DcrOptionsFrameAnchor:Disable();
    end

    Dcr_Configure();

    DecursiveTextFrame:SetFading(true);
    DecursiveTextFrame:SetFadeDuration(DCR_TEXT_LIFETIME / 3);
    DecursiveTextFrame:SetTimeVisible(DCR_TEXT_LIFETIME);
end

function Dcr_ReConfigure()

    if not DCR_HAS_SPELLS then
		return;
    end

    local DoNotReconfigure = true;

    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_MAGIC_1[1], DCR_SPELL_MAGIC_1[2], DCR_SPELL_MAGIC_1[3]);
    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_MAGIC_2[1], DCR_SPELL_MAGIC_2[2], DCR_SPELL_MAGIC_2[3]);

    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_ENEMY_MAGIC_1[1], DCR_SPELL_ENEMY_MAGIC_1[2], DCR_SPELL_ENEMY_MAGIC_1[3]);
    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_ENEMY_MAGIC_2[1], DCR_SPELL_ENEMY_MAGIC_2[2], DCR_SPELL_ENEMY_MAGIC_2[3]);

    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_DISEASE_1[1], DCR_SPELL_DISEASE_1[2], DCR_SPELL_DISEASE_1[3]);
    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_DISEASE_2[1], DCR_SPELL_DISEASE_2[2], DCR_SPELL_DISEASE_2[3]);

    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_POISON_1[1], DCR_SPELL_POISON_1[2], DCR_SPELL_POISON_1[3]);
    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_POISON_2[1], DCR_SPELL_POISON_2[2], DCR_SPELL_POISON_2[3]);

    DoNotReconfigure = Dcr_CheckSpellName(DCR_SPELL_CURSE[1], DCR_SPELL_CURSE[2], DCR_SPELL_CURSE[3]);

    if DoNotReconfigure == false then
		Dcr_Configure();
		return;
    end
end

function Dcr_Configure()

    DCR_HAS_SPELLS = false;
    DCR_SPELL_MAGIC_1 = {0,"", ""};
    DCR_SPELL_MAGIC_2 = {0,"", ""};
    DCR_CAN_CURE_MAGIC = false;
    DCR_SPELL_ENEMY_MAGIC_1 = {0,"", ""};
    DCR_SPELL_ENEMY_MAGIC_2 = {0,"", ""};
    DCR_CAN_CURE_ENEMY_MAGIC = false;
    DCR_SPELL_DISEASE_1 = {0,"", ""};
    DCR_SPELL_DISEASE_2 = {0,"", ""};
    DCR_CAN_CURE_DISEASE = false;
    DCR_SPELL_POISON_1 = {0,"", ""};
    DCR_SPELL_POISON_2 = {0,"", ""};
    DCR_CAN_CURE_POISON = false;
    DCR_SPELL_CURSE = {0,"", ""};
    DCR_CAN_CURE_CURSE = false;

    local Dcr_Name_Array = {
	[DCR_SPELL_CURE_DISEASE] = true,
	[DCR_SPELL_ABOLISH_DISEASE] = true,
	[DCR_SPELL_PURIFY] = true,
	[DCR_SPELL_CLEANSE] = true,
	[DCR_SPELL_DISPELL_MAGIC] = true,
	[DCR_SPELL_CURE_POISON] = true,
	[DCR_SPELL_ABOLISH_POISON] = true,
	[DCR_SPELL_REMOVE_LESSER_CURSE] = true,
	[DCR_SPELL_REMOVE_CURSE] = true,
	[DCR_SPELL_PURGE] = true,
	[DCR_PET_FEL_CAST] = true,
	[DCR_PET_DOOM_CAST] = true,
    }

    local i = 1;

    local BookType = BOOKTYPE_SPELL;
    local break_flag = false
    while not break_flag  do
		while (true) do -- I wish there was a continue statement in LUA...
			local spellName, spellRank = GetSpellName(i, BookType);
				if (not spellName) then
					if (BookType == BOOKTYPE_PET) then
						break_flag = true;
						break;
					end
					BookType = BOOKTYPE_PET;
					i = 1;
				break;
			end

			if (Dcr_Name_Array[spellName]) then

				DCR_HAS_SPELLS = true;
				DCR_SPELL_COOLDOWN_CHECK[1] = i; DCR_SPELL_COOLDOWN_CHECK[2] = BookType;

				if ((spellName == DCR_SPELL_CURE_DISEASE) or (spellName == DCR_SPELL_ABOLISH_DISEASE) or
					(spellName == DCR_SPELL_PURIFY) or (spellName == DCR_SPELL_CLEANSE)) then
					
						DCR_CAN_CURE_DISEASE = true;
						if ((spellName == DCR_SPELL_CURE_DISEASE) or (spellName == DCR_SPELL_PURIFY)) then
						
						DCR_SPELL_DISEASE_1[1] = i; DCR_SPELL_DISEASE_1[2] = BookType; DCR_SPELL_DISEASE_1[3] = spellName;
						else
						
						DCR_SPELL_DISEASE_2[1] = i; DCR_SPELL_DISEASE_2[2] = BookType; DCR_SPELL_DISEASE_2[3] = spellName;
						end
				end

				if ((spellName == DCR_SPELL_CURE_POISON) or (spellName == DCR_SPELL_ABOLISH_POISON) or
					(spellName == DCR_SPELL_PURIFY) or (spellName == DCR_SPELL_CLEANSE)) then

						DCR_CAN_CURE_POISON = true;
						if ((spellName == DCR_SPELL_CURE_POISON) or (spellName == DCR_SPELL_PURIFY)) then

						DCR_SPELL_POISON_1[1] = i; DCR_SPELL_POISON_1[2] = BookType; DCR_SPELL_POISON_1[3] = spellName;
						else
						
						DCR_SPELL_POISON_2[1] = i; DCR_SPELL_POISON_2[2] = BookType; DCR_SPELL_POISON_2[3] = spellName;
						end
				end

				if ((spellName == DCR_SPELL_REMOVE_CURSE) or (spellName == DCR_SPELL_REMOVE_LESSER_CURSE)) then
					
					DCR_CAN_CURE_CURSE = true;
					DCR_SPELL_CURSE[1] = i; DCR_SPELL_CURSE[2] =  BookType; DCR_SPELL_CURSE[3] = spellName;
				end

				if ((spellName == DCR_SPELL_DISPELL_MAGIC) or (spellName == DCR_SPELL_CLEANSE) or (spellName == DCR_PET_FEL_CAST) or (spellName == DCR_PET_DOOM_CAST)) then
					
					DCR_CAN_CURE_MAGIC = true;
					if (spellName == DCR_SPELL_CLEANSE) then
					
						DCR_SPELL_MAGIC_1[1] = i; DCR_SPELL_MAGIC_1[2] = BookType; DCR_SPELL_MAGIC_1[3] = spellName;
					
					else			
						if (spellRank == DCR_SPELL_RANK_1) then
							
							DCR_SPELL_MAGIC_1[1] = i; DCR_SPELL_MAGIC_1[2] = BookType; DCR_SPELL_MAGIC_1[3] = spellName;
						else
						
							DCR_SPELL_MAGIC_2[1] = i; DCR_SPELL_MAGIC_2[2] = BookType; DCR_SPELL_MAGIC_2[3] = spellName;
						end
					end
				end

				if ((spellName == DCR_SPELL_DISPELL_MAGIC) or (spellName == DCR_SPELL_PURGE) or (spellName == DCR_PET_FEL_CAST) or (spellName == DCR_PET_DOOM_CAST)) then
					
					DCR_CAN_CURE_ENEMY_MAGIC = true;
					if (spellRank == DCR_SPELL_RANK_1) then

						DCR_SPELL_ENEMY_MAGIC_1[1] = i; DCR_SPELL_ENEMY_MAGIC_1[2] = BookType; DCR_SPELL_ENEMY_MAGIC_1[3] = spellName;
					else

						DCR_SPELL_ENEMY_MAGIC_2[1] = i; DCR_SPELL_ENEMY_MAGIC_2[2] = BookType; DCR_SPELL_ENEMY_MAGIC_2[3] = spellName;
					end
				end
			end

			i = i + 1
		end
    end

    VerifyOrderList();
    Dcr_SetCureOrderList ();
end

function Dcr_CheckSpellName(id, booktype, spellname)

    if id ~= 0  then

		local found_spellname, spellrank = GetSpellName(id, booktype);

		if spellname ~= found_spellname then
			return false;
		end
    end
    return true;
end

function Dcr_OnLoad(Frame)
   Frame:RegisterEvent("PLAYER_LOGIN");
end

function Dcr_OnEvent(event)
    local Frame = this;

    if (event == "UNIT_PET" ) then
		if (UnitInRaid(arg1) or UnitInParty(arg1)) then
			Dcr_Groups_datas_are_invalid = true;
		end
		
		if ( arg1 == "player" and not Dcr_CheckingPET) then
			Dcr_CheckingPET = true;
		end
		return;

	elseif (event == "PLAYER_ENTER_COMBAT") then

		Dcr_EnterCombat();
		return;

	elseif (event == "PLAYER_LEAVE_COMBAT") then

		Dcr_LeaveCombat();
		return;

	elseif (event == "UI_ERROR_MESSAGE") then

		if (arg1 == SPELL_FAILED_LINE_OF_SIGHT or arg1 == SPELL_FAILED_BAD_TARGETS) then
			Dcr_SpellCastFailed();
		end
		return;

	elseif (event == "SPELLCAST_STOP") then

		Dcr_SpellWasCast();
		return;

    elseif (not Dcr_DelayedReconf and event == "SPELLS_CHANGED" and arg1==nil) then

		Dcr_DelayedReconf = true;
		return;

    elseif (event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED") then
		Dcr_Groups_datas_are_invalid = true; 
		return;

    elseif (event == "LEARNED_SPELL_IN_TAB") then

		Dcr_Configure();
		return;
    end

    if (event == "PLAYER_LOGIN") then
		Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
		Frame:RegisterEvent("PLAYER_LEAVING_WORLD");
		Dcr_Init();
		return;
    end

    if (event == "PLAYER_ENTERING_WORLD") then

		Dcr_Groups_datas_are_invalid = true;
		Frame:RegisterEvent("PLAYER_ENTER_COMBAT");
		Frame:RegisterEvent("PLAYER_LEAVE_COMBAT");
		Frame:RegisterEvent("SPELLCAST_STOP");
		Frame:RegisterEvent("UNIT_PET");
		Frame:RegisterEvent("SPELLS_CHANGED");
		Frame:RegisterEvent("LEARNED_SPELL_IN_TAB");
		Frame:RegisterEvent("UI_ERROR_MESSAGE");
		Frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
		Frame:RegisterEvent("PARTY_LEADER_CHANGED");

    elseif (event == "PLAYER_LEAVING_WORLD") then

		Frame:UnregisterEvent("PLAYER_ENTER_COMBAT");
		Frame:UnregisterEvent("PLAYER_LEAVE_COMBAT");
		Frame:UnregisterEvent("SPELLCAST_STOP");
		Frame:UnregisterEvent("UNIT_PET");
		Frame:UnregisterEvent("SPELLS_CHANGED");
		Frame:UnregisterEvent("LEARNED_SPELL_IN_TAB");
		Frame:UnregisterEvent("UI_ERROR_MESSAGE");
		Frame:UnregisterEvent("PARTY_MEMBERS_CHANGED");
		Frame:UnregisterEvent("PARTY_LEADER_CHANGED");
    end

end

function Dcr_OnUpdate(arg1)

    if Dcr_DelayedReconf then
		Dcr_DelayedReconf_timer = Dcr_DelayedReconf_timer + arg1;

		if (Dcr_DelayedReconf_timer >= Dcr_DelayedReconf_delay) then
			Dcr_DelayedReconf_timer = 0;

			Dcr_ReConfigure();
			Dcr_DelayedReconf = false;
			return;
		end
    end

    if (Dcr_CheckingPET) then
		Dcr_CheckPet_Timer = Dcr_CheckPet_Timer + arg1;

		if (Dcr_CheckPet_Timer >= Dcr_CheckPet_Delay) then
			
			Dcr_CheckPet_Timer = 0;
			curr_DemonType = UnitCreatureFamily("pet");

			if (last_DemonType ~= curr_DemonType) then
				last_DemonType = curr_DemonType;
				Dcr_Configure();
			end

			Dcr_CheckingPET = false;
			return;
		end
    end

    for unit in Dcr_Blacklist_Array do
		Dcr_Blacklist_Array[unit] = Dcr_Blacklist_Array[unit] - arg1;

		if (Dcr_Blacklist_Array[unit] < 0) then
			Dcr_Blacklist_Array[unit] = nil;
		end
    end

    if (Dcr_Delay_Timer > 0) then
		Dcr_Delay_Timer = Dcr_Delay_Timer - arg1;
		if (Dcr_Delay_Timer <= 0) then
			if (not Dcr_CombatMode) then
				AttackTarget();
			end
		end;
    end

    if (Dcr_Debuff_Texture_to_name_cache_life ~= 0) then
		Dcr_Debuff_Texture_to_name_cache_life = Dcr_Debuff_Texture_to_name_cache_life - arg1;

		if (Dcr_Debuff_Texture_to_name_cache_life < 0) then
			Dcr_Debuff_Texture_to_name_cache_life = 0;
			Dcr_Debuff_Texture_to_name_cache = {};
		end
    end

    if (Dcr_Buff_Texture_to_name_cache_life ~= 0) then
		Dcr_Buff_Texture_to_name_cache_life = Dcr_Buff_Texture_to_name_cache_life - arg1;

		if (Dcr_Buff_Texture_to_name_cache_life < 0) then
			Dcr_Buff_Texture_to_name_cache_life = 0;
			Dcr_Buff_Texture_to_name_cache = {};
		end
    end

    if (RestorSelfAutoCast) then
		RestorSelfAutoCastTimeOut = RestorSelfAutoCastTimeOut - arg1;
		if (RestorSelfAutoCastTimeOut < 0) then
			RestorSelfAutoCast = false;
			SetCVar("autoSelfCast", "1");
		end
    end

end

function Dcr_EnterCombat()
    Dcr_CombatMode = true;
end

function Dcr_LeaveCombat() 
    Dcr_CombatMode = false;
end

function Dcr_SpellCastFailed()
    if (Dcr_Casting_Spell_On and not (UnitIsUnit(Dcr_Casting_Spell_On, "player") or (Drc_Options.CheckBox.Do_Not_Blacklist_Prio_List and Dcr_IsInPriorList ( (UnitName(Dcr_Casting_Spell_On)))))) then

		Dcr_Blacklist_Array[Dcr_Casting_Spell_On] = nil;
		Dcr_Blacklist_Array[Dcr_Casting_Spell_On] = Drc_Options.Slider.Seconds_On_The_Blacklist;
		DCR_ThisCleanBlaclisted[Dcr_Casting_Spell_On] = true;
    end
end

function Dcr_SpellWasCast()
    Dcr_Casting_Spell_On = nil;
end 

function Dcr_GetUnitArray()

    if (not Dcr_Groups_datas_are_invalid) then
		return;
    end

    local pname;
    local raidnum = GetNumRaidMembers();
    local MyName = (UnitName( "player"));

    local SortIndex = 1;

    InternalPrioList = { };
    InternalSkipList = { };
    Dcr_Unit_Array   = { };
    SortingTable     = { };

    for _, pname in Dcr_Saved.PriorityList do

		local unit = Dcr_NameToUnit( pname );

		if (unit) then
			InternalPrioList[pname] = unit;
			Dcr_Unit_Array[pname] = unit;
			Dcr_AddToSort(unit, SortIndex); SortIndex = SortIndex + 1;
		end
    end

    for _, pname in Dcr_Saved.SkipList do
		local unit = Dcr_NameToUnit( pname );
		if (unit) then
			InternalSkipList[pname] = unit;
		end
    end

    if (not Dcr_IsInSkipOrPriorList(MyName)) then
		Dcr_Unit_Array[MyName] = "player";
		Dcr_AddToSort( "player", SortIndex); SortIndex = SortIndex + 1;
    end

    for i = 1, 4 do
		if (UnitExists("party"..i)) then
			pname = (UnitName("party"..i));

			if (not pname) then
				pname = "party"..i;
			end
		
			if (not Dcr_IsInSkipOrPriorList(pname)) then
				Dcr_Unit_Array[pname] = "party"..i;
				Dcr_AddToSort("party"..i, SortIndex); SortIndex = SortIndex + 1;
			end
		end
    end

    if ( raidnum > 0 ) then
		local temp_raid_table = {};
		local currentGroup = 0;

		for i = 1, raidnum do
			local rName, _, rGroup = GetRaidRosterInfo(i);

			if ( currentGroup==0 and rName == MyName) then
				currentGroup = rGroup;
			end

	    	if (currentGroup ~= rGroup and not Dcr_IsInSkipOrPriorList(rName)) then

				temp_raid_table[i] = {};
				
				if (not rName) then
					rName = rGroup.."unknown"..i;
				end

				temp_raid_table[i].rName    = rName;
				temp_raid_table[i].rGroup   = rGroup;
				temp_raid_table[i].rIndex   = i;
	    	end
		end

		for _, raidMember in temp_raid_table do

			if (raidMember.rGroup > currentGroup) then
				Dcr_Unit_Array[raidMember.rName] = "raid"..raidMember.rIndex;
				Dcr_AddToSort("raid"..raidMember.rIndex, raidMember.rGroup * 100 + SortIndex); SortIndex =  SortIndex + 1;
			end

			if (raidMember.rGroup < currentGroup) then
				Dcr_Unit_Array[raidMember.rName] = "raid"..raidMember.rIndex;
				Dcr_AddToSort("raid"..raidMember.rIndex, raidMember.rGroup * 100 + 1000 + SortIndex); SortIndex = SortIndex + 1;
			end
		end

		SortIndex = SortIndex + 8 * 100 + 1000 + 1;
    end

    if ( Drc_Options.CheckBox.Scan_Pets) then

	if (UnitExists("pet")) then
	    Dcr_Unit_Array[(UnitName("pet"))] = "pet";
	    Dcr_AddToSort("pet", SortIndex); SortIndex = SortIndex + 1;
	end

	for i = 1, 4 do
	    if (UnitExists("partypet"..i)) then

		pname = (UnitName("partypet"..i));
		if (not pname) then
		    pname = "partypet"..i;
		end

		Dcr_Unit_Array[pname] = "partypet"..i;
		Dcr_AddToSort("partypet"..i, SortIndex); SortIndex = SortIndex + 1;
	    end
	end

	if (raidnum > 0) then
	    for i = 1, raidnum do
			if (UnitExists("raidpet"..i)) then

				pname = (UnitName("raidpet"..i));
				
				if (not pname) then
					pname = "raidpet"..i;
				end
			
				if (not Dcr_Unit_Array[pname]) then
					Dcr_Unit_Array[pname] = "raidpet"..i;
					Dcr_AddToSort("raidpet"..i, SortIndex); SortIndex = SortIndex + 1;
				end
			end
	    end
	end
    end

    local Lua_Table_Library_Is_Really_A_Piece_Of_Shit = {};
    for _, value in Dcr_Unit_Array do
		table.insert(Lua_Table_Library_Is_Really_A_Piece_Of_Shit, value);
    end

    Dcr_Unit_ArrayByName = Dcr_Unit_Array;
    Dcr_Unit_Array = Lua_Table_Library_Is_Really_A_Piece_Of_Shit;

    table.sort(Dcr_Unit_Array, function (a,b) return SortingTable[a] < SortingTable[b] end);

    target_added = false;
    Dcr_Groups_datas_are_invalid = false;
    return;
end

function Dcr_AddToSort(unit, index)
    if (Drc_Options.CheckBox.Random_Order and (not InternalPrioList[(UnitName(unit))]) and not UnitIsUnit(unit,"player")) then
		index = random (1, 3000);
    end
    SortingTable[unit] = index;
end

function Dcr_NameToUnit(Name) --{{{
    if (not Name) then
	return false;
    elseif (Name == (UnitName("player"))) then
	return "player";
    elseif (Name == (UnitName("pet"))) then
	return "pet";
    elseif (Name == (UnitName("party1"))) then
	return "party1";
    elseif (Name == (UnitName("party2"))) then
	return "party2";
    elseif (Name == (UnitName("party3"))) then
	return "party3";
    elseif (Name == (UnitName("party4"))) then
	return "party4";
    elseif (Name == (UnitName("partypet1"))) then
	return "partypet1";
    elseif (Name == (UnitName("partypet2"))) then
	return "partypet2";
    elseif (Name == (UnitName("partypet3"))) then
	return "partypet3";
    elseif (Name == (UnitName("partypet4"))) then
	return "partypet4";
    else
	local numRaidMembers = GetNumRaidMembers();
		if (numRaidMembers > 0) then
			-- we are in a raid
			local i;
			for i=1, numRaidMembers do
			local RaidName = GetRaidRosterInfo(i);
			if ( Name == RaidName) then
				return "raid"..i;
			end
			if ( Name == (UnitName("raidpet"..i))) then
				return "raidpet"..i;
			end
			end
		end
    end
    return false;
end

function Dcr_Clean(UseThisTarget, SwitchToTarget)
  
    RestorSelfAutoCastTimeOut = 1;

    if (GetCVar("autoSelfCast") == "1") then
		RestorSelfAutoCast = true;
		SetCVar("autoSelfCast", "0");
    end

    if (not DCR_HAS_SPELLS) then
	
		Dcr_Configure();

		if (not DCR_HAS_SPELLS) then
			return false;
		end
    end

    Dcr_RestoreTarget = true;

    if (UseThisTarget and SwitchToTarget) then
		TargetUnit(UseThisTarget);
		Dcr_RestoreTarget = false;
    end

    if (Dcr_AlreadyCleanning) then
		return false;
    end

    Dcr_AlreadyCleanning = true;

    SpellStopTargeting();
    
    if ( DCR_SPELL_COOLDOWN_CHECK[2] ~= "pet") then SpellStopCasting(); end

    local _, cooldown = GetSpellCooldown(DCR_SPELL_COOLDOWN_CHECK[1], DCR_SPELL_COOLDOWN_CHECK[2]);

    if (cooldown ~= 0) then
		Dcr_AlreadyCleanning = false;
		return false;
    end

    DCR_ThisCleanBlaclisted = { };
  
    DCR_ThisNumberOoRUnits  = 0;

    local targetEnemy = false;
    local targetName = nil;
    local cleaned = false;
    local resetCombatMode = false;
    Dcr_Casting_Spell_On = nil;

    if (UnitExists("target")) then
	
		if (Dcr_CombatMode) then
			resetCombatMode = true;
		end

		if ((UnitIsFriend("target", "player") ) and (not UnitIsCharmed("target"))) then

			if (not UseThisTarget or SwitchToTarget) then 
				cleaned = Dcr_CureUnit("target");
			end

			targetName = (UnitName("target"));

		else
			targetEnemy = true;

			if ( UnitIsCharmed("target")) then
			
				if (not UseThisTarget or SwitchToTarget) then 
					cleaned = Dcr_CureUnit("target");
				end
			end
		end
    end

    if (UseThisTarget and not SwitchToTarget and not cleaned) then
		if (UnitIsVisible(UseThisTarget)) then

			if (DCR_CAN_CURE_ENEMY_MAGIC and UnitIsCharmed(UseThisTarget)) then
				if (Dcr_CureUnit(UseThisTarget)) then
					cleaned = true;
				end

			else
				if (not Dcr_CheckUnitStealth(UseThisTarget)) then
					
					if (Dcr_CureUnit(UseThisTarget)) then
						cleaned = true;
					end
				end
			end
		end
    end

    if (not cleaned) then

		Dcr_GetUnitArray();

		if( not cleaned) then
			if (DCR_CAN_CURE_ENEMY_MAGIC) then
			
				for _, unit in Dcr_Unit_Array do
				
					if (not Dcr_Blacklist_Array[unit]) then
					
						if (UnitIsVisible(unit)) then
				
							if (UnitIsCharmed(unit)) then
				
								if (Dcr_CureUnit(unit)) then
									cleaned = true;
									break;
								end
							end
						end
					end
				end
			end
		end

		if( not cleaned) then
			for _, unit in Dcr_Unit_Array do
				if (not Dcr_Blacklist_Array[unit]) then
				
					if (UnitIsVisible(unit)) then
				
						if (not UnitIsCharmed(unit)) then
				
							if (not Dcr_CheckUnitStealth(unit)) then

								if (Dcr_CureUnit(unit)) then
									cleaned = true;
									break;
								end
							end
						end
					end
				end
			end
		end

		if ( not cleaned) then
			for unit in Dcr_Blacklist_Array do
			
				if (not DCR_ThisCleanBlaclisted[unit]) then
			
					if (UnitExists(unit)) then

						if (UnitIsVisible(unit)) then
						
							if (not Dcr_CheckUnitStealth(unit)) then

								if (Dcr_CureUnit(unit)) then
					
									Dcr_Blacklist_Array[unit] = nil;
									cleaned = true;
									break;
								end
							end
						end
					end
				end
			end
		end
    end

    if (not SwitchToTarget) then

		if (targetEnemy) then
	    
	    	if (not UnitIsEnemy("target", "player")) then
		
				TargetUnit("playertarget");
				if (resetCombatMode) then
					Dcr_Delay_Timer = Dcr_SpellCombatDelay;
				end
			end

		elseif (targetName) then
			
			if ( targetName ~= (UnitName("target")) ) then
				TargetByName(targetName);
			end
		else
		
			if (UnitExists("target")) then
				ClearTarget();
			end
		end
    end

    Dcr_AlreadyCleanning = false;
    return cleaned;
end

function Dcr_GetUnitBuff(Unit, i)
    Dcr_ScanningTooltipTextLeft1:SetText("");
    Dcr_ScanningTooltip:SetUnitBuff(Unit, i);
    return Dcr_ScanningTooltipTextLeft1:GetText();
end

function Dcr_GetUnitDebuff(Unit, i)
    local DebuffTexture, debuffApplications, debuff_type;
    DebuffTexture, debuffApplications, debuff_type = UnitDebuff(Unit, i);

    if (DebuffTexture) then

		debuff_name = Dcr_GetUnitDebuffName(Unit, i, DebuffTexture);

		return debuff_name, debuff_type, debuffApplications, DebuffTexture;
    else
		return false, false, false, false;
    end
end

function Dcr_GetUnitDebuffName(Unit, i, DebuffTexture)
    local debuff_name;

    if (not Dcr_Debuff_Texture_to_name_cache[DebuffTexture]) then

		Dcr_ScanningTooltipTextLeft1:SetText(""); 
		Dcr_ScanningTooltip:SetUnitDebuff(Unit, i); 
		debuff_name = Dcr_ScanningTooltipTextLeft1:GetText();

		if (debuff_name == nil) then

		elseif (debuff_name ~= "") then
			
			Dcr_Debuff_Texture_to_name_cache_life = DEBUFF_CACHE_LIFE;
			Dcr_Debuff_Texture_to_name_cache[DebuffTexture] = debuff_name;
		end
    else

		debuff_name = Dcr_Debuff_Texture_to_name_cache[DebuffTexture];
    end

    Dcr_Debuff_Texture_to_name_cache_life = DEBUFF_CACHE_LIFE;

    return debuff_name;
end

function Dcr_GetUnitDebuffAll(unit)
    local DebuffTexture, debuffApplications, debuff_type, debuff_name, i;
    local ThisUnitDebuffs = {};

    i = 1;
    while (true) do
		debuff_name, debuff_type, debuffApplications, DebuffTexture = Dcr_GetUnitDebuff(unit, i);

		if (not debuff_name) then
			break;
		end

		ThisUnitDebuffs[debuff_name] = {};
		ThisUnitDebuffs[debuff_name].DebuffTexture	= DebuffTexture;
		ThisUnitDebuffs[debuff_name].debuffApplications = debuffApplications;
		ThisUnitDebuffs[debuff_name].debuff_type	= debuff_type;
		ThisUnitDebuffs[debuff_name].debuff_name	= debuff_name;
		ThisUnitDebuffs[debuff_name].index		= i;

		i = i + 1;
    end

    return ThisUnitDebuffs;
end

function Dcr_CheckUnitForBuff(Unit, BuffNameToCheck)
    local i = 1, texture, found_buff_name;

    while (true) do
		texture = UnitBuff (Unit, i);

		if (not texture) then
			break;
		end

		if (not Dcr_Buff_Texture_to_name_cache[texture]) then
			found_buff_name = Dcr_GetUnitBuff(Unit, i);

			if (found_buff_name == nil) then

			elseif (found_buff_name ~= "") then

				Dcr_Buff_Texture_to_name_cache_life = DEBUFF_CACHE_LIFE;
				Dcr_Buff_Texture_to_name_cache[texture] = found_buff_name;
			end
		else
			found_buff_name = Dcr_Buff_Texture_to_name_cache[texture];
		end

		if (i > 1) then 
			Dcr_Buff_Texture_to_name_cache_life = DEBUFF_CACHE_LIFE;
		end

		if (found_buff_name == BuffNameToCheck) then
			return true;
		end

		i = i + 1;
    end
    return false;
end

function Dcr_CheckUnitStealth(Unit)
    if (Drc_Options.CheckBox.Ingore_Stealthed) then
		for BuffName in DCR_INVISIBLE_LIST do
			if Dcr_CheckUnitForBuff(Unit, BuffName) then
				return true;
			end
		end
    end
    return false;
end

function Dcr_UnitInRange(Unit)
    if (CheckInteractDistance(Unit, 4)) then
		return true;
    end
    return false;
end

function Dcr_CureUnit(Unit)

    local Magic_Count	= 0;
    local Disease_Count = 0;
    local Poison_Count	= 0;
    local Curse_Count	= 0;

    local TClass, UClass = UnitClass(Unit);

    local AllUnitDebuffs = {};

    AllUnitDebuffs = Dcr_GetUnitDebuffAll(Unit);

    local Go_On;

    for debuff_name, debuff_params in AllUnitDebuffs do

		Go_On = true;

		if (DCR_IGNORELIST[debuff_name]) then
			return false;
		end

		if (DCR_SKIP_LIST[debuff_name]) then
			Go_On = false;
		end

		if (UnitAffectingCombat("player")) then
			if (DCR_SKIP_BY_CLASS_LIST[UClass]) then
				if (DCR_SKIP_BY_CLASS_LIST[UClass][debuff_name]) then
					Go_On = false;
				end
			end
		end

		if (Go_On) then
			
			if (debuff_params.debuff_type and debuff_params.debuff_type ~= "") then
				if (debuff_params.debuff_type == DCR_MAGIC) then

					Magic_Count = Magic_Count + debuff_params.debuffApplications + 1;
				elseif (debuff_params.debuff_type == DCR_DISEASE) then

					Disease_Count = Disease_Count + debuff_params.debuffApplications + 1;
				elseif (debuff_params.debuff_type == DCR_POISON) then

					Poison_Count = Poison_Count + debuff_params.debuffApplications + 1;
				elseif (debuff_params.debuff_type == DCR_CURSE) then

					Curse_Count = Curse_Count + debuff_params.debuffApplications + 1
				else

				end
			else

			end
		end
    end

    local res = false;
    local counts = {};
    counts.Magic_Count = Magic_Count;
    counts.Curse_Count = Curse_Count;
    counts.Poison_Count = Poison_Count;
    counts.Disease_Count = Disease_Count;
    local i;

    for i = 1, 4 do
		if Curing_functions[i] then

			res = Curing_functions[i](counts, Unit);
			if res then
				break;
			end
		end
    end
    return res;
end

function Dcr_Cure_Magic(counts, Unit)

	if (DCR_CAN_CURE_MAGIC) then
	end

	if (DCR_CAN_CURE_ENEMY_MAGIC) then
	end

	if ( (not (DCR_CAN_CURE_MAGIC or DCR_CAN_CURE_ENEMY_MAGIC)) or (counts.Magic_Count == 0) or not Drc_Options.ActiveDecurse.CureMagic) then
		return false;
	end

	if ( DCR_CAN_CURE_ENEMY_MAGIC and UnitIsCharmed(Unit) and UnitCanAttack("player", Unit) ) then

		if (DCR_SPELL_ENEMY_MAGIC_2[1] ~= 0 ) and (Drc_Options.CheckBox.Always_Use_Best_Spell or (counts.Magic_Count > 1) or (DCR_SPELL_MAGIC_1[1] == 0)) then
			return Dcr_Cast_CureSpell( DCR_SPELL_ENEMY_MAGIC_2	, Unit, DCR_CHARMED, true);
		else
			return Dcr_Cast_CureSpell( DCR_SPELL_ENEMY_MAGIC_1	, Unit, DCR_CHARMED, true);
		end

	elseif (DCR_CAN_CURE_MAGIC and (not UnitCanAttack("player", Unit))) then

		if (DCR_SPELL_MAGIC_2[1] ~= 0 ) and (Drc_Options.CheckBox.Always_Use_Best_Spell or (counts.Magic_Count > 1) or (DCR_SPELL_MAGIC_1[1] == 0)) then
			return Dcr_Cast_CureSpell( DCR_SPELL_MAGIC_2	, Unit, DCR_MAGIC, DCR_CAN_CURE_ENEMY_MAGIC);
		else
			return Dcr_Cast_CureSpell( DCR_SPELL_MAGIC_1, Unit, DCR_MAGIC, DCR_CAN_CURE_ENEMY_MAGIC);
		end
	end
    return false;
end

function Dcr_Cure_Curse( counts, Unit)

    if ( (not DCR_CAN_CURE_CURSE) or (counts.Curse_Count == 0) or not Drc_Options.ActiveDecurse.CureCurse) then
		return false;
    end

    if (UnitIsCharmed(Unit)) then
		return;
    end

    if (DCR_SPELL_CURSE ~= 0) then
		return Dcr_Cast_CureSpell(DCR_SPELL_CURSE, Unit, DCR_CURSE, false);
    end
    return false;
end

function Dcr_Cure_Poison(counts, Unit)

    if ( (not DCR_CAN_CURE_POISON) or (counts.Poison_Count == 0) or not Drc_Options.ActiveDecurse.CurePoison) then
		return false;
    end

    if (UnitIsCharmed(Unit)) then
		return;
    end

    if (Drc_Options.CheckBox.Check_For_Abolish and Dcr_CheckUnitForBuff(Unit, DCR_SPELL_ABOLISH_POISON)) then
		return false;
    end

    if (DCR_SPELL_POISON_2[1] ~= 0 ) and (Drc_Options.CheckBox.Always_Use_Best_Spell or (counts.Poison_Count > 1)) then
		return Dcr_Cast_CureSpell( DCR_SPELL_POISON_2, Unit, DCR_POISON, false);
    else
		return Dcr_Cast_CureSpell( DCR_SPELL_POISON_1, Unit, DCR_POISON, false);
    end
end

function Dcr_Cure_Disease(counts, Unit)

    if ( (not DCR_CAN_CURE_DISEASE) or (counts.Disease_Count == 0) or not Drc_Options.ActiveDecurse.CureDisease) then
		return false;
    end

    if (UnitIsCharmed(Unit)) then
		return;
    end

    if (Drc_Options.CheckBox.Check_For_Abolish and Dcr_CheckUnitForBuff(Unit, DCR_SPELL_ABOLISH_DISEASE)) then
		return false;
    end

    if (DCR_SPELL_DISEASE_2[1] ~= 0 ) and (Drc_Options.CheckBox.Always_Use_Best_Spell or (counts.Disease_Count > 1)) then
		return Dcr_Cast_CureSpell( DCR_SPELL_DISEASE_2, Unit, DCR_DISEASE, false);
    else
		return Dcr_Cast_CureSpell( DCR_SPELL_DISEASE_1, Unit, DCR_DISEASE, false);
    end
end

function Dcr_Cast_CureSpell(spellID, Unit, AfflictionType, ClearCurrentTarget)

    if (spellID[1] == 0) then
		return false;
    end

    if (
	(spellID[2] ~= BOOKTYPE_PET) and
	(not Dcr_UnitInRange(Unit))
	) then
		return false;
    end

    local spellName = GetSpellName(spellID[1], spellID[2]);

    if (ClearCurrentTarget) then

		if ( not UnitIsUnit( "target", Unit) ) then
			ClearTarget();
		end

    elseif ( UnitIsFriend( "player", "target") ) then

		if ( not UnitIsUnit( "target", Unit) ) then
			ClearTarget();
		end
    end

	Dcr_Print( string.gsub( string.gsub(DCR_CLEAN_STRING, "$t", MakePlayerName(UnitName(Unit))), "$a", MakeAfflictionName(AfflictionType)));

    if (spellID[2] == BOOKTYPE_PET or spellID[3] == DCR_SPELL_PURGE) then
		TargetUnit(Unit);
    end

    Dcr_Casting_Spell_On = Unit;
    CastSpell(spellID[1],  spellID[2]);

    if (Dcr_RestoreTarget and (spellID[2] == BOOKTYPE_PET or spellID[3] == DCR_SPELL_PURGE)) then
		TargetUnit("playertarget");
    else

		if (SpellIsTargeting()) then
			SpellTargetUnit(Unit);
		end
    end

    if ( SpellIsTargeting()) then
		SpellStopTargeting();
    end
    return true;
end
-------------------------------------------------------------------------------


