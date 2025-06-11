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

Scene.Resize(Vec2(1280, 720))
SCORE = 0
NOW_STAGE = 1
menu_object:setup()
texture_title = Texture()
drawer_title = Draw2D()
drawer_title.material:AppendTexture(texture_title)
font_title = Font()
font_title:Load(64)
font_title:RenderText(texture_title, "SINEN DEMO", Color(1, 1, 1, 0.9))
drawer_title.scale = texture_title:Size()

texture_press = Texture()
drawer_press = Draw2D()
drawer_press.material:AppendTexture(texture_press)
font_press = Font()
font_press:Load(32)
font_press:RenderText(texture_press, "CLICK TO START", Color(1, 1, 1, 0.9))
drawer_press.scale = texture_press:Size()
drawer_press.position = Vec2(0, -drawer_title.scale.y * 3.0)
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
		font_press:RenderText(texture_press, "CLICK TO START", Color(1, 1, 1, Periodic.Sin0_1(2.0, Time.Seconds())))
		if Mouse.IsPressed(Mouse.LEFT) then
			scene_switcher:start("scene01_stage")
		end
	end
end

function Draw()
	drawer_title:Draw()
	drawer_press:Draw()
	menu_object:draw()

	scene_switcher:draw()
	GUI_MANAGER:draw()
end
