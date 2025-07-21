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

sn.Scene.Resize(sn.Vec2(1280, 720))
SCORE = 0
NOW_STAGE = 1
menu_object:setup()
texture_title = sn.Texture()
drawer_title = sn.Draw2D(texture_title)
font_title = sn.Font()
font_title:Load(64, DEFAULT_FONT_NAME)
font_title:RenderText(texture_title, "SINEN DEMO", sn.Color(1, 1, 1, 0.9))
drawer_title.scale = texture_title:Size()
texture_press = sn.Texture()
drawer_press = sn.Draw2D(texture_press)
font_press = sn.Font()
font_press:Load(32, DEFAULT_FONT_NAME)
font_press:RenderText(texture_press, "CLICK TO START", sn.Color(1, 1, 1, 0.9))
drawer_press.scale = texture_press:Size()
drawer_press.position = sn.Vec2(0, -drawer_title.scale.y * 3.0)
scene_switcher:setup()
scene_switcher:start("")

function Update()
	GUI_MANAGER:update()
	if scene_switcher.flag then
		scene_switcher:update()
		return
	end
	menu_object:update()
	if menu_object.hide then
		font_press:RenderText(texture_press, "CLICK TO START", sn.Color(1, 1, 1, sn.Periodic.Sin0_1(2.0, sn.Time.Seconds())))
		if sn.Mouse.IsPressed(sn.Mouse.LEFT) then
			scene_switcher:start("scene01_stage")
		end
	end
end

function Draw()
	sn.Graphics.Draw2D(drawer_title)
	sn.Graphics.Draw2D(drawer_press)
	menu_object:draw()

	scene_switcher:draw()
	GUI_MANAGER:draw()
end
