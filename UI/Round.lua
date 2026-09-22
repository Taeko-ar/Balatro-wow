local _, Balatro = ...

local FONT = "Interface\\AddOns\\Balatro\\Assets\\fonts\\m6x11plus.ttf"
local TEX = "Interface\\AddOns\\Balatro\\Assets\\textures\\1x\\"

local C = {
    panel = { 0x2E, 0x3A, 0x3C },
    panelDark = { 0x1B, 0x26, 0x29 },
    handBox = { 0x17, 0x23, 0x25 },
    scoreBox = { 0x1E, 0x2B, 0x2D },
    chips = { 0x00, 0x93, 0xFF },
    mult = { 0xFF, 0x4C, 0x40 },
    orange = { 0xFF, 0x98, 0x00 },
    sortOrange = { 0xFF, 0x9A, 0x00 },
    sortBox = { 0x91, 0x97, 0x98 },
    disabled = { 0x54, 0x54, 0x54 },
    handsNum = { 0x00, 0x8C, 0xF4 },
    discNum = { 0xF3, 0x49, 0x3F },
    anteNum = { 0xFF, 0x8F, 0x00 },
    money = { 0xF3, 0xB9, 0x58 },
    white = { 0xFF, 0xFF, 0xFF },
    felt = { 0x3C, 0x78, 0x5E },
    blind = {
        small = { 0x00, 0x68, 0xAD },
        big = { 0xA5, 0x6C, 0x00 },
        boss = { 0xB4, 0x44, 0x30 },
    },
}

local function shown(f, on)
    if on then
        f:Show()
    else
        f:Hide()
    end
end
local C_DISABLED_BTN = { 0x47, 0x53, 0x54 }
local C_DISABLED_TXT = { 0x6C, 0x7A, 0x7C }
local function fmtNum(v)
    local n = tonumber(v) or 0
    if n >= 1e11 then
        return (string.format("%.3e", n):gsub("e%+?0*", "e"))
    end
    if n ~= math.floor(n) and math.abs(n) < 1000 then
        return (string.format("%.1f", n):gsub("%.0$", ""))
    end
    local str = tostring(math.floor(n + 0.5))
    local out = str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (out:gsub("^,", ""):gsub("^%-,", "-"))
end
local function fitText(fs, str, maxW, size)
    fs:SetFont(FONT, size)
    fs:SetText(str)
    while fs:GetStringWidth() > maxW and size > 10 do
        size = size - 2
        fs:SetFont(FONT, size)
    end
end
local function rgb(c, a)
    return c[1] / 255, c[2] / 255, c[3] / 255, a or 1
end
local function darken(c, f)
    return { c[1] * f, c[2] * f, c[3] * f }
end

local RoundUI = CreateFrame("Frame", "BalatroRound", _G.BalatroCanvas or UIParent)
RoundUI:SetAllPoints()
RoundUI:SetFrameLevel(RoundUI:GetParent():GetFrameLevel() + 10)
RoundUI:EnableMouse(true)
RoundUI:Hide()
_G.BalatroRound = RoundUI

local overlays = {}
local function toggleOverlay(name)
    if overlays.toggle then
        overlays.toggle(name)
    end
end

local function rect(parent, x, y, w, h, color, alpha, layer)
    local t = parent:CreateTexture(nil, layer or "BACKGROUND")
    t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    t:SetSize(w, h)
    t:SetTexture(rgb(color, alpha))
    return t
end

local function text(parent, x, y, w, size, color, justify, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    fs:SetFont(FONT, size)
    fs:SetShadowColor(0, 0, 0, 0.6)
    fs:SetShadowOffset(2, -2)
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
    b.bg:SetTexture(rgb(color))
    b.shadow = b:CreateTexture(nil, "BORDER")
    b.shadow:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 0, 0)
    b.shadow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
    b.shadow:SetHeight(5)
    b.shadow:SetTexture(0, 0, 0, 0.35)
    b.label = b:CreateFontString(nil, "OVERLAY")
    b.label:SetFont(FONT, size or 26)
    b.label:SetShadowColor(0, 0, 0, 0.6)
    b.label:SetShadowOffset(2, -2)
    b.label:SetPoint("CENTER", 0, 2)
    b.label:SetText(label)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetTexture(1, 1, 1, 0.12)
    b:SetScript("OnClick", function(...)
        if love and love.audio then
            love.audio.newSource("Assets/sounds/button.ogg", "static"):play()
        end
        if onClick then
            onClick(...)
        end
    end)
    b.SetColor = function(self, c)
        self.bg:SetTexture(rgb(c))
    end
    return b
end

local function applyQuad(tex, atlas, quad)
    if not (atlas and atlas.image and atlas.image.path and quad) then
        tex:Hide()
        return false
    end
    local path = atlas.image.path
    local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[path]
    local pw = dim and dim[3] or quad.sw
    local ph = dim and dim[4] or quad.sh
    tex:SetTexture(path)
    tex:SetTexCoord(quad.x / pw, (quad.x + quad.w) / pw, quad.y / ph, (quad.y + quad.h) / ph)
    tex:Show()
    return true
end

local function applyImage(tex, image)
    if not (image and image.path) then
        tex:Hide()
        return false
    end
    local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[image.path]
    if not dim then
        tex:Hide()
        return false
    end
    tex:SetTexture(image.path)
    tex:SetTexCoord(0, dim[1] / dim[3], 0, dim[2] / dim[4])
    tex:Show()
    return true
end

local EDITION_TINT = { foil = { 0.62, 0.78, 1 }, holo = { 1, 0.55, 0.55 }, polychrome = { 1, 0.8, 1 } }

local function applyCell(tex, file, cellW, cellH, index, cols, pw, ph)
    local col, row = index % cols, math.floor(index / cols)
    tex:SetVertexColor(1, 1, 1)
    tex:SetTexture(TEX .. file)
    tex:SetTexCoord(col * cellW / pw, (col + 1) * cellW / pw, row * cellH / ph, (row + 1) * cellH / ph)
end

local FeltFrame = CreateFrame("Frame", nil, RoundUI:GetParent())
FeltFrame:SetAllPoints()
FeltFrame:SetFrameLevel(RoundUI:GetFrameLevel() - 1)
FeltFrame:Hide()
RoundUI:SetScript("OnShow", function()
    FeltFrame:Show()
end)
RoundUI:SetScript("OnHide", function()
    FeltFrame:Hide()
end)
local felt = rect(FeltFrame, 0, 0, 1280, 720, C.felt)
local swirl = FeltFrame:CreateTexture(nil, "BORDER")
swirl:SetAllPoints()
swirl:SetTexture(TEX .. "menu.tga")
swirl:SetDesaturated(true)
swirl:SetAlpha(0.22)
FeltFrame:SetScript("OnUpdate", function()
    local i = math.floor(GetTime() * 6) % 63
    local col, row = i % 8, math.floor(i / 8)
    swirl:SetTexCoord(col * 128 / 1024, (col + 1) * 128 / 1024, row * 128 / 1024, (row + 1) * 128 / 1024)
end)

local P = CreateFrame("Frame", nil, RoundUI)
P:SetAllPoints()

rect(RoundUI, 46, 0, 288, 720, C.panel, 1, "BORDER")

local BH = CreateFrame("Frame", nil, P)
BH:SetAllPoints()

local banner = rect(BH, 55, 55, 270, 40, C.blind.small)
local bannerText = text(BH, 55, 62, 270, 30, C.white)

local blindInfo = rect(BH, 55, 98, 270, 155, darken(C.blind.small, 0.55))
local blindChip = BH:CreateTexture(nil, "ARTWORK")
blindChip:SetPoint("TOPLEFT", BH, "TOPLEFT", 65, -140)
blindChip:SetSize(80, 80)
rect(BH, 155, 137, 160, 85, C.scoreBox, 1, "BORDER")
text(BH, 155, 143, 160, 16, C.white):SetText("Score at least")
local targetChip = BH:CreateTexture(nil, "ARTWORK")
targetChip:SetPoint("TOPLEFT", BH, "TOPLEFT", 190, -163)
targetChip:SetSize(26, 26)
applyCell(targetChip, "chips.tga", 30, 30, 1, 4, 128, 128)
local targetText = text(BH, 222, 162, 95, 32, C.mult, "LEFT")
local rewardText = text(BH, 155, 199, 160, 16, C.money)
local bossDesc = text(BH, 55, 101, 270, 14, C.white)
local function placeBlindInfo(boss)
    local dy = boss and 16 or 0
    blindChip:SetPoint("TOPLEFT", BH, "TOPLEFT", 65, -(140 + dy))
    shown(bossDesc, boss)
end
local chooseText = text(P, 55, 118, 270, 40, C.white)
chooseText:SetText("Choose your\nnext Blind")
chooseText:SetSpacing(4)

rect(P, 55, 262, 270, 50, C.panelDark)
text(P, 58, 268, 78, 20, C.white):SetText("Round\nscore")
rect(P, 137, 268, 183, 40, C.panel, 1, "BORDER")
local scoreChip = P:CreateTexture(nil, "ARTWORK")
scoreChip:SetPoint("TOPLEFT", P, "TOPLEFT", 200, -275)
scoreChip:SetSize(26, 26)
applyCell(scoreChip, "chips.tga", 30, 30, 1, 4, 128, 128)
local roundScoreText = text(P, 232, 272, 90, 34, C.white, "LEFT")

rect(P, 55, 320, 270, 135, C.handBox)
local handNameText = text(P, 55, 334, 270, 36, C.white)
local handLevelText = text(P, 250, 340, 70, 18, C.white, "LEFT")
rect(P, 62, 388, 110, 57, C.chips, 1, "BORDER")
local chipsText = text(P, 62, 398, 104, 42, C.white, "RIGHT")
text(P, 172, 400, 36, 34, C.mult):SetText("X")
rect(P, 208, 388, 110, 57, C.mult, 1, "BORDER")
local multText = text(P, 214, 398, 104, 42, C.white, "LEFT")

button(P, 62, 475, 85, 97, C.mult, "Run\nInfo", 24, function()
    toggleOverlay("runinfo")
end)
button(P, 62, 583, 85, 97, C.orange, "Options", 22, function()
    toggleOverlay("options")
end)

local function statBox(x, y, w, h, label, color)
    rect(P, x, y, w, h, C.panelDark)
    text(P, x, y + 5, w, 18, C.white):SetText(label)
    rect(P, x + 6, y + 26, w - 12, h - 32, C.panel, 1, "BORDER")
    return text(P, x, y + 29, w, 34, color)
end
local handsText = statBox(160, 470, 78, 64, "Hands", C.handsNum)
local discardsText = statBox(248, 470, 78, 64, "Discards", C.discNum)
rect(P, 160, 545, 166, 66, C.panelDark)
rect(P, 166, 551, 154, 54, C.panel, 1, "BORDER")
local moneyText = text(P, 166, 560, 154, 42, C.money)
local anteText = statBox(160, 620, 78, 66, "Ante", C.anteNum)
local roundText = statBox(248, 620, 78, 66, "Round", C.anteNum)

rect(RoundUI, 348, 40, 560, 145, { 0, 0, 0 }, 0.16, "BORDER")
local jokerCount = text(RoundUI, 357, 188, 60, 18, C.white, "LEFT")
rect(RoundUI, 920, 40, 262, 145, { 0, 0, 0 }, 0.16, "BORDER")
local consumableCount = text(RoundUI, 1110, 188, 70, 18, C.white, "RIGHT")
local R = CreateFrame("Frame", nil, RoundUI)
R:SetAllPoints()
rect(R, 352, 535, 688, 145, { 0, 0, 0 }, 0.16, "BORDER")
local handCount = text(R, 647, 583, 100, 18, C.white)

local deckBack = RoundUI:CreateTexture(nil, "ARTWORK")
deckBack:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", 1062, -527)
deckBack:SetSize(108, 143)
local deckCount = text(RoundUI, 1080, 681, 100, 18, C.white, "RIGHT")
local deckBtn = CreateFrame("Button", nil, RoundUI)
deckBtn:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", 1062, -527)
deckBtn:SetSize(108, 143)
deckBtn:SetFrameLevel(RoundUI:GetFrameLevel() + 12)
deckBtn:SetScript("OnClick", function()
    local g = _G.G
    if g and g.toggle_deck_view then
        g:toggle_deck_view()
    end
end)

local function hand()
    return _G.G and _G.G.hand
end

local playBtn = button(R, 486, 600, 136, 75, C.chips, "Play Hand", 26, function()
    local h = hand()
    if h and h:has_selection() then
        h:play_selected()
    end
end)
local discardBtn = button(R, 770, 600, 136, 75, C.mult, "Discard", 26, function()
    local h = hand()
    if h and h:has_selection() then
        h:discard_selected()
    end
end)
rect(R, 632, 600, 128, 80, C.sortBox, 1, "BORDER")
rect(R, 636, 604, 120, 72, C.panel, 1, "ARTWORK")
text(R, 632, 606, 128, 18, C.white):SetText("Sort Hand")
button(R, 642, 628, 52, 38, C.sortOrange, "Rank", 18, function()
    local h = hand()
    if h then
        h:sort_by_rank()
    end
end):SetFrameLevel(RoundUI:GetFrameLevel() + 2)
button(R, 700, 628, 52, 38, C.sortOrange, "Suit", 18, function()
    local h = hand()
    if h then
        h:sort_by_suit()
    end
end):SetFrameLevel(RoundUI:GetFrameLevel() + 2)

local CARD_W, CARD_H = 108, 143
local hoverBtn
local btnOfNode = {}

local dragInfo, dragEndedAt = nil, 0
local function cursorCanvas()
    local x, y = GetCursorPosition()
    local s = RoundUI:GetEffectiveScale()
    return x / s - RoundUI:GetLeft(), RoundUI:GetTop() - y / s
