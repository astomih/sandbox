local texture_dead = {}
local font_dead = {}
local drawer_dead = {}
local scene_switcher = require("scene_switcher")()

texture_dead = sn.Texture()
drawer_dead = sn.Draw2D(texture_dead)
font_dead = sn.Font()
font_dead:Load(64, DEFAULT_FONT_NAME)
font_dead:RenderText(texture_dead, "GAME OVER", sn.Color(1, 0.25, 0.25, 1))
drawer_dead.scale = texture_dead:Size()
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
        scene_switcher:start("main")
    end
end

function Draw()
    sn.Graphics.Draw2D(drawer_dead)
    scene_switcher:draw()
    GUI_MANAGER:draw()
end
