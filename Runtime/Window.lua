local AddOnName, Balatro = ...

local CANVAS_W, CANVAS_H = 1280, 720
local TITLE_H = 32
local DEFAULT_HEIGHT = 0.6
local MIN_HEIGHT, MAX_HEIGHT = 0.3, 0.95

local rootFrame = CreateFrame("Frame", "BalatroCanvas", UIParent)
rootFrame:SetSize(CANVAS_W, CANVAS_H)
rootFrame:SetFrameStrata("HIGH")
rootFrame:SetToplevel(true)
rootFrame:SetMovable(true)
rootFrame:SetClampedToScreen(true)
rootFrame:SetClampRectInsets(0, 0, TITLE_H, 0)

local function savedLayout()
    BalatroProfile = BalatroProfile or {}
    BalatroProfile.window = BalatroProfile.window or {}
    return BalatroProfile.window
end

local function applyLayout(heightFrac, cx, cy)
    heightFrac = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, heightFrac))
    local scale = heightFrac * UIParent:GetHeight() / (CANVAS_H + TITLE_H)
    cy = cy or (UIParent:GetHeight() / 2 - TITLE_H / 2 * scale)
    rootFrame:SetScale(scale)
    rootFrame:ClearAllPoints()
    rootFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx / scale, cy / scale)
end

local function saveLayout()
    local scale = rootFrame:GetScale()
    local l, b = rootFrame:GetLeft(), rootFrame:GetBottom()
    if not l then
        return
    end
    local w = savedLayout()
    w.height = (CANVAS_H + TITLE_H) * scale / UIParent:GetHeight()
    w.x = (l + CANVAS_W / 2) * scale / UIParent:GetWidth()
    w.y = (b + CANVAS_H / 2) * scale / UIParent:GetHeight()
end

local function restoreLayout()
    local w = savedLayout()
    applyLayout(w.height or DEFAULT_HEIGHT, (w.x or 0.5) * UIParent:GetWidth(), w.y and w.y * UIParent:GetHeight())
end
Balatro.Window = { frame = rootFrame, restoreLayout = restoreLayout }

restoreLayout()
rootFrame:RegisterEvent("ADDON_LOADED")
rootFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
rootFrame:RegisterEvent("UI_SCALE_CHANGED")
rootFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 ~= AddOnName then
        return
    end
    restoreLayout()
end)

local chrome = CreateFrame("Frame", nil, rootFrame, "BackdropTemplate")
chrome:SetPoint("TOPLEFT", rootFrame, "TOPLEFT", -8, TITLE_H + 8)
chrome:SetPoint("BOTTOMRIGHT", rootFrame, "BOTTOMRIGHT", 8, -8)
chrome:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
chrome:SetBackdropColor(0.12, 0.14, 0.15, 1)
chrome:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
chrome:SetFrameLevel(rootFrame:GetFrameLevel())

local titleBar = CreateFrame("Frame", "BalatroWindowTitle", rootFrame)
titleBar:SetPoint("BOTTOMLEFT", rootFrame, "TOPLEFT", 0, 0)
titleBar:SetPoint("BOTTOMRIGHT", rootFrame, "TOPRIGHT", 0, 0)
titleBar:SetHeight(TITLE_H)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function()
    rootFrame:StartMoving()
end)
titleBar:SetScript("OnDragStop", function()
    rootFrame:StopMovingOrSizing()
    saveLayout()
end)
local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("LEFT", 12, 0)
titleText:SetText("Balatro")
local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
closeButton:SetPoint("RIGHT", titleBar, "RIGHT", 4, 0)
closeButton:SetScript("OnClick", function()
    rootFrame:Hide()
end)
rootFrame:HookScript("OnShow", function()
    if _G.BalatroSyncMusic then
        _G.BalatroSyncMusic()
    end
end)
rootFrame:HookScript("OnHide", function()
    if _G.BalatroSyncMusic then
        _G.BalatroSyncMusic()
    end
end)

local grip = CreateFrame("Button", nil, rootFrame)
grip:SetSize(48, 48)
grip:SetFrameLevel(rootFrame:GetFrameLevel() + 120)
grip:SetPoint("BOTTOMRIGHT", rootFrame, "BOTTOMRIGHT", 0, 0)
grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
grip:SetScript("OnMouseDown", function(self)
    local scale = rootFrame:GetScale()
    local left, top = rootFrame:GetLeft() * scale, (rootFrame:GetTop() + TITLE_H) * scale
    self:SetScript("OnUpdate", function()
        local cx, cy = GetCursorPosition()
        local ui = UIParent:GetEffectiveScale()
        cx, cy = cx / ui, cy / ui
        local hFromW = (cx - left) * (CANVAS_H + TITLE_H) / CANVAS_W
        local hFromH = top - cy
        local frac = math.max(hFromW, hFromH) / UIParent:GetHeight()
        frac = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, frac))
        local s = frac * UIParent:GetHeight() / (CANVAS_H + TITLE_H)
        rootFrame:SetScale(s)
        rootFrame:ClearAllPoints()
        rootFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left / s, top / s - TITLE_H)
    end)
end)
grip:SetScript("OnMouseUp", function(self)
    self:SetScript("OnUpdate", nil)
    saveLayout()
end)

local SETTING_DEFAULTS = {
    openFlightStart = false,
    openDeath = false,
    openLogIn = false,
    closeFlightEnd = false,
    closeReadyCheck = true,
    closeCombat = true,
    mouseOnTrans = 1,
    mouseOffTrans = 0.6,
}
local function settings()
    BalatroProfile = BalatroProfile or {}
    BalatroProfile.settings = BalatroProfile.settings or {}
    local s = BalatroProfile.settings
    for k, v in pairs(SETTING_DEFAULTS) do
        if s[k] == nil then
            s[k] = v
        end
    end
    return s
end
Balatro.Window.settings = settings

local FADE_TIME = 0.5
local fade = 0
local fader = CreateFrame("Frame", nil, rootFrame)
fader:SetScript("OnUpdate", function(_, elapsed)
    local s = settings()
    if rootFrame:IsMouseOver(TITLE_H + 8, -8, -8, 8) then
        fade = 0
    else
        fade = math.min(1, fade + elapsed / FADE_TIME)
    end
    rootFrame:SetAlpha(s.mouseOnTrans + (s.mouseOffTrans - s.mouseOnTrans) * fade)
end)

local flying = false
local autoFrame = CreateFrame("Frame")
autoFrame:RegisterEvent("PLAYER_LOGIN")
autoFrame:RegisterEvent("PLAYER_DEAD")
autoFrame:RegisterEvent("READY_CHECK")
autoFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
autoFrame:SetScript("OnEvent", function(_, event)
    local s = settings()
    if event == "PLAYER_LOGIN" then
        if s.openLogIn then
            rootFrame:Show()
        end
    elseif event == "PLAYER_DEAD" then
        if s.openDeath then
            rootFrame:Show()
        end
    elseif event == "READY_CHECK" then
        if s.closeReadyCheck then
            rootFrame:Hide()
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if s.closeCombat then
            rootFrame:Hide()
        end
    end
end)
autoFrame:SetScript("OnUpdate", function()
    local onTaxi = UnitOnTaxi("player") and true or false
    if onTaxi == flying then
        return
    end
    flying = onTaxi
    local s = settings()
    if flying and s.openFlightStart then
        rootFrame:Show()
    elseif not flying and s.closeFlightEnd then
        rootFrame:Hide()
    end
end)
