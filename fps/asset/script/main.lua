require("global")
local texture_title = {}
local texture_press = {}
local font_title = {}
local font_press = {}
local drawer_title = {}
local drawer_press = {}
local menu = require("gui/menu")
local menu_object = menu()
local scene_switcher = require("scene_switcher")()
local button = require("gui/button")()

sn.Graphics.getCamera2d():resize(sn.Vec2.new(1280, 720))
SCORE = 0
NOW_STAGE = 1
menu_object:setup()
texture_title = sn.Texture.new()
drawer_title = sn.Draw2D.new(texture_title)
font_title = sn.Font.new()
font_title:load(64, DEFAULT_FONT_NAME)
font_title:renderText(texture_title, "SINEN DEMO", sn.Color.new(1, 1, 1, 0.9))
drawer_title.scale = texture_title:size()
texture_press = sn.Texture.new()
drawer_press = sn.Draw2D.new(texture_press)
font_press = sn.Font.new()
font_press:load(32, DEFAULT_FONT_NAME)
font_press:renderText(texture_press, "CLICK TO START", sn.Color.new(1, 1, 1, 0.9))
drawer_press.scale = texture_press:size()
drawer_press.position = sn.Vec2.new(0, -drawer_title.scale.y * 3.0)
scene_switcher:setup()
scene_switcher:start("")

function update()
    GUI_MANAGER:update()
    if scene_switcher.flag then
        scene_switcher:update()
        return
    end
    menu_object:update()
    if menu_object.hide then
        font_press:renderText(texture_press, "CLICK TO START",
            sn.Color.new(1, 1, 1, sn.Periodic.sin0_1(2.0, sn.Time.seconds())))
        if sn.Mouse.isPressed(sn.Mouse.LEFT) then
            scene_switcher:start("scene01_stage")
        end
    end
end

function draw()
    sn.Graphics.draw2D(drawer_title)
    sn.Graphics.draw2D(drawer_press)
    menu_object:draw()

    scene_switcher:draw()
    GUI_MANAGER:draw()
end
