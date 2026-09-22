local DeckViewUI = {}
local SCREEN_W, SCREEN_H = 320, 240
local CARD_W, CARD_H = 71, 95
local TAP_THRESHOLD = 15

local _, _ = 400, 240

local SUITS = { "Hearts", "Clubs", "Diamonds", "Spades" }

sysDepth = 0
buttonHeight = 1
textHeight = 2
signHeight = 3
jokerHeight = 2
PopupHeight = 4

function DeckViewUI.group_by_suit(cards)
    local by_suit = {}
    for _, suit in ipairs(SUITS) do
        by_suit[suit] = {}
    end
    for _, card_data in ipairs(cards or {}) do
        local suit = card_data and card_data.suit
        if suit and by_suit[suit] then
            by_suit[suit][#by_suit[suit] + 1] = card_data
        end
    end
    for _, suit in ipairs(SUITS) do
        table.sort(by_suit[suit], function(a, b)
            return (tonumber(a.rank) or 0) < (tonumber(b.rank) or 0)
        end)
    end
    return by_suit
end

function DeckViewUI.active_suits(rows)
    local active = {}
    for _, suit in ipairs(SUITS) do
        if rows[suit] and #rows[suit] > 0 then
            active[#active + 1] = suit
        end
    end
    return active
end

local ROW_GAP = 2
local ROW_PAD_Y = 1

local function compute_fanned_step(n, area_w, card_w, gap)
    gap = gap or ROW_GAP
    n = tonumber(n) or 0
    card_w = tonumber(card_w) or CARD_W
    area_w = tonumber(area_w) or SCREEN_W
    if n <= 0 then
        return 0, 0, 0
    end
    if n == 1 then
        return 0, card_w, math.floor((area_w - card_w) * 0.5 + 0.5)
    end
    local natural_step = card_w + gap
    local natural_span = card_w + (n - 1) * natural_step
    local step, total_span
    if natural_span <= area_w then
        step = natural_step
        total_span = natural_span
    else
        step = (area_w - card_w) / (n - 1)
        total_span = (n - 1) * step + card_w
    end
    local start_x = math.floor((area_w - total_span) * 0.5 + 0.5)
    return step, total_span, start_x
end

function DeckViewUI._chrome_metrics(row_count)
    local margin_x = 2
    local label_w = 2
    local header_h = 16
    local footer_h = 16
    row_count = tonumber(row_count) or 0
    local content_h = SCREEN_H - header_h - footer_h
    local row_h = row_count > 0 and (content_h / row_count) or 0
    local area_w = SCREEN_W - margin_x * 4 - label_w
    local scale = row_count > 0 and math.min(1, (row_h - ROW_PAD_Y * 2) / CARD_H) or 1
    local card_w = CARD_W * scale
    local card_h = CARD_H * scale
    return {
        margin_x = margin_x,
        label_w = label_w,
        header_h = header_h,
        footer_h = footer_h,
        row_h = row_h,
        area_w = area_w,
        row_start_x = margin_x + label_w,
        scale = scale,
        card_w = card_w,
        card_h = card_h,
    }
end

function DeckViewUI._layout_row(nodes, m, row_y)
    local n = #(nodes or {})
    if n == 0 then
        return
    end
    local step, _, rel_start = compute_fanned_step(n, m.area_w, m.card_w, ROW_GAP)
    local card_y = row_y + math.floor((m.row_h - m.card_h) * 0.5 + 0.5)
    local x = m.row_start_x + rel_start
    for i, node in ipairs(nodes) do
        if node and node.T then
            local px = x + (i - 1) * step
            node.T.x = px
            node.T.y = card_y
            node.T.r = 0
            node.T.scale = m.scale
            if node.collision_offset then
                node.collision_offset.x = 0
                node.collision_offset.y = 0
            end
            if not (node.states and node.states.drag and node.states.drag.is) then
                node.VT.x = px
                node.VT.y = card_y
                node.VT.r = 0
                node.VT.scale = m.scale
            end
        end
    end
end

function DeckViewUI.layout(game)
    local rows = game._deck_view_rows
    if type(rows) ~= "table" then
        return
    end
    local active = DeckViewUI.active_suits(rows)
    local m = DeckViewUI._chrome_metrics(#active)
    for row_i, suit in ipairs(active) do
        local row_y = m.header_h + (row_i - 1) * m.row_h
        DeckViewUI._layout_row(rows[suit], m, row_y)
    end
end

function DeckViewUI.build(game)
    DeckViewUI.destroy(game)
    if not game or not game.deck then
        return
    end

    game._deck_view_rows = {}
    game._deck_view_nodes = {}
    for _, suit in ipairs(SUITS) do
        game._deck_view_rows[suit] = {}
    end

    local by_suit = DeckViewUI.group_by_suit(game.deck.cards)
    for _, suit in ipairs(SUITS) do
        for _, card_data in ipairs(by_suit[suit]) do
            local copy = Deck.copy_card_data(card_data)
            if copy and game.ensure_card_uid then
                game:ensure_card_uid(copy)
            end
            local node = Card(0, 0, CARD_W, CARD_H, copy, nil, { face_up = true })
            node._deck_view_card = true
            node.states.click.can = true
            node.states.drag.can = true
            game:add(node)
            game._deck_view_rows[suit][#game._deck_view_rows[suit] + 1] = node
            game._deck_view_nodes[#game._deck_view_nodes + 1] = node
        end
    end

    DeckViewUI.layout(game)

    if game.hand and game.hand.card_nodes then
        for _, node in ipairs(game.hand.card_nodes) do
            node.states.visible = false
            node._deck_view_hidden = true
        end
    end
end

function DeckViewUI.destroy(game)
    if not game then
        return
    end
    for _, node in ipairs(game._deck_view_nodes or {}) do
        if node then
            node.selected = false
            game:remove(node)
        end
    end
    game._deck_view_rows = nil
    game._deck_view_nodes = nil

    if game.hand and game.hand.card_nodes then
        for _, node in ipairs(game.hand.card_nodes) do
            if node and node._deck_view_hidden then
                node.states.visible = true
                node._deck_view_hidden = nil
            end
        end
    end
end

function DeckViewUI.toggle_tooltip(game, node)
    if not game or not node or not node._deck_view_card then
        return
    end
    if game.active_tooltip_card == node then
        game.active_tooltip_card = nil
    else
        game.active_tooltip_card = node
        game.active_tooltip_joker = nil
        game.active_tooltip_consumable_index = nil
        if game.move_to_front then
            game:move_to_front(node)
        end
    end
end

function DeckViewUI.get_node_at(game, x, y)
    for i = #(game._deck_view_nodes or {}), 1, -1 do
        local node = game._deck_view_nodes[i]
        if node and node.states and node.states.click.can and game:point_in_rect(x, y, node) then
            return node
        end
    end
    return nil
end

function DeckViewUI.handle_touchpressed(game, id, x, y)
    game.touch_start_x = x
    game.touch_start_y = y
    local node = DeckViewUI.get_node_at(game, x, y)
    if node and node.touchpressed then
        node:touchpressed(id, x, y)
        game.dragging = node
        game:move_to_front(node)
    else
        game.dragging = nil
    end
end

function DeckViewUI.handle_touchmoved(game, id, x, y, dx, dy)
    if game.dragging and game.dragging.touchmoved then
        game.dragging:touchmoved(id, x, y, dx, dy)
    end
end

function DeckViewUI.handle_touchreleased(game, id, x, y)
    local released = game.dragging
    if released and released.touchreleased then
        released:touchreleased(id, x, y)
    end
    local start_x = game.touch_start_x or x
    local start_y = game.touch_start_y or y
    local dx = x - start_x
    local dy = y - start_y
    local dist = math.sqrt(dx * dx + dy * dy)
    if released and released._deck_view_card and dist < TAP_THRESHOLD then
        DeckViewUI.toggle_tooltip(game, released)
    elseif released and released._deck_view_card and dist >= TAP_THRESHOLD then
        DeckViewUI.layout(game)
    elseif dist < TAP_THRESHOLD then
        game.active_tooltip_card = nil
    end
    game.dragging = nil
end

function DeckViewUI.update(game, dt)
    if not game then
        return
    end
    local target = game._deck_view_hand_panel_open and 1 or 0
    local t = tonumber(game._deck_view_hand_panel_t) or 0
    local speed = math.min(1, 10 * (tonumber(dt) or 0))
    t = t + (target - t) * speed
    if math.abs(t - target) < 0.001 then
        t = target
    end
    game._deck_view_hand_panel_t = t
end

function DeckViewUI.draw_bottom(game)
    love.graphics.setColor(G.C.PANEL)
    love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)

    local count = game.deck and game.deck:size() or #(game._deck_view_nodes or {})
    love.graphics.setColor(game.C.WHITE)
    love.graphics.setFont(game.FONTS.PIXEL.SMALL)
    love.graphics.printf("Draw pile (" .. tostring(count) .. ")", 0, 4, SCREEN_W, "center")

    local SUIT_COLORS = {
        Hearts = G.C.Hearts or { 0.92, 0.25, 0.28 },
        Diamonds = G.C.Diamonds or { 0.92, 0.25, 0.28 },
        Clubs = G.C.Clubs or { 0.2, 0.2, 0.22 },
        Spades = G.C.Spades or { 0.2, 0.2, 0.22 },
    }

    local rows = game._deck_view_rows or {}
    local active = DeckViewUI.active_suits(rows)
    local m = DeckViewUI._chrome_metrics(#active)
    love.graphics.setFont(game.FONTS.PIXEL.MEDIUM)
    for _, suit in ipairs(active) do
        local sc = SUIT_COLORS[suit]
        love.graphics.setColor(sc[1], sc[2], sc[3], 1)
    end

    love.graphics.setColor(1, 1, 1, 1)
    for _, node in ipairs(game._deck_view_nodes or {}) do
        if node and node.draw then
            node:draw()
        end
    end

    love.graphics.setFont(game.FONTS.PIXEL.SMALL)
    love.graphics.setColor(game.C.WHITE or { 0.65, 0.65, 0.65, 1 })
    local footer = "SELECT / B to close"
    if not game._deck_view_hand_panel_open and (tonumber(game._deck_view_hand_panel_t) or 0) <= 0.01 then
        footer = footer .. "  Right: Hand Levels"
    end
    love.graphics.printf(footer, 0, SCREEN_H - m.footer_h, SCREEN_W, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

function DeckViewUI.draw_tooltips(game)
    for _, node in ipairs(game._deck_view_nodes or {}) do
        if node and node.draw_tooltip_overlay then
            node:draw_tooltip_overlay()
        end
    end
end

return DeckViewUI
