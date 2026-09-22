local _, Balatro = ...

local Challenges = {}
Balatro.Challenges = Challenges
_G.BalatroChallenges = Challenges

local ID_MAP = {
    j_golden = "j_golden_joker",
    j_selzer = "j_seltzer",
    v_nacho_tong = "v_nacho",
    c_magician = "tarot_magician",
    c_empress = "tarot_empress",
    c_emperor = "tarot_emperor",
    c_heirophant = "tarot_hierophant",
    c_chariot = "tarot_chariot",
    c_devil = "tarot_devil",
    c_tower = "tarot_tower",
    c_lovers = "tarot_lovers",
    c_judgement = "tarot_judgement",
    c_incantation = "spectral_incantation",
    c_grim = "spectral_grim",
    c_familiar = "spectral_familiar",
    c_wraith = "spectral_wraith",
    c_soul = "spectral_soul",
}
local function mapId(id)
    return ID_MAP[id] or id
end

local RANKS = {
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    T = 10,
    J = 11,
    Q = 12,
    K = 13,
    A = 14,
}
local SUITS = { D = "Diamonds", C = "Clubs", H = "Hearts", S = "Spades" }
local ENHANCEMENTS = {
    m_bonus = "bonus",
    m_mult = "mult",
    m_wild = "wild",
    m_glass = "glass",
    m_steel = "steel",
    m_stone = "stone",
    m_gold = "gold",
    m_lucky = "lucky",
}

Challenges.RULE_TEXT = {
    all_eternal = "All Jokers are Eternal",
    chips_dollar_cap = "Chips cannot exceed the current $",
    debuff_played_cards = "All Played cards become debuffed after scoring",
    discard_cost = "Discards each cost $#1#",
    flipped_cards = "1 in #1# cards are drawn face down",
    inflation = "Permanently raise prices by $1 on every purchase",
    minus_hand_size_per_X_dollar = "Hold -1 cards in hand for every $#1# you have",
    no_extra_hand_money = "Extra Hands no longer earn money",
    no_interest = "Earn no Interest at end of round",
    no_reward = "All Blinds give no reward money",
    no_reward_specific = "#1# Blinds give no reward money",
    no_shop_jokers = "Jokers no longer appear in the shop",
    set_eternal_ante = "When ante #1# boss is defeated, all Jokers become eternal",
    set_joker_slots_ante = "When ante #1# boss is defeated, set Joker slots to 0",
    consumable_slots = "#1# Consumable Slots",
    discards = "#1# discards per round",
    dollars = "Start with $#1#",
    hand_size = "#1# hand size",
    hands = "#1# hands per round",
    joker_slots = "#1# Joker Slots",
    reroll_cost = "Rerolls start at $#1#",
}
function Challenges.ruleText(rule)
    local t = Challenges.RULE_TEXT[rule.id] or rule.id
    return (t:gsub("#1#", tostring(rule.value or "")))
end

function Challenges.list()
    return _G.BALATRO_CHALLENGES or {}
end
function Challenges.byId(id)
    for _, c in ipairs(Challenges.list()) do
        if c.id == id then
            return c
        end
    end
end

local function store(g)
    BalatroData = BalatroData or {}
    BalatroData.challenges = BalatroData.challenges or {}
    local key = "P" .. tostring(g and g.get_profile_id and g:get_profile_id() or 1)
    BalatroData.challenges[key] = BalatroData.challenges[key] or {}
    return BalatroData.challenges[key]
end
function Challenges.isCompleted(g, id)
    return store(g)[id] == true
end
function Challenges.completedCount(g)
    local n = 0
    for _, c in ipairs(Challenges.list()) do
        if store(g)[c.id] then
            n = n + 1
        end
    end
    return n
end
function Challenges.deckWins(g)
    local n = 0
    for _, deck in pairs(g and g.unlocks or {}) do
        local won = false
        for _, st in pairs(type(deck) == "table" and deck.stakes or {}) do
            if type(st) == "table" and st.defeated then
                won = true
            end
        end
        if won then
            n = n + 1
        end
    end
    return n
