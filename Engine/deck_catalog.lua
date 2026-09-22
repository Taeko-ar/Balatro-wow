DECK_DEFS = {
    {
        id = "b_red",
        name = "Red Deck",
        order = 1,
        pos = 0,
        unlocked = true,
        stake = 1,
        config = { discards = 1 },
        description = "+1 Discard every round",
    },
    {
        id = "b_blue",
        name = "Blue Deck",
        order = 2,
        pos = 14,
        unlocked = false,
        stake = 1,
        unlock_condition = { type = "discover_amount", amount = 20, text = "Discover 20 Cards" },
        config = { hands = 1 },
        description = "+1 Hand every round",
    },
    {
        id = "b_yellow",
        name = "Yellow Deck",
        order = 3,
        pos = 15,
        unlocked = false,
        stake = 1,
        unlock_condition = { type = "discover_amount", amount = 50, text = "Discover 50 Cards" },
        config = { dollars = 10 },
        description = "Start with $10",
    },
    {
        id = "b_green",
        name = "Green Deck",
        order = 4,
        pos = 16,
        unlocked = false,
        stake = 1,
        unlock_condition = { type = "discover_amount", amount = 75, text = "Discover 75 Cards" },
        config = { extra_hand_bonus = 2, extra_discard_bonus = 1, no_interest = true },
        description = "+$2 per remaining Hand, +$1 per remaining Discard. No interest earned.",
    },
    {
        id = "b_black",
        name = "Black Deck",
        order = 5,
        pos = 17,
        unlocked = false,
        stake = 1,
        unlock_condition = { type = "discover_amount", amount = 100, text = "Discover 10 Cards" },
        config = { joker_slots = 1, hands = -1 },
        description = "+1 Joker slot. -1 Hand per round.",
    },
    {
        id = "b_magic",
        name = "Magic Deck",
        order = 6,
        pos = 21,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            deck_id = "b_red",
            text = "Win a run with the Red Deck on any difficulty",
        },
        config = {},
        description = "Start with Crystal Ball and 2 copies of The Fool",
        start_vouchers = { "v_crystal_ball" },
        start_consumables = { "tarot_fool", "tarot_fool" },
    },
    {
        id = "b_nebula",
        name = "Nebula Deck",
        order = 7,
        pos = 3,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            deck_id = "b_blue",
            text = "Win a run with the Blue Deck on any difficulty",
        },
        config = { consumable_slots = -1 },
        description = "-1 Consumable slot. Start run with the Telescope voucher ",
        start_vouchers = { "v_telescope" },
    },
    {
        id = "b_ghost",
        name = "Ghost Deck",
        order = 8,
        pos = 20,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            deck_id = "b_yellow",
            text = "Win a run with the Yellow Deck on any difficulty",
        },
        config = { spectral_rate = 2 },
        description = "Spectral cards may appear in the shop. Start with a Hex card.",
        start_consumables = { "spectral_hex" },
    },
    {
        id = "b_abandoned",
        name = "Abandoned Deck",
        order = 9,
        pos = 24,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            deck_id = "b_green",
            text = "Win a run with the Green Deck on any difficulty",
        },
        config = { no_face_cards = true },
        description = "Start run with no Face Cards in your deck ",
    },
    {
        id = "b_checkered",
        name = "Checkered Deck",
        order = 10,
        pos = 22,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            deck_id = "b_black",
            text = "Win a run with the Black Deck on any difficulty",
        },
        config = { suit_split = { "Spades", "Hearts" } },
        description = "Start run with 26 Spades and 26 Hearts in deck ",
    },
    {
        id = "b_zodiac",
        name = "Zodiac Deck",
        order = 11,
        pos = 31,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            stake_id = "stake_red",
            text = "Win a run with any deck on the Red Stake difficulty",
        },
        config = {},
        description = "Start run with Tarot Merchant, Planet Merchant, and Overstock",
        start_vouchers = { "v_tarot_merchant", "v_planet_merchant", "v_overstock" },
    },
    {
        id = "b_painted",
        name = "Painted Deck",
        order = 12,
        pos = 25,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            stake_id = "stake_green",
            text = "Win a run with any deck on the Green Stake difficulty",
        },
        config = { hand_size = 2, joker_slots = -1 },
        description = "+2 Hand size. -1 Joker slot.",
    },
    {
        id = "b_anaglyph",
        name = "Anaglyph Deck",
        order = 13,
        pos = 30,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            stake_id = "stake_black",
            text = "Win a run with any deck on the Black Stake difficulty",
        },
        config = {},
        description = "After defeating each Boss Blind, gain a Double Tag.",
        special = "anaglyph",
    },
    {
        id = "b_plasma",
        name = "Plasma Deck",
        order = 14,
        pos = 18,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            stake_id = "stake_blue",
            text = "Win a run with any deck on the Blue Stake difficulty",
        },
        config = {},
        description = "Balance Chips and Mult when scoring. x2 Base Blind Size.",
        special = "plasma",
    },
    {
        id = "b_erratic",
        name = "Erratic Deck",
        order = 15,
        pos = 23,
        unlocked = false,
        stake = 1,
        unlock_condition = {
            type = "deck_win",
            stake_id = "stake_orange",
            text = "Win a run with any deck on the Orange Stake difficulty",
        },
        config = {},
        description = "All card Ranks and Suits in deck are randomised.",
        special = "erratic",
    },
}

