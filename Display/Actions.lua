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