end
local function beginDrag(self)
    if not (self.dragKind and self.node) then
        return
    end
    local g = _G.G
    if g and g.hand and g.hand._play_sequence then
        return
    end
    local cx, cy = cursorCanvas()
    local bx, by = self:GetLeft() - RoundUI:GetLeft(), RoundUI:GetTop() - self:GetTop()
    dragInfo = { kind = self.dragKind, node = self.node, dx = cx - bx, dy = cy - by }
end
local function endDrag(self)
    local info = dragInfo
    dragInfo, dragEndedAt = nil, GetTime()
    local g = _G.G
    if not (info and g) then
        return
    end
    local cx = cursorCanvas()
    local list = (info.kind == "hand") and (g.hand and g.hand.card_nodes) or g.jokers
    if not list then
        return
    end
    local from
    for i, n in ipairs(list) do
        if n == info.node then
            from = i
        end
    end
    if not from then
        return
    end
    local centres = (info.kind == "hand") and self.pool.centres or self.pool.centres
    local to = 1
    for i, c in ipairs(centres or {}) do
        if i ~= from and c < cx then
            to = to + 1
        end
    end
    to = math.max(1, math.min(#list, to))
    if to == from then
        return
    end
    if info.kind == "hand" then
        table.remove(list, from)
        table.insert(list, to, info.node)
        g.hand:sync_cards_from_nodes()
    else
        local step = to > from and 1 or -1
        for i = from, to - step, step do
            g:swap_jokers_at_indices(i, i + step)
        end
    end
end

local function captureTooltip(fn)
    local TD = package.loaded and package.loaded["tooltip_draw"]
    if type(TD) ~= "table" then
        return nil
    end
    local orig, cap = TD.draw_tooltip_layout, nil
    TD.draw_tooltip_layout = function(_, title, lines)
        cap = { title = title, lines = lines }
    end
    local ok = pcall(fn, TD)
    TD.draw_tooltip_layout = orig
    return ok and cap or nil
end
local CONSUMABLE_PILLS = {
    tarot = { "Tarot", { 0xA7, 0x82, 0xD1 } },
    planet = { "Planet", { 0x13, 0xAF, 0xCE } },
    spectral = { "Spectral", { 0x45, 0x84, 0xFA } },
}
local RANK_NAMES = { [11] = "Jack", [12] = "Queen", [13] = "King", [14] = "Ace" }
local function segs(TD, str)
    return TD.build_segments_from_text(str)
end

local function nodeTip(node)
    return function()
        local TD = package.loaded and package.loaded["tooltip_draw"]
        if type(TD) ~= "table" or not node then
            return nil
        end
        if node.rank_quad or node.face_quad then
            local d = node.card_data or {}
            if node.enhancement == "stone" then
                return { title = "Stone Card", lines = { segs(TD, "+50 chips") } }
            end
            local rank = tonumber(d.rank)
            local base = (rank == 14 and 11) or ((rank or 0) >= 11 and 10) or (rank or 0)
            local chipBonus, multBonus = 0, 0
            if _G.G and _G.G.hand and _G.G.hand.get_modifier_bonus then
                chipBonus, multBonus = _G.G.hand:get_modifier_bonus(d)
            end
            local chips = base + math.floor(tonumber(d.Bonus) or tonumber(d.bonus) or 0) + (tonumber(chipBonus) or 0)
            local lines = { segs(TD, "+" .. chips .. " chips") }
            if (tonumber(multBonus) or 0) > 0 then
                lines[#lines + 1] = segs(TD, "+" .. multBonus .. " Mult")
            end
            return {
                title = (RANK_NAMES[rank] or tostring(rank or "?")) .. " of " .. tostring(d.suit or "?"),
                lines = lines,
            }
        end
        if node.get_tooltip_body_lines and not node.front_sprite and not node.back_quad then
            local lines = {}
            for _, l in ipairs(node:get_tooltip_body_lines() or {}) do
                lines[#lines + 1] = segs(TD, tostring(l))
            end
            local def = node.def or {}
            local pill = CONSUMABLE_PILLS[def.kind or ""]
            if pill then
                lines[#lines + 1] = { { rarity_badge = true, text = pill[1], color = pill[2] } }
            end
            return { title = node.name or def.name or "Consumable", lines = lines }
        end
        local cap = captureTooltip(function()
            node:draw_tooltip(0, 0)
        end)
        if cap and cap.title == "Not Discovered" then
            cap.title = node.name or (node.def and node.def.name) or cap.title
        end
        return cap
    end
end
local cardPool, jokerPool, consPool = {}, {}, {}

local function tagTip(tagType)
    return function()
        local TD = package.loaded and package.loaded["tooltip_draw"]
        if type(TD) ~= "table" or not tagType then
            return nil
        end
        local CC = package.loaded["collection_catalog"]
        local key = type(CC) == "table" and CC.TAG_KEY_FROM_TYPE and CC.TAG_KEY_FROM_TYPE[tagType]
        local def = key and _G.G and _G.G.P_TAGS and _G.G.P_TAGS[key]
        local name = (def and def.name) or (tagType:sub(1, 1):upper() .. tagType:sub(2) .. " Tag")
        local desc = (_G.Tag and _G.Tag.get_description) and _G.Tag.get_description(tagType) or ""
        return { title = name, lines = TD.resolved_lines_from_multiline(desc) }
    end
end

local function newSpriteButton(pool, i, onClick, parent)
    local b = pool[i]
    if b then
        return b
    end
    b = CreateFrame("Button", nil, parent or RoundUI)
    b:SetSize(CARD_W, CARD_H)
    b.base = b:CreateTexture(nil, "ARTWORK")
    b.base:SetAllPoints()
    b.over = b:CreateTexture(nil, "OVERLAY")
    b.over:SetAllPoints()
    b.seal = b:CreateTexture(nil, "OVERLAY")
    b.seal:SetAllPoints()
    b.shine = b:CreateTexture(nil, "OVERLAY")
    b.shine:SetAllPoints()
    b.shine:SetTexture(1, 1, 1, 1)
    b.shine:SetBlendMode("ADD")
    b.shine:Hide()
    b.debuff = b:CreateFontString(nil, "OVERLAY")
    b.debuff:SetFont(FONT, 90)
    b.debuff:SetTextColor(1, 0.25, 0.2, 0.8)
    b.debuff:SetPoint("CENTER")
    b.debuff:SetText("X")
    b:SetScript("OnClick", function(self, ...)
        if GetTime() - dragEndedAt < 0.15 then
            return
        end
        if onClick then
            onClick(self, ...)
        end
    end)
    b.pool = pool
    if pool == cardPool or pool == jokerPool then
        b:RegisterForDrag("LeftButton")
    end
    b:SetScript("OnDragStart", beginDrag)
    b:SetScript("OnDragStop", endDrag)
    b:SetScript("OnEnter", function(self)
        hoverBtn = self
    end)
    b:SetScript("OnLeave", function(self)
        if hoverBtn == self then
            hoverBtn = nil
        end
    end)
    pool[i] = b
    return b
end

local SHINE = { foil = { 0.25, 0.55, 1 }, holo = { 1, 0.2, 0.35 } }
local function applyEdition(b, edition)
    if edition ~= "foil" and edition ~= "holo" and edition ~= "polychrome" then
        b.shine:Hide()
        return
    end
    local t = GetTime()
    local c = SHINE[edition]
    if not c then
        c = { 0.5 + 0.5 * math.sin(t * 2.2), 0.5 + 0.5 * math.sin(t * 2.2 + 2.1), 0.5 + 0.5 * math.sin(t * 2.2 + 4.2) }
    end
    local p = 0.5 + 0.5 * math.sin(t * 1.6)
    b.shine:SetGradientAlpha("HORIZONTAL", c[1], c[2], c[3], 0.10 + 0.30 * p, c[1], c[2], c[3], 0.40 - 0.30 * p)
    b.shine:Show()
end

local function drawCard(b, node)
    b.base:SetVertexColor(1, 1, 1)
    if node.face_up then
        if not applyQuad(b.base, node.face_atlas, node.face_quad) then
            applyQuad(b.base, node.back_atlas, node.back_quad)
        end
        applyQuad(b.over, node.rank_atlas, node.rank_quad)
        applyQuad(b.seal, node.seal_atlas, node.seal_quad)
    else
        applyQuad(b.base, node.back_atlas, node.back_quad)
        b.over:Hide()
        b.seal:Hide()
    end
    local mod = node.card_data and node.card_data.modifier
    applyEdition(b, node.face_up and mod and mod.edition or nil)
    local debuffed = _G.G.boss_is_card_debuffed_for_scoring and _G.G:boss_is_card_debuffed_for_scoring(node) == true
    if debuffed then
        b.debuff:Show()
    else
        b.debuff:Hide()
    end
end

local function drawNode(b, node)
    if node.rank_quad or node.face_quad then
        drawCard(b, node)
        return
    end
    b.seal:Hide()
    b.debuff:Hide()
    b.base:SetVertexColor(1, 1, 1)
    applyEdition(b, node.face_up ~= false and node.edition or nil)
    if node.front_sprite or node.back_quad then
        if node.face_up ~= false and node.front_sprite and applyImage(b.base, node.front_sprite.image) then
            local tint = EDITION_TINT[node.edition or ""]
            if tint then
                b.base:SetVertexColor(tint[1], tint[2], tint[3])
            end
            applyQuad(b.over, node.sub_atlas, node.sub_quad)
        else
            applyQuad(b.base, node.back_atlas, node.back_quad)
            b.over:Hide()
        end
    else
        applyQuad(b.base, node.atlas, node.quad)
        b.over:Hide()
    end
end

local function onCardClick(self)
    local h = hand()
    if h and self.node and not h._play_sequence then
        h:toggle_selection(self.node)
    end
end

local function spread(n, cx, maxW, step)
    if n <= 1 then
        return cx - CARD_W / 2, 0
    end
    step = math.min(step, (maxW - CARD_W) / (n - 1))
    return cx - ((n - 1) * step + CARD_W) / 2, step
end

local HAND_Y = 432
local function updateCards(g, handY)
    handY = handY or HAND_Y
    local h = g.hand
    local seq = h and h._play_sequence
    local played = {}
    if seq and seq.cards then
        for _, n in ipairs(seq.cards) do
            played[n] = true
        end
    end

    local inHand = {}
    for _, node in ipairs(h and h.card_nodes or {}) do
        if not played[node] then
            inHand[#inHand + 1] = node
        end
    end

    local used = 0
    local x0, step = spread(#inHand, 696, 688, 83)
    cardPool.centres = {}
    for i, node in ipairs(inHand) do
        used = used + 1
        local b = newSpriteButton(cardPool, used, onCardClick)
        b.node = node
        b.dragKind = (not seq) and "hand" or nil
        b.tipFn = nodeTip(node)
        cardPool.centres[i] = x0 + (i - 1) * step + CARD_W / 2
        b:ClearAllPoints()
        if dragInfo and dragInfo.node == node then
            local cx, cy = cursorCanvas()
            b:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", cx - dragInfo.dx, -(cy - dragInfo.dy))
        else
            local lift = (node.selected and 32 or 0) + ((hoverBtn == b and not seq) and 8 or 0)
            b:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", x0 + (i - 1) * step, -(handY - lift))
        end
        b:SetFrameLevel(RoundUI:GetFrameLevel() + 3 + i + ((dragInfo and dragInfo.node == node) and 20 or 0))
        btnOfNode[node] = b
        drawCard(b, node)
        b:Show()
    end

    if seq and seq.cards then
        local px, pstep = spread(#seq.cards, 696, 688, 123)
        for i, node in ipairs(seq.cards) do
            used = used + 1
            local b = newSpriteButton(cardPool, used, onCardClick)
            b.node = nil
            b.dragKind = nil
            b.tipFn = nil
            b:ClearAllPoints()
            b:SetPoint(
                "TOPLEFT",
                RoundUI,
                "TOPLEFT",
                px + (i - 1) * pstep,
                -(node.counts_for_play_score and 262 or 277)
            )
            b:SetFrameLevel(RoundUI:GetFrameLevel() + 3 + i)
            btnOfNode[node] = b
            drawCard(b, node)
            b:Show()
        end
    end

    for i = used + 1, #cardPool do
        cardPool[i]:Hide()
    end
    handCount:SetText(#inHand .. "/" .. (g.get_effective_hand_size_limit and g:get_effective_hand_size_limit() or 8))
end

local ownedSel
local function onOwnedClick(self)
    if ownedSel and ownedSel.kind == self.kind and ownedSel.i == self.slot then
        ownedSel = nil
    else
        ownedSel = { kind = self.kind, i = self.slot }
    end
end
local sellBtn = button(RoundUI, 0, 0, 96, 38, C.mult, "SELL", 20, function()
    local g = _G.G
    if g and ownedSel then
        g:perform_sell_for_target({ kind = ownedSel.kind, index = ownedSel.i })
    end
    ownedSel = nil
end)
local useBtn = button(RoundUI, 0, 0, 96, 38, { 0x35, 0xBD, 0x86 }, "USE", 20, function()
    local g = _G.G
    if g and ownedSel and ownedSel.kind == "consumable" and g:consumable_use_enabled(ownedSel.i) then
        g:use_consumable(ownedSel.i)
    end
    ownedSel = nil
end)
sellBtn:SetFrameLevel(RoundUI:GetFrameLevel() + 50)
useBtn:SetFrameLevel(RoundUI:GetFrameLevel() + 50)
sellBtn:Hide()
useBtn:Hide()

local function capacity(g, key, default)
    local v = g[key]
    if type(v) == "function" then
        v = v(g)
    end
    return tonumber(v) or default
end

local function updateJokers(g)
    local jokers = g.jokers or {}
    sellBtn._want, useBtn._want = false, false
    local busy = g.hand and g.hand._play_sequence
    if busy then
        ownedSel = nil
    end
    local function placeActions(x, kind, i, item)
        sellBtn:ClearAllPoints()
        sellBtn:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", x + CARD_W / 2 - 48, -(41 + CARD_H - 10))
        local value = (kind == "joker") and math.floor(tonumber(item.sell_cost) or 0)
            or math.floor(g:consumable_sell_value(g.consumables and g.consumables[i]) or 0)
        sellBtn.label:SetText("SELL $" .. value)
        sellBtn._want = true
        if kind == "consumable" then
            useBtn:ClearAllPoints()
            useBtn:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", x + CARD_W / 2 - 48, -(41 + CARD_H + 30))
            local ok = g:consumable_use_enabled(i)
            useBtn.bg:SetTexture(rgb(ok and { 0x35, 0xBD, 0x86 } or C_DISABLED_BTN))
            useBtn._want = true
        end
    end
    local x0, step = spread(#jokers, 628, 540, 118)
    for i, j in ipairs(jokers) do
        local b = newSpriteButton(jokerPool, i, onOwnedClick)
        b.kind, b.slot = "joker", i
        b.node, b.dragKind = j, "joker"
        b.tipFn = nodeTip(j)
        jokerPool.centres = jokerPool.centres or {}
        jokerPool.centres[i] = x0 + (i - 1) * step + CARD_W / 2
        local lifted = ownedSel and ownedSel.kind == "joker" and ownedSel.i == i
        b:ClearAllPoints()
        if dragInfo and dragInfo.node == j then
            local cx, cy = cursorCanvas()
            b:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", cx - dragInfo.dx, -(cy - dragInfo.dy))
        else
            b:SetPoint(
                "TOPLEFT",
                RoundUI,
                "TOPLEFT",
                x0 + (i - 1) * step,
                -((lifted and 28 or 41) - (hoverBtn == b and 6 or 0))
            )
        end
        if lifted then
            placeActions(x0 + (i - 1) * step, "joker", i, j)
        end
        b:SetFrameLevel(RoundUI:GetFrameLevel() + 3 + i)
        btnOfNode[j] = b
        drawNode(b, j)
        b:Show()
    end
    for i = #jokers + 1, #jokerPool do
        jokerPool[i]:Hide()
    end
    if jokerPool.centres then
        for i = #jokers + 1, #jokerPool.centres do
            jokerPool.centres[i] = nil
        end
    end
    local cons = g.consumable_nodes or {}
    local cx0, cstep = spread(#cons, 1051, 250, 118)
    for i, c in ipairs(cons) do
        local b = newSpriteButton(consPool, i, onOwnedClick)
        b.kind, b.slot = "consumable", i
        b.tipFn = nodeTip(c)
        local lifted = ownedSel and ownedSel.kind == "consumable" and ownedSel.i == i
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", cx0 + (i - 1) * cstep, -(lifted and 28 or 41))
        if lifted then
            placeActions(cx0 + (i - 1) * cstep, "consumable", i, c)
        end
        b:SetFrameLevel(RoundUI:GetFrameLevel() + 3 + i)
        drawNode(b, c)
        b:Show()
    end
    for i = #cons + 1, #consPool do
        consPool[i]:Hide()
    end
    shown(sellBtn, sellBtn._want)
    shown(useBtn, useBtn._want)
    jokerCount:SetText(#jokers .. "/" .. capacity(g, "joker_base_capacity", 5))
    consumableCount:SetText(#(g.consumables or {}) .. "/" .. capacity(g, "consumable_base_capacity", 2))
end

local BS = CreateFrame("Frame", nil, RoundUI)
BS:SetAllPoints()
BS:SetFrameLevel(RoundUI:GetFrameLevel() + 2)

local CARD_X = { 358, 594, 830 }
local BLIND_W = 206
local C_BLIND_BG = { 0x34, 0x47, 0x4C }
local C_BLIND_BG_ACTIVE = { 0x2C, 0x3D, 0x40 }
local C_INACTIVE_EDGE = { 0x4F, 0x63, 0x67 }

local function to255(c)
    return { (c[1] or 0) * 255, (c[2] or 0) * 255, (c[3] or 0) * 255 }
end

local function wasSkipped(g, i)
    return Balatro.skippedBlinds and Balatro.skippedBlinds[tostring(g.SEED) .. ":" .. tostring(g.ante) .. ":" .. i]
        or false
end

local function blindCard(i)
    local f = CreateFrame("Frame", nil, BS)
    f:SetWidth(BLIND_W)
    f.edge = f:CreateTexture(nil, "BACKGROUND")
    f.edge:SetAllPoints()
    f.bg = f:CreateTexture(nil, "BORDER")
    f.bg:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
    f.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 0)

    f.header = button(f, 28, 20, 150, 34, C.orange, "Select", 24, function()
        local g = _G.G
        if g and g:is_blind_selectable(i) then
            g.selected_blind_index = i
            g:start_selected_blind()
        end
    end)
    f.plateEdge = rect(f, 20, 69, 166, 32, C.panel, 1, "ARTWORK")
    f.plate = rect(f, 23, 72, 160, 26, C.panel, 1, "ARTWORK")
    f.name = text(f, 20, 74, 166, 24, C.white)
    f.name:SetDrawLayer("OVERLAY")
    f.chip = f:CreateTexture(nil, "ARTWORK")
    f.chip:SetPoint("TOPLEFT", f, "TOPLEFT", 66, -113)
    f.chip:SetSize(74, 74)
    f.desc = text(f, 8, 200, 190, 16, C.white)

    f.scoreFrame = CreateFrame("Frame", nil, f)
    f.scoreFrame:SetAllPoints()
    local sf = f.scoreFrame
    sf.box = rect(sf, 16, 0, 174, 82, C.scoreBox, 1, "ARTWORK")
    sf.label = text(sf, 16, 0, 174, 16, C.white)
    sf.label:SetText("Score at least")
    sf.chip = sf:CreateTexture(nil, "OVERLAY")
    sf.chip:SetSize(24, 24)
    applyCell(sf.chip, "chips.tga", 30, 30, 1, 4, 128, 128)
    sf.target = text(sf, 80, 0, 110, 32, C.mult, "LEFT")
    sf.reward = text(sf, 16, 0, 174, 16, C.money)
    sf.Place = function(self, y)
        self.box:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -y)
        self.label:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -(y + 8))
        self.chip:SetPoint("TOPLEFT", f, "TOPLEFT", 48, -(y + 31))
        self.target:SetPoint("TOPLEFT", f, "TOPLEFT", 78, -(y + 28))
        self.reward:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -(y + 60))
    end

    f.orText = text(f, 0, 296, BLIND_W, 24, C.white)
    f.orText:SetText("or")
    f.skip = CreateFrame("Frame", nil, f)
    f.skip:SetAllPoints()
    rect(f.skip, 16, 326, 174, 66, C.scoreBox, 1, "ARTWORK")
    f.tag = f.skip:CreateTexture(nil, "OVERLAY")
    f.tag:SetPoint("TOPLEFT", f, "TOPLEFT", 24, -338)
    f.tag:SetSize(42, 42)
    f.tagBtn = CreateFrame("Button", nil, f.skip)
    f.tagBtn:SetPoint("TOPLEFT", f, "TOPLEFT", 24, -338)
    f.tagBtn:SetSize(42, 42)
    f.tagBtn:SetScript("OnEnter", function(self)
        hoverBtn = self
    end)
    f.tagBtn:SetScript("OnLeave", function(self)
        if hoverBtn == self then
            hoverBtn = nil
        end
    end)
    f.skipBtn = button(f.skip, 72, 330, 110, 58, C.mult, "Skip Blind", 20, function()
        local g = _G.G
        if g and g:is_blind_selectable(i) and g.skips and g.skips[i] ~= nil and g:skip_blind(i) then
            Balatro.skippedBlinds = Balatro.skippedBlinds or {}
            Balatro.skippedBlinds[tostring(g.SEED) .. ":" .. tostring(g.ante) .. ":" .. i] = true
        end
    end)

    f.ante = CreateFrame("Frame", nil, f)
    f.ante:SetAllPoints()
    rect(f.ante, 22, 322, 162, 72, C.scoreBox, 1, "ARTWORK")
    text(f.ante, 0, 326, BLIND_W, 26, C.orange):SetText("Up the Ante")
    text(f.ante, 0, 354, BLIND_W, 16, C.white):SetText("Raise all Blinds")
    text(f.ante, 0, 373, BLIND_W, 16, C.white):SetText("Refresh Blinds")
    return f
end
local blindCards = { blindCard(1), blindCard(2), blindCard(3) }

local function tagCell(tex, tagType)
    local ok, tag = pcall(function()
        return _G.Tag and _G.Tag(tagType)
    end)
    local id = ok and tag and tonumber(tag.id)
    if not id then
        tex:Hide()
        return
    end
    local path = TEX .. "tags.tga"
    local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[path]
    if not dim then
        tex:Hide()
        return
    end
    applyCell(tex, "tags.tga", 34, 34, id, math.floor(dim[1] / 34), dim[3], dim[4])
    tex:Show()
end

local function updateBlindSelect(g)
    local current = tonumber(g.current_blind_index) or 1
    for i, f in ipairs(blindCards) do
        local def = g:get_blind_def(i)
        local isBoss = def and def.id == "boss"
        local active = i == current
        local top = active and 208 or 248
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", BS, "TOPLEFT", CARD_X[i], -top)
        f:SetHeight(720 - top)

        local bc = to255(g:get_blind_color(i))
        f.edge:SetTexture(rgb(active and bc or C.panel))
        f.bg:SetTexture(rgb(active and C_BLIND_BG_ACTIVE or C_BLIND_BG))

        local state = (i < current and (wasSkipped(g, i) and "Skipped" or "Defeated"))
            or (active and "Select")
            or "Upcoming"
        f.header.label:SetText(state)
        f.header:SetColor(active and C.orange or C_DISABLED_BTN)
        f.header.label:SetTextColor(rgb(active and C.white or C_DISABLED_TXT))
        if active then
            f.header:Enable()
        else
            f.header:Disable()
        end

        f.plateEdge:SetTexture(rgb(active and bc or C_INACTIVE_EDGE))
        f.plate:SetTexture(rgb(active and darken(bc, 0.55) or C.panel))
        f.name:SetText(g:get_blind_display_name(i) or (def and def.name) or "")

        local row = g:get_blind_sprite_index(i) or 0
        local frame = active and (math.floor(GetTime() * 10) % 21) or 0
        applyCell(f.chip, "BlindChips.tga", 36, 36, row * 21 + frame, 24, 1024, 1024)
        f.chip:SetDesaturated(i < current)

        f.scoreFrame:Place(isBoss and 240 or 200)
        fitText(f.scoreFrame.target, fmtNum(g:get_blind_target(i, g.ante)), 108, 32)
        local reward = g:get_blind_reward(i) or 0
        f.scoreFrame.reward:SetText(reward > 0 and ("Reward: " .. string.rep("$", reward) .. "+") or "No Reward")

        if isBoss then
            f.desc:SetText(g:get_blind_description(i) or "")
            f.desc:Show()
            f.ante:Show()
            f.orText:Hide()
            f.skip:Hide()
        else
            f.desc:Hide()
            f.ante:Hide()
            local skipId = g.skips and g.skips[i]
            local tagType = skipId ~= nil and g:tag_type_for_id(skipId)
            if tagType and i >= current then
                f.orText:Show()
                f.skip:Show()
                tagCell(f.tag, tagType)
                f.tagBtn.tipFn = tagTip(tagType)
                f.skipBtn:SetColor(active and C.mult or C_DISABLED_BTN)
                if active then
                    f.skipBtn:Enable()
                else
                    f.skipBtn:Disable()
                end
            else
                f.orText:Hide()
                f.skip:Hide()
            end
        end
    end
end

local EV, updateCashOut
do
    EV = CreateFrame("Frame", nil, RoundUI)
    EV:SetAllPoints()
    EV:SetFrameLevel(RoundUI:GetFrameLevel() + 2)
    rect(EV, 398, 248, 600, 472, C.panel)
    rect(EV, 404, 254, 588, 232, C.panelDark, 1, "BORDER")
    local cashBtn = button(EV, 502, 266, 388, 62, C.orange, "Cash Out", 44, function()
        local g = _G.G
        if g and g.STATE == g.STATES.ROUND_EVAL then
            g:continue_from_round_win()
        end
    end)
    local evChip = EV:CreateTexture(nil, "ARTWORK")
    evChip:SetPoint("TOPLEFT", EV, "TOPLEFT", 414, -352)
    evChip:SetSize(64, 64)
    text(EV, 494, 352, 200, 18, C.white, "LEFT"):SetText("Score at least")
    local evTargetChip = EV:CreateTexture(nil, "ARTWORK")
    evTargetChip:SetPoint("TOPLEFT", EV, "TOPLEFT", 506, -378)
    evTargetChip:SetSize(28, 28)
    applyCell(evTargetChip, "chips.tga", 30, 30, 1, 4, 128, 128)
    local evTarget = text(EV, 538, 374, 200, 36, C.mult, "LEFT")
    local evBlindPay = text(EV, 780, 380, 200, 26, C.money, "RIGHT")
    local evSep = text(EV, 410, 424, 570, 18, C.white)
    evSep:SetText(string.rep(". ", 42))

    local EV_ROWS = 6
    local evRows = {}
    for i = 1, EV_ROWS do
        local y = 448 + (i - 1) * 40
        evRows[i] = {
            num = text(EV, 408, y, 40, 32, C.handsNum, "LEFT"),
            label = text(EV, 442, y + 8, 440, 18, C.white, "LEFT"),
            pay = text(EV, 780, y + 6, 200, 26, C.money, "RIGHT"),
        }
    end

    local function payoutRow(label, amount)
        local n = label:match("^Hands left %((%d+)%)")
        if n then
            return n, "Remaining Hands ($1 each)"
        end
        if label:match("^Interest") then
            return tostring(amount),
                "Interest ($1 each $5" .. (label:match("max %$%d+") and (", " .. label:match("max %$%d+")) or "") .. ")"
        end
        return "", label
    end

    function updateCashOut(g)
        local lines = g._round_win_display_lines or {}
        local revealed = math.min(tonumber(g._round_win_lines_revealed) or 0, #lines)
        local total = 0
        for i = 1, revealed do
            total = total + math.max(0, math.floor(tonumber(lines[i][2]) or 0))
        end
        cashBtn.label:SetText("Cash Out: $" .. total)
        EV.total = total

        local idx = tonumber(g.current_blind_index) or 1
        local row = g:get_blind_sprite_index(idx) or 0
        applyCell(evChip, "BlindChips.tga", 36, 36, row * 21, 24, 1024, 1024)
        evTarget:SetText(fmtNum(g.current_blind_target))

        local first = lines[1]
        local blindPay = (first and revealed >= 1) and math.max(0, math.floor(tonumber(first[2]) or 0)) or 0
        evBlindPay:SetText(string.rep("$", blindPay))

        local shownLines = {}
        for i = 2, revealed do
            local line = lines[i]
            if line and math.floor(tonumber(line[2]) or 0) > 0 then
                shownLines[#shownLines + 1] = line
            end
        end
        for i = 1, EV_ROWS do
            local r, line = evRows[i], shownLines[i]
            if line then
                local amount = math.max(0, math.floor(tonumber(line[2]) or 0))
                local num, label = payoutRow(tostring(line[1] or ""), amount)
                r.num:SetText(num)
                r.label:SetText(label)
                r.pay:SetText(string.rep("$", amount))
            else
                r.num:SetText("")
                r.label:SetText("")
                r.pay:SetText("")
            end
        end
    end
end

local C_SHOP_RED = { 0xEA, 0x48, 0x3E }
local C_REROLL = { 0x35, 0xBD, 0x86 }
local C_AREA = { 0x34, 0x47, 0x4C }
local C_AREA_DARK = { 0x21, 0x2F, 0x31 }
local C_TAG = { 0x37, 0x40, 0x41 }

local SH = CreateFrame("Frame", nil, RoundUI)
SH:SetAllPoints()
SH:SetFrameLevel(RoundUI:GetFrameLevel() + 2)

local sign = CreateFrame("Frame", nil, RoundUI)
sign:SetAllPoints()
sign:SetFrameLevel(RoundUI:GetFrameLevel() + 2)
rect(sign, 55, 60, 270, 186, C_SHOP_RED)
rect(sign, 59, 64, 262, 178, C.scoreBox, 1, "BORDER")
local signAnim = sign:CreateTexture(nil, "ARTWORK")
signAnim:SetPoint("TOPLEFT", sign, "TOPLEFT", 72, -72)
signAnim:SetSize(236, 125)
text(sign, 55, 204, 270, 22, C.money):SetText("Improve your run!")

rect(SH, 368, 242, 656, 478, C_SHOP_RED)
rect(SH, 372, 246, 648, 474, C.panelDark, 1, "BORDER")
rect(SH, 552, 257, 458, 190, C_AREA, 1, "ARTWORK")
rect(SH, 394, 481, 302, 194, C_AREA_DARK, 1, "ARTWORK")
rect(SH, 710, 481, 290, 194, C_AREA, 1, "ARTWORK")
local voucherLabel = text(SH, 398, 486, 120, 14, C_DISABLED_TXT, "LEFT")

button(SH, 388, 261, 154, 80, C.mult, "Next\nRound", 24, function()
    local g = _G.G
    if g and g.STATE == g.STATES.SHOP then
        g:continue_from_shop()
    end
end)
local rerollBtn = button(SH, 388, 351, 154, 86, C_REROLL, "Reroll", 22, function()
    local g = _G.G
    if g and g.STATE == g.STATES.SHOP then
        g:reroll_shop_offers()
    end
end)
rerollBtn.label:ClearAllPoints()
rerollBtn.label:SetPoint("TOP", 0, -10)
local rerollCost = rerollBtn:CreateFontString(nil, "OVERLAY")
rerollCost:SetFont(FONT, 40)
rerollCost:SetShadowColor(0, 0, 0, 0.6)
rerollCost:SetShadowOffset(2, -2)
rerollCost:SetPoint("TOP", 0, -36)

local shopSel
local shopPool, tagPool = {}, {}
local shopUsed

local actionBtn = button(SH, 0, 0, 90, 38, C_REROLL, "BUY", 22, function()
    local g = _G.G
    if not (g and shopSel and g.STATE == g.STATES.SHOP) then
        return
    end
    if shopSel.kind == "offer" then
        g:buy_shop_joker(shopSel.i)
    elseif shopSel.kind == "booster" then
        g:buy_shop_booster(shopSel.i)
    elseif shopSel.kind == "voucher" then
        g:buy_shop_voucher(shopSel.i)
    end
    shopSel = nil
end)
actionBtn:SetFrameLevel(SH:GetFrameLevel() + 40)
actionBtn:Hide()
local buyUseBtn = button(SH, 0, 0, 120, 38, C_REROLL, "BUY & USE", 20, function()
    local g = _G.G
    if g and shopSel and shopSel.kind == "offer" then
        g:buy_and_use_shop_consumable(shopSel.i)
    end
    shopSel = nil
end)
buyUseBtn:SetFrameLevel(SH:GetFrameLevel() + 40)
buyUseBtn:Hide()

local function priceTag(i, x, y, price)
    local t = tagPool[i]
    if not t then
        t = CreateFrame("Frame", nil, SH)
        t:SetSize(56, 32)
        t.bg = t:CreateTexture(nil, "BACKGROUND")
        t.bg:SetAllPoints()
        t.bg:SetTexture(rgb(C_TAG))
        t.text = t:CreateFontString(nil, "OVERLAY")
        t.text:SetFont(FONT, 26)
        t.text:SetTextColor(rgb(C.money))
        t.text:SetShadowColor(0, 0, 0, 0.6)
        t.text:SetShadowOffset(2, -2)
        t.text:SetPoint("CENTER", 0, 1)
        tagPool[i] = t
    end
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT", SH, "TOPLEFT", x, -y)
    t:SetFrameLevel(SH:GetFrameLevel() + 30)
    t.text:SetText("$" .. tostring(price or 0))
    t:Show()
end

local function canBuy(g, kind, slot, price)
    if not g or not g:can_afford_price(price) then
        return false
    end
    if kind == "voucher" then
        local offer = g.shop_voucher_offers and g.shop_voucher_offers[slot]
        return not (offer and g:_voucher_already_owned(offer.id))
    elseif kind == "offer" then
        local offer = g.shop_offers and g.shop_offers[slot]
        if not offer then
            return false
        end
        if offer.kind == nil or offer.kind == "joker" then
            return g:joker_has_room_for_new(offer.edition) ~= false
        end
        if offer.kind == "tarot" or offer.kind == "planet" or offer.kind == "spectral" then
            return g:can_add_consumable(offer.edition and { edition = offer.edition } or nil) ~= false
        end
    end
    return true
end

local function onShopItemClick(self)
    if shopSel and shopSel.kind == self.kind and shopSel.i == self.slot then
        shopSel = nil
    else
        shopSel = { kind = self.kind, i = self.slot }
    end
end

local function shopItem(kind, slot, x, y, w, h, price, label)
    shopUsed = shopUsed + 1
    local b = newSpriteButton(shopPool, shopUsed, onShopItemClick, SH)
    b.kind, b.slot = kind, slot
    local selected = shopSel and shopSel.kind == kind and shopSel.i == slot
    local yy = selected and (y - 14) or y
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", SH, "TOPLEFT", x, -yy)
    b:SetSize(w, h)
    b:SetFrameLevel(SH:GetFrameLevel() + 10 + shopUsed)
    b:Show()
    priceTag(shopUsed, x + w / 2 - 28, yy - 30, price)
    if selected then
        actionBtn:ClearAllPoints()
        actionBtn:SetPoint("TOPLEFT", SH, "TOPLEFT", x + w / 2 - 45, -(yy + h + 4))
        actionBtn.label:SetText(label)
        local ok = canBuy(_G.G, kind, slot, price)
        actionBtn:SetColor(ok and C_REROLL or C_DISABLED_BTN)
        actionBtn.label:SetTextColor(rgb(ok and C.white or C_DISABLED_TXT))
        actionBtn._want = true
        local g = _G.G
        local offer = kind == "offer" and g and g.shop_offers and g.shop_offers[slot]
        if
            offer
            and offer.kind ~= nil
            and offer.kind ~= "joker"
            and offer.kind ~= "playing_card"
            and g:shop_offer_consumable_use_enabled(offer)
        then
            buyUseBtn:ClearAllPoints()
            buyUseBtn:SetPoint("TOPLEFT", SH, "TOPLEFT", x + w / 2 - 60, -(yy + h + 46))
            local canUse = g:can_afford_price(price)
            buyUseBtn:SetColor(canUse and C_REROLL or C_DISABLED_BTN)
            buyUseBtn.label:SetTextColor(rgb(canUse and C.white or C_DISABLED_TXT))
            buyUseBtn._want = true
        end
    end
    return b
end

local function boosterCell(tex, index)
    local path = TEX .. "boosters.tga"
    local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[path]
    if not dim then
        tex:Hide()
        return
    end
    applyCell(tex, "boosters.tga", 72, 95, index, math.floor(dim[1] / 72), dim[3], dim[4])
    tex:Show()
end

local function voucherCell(tex, id)
    local def = _G.VOUCHER_DEFS and _G.VOUCHER_DEFS[id]
    local pos = def and tonumber(def.pos)
    local path = TEX .. "Vouchers.tga"
    local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[path]
    if not (pos and dim) then
        tex:Hide()
        return
    end
    applyCell(tex, "Vouchers.tga", 72, 95, pos, math.floor(dim[1] / 72), dim[3], dim[4])
    tex:Show()
end

local function updateShop(g)
    shopUsed = 0
    actionBtn._want, buyUseBtn._want = false, false
    signAnim:SetTexture(TEX .. "ShopSignAnimation.tga")
    local frame = math.floor(GetTime() * 4) % 4
    signAnim:SetTexCoord(frame * 113 / 512, (frame + 1) * 113 / 512, 0, 60 / 64)
    local rerollPrice = g:shop_current_reroll_cost() or 0
    rerollCost:SetText("$" .. tostring(rerollPrice))
    rerollBtn:SetColor(g:can_afford_price(rerollPrice) and C_REROLL or C_DISABLED_BTN)
    voucherLabel:SetText("ANTE " .. (g.ante or 1) .. " VOUCHER")

    local nodes, offers = g.shop_offer_nodes or {}, g.shop_offers or {}
    local n = math.min(#nodes, #offers)
    local x0, step = spread(n, 781, 440, 124)
    for i = 1, n do
        local b =
            shopItem("offer", i, x0 + (i - 1) * step, 279, CARD_W, CARD_H, g:get_shop_offer_price(offers[i]), "BUY")
        b.tipFn = nodeTip(nodes[i])
        drawNode(b, nodes[i])
    end

    local boosters = g.shop_booster_offers or {}
    local bx0, bstep = spread(#boosters, 855, 280, 130)
    for i, offer in ipairs(boosters) do
        local b =
            shopItem("booster", i, bx0 + (i - 1) * bstep, 505, CARD_W, CARD_H, g:get_shop_booster_price(offer), "OPEN")
        b.tipFn = function()
            return captureTooltip(function()
                g:_draw_shop_booster_tooltip(offer, { x = 0, y = 0, w = 1, h = 1 })
            end)
        end
        boosterCell(b.base, tonumber(offer.booster_sprite_index) or 0)
        b.over:Hide()
        b.seal:Hide()
        b.debuff:Hide()
        b.shine:Hide()
    end

    local vouchers = g.shop_voucher_offers or {}
    local vx0, vstep = spread(#vouchers, 560, 280, 124)
    for i, offer in ipairs(vouchers) do
        local b = shopItem(
            "voucher",
            i,
            vx0 + (i - 1) * vstep,
            505,
            CARD_W,
            CARD_H,
            g:get_shop_voucher_price(offer),
            "REDEEM"
        )
        b.tipFn = function()
            return captureTooltip(function(TD)
                TD.draw_tooltip_layout(
                    nil,
                    tostring(offer.name or "Voucher"),
                    TD.resolved_lines_from_multiline(offer.description or "")
                )
            end)
        end
        voucherCell(b.base, offer.id)
        b.over:Hide()
        b.seal:Hide()
        b.debuff:Hide()
        b.shine:Hide()
    end

    for i = shopUsed + 1, #shopPool do
        shopPool[i]:Hide()
    end
    shown(actionBtn, actionBtn._want)
    shown(buyUseBtn, buyUseBtn._want)
    for i = shopUsed + 1, #tagPool do
        tagPool[i]:Hide()
    end
end

local PACK_FELT = {
    buffoon = { 0xC3, 0x6F, 0x00 },
    spectral = { 0x22, 0x5A, 0xBF },
    arcana = { 0x86, 0x68, 0xA7 },
    celestial = { 0x0F, 0x8C, 0xA5 },
    standard = { 0x5A, 0x6F, 0x74 },
}

local BP = CreateFrame("Frame", nil, RoundUI)
BP:SetAllPoints()
BP:SetFrameLevel(RoundUI:GetFrameLevel() + 2)
local bpBorder = rect(BP, 573, 615, 244, 105, C.chips)
rect(BP, 576, 618, 238, 102, C.panel, 1, "BORDER")
local bpTitle = text(BP, 573, 628, 244, 34, C.white)
local bpPicks = text(BP, 573, 666, 244, 24, C.white)
button(BP, 843, 625, 100, 65, { 0x4C, 0x63, 0x67 }, "Skip", 26, function()
    local g = _G.G
    if g and g.booster_session and g.end_booster_session then
        g:emit_joker_event("on_booster_skip", {})
        g:end_booster_session()
    end
end)

local packSel
local packPool = {}
local packAction = button(BP, 0, 0, 90, 38, C_REROLL, "SELECT", 20, function()
    local g = _G.G
    if g and packSel and g.booster_session then
        g:pick_booster_choice(packSel)
    end
    packSel = nil
end)
packAction:SetFrameLevel(BP:GetFrameLevel() + 40)
packAction:Hide()

local function onPackChoiceClick(self)
    packSel = (packSel == self.slot) and nil or self.slot
end

local function updateBooster(g)
    local sess = g.booster_session
    packAction._want = false
    if not sess then
        packAction:Hide()
        for _, b in ipairs(packPool) do
            b:Hide()
        end
        return
    end
    local tint = PACK_FELT[sess.pack or ""] or C.felt
    felt:SetTexture(rgb(tint))
    bpBorder:SetTexture(rgb(darken(tint, 1.2)))
    bpTitle:SetText(sess.title or "Pack")
    bpPicks:SetText("Choose " .. tostring(sess.picks_remaining or 0))

    local idx = {}
    for i, ch in ipairs(sess.choices or {}) do
        if ch and not ch.taken and sess.choice_nodes and sess.choice_nodes[i] then
            idx[#idx + 1] = i
        end
    end
    local x0, step = spread(#idx, 696, 600, 124)
    for k, i in ipairs(idx) do
        local b = newSpriteButton(packPool, k, onPackChoiceClick, BP)
        b.slot = i
        local x, y = x0 + (k - 1) * step, (packSel == i) and 426 or 440
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", BP, "TOPLEFT", x, -y)
        b:SetFrameLevel(BP:GetFrameLevel() + 10 + k)
        b.tipFn = nodeTip(sess.choice_nodes[i])
        drawNode(b, sess.choice_nodes[i])
        b:Show()
        if packSel == i then
            local kind = sess.choices[i].kind
            packAction.label:SetText((kind == "joker" or kind == "playing") and "SELECT" or "USE")
            packAction:ClearAllPoints()
            packAction:SetPoint("TOPLEFT", BP, "TOPLEFT", x + CARD_W / 2 - 45, -(y + CARD_H + 4))
            packAction._want = true
        end
    end
    for k = #idx + 1, #packPool do
        packPool[k]:Hide()
    end
    shown(packAction, packAction._want)
end

local GO, updateGameOver
do
    local C_GO_EDGE = { 0xA3, 0xAC, 0xB9 }
    local C_GO_BG = { 0x3A, 0x50, 0x55 }
    local C_GREEN = { 0x35, 0xBD, 0x86 }

    GO = CreateFrame("Frame", nil, RoundUI)
    GO:SetAllPoints()
    GO:SetFrameLevel(RoundUI:GetFrameLevel() + 60)
    GO:EnableMouse(true)
    local goTint = rect(GO, 0, 0, 1280, 720, { 0xD9, 0x4A, 0x40 }, 0.72)
    rect(GO, 582, 55, 466, 603, C_GO_EDGE, 1, "BORDER")
    rect(GO, 586, 59, 458, 595, C_GO_BG, 1, "BORDER")
    local goTitle = text(GO, 582, 72, 466, 72, C.mult)
    goTitle:SetText("GAME OVER")
    rect(GO, 608, 145, 414, 395, C.scoreBox, 1, "ARTWORK")

    local function goLayer()
        local f = CreateFrame("Frame", nil, GO)
        f:SetAllPoints()
        f:SetFrameLevel(GO:GetFrameLevel() + 2)
        return f
    end
    local function goRow(x, y, w, h, labelW, label, labelSize)
        local f = goLayer()
        rect(f, x, y, w, h, C_GO_EDGE)
        text(f, x, y + (h - labelSize) / 2 + 1, labelW, labelSize, C.white):SetText(label)
        rect(f, x + labelW + 4, y + 4, w - labelW - 8, h - 8, C.scoreBox, 1, "BORDER")
        return text(f, x + labelW + 4, y + (h - 26) / 2 + 1, w - labelW - 8, 26, C.white)
    end
    local goBest = goRow(618, 153, 397, 44, 196, "Best Hand", 30)
    goBest:SetTextColor(rgb(C.mult))
    local goMost = goRow(618, 202, 397, 40, 216, "Most Played Hand", 26)
    local goStats = {}
    local statDefs = {
        { "Cards Played", C.chips },
        { "Cards Discarded", C.mult },
        { "Cards Purchased", C.orange },
        { "Times Rerolled", C_GREEN },
        { "New Discoveries", C.white },
        { "Seed", C.white },
    }
    for i, d in ipairs(statDefs) do
        local wide = d[1] == "Seed"
        local v = goRow(614, 252 + (i - 1) * 43, 226, 38, wide and 110 or 164, d[1], 22)
        v:SetTextColor(rgb(d[2]))
        goStats[i] = v
    end
    local goAnte = goRow(852, 252, 163, 38, 104, "Ante", 24)
    goAnte:SetTextColor(rgb(C.anteNum))
    local goRound = goRow(852, 295, 163, 38, 104, "Round", 24)
    goRound:SetTextColor(rgb(C.anteNum))
    local goDef = goLayer()
    rect(goDef, 850, 340, 167, 166, C_GO_EDGE)
    text(goDef, 850, 346, 167, 22, C.white):SetText("Defeated By")
    rect(goDef, 854, 372, 159, 130, C.scoreBox, 1, "BORDER")
    local goDefeatName = text(goDef, 854, 380, 159, 20, C.white)
    local goDefeatChip = goDef:CreateTexture(nil, "ARTWORK")
    goDefeatChip:SetPoint("TOPLEFT", goDef, "TOPLEFT", 898, -408)
    goDefeatChip:SetSize(72, 72)

    local function mainMenuUI()
        return package.loaded and package.loaded["main_menu_ui"]
    end
    local function isWin(g)
        return g.STATE == g.STATES.YOU_WIN
    end
    local goNew = button(GO, 678, 551, 278, 34, C.mult, "New Run", 24, function()
        local g = _G.G
        if not g then
            return
        end
        if isWin(g) then
            g:continue_from_you_win_new_run()
            return
        end
        g:continue_from_game_over()
        local m = mainMenuUI()
        if type(m) == "table" and m.open_deck_select then
            m.open_deck_select(g)
        end
    end)
    local goMenu = button(GO, 678, 592, 278, 34, C.mult, "Main Menu", 24, function()
        local g = _G.G
        if not g then
            return
        end
        if isWin(g) then
            g:continue_from_you_win_main_menu()
        else
            g:continue_from_game_over()
        end
    end)
    local goEndless = button(GO, 678, 510, 278, 34, C.orange, "Endless Mode", 24, function()
        local g = _G.G
        if g and isWin(g) then
            g:continue_from_you_win_endless()
        end
    end)
    goEndless:SetFrameLevel(GO:GetFrameLevel() + 5)
    goNew:SetFrameLevel(GO:GetFrameLevel() + 5)
    goMenu:SetFrameLevel(GO:GetFrameLevel() + 5)
    GO:Hide()

    local function seedText(seed)
        local n = math.floor(math.abs(tonumber(seed) or 0))
        local digits, out = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", ""
        for _ = 1, 8 do
            local d = n % 36
            out = digits:sub(d + 1, d + 1) .. out
            n = math.floor(n / 36)
        end
        return out
    end

    function updateGameOver(g)
        local win = isWin(g)
        goTitle:SetText(win and "YOU WIN!" or "GAME OVER")
        goTitle:SetTextColor(rgb(win and C.orange or C.mult))
        goTint:SetTexture(rgb(win and { 0x00, 0x93, 0xFF } or { 0xD9, 0x4A, 0x40 }, 0.72))
        shown(goDef, not win)
        shown(goEndless, win)
        goBest:SetText(fmtNum(g.run_best_hand_score))
        local name = g.get_most_played_hand_name and g:get_most_played_hand_name() or "None"
        local count = 0
        for i, n in ipairs(g.handlist or {}) do
            if n == name then
                count = tonumber(g.hand_play_counts and g.hand_play_counts[i]) or 0
            end
        end
        goMost:SetText(count > 0 and (name .. " (" .. count .. ")") or name)
        local vals = {
            g.run_cards_played,
            g.run_cards_discarded,
            g.run_cards_purchased,
            g.run_times_rerolled,
            g.run_new_discoveries,
            seedText(g.SEED),
        }
        for i, v in ipairs(goStats) do
            v:SetText(tostring(vals[i] or 0))
        end
        goAnte:SetText(tostring(g._game_over_ante or g.ante or 1))
        goRound:SetText(tostring(g._game_over_round or g.round or 1))
        local idx = tonumber(g.current_blind_index) or 1
        goDefeatName:SetText(g._game_over_blind_label or g:get_blind_display_name(idx) or "")
        applyCell(goDefeatChip, "BlindChips.tga", 36, 36, (g:get_blind_sprite_index(idx) or 0) * 21, 24, 1024, 1024)
    end
end

local C_EDGE = { 0xA3, 0xAC, 0xB9 }

local function overlayFrame()
    local f = CreateFrame("Frame", nil, RoundUI)
    f:SetAllPoints()
    f:SetFrameLevel(RoundUI:GetFrameLevel() + 80)
    f:EnableMouse(true)
    rect(f, 0, 0, 1280, 720, { 0, 0, 0 }, 0.45)
    f:Hide()
    return f
end
local function layer(parent, add)
    local f = CreateFrame("Frame", nil, parent)
    f:SetAllPoints()
    f:SetFrameLevel(parent:GetFrameLevel() + (add or 2))
    return f
end

local RI, updateRunInfo
do
    RI = overlayFrame()
    rect(RI, 277, 52, 726, 608, C_EDGE, 1, "BORDER")
    rect(RI, 281, 56, 718, 600, C.panel, 1, "ARTWORK")
    local riL = layer(RI)
    local riTab = 1
    local riTabBtns = {}
    local tabs = { "Poker Hands", "Blinds", "Vouchers", "Stake" }
    for i, name in ipairs(tabs) do
        riTabBtns[i] = button(riL, 348 + (i - 1) * 148, 84, 138, 46, C.mult, name, 24, function()
            riTab = i
        end)
    end
    local riPages = {}
    for i = 1, 4 do
        riPages[i] = layer(riL, 2)
    end
    local RI_ROWS = 12
    local riRows = {}
    for i = 1, RI_ROWS do
        local y = 150 + (i - 1) * 38
        local f = layer(riPages[1], 2)
        local r = {
            f = f,
            bg = rect(f, 350, y, 580, 34, C_EDGE),
            lvlBox = rect(f, 353, y + 3, 84, 28, C.white, 1, "BORDER"),
            lvl = text(f, 353, y + 7, 84, 20, C_DISABLED_TXT),
            name = text(f, 440, y + 6, 248, 22, C.white),
            chipsBox = rect(f, 690, y + 3, 72, 28, C.chips, 1, "BORDER"),
            chips = text(f, 690, y + 7, 68, 22, C.white, "RIGHT"),
            x = text(f, 762, y + 6, 18, 22, C.mult),
            multBox = rect(f, 780, y + 3, 56, 28, C.mult, 1, "BORDER"),
            mult = text(f, 784, y + 7, 52, 22, C.white, "LEFT"),
            cntBox = rect(f, 862, y + 3, 66, 28, C.scoreBox, 1, "BORDER"),
            cnt = text(f, 862, y + 7, 62, 22, C.orange, "RIGHT"),
            hash = text(f, 842, y + 6, 20, 22, C.white),
        }
        r.x:SetText("X")
        r.hash:SetText("#")
        riRows[i] = r
    end
    button(riL, 290, 612, 700, 36, C.orange, "Back", 26, function()
        RI:Hide()
    end)

    local riBlinds = {}
    for i = 1, 3 do
        local y = 156 + (i - 1) * 146
        local f = layer(riPages[2], 2)
        riBlinds[i] = {
            edge = rect(f, 350, y, 580, 134, C_EDGE),
            bg = rect(f, 354, y + 4, 572, 126, C.scoreBox, 1, "BORDER"),
            chip = f:CreateTexture(nil, "ARTWORK"),
            name = text(f, 470, y + 14, 440, 28, C.white, "LEFT"),
            desc = text(f, 470, y + 46, 440, 18, C.white, "LEFT"),
            target = text(f, 470, y + 72, 440, 26, C.mult, "LEFT"),
            reward = text(f, 470, y + 102, 440, 20, C.money, "LEFT"),
            state = text(f, 700, y + 14, 216, 22, C.orange, "RIGHT"),
        }
        riBlinds[i].chip:SetPoint("TOPLEFT", f, "TOPLEFT", 370, -(y + 22))
        riBlinds[i].chip:SetSize(90, 90)
    end
    local riVoucherPool = {}
    local riNoVouchers = text(riPages[3], 281, 360, 718, 26, C.white)
    riNoVouchers:SetText("No Vouchers redeemed this run")
    local riStakeChip = riPages[4]:CreateTexture(nil, "ARTWORK")
    riStakeChip:SetPoint("TOPLEFT", riPages[4], "TOPLEFT", 380, -170)
    riStakeChip:SetSize(90, 90)
    local riStakeName = text(riPages[4], 490, 176, 460, 32, C.white, "LEFT")
    local riStakeDesc = text(riPages[4], 490, 216, 460, 22, C.white, "LEFT")
    local riStakeAlso = text(riPages[4], 380, 290, 560, 20, C.white, "LEFT")
    riStakeAlso:SetSpacing(6)

    local function stakeCell(tex, def)
        applyCell(tex, "chips.tga", 30, 30, tonumber(def and def.pos) or 0, 4, 128, 128)
    end

    local function updateRunInfoBlinds(g)
        local current = tonumber(g.current_blind_index) or 1
        for i, r in ipairs(riBlinds) do
            local def = g:get_blind_def(i)
            local bc = to255(g:get_blind_color(i))
            r.edge:SetTexture(rgb(i == current and bc or C_EDGE))
            applyCell(r.chip, "BlindChips.tga", 36, 36, (g:get_blind_sprite_index(i) or 0) * 21, 24, 1024, 1024)
            r.chip:SetDesaturated(i < current)
            r.name:SetText(g:get_blind_display_name(i) or (def and def.name) or "")
            r.desc:SetText(def and def.id == "boss" and (g:get_blind_description(i) or "") or "")
            r.target:SetText("Score at least " .. fmtNum(g:get_blind_target(i, g.ante)))
            local reward = g:get_blind_reward(i) or 0
            r.reward:SetText(reward > 0 and ("Reward: " .. string.rep("$", reward)) or "No Reward")
            r.state:SetText(
                (i < current and (wasSkipped(g, i) and "Skipped" or "Defeated"))
                    or (i == current and "Current")
                    or "Upcoming"
            )
        end
    end

    local function updateRunInfoVouchers(g)
        local ids = g.vouchers or {}
        for k, id in ipairs(ids) do
            local b = newSpriteButton(riVoucherPool, k, nil, riPages[3])
            local row = math.floor((k - 1) / 6)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", riPages[3], "TOPLEFT", 331 + ((k - 1) % 6) * 106, -(160 + row * 160))
            b:SetSize(CARD_W * 0.9, CARD_H * 0.9)
            b:SetFrameLevel(riPages[3]:GetFrameLevel() + 2 + k)
            voucherCell(b.base, id)
            b.over:Hide()
            b.seal:Hide()
            b.debuff:Hide()
            b.shine:Hide()
            local def = _G.VOUCHER_DEFS and _G.VOUCHER_DEFS[id]
            b.tipFn = function()
                return captureTooltip(function(TD)
                    TD.draw_tooltip_layout(
                        nil,
                        tostring(def and def.name or id),
                        TD.resolved_lines_from_multiline(def and def.description or "")
                    )
                end)
            end
            b:Show()
        end
        for k = #ids + 1, #riVoucherPool do
            riVoucherPool[k]:Hide()
        end
        shown(riNoVouchers, #ids == 0)
    end

    local function updateRunInfoStake(g)
        local id = g:get_run_stake_id() or "stake_white"
        local def = _G.STAKE_DEFS_BY_ID and _G.STAKE_DEFS_BY_ID[id]
        stakeCell(riStakeChip, def)
        riStakeName:SetText(def and def.name or "White Stake")
        riStakeDesc:SetText(def and def.description or "")
        local also = {}
        for _, sd in ipairs(_G.STAKE_DEFS or {}) do
            if def and (tonumber(sd.order) or 0) < (tonumber(def.order) or 0) and sd.id ~= "stake_white" then
                also[#also + 1] = sd.name .. ": " .. tostring(sd.description or "")
            end
        end
        riStakeAlso:SetText(#also > 0 and ("Also applies:\n" .. table.concat(also, "\n")) or "")
    end

    local SECRET_HANDS = { ["Flush Five"] = true, ["Flush House"] = true, ["Five of a Kind"] = true }
    function updateRunInfo(g)
        for i, b in ipairs(riTabBtns) do
            b:SetColor(i == riTab and C.mult or darken(C.mult, 0.6))
            shown(riPages[i], i == riTab)
        end
        if riTab == 2 then
            updateRunInfoBlinds(g)
            return
        end
        if riTab == 3 then
            updateRunInfoVouchers(g)
            return
        end
        if riTab == 4 then
            updateRunInfoStake(g)
            return
        end
        local row = 0
        for i, name in ipairs(g.handlist or {}) do
            local secret = SECRET_HANDS[name] and not (g.has_played_hand_name and g:has_played_hand_name(name))
            if not secret and row < RI_ROWS then
                row = row + 1
                local r = riRows[row]
                local lvl, chips, mult = g:get_hand_level_stats(i)
                r.lvl:SetText("lvl." .. lvl)
                r.name:SetText(name)
                r.chips:SetText(tostring(chips))
                r.mult:SetText(tostring(mult))
                r.cnt:SetText(tostring(tonumber(g.hand_play_counts and g.hand_play_counts[i]) or 0))
                r.f:Show()
            end
        end
        for i = row + 1, RI_ROWS do
            riRows[i].f:Hide()
        end
    end
end

local OP = overlayFrame()
rect(OP, 431, 128, 418, 454, C_EDGE, 1, "BORDER")
rect(OP, 435, 132, 410, 446, C.panel, 1, "ARTWORK")
local opL = layer(OP)
local function mainMenu()
    return package.loaded and package.loaded["main_menu_ui"]
end
local opDefs = {
    {
        "Settings",
        function()
            Balatro.UI.settings()
        end,
    },
    {
        "New Run",
        function(g)
            g:enter_main_menu()
            local m = mainMenu()
            if type(m) == "table" and m.open_deck_select then
                m.open_deck_select(g)
            end
        end,
    },
    {
        "Main Menu",
        function(g)
            g:pause_save_and_quit()
        end,
    },
    {
        "Stats",
        function()
            Balatro.UI.stats()
        end,
    },
    {
        "Collection",
        function()
            Balatro.UI.collection()
        end,
    },
}
for i, d in ipairs(opDefs) do
    local action = d[2]
    local b = button(opL, 500, 152 + (i - 1) * 62, 280, 50, action and C.mult or C_DISABLED_BTN, d[1], 26, function()
        local g = _G.G
        if g and action then
            OP:Hide()
            action(g)
        end
    end)
    if not action then
        b:Disable()
        b.label:SetTextColor(rgb(C_DISABLED_TXT))
    end
end
button(opL, 445, 528, 390, 36, C.orange, "Back", 26, function()
    OP:Hide()
end)

overlays.toggle = function(name)
    local f = (name == "runinfo") and RI or OP
    local other = (name == "runinfo") and OP or RI
    other:Hide()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end

local DV, updateDeckView
do
    local DV_SUITS = { "Spades", "Hearts", "Clubs", "Diamonds" }
    DV = CreateFrame("Frame", nil, RoundUI)
    DV:SetAllPoints()
    DV:SetFrameLevel(RoundUI:GetFrameLevel() + 80)
    DV:EnableMouse(true)
    rect(DV, 0, 0, 1280, 720, { 0, 0, 0 }, 0.55)
    rect(DV, 190, 40, 900, 640, C_EDGE, 1, "BORDER")
    rect(DV, 194, 44, 892, 632, C.panel, 1, "ARTWORK")
    local dvLayer = CreateFrame("Frame", nil, DV)
    dvLayer:SetAllPoints()
    dvLayer:SetFrameLevel(DV:GetFrameLevel() + 2)
    local dvTitle = text(dvLayer, 194, 54, 892, 30, C.white)
    local dvCounts = {}
    for r = 1, 4 do
        dvCounts[r] = text(dvLayer, 206, 118 + (r - 1) * 128, 110, 22, C.white, "LEFT")
    end
    local dvPool = {}
    local function closeDeckView()
        local g = _G.G
        if g and g.exit_deck_view then
            g:exit_deck_view()
        end
    end
    button(dvLayer, 400, 626, 480, 38, C.orange, "Back", 26, closeDeckView)
    DV:Hide()

    function updateDeckView(g)
        local rows = g._deck_view_rows or {}
        local used, total = 0, 0
        for r, suit in ipairs(DV_SUITS) do
            local nodes = rows[suit] or {}
            total = total + #nodes
            dvCounts[r]:SetText(suit .. "\n" .. #nodes)
            local step = math.min(56, (740 - 72) / math.max(1, #nodes - 1))
            for k, node in ipairs(nodes) do
                used = used + 1
                local b = newSpriteButton(dvPool, used, nil, dvLayer)
                b:SetSize(72, 95)
                b.tipFn = nodeTip(node)
                b:ClearAllPoints()
                b:SetPoint("TOPLEFT", dvLayer, "TOPLEFT", 320 + (k - 1) * step, -(96 + (r - 1) * 128))
                b:SetFrameLevel(dvLayer:GetFrameLevel() + 2 + k)
                drawCard(b, node)
                b:Show()
            end
        end
        for i = used + 1, #dvPool do
            dvPool[i]:Hide()
        end
        dvTitle:SetText("Remaining cards: " .. total)
    end
end

local tagIconPool = {}
local function updateTags(g)
    local tags = g.tags or {}
    local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[TEX .. "tags.tga"]
    for i, tag in ipairs(tags) do
        local b = tagIconPool[i]
        if not b then
            b = CreateFrame("Button", nil, RoundUI)
            b:SetSize(40, 40)
            b.icon = b:CreateTexture(nil, "ARTWORK")
            b.icon:SetAllPoints()
            b:SetScript("OnEnter", function(self)
                hoverBtn = self
            end)
            b:SetScript("OnLeave", function(self)
                if hoverBtn == self then
                    hoverBtn = nil
                end
            end)
            tagIconPool[i] = b
        end
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", 3, -(60 + (i - 1) * 44))
        b:SetFrameLevel(RoundUI:GetFrameLevel() + 20)
        if dim and tag.id then
            applyCell(b.icon, "tags.tga", 34, 34, tonumber(tag.id) or 0, math.floor(dim[1] / 34), dim[3], dim[4])
        end
        b.tipFn = tagTip(tostring(tag.type or ""))
        b:Show()
    end
    for i = #tags + 1, #tagIconPool do
        tagIconPool[i]:Hide()
    end
end

local TIP, updateTooltip
do
    local TIP_COLORS = {
        MULT = "FE5F55",
        CHIPS = "009DFF",
        CHANCE = "35BD86",
        PURPLE = "A782D1",
        IMPORTANT = "FF9800",
        MONEY = "F3B958",
        RED = "FE5F55",
    }
    local TIP_DEFAULT = "4F6367"
    local RARITY_COLORS = { { 0x00, 0x9D, 0xFF }, { 0x4B, 0xC2, 0x92 }, { 0xFE, 0x5F, 0x55 }, { 0xB2, 0x6C, 0xBB } }
    local TIP_LINES = 6

    TIP = CreateFrame("Frame", nil, RoundUI)
    TIP:SetFrameLevel(RoundUI:GetFrameLevel() + 95)
    TIP:SetSize(10, 10)
    TIP.edge = TIP:CreateTexture(nil, "BACKGROUND")
    TIP.edge:SetAllPoints()
    TIP.edge:SetTexture(rgb(C_EDGE))
    TIP.bg = TIP:CreateTexture(nil, "BORDER")
    TIP.bg:SetPoint("TOPLEFT", 3, -3)
    TIP.bg:SetPoint("BOTTOMRIGHT", -3, 3)
    TIP.bg:SetTexture(rgb(C.panel))
    TIP.title = TIP:CreateFontString(nil, "OVERLAY")
    TIP.title:SetFont(FONT, 26)
    TIP.title:SetShadowColor(0, 0, 0, 0.6)
    TIP.title:SetShadowOffset(2, -2)
    TIP.title:SetPoint("TOP", 0, -8)
    TIP.body = TIP:CreateTexture(nil, "ARTWORK")
    TIP.body:SetTexture(1, 1, 1, 1)
    TIP.lines = {}
    for i = 1, TIP_LINES do
        local fs = TIP:CreateFontString(nil, "OVERLAY")
        fs:SetFont(FONT, 20)
        TIP.lines[i] = fs
    end
    TIP.pill = TIP:CreateTexture(nil, "ARTWORK")
    TIP.pillText = TIP:CreateFontString(nil, "OVERLAY")
    TIP.pillText:SetFont(FONT, 20)
    TIP.pillText:SetShadowColor(0, 0, 0, 0.6)
    TIP.pillText:SetShadowOffset(2, -2)
    TIP:Hide()

    local function segmentsToText(segments)
        local out = {}
        for _, seg in ipairs(segments or {}) do
            out[#out + 1] = "|cff"
                .. (TIP_COLORS[seg.color_key or ""] or TIP_DEFAULT)
                .. tostring(seg.text or "")
                .. "|r"
        end
        return table.concat(out)
    end

    local function showTooltip(anchor, cap)
        local lines, rarity = {}, nil
        for _, line in ipairs(cap.lines or {}) do
            if #line == 1 and line[1].rarity_badge then
                rarity = line[1]
            else
                lines[#lines + 1] = line
            end
        end
        TIP.title:SetText(tostring(cap.title or ""))
        local w = TIP.title:GetStringWidth()
        local n = math.min(#lines, TIP_LINES)
        for i = 1, TIP_LINES do
            local fs = TIP.lines[i]
            if i <= n then
                fs:SetText(segmentsToText(lines[i]))
                fs:Show()
                w = math.max(w, fs:GetStringWidth())
            else
                fs:Hide()
            end
        end
        w = math.max(w + 36, 180)
        local bodyH = n > 0 and (n * 24 + 14) or 0
        local h = 44 + bodyH + (rarity and 40 or 0) + 8
        TIP:SetSize(w, h)
        TIP.body:ClearAllPoints()
        TIP.body:SetPoint("TOPLEFT", TIP, "TOPLEFT", 10, -42)
        TIP.body:SetSize(w - 20, math.max(bodyH, 1))
        if n > 0 then
            TIP.body:Show()
        else
            TIP.body:Hide()
        end
        for i = 1, n do
            TIP.lines[i]:ClearAllPoints()
            TIP.lines[i]:SetPoint("TOP", TIP, "TOP", 0, -(49 + (i - 1) * 24))
        end
        if rarity then
            local rc = rarity.color or RARITY_COLORS[tonumber(rarity.rarity_index) or 1] or RARITY_COLORS[1]
            TIP.pillText:SetText(tostring(rarity.text or ""))
            local pw = TIP.pillText:GetStringWidth() + 36
            TIP.pill:ClearAllPoints()
            TIP.pill:SetPoint("TOP", TIP, "TOP", 0, -(46 + bodyH))
            TIP.pill:SetSize(pw, 30)
            TIP.pill:SetTexture(rgb(rc))
            TIP.pill:Show()
            TIP.pillText:ClearAllPoints()
            TIP.pillText:SetPoint("CENTER", TIP.pill, "CENTER", 0, 1)
            TIP.pillText:Show()
        else
            TIP.pill:Hide()
            TIP.pillText:Hide()
        end

        local root = RoundUI:GetParent()
        local ax = anchor:GetLeft() - root:GetLeft()
        local ay = root:GetTop() - anchor:GetTop()
        local aw, ah = anchor:GetWidth(), anchor:GetHeight()
        local x = math.max(4, math.min(1280 - w - 4, ax + aw / 2 - w / 2))
        local y = ay - h - 8
        if y < 4 then
            y = ay + ah + 8
        end
        TIP:ClearAllPoints()
        TIP:SetPoint("TOPLEFT", RoundUI:GetParent(), "TOPLEFT", x, -y)
        TIP:Show()
    end

    function updateTooltip()
        local b = hoverBtn
        if not (b and b:IsVisible() and b.tipFn) then
            TIP:Hide()
            return
        end
        local over = (b.IsMouseOver and b:IsMouseOver()) or (not b.IsMouseOver and MouseIsOver and MouseIsOver(b))
        if not over then
            hoverBtn = nil
            TIP:Hide()
            return
        end
        local cap = b.tipFn()
        if cap and cap.title then
            showTooltip(b, cap)
        else
            TIP:Hide()
        end
    end
end

do
    local CANVAS = RoundUI:GetParent()
    local SHARED_LEVEL = CANVAS:GetFrameLevel() + 112
    TIP:SetParent(CANVAS)
    TIP:SetFrameLevel(CANVAS:GetFrameLevel() + 124)

    local sharedFrames = {}
    local function sharedFrame()
        local f = CreateFrame("Frame", nil, CANVAS)
        f:SetAllPoints()
        f:SetFrameLevel(SHARED_LEVEL)
        f:EnableMouse(true)
        rect(f, 0, 0, 1280, 720, { 0, 0, 0 }, 0.55)
        f:Hide()
        sharedFrames[#sharedFrames + 1] = f
        return f
    end
    local function openShared(f)
        for _, o in ipairs(sharedFrames) do
            if o ~= f then
                o:Hide()
            end
        end
        f:Show()
    end
    local function panel(f, x, y, w, h)
        rect(f, x, y, w, h, C_EDGE, 1, "BORDER")
        rect(f, x + 4, y + 4, w - 8, h - 8, C.panel, 1, "ARTWORK")
        return layer(f, 2)
    end
    local function catalog()
        return package.loaded and package.loaded["collection_catalog"]
    end

    local COL = sharedFrame()
    local colMenu = CreateFrame("Frame", nil, COL)
    colMenu:SetAllPoints()
    colMenu:SetFrameLevel(SHARED_LEVEL + 1)
    local colGrid = CreateFrame("Frame", nil, COL)
    colGrid:SetAllPoints()
    colGrid:SetFrameLevel(SHARED_LEVEL + 1)
    local colState = { cat = nil, page = 1, key = nil, items = {} }
    local COL_PER_PAGE = 15

    local menuL = panel(colMenu, 313, 110, 654, 490)
    rect(menuL, 347, 338, 279, 180, C.scoreBox, 1, "BORDER")
    local C_TAROT, C_PLANET, C_SPECTRAL = { 0xA7, 0x82, 0xD1 }, { 0x13, 0xAF, 0xCE }, { 0x45, 0x84, 0xFA }
    local COL_BUTTONS = {
        { "jokers", "Jokers", 347, 142, 279, 78, C.mult },
        { "decks", "Decks", 347, 229, 279, 44, C.mult },
        { "vouchers", "Vouchers", 347, 283, 279, 44, C.mult },
        { "tarots", "Tarot Cards", 388, 351, 222, 44, C_TAROT },
        { "planets", "Planet Cards", 388, 405, 222, 44, C_PLANET },
        { "spectrals", "Spectral Cards", 388, 459, 222, 44, C_SPECTRAL },
        { "enhanced", "Enhanced Cards", 654, 143, 279, 50, C.mult },
        { "seals", "Seals", 654, 202, 279, 50, C.mult },
        { "editions", "Editions", 654, 260, 279, 46, C.mult },
        { "boosters", "Booster Packs", 654, 314, 279, 46, C.mult },
        { "tags", "Tags", 654, 368, 279, 46, C.mult },
        { "blinds", "Blinds", 654, 422, 279, 95, C.mult },
    }
    local colCounts = {}
    for _, d in ipairs(COL_BUTTONS) do
        local b = button(menuL, d[3], d[4], d[5], d[6], d[7], d[2], 26, function()
            colState.cat, colState.page, colState.key = d[1], 1, nil
        end)
        b.label:ClearAllPoints()
        b.label:SetPoint("CENTER", 0, 8)
        local cnt = b:CreateFontString(nil, "OVERLAY")
        cnt:SetFont(FONT, 18)
        cnt:SetShadowColor(0, 0, 0, 0.6)
        cnt:SetShadowOffset(2, -2)
        cnt:SetPoint("CENTER", 0, -12)
        colCounts[d[1]] = cnt
    end
    button(menuL, 327, 548, 626, 34, C.orange, "Back", 26, function()
        COL:Hide()
    end)

    local gridL = panel(colGrid, 325, 33, 630, 645)
    rect(gridL, 350, 58, 580, 465, C.scoreBox, 1, "BORDER")
    local colPageText
    button(gridL, 476, 543, 32, 46, C.mult, "<", 26, function()
        colState.page = colState.page - 1
        colState.key = nil
    end)
    local pageBtn = button(gridL, 514, 543, 252, 46, C.mult, "", 28, function() end)
    colPageText = pageBtn.label
    button(gridL, 772, 543, 32, 46, C.mult, ">", 26, function()
        colState.page = colState.page + 1
        colState.key = nil
    end)
    button(gridL, 339, 626, 602, 34, C.orange, "Back", 26, function()
        colState.cat, colState.key = nil, nil
    end)
    local colPool = {}

    local function colNode(entry)
        local ok, node = pcall(function()
            local k = entry.node_kind
            if k == "joker" then
                return _G.Joker(0, 0, 70, 94, entry.def, { face_up = true })
            end
            if k == "edition" then
                return _G.Joker(0, 0, 70, 94, _G.JOKER_DEFS.j_joker, { face_up = true, edition = entry.edition })
            end
            if k == "consumable" then
                return _G.Consumable(0, 0, entry.def)
            end
            if k == "enhanced" then
                return _G.Card(
                    0,
                    0,
                    71,
                    95,
                    { rank = 14, suit = "Spades", enhancement = entry.enhancement },
                    nil,
                    { face_up = true }
                )
            end
            if k == "seal" then
                return _G.Card(0, 0, 71, 95, { rank = 14, suit = "Spades", seal = entry.seal }, nil, { face_up = true })
            end
        end)
        return ok and node or nil
    end

    local function entryTip(g, entry, node, discovered)
        return function()
            if entry.node_kind == "deck" then
                local TD, CC = package.loaded["tooltip_draw"], catalog()
                if type(TD) ~= "table" or type(CC) ~= "table" then
                    return nil
                end
                return {
                    title = entry.name,
                    lines = TD.resolved_lines_from_multiline(CC.deck_tooltip_body(g, entry.def)),
                }
            end
            if not discovered then
                return { title = "Not Discovered", lines = {} }
            end
            if node and entry.node_kind ~= "enhanced" and entry.node_kind ~= "seal" then
                local cap = nodeTip(node)()
                if cap then
                    return cap
                end
            end
            local TD, CC = package.loaded["tooltip_draw"], catalog()
            if type(TD) ~= "table" or type(CC) ~= "table" then
                return nil
            end
            local title, raw = CC.entry_tooltip_content(g, entry)
            local lines = {}
            for _, l in ipairs(raw or {}) do
                for _, sl in ipairs(TD.resolved_lines_from_multiline(tostring(l))) do
                    lines[#lines + 1] = sl
                end
            end
            return { title = title, lines = lines }
        end
    end

    local function drawEntry(g, b, item)
        local e, node = item.entry, item.node
        b.over:Hide()
        b.seal:Hide()
        b.debuff:Hide()
        b.shine:Hide()
        b.base:SetDesaturated(false)
        b.base:SetVertexColor(1, 1, 1)
        if not item.discovered and e.node_kind ~= "deck" then
            local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[TEX .. "Enhancers.tga"]
            if dim then
                local cols = math.floor(dim[1] / 72)
                applyCell(b.base, "Enhancers.tga", 72, 95, 1, cols, dim[3], dim[4])
                applyCell(b.over, "Enhancers.tga", 72, 95, 26, cols, dim[3], dim[4])
                b.over:Show()
            end
            b.base:Show()
            return
        end
        local k = e.node_kind
        if node then
            drawNode(b, node)
            return
        end
        local dimOf = function(file)
            return _G.BalatroImageDimensions and _G.BalatroImageDimensions[TEX .. file]
        end
        if k == "deck" then
            local dim = dimOf("Enhancers.tga")
            if dim then
                applyCell(
                    b.base,
                    "Enhancers.tga",
                    72,
                    95,
                    tonumber(e.pos) or 0,
                    math.floor(dim[1] / 72),
                    dim[3],
                    dim[4]
                )
            end
            b.base:SetDesaturated(not item.discovered)
        elseif k == "voucher" then
            voucherCell(b.base, e.id)
        elseif k == "booster" then
            boosterCell(b.base, tonumber(e.frame_index) or 0)
        elseif k == "tag" then
            tagCell(b.base, e.tag_type)
        elseif k == "blind" then
            applyCell(
                b.base,
                "BlindChips.tga",
                36,
                36,
                (tonumber(e.blind_def and e.blind_def.pos) or 0) * 21,
                24,
                1024,
                1024
            )
        end
        b.base:Show()
    end

    local function updateCollection(g)
        local CC = catalog()
        if type(CC) ~= "table" then
            return
        end
        shown(colMenu, colState.cat == nil)
        shown(colGrid, colState.cat ~= nil)
        if not colState.cat then
            for id, fs in pairs(colCounts) do
                local p = CC.get_progress(g, id)
                fs:SetText(p.discovered .. " / " .. p.total)
            end
            return
        end
        local entries = CC.get_entries(colState.cat)
        local pages = math.max(1, math.ceil(#entries / COL_PER_PAGE))
        colState.page = ((colState.page - 1) % pages) + 1
        colPageText:SetText("Page " .. colState.page .. "/" .. pages)
        local key = colState.cat .. ":" .. colState.page
        if colState.key ~= key then
            colState.key = key
            colState.items = {}
            local first = (colState.page - 1) * COL_PER_PAGE + 1
            for i = first, math.min(#entries, first + COL_PER_PAGE - 1) do
                local e = entries[i]
                local discovered = CC.is_entry_discovered(g, e)
                colState.items[#colState.items + 1] =
                    { entry = e, discovered = discovered, node = discovered and colNode(e) or nil }
            end
        end
        local n = #colState.items
        local small = { tag = true, blind = true }
        for i, item in ipairs(colState.items) do
            local b = newSpriteButton(colPool, i, nil, gridL)
            local row, col = math.floor((i - 1) / 5), (i - 1) % 5
            local inRow = math.min(5, n - row * 5)
            local w, h = 104, 138
            if small[item.entry.node_kind] then
                w, h = 84, 84
            end
            local cx = 640 + (col - (inRow - 1) / 2) * 116
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", gridL, "TOPLEFT", cx - w / 2, -(80 + row * 150 + (138 - h) / 2))
            b:SetSize(w, h)
            b:SetFrameLevel(gridL:GetFrameLevel() + 2)
            b.tipFn = entryTip(g, item.entry, item.node, item.discovered)
            drawEntry(g, b, item)
            b:Show()
        end
        for i = n + 1, #colPool do
            colPool[i]:Hide()
        end
    end

    local SET = sharedFrame()
    local setL = panel(SET, 390, 170, 500, 380)
    text(setL, 390, 190, 500, 34, C.white):SetText("Settings")
    text(setL, 390, 250, 500, 24, C.white):SetText("Game Speed")
    local SPEEDS = { 0.5, 1, 2, 4 }
    local speedBtns = {}
    for i, v in ipairs(SPEEDS) do
        speedBtns[i] = button(
            setL,
            430 + (i - 1) * 108,
            284,
            96,
            50,
            C.mult,
            (v == 0.5 and "0.5" or tostring(v)) .. "x",
            26,
            function()
                local g = _G.G
                if g and g.set_game_speed then
                    g:set_game_speed(v)
                end
            end
        )
    end
    text(setL, 390, 346, 250, 24, C.white):SetText("Music")
    local musicBtn = button(setL, 440, 374, 150, 44, C.mult, "On", 24, function()
        local g = _G.G
        if g and g.set_music_volume then
            g:set_music_volume(g:get_music_volume() > 0 and 0 or 100)
        end
    end)
    text(setL, 640, 346, 250, 24, C.white):SetText("Sound")
    local sfxBtn = button(setL, 690, 374, 150, 44, C.mult, "On", 24, function()
        BalatroProfile = BalatroProfile or {}
        BalatroProfile.sfxOff = not BalatroProfile.sfxOff
    end)
    local winHint = text(setL, 400, 424, 480, 18, C_DISABLED_TXT)
    winHint:SetText("Window: drag the title bar to move, the corner to resize")
    button(setL, 400, 496, 480, 38, C.orange, "Back", 26, function()
        SET:Hide()
    end)
    local function updateSettings(g)
        local cur = tonumber(g.SETTINGS and g.SETTINGS.GAMESPEED) or 1
        for i, b in ipairs(speedBtns) do
            b:SetColor(SPEEDS[i] == cur and C.mult or darken(C.mult, 0.55))
        end
        local musicOn = g.get_music_volume and g:get_music_volume() > 0
        musicBtn.label:SetText(musicOn and "On" or "Off")
        musicBtn:SetColor(musicOn and C.mult or darken(C.mult, 0.55))
        local sfxOn = not (BalatroProfile and BalatroProfile.sfxOff)
        sfxBtn.label:SetText(sfxOn and "On" or "Off")
        sfxBtn:SetColor(sfxOn and C.mult or darken(C.mult, 0.55))
    end

    local STAT = sharedFrame()
    local statL = panel(STAT, 390, 90, 500, 540)
    text(statL, 390, 108, 500, 34, C.white):SetText("Stats")
    text(statL, 410, 150, 460, 22, C.orange, "LEFT"):SetText("Collection progress")
    local statRows = {}
    for i, d in ipairs(COL_BUTTONS) do
        statRows[i] = {
            label = text(statL, 420, 150 + i * 30, 300, 20, C.white, "LEFT"),
            value = text(statL, 700, 150 + i * 30, 160, 20, C.white, "RIGHT"),
        }
        statRows[i].label:SetText(d[2])
    end
    button(statL, 400, 578, 480, 38, C.orange, "Back", 26, function()
        STAT:Hide()
    end)
    local function updateStats(g)
        local CC = catalog()
        if type(CC) ~= "table" then
            return
        end
        for i, d in ipairs(COL_BUTTONS) do
            local p = CC.get_progress(g, d[1])
            statRows[i].value:SetText(p.discovered .. " / " .. p.total)
        end
    end

    local MOPT = sharedFrame()
    local moL = panel(MOPT, 431, 200, 418, 300)
    button(moL, 500, 230, 280, 50, C.mult, "Settings", 26, function()
        openShared(SET)
    end)
    button(moL, 500, 292, 280, 50, C.mult, "Stats", 26, function()
        openShared(STAT)
    end)
    button(moL, 500, 354, 280, 50, C.mult, "Collection", 26, function()
        colState.cat = nil
        openShared(COL)
    end)
    button(moL, 445, 446, 390, 36, C.orange, "Back", 26, function()
        MOPT:Hide()
    end)

    Balatro.UI = {
        collection = function()
            colState.cat, colState.key = nil, nil
            openShared(COL)
        end,
        settings = function()
            openShared(SET)
        end,
        stats = function()
            openShared(STAT)
        end,
        options = function()
            openShared(MOPT)
        end,
    }

    local Driver = CreateFrame("Frame", nil, CANVAS)
    local driverError = false
    Driver:SetScript("OnUpdate", function()
        local ok, err = pcall(function()
            local g = _G.G
            if g then
                if COL:IsShown() then
                    updateCollection(g)
                end
                if SET:IsShown() then
                    updateSettings(g)
                end
                if STAT:IsShown() then
                    updateStats(g)
                end
            end
            updateTooltip()
        end)
        if not ok and not driverError then
            driverError = true
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4040Balatro overlay error:|r " .. tostring(err))
        end
    end)
end

local updatePopups
do
    local POP = CreateFrame("Frame", nil, RoundUI)
    POP:SetAllPoints()
    POP:SetFrameLevel(RoundUI:GetFrameLevel() + 70)
    local popPool = {}
    local function nodeCentre(n)
        local vt = n.VT or {}
        local off = n.collision_offset or {}
        local sc = vt.scale or 1
        return (vt.x or 0) + (off.x or 0) + (vt.w or 0) * sc / 2, (vt.y or 0) + (off.y or 0) + (vt.h or 0) * sc / 2
    end
    local function nearest(p, candidates)
        local best, bd
        for _, n in ipairs(candidates) do
            local x, y = nodeCentre(n)
            local d = (x - p.pos.x) ^ 2 + (y - p.pos.y) ^ 2
            if not bd or d < bd then
                best, bd = n, d
            end
        end
        return best
    end
    function updatePopups(g)
        local used = 0
        local cards = {}
        local seq = g.hand and g.hand._play_sequence
        for _, n in ipairs(seq and seq.cards or {}) do
            cards[#cards + 1] = n
        end
        for _, n in ipairs(g.hand and g.hand.card_nodes or {}) do
            cards[#cards + 1] = n
        end
        local sources =
            { { list = g.popups, nodes = cards }, { list = _G.Top and _G.Top.popups, nodes = g.jokers or {} } }
        for _, src in ipairs(sources) do
            for _, p in ipairs(src.list or {}) do
                if (tonumber(p.time) or 0) > 0 and p.pos then
                    if p._anchor == nil then
                        p._anchor = (p.Color ~= nil and p.scale ~= 5) and nearest(p, src.nodes) or false
                    end
                    local b = p._anchor and btnOfNode[p._anchor]
                    local x, y
                    if b and b:IsVisible() then
                        x = b:GetLeft() - RoundUI:GetLeft() + b:GetWidth() / 2
                        y = RoundUI:GetTop() - b:GetTop() - 6
                    elseif p.scale == 5 then
                        x, y = 696, 330
                    end
                    if x then
                        used = used + 1
                        local f = popPool[used]
                        if not f then
                            f = CreateFrame("Frame", nil, POP)
                            f.bg = f:CreateTexture(nil, "BACKGROUND")
                            f.bg:SetAllPoints()
                            f.text = f:CreateFontString(nil, "OVERLAY")
                            f.text:SetShadowColor(0, 0, 0, 0.6)
                            f.text:SetShadowOffset(2, -2)
                            f.text:SetPoint("CENTER", 0, 1)
                            popPool[used] = f
                        end
                        local t = 1 - (tonumber(p.time) or 0) / 0.75
                        local size = p.scale == 5 and 40
                            or math.floor(30 * (1 + 0.35 * math.sin(math.min(t, 1) * math.pi)))
                        f.text:SetFont(FONT, size)
                        f.text:SetText(tostring(p.text or ""))
                        local w, h = f.text:GetStringWidth() + 16, size + 10
                        f:SetSize(w, h)
                        f:ClearAllPoints()
                        f:SetPoint("TOPLEFT", RoundUI, "TOPLEFT", x - w / 2, -(y - h - t * 16))
                        local c = p.Color or { 1, 1, 1, 1 }
                        if p.noRect then
                            f.bg:Hide()
                            f.text:SetTextColor(c[1] or 1, c[2] or 1, c[3] or 1, 1)
                        else
                            f.bg:SetTexture(c[1] or 1, c[2] or 1, c[3] or 1, 1)
                            f.bg:Show()
                            f.text:SetTextColor(1, 1, 1, 1)
                        end
                        f:Show()
                    end
                end
            end
        end
        for i = used + 1, #popPool do
            popPool[i]:Hide()
        end
    end
end

local function refreshPanel(g, selecting, cashing, shopping, opening, inRound)
    local idx = g.current_blind_index or 1
    local bc = g.get_blind_color and to255(g:get_blind_color(idx)) or C.blind.small
    banner:SetTexture(rgb(bc))
    blindInfo:SetTexture(rgb(darken(bc, 0.45)))
    bannerText:SetText(g.current_blind_name or "")
    local blindDef = g.get_blind_def and g:get_blind_def(idx)
    local isBoss = blindDef and blindDef.id == "boss"
    placeBlindInfo(isBoss)
    if isBoss then
        bossDesc:SetText(g:get_blind_description(idx) or "")
    end
    if not opening then
        felt:SetTexture(rgb(isBoss and (inRound or selecting) and darken(bc, 0.5) or C.felt))
    end
    fitText(targetText, fmtNum(g.current_blind_target), 95, 32)
    local reward = g.get_blind_reward and g:get_blind_reward(idx) or 0
    rewardText:SetText(reward > 0 and ("Reward: " .. string.rep("$", reward)) or "No Reward")
    local row = g.get_blind_sprite_index and g:get_blind_sprite_index(idx) or 0
    local frame = math.floor(GetTime() * 10) % 21
    applyCell(blindChip, "BlindChips.tga", 36, 36, row * 21 + frame, 24, 1024, 1024)

    fitText(roundScoreText, fmtNum(g.round_score), 90, 34)

    local sel = tonumber(g.selectedHand) or -1
    if sel ~= -1 and g.handlist then
        fitText(handNameText, g.selectedHandHidden and "???" or (g.handlist[sel] or ""), 170, 36)
        handLevelText:SetText(g.selectedHandHidden and "lvl.?" or ("lvl." .. (g.selectedHandLevel or 1)))
        handLevelText:ClearAllPoints()
        handLevelText:SetPoint(
            "TOPLEFT",
            P,
            "TOPLEFT",
            math.min(281, 190 + handNameText:GetStringWidth() / 2 + 6),
            -342
        )
    else
        handNameText:SetText("")
        handLevelText:SetText("")
    end
    fitText(chipsText, fmtNum(g.selectedHandChips), 100, 42)
    fitText(multText, fmtNum(g.selectedHandMult), 100, 42)

    local between = (selecting or shopping or opening) and g.get_effective_hands_per_round
    handsText:SetText(tostring(between and g:get_effective_hands_per_round() or g.hands or 0))
    discardsText:SetText(tostring(between and g:get_effective_discards_per_round() or g.discards or 0))
    local money = tonumber(g.money) or 0
    if cashing then
        money = money - (EV.total or 0)
    end
    moneyText:SetText("$" .. tostring(money))
    anteText:SetText((g.ante or 1) .. " / 8")
    roundText:SetText(tostring(g.round or 1))

    local h = g.hand
    local canAct = h and h:has_selection() and not h._play_sequence
    playBtn:SetColor((canAct and (g.hands or 0) > 0) and C.chips or C.disabled)
    discardBtn:SetColor((canAct and (g.discards or 0) > 0) and C.mult or C.disabled)
end

local function refresh()
    local g = _G.G
    if not g then
        return
    end
    wipe(btnOfNode)

    local selecting = g.STATE == g.STATES.BLIND_SELECT
    local cashing = g.STATE == g.STATES.ROUND_EVAL
    local shopping = g.STATE == g.STATES.SHOP
    local opening = g.STATE == g.STATES.OPEN_BOOSTER
    local over = g.STATE == g.STATES.GAME_OVER or g.STATE == g.STATES.YOU_WIN
    shown(GO, over)
    if RI:IsShown() then
        updateRunInfo(g)
    end
    if g._deck_view_open then
        DV:Show()
        updateDeckView(g)
    else
        DV:Hide()
    end
    if over then
        RI:Hide()
        OP:Hide()
    end
    if over then
        updateGameOver(g)
    end
    shown(BP, opening)
    if not opening then
        packSel = nil
    end
    shown(BS, selecting)
    shown(EV, cashing)
    shown(SH, shopping)
    shown(sign, shopping or opening)
    shown(chooseText, selecting)
    local inRound = not selecting and not cashing and not shopping and not opening
    shown(BH, inRound)
    shown(R, inRound)
    local packHand = opening and g.booster_session and g.booster_session.hand_for_tarot
    if not inRound and not packHand then
        for _, b in ipairs(cardPool) do
            b:Hide()
        end
    end
    if selecting then
        updateBlindSelect(g)
    end
    if cashing then
        updateCashOut(g)
    end
    if shopping then
        updateShop(g)
    else
        shopSel = nil
    end
    if opening then
        updateBooster(g)
        if g.booster_session and g.booster_session.hand_for_tarot then
            updateCards(g, 252)
        end
    end

    refreshPanel(g, selecting, cashing, shopping, opening, inRound)

    if inRound then
        updateCards(g)
    end
    updateJokers(g)
    updatePopups(g)
    updateTags(g)

    local h = g.hand
    local anyNode = h and h.card_nodes and h.card_nodes[1]
    local cb = _G.BalatroImageDimensions and _G.BalatroImageDimensions[TEX .. "ChallengeBack.tga"]
    if g.challenge and cb then
        applyCell(deckBack, "ChallengeBack.tga", cb[1], cb[2], 0, 1, cb[3], cb[4])
    elseif anyNode then
        applyQuad(deckBack, anyNode.back_atlas, anyNode.back_quad)
    else
        local id = g.selected_deck_id or g._pending_deck_id or "b_red"
        for _, d in ipairs(_G.DECK_DEFS or {}) do
            if d.id == id then
                local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[TEX .. "Enhancers.tga"]
                if dim then
                    applyCell(
                        deckBack,
                        "Enhancers.tga",
                        72,
                        95,
                        tonumber(d.pos) or 0,
                        math.floor(dim[1] / 72),
                        dim[3],
                        dim[4]
                    )
                end
            end
        end
    end
    local remaining = g.deck and g.deck.cards and #g.deck.cards or 0
    local total = remaining
        + (g.deck and g.deck.discard_pile and #g.deck.discard_pile or 0)
        + (h and #h.card_nodes or 0)
    deckCount:SetText(remaining .. "/" .. total)
end

local errorReported = false
RoundUI:SetScript("OnUpdate", function()
    local ok, err = pcall(refresh)
    if not ok and not errorReported then
        errorReported = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4040Balatro RoundUI error:|r " .. tostring(err))
    end
end)

Balatro.RoundUI = RoundUI
