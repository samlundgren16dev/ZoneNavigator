-- This script creates a settings interface for my "AdventureStats" addon in World of Warcraft.
-- It defines a settings frame with checkboxes for enabling or disabling specific tracking features,
-- such as kill tracking and currency tracking. The settings can be toggled via a slash command (/zn settings)
-- or through a minimap button. The settings are saved in the AdventureStatsDB and are initialized on player login.

local checkboxes = 0

local settings = {
    {
        settingText = "Enable tracking of Kills",
        settingKey = "enableKillTracking",
        settingTooltip = "While enabled, your kills will be tracked.",
    },
    {
        settingText = "Enable tracking of Currency",
        settingKey = "enableCurrencyTracking",
        settingTooltip = "While enabled, your currency gained will be tracked.",
    },
}

local settingsFrame = CreateFrame("Frame", "AdventureStatsMainFrame1", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(400, 300)
settingsFrame:SetPoint("CENTER")
settingsFrame.TitleBg:SetHeight(30)
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("CENTER", settingsFrame.TitleBg, "CENTER", 0, -3)
settingsFrame.title:SetText("AdventureStats Settings")
settingsFrame:Hide()
settingsFrame:EnableMouse(true)
settingsFrame:SetMovable(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)

settingsFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

local function CreateCheckbox(checkboxText, key, checkboxTooltip)
    local checkbox = CreateFrame("CheckButton", "AdventureStatsCheckboxID" .. checkboxes, settingsFrame, "UICheckButtonTemplate")
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -30 + (checkboxes * -30))

    if AdventureStatsDB.settingsKeys[key] == nil then
        AdventureStatsDB.settingsKeys[key] = true
    end

    checkbox:SetChecked(AdventureStatsDB.settingsKeys[key])

    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
    end)

    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    checkbox:SetScript("OnClick", function(self)
        AdventureStatsDB.settingsKeys[key] = self:GetChecked()
    end)

    checkboxes = checkboxes + 1

    return checkbox
end

-- Section to open and close the window via typing /zn
SLASH_AdventureStats_SETTINGS1 = "/zn settings"
SlashCmdList["AdventureStats_SETTINGS"] = function()
    if settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        settingsFrame:Show()
    end
end

local eventListenerFrame = CreateFrame("Frame", "ZoneNavigatgorSettingsEventListenerFrame", UIParent)

eventListenerFrame:RegisterEvent("PLAYER_LOGIN")

eventListenerFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		if not AdventureStatsDB.settingsKeys then
			AdventureStatsDB.settingsKeys = {}
		end

		for _, setting in pairs(settings) do
			CreateCheckbox(setting.settingText, setting.settingKey, setting.settingTooltip)
		end
	end
end)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("AdventureStats", {
    type = "data source",
    text = "AdventureStats",
    icon = "Interface\\AddOns\\AdventureStats\\minimap.tga",
    OnClick = function(self, button)
        if button == "LeftButton" then
            -- Call ToggleMainFrame using AdventureStats.mainFrame
            AdventureStats:ToggleMainFrame()
        elseif button == "RightButton" then
            if settingsFrame:IsShown() then
                settingsFrame:Hide()
            else
                settingsFrame:Show()
            end
        end
    end,

    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then
            return
        end

        tooltip:AddLine("AdventureStats\n\nLeft-click: Open AdventureStats\nRight-click: Open AdventureStats Settings", nil, nil, nil, nil)
    end,
})


local addon = LibStub("AceAddon-3.0"):NewAddon("AdventureStats")
AdventureStatsMinimapButton = LibStub("LibDBIcon-1.0", true)

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AdventureStatsMinimapPOS", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})
	AdventureStatsMinimapButton:Register("AdventureStats", miniButton, self.db.profile.minimap)
end

AdventureStatsMinimapButton:Show("AdventureStats")

function AdventureStats:ToggleMainFrame()
    if not AdventureStats.mainFrame:IsShown() then
        AdventureStats.mainFrame:Show()
    else
        AdventureStats.mainFrame:Hide()
    end
end
