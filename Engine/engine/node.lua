Node = Object:extend()

function Node:init(args)
    args = args or {}
    args.T = args.T or {}

    self.ARGS = self.ARGS or {}
    self.RETS = {}

    self.config = self.config or {}

    self.T = {
        x = args.T.x or args.T[1] or 0,
        y = args.T.y or args.T[2] or 0,
        w = args.T.w or args.T[3] or 1,
        h = args.T.h or args.T[4] or 1,
        r = args.T.r or args.T[5] or 0,
        scale = args.T.scale or args.T[6] or 1,
    }

    self.CT = self.T

    self.click_offset = { x = 0, y = 0 }
    self.hover_offset = { x = 0, y = 0 }

    self.FRAME = {
        DRAW = -1,
        MOVE = -1,
    }

    self.states = {
        visible = true,
        collide = { can = false, is = false },
        focus = { can = false, is = false },
        hover = { can = true, is = false },
        click = { can = true, is = false },
        drag = { can = true, is = false },
        release_on = { can = true, is = false },
    }

    if not self.children then
        self.children = {}
    end

    self.collision_offset = { x = 0, y = 0 }
end

function Node:get_collision_rect()
    local t = self.VT or self.T
    return {
        x = t.x + self.collision_offset.x,
        y = t.y + self.collision_offset.y,
        w = t.w * t.scale,
        h = t.h * t.scale,
    }
end

function Node:draw_boundingrect()
    if not G or not G.DEBUG then
        return
    end
    local prev_r, prev_g, prev_b, prev_a = love.graphics.getColor()

    love.graphics.setColor(0, 1, 0, 1)

    love.graphics.push()

    local cx = self.T.x + (self.T.w * self.T.scale) / 2
    local cy = self.T.y + (self.T.h * self.T.scale) / 2

    love.graphics.translate(cx, cy)
    love.graphics.rotate(self.T.r)
    love.graphics.translate(-cx, -cy)

    love.graphics.rectangle("line", self.T.x, self.T.y, self.T.w * self.T.scale, self.T.h * self.T.scale)

    love.graphics.pop()

    love.graphics.setColor(prev_r, prev_g, prev_b, prev_a)
end

function Node:draw()
    self:draw_boundingrect()
    if self.states.visible then
        for _, v in pairs(self.children) do
            v:draw()
        end
    end
end