end
Challenges.WINS_TO_UNLOCK = 5
function Challenges.unlockedCount(g)
    if Challenges.deckWins(g) < Challenges.WINS_TO_UNLOCK then
        return 0
    end
    return math.min(#Challenges.list(), Challenges.completedCount(g) + 5)
end

local function buildRules(ch)
    local r = { id = ch.id, custom = {}, modifiers = {}, no_reward = {}, banned = {}, banned_packs = {} }
    for _, v in ipairs(ch.rules and ch.rules.custom or {}) do
        if v.id == "no_reward" then
            r.no_reward[1], r.no_reward[2], r.no_reward[3] = true, true, true
        elseif v.id == "no_reward_specific" then
            r.no_reward[(v.value == "Small" and 1) or (v.value == "Big" and 2) or 3] = true
        else
            r.custom[v.id] = v.value or true
        end
    end
    for _, v in ipairs(ch.rules and ch.rules.modifiers or {}) do
        r.modifiers[v.id] = v.value
    end
    local rs = ch.restrictions or {}
    for _, list in ipairs({ rs.banned_cards or {}, rs.banned_tags or {}, rs.banned_other or {} }) do
        for _, v in ipairs(list) do
            r.banned[mapId(v.id)] = true
            for _, sub in ipairs(v.ids or {}) do
                r.banned[sub] = true
            end
        end
    end
    for key in pairs(r.banned) do
        local pack = type(key) == "string" and key:match("^p_(%a+)_")
        if pack then
            r.banned_packs[pack] = true
        end
    end
    return r
end

local function applyModifiers(g, r)
    local m = r.modifiers
    g.deck_hands, g.deck_discards, g.deck_hand_size = 0, 0, 0
    g.deck_joker_slots, g.deck_consumable_slots = 0, 0
    g.extra_hand_bonus, g.extra_discard_bonus, g._deck_no_interest = nil, nil, nil
    if m.hands then
        g.deck_hands = m.hands - 4
    end
    if m.discards then
        g.deck_discards = m.discards - 3
    end
    if m.hand_size then
        g.deck_hand_size = m.hand_size - 8
    end
    if m.joker_slots then
        g.deck_joker_slots = m.joker_slots - 5
    end
    if r.joker_slots_zeroed then
        g.deck_joker_slots = -5
    end
    if m.consumable_slots then
        g.consumable_base_capacity = m.consumable_slots
    end
    if m.reroll_cost then
        g.shop_reroll_base_cost = m.reroll_cost
    end
    if r.custom.no_interest then
        g._deck_no_interest = true
    end
    if g.refresh_joker_capacity_from_negatives then
        g:refresh_joker_capacity_from_negatives()
    end
end

local function startItems(g, ch, r)
    if r.modifiers.dollars then
        g.money = r.modifiers.dollars
    end
    for _, j in ipairs(ch.jokers or {}) do
        local params = { edition = j.edition, eternal = j.eternal or r.custom.all_eternal or nil }
        if g:add_joker_by_def(mapId(j.id), params) and j.pinned then
            local node = g.jokers[#g.jokers]
            if node then
                node.challenge_pinned = true
            end
        end
    end
    for _, c in ipairs(ch.consumeables or {}) do
        g:add_consumable(mapId(c.id))
    end
    for _, v in ipairs(ch.vouchers or {}) do
        local vid = mapId(v.id)
        if not g:has_voucher(vid) then
            table.insert(g.vouchers, vid)
            g:apply_voucher_effect(vid)
        end
    end
    local cards = ch.deck and ch.deck.cards
    if cards and g.deck then
        g.deck.cards = {}
        for _, c in ipairs(cards) do
            table.insert(g.deck.cards, {
                rank = RANKS[c.r],
                suit = SUITS[c.s],
                enhancement = c.e and ENHANCEMENTS[c.e] or nil,
                seal = c.g and c.g:lower() or nil,
            })
        end
        if g.deck.discard_pile then
            g.deck.discard_pile = {}
        end
        if g.deck.shuffle then
            g.deck:shuffle()
        end
    end
    g.hands = g:get_effective_hands_per_round()
    g.discards = g:get_effective_discards_per_round()
end

function Challenges.start(g, id)
    local ch = Challenges.byId(id)
    if not (g and ch) then
        return false
    end
    g._pending_challenge_id = id
    g._pending_deck_id = "b_red"
    g._pending_stake_id = "stake_white"
    g._menu_sub_state = nil
    g:start_new_run_from_main_menu()
    return true
end

local function wrap(class, name, fn)
    local orig = class[name]
    if type(orig) ~= "function" then
        return
    end
    class[name] = function(self, ...)
        return fn(orig, self, ...)
    end
end

local function rules(g)
    return g and g.challenge
end

function Challenges.install()
    local Game, Hand = _G.Game, _G.Hand
    if not Game or Challenges.installed then
        return
    end
    Challenges.installed = true

    wrap(Game, "initialize_run_loop", function(orig, self, ...)
        local id = self._pending_challenge_id
        self._pending_challenge_id = nil
        self.challenge, self.challenge_inflation = nil, 0
        local res = orig(self, ...)
        local ch = id and Challenges.byId(id)
        if ch then
            self.challenge = buildRules(ch)
            applyModifiers(self, self.challenge)
            startItems(self, ch, self.challenge)
            if self.init_shop_offer_queue then
                self:init_shop_offer_queue()
            end
            if self.roll_skips then
                self:roll_skips()
            end
        end
        return res
    end)

    wrap(Game, "start_new_run_from_main_menu", function(orig, self, ...)
        if not self._pending_challenge_id then
            self.challenge = nil
        end
        return orig(self, ...)
    end)

    wrap(Game, "build_run_snapshot", function(orig, self, ...)
        local snap = orig(self, ...)
        if type(snap) == "table" and self.challenge then
            snap.challenge_id = self.challenge.id
            snap.challenge_inflation = self.challenge_inflation
            snap.challenge_joker_slots_zeroed = self.challenge.joker_slots_zeroed
        end
        return snap
    end)
    wrap(Game, "load_run_snapshot", function(orig, self, snap, ...)
        local res = { orig(self, snap, ...) }
        local ch = type(snap) == "table" and snap.challenge_id and Challenges.byId(snap.challenge_id)
        self.challenge = ch and buildRules(ch) or nil
        if self.challenge then
            self.challenge_inflation = tonumber(snap.challenge_inflation) or 0
            self.challenge.joker_slots_zeroed = snap.challenge_joker_slots_zeroed
            applyModifiers(self, self.challenge)
        end
        return unpack(res)
    end)

    wrap(Game, "ensure_victory_progress_recorded", function(orig, self, ...)
        local r = rules(self)
        if r then
            store(self)[r.id] = true
            return true
        end
        return orig(self, ...)
    end)

    wrap(Game, "get_blind_reward", function(orig, self, index, ...)
        local r = rules(self)
        if r and r.no_reward[tonumber(index) or 0] then
            return 0
        end
        return orig(self, index, ...)
    end)
    wrap(Game, "start_selected_blind", function(orig, self, ...)
        local res = orig(self, ...)
        local r = rules(self)
        if r and r.no_reward[tonumber(self.current_blind_index) or 0] then
            self.current_blind_reward = 0
        end
        return res
    end)
    wrap(Game, "enter_round_win_after_blind", function(orig, self, ...)
        local r = rules(self)
        local wasBoss = tonumber(self.current_blind_index) == 3
        if r and wasBoss then
            if r.custom.set_eternal_ante and tonumber(self.ante) == r.custom.set_eternal_ante then
                for _, j in ipairs(self.jokers or {}) do
                    j.eternal = true
                end
            end
            if r.custom.set_joker_slots_ante and tonumber(self.ante) == r.custom.set_joker_slots_ante then
                r.joker_slots_zeroed = true
                applyModifiers(self, r)
            end
        end
        local res = orig(self, ...)
        if r then
            for i, line in ipairs(self._round_win_display_lines or {}) do
                local label = tostring(line[1] or "")
                local revealed = i <= (tonumber(self._round_win_lines_revealed) or 0)
                if
                    not revealed
                    and (
                        (r.custom.no_extra_hand_money and label:match("^Hands left"))
                        or (r.custom.no_interest and label:match("^Interest"))
                    )
                then
                    line[2] = 0
                end
            end
        end
        return res
    end)

    wrap(Game, "joker_allowed_in_random_pool", function(orig, self, id, ...)
        local r = rules(self)
        if r and r.banned[id] then
            return false
        end
        return orig(self, id, ...)
    end)
    wrap(Game, "_roll_shop_queue_joker_offer", function(orig, self, ...)
        local r = rules(self)
        if r and r.custom.no_shop_jokers then
            return nil
        end
        return orig(self, ...)
    end)
    wrap(Game, "_shop_queue_emergency_joker_offer", function(orig, self, ...)
        local r = rules(self)
        if r and r.custom.no_shop_jokers and self._roll_shop_queue_consumable_offer then
            local c = self:_roll_shop_queue_consumable_offer("planet")
                or self:_roll_shop_queue_consumable_offer("tarot")
            if c then
                return c
            end
        end
        return orig(self, ...)
    end)
    wrap(Game, "random_consumable_id_of_kind", function(orig, self, kind, exclude, ...)
        local r = rules(self)
        if r then
            local ex = {}
            for k, v in pairs(exclude or {}) do
                ex[k] = v
            end
            for k in pairs(r.banned) do
                ex[k] = true
            end
            exclude = ex
        end
        return orig(self, kind, exclude, ...)
    end)
    wrap(Game, "_roll_shop_queue_consumable_offer", function(orig, self, kind, ...)
        local r = rules(self)
        for _ = 1, 12 do
            local offer = orig(self, kind, ...)
            if not (r and offer and r.banned[offer.id]) then
                return offer
            end
        end
        return nil
    end)
    wrap(Game, "_shop_pick_unique_consumable_ids", function(orig, self, kind, count, ...)
        local r = rules(self)
        local ids = orig(self, kind, (tonumber(count) or 1) + (r and 6 or 0), ...)
        if not r or type(ids) ~= "table" then
            return ids
        end
        local out = {}
        for _, id in ipairs(ids) do
            if not r.banned[id] and #out < (tonumber(count) or 1) then
                out[#out + 1] = id
            end
        end
        return out
    end)
    wrap(Game, "_shop_voucher_candidate_ids", function(orig, self, ...)
        local ids = orig(self, ...)
        local r = rules(self)
        if not r or type(ids) ~= "table" then
            return ids
        end
        local out = {}
        for _, id in ipairs(ids) do
            if not r.banned[id] then
                out[#out + 1] = id
            end
        end
        return out
    end)
    wrap(Game, "_roll_booster_offer_profile", function(orig, self, ...)
        local r = rules(self)
        local p = orig(self, ...)
        for _ = 1, 30 do
            if not (r and type(p) == "table" and r.banned_packs[p.pack or ""]) then
                break
            end
            p = orig(self, ...)
        end
        return p
    end)
    wrap(Game, "roll_skips", function(orig, self, ...)
        local r = rules(self)
        if not (r and type(self.P_TAGS) == "table") then
            return orig(self, ...)
        end
        local hidden = {}
        for key in pairs(r.banned) do
            if self.P_TAGS[key] then
                hidden[key] = self.P_TAGS[key]
                self.P_TAGS[key] = nil
            end
        end
        local res = { pcall(orig, self, ...) }
        for key, def in pairs(hidden) do
            self.P_TAGS[key] = def
        end
        if not res[1] then
            error(res[2], 0)
        end
        return unpack(res, 2)
    end)
    wrap(Game, "get_boss_blind_pool", function(orig, self, ...)
        local pool = orig(self, ...)
        local r = rules(self)
        if not r or type(pool) ~= "table" then
            return pool
        end
        local out = {}
        for _, id in ipairs(pool) do
            if not r.banned[id] then
                out[#out + 1] = id
            end
        end
        return #out > 0 and out or pool
    end)
    local function inflate(orig, self, ...)
        local price = orig(self, ...)
        if rules(self) and rules(self).custom.inflation then
            return (tonumber(price) or 0) + (tonumber(self.challenge_inflation) or 0)
        end
        return price
    end
    wrap(Game, "get_shop_offer_price", inflate)
    wrap(Game, "get_shop_booster_price", inflate)
    wrap(Game, "get_shop_voucher_price", inflate)
    for _, name in ipairs({ "buy_shop_joker", "buy_shop_booster", "buy_shop_voucher", "buy_and_use_shop_consumable" }) do
        wrap(Game, name, function(orig, self, ...)
            local ok = orig(self, ...)
            if ok and rules(self) and rules(self).custom.inflation then
                self.challenge_inflation = (tonumber(self.challenge_inflation) or 0) + 1
            end
            return ok
        end)
    end

    wrap(Game, "add_joker_by_def", function(orig, self, id, params, ...)
        local r = rules(self)
        if r and r.custom.all_eternal then
            params = type(params) == "table" and params or {}
            params.eternal = true
        end
        return orig(self, id, params, ...)
    end)
    wrap(Game, "swap_jokers_at_indices", function(orig, self, a, b, ...)
        local ja, jb = self.jokers and self.jokers[a], self.jokers and self.jokers[b]
        if (ja and ja.challenge_pinned) or (jb and jb.challenge_pinned) then
            return false
        end
        return orig(self, a, b, ...)
    end)

    wrap(Game, "get_effective_hand_size_limit", function(orig, self, ...)
        local limit = orig(self, ...)
        local r = rules(self)
        local per = r and tonumber(r.custom.minus_hand_size_per_X_dollar)
        if per and per > 0 then
            limit = math.max(1, limit - math.floor(math.max(0, tonumber(self.money) or 0) / per))
        end
        return limit
    end)
    wrap(Game, "boss_on_card_drawn", function(orig, self, node, ...)
        local res = orig(self, node, ...)
        local r = rules(self)
        local n = r and tonumber(r.custom.flipped_cards)
        if n and n > 0 and node and node.set_face_up and math.random(1, n) == 1 then
            node:set_face_up(false)
        end
        return res
    end)
    wrap(Game, "boss_is_card_debuffed_for_scoring", function(orig, self, node, ...)
        if node and node.card_data and node.card_data.challenge_debuffed then
            return true
        end
        return orig(self, node, ...)
    end)
    Game.mod_chips = function(self, chips)
        if rules(self) and rules(self).custom.chips_dollar_cap then
            return math.min(chips, math.max(tonumber(self.money) or 0, 0))
        end
        return chips
    end
    if Hand then
        wrap(Hand, "discard_selected", function(orig, self, ...)
            local g = _G.G
            local before = g and g.discards
            local res = orig(self, ...)
            local r = rules(g)
            if r and r.custom.discard_cost and g.discards ~= before then
                g.money = (tonumber(g.money) or 0) - (tonumber(r.custom.discard_cost) or 0)
            end
            return res
        end)
    end

    local watcher = CreateFrame("Frame")
    local lastSeq
    watcher:SetScript("OnUpdate", function()
        local g = _G.G
        local seq = g and g.hand and g.hand._play_sequence
        if lastSeq and seq ~= lastSeq and rules(g) and rules(g).custom.debuff_played_cards then
            for _, node in ipairs(lastSeq.cards or {}) do
                if node.counts_for_play_score and node.card_data then
                    node.card_data.challenge_debuffed = true
                end
            end
        end
        lastSeq = seq
    end)
end
