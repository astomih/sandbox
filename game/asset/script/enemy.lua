local bombedSound = sn.Sound.new()
bombedSound:load("bombed.wav")
local r1 = 0
local r2 = 0

---@param map sn.Grid
---@param mapSizeX number
---@param mapSizeY number
local function decidePos(map, mapSizeX, mapSizeY)
    r1 = sn.Random.getRange(1, mapSizeX)
    r2 = sn.Random.getRange(1, mapSizeY)
    return map:at(r1, r2) < MAP_CHIP_WALKABLE
end

local enemyModel = sn.Model.new()
enemyModel:load("enemy.glb")
enemyModel:getAABB().max.z = 10.0
enemyModel:getAABB().min.z = -10.0

local enemyTexture = sn.Texture.new()
enemyTexture:fill(sn.Color.new(0, 1, 0, 1))

---@class Enemy
local Enemy = {
    ---@type sn.Draw3D 
    drawer = {},
    ---@type number
    speed = 10,
    ---@type number
    search_length = 15,
    ---@type integer
    hp = 30,
    ---@type sn.AABB
    aabb = {},
    ---@type boolean
    is_collision_first = {},
    ---@type number
    collision_time = {},
    ---@type sn.Timer
    collision_timer = {},
    ---@type sn.Grid
    map = {},
    ---@type sn.BFSGrid
    bfs = {}
}

Enemy.__index = Enemy

Enemy.new = function()
    return setmetatable({}, Enemy)
end

Enemy.get_forward_z = function(drawer)
    return sn.Vec2.new(-math.sin(math.rad(drawer.rotation.z)), math.cos(math.rad(-drawer.rotation.z)))
end

---Add damage to enemy
---@param self Enemy
---@param damage number Damage value
---@return boolean Returns true if the enemy is dead
Enemy.add_damage = function(self, damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        return true
    end
    return false
end

---@param self Enemy
---@param map sn.Grid
---@param mapSizeX number
---@param mapSizeY number
Enemy.setup = function(self, map, mapSizeX, mapSizeY)
    self.bfs = sn.BFSGrid.new(map)
    self.drawer = sn.Draw3D.new(enemyTexture)
    self.drawer.model = enemyModel
    self.drawer.scale = sn.Vec3.new(0.5, 0.5, 0.5)
    self.aabb = sn.AABB.new()
    self.map = map
    r1 = 0
    r2 = 0
    while decidePos(map, mapSizeX, mapSizeY) == true do
    end
    self.drawer.position = sn.Vec3.new(r1 * TILE_SIZE, r2 * TILE_SIZE, 0.5)
    self.is_collision_first = true
    self.collision_time = 1.0
    self.collision_timer = 0.0
end

---@param self Enemy
---@param player Player
Enemy.update = function(self, player)
    local dT = sn.Time.delta()
    local length = (self.drawer.position - player.drawer.position):length()
    if length > self.search_length then
        return
    end
    self.aabb:updateWorld(self.drawer.position, self.drawer.scale, enemyModel:getAABB())
    -- If there is a wall between the player and the enemy, the enemy will not move.
    local start = sn.Vec2i.new(self.drawer.position.x / TILE_SIZE, self.drawer.position.y / TILE_SIZE)
    local goal = sn.Vec2i.new(player.drawer.position.x / TILE_SIZE, player.drawer.position.y / TILE_SIZE)

    local min_x = math.min(start.x, goal.x)
    local max_x = math.max(start.x, goal.x)
    local min_y = math.min(start.y, goal.y)
    local max_y = math.max(start.y, goal.y)
    for i = min_x, max_x do
        if self.map:at(i, start.y) < MAP_CHIP_WALKABLE then
            return
        end
    end
    for i = min_y, max_y do
        if self.map:at(start.x, i) < MAP_CHIP_WALKABLE then
            return
        end
    end
    self.drawer.rotation = sn.Vec3.new(0, 0, math.deg(-math.atan(player.drawer.position.x - self.drawer.position.x,
        player.drawer.position.y - self.drawer.position.y)))
    local foundPath = self.bfs:findPath(start, goal)
    if foundPath then
        local path = self.bfs:trace()
        path = self.bfs:trace()

        local dir = sn.Vec2
                        .new(path.x * TILE_SIZE - self.drawer.position.x, path.y * TILE_SIZE - self.drawer.position.y)
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

        self.drawer.position.x = self.drawer.position.x + dir.x * dT * self.speed
        self.drawer.position.y = self.drawer.position.y + dir.y * dT * self.speed
    else
        self.drawer.position.x = self.drawer.position.x + dT * self.speed * self.get_forward_z(self.drawer).x
        self.drawer.position.y = self.drawer.position.y + dT * self.speed * self.get_forward_z(self.drawer).y
    end
    self.bfs:reset()
end

---@param self Enemy
Enemy.draw = function(self)
    sn.Graphics.draw3D(self.drawer)
end

---@param self Enemy
---@param player Player
Enemy.player_collision = function(self, player)
    if sn.Collision.AABBvsAABB(self.aabb, player.aabb) then
        if self.is_collision_first then
            bombedSound:play()
            player.hp = player.hp - 1
            if player.hp <= 0 then
                player.hp = 0
            end
            player:render_text()
            self.is_collision_first = false
        else
            self.collision_timer = self.collision_timer + sn.Time.delta()
            if self.collision_timer > self.collision_time then
                bombedSound:play()
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
return Enemy
