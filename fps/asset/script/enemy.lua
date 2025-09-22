local bombed = sn.Sound()
bombed:Load("bombed.wav")
local r1 = 0
local r2 = 0

---@param map Grid
---@param map_size_x number
---@param map_size_y number
local function decide_pos(map, map_size_x, map_size_y)
    r1 = sn.Random.GetRange(1, map_size_x)
    r2 = sn.Random.GetRange(1, map_size_y)
    return map:At(r1, r2) < MAP_CHIP_WALKABLE
end

local enemy_model = sn.Model()
enemy_model:Load("enemy.glb")
enemy_model:GetAABB().max.z = 10.0
enemy_model:GetAABB().min.z = -10.0

local enemy_texture = sn.Texture()
enemy_texture:FillColor(sn.Color(0, 1, 0, 1))


---@class enemy
---@field drawer Draw3D
---@field speed number
---@field search_length number
---@field hp number
---@field aabb AABB
---@field is_collision_first boolean
---@field collision_time number
---@field collision_timer number
---@field map Grid
---@field get_forward_z fun(drawer: Draw3D): Vec2
---@field bfs BFSGrid
---@field add_damage fun(self: enemy, damage: number): boolean
---@field setup fun(self: enemy, _map: Grid, map_size_x: number, map_size_y: number)
---@field update fun(self: enemy, player: Player)
---@field draw fun(self: enemy)
---@field player_collision fun(self: enemy, player: Player)
---@return enemy
local enemy = function()
    local object = {
        drawer = {},
        speed = 10,
        search_length = 15,
        hp = 30,
        aabb = {},
        is_collision_first = {},
        collision_time = {},
        collision_timer = {},
        map = {},
        get_forward_z = function(drawer)
            return sn.Vec2(-math.sin(math.rad(drawer.rotation.z)),
                math.cos(math.rad(-drawer.rotation.z)))
        end,
        bfs = {},
        ---Add damage to enemy
        ---@param damage number Damage value
        ---@return boolean Returns true if the enemy is dead
        add_damage = function(self, damage)
            self.hp = self.hp - damage
            if self.hp <= 0 then
                return true
            end
            return false
        end,
        ---@param self enemy
        ---@param _map Grid
        ---@param map_size_x number
        ---@param map_size_y number
        setup = function(self, _map, map_size_x, map_size_y)
            self.bfs = sn.BFSGrid(_map)
            self.drawer = sn.Draw3D(enemy_texture)
            self.drawer.model = enemy_model
            self.drawer.scale = sn.Vec3(0.5, 0.5, 0.5)
            self.aabb = sn.AABB()
            self.map = _map
            r1 = 0
            r2 = 0
            while decide_pos(_map, map_size_x, map_size_y) == true do
            end
            self.drawer.position = sn.Vec3(r1 * TILE_SIZE, r2 * TILE_SIZE, 0.5)
            self.is_collision_first = true
            self.collision_time = 1.0
            self.collision_timer = 0.0
        end,
        ---@param self enemy
        ---@param player Player
        update = function(self, player)
            local dT = sn.Time.DeltaTime()
            local length = (self.drawer.position - player.drawer.position):Length()
            if length > self.search_length then
                return
            end
            self.aabb:UpdateWorld(self.drawer.position, self.drawer.scale, enemy_model:GetAABB())
            -- If there is a wall between the player and the enemy, the enemy will not move.
            local start = sn.Vec2i(
                self.drawer.position.x / TILE_SIZE,
                self.drawer.position.y / TILE_SIZE
            )
            local goal = sn.Vec2i(
                player.drawer.position.x / TILE_SIZE,
                player.drawer.position.y / TILE_SIZE
            )

            local min_x = math.min(start.x, goal.x)
            local max_x = math.max(start.x, goal.x)
            local min_y = math.min(start.y, goal.y)
            local max_y = math.max(start.y, goal.y)
            for i = min_x, max_x do
                if self.map:At(i, start.y) < MAP_CHIP_WALKABLE then
                    return
                end
            end
            for i = min_y, max_y do
                if self.map:At(start.x, i) < MAP_CHIP_WALKABLE then
                    return
                end
            end
            self.drawer.rotation = sn.Vec3(0, 0,
                math.deg(
                    -math.atan(
                        player.drawer.position.x -
                        self.drawer.position.x,
                        player.drawer.position.y -
                        self.drawer.position.y)))
            local foundPath = self.bfs:FindPath(start, goal)
            if foundPath then
                local path = self.bfs:Trace()
                path = self.bfs:Trace()

                local dir = sn.Vec2(
                    path.x * TILE_SIZE - self.drawer.position.x,
                    path.y * TILE_SIZE - self.drawer.position.y)
                if dir.x < -1 then
                    dir.x = -1
                end
                if dir.x > 1 then
                    dir.x = 1
                end
                if dir.y < -1 then
                    dir.y = -1
                end
                if dir.y > 1 then
                    dir.y = 1
                end

                self.drawer.position.x =
                    self.drawer.position.x +
                    dir.x * dT * self.speed
                self.drawer.position.y =
                    self.drawer.position.y +
                    dir.y * dT * self.speed
            else
                self.drawer.position.x =
                    self.drawer.position.x + dT * self.speed *
                    self.get_forward_z(self.drawer).x
                self.drawer.position.y =
                    self.drawer.position.y + dT * self.speed *
                    self.get_forward_z(self.drawer).y
            end
            self.bfs:Reset()
        end,

        ---@param self enemy
        draw = function(self)
            sn.Graphics.Draw3D(self.drawer)
        end,

        ---@param self enemy
        ---@param player Player
        player_collision = function(self, player)
            if sn.Collision.AABBvsAABB(self.aabb, player.aabb) then
                if self.is_collision_first then
                    bombed:Play()
                    player.hp = player.hp - 1
                    if player.hp <= 0 then
                        player.hp = 0
                    end
                    player:render_text()
                    self.is_collision_first = false
                else
                    self.collision_timer = self.collision_timer + sn.Time.DeltaTime()
                    if self.collision_timer > self.collision_time then
                        bombed:Play()
                        player.hp = player.hp - 10
                        if player.hp <= 0 then
                            player.hp = 0
                        end
                        player:render_text()
                        self.collision_timer = 0.0
                    end
                end
            else
                self.is_collision_first = true
            end
        end
    }
    return object
end
return enemy
