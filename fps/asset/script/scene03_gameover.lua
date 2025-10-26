local texture_dead = {}
local font_dead = {}
local drawer_dead = {}
local scene_switcher = require("scene_switcher")()

texture_dead = sn.Texture.new()
drawer_dead = sn.Draw2D.new(texture_dead)
font_dead = sn.Font.new()
font_dead:load(64, DEFAULT_FONT_NAME)
font_dead:renderText(texture_dead, "GAME OVER", sn.Color.new(1, 0.25, 0.25, 1))
drawer_dead.scale = texture_dead:size()
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
    sn.Graphics.draw2D(drawer_dead)
    scene_switcher:draw()
    GUI_MANAGER:draw()
end
