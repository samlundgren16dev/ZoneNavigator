-- ZoneNavigator.lua

if not ZoneNavigatorDB then
    ZoneNavigatorDB = {}
end

ZoneNavigator = ZoneNavigator or {}

print("|cff00ff00Zone Navigator Successfully Loaded!|r")

-- Makes mainFrame globally accessible
ZoneNavigator.mainFrame = CreateFrame("Frame", "ZoneNavigatorMainFrame", UIParent, "BasicFrameTemplateWithInset")
ZoneNavigator.mainFrame:SetSize(500, 350)
ZoneNavigator.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
ZoneNavigator.mainFrame.TitleBg:SetHeight(30)
ZoneNavigator.mainFrame.title = ZoneNavigator.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
ZoneNavigator.mainFrame.title:SetPoint("TOPLEFT", ZoneNavigator.mainFrame.TitleBg, "TOPLEFT", 5, -3)
ZoneNavigator.mainFrame.title:SetText("Zone Navigator")

-- Set up the main frame for mouse interaction, movement, and drag functionality
ZoneNavigator.mainFrame:EnableMouse(true)
ZoneNavigator.mainFrame:SetMovable(true)
ZoneNavigator.mainFrame:RegisterForDrag("LeftButton")
ZoneNavigator.mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
ZoneNavigator.mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

ZoneNavigator.mainFrame:SetScript("OnShow", function()
    PlaySound(808)
    ZoneNavigator.mainFrame.totalPlayerKills:SetText("Total Kills: " .. (ZoneNavigatorDB.kills or "0"))
    ZoneNavigator.mainFrame.totalCurrency:SetText("Gold: " .. (ZoneNavigatorDB.gold or "0") .. " Silver: " .. (ZoneNavigatorDB.silver or "0") .. " Copper: " .. (ZoneNavigatorDB.copper or "0"))
end)

ZoneNavigator.mainFrame:SetScript("OnHide", function()
    PlaySound(808)
end)

-- Section to populate the main frame with player information, including character name, level, and total kills.
ZoneNavigator.mainFrame.playerName = ZoneNavigator.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZoneNavigator.mainFrame.playerName:SetPoint("TOPLEFT", ZoneNavigator.mainFrame, "TOPLEFT", 15, -35)
ZoneNavigator.mainFrame.playerName:SetText("Character: " .. UnitName("player") .. " (Level " .. UnitLevel("player") .. ")")
ZoneNavigator.mainFrame.totalPlayerKills = ZoneNavigator.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZoneNavigator.mainFrame.totalPlayerKills:SetPoint("TOPLEFT", ZoneNavigator.mainFrame.playerName, "BOTTOMLEFT", 0, -10)
ZoneNavigator.mainFrame.totalPlayerKills:SetText("Total Kills: " .. (ZoneNavigatorDB.kills or "0"))
ZoneNavigator.mainFrame.totalCurrency = ZoneNavigator.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZoneNavigator.mainFrame.totalCurrency:SetPoint("TOPLEFT", ZoneNavigator.mainFrame.totalPlayerKills, "BOTTOMLEFT", 0, -10)
ZoneNavigator.mainFrame.totalCurrency:SetText("Gold: " .. (ZoneNavigatorDB.gold or "0") .. ", Silver: " .. (ZoneNavigatorDB.silver or "0") .. ", Copper: " .. (ZoneNavigatorDB.copper or "0"))



-- Section to open and close the window via typing /zn
SLASH_ZONENAVIGATOR1 = "/zn"
SlashCmdList["ZONENAVIGATOR"] = function()
    if ZoneNavigator.mainFrame:IsShown() then
        ZoneNavigator.mainFrame:Hide()
    else
        ZoneNavigator.mainFrame:Show()
    end
end

-- Adds the ZoneNavigator main frame to the list of special frames, allowing it to be hidden when the Escape key is pressed.
table.insert(UISpecialFrames, "ZoneNavigatorMainFrame")

-- Creates an event listener frame to handle in-game events.
local eventListenerFrame = CreateFrame("Frame", "ZoneNavigatorEventListenerFrame", UIParent)

-- Event handler function to track and update the total number of kills when a "PARTY_KILL" event is triggered.
local function eventHandler(self, event, ...)
    local _, eventType = CombatLogGetCurrentEventInfo()

    if event == "COMBAT_LOG_EVENT_UNFILTERED" and ZoneNavigatorDB.settingsKeys.enableKillTracking then
        if eventType == "PARTY_KILL" then
            if not ZoneNavigatorDB.kills then
                ZoneNavigatorDB.kills = 1
            else
                ZoneNavigatorDB.kills = ZoneNavigatorDB.kills + 1
            end
        end
    elseif event == "CHAT_MSG_MONEY" and ZoneNavigatorDB.settingsKeys.enableCurrencyTracking then
        local msg = ...
        local gold = tonumber(string.match(msg, "(%d+) Gold")) or 0
        local silver = tonumber(string.match(msg, "(%d+) Silver")) or 0
        local copper = tonumber(string.match(msg, "(%d+) Copper")) or 0

        ZoneNavigatorDB.gold = (ZoneNavigatorDB.gold or 0) + gold
        ZoneNavigatorDB.silver = (ZoneNavigatorDB.silver or 0) + silver
        ZoneNavigatorDB.copper = (ZoneNavigatorDB.copper or 0) + copper

        if ZoneNavigatorDB.copper >= 100 then
            ZoneNavigatorDB.silver = ZoneNavigatorDB.silver + math.floor(ZoneNavigatorDB.copper / 100)
            ZoneNavigatorDB.copper = ZoneNavigatorDB.copper % 100
        end

        if ZoneNavigatorDB.silver >= 100 then
            ZoneNavigatorDB.gold = ZoneNavigatorDB.gold + math.floor(ZoneNavigatorDB.silver / 100)
            ZoneNavigatorDB.silver = ZoneNavigatorDB.silver % 100
        end
    end

    if ZoneNavigator.mainFrame:IsShown() then
        ZoneNavigator.mainFrame.totalPlayerKills:SetText("Total Kills: " .. (ZoneNavigatorDB.kills or "0"))
        ZoneNavigator.mainFrame.totalCurrency:SetText("Gold: " .. (ZoneNavigatorDB.gold or "0") .. " Silver: " .. (ZoneNavigatorDB.silver or "0") .. " Copper: " .. (ZoneNavigatorDB.copper or "0"))
    end
end

-- Sets the event handler script for the event listener frame and registers it to listen for "COMBAT_LOG_EVENT_UNFILTERED" events.
eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventListenerFrame:RegisterEvent("CHAT_MSG_MONEY")
