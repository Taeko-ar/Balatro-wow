local AddOnName, Balatro = ...

local FONT = "Interface\\AddOns\\Balatro\\Assets\\fonts\\m6x11plus.ttf"
local TEX = "Interface\\AddOns\\Balatro\\Assets\\textures\\1x\\"

local C = {
    panel = { 0x3A, 0x50, 0x55 },
    dark = { 0x1E, 0x2B, 0x2D },
    grey = { 0x70, 0x83, 0x86 },
    blue = { 0x00, 0x93, 0xFF },
    orange = { 0xFF, 0x98, 0x00 },
    red = { 0xFF, 0x4C, 0x40 },
    green = { 0x42, 0x9F, 0x79 },
    backBar = { 0xFF, 0x98, 0x00 },
    white = { 0xFF, 0xFF, 0xFF },
    text = { 0x4F, 0x63, 0x67 },
    edge = { 0xB9, 0xC2, 0xD2 },
}
local function rgb(c, a)
    return c[1] / 255, c[2] / 255, c[3] / 255, a or 1
end
local function darken(c, f)
    return { c[1] * f, c[2] * f, c[3] * f }
end
local function shown(f, on)
    if on then
        f:Show()
    else
        f:Hide()
    end
end

local MainMenu = CreateFrame("Frame", "BalatroMainMenu", BalatroCanvas)
MainMenu:SetAllPoints()
MainMenu:SetFrameLevel(MainMenu:GetParent():GetFrameLevel() + 10)
MainMenu:EnableMouse(true)

local function rect(parent, x, y, w, h, color, alpha, layer)
    local t = parent:CreateTexture(nil, layer or "BACKGROUND")
    t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    t:SetSize(w, h)
    t:SetColorTexture(rgb(color, alpha))
    return t
end

