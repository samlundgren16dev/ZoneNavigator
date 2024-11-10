-- ZoneNavigator.lua

print("Zone Navigator successfully loaded!")

local mainframe = CreateFrame("Frame", "ZoneNavigatorMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainframe:SetSize(500, 350)
mainFrame:setPoint("CENTER", UIParent, "CENTER", 0, 0)
