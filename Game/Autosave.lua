local SAVE_STATES = { "SELECTING_HAND", "BLIND_SELECT", "SHOP", "ROUND_EVAL", "OPEN_BOOSTER" }
local SAVE_ON_ENTER = { BLIND_SELECT = true, SHOP = true, SELECTING_HAND = true }

local function inState(g, names)
    for _, name in ipairs(names) do
        if g.STATE == g.STATES[name] then
            return true
        end
    end
    return false
end

local function autosave()
    local g = _G.G
    if not (g and g.STATES and g.STAGE == g.STAGES.RUN) then
        return
    end
    if not inState(g, SAVE_STATES) or g:is_hand_scoring_active() then
        return
    end
    pcall(function()
        g:write_run_snapshot(g:build_run_snapshot())
    end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", autosave)
local lastState
frame:SetScript("OnUpdate", function()
    local g = _G.G
    local state = g and g.STATE
    if state == lastState then
        return
    end
    lastState = state
    for name in pairs(SAVE_ON_ENTER) do
        if g and state == g.STATES[name] then
            return autosave()
        end
    end
end)
