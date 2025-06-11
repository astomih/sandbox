local function text()
  local object = {
    font = {},
    drawer = {},
    color = Color(1, 1, 1, 0.9),
    show = function(self, text, pos, scale)
      local texture = GUI_MANAGER:get_texture()
      self.drawer = Draw2D(texture)
      self.font:RenderText(texture, text, self.color)
      self.drawer.scale = texture:Size()
      self.drawer.position = pos
      GUI_MANAGER:add(self.drawer)
    end,
  }
  object.font = Font()
  object.font:Load(32, DEFAULT_FONT_NAME)
  object.drawer = Draw2D(Texture())

  return object
end

return text
