local function camera_controller()
  local object = {
    position = Vec3(0, 0, 0),
    target = Vec3(0, 0, 0),
    up = Vec3(0, 0, 1),
    prev_boost = false,
    is_tracking_player = false,
    player = {},
    py = 5,
    pz = 12,
    track_speed = 15,
    setup = function(self, player)
      self.player = player
      self.position = Vec3(self.player.drawer.position.x,
        self.player.drawer.position.y - self.py,
        self.player.drawer.position.z + self.pz)
      self.target = Vec3(self.player.drawer.position.x,
        self.player.drawer.position.y,
        self.player.drawer.position.z)
    end,
    update = function(self)
      -- rotation to look at the player Vec3
      self.target.x = math.sin(math.rad(self.player.drawer.rotation.z))
      self.target.y = math.cos(math.rad(self.player.drawer.rotation.z))
      self.target.z = math.sin(math.rad(self.player.drawer.rotation.y))
      self.position = self.player.drawer.position:copy()
      scene.camera():lookat(self.position, self.position + self.target, Vec3(0, 0, 1))
    end
  }
  return object
end

return camera_controller
