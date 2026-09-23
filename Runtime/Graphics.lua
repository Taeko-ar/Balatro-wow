local _, Balatro = ...

local texturePool = {}
local activeTextures = 0
local fontStringPool = {}
local activeFontStrings = 0
local rootFrame = BalatroCanvas

local canvasFrame = CreateFrame("Frame", "BalatroEngineCanvas", rootFrame)
canvasFrame:SetAllPoints(true)
canvasFrame:SetFrameLevel(rootFrame:GetFrameLevel() + 2)

local bgTex = canvasFrame:CreateTexture(nil, "BACKGROUND")
bgTex:SetAllPoints(true)
canvasFrame:EnableMouse(true)

local isTouching = false
local last_lx, last_ly = 0, 0

local function mapTouch(self)
    local cx, cy = GetCursorPosition()
    local s = self:GetEffectiveScale()
    cx, cy = cx / s, cy / s
    local left, bottom = self:GetLeft(), self:GetBottom()
    local frame_x = cx - left
    local frame_y = 720 - (cy - bottom)

    local love_x = frame_x - 250
    local love_y = frame_y
    return love_x, love_y
end

canvasFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        isTouching = true
        local love_x, love_y = mapTouch(self)
        last_lx, last_ly = love_x, love_y
        if love.touchpressed then
            pcall(love.touchpressed, "mouse1", love_x, love_y, 0, 0, 1)
        end
        if love.mousepressed then
            pcall(love.mousepressed, love_x, love_y, 1, false)
        end
    end
end)

canvasFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        isTouching = false
        local love_x, love_y = mapTouch(self)
        if love.touchreleased then
            pcall(love.touchreleased, "mouse1", love_x, love_y, 0, 0, 0)
        end
        if love.mousereleased then
            pcall(love.mousereleased, love_x, love_y, 1, false)
        end
    end
end)

canvasFrame:SetScript("OnUpdate", function(self)
    local love_x, love_y = mapTouch(self)
    if love.mousemoved then
        pcall(love.mousemoved, love_x, love_y, love_x - last_lx, love_y - last_ly, false)
    end
    if isTouching then
        if love_x ~= last_lx or love_y ~= last_ly then
            if love.touchmoved then
                pcall(love.touchmoved, "mouse1", love_x, love_y, love_x - last_lx, love_y - last_ly, 1)
            end
            last_lx, last_ly = love_x, love_y
        end
    else
        last_lx, last_ly = love_x, love_y
    end
end)

local bg = canvasFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 1)

local function getTexture()
    activeTextures = activeTextures + 1
    if not texturePool[activeTextures] then
        local tex = canvasFrame:CreateTexture(nil, "OVERLAY")
        texturePool[activeTextures] = tex
    end
    local tex = texturePool[activeTextures]
    tex:Show()
    return tex
end

