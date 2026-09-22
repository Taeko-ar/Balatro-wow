local raw_print = print
function print(...)
    if G and G.DEBUG then
        raw_print(...)
    end
end

require("engine.object")
require("engine.node")
require("engine.moveable")
require("engine.sprite")
require("card")
require("deck")
require("hand")
require("joker")
require("joker_catalog")
require("shop_nodes")
require("consumable")
require("game")
require("globals")
require("consumable_catalog")
require("voucher_catalog")
require("topUI")
require("popup")
require("tag")
require("deck_catalog")
require("you_win")
require("main_menu_ui")
require("deck_view_ui")
Sfx = require("sfx")

function love.load()
    if Sfx and Sfx.preload_game_sounds then
        Sfx.preload_game_sounds()
    end

    G = Game()
    G:enter_main_menu()
    Top = TopUI()

    G.music = love.audio.newSource("Assets/sounds/music1_low.ogg", "stream")
    if G.music then
        G.music:setLooping(true)
        if G.apply_music_volume then
            G:apply_music_volume()
        else
            G.music:play()
        end
    end
end

function love.update(dt)
    local speed = (G and G.SETTINGS and tonumber(G.SETTINGS.GAMESPEED)) or 1
    if speed <= 0 then
        speed = 1
    end
    G:update(dt * speed)
    Top:update(dt * speed)
end

function love.draw()
    love.graphics.clear(unpack(G.C.BLIND.Big))
    love.graphics.setColor(1, 1, 1)
    G:draw()
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    G:touchpressed(id, x, y)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    G:touchmoved(id, x, y, dx, dy)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    G:touchreleased(id, x, y)
end
