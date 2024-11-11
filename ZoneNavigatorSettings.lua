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

local settingsFrame = CreateFrame("Frame", "ZoneNavigatorMainFrame1", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(400, 300)
settingsFrame:SetPoint("CENTER")
settingsFrame.TitleBg:SetHeight(30)
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("CENTER", settingsFrame.TitleBg, "CENTER", 0, -3)
settingsFrame.title:SetText("ZoneNavigator Settings")
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
    local checkbox = CreateFrame("CheckButton", "ZoneNavigatorCheckboxID" .. checkboxes, settingsFrame, "UICheckButtonTemplate")
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -30 + (checkboxes * -30))

    if ZoneNavigatorDB.settingsKeys[key] == nil then
        ZoneNavigatorDB.settingsKeys[key] = true
    end

    checkbox:SetChecked(ZoneNavigatorDB.settingsKeys[key])

    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
    end)

    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    checkbox:SetScript("OnClick", function(self)
        ZoneNavigatorDB.settingsKeys[key] = self:GetChecked()
    end)

    checkboxes = checkboxes + 1

    return checkbox
end

-- Section to open and close the window via typing /zn
SLASH_ZONENAVIGATOR_SETTINGS1 = "/zn settings"
SlashCmdList["ZONENAVIGATOR_SETTINGS"] = function()
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
		if not ZoneNavigatorDB.settingsKeys then
			ZoneNavigatorDB.settingsKeys = {}
		end

		for _, setting in pairs(settings) do
			CreateCheckbox(setting.settingText, setting.settingKey, setting.settingTooltip)
		end
	end
end)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("ZoneNavigator", {
    type = "data source",
    text = "ZoneNavigator",
    icon = "Interface\\AddOns\\ZoneNavigator\\minimap.tga",
    OnClick = function(self, button)
        if button == "LeftButton" then
            -- Call ToggleMainFrame using ZoneNavigator.mainFrame
            ZoneNavigator:ToggleMainFrame()
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

        tooltip:AddLine("ZoneNavigator\n\nLeft-click: Open ZoneNavigator\nRight-click: Open ZoneNavigator Settings", nil, nil, nil, nil)
    end,
})


local addon = LibStub("AceAddon-3.0"):NewAddon("ZoneNavigator")
ZoneNavigatorMinimapButton = LibStub("LibDBIcon-1.0", true)

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("ZoneNavigatorMinimapPOS", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})
	ZoneNavigatorMinimapButton:Register("ZoneNavigator", miniButton, self.db.profile.minimap)
end

ZoneNavigatorMinimapButton:Show("ZoneNavigator")

function ZoneNavigator:ToggleMainFrame()
    if not ZoneNavigator.mainFrame:IsShown() then
        ZoneNavigator.mainFrame:Show()
    else
        ZoneNavigator.mainFrame:Hide()
    end
end
