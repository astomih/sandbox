---@class scene_switcher
---@field texture Texture
---@field color Color
---@field drawer Draw2D
---@field time number
---@field timer number
---@field flag boolean
---@field scene_name string
---@field is_launch boolean
---@field setup fun(self: scene_switcher)
---@field update fun(self: scene_switcher)
---@field draw fun(self: scene_switcher)
---@field start fun(self: scene_switcher, scene_name: string)
---@return scene_switcher
local scene_switcher = function()
    return {
        texture = sn.Texture(),
        color = sn.Color(0, 0, 0, 0.0),
        drawer = sn.Draw2D(),
        time = 0.25,
        timer = 0.0,
        flag = false,
        scene_name = "",
        is_launch = false,
        setup = function(self)
            self.drawer.material:set_texture(self.texture)
            self.drawer.scale = sn.Window:size()
        end,
        update = function(self)
            self.drawer.scale = sn.Window:size()
            if self.flag then
                if not self.is_launch then
                    if self.timer < self.time then
                        self.timer = self.timer + sn.Time.delta()
                        local t = self.timer * (1.0 / self.time)
                        if t > 1.0 then
                            t = 1.0
                        end
                        if t < 0.0 then
                            t = 1.0
                        end
                        self.texture:fill(sn.Color(self.color.r, self.color.g, self.color.b, t))
                    else
                        self.timer = 0
                        self.texture:fill(sn.Color(self.color.r, self.color.g, self.color.b, 1.0))
                        self.flag = false
                        sn.Script.load(self.scene_name)
                    end
                else
                    if self.timer > 0.0 then
                        self.timer = self.timer - sn.Time.delta()
                        local t = self.timer * (1.0 / self.time)
                        if t < 0.0 then
                            t = 0.0
                        end
                        self.texture:fill(sn.Color(self.color.r, self.color.g, self.color.b, t))
                    else
                        self.flag = false
                        self.texture:fill(sn.Color(self.color.r, self.color.g, self.color.b, 0.0))
                        self.timer = 0.0
                    end
                end
            end
        end,
        draw = function(self)
            sn.Graphics.draw2d(self.drawer)
        end,
        start = function(self, scene_name)
            self.is_launch = string.len(scene_name) == 0
            if self.is_launch then
                self.texture:fill(sn.Color(self.color.r, self.color.g, self.color.b, 1.0))
                self.flag = false
                self.timer = self.time
            else
                self.texture:fill(sn.Color(self.color.r, self.color.g, self.color.b, 0.0))
                self.timer = 0.0
            end
            self.scene_name = scene_name
            self.flag = true
        end
    }
end
return scene_switcher
