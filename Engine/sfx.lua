local M = {}

local cache = {}

local GAME_SFX_PATHS = {
    "Assets/sounds/generic1.ogg",
    "Assets/sounds/cardSlide1.ogg",
    "Assets/sounds/cardSlide2.ogg",
    "Assets/sounds/card1.ogg",
    "Assets/sounds/card3.ogg",
    "Assets/sounds/chips1.ogg",
    "Assets/sounds/chips2.ogg",
    "Assets/sounds/coin1.ogg",
    "Assets/sounds/coin2.ogg",
    "Assets/sounds/coin3.ogg",
    "Assets/sounds/coin4.ogg",
    "Assets/sounds/coin5.ogg",
    "Assets/sounds/coin6.ogg",
    "Assets/sounds/coin7.ogg",
    "Assets/sounds/multhit1.ogg",
    "Assets/sounds/multhit2.ogg",
}

local function get_source(path)
    if not path or path == "" then
        return nil
    end
    local cached = cache[path]
    if cached then
        return cached
    end
    if not love or not love.audio then
        return nil
    end
    local ok, src = pcall(love.audio.newSource, path, "static")
    if ok and src then
        cache[path] = src
        return src
    end
    return nil
end

local function normalize_paths(...)
    local args = { ... }
    if #args == 1 and type(args[1]) == "table" then
        return args[1]
    end
    return args
end

function M.play_random(...)
    local paths = normalize_paths(...)
    local n = #paths
    if n == 0 then
        return false
    end

    local idx = love.math.random(1, n)
    local path = paths[idx]
    local src = get_source(path)
    if not src or not src.play then
        return false
    end
    src:stop()
    src:play()
    return true
end

function M.play(path)
    local src = get_source(path)
    if not src or not src.play then
        return false
    end
    src:stop()
    src:play()
    return true
end

function M.preload(...)
    local paths = normalize_paths(...)
    local ok = 0
    for _, path in ipairs(paths) do
        if path and path ~= "" and get_source(path) then
            ok = ok + 1
        end
    end
    return ok
end

function M.preload_game_sounds()
    return M.preload(GAME_SFX_PATHS)
end

function M.play_money()
    M.play_random(
        "Assets/sounds/coin1.ogg",
        "Assets/sounds/coin2.ogg",
        "Assets/sounds/coin3.ogg",
        "Assets/sounds/coin4.ogg",
        "Assets/sounds/coin5.ogg",
        "Assets/sounds/coin6.ogg",
        "Assets/sounds/coin7.ogg"
    )
end

function M.play_mult()
    M.play("Assets/sounds/multhit1.ogg")
end

function M.play_mult2()
    M.play("Assets/sounds/multhit2.ogg")
end

function M.play_chips()
    M.play_random("Assets/sounds/chips1.ogg", "Assets/sounds/chips2.ogg")
end

function M.play_glass_break()
    M.play_random(
        "Assets/sounds/glass1.ogg",
        "Assets/sounds/glass2.ogg",
        "Assets/sounds/glass3.ogg",
        "Assets/sounds/glass4.ogg",
        "Assets/sounds/glass5.ogg",
        "Assets/sounds/glass6.ogg"
    )
end

return M
