function HEX(hex)
    if #hex <= 6 then
        hex = hex .. "FF"
    end
    local _, _, r, g, b, a = hex:find("(%x%x)(%x%x)(%x%x)(%x%x)")
    local color = { tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 or 255 }
    return color
end

function copy_table(t)
    if type(t) ~= "table" then
        return t
    end
    local nt = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            nt[k] = copy_table(v)
        else
            nt[k] = v
        end
    end
    return nt
end

function Game:set_globals()
    self.F_QUIT_BUTTON = true
    self.F_SKIP_TUTORIAL = false
    self.F_BASIC_CREDITS = false
    self.F_EXTERNAL_LINKS = true
    self.F_ENABLE_PERF_OVERLAY = false
    self.F_NO_SAVING = false
    self.F_MUTE = false
    self.F_SOUND_THREAD = true
    self.F_VIDEO_SETTINGS = true
    self.F_CTA = false
    self.F_VERBOSE = true
    self.F_HTTP_SCORES = false
    self.F_RUMBLE = nil
    self.F_CRASH_REPORTS = false
    self.F_NO_ERROR_HAND = false
    self.F_SWAP_AB_PIPS = false
    self.F_SWAP_AB_BUTTONS = false
    self.F_SWAP_XY_BUTTONS = false
    self.F_NO_ACHIEVEMENTS = false
    self.F_DISP_USERNAME = nil
    self.F_ENGLISH_ONLY = nil
    self.F_GUIDE = false
    self.F_JAN_CTA = false
    self.F_HIDE_BG = false
    self.F_TROPHIES = false
    self.F_PS4_PLAYSTATION_GLYPHS = false
    self.F_LOCAL_CLIPBOARD = false
    self.F_SAVE_TIMER = 30
    self.F_MOBILE_UI = false
    self.F_HIDE_BETA_LANGS = nil

    self.SEED = os.time()
    self.TIMERS = {
        TOTAL = 0,
        REAL = 0,
        REAL_SHADER = 0,
        UPTIME = 0,
        BACKGROUND = 0,
    }
    self.FRAMES = {
        DRAW = 0,
        MOVE = 0,
    }
    self.exp_times = { xy = 0, scale = 0, r = 0 }
    self.SETTINGS = {
        GAMESPEED = 1,
        SOUND = {
            music_volume = 100,
        },
        GRAPHICS = {
            texture_scaling = 1,
        },
    }

    self.COLLABS = {
        pos = { Jack = { x = 0, y = 0 }, Queen = { x = 1, y = 0 }, King = { x = 2, y = 0 } },
        options = {
            Spades = {
                "default",
                "collab_TW",
                "collab_CYP",
                "collab_SK",
                "collab_DS",
                "collab_AC",
                "collab_STP",
            },
            Hearts = {
                "default",
                "collab_AU",
                "collab_TBoI",
                "collab_CL",
                "collab_D2",
                "collab_CR",
                "collab_BUG",
            },
            Clubs = {
                "default",
                "collab_VS",
                "collab_STS",
                "collab_PC",
                "collab_WF",
                "collab_FO",
                "collab_DBD",
            },
            Diamonds = {
                "default",
                "collab_DTD",
                "collab_SV",
                "collab_EG",
                "collab_XR",
                "collab_C7",
                "collab_R",
            },
        },
    }

    self.METRICS = {
        cards = {
            used = {},
            bought = {},
            appeared = {},
        },
        decks = {
            chosen = {},
            win = {},
            lose = {},
        },
        bosses = {
            faced = {},
            win = {},
            lose = {},
        },
    }

    self.PROFILES = {
        {},
        {},
        {},
    }

    self.TILESIZE = 20
    self.TILESCALE = 3.65
    self.TILE_W = 20
    self.TILE_H = 11.5
    self.DRAW_HASH_BUFF = 2
    self.CARD_W = 2.4 * 35 / 41
    self.CARD_H = 2.4 * 47 / 41
    self.HIGHLIGHT_H = 0.2 * self.CARD_H
    self.COLLISION_BUFFER = 0.05

    self.PITCH_MOD = 1

    self.STATES = {
        SELECTING_HAND = 1,
        HAND_PLAYED = 2,
        DRAW_TO_HAND = 3,
        GAME_OVER = 4,
        SHOP = 5,
        PLAY_TAROT = 6,
        BLIND_SELECT = 7,
        ROUND_EVAL = 8,
        TAROT_PACK = 9,
        PLANET_PACK = 10,
        MENU = 11,
        TUTORIAL = 12,
        SPLASH = 13,
        SANDBOX = 14,
        SPECTRAL_PACK = 15,
        DEMO_CTA = 16,
        STANDARD_PACK = 17,
        BUFFOON_PACK = 18,
        NEW_ROUND = 19,
        OPEN_BOOSTER = 20,
        PAUSED = 21,
        YOU_WIN = 22,
    }

    self.STAGES = {
        MAIN_MENU = 1,
        RUN = 2,
        SANDBOX = 3,
    }
    self.STAGE_OBJECTS = {
        {},
        {},
        {},
    }
    self.STAGE = self.STAGES.MAIN_MENU
    self.STATE = self.STATES.SPLASH
    self.TAROT_INTERRUPT = nil
    self.STATE_COMPLETE = false
    self.BASE_REQUIREMENT_BY_ANTE = {
        [0] = 100,
        [1] = 300,
        [2] = 800,
        [3] = 2000,
        [4] = 5000,
        [5] = 11000,
        [6] = 20000,
        [7] = 35000,
        [8] = 50000,
        [9] = 100,
        [10] = 300,
        [11] = 900,
        [12] = 2600,
        [13] = 8000,
        [14] = 20000,
        [15] = 36000,
        [16] = 60000,
        [17] = 100000,
        [18] = 100,
        [19] = 300,
        [20] = 1000,
        [21] = 3200,
        [22] = 9000,
        [23] = 25000,
        [24] = 60000,
        [25] = 110000,
        [26] = 200000,
    }
    self.BLIND_DEFS = {
        { id = "small", name = "Small Blind", key = "Small", multiplier = 1.0, reward = 3 },
        { id = "big", name = "Big Blind", key = "Big", multiplier = 1.5, reward = 4 },
        { id = "boss", name = "Boss Blind", key = "Boss", multiplier = 2.0, reward = 5 },
    }

    self.ARGS = {}
    self.FUNCS = {}
    self.I = {
        NODE = {},
        MOVEABLE = {},
        SPRITE = {},
        UIBOX = {},
        POPUP = {},
        CARD = {},
        CARDAREA = {},
        ALERT = {},
    }
    self.ANIMATION_ATLAS = {}
    self.ASSET_ATLAS = {}
    self.JOKER_SPRITES = {}
    self.MOVEABLES = {}
    self.ANIMATIONS = {}
    self.DRAW_HASH = {}

    self.MIN_CLICK_DIST = 0.9
    self.MIN_HOVER_TIME = 0.1
    self.DEBUG = false
    self.ANIMATION_FPS = 10
    self.VIBRATION = 0
    self.CHALLENGE_WINS = 5

    self.C = {
        MULT = HEX("FE5F55"),
        MULT_DARK = HEX("a42615"),
        CHIPS = HEX("009dff"),
        CHIPS_DARK = HEX("0f53a6"),
        MONEY = HEX("f3b958"),
        XMULT = HEX("FE5F55"),
        FILTER = HEX("ff9a00"),
        BLUE = HEX("009dff"),
        RED = HEX("FE5F55"),
        GREEN = HEX("4BC292"),
        PALE_GREEN = HEX("56a887"),
        ORANGE = HEX("fda200"),
        IMPORTANT = HEX("ff9a00"),
        GOLD = HEX("eac058"),
        YELLOW = { 1, 1, 0, 1 },
        CLEAR = { 0, 0, 0, 0 },
        WHITE = { 1, 1, 1, 1 },
        DARK_WHITE = HEX("ababab"),
        PURPLE = HEX("8867a5"),
        BLACK = HEX("374244"),
        L_BLACK = HEX("4f6367"),
        GREY = HEX("5f7377"),
        LIGHT_GREY = HEX("9aa2ab"),
        CHANCE = HEX("4BC292"),
        JOKER_GREY = HEX("bfc7d5"),
        VOUCHER = HEX("cb724c"),
        BOOSTER = HEX("646eb7"),
        EDITION = { 1, 1, 1, 1 },
        DARK_EDITION = { 0, 0, 0, 1 },
        ETERNAL = HEX("c75985"),
        PERISHABLE = HEX("4f5da1"),
        RENTAL = HEX("b18f43"),
        TOOLTIP = HEX("3f4a4d"),
        PANEL = HEX("394f55"),
        BLOCK = {
            BACK = HEX("1b2629"),
            SHADOW = HEX("0b1415"),
        },

        DYN_UI = {
            MAIN = HEX("374244"),
            DARK = HEX("374244"),
            BOSS_MAIN = HEX("374244"),
            BOSS_DARK = HEX("374244"),
            BOSS_PALE = HEX("374244"),
        },
        SO_1 = {
            Hearts = HEX("f03464"),
            Diamonds = HEX("f06b3f"),
            Spades = HEX("403995"),
            Clubs = HEX("235955"),
        },
        SO_2 = {
            Hearts = HEX("f83b2f"),
            Diamonds = HEX("e29000"),
            Spades = HEX("4f31b9"),
            Clubs = HEX("008ee6"),
        },
        SUITS = {
            Hearts = HEX("FE5F55"),
            Diamonds = HEX("FE5F55"),
            Spades = HEX("374649"),
            Clubs = HEX("424e54"),
        },
        UI = {
            TEXT_LIGHT = { 1, 1, 1, 1 },
            TEXT_DARK = HEX("4F6367"),
            TEXT_INACTIVE = HEX("88888899"),
            BACKGROUND_LIGHT = HEX("B8D8D8"),
            BACKGROUND_WHITE = { 1, 1, 1, 1 },
            BACKGROUND_DARK = HEX("7A9E9F"),
            BACKGROUND_INACTIVE = HEX("666666FF"),
            OUTLINE_LIGHT = HEX("D8D8D8"),
            OUTLINE_LIGHT_TRANS = HEX("D8D8D866"),
            OUTLINE_DARK = HEX("7A9E9F"),
            TRANSPARENT_LIGHT = HEX("eeeeee22"),
            TRANSPARENT_DARK = HEX("22222222"),
            HOVER = HEX("00000055"),
        },
        SET = {
            Default = HEX("cdd9dc"),
            Enhanced = HEX("cdd9dc"),
            Joker = HEX("424e54"),
            Tarot = HEX("424e54"),
            Planet = HEX("424e54"),
            Spectral = HEX("424e54"),
            Voucher = HEX("424e54"),
        },
        SECONDARY_SET = {
            Default = HEX("9bb6bdFF"),
            Enhanced = HEX("8389DDFF"),
            Joker = HEX("708b91"),
            Tarot = HEX("a782d1"),
            Planet = HEX("13afce"),
            Spectral = HEX("4584fa"),
            Voucher = HEX("fd682b"),
            Edition = HEX("4ca893"),
        },
        RARITY = {
            HEX("009dff"),
            HEX("4BC292"),
            HEX("fe5f55"),
            HEX("b26cbb"),
        },
        BLIND = {
            Small = HEX("50846e"),
            Big = HEX("225b49"),
            Boss = HEX("b44430"),
            won = HEX("4f6367"),
        },
        BLIND_COLORS = {
            Small = HEX("0068ad"),
            Big = HEX("a56c00"),
            BigSign = HEX("54451a"),
            Boss = HEX("b44430"),
            won = HEX("4f6367"),
        },
        HAND_LEVELS = {
            HEX("efefef"),
            HEX("95acff"),
            HEX("65efaf"),
            HEX("fae37e"),
            HEX("ffc052"),
            HEX("f87d75"),
            HEX("caa0ef"),
        },
        BACKGROUND = {
            L = { 1, 1, 0, 1 },
            D = HEX("374244"),
            C = HEX("374244"),
            contrast = 1,
        },
    }
    G.C.HAND_LEVELS[0] = G.C.RED
    G.C.UI_CHIPS = copy_table(G.C.BLUE)
    G.C.UI_MULT = copy_table(G.C.RED)

    local function pixel_font(path, size)
        local font = love.graphics.newFont(path, size)
        if font and font.setFilter then
            font:setFilter("nearest", "nearest")
        end
        return font
    end

    self.FONTS = {
        PIXEL = {
            SMALL_HEIGHT = 11,
            MEDIUM_HEIGHT = 22,
            LARGE_HEIGHT = 33,
            SMALL = pixel_font("Assets/fonts/m6x11plus.ttf", 11),
            MEDIUM = pixel_font("Assets/fonts/m6x11plus.ttf", 22),
            LARGE = pixel_font("Assets/fonts/m6x11plus.ttf", 33),
        },
    }
    self.UIT = {
        T = 1,
        B = 2,
        C = 3,
        R = 4,
        O = 5,
        ROOT = 7,
        S = 8,
        I = 9,
        padding = 0,
    }
    self.handlist = {
        "Flush Five",
        "Flush House",
        "Five of a Kind",
        "Straight Flush",
        "Four of a Kind",
        "Full House",
        "Flush",
        "Straight",
        "Three of a Kind",
        "Two Pair",
        "Pair",
        "High Card",
    }
    self.hand_stats = {
        [1] = { level = 1, base_chips = 160, base_mult = 16, chips_per_level = 40, mult_per_level = 3 },
        [2] = { level = 1, base_chips = 140, base_mult = 14, chips_per_level = 40, mult_per_level = 3 },
        [3] = { level = 1, base_chips = 120, base_mult = 12, chips_per_level = 35, mult_per_level = 3 },
        [4] = { level = 1, base_chips = 100, base_mult = 8, chips_per_level = 40, mult_per_level = 3 },
        [5] = { level = 1, base_chips = 60, base_mult = 7, chips_per_level = 30, mult_per_level = 3 },
        [6] = { level = 1, base_chips = 40, base_mult = 4, chips_per_level = 25, mult_per_level = 2 },
        [7] = { level = 1, base_chips = 35, base_mult = 4, chips_per_level = 15, mult_per_level = 2 },
        [8] = { level = 1, base_chips = 30, base_mult = 4, chips_per_level = 30, mult_per_level = 2 },
        [9] = { level = 1, base_chips = 30, base_mult = 3, chips_per_level = 20, mult_per_level = 2 },
        [10] = { level = 1, base_chips = 20, base_mult = 2, chips_per_level = 20, mult_per_level = 1 },
        [11] = { level = 1, base_chips = 10, base_mult = 2, chips_per_level = 15, mult_per_level = 1 },
        [12] = { level = 1, base_chips = 5, base_mult = 1, chips_per_level = 10, mult_per_level = 1 },
    }
    self.button_mapping = {
        a = G.F_SWAP_AB_BUTTONS and "b" or nil,
        b = G.F_SWAP_AB_BUTTONS and "a" or nil,
        y = G.F_SWAP_XY_BUTTONS and "x" or nil,
        x = G.F_SWAP_XY_BUTTONS and "y" or nil,
    }
    self.keybind_mapping = {
        {
            a = "dpleft",
            d = "dpright",
            w = "dpup",
            s = "dpdown",
            x = "x",
            c = "y",
            space = "a",
            shift = "b",
            esc = "start",
            q = "triggerleft",
            e = "triggerright",
        },
    }
end
