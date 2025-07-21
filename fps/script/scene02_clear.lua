local texture_clear = {}
local font_clear = {}
local drawer_clear = {}
local scene_switcher = require("scene_switcher")()
NOW_STAGE = 1
texture_clear = sn.Texture()
drawer_clear = sn.Draw2D(texture_clear)
font_clear = sn.Font()
font_clear:Load(64, DEFAULT_FONT_NAME)
font_clear:RenderText(texture_clear, "STAGE CLEAR", sn.Color(1, 1, 1, 1))
drawer_clear.scale = texture_clear:Size()
scene_switcher:setup()
scene_switcher:start("")
sn.Mouse.HideCursor(false)
sn.Mouse.SetRelative(false)

function Update()
    GUI_MANAGER:update()
    if scene_switcher.flag then
        scene_switcher:update()
        return
    end
    if sn.Mouse.IsPressed(sn.Mouse.LEFT) then
        scene_switcher:start("scene01_stage")
    end
end

function Draw()
    sn.Graphics.Draw2D(drawer_clear)
    scene_switcher:draw()
    GUI_MANAGER:draw()
end
