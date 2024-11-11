AdventureStats = AdventureStats or {}

if not AdventureStatsDB then
    AdventureStatsDB = {}
end

print("|cff00ff00Adventure Stats Successfully Loaded!|r")

local mainFrame = CreateFrame("Frame", "AdventureStatsMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(500, 350)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame.TitleBg:SetHeight(30)
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)
mainFrame.title:SetText("AdventureStats")
mainFrame:Hide()
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
mainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

-- Character name with class color
mainFrame.playerName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.playerName:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -35)
local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))] -- Retrieve class color
local classColorHex = ("|cFF%02x%02x%02x"):format(classColor.r * 255, classColor.g * 255, classColor.b * 255)
mainFrame.playerName:SetText("Character: " .. classColorHex .. UnitName("player") .. "|r (Level " .. UnitLevel("player") .. ")")

-- Total kills display, preset with red color
mainFrame.totalPlayerKills = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.totalPlayerKills:SetPoint("TOPLEFT", mainFrame.playerName, "BOTTOMLEFT", 0, -10)
mainFrame.totalPlayerKills:SetText("|cFFFF4500Total Kills: " .. (AdventureStatsDB.kills or "0") .. "|r")  -- Set initial red color

-- Total currency collected label
mainFrame.totalCurrency = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.totalCurrency:SetPoint("TOPLEFT", mainFrame.totalPlayerKills, "BOTTOMLEFT", 0, -10)
mainFrame.totalCurrency:SetText("Total Currency Collected:")

-- Gold, Silver, Copper labels, only set on OnShow to prevent duplication
mainFrame.currencyGold = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.currencyGold:SetPoint("TOPLEFT", mainFrame.totalCurrency, "BOTTOMLEFT", 10, -15)

mainFrame.currencySilver = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.currencySilver:SetPoint("TOPLEFT", mainFrame.currencyGold, "BOTTOMLEFT", 0, -15)

mainFrame.currencyCopper = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.currencyCopper:SetPoint("TOPLEFT", mainFrame.currencySilver, "BOTTOMLEFT", 0, -15)

-- Total items collected
-- mainFrame.totalItemsCollected = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- mainFrame.totalItemsCollected:SetPoint("TOPLEFT", mainFrame.totalPlayerKills, "BOTTOMLEFT", 0, -115)
-- mainFrame.totalItemsCollected:SetText("|cFF00FF00Total Items Collected: " .. (AdventureStatsDB.itemsCollected or "0"))


-- Set display values when the frame is shown
mainFrame:SetScript("OnShow", function()
    PlaySound(808)

    -- Set red color for Total Kills consistently
    mainFrame.totalPlayerKills:SetText("|cFFFF4500Total Kills: |cFFFFFFFF" .. (AdventureStatsDB.kills or "0"))

    -- Set colors for currency display
    mainFrame.currencyGold:SetText("|cFFFFD700Gold: |cFFFFFFFF" .. (AdventureStatsDB.gold or "0"))
    mainFrame.currencySilver:SetText("|cFFB0E0E6Silver: |cFFFFFFFF" .. (AdventureStatsDB.silver or "0"))
    mainFrame.currencyCopper:SetText("|cFFEDC9AFCopper: |cFFFFFFFF" .. (AdventureStatsDB.copper or "0"))

    -- Set color for items collected
    --mainFrame.totalItemsCollected:SetText("|cFF00FF00Items Collected: |cFFFFFFFF" .. (AdventureStatsDB.itemsCollected or "0"))
end)

SLASH_ADVENTURESTATS1 = "/as"
SlashCmdList["ADVENTURESTATS"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

SLASH_ADVENTURESTATS2 = "/asconfig"
SlashCmdList["ADVENTURESTATS2"] = function()
    if settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        settingsFrame:Show()
    end
end

table.insert(UISpecialFrames, "AdventureStatsMainFrame")

local eventListenerFrame = CreateFrame("Frame", "AdventureStatsEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)
    local _, eventType = CombatLogGetCurrentEventInfo()

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if eventType and eventType == "PARTY_KILL" then
            if not AdventureStatsDB.kills then
                AdventureStatsDB.kills = 1
            else
                AdventureStatsDB.kills = AdventureStatsDB.kills + 1
            end
        end
    elseif event == "CHAT_MSG_MONEY" then
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
end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventListenerFrame:RegisterEvent("CHAT_MSG_MONEY")
eventListenerFrame:RegisterEvent("BAG_UPDATE")
eventListenerFrame:RegisterEvent("MERCHANT_UPDATE")

function AdventureStats:ToggleMainFrame()
    if not mainFrame:IsShown() then
        mainFrame:Show()
    else
        mainFrame:Hide()
    end
end