DECK_DEFS_BY_ID = {}
for _, d in ipairs(DECK_DEFS) do
    DECK_DEFS_BY_ID[d.id] = d
end

STAKE_DEFS = {
    {
        id = "stake_white",
        name = "White Stake",
        order = 1,
        pos = 0,
        unlocked = true,
        colour = { 1, 1, 1, 1 },
        config = { ante_mult = 0 },
        description = "No modifiers.",
    },
    {
        id = "stake_red",
        name = "Red Stake",
        order = 2,
        pos = 1,
        unlocked = false,
        colour = { 0.996, 0.373, 0.333, 1 },
        config = { ante_mult = 0, no_small_reward = true },
        description = "Small Blind gives no reward money",
    },
    {
        id = "stake_green",
        name = "Green Stake",
        order = 3,
        pos = 2,
        unlocked = false,
        colour = { 0.294, 0.761, 0.573, 1 },
        config = { ante_mult = 1, no_small_reward = true },
        description = "Required score scales faster for each Ante",
    },
    {
        id = "stake_black",
        name = "Black Stake",
        order = 4,
        pos = 4,
        unlocked = false,
        colour = { 0, 0, 0, 1 },
        config = { ante_mult = 1, no_small_reward = true, eternal_jokers = true },
        description = "30% chance for Jokers in shops or booster packs to have an Eternal sticker",
    },
    {
        id = "stake_blue",
        name = "Blue Stake",
        order = 5,
        pos = 3,
        unlocked = false,
        colour = { 0, 0.616, 1, 1 },
        config = {
            ante_mult = 1,
            no_small_reward = true,
            eternal_jokers = true,
            stake_discard = -1,
        },
        description = "-1 Discard ",
    },
    {
        id = "stake_purple",
        name = "Purple Stake",
        order = 6,
        pos = 5,
        unlocked = false,
        colour = { 0.533, 0.404, 0.647, 1 },
        config = {
            ante_mult = 2,
            no_small_reward = true,
            eternal_jokers = true,
            stake_discard = -1,
        },
        description = "Required score scales even faster for each Ante",
    },
    {
        id = "stake_orange",
        name = "Orange Stake",
        order = 7,
        pos = 6,
        unlocked = false,
        colour = { 0.992, 0.635, 0, 1 },
        config = {
            ante_mult = 2,
            no_small_reward = true,
            eternal_jokers = true,
            stake_discard = -1,
            perishable_jokers = true,
        },
        description = "30% chance for Jokers in shops or booster packs to have a Perishable sticker",
    },
    {
        id = "stake_gold",
        name = "Gold Stake",
        order = 8,
        pos = 7,
        unlocked = false,
        colour = { 0.918, 0.753, 0.345, 1 },
        config = {
            ante_mult = 2,
            no_small_reward = true,
            eternal_jokers = true,
            stake_discard = -1,
            perishable_jokers = true,
            rental_jokers = true,
        },
        description = "30% chance for Jokers in shops or booster packs to have a Rental sticker",
    },
}

STAKE_DEFS_BY_ID = {}
for _, s in ipairs(STAKE_DEFS) do
    STAKE_DEFS_BY_ID[s.id] = s
end