_G.love.graphics = {
    getWidth = function(screen)
        return 1030
    end,
    getHeight = function(screen)
        return 720
    end,
    getDimensions = function(screen)
        return _G.love.graphics.getWidth(screen), _G.love.graphics.getHeight(screen)
    end,

    newImage = function(path)
        local wPath = "Interface\\AddOns\\Balatro\\" .. string.gsub(string.gsub(path, "%.png$", ".tga"), "/", "\\")

        if not _G.BalatroDimensionsDebugged then
            _G.BalatroDimensionsDebugged = {}
        end
        if _G.BalatroDebug and not _G.BalatroDimensionsDebugged[path] then
            _G.BalatroDimensionsDebugged[path] = true
            local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[wPath]
            if not dim then
                local keys = ""
                for k, v in pairs(_G.BalatroImageDimensions or {}) do
                    if string.find(k, "balatro.tga") then
                        keys = k
                    end
                end
                DEFAULT_CHAT_FRAME:AddMessage("Balatro MISS: " .. wPath .. " | Found: " .. tostring(keys))
            else
                DEFAULT_CHAT_FRAME:AddMessage(
                    "Balatro Load: " .. path .. " (Dim: " .. (dim and (dim[1] .. "x" .. dim[2]) or "nil") .. ")"
                )
            end
        end

        return {
            path = wPath,
            getDimensions = function()
                local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[wPath]
                if dim then
                    return dim[1], dim[2]
                end
                return 1024, 1024
            end,
            getWidth = function()
                local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[wPath]
                if dim then
                    return dim[1]
                end
                return 1024
            end,
            getHeight = function()
                local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[wPath]
                if dim then
                    return dim[2]
                end
                return 1024
            end,
            getDepth = function()
                return 1
            end,
            setFilter = function() end,
            setWrap = function() end,
        }
    end,
    newFont = function()
        return {
            getHeight = function()
                return 12
            end,
            getWidth = function(s, text)
                return string.len(text) * 6
            end,
        }
    end,
    setFont = function() end,
    getFont = function()
        return _G.love.graphics.newFont()
    end,

    _currentColor = { 1, 1, 1, 1 },
    setColor = function(r, g, b, a)
        if type(r) == "table" then
            _G.love.graphics._currentColor = { r[1] or 1, r[2] or 1, r[3] or 1, r[4] or 1 }
        else
            _G.love.graphics._currentColor = { r or 1, g or 1, b or 1, a or 1 }
        end
    end,

    getColor = function()
        if not _G.love.graphics._currentColor then
            return 1, 1, 1, 1
        end
        return unpack(_G.love.graphics._currentColor)
    end,
    setBackgroundColor = function(r, g, b, a) end,
    getBackgroundColor = function()
        return 0, 0, 0, 1
    end,
    setDefaultFilter = function(min, mag, anisotropy) end,
    setBlendMode = function(mode, alphamode) end,
    setLineStyle = function(style) end,
    _currentLineWidth = 1,
    setLineWidth = function(width)
        _G.love.graphics._currentLineWidth = width or 1
    end,
    getLineWidth = function()
        return _G.love.graphics._currentLineWidth or 1
    end,
    getDepth = function()
        return 0
    end,

    newQuad = function(x, y, w, h, sw, sh)
        return { x = x, y = y, w = w, h = h, sw = sw, sh = sh }
    end,

    draw = function(drawable, quad_or_x, x_or_y, y_or_r, r_or_sx, sx_or_sy, sy, ox, oy, kx, ky)
        local x, y, sx, sy_scale, quad, originX, originY
        if type(quad_or_x) == "table" then
            quad = quad_or_x
            x, y = x_or_y or 0, y_or_r or 0
            sx = sx_or_sy or 1
            sy_scale = sy or sx
            originX = ox or 0
            originY = oy or 0
        else
            x, y = quad_or_x or 0, x_or_y or 0
            sx = r_or_sx or 1
            sy_scale = sx_or_sy or sx
            originX = sy or 0
            originY = ox or 0
        end

        local ct = _G.love.graphics._currentTransform
        local final_x = ct.x + (x - originX * sx) * ct.sx
        local final_y = ct.y + (y - originY * sy_scale) * ct.sy
        local final_sx = sx * ct.sx
        local final_sy = sy_scale * ct.sy

        local tex = getTexture()
        if type(drawable) == "table" and drawable.path then
            tex:SetTexture(drawable.path)
        end

        if quad then
            local pw2_w, pw2_h = quad.sw, quad.sh
            local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[drawable.path]
            if dim and dim[3] and dim[4] then
                pw2_w, pw2_h = dim[3], dim[4]
            end
            tex:SetTexCoord(quad.x / pw2_w, (quad.x + quad.w) / pw2_w, quad.y / pw2_h, (quad.y + quad.h) / pw2_h)
            tex:SetSize(quad.w * final_sx, quad.h * final_sy)
        else
            local w, h = 64, 64
            if type(drawable) == "table" and drawable.getWidth then
                w = drawable:getWidth()
                h = drawable:getHeight()
            end
            local dim = _G.BalatroImageDimensions and _G.BalatroImageDimensions[drawable.path]
            if dim and dim[3] and dim[4] then
                tex:SetTexCoord(0, w / dim[3], 0, h / dim[4])
            else
                tex:SetTexCoord(0, 1, 0, 1)
            end
            tex:SetSize(w * final_sx, h * final_sy)
        end

        local c = _G.love.graphics._currentColor
        tex:SetVertexColor(c[1], c[2], c[3], c[4])

        tex:SetPoint("TOPLEFT", canvasFrame, "TOPLEFT", final_x, -final_y)
    end,

    print = function(text, x, y)
        local ct = _G.love.graphics._currentTransform
        local final_x = ct.x + (x * ct.sx)
        local final_y = ct.y + (y * ct.sy)

        activeFontStrings = activeFontStrings + 1
        if #fontStringPool < activeFontStrings then
            local fs = canvasFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            table.insert(fontStringPool, fs)
        end
        local fs = fontStringPool[activeFontStrings]
        local c = _G.love.graphics._currentColor
        fs:SetTextColor(c[1], c[2], c[3], c[4] or 1)
        fs:SetPoint("TOPLEFT", canvasFrame, "TOPLEFT", final_x, -final_y)
        fs:SetText(text)
        fs:Show()
    end,

    printf = function(text, x, y, limit, align)
        local ct = _G.love.graphics._currentTransform
        local final_x = ct.x + (x * ct.sx)
        local final_y = ct.y + (y * ct.sy)
        local final_w = (limit or 0) * ct.sx

        activeFontStrings = activeFontStrings + 1
        if #fontStringPool < activeFontStrings then
            local fs = canvasFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            table.insert(fontStringPool, fs)
        end
        local fs = fontStringPool[activeFontStrings]
        local c = _G.love.graphics._currentColor
        fs:SetTextColor(c[1], c[2], c[3], c[4] or 1)

        if final_w > 0 then
            fs:SetWidth(final_w)
        end

        if align == "center" then
            fs:SetJustifyH("CENTER")
        elseif align == "right" then
            fs:SetJustifyH("RIGHT")
        else
            fs:SetJustifyH("LEFT")
        end

        fs:SetPoint("TOPLEFT", canvasFrame, "TOPLEFT", final_x, -final_y)
        fs:SetText(text)
        fs:Show()
    end,

    rectangle = function(mode, x, y, w, h)
        local ct = _G.love.graphics._currentTransform
        local final_x = ct.x + (x * ct.sx)
        local final_y = ct.y + (y * ct.sy)
        local final_w = w * ct.sx
        local final_h = h * ct.sy

        local tex = getTexture()
        local c = _G.love.graphics._currentColor
        tex:SetColorTexture(c[1], c[2], c[3], mode == "fill" and (c[4] or 1) or 0.5)
        tex:SetTexCoord(0, 1, 0, 1)
        tex:SetPoint("TOPLEFT", canvasFrame, "TOPLEFT", final_x, -final_y)
        tex:SetSize(final_w, final_h)
    end,

    clear = function(r, g, b, a)
        if _G.G then
            _G.G.jokers_on_bottom = true
            _G.G.consumables_on_bottom = true
        end
        local alpha = a or 1
        if r then
            if type(r) == "table" then
                bg:SetColorTexture(r[1], r[2], r[3], alpha)
            else
                bg:SetColorTexture(r, g, b, alpha)
            end
        else
            bg:SetColorTexture(0, 0, 0, alpha)
        end
    end,

    _currentTransform = { x = 0, y = 0, sx = 2, sy = 2 },
    _stack = {},
    push = function()
        table.insert(_G.love.graphics._stack, {
            x = _G.love.graphics._currentTransform.x,
            y = _G.love.graphics._currentTransform.y,
            sx = _G.love.graphics._currentTransform.sx,
            sy = _G.love.graphics._currentTransform.sy,
            r = _G.love.graphics._currentTransform.r,
        })
    end,
    pop = function()
        local t = table.remove(_G.love.graphics._stack)
        if t then
            _G.love.graphics._currentTransform = t
        end
    end,
    translate = function(dx, dy)
        local ct = _G.love.graphics._currentTransform
        ct.x = ct.x + (dx or 0) * ct.sx
        ct.y = ct.y + (dy or 0) * ct.sy
    end,
    rotate = function(angle) end,
    scale = function(sx, sy)
        local ct = _G.love.graphics._currentTransform
        ct.sx = ct.sx * (sx or 1)
        ct.sy = ct.sy * (sy or sx or 1)
    end,
}

Balatro.Graphics = {
    canvas = canvasFrame,
    beginFrame = function()
        for i = 1, #texturePool do
            texturePool[i]:Hide()
        end
        for i = 1, #fontStringPool do
            fontStringPool[i]:Hide()
        end
        activeTextures = 0
        activeFontStrings = 0
        _G.love.graphics._stack = {}
    end,
}
