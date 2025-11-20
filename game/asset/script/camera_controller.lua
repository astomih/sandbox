---@class camera_controller
---@field position Vec3
---@field target Vec3
---@field up Vec3
---@field prev_boost boolean
---@field is_tracking_player boolean
---@field player Player
---@field py number
---@field pz number
---@field track_speed number
---@field setup fun(self: camera_controller, player: Player)
---@field update fun(self: camera_controller)
---@return camera_controller
local function camera_controller()
    local object = {
        position = sn.Vec3.new(0, 0, 0),
        target = sn.Vec3.new(0, 0, 0),
        up = sn.Vec3.new(0, 0, 1),
        prev_boost = false,
        is_tracking_player = false,
        player = {},
        py = 5,
        pz = 20,
        track_speed = 15,
        ---@paramv self camera_controller
        ---@param player Player
        setup = function(self, player)
            self.player = player
            self.position = sn.Vec3.new(self.player.drawer.position.x, self.player.drawer.position.y - self.py,
                self.player.drawer.position.z + self.pz)
            self.target = sn.Vec3.new(self.player.drawer.position.x, self.player.drawer.position.y,
                self.player.drawer.position.z)
        end,
        ---@param self camera_controller
        update = function(self)
            self.target.x = math.sin(math.rad(self.player.drawer.rotation.z))
            self.target.y = math.cos(math.rad(self.player.drawer.rotation.z))
            self.target.z = math.sin(math.rad(self.player.drawer.rotation.y))
            self.position = self.player.drawer.position:copy()
            sn.Graphics.getCamera():lookat(self.position, self.position + self.target, sn.Vec3.new(0, 0, 1))
        end
    }
    return object
end

return camera_controller
