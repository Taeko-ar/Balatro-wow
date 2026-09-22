local minimapBtn = CreateFrame("Button", "BalatroMinimapButton", Minimap)
minimapBtn:SetSize(32, 32)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(8)

local icon = minimapBtn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\INV_Inscription_TarotGreatness")
icon:SetSize(21, 21)
icon:SetPoint("TOPLEFT", 7, -6)

local border = minimapBtn:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(56, 56)
border:SetPoint("TOPLEFT", 0, 0)

minimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

minimapBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(45)), (80 * sin(45)) - 52)

minimapBtn:SetScript("OnClick", function()
    if SlashCmdList["BALATRO"] then
        SlashCmdList["BALATRO"]()
    end
end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Balatro", 1, 1, 1)
    GameTooltip:AddLine("Click to open Balatro.", nil, nil, nil, true)
    GameTooltip:Show()
end)

minimapBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local xpos, ypos = GetCursorPosition()
        local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
        xpos = xmin - xpos / UIParent:GetScale() + 70
        ypos = ypos / UIParent:GetScale() - ymin - 70
        local v = math.deg(math.atan2(ypos, xpos))
        if v < 0 then
            v = v + 360
        end
        self:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(v)), (80 * sin(v)) - 52)
    end)
end)

minimapBtn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)
