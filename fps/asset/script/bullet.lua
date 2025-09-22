local m = sn.Model()
local sound = sn.Sound()
sound:Load("shot.wav")
sound:SetVolume(0.3)

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
            self.texture:FillColor(sn.Color(1.0, 1.0, 1.0, 1.0))
            self.drawer = sn.Draw3D(self.texture)
            self.drawer.position = sn.Vec3(owner.position.x, owner.position.y,
                owner.position.z)
            self.drawer.rotation = owner.rotation
            self.drawer.scale = sn.Vec3(0.2, 0.2, 0.2)
            self.forward = forward
            sound:Play()
        end,
        ---@param self bullet
        update = function(self)
            local dT = sn.Time.DeltaTime()
            self.aabb.max = self.drawer.position + (
                self.drawer.scale * m:GetAABB().max)
            self.aabb.min = self.drawer.position + (
                self.drawer.scale * m:GetAABB().min)
            self.current_time = self.current_time + dT
            self.drawer.position = self.drawer.position +
                (self.forward * sn.Vec3(self.speed, self.speed, self.speed) * sn.Vec3(dT))
        end,
        ---@param self bullet
        draw = function(self)
            sn.Graphics.Draw3D(self.drawer)
        end
    }

    return object
end

return bullet
