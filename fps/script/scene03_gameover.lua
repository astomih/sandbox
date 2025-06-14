local texture_dead = {}
local font_dead = {}
local drawer_dead = {}
local scene_switcher = require("scene_switcher")()

texture_dead = Texture()
drawer_dead = Draw2D(texture_dead)
font_dead = Font()
font_dead:Load(64, DEFAULT_FONT_NAME)
font_dead:RenderText(texture_dead, "GAME OVER", Color(1, 0.25, 0.25, 1))
drawer_dead.scale = texture_dead:Size()
scene_switcher:setup()
scene_switcher:start("")

function Update()
    GUI_MANAGER:update()
    Mouse.HideCursor(false)
    if scene_switcher.flag then
        scene_switcher:update()
        return
    end
    if Mouse.IsPressed(Mouse.LEFT) then
        scene_switcher:start("main")
    end
end

function Draw()
    drawer_dead:Draw()
    scene_switcher:draw()
    GUI_MANAGER:draw()
end
