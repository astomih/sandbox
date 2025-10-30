local m = sn.Model.new()
local sound = sn.Sound.new()
sound:load("shot.wav")
sound:setVolume(0.3)

---@class Bullet
local Bullet = {
    ---@type number
    speed = 40,
    ---@type sn.Draw3D
    drawer = {},
    ---@type sn.Vec3
    forward = sn.Vec3.new(0, 0, 0),
    ---@type number
    life_time = 0.25,
    ---@type number
    current_time = 0.0,
    ---@type sn.AABB
    aabb = {},
    ---@type sn.Texture
    texture = {}
}
Bullet.__index = Bullet
Bullet.new = function()
    return setmetatable({}, Bullet)
end
---@param self Bullet
---@param owner sn.Draw3D
---@param forward sn.Vec3
Bullet.setup = function(self, owner, forward)
    self.aabb = sn.AABB.new()
    self.texture = sn.Texture.new()
    self.texture:fill(sn.Color.new(1.0, 1.0, 1.0, 1.0))
    self.drawer = sn.Draw3D.new(self.texture)
    self.drawer.position = sn.Vec3.new(owner.position.x, owner.position.y, owner.position.z)
    self.drawer.rotation = owner.rotation
    self.drawer.scale = sn.Vec3.new(0.2, 0.2, 0.2)
    self.forward = forward
    sound:play()
end
---@param self Bullet
Bullet.update = function(self)
    local dT = sn.Time.delta()
    self.aabb.max = self.drawer.position + (self.drawer.scale * m:getAABB().max)
    self.aabb.min = self.drawer.position + (self.drawer.scale * m:getAABB().min)
    self.current_time = self.current_time + dT
    self.drawer.position = self.drawer.position +
                               (self.forward * sn.Vec3.new(self.speed, self.speed, self.speed) * sn.Vec3.new(dT))
end
---@param self Bullet
Bullet.draw = function(self)
    sn.Graphics.draw3D(self.drawer)
end

return Bullet
