local m = sn.Model()
local sound = sn.Sound()
sound:load("shot.wav")
sound:set_volume(0.3)

---@class bullet
---@field speed number
---@field drawer Draw3D
---@field forward Vec3
---@field life_time number
---@field current_time number
---@field aabb AABB
---@field texture Texture
---@field setup fun(self: bullet, owner: Draw3D, forward: Vec3)
---@field update fun(self: bullet)
---@field draw fun(self: bullet)
---@return bullet
local function bullet(map_draw3ds)
    local object = {
        speed = 40,
        drawer = {},
        forward = sn.Vec3(0, 0, 0),
        life_time = 0.25,
        current_time = 0,
        aabb = {},
        texture = {},
        ---@param self bullet
        ---@param owner Draw3D
        ---@param forward Vec3
        setup = function(self, owner, forward)
            self.aabb = sn.AABB()
            self.texture = sn.Texture()
            self.texture:fill(sn.Color(1.0, 1.0, 1.0, 1.0))
            self.drawer = sn.Draw3D(self.texture)
            self.drawer.position = sn.Vec3(owner.position.x, owner.position.y,
                owner.position.z)
            self.drawer.rotation = owner.rotation
            self.drawer.scale = sn.Vec3(0.2, 0.2, 0.2)
            self.forward = forward
            sound:play()
        end,
        ---@param self bullet
        update = function(self)
            local dT = sn.Time.delta()
            self.aabb.max = self.drawer.position + (
                self.drawer.scale * m:get_aabb().max)
            self.aabb.min = self.drawer.position + (
                self.drawer.scale * m:get_aabb().min)
            self.current_time = self.current_time + dT
            self.drawer.position = self.drawer.position +
                (self.forward * sn.Vec3(self.speed, self.speed, self.speed) * sn.Vec3(dT))
        end,
        ---@param self bullet
        draw = function(self)
            sn.Graphics.draw3d(self.drawer)
        end
    }

    return object
end

return bullet
