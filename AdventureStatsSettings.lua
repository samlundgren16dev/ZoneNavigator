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

-- Create the settings frame but keep it hidden initially
settingsFrame = CreateFrame("Frame", "AdventureStatsSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(400, 300)
settingsFrame:SetPoint("CENTER")
settingsFrame.TitleBg:SetHeight(30)
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("TOP", settingsFrame.TitleBg, "TOP", 0, -3)
settingsFrame.title:SetText("AdventureStats Settings")
settingsFrame:EnableMouse(true)
settingsFrame:SetMovable(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
settingsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Hide the settings frame by default on load
settingsFrame:Hide()

local function CreateCheckbox(checkboxText, key, checkboxTooltip)
    local checkbox = CreateFrame("CheckButton", "AdventureStatsCheckboxID" .. checkboxes, settingsFrame, "UICheckButtonTemplate")
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -30 + (checkboxes * -30))

    -- Set default setting if missing
    if AdventureStatsDB.settingsKeys[key] == nil then
        AdventureStatsDB.settingsKeys[key] = true
    end

    -- Set the checkbox state based on saved settings
    checkbox:SetChecked(AdventureStatsDB.settingsKeys[key])

    -- Tooltip and on-click behavior
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

-- Event listener frame to create checkboxes only once on PLAYER_LOGIN
local eventListenerFrame = CreateFrame("Frame", "AdventureStatsSettingsEventListenerFrame", UIParent)
eventListenerFrame:RegisterEvent("PLAYER_LOGIN")
eventListenerFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if not AdventureStatsDB.settingsKeys then
            AdventureStatsDB.settingsKeys = {}
        end

        -- Create each checkbox once on PLAYER_LOGIN
        for _, setting in pairs(settings) do
            CreateCheckbox(setting.settingText, setting.settingKey, setting.settingTooltip)
        end
    end
end)

local addon = LibStub("AceAddon-3.0"):NewAddon("AdventureStats")
AdventureStatsMinimapButton = LibStub("LibDBIcon-1.0", true)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("AdventureStats", {
    type = "data source",
    text = "AdventureStats",
    icon = "Interface\\AddOns\\AdventureStats\\minimap.tga",
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            AdventureStats:ToggleMainFrame()
        elseif btn == "RightButton" then
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

-- Ensure the minimap button is shown if configured to do so
AdventureStatsMinimapButton:Show("AdventureStats")
