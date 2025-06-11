local scene_switcher = function()
  local object = {
    texture = Texture(),
    color = Color(0, 0, 0, 0.0),
    drawer = Draw2D(),
    time = 0.25,
    timer = 0.0,
    flag = false,
    scene_name = "",
    is_launch = false,
    setup = function(self)
      self.drawer.material:SetTexture(self.texture)
      self.drawer.scale = Window:Size()
    end,
    update = function(self)
      self.drawer.scale = Window:Size()
      if self.flag then
        if not self.is_launch then
          if self.timer < self.time then
            self.timer = self.timer + Scene.DeltaTime()
            local t = self.timer * (1.0 / self.time)
            if t > 1.0 then
              t = 1.0
            end
            if t < 0.0 then
              t = 1.0
            end
            self.texture:FillColor(Color(self.color.r, self.color.g, self.color.b, t))
          else
            self.timer = 0
            self.texture:FillColor(Color(self.color.r, self.color.g, self.color.b, 1.0))
            self.flag = false
            Scene.Change(self.scene_name)
          end
        else
          if self.timer > 0.0 then
            self.timer = self.timer - Scene.DeltaTime()
            local t = self.timer * (1.0 / self.time)
            if t < 0.0 then
              t = 0.0
            end
            self.texture:FillColor(Color(self.color.r, self.color.g, self.color.b, t))
          else
            self.flag = false
            self.texture:FillColor(Color(self.color.r, self.color.g, self.color.b, 0.0))
            self.timer = 0.0
          end
        end
      end
    end,
    draw = function(self)
      self.drawer:Draw()
    end,
    start = function(self, scene_name)
      self.is_launch = string.len(scene_name) == 0
      if self.is_launch then
        self.texture:FillColor(Color(self.color.r, self.color.g, self.color.b, 1.0))
        self.flag = false
        self.timer = self.time
      else
        self.texture:FillColor(Color(self.color.r, self.color.g, self.color.b, 0.0))
        self.timer = 0.0
      end
      self.scene_name = scene_name
      self.flag = true
    end
  }
  return object
end
return scene_switcher
