local function text()
    local object = {
        font = {},
        drawer = {},
        color = sn.Color.new(1, 1, 1, 0.9),
        show = function(self, text, pos, scale)
            local texture = GUI_MANAGER:get_texture()
            self.drawer = sn.Draw2D.new(texture)
            self.font:renderText(texture, text, self.color)
            self.drawer.scale = texture:size()
            self.drawer.position = pos
            GUI_MANAGER:add(self.drawer)
        end,
    }
    object.font = sn.Font.new()
    object.font:load(32, DEFAULT_FONT_NAME)
    object.drawer = sn.Draw2D.new(sn.Texture.new())

    return object
end

return text
