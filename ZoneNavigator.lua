-- ZoneNavigator.lua

if not MyAddonDB then
    MyAddonDB = {}
end

print("Zone Navigator successfully loaded!")

local mainFrame = CreateFrame("Frame", "ZoneNavigatorMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(500, 350)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)  -- Corrected capitalization
mainFrame.TitleBg:SetHeight(30)  -- Added colon for method call
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)  -- Corrected capitalization
mainFrame.title:SetText("Zone Navigator")

mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

mainFrame:SetScript("OnShow", function()
    PlaySound(808)
end)

mainFrame:SetScript("OnHide", function()
    PlaySound(808)
end)

mainFrame.playerName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.playerName:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -35)
mainFrame.playerName:SetText("Character: " .. UnitName("player") .. " (Level " .. UnitLevel("player") .. ")")

SLASH_ZONENAVIGATOR1 = "/zonenavigator"
SlashCmdList["ZONENAVIGATOR"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

table.insert(UISpecialFrames, "ZoneNavigatorMainFrame")

local eventListenerFrame = CreateFrame("Frame", "ZoneNavigatorEventListenerFrame", UIParent)
local function eventHandler(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
    end
end
eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
