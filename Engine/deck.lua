Deck = Object:extend()

local SUITS = { "Hearts", "Clubs", "Diamonds", "Spades" }
local MIN_RANK = 2
local MAX_RANK = 14

function Deck.copy_card_data(data)
    if type(data) ~= "table" then
        return nil
    end
    local c = {}
    for k, v in pairs(data) do
        c[k] = v
    end
    return c
end

function Deck:init()
    self.cards = {}
    self.discard_pile = {}
    self:fill()
end

function Deck:fill()
    self.cards = {}
    for _, suit in ipairs(SUITS) do
        for rank = MIN_RANK, MAX_RANK do
            table.insert(self.cards, { rank = rank, suit = suit, enhancement = nil, seal = nil })
        end
    end
end

function Deck:shuffle()
    local n = #self.cards
    for i = n, 2, -1 do
        local j = math.random(1, i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

function Deck:push_discard(card_data)
    local c = Deck.copy_card_data(card_data)
    if c then
        table.insert(self.discard_pile, c)
    end
end

function Deck:move_draw_pile_to_discard()
    while #self.cards > 0 do
        local c = table.remove(self.cards)
        self:push_discard(c)
    end
end

function Deck:shuffle_discard_into_draw()
    if #self.discard_pile == 0 then
        return
    end
    for _, c in ipairs(self.discard_pile) do
        table.insert(self.cards, c)
    end
    self.discard_pile = {}
    self:shuffle()
end

function Deck:end_round()
    self:move_draw_pile_to_discard()
    self:shuffle_discard_into_draw()
end

function Deck:recycle_all(hand_cards, hand_queue)
    local merged = {}
    local function add(c)
        local copy = Deck.copy_card_data(c)
        if copy then
            merged[#merged + 1] = copy
        end
    end
    for _, c in ipairs(self.discard_pile) do
        add(c)
    end
    for _, c in ipairs(self.cards) do
        add(c)
    end
    for _, c in ipairs(hand_cards or {}) do
        add(c)
    end
    for _, c in ipairs(hand_queue or {}) do
        add(c)
    end
    self.cards = merged
    self.discard_pile = {}
    if #self.cards > 0 then
        self:shuffle()
    end
end

function Deck:draw()
    if #self.cards == 0 then
        return nil
    end
    return table.remove(self.cards)
end

function Deck:random_card()
    local n = #self.cards
    if n == 0 then
        return nil
    end
    local i = math.random(1, n)
    return Deck.copy_card_data(self.cards[i])
end

function Deck:size()
    return #self.cards
end

function Deck:insert_random(card_data)
    local c = Deck.copy_card_data(card_data)
    if not c then
        return
    end
    local n = #self.cards
    local pos = math.random(1, n + 1)
    table.insert(self.cards, pos, c)
end

function Deck:empty()
    return #self.cards == 0
end
