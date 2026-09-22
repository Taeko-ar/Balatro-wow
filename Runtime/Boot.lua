local _, Balatro = ...

local NATIVE_ROUND_STATES = {
    "BLIND_SELECT",
    "SELECTING_HAND",
    "HAND_PLAYED",
    "DRAW_TO_HAND",
    "NEW_ROUND",
    "ROUND_EVAL",
    "SHOP",
    "OPEN_BOOSTER",
    "GAME_OVER",
    "YOU_WIN",
}

local function isNativeRoundState(g)
    for _, name in ipairs(NATIVE_ROUND_STATES) do
        if g.STATE == g.STATES[name] then
            return true
        end
    end
    return false
end

local function drawEngine(label)
    _G.love.graphics._clearActive = false
    _G.love.graphics.clear()
    if not love.draw then
        return
    end
    _G.love.graphics._currentTransform = { x = 250, y = 0, sx = 1, sy = 1, originX = 0, originY = 0, r = 0 }
    local ok, err = pcall(love.draw)
    if not ok then
        DEFAULT_CHAT_FRAME:AddMessage("Balatro " .. label .. " error: " .. tostring(err))
    end
end

Balatro.Boot = function()
    local chunk, err = loadstring(BALATRO_MODULES["main"], "main")
    if not chunk then
        error("Balatro: cannot load main: " .. tostring(err))
    end
    chunk()
    if love.load then
        love.load()
    end

    local canvas = Balatro.Graphics.canvas
    local updateErrorLogged = false
    BalatroCanvas:SetScript("OnUpdate", function(_, elapsed)
        Balatro.Graphics.beginFrame()
        if love.update then
            local ok, updateErr = pcall(love.update, elapsed)
            if not ok and not updateErrorLogged then
                DEFAULT_CHAT_FRAME:AddMessage("Balatro update error: " .. tostring(updateErr))
                updateErrorLogged = true
            end
        end
        local g = _G.G
        if not g then
            return
        end
        local menu, round = BalatroMainMenu, BalatroRound
        if g.STATE == g.STATES.MENU then
            canvas:Hide()
            round:Hide()
            menu:Show()
        elseif isNativeRoundState(g) then
            canvas:Hide()
            menu:Hide()
            round:Show()
            if g.STATE ~= g.STATES.BLIND_SELECT then
                drawEngine("draw")
            end
        else
            menu:Hide()
            round:Hide()
            canvas:Show()
            canvas:SetAlpha(1)
            drawEngine("overlay draw")
        end
    end)
end
