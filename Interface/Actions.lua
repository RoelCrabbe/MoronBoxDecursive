-------------------------------------------------------------------------------
-- Slicer Actions {{{
-------------------------------------------------------------------------------

-- Options
function SecondsOnBlacklistSlider_OnValueChanged()
    MoronBoxDecursive_Options.Slider.Seconds_On_Blacklist = this:GetValue()
    MBD_SliderValueChanged(MoronBoxDecursive_Options.Slider.Seconds_On_Blacklist, MBD_TIMEONBLACKLISTSLIDER)
end

function ScanFrequencySlider_OnValueChanged()
    MoronBoxDecursive_Options.Slider.ScanFrequency = this:GetValue() * 10;
    if (MoronBoxDecursive_Options.Slider.ScanFrequency < 0) then
	    MoronBoxDecursive_Options.Slider.ScanFrequency = ceil(MoronBoxDecursive_Options.Slider.ScanFrequency - 0.5)
    else
	    MoronBoxDecursive_Options.Slider.ScanFrequency = floor(MoronBoxDecursive_Options.Slider.ScanFrequency + 0.5)
    end
    MoronBoxDecursive_Options.Slider.ScanFrequency = MoronBoxDecursive_Options.Slider.ScanFrequency / 10;
    MBD_SliderValueChanged(MoronBoxDecursive_Options.Slider.ScanFrequency, MBD_SCANFREQUENCYSLIDER)
end

function MBD_UpdateLiveDisplay(Index, Unit, dBuffParams)
    
    local baseFrame = "MoronBoxDecursiveAfflictedListFrame"
    local afflictedList = getglobal(baseFrame)
    local listItem = afflictedList["ListItem"..Index]

    local afflictionText = dBuffParams.dBuffName
    if dBuffParams.dBuffApplications and dBuffParams.dBuffApplications > 1 then
        afflictionText = dBuffParams.dBuffApplications.."x "..dBuffParams.dBuffName
    end

    local coloredName = MBD_GetClassColoredName(Unit)
    local colorAfflictionText = MBD_GetDebuffColored(dBuffParams.dBuffType, afflictionText)

    if listItem.DebuffTextureOne:GetTexture() == dBuffParams.dBuffTexture and
       listItem.Name:GetText() == coloredName and
       listItem.Affliction:GetText() == afflictionText then
        return
    end

    listItem.UnitID = Unit
    listItem.DebuffTextureOne:SetTexture(dBuffParams.dBuffTexture)
    listItem.DebuffTextureTwo:SetTexture(dBuffParams.dBuffTexture)
    listItem.Name:SetText(coloredName)
    listItem.Affliction:SetText(colorAfflictionText)
    ShowUIPanel(listItem)
end

function MBD_HideAfflictedItemsFromIndex(Index)
    for i = Index, MBD.Session.Amount_Of_Afflicted do
        local baseFrame = "MoronBoxDecursiveAfflictedListFrame"
        local afflictedList = getglobal(baseFrame)
        local listItem = afflictedList["ListItem"..i]
        if listItem then
            HideUIPanel(listItem)
        end
    end
end