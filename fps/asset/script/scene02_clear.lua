local texture_clear = {}
local font_clear = {}
local drawer_clear = {}
local scene_switcher = require("scene_switcher")()
NOW_STAGE = 1
texture_clear = sn.Texture.new()
drawer_clear = sn.Draw2D.new(texture_clear)
font_clear = sn.Font.new()
font_clear:load(64, DEFAULT_FONT_NAME)
font_clear:renderText(texture_clear, "STAGE CLEAR", sn.Color.new(1, 1, 1, 1))
drawer_clear.scale = texture_clear:size()
scene_switcher:setup()
scene_switcher:start("")
sn.Mouse.hideCursor(false)
sn.Mouse.setRelative(false)

function update()
    GUI_MANAGER:update()
    if scene_switcher.flag then
        scene_switcher:update()
        return
    end
    if sn.Mouse.isPressed(sn.Mouse.LEFT) then
        scene_switcher:start("main")
    end
end

function draw()
    sn.Graphics.draw2D(drawer_clear)
    scene_switcher:draw()
    GUI_MANAGER:draw()
end
