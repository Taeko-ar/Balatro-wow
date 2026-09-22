local function say(text)
    DEFAULT_CHAT_FRAME:AddMessage("Balatro: " .. text)
end

local function addById(kind, method, id)
    local g = _G.G
    if not (g and g[method]) then
        return say("game not ready")
    end
    say((g[method](g, id) and "added " or "could not add ") .. kind .. " " .. id)
end

SLASH_BALATRO1 = "/balatro"
SlashCmdList["BALATRO"] = function(msg)
    msg = msg or ""
    if msg == "reset" then
        if love.load then
            love.load()
        end
        return say("reset to the main menu")
    end
    local joker = msg:match("^addjoker (.+)$")
    if joker then
        return addById("joker", "add_joker_by_def", joker)
    end
    local consumable = msg:match("^addconsumable (.+)$")
    if consumable then
        return addById("consumable", "add_consumable", consumable)
    end
    if BalatroCanvas:IsShown() then
        BalatroCanvas:Hide()
    else
        BalatroCanvas:Show()
    end
end

SLASH_BALATRODEBUG1 = "/balatrodebug"
SlashCmdList["BALATRODEBUG"] = function()
    BalatroDebug = not BalatroDebug
    if _G.G then
        _G.G.DEBUG = BalatroDebug
    end
    say("debug " .. (BalatroDebug and "on" or "off"))
end
