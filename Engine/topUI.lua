TopUI = Object:extend()

sysDepth = 0
buttonHeight = 1
textHeight = 2
signHeight = 3
jokerHeight = 2
PopupHeight = 4

function draw_rounded_rect(x, y, w, h, radius, padding, mode)
    padding = padding or 0
    mode = mode or "fill"
    if mode == "line" and padding ~= 0 then
        love.graphics.setLineWidth(padding)
    end
    radius = math.min(radius or 0, w / 2, h / 2)
    if radius < 0 then
        radius = 0
    end
    love.graphics.rectangle(mode, x, y, w, h, radius, radius)
    local pad = padding
    love.graphics.setLineWidth(1)
    return x + pad, y + pad, w - (2 * pad), h - (2 * pad)
end

function draw_rect_with_shadow(x, y, w, h, radius, padding, color, shadowColor, shadowSize, offset)
    local ox = tonumber(offset) or 0
    local rx = x - ox
    love.graphics.setColor(shadowColor)
    draw_rounded_rect(rx, y + shadowSize, w, h, radius, padding, "fill")
    love.graphics.setColor(color)
    return draw_rounded_rect(rx, y, w, h, radius, padding, "fill")
end

function TopUI:init()
    self.popups = {}
end

function TopUI:update(dt)
    local to_remove = {}
    for i, popup in ipairs(self.popups or {}) do
        if popup.update then
            popup:update(dt)
            if popup.remove or popup.time <= 0 then
                table.insert(to_remove, i)
            end
        end
    end

    for i = #to_remove, 1, -1 do
        table.remove(self.popups, to_remove[i])
    end
end

function TopUI:addPopup(node)
    if Popup and node and node.is and node:is(Popup) then
        table.insert(self.popups, node)
    end
end
