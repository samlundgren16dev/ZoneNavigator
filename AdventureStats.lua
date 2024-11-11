-- AdventureStats.lua

if not AdventureStatsDB then
    AdventureStatsDB = {}
end

AdventureStats = AdventureStats or {}

print("|cff00ff00Zone Navigator Successfully Loaded!|r")

-- Makes mainFrame globally accessible
AdventureStats.mainFrame = CreateFrame("Frame", "AdventureStatsMainFrame", UIParent, "BasicFrameTemplateWithInset")
AdventureStats.mainFrame:SetSize(500, 350)
AdventureStats.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
AdventureStats.mainFrame.TitleBg:SetHeight(30)
AdventureStats.mainFrame.title = AdventureStats.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
AdventureStats.mainFrame.title:SetPoint("TOPLEFT", AdventureStats.mainFrame.TitleBg, "TOPLEFT", 5, -3)
AdventureStats.mainFrame.title:SetText("Zone Navigator")

-- Set up the main frame for mouse interaction, movement, and drag functionality
AdventureStats.mainFrame:EnableMouse(true)
AdventureStats.mainFrame:SetMovable(true)
AdventureStats.mainFrame:RegisterForDrag("LeftButton")
AdventureStats.mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
AdventureStats.mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

AdventureStats.mainFrame:SetScript("OnShow", function()
    PlaySound(808)
    AdventureStats.mainFrame.totalPlayerKills:SetText("Total Kills: " .. (AdventureStatsDB.kills or "0"))
    AdventureStats.mainFrame.totalCurrency:SetText("Gold: " .. (AdventureStatsDB.gold or "0") .. " Silver: " .. (AdventureStatsDB.silver or "0") .. " Copper: " .. (AdventureStatsDB.copper or "0"))
end)

AdventureStats.mainFrame:SetScript("OnHide", function()
    PlaySound(808)
end)

-- Section to populate the main frame with player information, including character name, level, and total kills.
AdventureStats.mainFrame.playerName = AdventureStats.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
AdventureStats.mainFrame.playerName:SetPoint("TOPLEFT", AdventureStats.mainFrame, "TOPLEFT", 15, -35)
AdventureStats.mainFrame.playerName:SetText("Character: " .. UnitName("player") .. " (Level " .. UnitLevel("player") .. ")")
AdventureStats.mainFrame.totalPlayerKills = AdventureStats.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
AdventureStats.mainFrame.totalPlayerKills:SetPoint("TOPLEFT", AdventureStats.mainFrame.playerName, "BOTTOMLEFT", 0, -10)
AdventureStats.mainFrame.totalPlayerKills:SetText("Total Kills: " .. (AdventureStatsDB.kills or "0"))
AdventureStats.mainFrame.totalCurrency = AdventureStats.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
AdventureStats.mainFrame.totalCurrency:SetPoint("TOPLEFT", AdventureStats.mainFrame.totalPlayerKills, "BOTTOMLEFT", 0, -10)
AdventureStats.mainFrame.totalCurrency:SetText("Gold: " .. (AdventureStatsDB.gold or "0") .. ", Silver: " .. (AdventureStatsDB.silver or "0") .. ", Copper: " .. (AdventureStatsDB.copper or "0"))



-- Section to open and close the window via typing /zn
SLASH_AdventureStats1 = "/zn"
SlashCmdList["AdventureStats"] = function()
    if AdventureStats.mainFrame:IsShown() then
        AdventureStats.mainFrame:Hide()
    else
        AdventureStats.mainFrame:Show()
    end
end

-- Adds the AdventureStats main frame to the list of special frames, allowing it to be hidden when the Escape key is pressed.
table.insert(UISpecialFrames, "AdventureStatsMainFrame")

-- Creates an event listener frame to handle in-game events.
local eventListenerFrame = CreateFrame("Frame", "AdventureStatsEventListenerFrame", UIParent)

-- Event handler function to track and update the total number of kills when a "PARTY_KILL" event is triggered.
local function eventHandler(self, event, ...)
    local _, eventType = CombatLogGetCurrentEventInfo()

    if event == "COMBAT_LOG_EVENT_UNFILTERED" and AdventureStatsDB.settingsKeys.enableKillTracking then
        if eventType == "PARTY_KILL" then
            if not AdventureStatsDB.kills then
                AdventureStatsDB.kills = 1
            else
                AdventureStatsDB.kills = AdventureStatsDB.kills + 1
            end
        end
    elseif event == "CHAT_MSG_MONEY" and AdventureStatsDB.settingsKeys.enableCurrencyTracking then
        local msg = ...
        local gold = tonumber(string.match(msg, "(%d+) Gold")) or 0
        local silver = tonumber(string.match(msg, "(%d+) Silver")) or 0
        local copper = tonumber(string.match(msg, "(%d+) Copper")) or 0

        AdventureStatsDB.gold = (AdventureStatsDB.gold or 0) + gold
        AdventureStatsDB.silver = (AdventureStatsDB.silver or 0) + silver
        AdventureStatsDB.copper = (AdventureStatsDB.copper or 0) + copper

        if AdventureStatsDB.copper >= 100 then
            AdventureStatsDB.silver = AdventureStatsDB.silver + math.floor(AdventureStatsDB.copper / 100)
            AdventureStatsDB.copper = AdventureStatsDB.copper % 100
        end

        if AdventureStatsDB.silver >= 100 then
            AdventureStatsDB.gold = AdventureStatsDB.gold + math.floor(AdventureStatsDB.silver / 100)
            AdventureStatsDB.silver = AdventureStatsDB.silver % 100
        end
    end

    if AdventureStats.mainFrame:IsShown() then
        AdventureStats.mainFrame.totalPlayerKills:SetText("Total Kills: " .. (AdventureStatsDB.kills or "0"))
        AdventureStats.mainFrame.totalCurrency:SetText("Gold: " .. (AdventureStatsDB.gold or "0") .. " Silver: " .. (AdventureStatsDB.silver or "0") .. " Copper: " .. (AdventureStatsDB.copper or "0"))
    end
end

-- Sets the event handler script for the event listener frame and registers it to listen for "COMBAT_LOG_EVENT_UNFILTERED" events.
eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventListenerFrame:RegisterEvent("CHAT_MSG_MONEY")
