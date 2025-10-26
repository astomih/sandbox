local world = require "world"
local tree = sn.Model.new()

---@class effect
---@field duration number
---@field looping boolean
---@field prewarm boolean
---@field start_lifetime number
---@field start_speed number
---@field start_size number
---@field start_rotation number
---@field start_color Color
---@field gravity_multiplier number
---@field inherit_velocity number
---@field play_on_awake boolean
---@field max_particles number
---@field drawer Draw3D
---@field texture Texture
---@field worlds world[]
---@field is_playing boolean
---@field is_stop boolean
---@field timer number
---@field setup fun(self: effect)
---@field impl fun(self: effect)
---@field update fun(self: effect)
---@field draw fun(self: effect)
---@field play fun(self: effect)
---@return effect
local function effect()
    local object = {
        duration = 1.0,
        looping = false,
        prewarm = false,
        start_lifetime = 1.0,
        start_speed = 5.0,
        start_size = 1.0,
        start_rotation = 0.0,
        start_color = sn.Color.new(1, 1, 1, 1),
        gravity_multiplier = 0.0,
        inherit_velocity = 0.0,
        play_on_awake = false,
        max_particles = 10,
        drawer = {},
        texture = {},
        worlds = {},
        is_playing = false,
        is_stop = false,
        timer = 0.0,
        ---@param self effect
        setup = function(self)
            self.texture = sn.Texture.new()
            self.texture:fill(self.start_color)
            self.drawer = sn.Draw3D.new(self.texture)
            for i = 1, self.max_particles do
                self.worlds[i] = world()
                self.worlds[i].position = sn.Vec3.new(0, 0, 0)
                self.worlds[i].rotation = sn.Vec3.new(0, 0, 0)
                self.worlds[i].scale = sn.Vec3.new(0.1, 0.1, 0.1)
            end
            if self.play_on_awake then
                self.is_playing = true
            end
        end,
        ---@param self effect
        impl = function(self)
            local dT = sn.Time.delta()
            for i = 1, self.max_particles do
                self.worlds[i].position.x = self.worlds[i].position.x + math.cos(i) * dT
                self.worlds[i].position.y = self.worlds[i].position.y + math.sin(i) * dT
                self.worlds[i].position.z = self.worlds[i].position.z + dT
            end
        end,
        ---@param self effect
        update = function(self)
            --  if not self.is_playing then return end
            self.drawer:clear()
            self.timer = self.timer + sn.Time.delta()
            if self.timer > self.start_lifetime then
                self.timer = 0.0
                for i = 1, self.max_particles do
                    self.worlds[i].position = sn.Vec3.new(0, 0, 0)
                    self.worlds[i].rotation = sn.Vec3.new(0, 0, 0)
                    self.worlds[i].scale = sn.Vec3.new(1, 1, 1)
                end
                if not self.looping then
                    self.is_playing = false
                    self.is_stop = true
                end
            end
            self:impl()
            if self.is_playing then
                for i = 1, self.max_particles do
                    self.drawer:add(self.worlds[i].position, self.worlds[i].rotation, self.worlds[i].scale)
                end
            end
        end,
        ---@param self effect
        draw = function(self)
            if self.is_playing then
                sn.Graphics.draw3D(self.drawer)
            end
        end,
        ---@param self effect
        play = function(self)
            self.is_playing = true
            self.is_stop = false
        end
    }
    return object
end

return effect