function Game:apply_deck_config(deck_id)
    local def = DECK_DEFS_BY_ID[deck_id or "b_red"]
    if not def then
        def = DECK_DEFS[1]
    end

    self.selected_deck_id = def.id
    local cfg = def.config or {}

    self.deck_hands = (tonumber(cfg.hands) or 0)
    self.deck_discards = (tonumber(cfg.discards) or 0)

    if (tonumber(cfg.dollars) or 0) ~= 0 then
        self.money = math.max(0, (tonumber(self.money) or 0) + (tonumber(cfg.dollars) or 0))
    end

    if (tonumber(cfg.extra_hand_bonus) or 0) ~= 0 then
        self.extra_hand_bonus = (tonumber(cfg.extra_hand_bonus) or 0)
    end

    if (tonumber(cfg.extra_discard_bonus) or 0) ~= 0 then
        self.extra_discard_bonus = (tonumber(cfg.extra_discard_bonus) or 0)
    end

    if (tonumber(cfg.hand_size) or 0) ~= 0 then
        self.deck_hand_size = (tonumber(cfg.hand_size) or 0)
    end

    if (tonumber(cfg.consumable_slots) or 0) ~= 0 then
        self.deck_consumable_slots = (tonumber(cfg.consumable_slots) or 0)
    end

    if cfg.no_interest then
        self._deck_no_interest = true
    end

    if (tonumber(cfg.joker_slots) or 0) ~= 0 then
        self.deck_joker_slots = (tonumber(cfg.joker_slots) or 0)
        self:refresh_joker_capacity_from_negatives()
    end

    if (tonumber(cfg.spectral_rate) or 0) ~= 0 then
        self.deck_spectral_rate = (tonumber(cfg.spectral_rate) or 0)
    end

    if def.special == "erratic" then
        self:_apply_erratic_deck()
    elseif cfg.no_face_cards then
        self:_apply_no_face_cards()
    elseif cfg.suit_filter then
        self:_apply_suit_filter(cfg.suit_filter)
    elseif cfg.suit_split then
        self:_apply_suit_split(cfg.suit_split)
    end

    if def.start_consumables and type(def.start_consumables) == "table" then
        for _, cid in ipairs(def.start_consumables) do
            self:_give_start_consumable(cid)
        end
    end

    if def.start_vouchers and type(def.start_vouchers) == "table" then
        for _, vid in ipairs(def.start_vouchers) do
            if not self:has_voucher(vid) then
                table.insert(self.vouchers, vid)
                self:apply_voucher_effect(vid)
            end
        end
    end

    self._deck_special = def.special or nil
    if self.refresh_playing_card_backs then
        self:refresh_playing_card_backs()
    end
end

function Game:get_selected_deck_back_index()
    local id = self.selected_deck_id or self._pending_deck_id or "b_red"
    local def = DECK_DEFS_BY_ID and DECK_DEFS_BY_ID[id]
    if not def and DECK_DEFS then
        def = DECK_DEFS[1]
    end
    return tonumber(def and def.pos) or 0
end

function Game:refresh_playing_card_backs()
    for _, node in ipairs(self.nodes or {}) do
        if node and node.card_data and node.refresh_quads then
            node:refresh_quads()
        end
    end
end

function Game:apply_stake_config(stake_id)
    local def = STAKE_DEFS_BY_ID[stake_id or "stake_white"]
    if not def then
        def = STAKE_DEFS[1]
    end

    self.selected_stake_id = def.id
    self.selected_stake_order = def.order
    local cfg = def.config or {}

    self._stake_no_small_reward = cfg.no_small_reward or false
    self._stake_eternal_jokers = cfg.eternal_jokers or false
    self._stake_discard = cfg.stake_discard or 0
    self._stake_perishable_jokers = cfg.perishable_jokers or false
    self._stake_rental_jokers = cfg.rental_jokers or false
    print("Stake Config Applied:", def.id)
    print(
        "Stake Config:",
        self._stake_no_small_reward,
        self._stake_eternal_jokers,
        self._stake_discard,
        self._stake_perishable_jokers,
        self._stake_rental_jokers
    )
end

function Game:_apply_erratic_deck()
    if not self.deck then
        return
    end
    local suits = { "Hearts", "Clubs", "Diamonds", "Spades" }
    for _, c in ipairs(self.deck.cards or {}) do
        c.rank = math.random(2, 14)
        c.suit = suits[math.random(1, 4)]
    end
end

function Game:_apply_no_face_cards()
    if not self.deck then
        return
    end
    local kept = {}
    for _, c in ipairs(self.deck.cards or {}) do
        if not (c.rank >= 11 and c.rank <= 13) then
            table.insert(kept, c)
        end
    end
    self.deck.cards = kept
end

function Game:_apply_suit_filter(suit)
    if not self.deck then
        return
    end
    local kept = {}
    for _, c in ipairs(self.deck.cards or {}) do
        if c.suit == suit then
            table.insert(kept, c)
        end
    end
    self.deck.cards = kept
end

function Game:_apply_suit_split(suits)
    if not self.deck or type(suits) ~= "table" or #suits < 2 then
        return
    end
    local new_cards = {}
    for _, suit in ipairs(suits) do
        for r = 2, 14 do
            for _ = 1, 2 do
                table.insert(new_cards, { rank = r, suit = suit, enhancement = nil, seal = nil })
            end
        end
    end
    self.deck.cards = new_cards
end

function Game:_give_start_consumable(cid)
    self:add_consumable(cid)
end
