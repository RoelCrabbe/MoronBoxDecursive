-------------------------------------------------------------------------------
-- Frame Names {{{
-------------------------------------------------------------------------------

local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))

MBD.MiniMapButton = CreateFrame("Frame", nil , Minimap)
MBD.MainFrame = CreateFrame("Frame", nil , UIParent) 
MBD.OptionFrame = CreateFrame("Frame", nil , UIParent) 
MBD.PopupDefaultFrame = CreateFrame("Frame", nil , UIParent) 

function MBD:CreateWindows()
    MBD.MiniMapButton:CreateMinimapIcon()
    MBD.MainFrame:CreateMainFrame()
    MBD.OptionFrame:CreateOptionFrame()
    MBD.PopupDefaultFrame:CreatePopupDefaultFrame()
end

function MBD_ResetAllWindow()
    MBD.MainFrame:ClearAllPoints()
    MBD.MainFrame:SetPoint("CENTER", nil, "TOP", 0, -50)
    MBD_ResetFramePosition(MBD.OptionFrame)
    MBD_ResetFramePosition(MBD.PopupDefaultFrame)
end

function MBD_OpenOptionFrame()
    if MBD.OptionFrame:IsVisible() then
        MBD_CloseAllWindow()
    else 
        ShowUIPanel(MBD.OptionFrame)
    end
end

function MBD_CloseAllWindow()
    MBD_ResetAllWindow()
    HideUIPanel(MBD.OptionFrame)
end

-------------------------------------------------------------------------------
-- Locals {{{
-------------------------------------------------------------------------------

local ColorPicker = {
    White = { r = 1, g = 1, b = 1, a = 1 },                 -- #ffffff
    Black = { r = 0, g = 0, b = 0, a = 1 },                 -- #000000 

    -- Gray Shades
    Gray50 = { r = 0.976, g = 0.976, b = 0.976, a = 1 },    -- #f9f9f9
    Gray100 = { r = 0.925, g = 0.925, b = 0.925, a = 1 },   -- #ececec
    Gray200 = { r = 0.890, g = 0.890, b = 0.890, a = 1 },   -- #e3e3e3
    Gray300 = { r = 0.804, g = 0.804, b = 0.804, a = 1 },   -- #cdcdcd
    Gray400 = { r = 0.706, g = 0.706, b = 0.706, a = 1 },   -- #b4b4b4
    Gray500 = { r = 0.608, g = 0.608, b = 0.608, a = 1 },   -- #9b9b9b
    Gray600 = { r = 0.404, g = 0.404, b = 0.404, a = 1 },   -- #676767
    Gray650 = { r = 0.404, g = 0.404, b = 0.404, a = 0.45 },   -- #676767
    Gray700 = { r = 0.259, g = 0.259, b = 0.259, a = 1 },   -- #424242
    Gray800 = { r = 0.184, g = 0.184, b = 0.184, a = 1 },   -- #2f2f2f
    Gray850 = { r = 0.184, g = 0.184, b = 0.184, a = 0.5 },   -- #2f2f2f

    -- Blue Shades
    Blue50 = { r = 0.678, g = 0.725, b = 0.776, a = 1 },    -- #adb9c6
    Blue100 = { r = 0.620, g = 0.675, b = 0.737, a = 1 },   -- #9eaebd
    Blue200 = { r = 0.561, g = 0.624, b = 0.698, a = 1 },   -- #8fa0b2
    Blue300 = { r = 0.502, g = 0.576, b = 0.659, a = 1 },   -- #8093a8
    Blue400 = { r = 0.443, g = 0.529, b = 0.620, a = 1 },   -- #71879e
    Blue500 = { r = 0.384, g = 0.482, b = 0.682, a = 1 },   -- #627bb0
    Blue600 = { r = 0.325, g = 0.435, b = 0.643, a = 1 },   -- #5370a4
    Blue700 = { r = 0.267, g = 0.388, b = 0.604, a = 1 },   -- #44639a
    Blue800 = { r = 0.208, g = 0.341, b = 0.565, a = 1 },   -- #355791

    -- Green Shades
    Green50 = { r = 0.561, g = 0.698, b = 0.624, a = 1 },   -- #8fb28f
    Green100 = { r = 0.502, g = 0.659, b = 0.576, a = 1 },  -- #80a89a
    Green200 = { r = 0.443, g = 0.620, b = 0.529, a = 1 },  -- #719e86
    Green300 = { r = 0.384, g = 0.682, b = 0.482, a = 1 },  -- #62ae7b
    Green400 = { r = 0.325, g = 0.643, b = 0.435, a = 1 },  -- #53a480
    Green500 = { r = 0.267, g = 0.604, b = 0.388, a = 1 },  -- #439a63
    Green600 = { r = 0.208, g = 0.565, b = 0.341, a = 1 },  -- #359155
    Green700 = { r = 0.149, g = 0.525, b = 0.294, a = 1 },  -- #27864b
    Green800 = { r = 0.090, g = 0.486, b = 0.247, a = 1 },  -- #176f3f

    -- Red Shades
    Red500 = { r = 0.937, g = 0.267, b = 0.267, a = 1 },    -- #ef4444
    Red700 = { r = 0.725, g = 0.110, b = 0.110, a = 1 },    -- #b91c1c
}

local BackDrop = {
    bgFile = "Interface/Buttons/WHITE8X8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = false,
    tileSize = 16,
    edgeSize = 4,
    insets = {
        left = 1,
        right = 1,
        top = 1,
        bottom = 1
    }
}

local SliderBackDrop = {
    bgFile = "Interface/Buttons/UI-SliderBar-Background",
    edgeFile = "Interface/Buttons/UI-SliderBar-Border",
    tile = false,
    tileSize = 16,
    edgeSize = 1,
    insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }
}

-------------------------------------------------------------------------------
-- MiniMap Button {{{
-------------------------------------------------------------------------------

function MBD.MiniMapButton:CreateMinimapIcon()
    local IsMiniMapMoving = false

    self:SetFrameStrata("LOW")
    MBD_SetSize(self, 32, 32)
	self:SetPoint("BOTTOMLEFT", 0, 0)
	
	self.Button = CreateFrame("Button", nil, self)
    MBD_SetSize(self.Button, 32, 32)
    MBD_RegisterAllClicksAndDrags(self.Button)
	self.Button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	self.Overlay = self:CreateTexture(nil, "OVERLAY", self)
    MBD_SetSize(self.Overlay, 52, 52)
    self.Overlay:SetPoint("TOPLEFT", 0, 0)
	self.Overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	
	self.MinimapIcon = self:CreateTexture(nil, "BACKGROUND")
    MBD_SetSize(self.MinimapIcon, 18, 18)
	self.MinimapIcon:SetTexture("Interface\\Icons\\Spell_Holy_DispelMagic")
    self.MinimapIcon:SetTexCoord(0.075, 0.925, 0.075, 0.925)

    local function OnUpdate()
        if IsMiniMapMoving then

            local xpos, ypos = GetCursorPosition()
            local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
            xpos = xmin - xpos / UIParent:GetScale() + 70
            ypos = ypos / UIParent:GetScale() - ymin - 70
            local iconPos = math.deg(math.atan2(ypos, xpos))

            if iconPos < 0 then
                iconPos = iconPos + 360
            end

            self:SetPoint(
                "TOPLEFT",
                "Minimap",
                "TOPLEFT",
                54 - (78 * cos(iconPos)),
                (78 * sin(iconPos)) - 55
            )
        end
    end

    local function OnDragStart()
        if not IsMiniMapMoving and arg1 == "LeftButton" then
            self.Button:SetScript("OnUpdate", OnUpdate)
            IsMiniMapMoving = true
        end
    end

    local function OnDragStop()
        if IsMiniMapMoving then
            self.Button:SetScript("OnUpdate", nil)
            IsMiniMapMoving = false
        end
    end

    local function OnClick()
        MBD_OpenOptionFrame()
    end

    self.Button:SetScript("OnDragStart", OnDragStart)
    self.Button:SetScript("OnDragStop", OnDragStop)
    self.Button:SetScript("OnClick", OnClick)
    self.Button:SetScript("OnLeave", MBD_HideTooltip)
    self.Button:SetScript("OnEnter", function()
        MBD_ShowToolTip(self, MBD_TITLE, MBD_MINIMAPHOVER)
    end)   
end

-------------------------------------------------------------------------------
-- Main Frame {{{
-------------------------------------------------------------------------------

function MBD.MainFrame:CreateMainFrame()

    MBD_CreateMainBar(self)
    self.AfflictedList = MBD_CreateAfflictedList(self)
end

-------------------------------------------------------------------------------
-- Option Frame {{{
-------------------------------------------------------------------------------

function MBD.OptionFrame:CreateOptionFrame()
    
    MBD_DefaultFrameTemplate(self)
    MBD_DefaultFrameButtons(self)

    self.InnerContainer = MBD_CreateInnerContainer(self)

        self.SecondsOnBlacklistSlider = MBD_CreateSlider(self.InnerContainer, "SecondsOnBlacklistSlider", 220)
        self.SecondsOnBlacklistSlider:SetPoint("CENTER", self.InnerContainer, "TOP", 0, -50)
        self.SecondsOnBlacklistSlider:SetScript("OnValueChanged", SecondsOnBlacklistSlider_OnValueChanged)
        self.SecondsOnBlacklistSlider:SetScript("OnShow", function()
            MBD_InitializeSlider(self.SecondsOnBlacklistSlider, MBD_TIMEONBLACKLISTSLIDER, MoronBoxDecursive_Options.Slider.Seconds_On_Blacklist, 1, 10, 1)
        end)

        self.ScanFrequencySlider = MBD_CreateSlider(self.InnerContainer, "ScanFrequencySlider", 220)
        self.ScanFrequencySlider:SetPoint("CENTER", self.SecondsOnBlacklistSlider, "CENTER", 0, -50)
        self.ScanFrequencySlider:SetScript("OnValueChanged", ScanFrequencySlider_OnValueChanged)
        self.ScanFrequencySlider:SetScript("OnShow", function()
            MBD_InitializeSlider(self.ScanFrequencySlider, MBD_SCANFREQUENCYSLIDER, MoronBoxDecursive_Options.Slider.ScanFrequency, 0.1, 1, 0.1)
        end)

        self.AbolishCheckButton = MBD_CreateCheckButton(self.InnerContainer, MBD_ABOLISHCHECK, MoronBoxDecursive_Options.CheckBox.Check_For_Abolish, -15)
        self.AbolishCheckButton:SetPoint("CENTER", self.ScanFrequencySlider, "CENTER", 0, -75)
        self.AbolishCheckButton:SetScript("OnClick", function()
            MoronBoxDecursive_Options.CheckBox.Check_For_Abolish = (self.AbolishCheckButton:GetChecked() == 1)
        end)

        self.BestSpellCheckButton = MBD_CreateCheckButton(self.InnerContainer, MBD_ALWAYSBESTSPELL, MoronBoxDecursive_Options.CheckBox.Always_Use_Best_Spell, -15)
        self.BestSpellCheckButton:SetPoint("CENTER", self.AbolishCheckButton, "CENTER", 0, -35)
        self.BestSpellCheckButton:SetScript("OnClick", function()
            MoronBoxDecursive_Options.CheckBox.Always_Use_Best_Spell = (self.BestSpellCheckButton:GetChecked() == 1)
        end)

        self.RandomOrderCheckButton = MBD_CreateCheckButton(self.InnerContainer, MBD_CURERANDOMORDER, MoronBoxDecursive_Options.CheckBox.Random_Order, -15)
        self.RandomOrderCheckButton:SetPoint("CENTER", self.BestSpellCheckButton, "CENTER", 0, -35)
        self.RandomOrderCheckButton:SetScript("OnClick", function()
            MoronBoxDecursive_Options.CheckBox.Random_Order = (self.RandomOrderCheckButton:GetChecked() == 1)
        end)
end

-------------------------------------------------------------------------------
-- PopupDefault Frame {{{
-------------------------------------------------------------------------------

function MBD.PopupDefaultFrame:CreatePopupDefaultFrame()

    MBD_CreatePopupFrame(self)

    self.PopupPresetText = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.PopupPresetText:SetText(MBD_RESTOREDEFAULTCONFIRM)
    self.PopupPresetText:SetPoint("CENTER", self, "TOP", 0, -25)

    self.AcceptButton:SetScript("OnClick", function()
        MBD_SetDefaultValues()
        HideUIPanel(self)
    end)
end

-------------------------------------------------------------------------------
-- Helper Functions {{{
-------------------------------------------------------------------------------

function MBD_ResetFramePosition(Frame)
    if not Frame then return end

    Frame:ClearAllPoints()
    Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    HideUIPanel(Frame)
end

function MBD_SetBackdropColor(Frame, Color)
    if not Frame or not Color then return end
    Frame:SetBackdropColor(MBD_GetColorValue(Color))
    Frame:SetBackdropBorderColor(MBD_GetColorValue(Color))
end

function MBD_SetFontSize(FontString, Size)
    if not FontString then return end
    if not Size then Size = 13 end
    local font, _, flags = FontString:GetFont()
    FontString:SetFont(font, Size, flags)
end

function MBD_SetSize(Frame, Width, Height)
    if not Frame or not Width or not Height then return end
    Frame:SetWidth(Width)
	Frame:SetHeight(Height)
    Frame:SetPoint("CENTER", 0, 0)
end

function MBD_ShowToolTip(Parent, Title, Text)
    if not Parent or not Title or not Text then return end
    GameTooltip:SetOwner(Parent, "ANCHOR_BOTTOMLEFT")
    GameTooltip:SetText(Title, 1, 1, 0.5)
    GameTooltip:AddLine(Text)
    GameTooltip:Show()
end

function MBD_HideTooltip()
    GameTooltip:Hide()
end

function MBD_GetColorValue(colorKey)
    return ColorPicker[colorKey].r, ColorPicker[colorKey].g, ColorPicker[colorKey].b, ColorPicker[colorKey].a
end

function MBD_RegisterAllClicksAndDrags(Frame)
    if not Frame then return end
    Frame:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    Frame:RegisterForDrag("LeftButton", "RightButton")
end

function MBD_CreateButton(Parent, Text, Width, Height)
    if not Parent or not Text then return end

    Width = Width or 60
    Height = Height or 25

    local Button = CreateFrame("Button", nil, Parent)
    Button:SetBackdrop(BackDrop)
    MBD_SetSize(Button, Width, Height)
    MBD_SetBackdropColor(Button, "Gray600")

    local Overlay = Button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Overlay:SetText(Text)
    Overlay:SetPoint("CENTER", Button, "CENTER")
    Button.Overlay = Overlay

    local function Button_OnEnter()
        MBD_SetBackdropColor(Button, "Gray400")
    end

    local function Button_OnLeave()
        MBD_SetBackdropColor(Button, "Gray600")
    end

    Button:SetScript("OnEnter", Button_OnEnter)
    Button:SetScript("OnLeave", Button_OnLeave)
    return Button
end

function MBD_CreateInnerContainer(Parent)
    if not Parent then return end

    local InnerContainer = CreateFrame("Frame", nil, Parent)
    InnerContainer:SetBackdrop(BackDrop)
    MBD_SetSize(InnerContainer, 350, 300)
    MBD_SetBackdropColor(InnerContainer, "Gray600")
    InnerContainer:SetPoint("CENTER", Parent, "CENTER", 0, 0)
    Parent.InnerContainer = InnerContainer

    return InnerContainer
end

function MBD_DefaultFrameTemplate(Frame)
    local IsMoving = false

    Frame:SetFrameLevel(9)
    Frame:SetBackdrop(BackDrop)
    Frame:SetMovable(true)
    Frame:EnableMouse(true)
    MBD_SetSize(Frame, 400, 400)
    MBD_SetBackdropColor(Frame, "Gray800")

    local Title = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    Title:SetText(MBD_TITLE)
    Title:SetPoint("CENTER", Frame, "TOP", 0, -25)
    Frame.Title = Title

    local Author = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Author:SetText(MBD_AUTHOR)
    Author:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -10, 15)
    Frame.Author = Author

    local function Frame_OnMouseUp()
        if IsMoving then
            Frame:StopMovingOrSizing()
            IsMoving = false
        end
    end

    local function Frame_OnMouseDown()
        if not IsMoving and arg1 == "LeftButton" then
            Frame:StartMoving()
            IsMoving = true
        end
    end

    Frame:SetScript("OnMouseUp", Frame_OnMouseUp)
    Frame:SetScript("OnMouseDown", Frame_OnMouseDown)
    Frame:SetScript("OnHide", Frame_OnMouseUp)
    HideUIPanel(Frame)
end

function MBD_DefaultFrameButtons(Parent)

    local CloseButton = MBD_CreateButton(Parent, MBD_HIDE) 
    CloseButton:SetPoint("BOTTOMLEFT", Parent, "BOTTOMLEFT", 10, 12.5)
    Parent.CloseButton = CloseButton

    local function CloseButton_OnEnter()
        MBD_SetBackdropColor(CloseButton, "Red500")
        CloseButton.Overlay:SetText(MBD_EXIT)
    end

    local function CloseButton_OnLeave()
        MBD_SetBackdropColor(CloseButton, "Gray600")
        CloseButton.Overlay:SetText(MBD_HIDE)
    end

    CloseButton:SetScript("OnEnter", CloseButton_OnEnter)
    CloseButton:SetScript("OnLeave", CloseButton_OnLeave)
    CloseButton:SetScript("OnClick", function()
        HideUIPanel(Parent)
    end)

    local DefaultSettingsButton = MBD_CreateButton(Parent, MBD_RESTOREDEFAULT, 120) 
    DefaultSettingsButton:SetPoint("LEFT", CloseButton, "RIGHT", 5, 0)
    Parent.DefaultSettingsButton = DefaultSettingsButton

    local function DefaultSettingsButton_OnEnter()
        MBD_SetBackdropColor(DefaultSettingsButton, "Blue600")
    end

    DefaultSettingsButton:SetScript("OnEnter", DefaultSettingsButton_OnEnter)
    DefaultSettingsButton:SetScript("OnClick", function()
        ShowUIPanel(MBD.PopupDefaultFrame)
    end)
end

function MBD_CreateSlider(Parent, Name, Width, Height)
    if not Parent or not Name then return end

    Width = Width or 220
    Height = Height or 16

    local Slider = CreateFrame("Slider", Name, Parent, 'OptionsSliderTemplate')
    Slider:SetBackdrop(SliderBackDrop)
    MBD_SetSize(Slider, Width, Height)
    Parent.Slider = Slider

    return Slider
end

function _G.MBD_SliderValueChanged(Value, String)
    getglobal(this:GetName().."Text"):SetText(string.gsub(String, "$p", Value))
    getglobal(this:GetName().."Text"):SetPoint("BOTTOM", this, "TOP", 0, 5)
end

function MBD_InitializeSlider(Slider, String, Value, MinStep, MaxStep, ValStep)
    getglobal(Slider:GetName().."Text"):SetText(string.gsub(String, "$p", Value))
    getglobal(Slider:GetName().."Text"):SetPoint("BOTTOM", Slider, "TOP", 0, 5)

    MinStep = MinStep or 1
    MaxStep = MaxStep or 100

    Slider:SetMinMaxValues(MinStep, MaxStep)
    Slider:SetValueStep(ValStep or 1)
    Slider:SetValue(Value)

    HideUIPanel(Slider:GetName().."Low")
    HideUIPanel(Slider:GetName().."High")

    local minValueText = Slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minValueText:SetText(MinStep)
    minValueText:SetPoint("CENTER", Slider, "LEFT", -10, 0)

    local maxValueText = Slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    maxValueText:SetText(MaxStep)
    maxValueText:SetPoint("CENTER", Slider, "RIGHT", 10, 0)
end

function MBD_CreateCheckButton(Parent, Title, Value, XAsis)
    if not Parent or not Title then return end

    Value = Value or 0
    XAsis = XAsis or -48.5

    local CheckButton = CreateFrame("CheckButton", nil, Parent, "OptionsCheckButtonTemplate")
    CheckButton:SetChecked(Value)
    
    local CheckButtonText = CheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    CheckButtonText:SetText(Title)
    CheckButtonText:SetPoint("RIGHT", CheckButton, "LEFT", XAsis, 0)
    CheckButton.CheckButtonText = CheckButtonText

    return CheckButton
end

function MBD_CreatePopupFrame(PopupFrame)
    local IsMoving = false

    PopupFrame:SetFrameStrata("HIGH")
    PopupFrame:SetMovable(true)
    PopupFrame:EnableMouse(true)
    PopupFrame:SetBackdrop(BackDrop)
    MBD_SetSize(PopupFrame, 300, 110)
    MBD_SetBackdropColor(PopupFrame, "Gray800")

    local PopupFrameText = PopupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    PopupFrameText:SetText(MBD_RELOADUI)
    PopupFrameText:SetPoint("CENTER", PopupFrame, "CENTER", 0, 0)
    PopupFrame.PopupFrameText = PopupFrameText

    local AcceptButton = MBD_CreateButton(PopupFrame, MBD_YES, 100) 
    AcceptButton:SetPoint("BOTTOMLEFT", PopupFrame, "BOTTOMLEFT", 5, 7.5)
    PopupFrame.AcceptButton = AcceptButton

    local function AcceptButton_OnEnter()
        MBD_SetBackdropColor(AcceptButton, "Green600")
    end

    AcceptButton:SetScript("OnEnter", AcceptButton_OnEnter)

    local DeclineButton = MBD_CreateButton(PopupFrame, MBD_NO, 100) 
    DeclineButton:SetPoint("BOTTOMRIGHT", PopupFrame, "BOTTOMRIGHT", -5, 7.5)
    PopupFrame.DeclineButton = DeclineButton

    local function DeclineButton_OnEnter()
        MBD_SetBackdropColor(DeclineButton, "Red500")
    end

    DeclineButton:SetScript("OnEnter", DeclineButton_OnEnter)
    DeclineButton:SetScript("OnClick", function()
        HideUIPanel(PopupFrame)
    end)

    local function PopupFrame_OnMouseUp()
        if IsMoving then
            PopupFrame:StopMovingOrSizing()
            IsMoving = false
        end
    end

    local function PopupFrame_OnMouseDown()
        if not IsMoving and arg1 == "LeftButton" then
            PopupFrame:StartMoving()
            IsMoving = true
        end
    end

    PopupFrame:SetScript("OnMouseUp", PopupFrame_OnMouseUp)
    PopupFrame:SetScript("OnMouseDown", PopupFrame_OnMouseDown)
    PopupFrame:SetScript("OnHide", PopupFrame_OnMouseUp)
    HideUIPanel(PopupFrame)
end

function MBD_CreateMainBar(Frame)
    local IsMoving = false

    Frame:SetFrameLevel(10)
    Frame:SetBackdrop(BackDrop)
    Frame:SetMovable(true)
    Frame:EnableMouse(true)
    MBD_SetSize(Frame, 120, 25)
    MBD_SetBackdropColor(Frame, "Gray850")
    Frame:SetPoint("CENTER", UIParent, "TOP", 0, -50)

    local Title = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Title:SetText(MBD_TITLE)
    Title:SetPoint("CENTER", Frame, "CENTER", 0, 0)
    Frame.Title = Title

    local function Frame_OnMouseUp()
        if IsMoving then
            Frame:StopMovingOrSizing()
            IsMoving = false
        end
    end

    local function Frame_OnMouseDown()
        if not IsMoving and arg1 == "LeftButton" then
            Frame:StartMoving()
            IsMoving = true
        elseif arg1 == "RightButton" then
            MBD_OpenOptionFrame()
        end
    end

    Frame:SetScript("OnMouseUp", Frame_OnMouseUp)
    Frame:SetScript("OnMouseDown", Frame_OnMouseDown)
    Frame:SetScript("OnHide", Frame_OnMouseUp)
end

function MBD_CreateDecursiveAfflictedTemplate(Name, Parent)

    local AfflictedButton = CreateFrame("Button", Name, Parent)
    AfflictedButton:SetBackdrop(BackDrop)
    AfflictedButton:SetFrameLevel(10)
    AfflictedButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    MBD_SetSize(AfflictedButton, 160, 35)
    MBD_SetBackdropColor(AfflictedButton, "Gray650")

    local DebuffTextureOne = AfflictedButton:CreateTexture(nil, "ARTWORK")
    MBD_SetSize(DebuffTextureOne, 30, 30)
    DebuffTextureOne:SetPoint("LEFT", AfflictedButton, "LEFT", 3, 0)
    DebuffTextureOne:SetTexture("Interface\\Icons\\Spell_Holy_DispelMagic")
    DebuffTextureOne:SetTexCoord(0.075, 0.925, 0.075, 0.925)
    AfflictedButton.DebuffTextureOne = DebuffTextureOne

    local Name = AfflictedButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    MBD_SetSize(Name, 145, 10)
    MBD_SetFontSize(Name, 12)
    Name:SetPoint("CENTER", AfflictedButton, "CENTER", 0, 8)
    Name:SetText("Name")
    AfflictedButton.Name = Name

    local Affliction = AfflictedButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    MBD_SetSize(Affliction, 145, 10)
    MBD_SetFontSize(Affliction, 11)
    Affliction:SetPoint("CENTER", AfflictedButton, "CENTER", 0, -8)
    Affliction:SetText("Affliction")
    AfflictedButton.Affliction = Affliction

    local DebuffTextureTwo = AfflictedButton:CreateTexture(nil, "ARTWORK")
    MBD_SetSize(DebuffTextureTwo, 30, 30)
    DebuffTextureTwo:SetPoint("RIGHT", AfflictedButton, "RIGHT", -3, 0)
    DebuffTextureTwo:SetTexture("Interface\\Icons\\Spell_Holy_DispelMagic")
    DebuffTextureTwo:SetTexCoord(0.075, 0.925, 0.075, 0.925)
    AfflictedButton.DebuffTextureTwo = DebuffTextureTwo
    
    HideUIPanel(AfflictedButton)
    AfflictedButton:SetScript("OnClick", function()
        if AfflictedButton.UnitID then
            MBD_Clean(AfflictedButton.UnitID, (arg1 == "RightButton"))
        end
    end)
    return AfflictedButton
end

function MBD_CreateAfflictedListItem(Parent, Name, RelativeTo)
    local listItem = MBD_CreateDecursiveAfflictedTemplate(Name, Parent)
    listItem:SetPoint("TOPLEFT", RelativeTo, "BOTTOMLEFT", 0, -5)
    return listItem
end

function MBD_CreateAfflictedList(Parent)
    if not Parent then return end

    local AfflictedList = CreateFrame("Frame", "MoronBoxDecursiveAfflictedListFrame", Parent)
    MBD_SetSize(AfflictedList, 160, 1)
    AfflictedList:SetPoint("TOP", Parent, "BOTTOM", 0, 5)
    Parent.AfflictedList = AfflictedList

    for i = 1, MBD.Session.Amount_Of_Afflicted do
        local PreviousItem = i == 1 and AfflictedList or AfflictedList["ListItem"..(i - 1)]
        local Item = MBD_CreateAfflictedListItem(AfflictedList, "$parentListItem"..i, PreviousItem)
        AfflictedList["ListItem"..i] = Item
    end

    return AfflictedList
end