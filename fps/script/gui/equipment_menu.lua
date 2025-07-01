local button = require("gui/button")()
local text = require("gui/text")()
local scroll = require("gui/scroll")()
local image = require("gui/image")()
local function equipment_menu()
  local object = {
    hide = true,
    ui_panel = {},
    ui_panel_texture = {},
    is_list = false,
    setup = function(self)
      -- setup menu
      self.ui_panel_texture = sn.Texture()
      self.ui_panel_texture:FillColor(sn.Color(1, 1, 1, 0.5))
      self.ui_panel = sn.Draw2D(self.ui_panel_texture)
      self.ui_panel.scale = sn.Vec2(1120, 630)
      button.fg_color = sn.Color(0, 0, 0, 0.9)
      button.bg_color = sn.Color(1, 1, 1, 1.0)
    end,
    draw = function(self)
      if self.hide then
        return
      end
    end,
    update = function(self)
      if sn.Keyboard.IsPressed(sn.Keyboard.E) then
        self.hide = not self.hide
      end
      if self.hide then
        return false
      end
      sn.Mouse.HideCursor(false)
      sn.Mouse.SetRelative(false)
      GUI_MANAGER:add(self.ui_panel)
      button.fg_color = sn.Color(1, 1, 1, 0.9)
      button.bg_color = sn.Color(1, 0, 0, 1.0)
      if button:show("BACK", sn.Vec2(500, 270), sn.Vec2(100, 50)) then
        self.hide = true
      end
      button.fg_color = sn.Color(0, 0, 0, 0.9)
      button.bg_color = sn.Color(1, 1, 1, 1.0)
      text:show("MHP: ", sn.Vec2(-400, 200), 50)
      text:show("STM: ", sn.Vec2(-400, 175), 50)
      text:show("OIL: ", sn.Vec2(-400, 150), 50)

      if button:show("SP1", sn.Vec2(-400, 100), sn.Vec2(150, 50)) then
        self.is_list = true
      end
      if button:show("SP2", sn.Vec2(-400, 0), sn.Vec2(150, 50)) then
        self.is_list = true
      end
      if button:show("ORBIT", sn.Vec2(-400, -100), sn.Vec2(150, 50)) then
        self.is_list = true
      end
      if button:show("BOOSTER", sn.Vec2(-400, -200), sn.Vec2(150, 50)) then
        self.is_list = true
      end
      if self.is_list then
        scroll:show(sn.Vec2(200, 0), sn.Vec2(20, 200))
        local offset = scroll.pos.y
        local tex = sn.Texture()
        tex:FillColor(sn.Color(0, 0, 0, 0.5))
        image:show(tex, sn.Vec2(0, 0), sn.Vec2(250, 500))
        if button:show("a", sn.Vec2(0, 100 + offset), sn.Vec2(200, 50)) then
          -- do
        end
        if button:show("b", sn.Vec2(0, 50 + offset), sn.Vec2(200, 50)) then
          -- do
        end
        if button:show("c", sn.Vec2(0, 0 + offset), sn.Vec2(200, 50)) then
          -- do
        end
        image:show(tex, sn.Vec2(0, 200), sn.Vec2(250, 50))
        text:show("EQUIPMENT LIST", sn.Vec2(0, 200), 50)
        button.fg_color = sn.Color(1, 1, 1, 0.9)
        button.bg_color = sn.Color(1, 0, 0, 1.0)
        if button:show("Close", sn.Vec2(0, -150), sn.Vec2(200, 50))
        then
          self.is_list = false
        end
      end


      -- update menu
      return true
    end
  }
  return object
end

return equipment_menu