local function text(parent, x, y, w, size, color, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(FONT, size, "")
    if color ~= C.text then
        fs:SetShadowColor(0, 0, 0, 0.6)
        fs:SetShadowOffset(2, -2)
    end
    fs:SetTextColor(rgb(color or C.white))
    fs:SetJustifyH(justify or "CENTER")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    fs:SetWidth(w)
    return fs
end

local function button(parent, x, y, w, h, color, label, size, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    b:SetSize(w, h)
    b.bg = b:CreateTexture(nil, "BACKGROUND")
    b.bg:SetAllPoints()
    b.bg:SetColorTexture(rgb(color))
    local shadow = b:CreateTexture(nil, "BORDER")
    shadow:SetPoint("BOTTOMLEFT")
    shadow:SetPoint("BOTTOMRIGHT")
    shadow:SetHeight(5)
    shadow:SetColorTexture(0, 0, 0, 0.35)
    b.label = b:CreateFontString(nil, "OVERLAY")
    b.label:SetFont(FONT, size, "")
    b.label:SetShadowColor(0, 0, 0, 0.6)
    b.label:SetShadowOffset(2, -2)
    b.label:SetPoint("CENTER", 0, 2)
    b.label:SetText(label)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.12)
    b:SetScript("OnClick", function(...)
        if love and love.audio then
            love.audio.newSource("Assets/sounds/button.ogg", "static"):play()
        end
        if onClick then
            onClick(...)
        end
    end)
    return b
end

local function cell(tex, file, cw, ch, index, cols, pw, ph)
    local col, row = index % cols, math.floor(index / cols)
    tex:SetTexture(TEX .. file)
    tex:SetTexCoord(col * cw / pw, (col + 1) * cw / pw, row * ch / ph, (row + 1) * ch / ph)
end

local function padded(file)
    local d = _G.BalatroImageDimensions and _G.BalatroImageDimensions[TEX .. file]
    return d
end

local function G()
    return _G.G
end
local function menuUI()
    return package.loaded and package.loaded["main_menu_ui"]
end

local bg = MainMenu:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture(TEX .. "menu.tga")
local frameTimer, frameIdx = 0, 0

local Title = CreateFrame("Frame", nil, MainMenu)
Title:SetAllPoints()

local logo = Title:CreateTexture(nil, "ARTWORK")
logo:SetPoint("TOPLEFT", Title, "TOPLEFT", 262, -57)
logo:SetSize(336 * 2.25, 216 * 2.25)
logo:SetTexture(TEX .. "balatro_alt.tga")
local logoCard = Title:CreateTexture(nil, "OVERLAY")
logoCard:SetPoint("TOPLEFT", Title, "TOPLEFT", 569, -197)
logoCard:SetSize(142, 187)
local logoRank = Title:CreateTexture(nil, "OVERLAY")
logoRank:SetAllPoints(logoCard)

local version = text(Title, 1000, 40, 200, 16, C.white, "RIGHT")
version:SetText((C_AddOns.GetAddOnMetadata(AddOnName, "Version") or "") .. "-WOW")

rect(Title, 82, 580, 134, 96, C.panel)
text(Title, 82, 590, 134, 22, C.white):SetText("Profile")
local profileBtn = button(Title, 94, 618, 110, 44, C.grey, "P1", 26, function()
    local g = G()
    if not (g and g.switch_profile) then
        return
    end
    local n = g:get_profile_count() or 1
    g:switch_profile((g:get_profile_id() or 1) % n + 1)
end)

rect(Title, 262, 568, 756, 108, C.panel)
button(Title, 272, 578, 202, 86, C.blue, "PLAY", 44, function()
    local g = G()
    local m = menuUI()
    if g and m then
        m.open_deck_select(g)
    end
end)
button(Title, 487, 582, 146, 78, C.orange, "OPTIONS", 26, function()
    if Balatro.UI then
        Balatro.UI.options()
    end
end)
button(Title, 647, 582, 146, 78, C.red, "QUIT", 26, function()
    if _G.BalatroCanvas then
        _G.BalatroCanvas:Hide()
    end
end)
button(Title, 806, 578, 202, 86, C.green, "COLLECTION", 30, function()
    if Balatro.UI then
        Balatro.UI.collection()
    end
end)

local Run = CreateFrame("Frame", nil, MainMenu)
Run:SetAllPoints()
Run:SetFrameLevel(MainMenu:GetFrameLevel() + 5)
Run:EnableMouse(true)
rect(Run, 0, 0, 1280, 720, { 0, 0, 0 }, 0.45)
rect(Run, 335, 50, 610, 610, C.edge, 1, "BORDER")
rect(Run, 339, 54, 602, 602, C.panel, 1, "ARTWORK")

local runTab = "new"
local tabNew = button(Run, 423, 80, 138, 46, C.red, "New Run", 26, function()
    runTab = "new"
end)
local tabContinue = button(Run, 571, 80, 138, 46, C.red, "Continue", 26, function()
    local g = G()
    if g and g.has_saved_run and g:has_saved_run() then
        g._menu_sub_state = nil
        g:continue_saved_run_from_main_menu()
    end
end)
local tabChallenges = button(Run, 719, 80, 138, 46, C.red, "Challenges", 26, function()
    runTab = "challenges"
end)

local deckFrame = CreateFrame("Frame", nil, Run)
deckFrame:SetAllPoints()
rect(deckFrame, 437, 155, 406, 170, C.dark)
local deckBack = deckFrame:CreateTexture(nil, "ARTWORK")
deckBack:SetPoint("TOPLEFT", deckFrame, "TOPLEFT", 448, -163)
deckBack:SetSize(108, 143)
rect(deckFrame, 567, 163, 236, 150, C.panel, 1, "BORDER")
local deckName = text(deckFrame, 567, 172, 236, 28, C.white)
rect(deckFrame, 574, 208, 222, 98, C.white, 1, "ARTWORK")
local deckDesc = text(deckFrame, 580, 222, 210, 20, C.text)
local deckLock = text(deckFrame, 448, 220, 108, 20, C.white)

rect(deckFrame, 437, 363, 406, 92, C.dark)
local stakeChip = deckFrame:CreateTexture(nil, "ARTWORK")
stakeChip:SetPoint("TOPLEFT", deckFrame, "TOPLEFT", 462, -381)
stakeChip:SetSize(56, 56)
rect(deckFrame, 525, 368, 312, 82, C.panel, 1, "BORDER")
local stakeName = text(deckFrame, 525, 373, 312, 22, C.white)
rect(deckFrame, 530, 398, 302, 46, C.white, 1, "ARTWORK")
local stakeDesc = text(deckFrame, 534, 404, 294, 18, C.text)

local function step(field, defs, delta)
    local g = G()
    if not g or #(defs or {}) == 0 then
        return
    end
    local cur = tonumber(g[field]) or 1
    g[field] = ((cur - 1 + delta) % #defs) + 1
end

button(deckFrame, 392, 212, 36, 56, C.red, "<", 30, function()
    step("_deck_select_idx", _G.DECK_DEFS, -1)
end)
button(deckFrame, 852, 212, 36, 56, C.red, ">", 30, function()
    step("_deck_select_idx", _G.DECK_DEFS, 1)
end)
button(deckFrame, 392, 381, 36, 56, C.red, "<", 30, function()
    step("_stake_select_idx", _G.STAKE_DEFS, -1)
end)
button(deckFrame, 852, 381, 36, 56, C.red, ">", 30, function()
    step("_stake_select_idx", _G.STAKE_DEFS, 1)
end)

local playBtn = button(Run, 498, 524, 280, 60, C.blue, "PLAY", 44, function()
    local g = G()
    local m = menuUI()
    if g and m and m._start_run then
        m._start_run(g)
    end
end)
button(Run, 347, 614, 576, 36, C.backBar, "Back", 26, function()
    local g = G()
    if g then
        g._menu_sub_state = nil
    end
end)

local CH = CreateFrame("Frame", nil, Run)
CH:SetAllPoints()
CH:SetFrameLevel(Run:GetFrameLevel() + 2)
CH:Hide()
local chLocked = CreateFrame("Frame", nil, CH)
chLocked:SetAllPoints()
text(chLocked, 339, 200, 602, 44, C.white):SetText("Locked")
local chLockText = text(chLocked, 359, 260, 562, 26, C.white)
local chLockCount = text(chLocked, 339, 380, 602, 52, C.orange)
local chOpen = CreateFrame("Frame", nil, CH)
chOpen:SetAllPoints()
rect(chOpen, 351, 140, 240, 400, C.dark)
rect(chOpen, 601, 140, 328, 370, C.dark)
local CH_PER_PAGE = 10
local chPage, chSel = 1, nil
local chRows = {}
for i = 1, CH_PER_PAGE do
    local b = button(chOpen, 359, 148 + (i - 1) * 38, 224, 32, C.red, "", 20, function(self)
        if self.id then
            chSel = self.id
        end
    end)
    chRows[i] = b
end
local chPageText = text(chOpen, 395, 540, 150, 22, C.white)
button(chOpen, 355, 536, 36, 30, C.red, "<", 22, function()
    chPage = chPage - 1
end)
button(chOpen, 551, 536, 36, 30, C.red, ">", 22, function()
    chPage = chPage + 1
end)
local chDone = text(chOpen, 339, 574, 602, 20, C.white)
local chName = text(chOpen, 605, 150, 320, 28, C.white)
local chBody = text(chOpen, 613, 186, 304, 15, C.white, "LEFT")
chBody:SetSpacing(3)
local chPlay = button(chOpen, 640, 520, 250, 46, C.blue, "PLAY", 34, function()
    local g, CHM = G(), Balatro.Challenges
    if g and CHM and chSel then
        CHM.start(g, chSel)
    end
end)

local function defName(id)
    local CHM = Balatro.Challenges
    local key = id
    for pcId, ours in pairs({ j_golden = "j_golden_joker", j_selzer = "j_seltzer", v_nacho_tong = "v_nacho" }) do
        if id == pcId then
            key = ours
        end
    end
    local d = (_G.JOKER_DEFS and _G.JOKER_DEFS[key])
        or (_G.VOUCHER_DEFS and _G.VOUCHER_DEFS[key])
        or (_G.CONSUMABLE_DEFS and _G.CONSUMABLE_DEFS[key])
    if d and d.name then
        return d.name
    end
    if CHM and _G.CONSUMABLE_DEFS then
        local short = id:gsub("^c_", "")
        for _, prefix in ipairs({ "tarot_", "spectral_", "planet_" }) do
            local cd = _G.CONSUMABLE_DEFS[prefix .. (short == "heirophant" and "hierophant" or short)]
            if cd and cd.name then
                return cd.name
            end
        end
    end
    local g = G()
    local tag = g and g.P_TAGS and g.P_TAGS[id]
    if tag then
        return tag.name
    end
    local bl = g and g.P_BLINDS and g.P_BLINDS[id]
    if bl then
        return bl.name
    end
    return (id:gsub("^%a+_", ""):gsub("_", " "))
end

local function challengeText(ch)
    local CHM = Balatro.Challenges
    local out = {}
    local function add(s)
        out[#out + 1] = s
    end
    add("|cffff9800Rules|r")
    local any = false
    for _, r in ipairs(ch.rules and ch.rules.custom or {}) do
        add("- " .. CHM.ruleText(r))
        any = true
    end
    for _, r in ipairs(ch.rules and ch.rules.modifiers or {}) do
        add("- " .. CHM.ruleText(r))
        any = true
    end
    if not any then
        add("- None")
    end
    local items = {}
    for _, j in ipairs(ch.jokers or {}) do
        items[#items + 1] = defName(j.id)
            .. (j.edition and (" (" .. j.edition .. ")") or "")
            .. (j.eternal and " [Eternal]" or "")
    end
    for _, c in ipairs(ch.consumeables or {}) do
        items[#items + 1] = defName(c.id)
    end
    for _, v in ipairs(ch.vouchers or {}) do
        items[#items + 1] = defName(v.id)
    end
    if #items > 0 then
        add("|cffff9800Starting items|r")
        add(table.concat(items, ", "))
    end
    if ch.deck and ch.deck.cards then
        add("|cffff9800Deck|r")
        add(#ch.deck.cards .. " custom cards")
    end
    local bans = {}
    local rs = ch.restrictions or {}
    for _, list in ipairs({ rs.banned_cards or {}, rs.banned_tags or {}, rs.banned_other or {} }) do
        for _, v in ipairs(list) do
            bans[#bans + 1] = v.ids and (defName(v.id) .. " packs") or defName(v.id)
        end
    end
    if #bans > 0 then
        add("|cffff9800Banned|r")
        add(table.concat(bans, ", "))
    end
    return table.concat(out, "\n")
end

local function updateChallenges(g)
    local CHM = Balatro.Challenges
    if not CHM then
        return
    end
    local open = CHM.unlockedCount(g)
    shown(chLocked, open == 0)
    shown(chOpen, open > 0)
    if open == 0 then
        chLockText:SetText(
            "Win a run with at least\n" .. CHM.WINS_TO_UNLOCK .. " different decks to unlock\nChallenge mode"
        )
        chLockCount:SetText(CHM.deckWins(g) .. "/" .. CHM.WINS_TO_UNLOCK)
        return
    end
    local list = CHM.list()
    local pages = math.max(1, math.ceil(#list / CH_PER_PAGE))
    chPage = ((chPage - 1) % pages) + 1
    chPageText:SetText("Page " .. chPage .. "/" .. pages)
    chDone:SetText(CHM.completedCount(g) .. "/" .. #list .. " Challenges completed")
    for i, b in ipairs(chRows) do
        local idx = (chPage - 1) * CH_PER_PAGE + i
        local ch = list[idx]
        if ch then
            local unlocked = idx <= open
            b.id = unlocked and ch.id or nil
            b.label:SetText(
                unlocked and (ch.name .. (CHM.isCompleted(g, ch.id) and "  |cff35bd86done|r" or "")) or "Locked"
            )
            b.bg:SetColorTexture(rgb(not unlocked and C.grey or (chSel == ch.id and C.orange or C.red)))
            b:Show()
        else
            b:Hide()
        end
    end
    local ch = chSel and CHM.byId(chSel)
    chName:SetText(ch and ch.name or "Select a Challenge")
    chBody:SetText(ch and challengeText(ch) or "")
    shown(chPlay, ch ~= nil)
end

local function updateRunPanel(g)
    local decks, stakes = _G.DECK_DEFS or {}, _G.STAKE_DEFS or {}
    local d = decks[tonumber(g._deck_select_idx) or 1]
    local s = stakes[tonumber(g._stake_select_idx) or 1]
    local hasSave = g.has_saved_run and g:has_saved_run()
    tabContinue.bg:SetColorTexture(rgb(hasSave and C.red or C.grey))
    tabNew.bg:SetColorTexture(rgb(runTab == "new" and C.red or darken(C.red, 0.6)))
    tabChallenges.bg:SetColorTexture(rgb(runTab == "challenges" and C.red or darken(C.red, 0.6)))
    shown(CH, runTab == "challenges")
    shown(deckFrame, runTab == "new")
    shown(playBtn, runTab == "new")
    if runTab == "challenges" then
        updateChallenges(g)
        return
    end

    if d then
        local dim = padded("Enhancers.tga")
        if dim then
            cell(deckBack, "Enhancers.tga", 72, 95, tonumber(d.pos) or 0, math.floor(dim[1] / 72), dim[3], dim[4])
        end
        local unlocked = g:is_deck_unlocked(d.id)
        deckBack:SetDesaturated(not unlocked)
        deckName:SetText(d.name or "")
        deckDesc:SetText(
            unlocked and (d.description or "") or ((d.unlock_condition and d.unlock_condition.text) or "Locked")
        )
        deckLock:SetText(unlocked and "" or "LOCKED")
    end
    local stakeOk = false
    if s then
        cell(stakeChip, "chips.tga", 30, 30, tonumber(s.pos) or 0, 4, 128, 128)
        stakeOk = d and g:is_stake_unlocked(d.id, s.id) or false
        stakeChip:SetDesaturated(not stakeOk)
        stakeName:SetText(s.name or "")
        stakeDesc:SetText(stakeOk and (s.description or "") or "Locked: win with the previous Stake on this Deck")
    end
    local playable = d and g:is_deck_unlocked(d.id) and stakeOk
    playBtn.bg:SetColorTexture(rgb(playable and C.blue or C.grey))
end

local errorReported = false
MainMenu:SetScript("OnUpdate", function(self, elapsed)
    frameTimer = frameTimer + elapsed
    if frameTimer > 0.05 then
        frameTimer = 0
        frameIdx = (frameIdx + 1) % 63
        local col, row = frameIdx % 8, math.floor(frameIdx / 8)
        bg:SetTexCoord(col * 128 / 1024, (col + 1) * 128 / 1024, row * 128 / 1024, (row + 1) * 128 / 1024)
    end

    local ok, err = pcall(function()
        local g = G()
        if not g then
            return
        end
        local dim = padded("balatro_alt.tga")
        if dim then
            logo:SetTexCoord(0, dim[1] / dim[3], 0, dim[2] / dim[4])
        end
        local edim, rdim = padded("Enhancers.tga"), padded("8BitDeck_opt2.tga")
        if edim then
            cell(logoCard, "Enhancers.tga", 72, 95, 1, math.floor(edim[1] / 72), edim[3], edim[4])
        end
        if rdim then
            cell(logoRank, "8BitDeck_opt2.tga", 72, 95, 12 + 39, math.floor(rdim[1] / 72), rdim[3], rdim[4])
        end

        profileBtn.label:SetText("P" .. tostring(g.get_profile_id and g:get_profile_id() or 1))
        local inRun = g._menu_sub_state == "deck_select"
        if inRun then
            if not g._deck_select_idx then
                g._deck_select_idx = 1
            end
            if not g._stake_select_idx then
                g._stake_select_idx = 1
            end
            Run:Show()
            updateRunPanel(g)
        else
            Run:Hide()
        end
    end)
    if not ok and not errorReported then
        errorReported = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4040Balatro MainMenu error:|r " .. tostring(err))
    end
end)

Run:Hide()
MainMenu:Hide()

local Toast = CreateFrame("Frame", nil, BalatroCanvas)
Toast:SetSize(360, 84)
Toast:SetPoint("TOPRIGHT", BalatroCanvas, "TOPRIGHT", -20, -20)
Toast:SetFrameLevel(BalatroCanvas:GetFrameLevel() + 126)
rect(Toast, 0, 0, 360, 84, C.edge, 1, "BORDER")
rect(Toast, 4, 4, 352, 76, C.panel, 1, "ARTWORK")
local toastTitle = text(Toast, 4, 12, 352, 24, C.orange)
local toastBody = text(Toast, 4, 44, 352, 22, C.white)
Toast:Hide()
local toastQueue, toastUntil = {}, 0
local lastUnlocks, lastProfile
local pollTimer = 0
local unlockFrame = CreateFrame("Frame", nil, BalatroCanvas)
unlockFrame:SetScript("OnUpdate", function(_, elapsed)
    pollTimer = pollTimer + elapsed
    if Toast:IsShown() and GetTime() > toastUntil then
        Toast:Hide()
    end
    if not Toast:IsShown() and #toastQueue > 0 then
        local t = table.remove(toastQueue, 1)
        toastTitle:SetText(t[1])
        toastBody:SetText(t[2])
        toastUntil = GetTime() + 4
        Toast:Show()
    end
    if pollTimer < 1 then
        return
    end
    pollTimer = 0
    local g = G()
    if not (g and g.unlocks) then
        return
    end
    local now = {}
    for _, d in ipairs(_G.DECK_DEFS or {}) do
        local u = g.unlocks[d.id]
        if u then
            now["deck:" .. d.id] = u.unlocked == true and d.name or nil
            for _, s in ipairs(_G.STAKE_DEFS or {}) do
                local st = u.stakes and u.stakes[s.id]
                if st and st.unlocked then
                    now["stake:" .. d.id .. ":" .. s.id] = s.name .. " (" .. d.name .. ")"
                end
            end
        end
    end
    local profile = g.get_profile_id and g:get_profile_id()
    if lastUnlocks and profile == lastProfile then
        for key, name in pairs(now) do
            if not lastUnlocks[key] then
                local isDeck = key:sub(1, 5) == "deck:"
                toastQueue[#toastQueue + 1] = { isDeck and "Deck Unlocked!" or "Stake Unlocked!", name }
            end
        end
    end
    lastUnlocks, lastProfile = now, profile
end)
