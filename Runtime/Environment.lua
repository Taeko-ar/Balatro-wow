_G.package = _G.package or { loaded = {} }

_G.os = _G.os or {}
_G.os.time = _G.os.time or time
_G.os.date = _G.os.date or date
_G.os.difftime = _G.os.difftime or difftime
if GetTime then
    _G.os.clock = _G.os.clock or GetTime
end

_G.math.randomseed = _G.math.randomseed or function() end

_G.love = {}

_G.love.math = {
    random = math.random,
    randomseed = math.randomseed,
    setRandomSeed = math.randomseed,
    noise = function()
        return 0
    end,
}

_G.require = function(modname)
    if package.loaded[modname] then
        return package.loaded[modname]
    end

    local path_modname = string.gsub(modname, "%.", "/")

    local paths = {
        path_modname,
        "engine/" .. path_modname,
    }

    for _, path in ipairs(paths) do
        if _G.BALATRO_MODULES and _G.BALATRO_MODULES[path] then
            local chunk, err = loadstring(_G.BALATRO_MODULES[path], path)
            if chunk then
                local result = chunk()
                package.loaded[modname] = result or true
                return package.loaded[modname]
            else
                print("Error loading module: " .. path .. " - " .. tostring(err))
            end
        end
    end
    error("Module " .. modname .. " not found")
end

_G.love.timer = {
    getTime = GetTime,
    sleep = function() end,
}

_G.love.mouse = {
    getX = function()
        local x = GetCursorPosition()
        local s = UIParent:GetEffectiveScale()
        return x / s
    end,
    getY = function()
        local _, y = GetCursorPosition()
        local s = UIParent:GetEffectiveScale()
        return (GetScreenHeight() * s - y) / s
    end,
    isDown = function(button)
        return IsMouseButtonDown(button == 1 and "LeftButton" or "RightButton")
    end,
}

_G.love.keyboard = {
    isDown = function(key)
        return false
    end,
}

_G.love.joystick = {
    getJoysticks = function()
        return {}
    end,
    getJoystickCount = function()
        return 0
    end,
}

_G.BalatroData = _G.BalatroData or {}

_G.love.filesystem = {
    getInfo = function(path, type)
        return _G.BalatroData[path] and { type = "file" } or nil
    end,
    load = function(path)
        if _G.BalatroData[path] then
            return loadstring(_G.BalatroData[path])
        end
        return nil, "File not found"
    end,
    write = function(path, data)
        _G.BalatroData[path] = data
        return true
    end,
    createDirectory = function(path)
        return true
    end,
    remove = function(path)
        _G.BalatroData[path] = nil
        return true
    end,
}

_G.love.window = {
    setMode = function() end,
    setTitle = function() end,
}
