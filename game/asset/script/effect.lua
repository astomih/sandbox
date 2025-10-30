local world = require "world"

---@class Effect
local Effect = {
    ---@type number
    duration = 1.0,
    ---@type boolean
    looping = false,
    ---@type boolean
    prewarm = false,
    ---@type number
    start_lifetime = 1.0,
    ---@type number
    start_speed = 5.0,
    ---@type number
    start_size = 1.0,
    ---@type number
    start_rotation = 0.0,
    ---@type sn.Color
    start_color = sn.Color.new(1, 1, 1, 1),
    ---@type number
    gravity_multiplier = 0.0,
    ---@type number
    inherit_velocity = 0.0,
    ---@type boolean
    play_on_awake = false,
    ---@type integer
    max_particles = 10,
    ---@type sn.Draw3D
    drawer = {},
    ---@type sn.Texture
    texture = {},
    ---@type world[]
    worlds = {},
    ---@type boolean
    is_playing = false,
    ---@type boolean
    is_stop = false,
    ---@type number
    timer = 0.0
}

Effect.__index = Effect

Effect.new = function()
    return setmetatable({}, Effect)
end

Effect.setup = function(self)
    self.texture = sn.Texture.new()
    self.texture:fill(self.start_color)
    self.drawer = sn.Draw3D.new(self.texture)
    for i = 1, self.max_particles do
        self.worlds[i] = world()
        self.worlds[i].position = sn.Vec3.new(0)
        self.worlds[i].rotation = sn.Vec3.new(0)
        self.worlds[i].scale = sn.Vec3.new(0.1)
    end
    if self.play_on_awake then
        self.is_playing = true
    end
end
---@param self Effect
Effect.impl = function(self)
    local dT = sn.Time.delta()
    for i = 1, self.max_particles do
        self.worlds[i].position.x = self.worlds[i].position.x + math.cos(i) * dT
        self.worlds[i].position.y = self.worlds[i].position.y + math.sin(i) * dT
        self.worlds[i].position.z = self.worlds[i].position.z + dT
    end
end
---@param self Effect
Effect.update = function(self)
    --  if not self.is_playing then return end
    self.drawer:clear()
    self.timer = self.timer + sn.Time.delta()
    if self.timer > self.start_lifetime then
        self.timer = 0.0
        for i = 1, self.max_particles do
            self.worlds[i].position = sn.Vec3.new(0)
            self.worlds[i].rotation = sn.Vec3.new(0)
            self.worlds[i].scale = sn.Vec3.new(0.1)
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
end
---@param self Effect
Effect.draw = function(self)
    if self.is_playing then
        sn.Graphics.draw3D(self.drawer)
    end
end
---@param self Effect
Effect.play = function(self)
    self.is_playing = true
    self.is_stop = false
end
return Effect
