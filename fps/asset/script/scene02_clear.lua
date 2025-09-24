local texture_clear = {}
local font_clear = {}
local drawer_clear = {}
local scene_switcher = require("scene_switcher")()
NOW_STAGE = 1
texture_clear = sn.Texture()
drawer_clear = sn.Draw2D(texture_clear)
font_clear = sn.Font()
font_clear:load(64, DEFAULT_FONT_NAME)
font_clear:render_text(texture_clear, "STAGE CLEAR", sn.Color(1, 1, 1, 1))
drawer_clear.scale = texture_clear:size()
scene_switcher:setup()
scene_switcher:start("")
sn.Mouse.hide_cursor(false)
sn.Mouse.set_relative(false)

function update()
    GUI_MANAGER:update()
    if scene_switcher.flag then
        scene_switcher:update()
        return
    end
    if sn.Mouse.is_pressed(sn.Mouse.LEFT) then
        scene_switcher:start("scene01_stage")
    end
end

function draw()
    sn.Graphics.draw2d(drawer_clear)
    scene_switcher:draw()
    GUI_MANAGER:draw()
end
