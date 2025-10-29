local bullet = require "bullet"
local calc_input_vector = require "calc_input_vector"
local is_collision = require "is_collision"
local input_vector = {}
local speed = 2.0
local effect = require "effect"
local r1 = 0
local r2 = 0

local scopeTex = sn.Texture.new()
scopeTex:load("scope.png")

---@param map sn.Grid
local function decide_pos(map, map_size_x, map_size_y)
    r1 = math.random(1, map_size_x)
    r2 = math.random(1, map_size_y)
    return map:at(r1, r2) == 1
end

local beforeMousePos = sn.Vec2.new(0, 0)

local Player = {
    ---@type sn.Draw3D
    drawer = {},
    ---@type number
    rotationZ = 0.0,
    model = {},
    bullets = {},
    hp = 0,
    hp_max = 100,
    hp_drawer = {},
    hp_font = {},
    hp_font_texture = {},
    stamina = {},
    stamina_max = 100,
    stamina_recover_speed = 20,
    stamina_boost_cost = 20,
    stamina_run_cost = 5,
    stamina_texture = {},
    stamina_drawer = {},
    stamina_max_texture = {},
    stamina_max_drawer = {},
    aabb = {},
    bullet_time = {},
    bullet_timer = {},
    bullet_flag = false,
    efks = {},
    is_shot = true,
    boost = 0.0,
    boost_time = 0.3,
    boost_timer = 0.0,
    boost_mag = 5,
    boost_sound = {},
    is_boost = false,
    speed_min = 6.0,
    speed_max = 16.0,
    blur_time = 0.0,
    scopePos = sn.Vec2.new(0),
    boost_reset = function(self)
        self.boost_timer = 0.0
        self.boost = 0.0
        self.is_boost = false
    end,
    ---@param self Player
    ---@param map sn.Grid
    ---@param map_size_x number
    ---@param map_size_y number
    setup = function(self, map, map_size_x, map_size_y)
        self.model = sn.Model.new()
        self.model:load("triangle.glb")
        self.drawer = sn.Draw3D.new(DEFAULT_TEXTURE)
        self.drawer.model = self.model
        self.aabb = sn.AABB.new()
        self.bullet_time = 0.1
        self.bullet_timer = 0.0
        self.hp = 100
        self.hp_font = sn.Font.new()
        self.hp_font:load(64, DEFAULT_FONT_NAME)
        self.hp_font_texture = sn.Texture.new()
        self.hp_drawer = sn.Draw2D.new(self.hp_font_texture)
        self.stamina = self.stamina_max
        self.stamina_texture = sn.Texture.new()
        self.stamina_texture:fill(sn.Color.new(1.0, 1.0, 1.0, 0.9))
        self.stamina_max_texture = sn.Texture.new()
        self.stamina_max_texture:fill(sn.Color.new(0.0, 0.0, 0.0, 0.2))
        self.stamina_drawer = sn.Draw2D.new(self.stamina_texture)
        self.stamina_drawer.position = sn.Vec2.new(0, 350)
        self.stamina_drawer.scale = UI_SCALE_Vec2(300, 10)
        self.stamina_max_drawer = sn.Draw2D.new(self.stamina_max_texture)
        self.stamina_max_drawer.position = sn.Vec2.new(0, 350)
        self.stamina_max_drawer.scale = UI_SCALE_Vec2(300, 10)

        self:render_text()
        r1 = 0
        r2 = 0
        while decide_pos(map, map_size_x, map_size_y) == true do
        end
        self.drawer.position = sn.Vec3.new(r1 * 2, r2 * 2, 0.5)
        self.drawer.scale = sn.Vec3.new(1)
        self.hp_drawer.position.x = 0
        self.hp_drawer.position.y = 300
        self.boost_sound = sn.Sound.new()
        self.boost_sound:load("boost.wav")
        self.boost_sound:setVolume(0.2)
    end,
    horizontal = math.pi,
    vertical = 0.0,
    ---@param self Player
    ---@param map Grid
    ---@param map_draw3ds world[][]
    ---@param map_size_x number
    ---@param map_size_y number
    update = function(self, map, map_draw3ds, map_size_x, map_size_y)
        local p = self.drawer.position:copy()
        self.aabb:updateWorld(self.drawer.position, self.drawer.scale, self.model:getAABB())
        input_vector = calc_input_vector()
        local is_move = input_vector.x ~= 0 or input_vector.y ~= 0

        if sn.Keyboard.isDown(sn.Keyboard.LSHIFT) and is_move then
            speed = self.speed_max
            self.stamina = self.stamina - self.stamina_run_cost * sn.Time.delta()
            if self.stamina <= 0.0 then
                self.stamina = 0.0
                speed = self.speed_min
            end
        else
            speed = self.speed_min
            self.stamina = self.stamina + sn.Time.delta() * self.stamina_recover_speed
            if self.stamina > self.stamina_max then
                self.stamina = self.stamina_max
            end
        end
        -- bullet
        if sn.Mouse.isPressed(sn.Mouse.LEFT) then
            self.bullet_flag = true
        end
        self.bullet_timer = self.bullet_timer + sn.Time.delta()
        if self.bullet_flag then
            if self.bullet_timer > self.bullet_time and (sn.Mouse.isDown(sn.Mouse.LEFT)) then
                local b = bullet(map_draw3ds)

                local forward = sn.Vec3.new(math.cos(math.rad(self.rotationZ)), math.sin(math.rad(self.rotationZ)),
                    math.sin(math.rad(self.drawer.rotation.y)))
                local cross = sn.Vec3.new(math.cos(math.rad(self.rotationZ + 90)),
                    math.sin(math.rad(self.rotationZ + 90)), -0.5)

                local rot = forward * sn.Vec3.new(1000) - cross
                rot = rot:normalize()
                b:setup(self.drawer, rot)

                b.drawer.position = b.drawer.position + cross * sn.Vec3.new(0.25, 0.25, 1)

                table.insert(self.bullets, b)
                self.bullet_timer = 0.0
            end
            if sn.Mouse.isReleased(sn.Mouse.LEFT) then
                self.bullet_flag = false
            end
        end
        if self.is_boost then
            if self.boost_timer >= self.boost_time then
                self:boost_reset()
            else
                local t = sn.Periodic.sin0_1(self.boost_time * 2.0, self.boost_timer) - 0.5
                t = t * 0.2
                self.boost_timer = self.boost_timer + sn.Time.delta()
            end
        else
            if sn.Keyboard.isPressed(sn.Keyboard.SPACE) and is_move then
                if self.stamina >= self.stamina_boost_cost then
                    self.stamina = self.stamina - self.stamina_boost_cost
                    if self.stamina <= 0.0 then
                        self.stamina = 0.0
                    end
                    local efk = effect()
                    efk:setup()
                    efk.texture:fill(sn.Color.new(0.6, 0.6, 1.0, 1.0))
                    efk.impl = function(e)
                        for i = 1, e.max_particles do
                            local t = sn.Time.delta() * 2
                            e.worlds[i].position.x = e.worlds[i].position.x + math.cos(i) * t
                            e.worlds[i].position.y = e.worlds[i].position.y + math.sin(i) * t
                            e.worlds[i].position.z = e.worlds[i].position.z + t
                        end
                    end
                    for j = 1, efk.max_particles do
                        efk.worlds[j].position = self.drawer.position:copy()
                    end
                    efk:play()
                    table.insert(self.efks, efk)
                    self.boost_sound:play()
                    self.boost = self.boost_mag
                    self.is_boost = true
                    self.boost_timer = 0.0
                end
            end
        end
        for i, v in ipairs(self.bullets) do
            v:update()
            if v.current_time > v.life_time then
                local efk = effect()
                efk:setup()
                efk.texture:fill(sn.Color.new(1.0, 1.0, 1.0, 1.0))
                for j = 1, efk.max_particles do
                    efk.worlds[j].position = v.drawer.position:copy()
                end
                efk:play()
                table.insert(self.efks, efk)
                table.remove(self.bullets, i)
            end
        end
        for i, v in ipairs(self.efks) do
            v:update()
            if v.is_stop then
                table.remove(self.efks, i)
            end
        end
        local before_pos = sn.Vec3.new(self.drawer.position.x, self.drawer.position.y, self.drawer.position.z)
        local final_speed = 0.0
        if self.is_boost then
            final_speed = self.speed_max * self.boost
        else
            final_speed = speed
        end
        if input_vector.x ~= 0 and input_vector.y ~= 0 then
            final_speed = final_speed / math.sqrt(2)
        end

        before_pos = self.drawer.position:copy()
        local flag = false
        if input_vector.y ~= 0 then
            flag = true
            self.drawer.position = self.drawer.position +
                                       sn.Vec3.new(0, input_vector.y * final_speed * sn.Time.delta(), 0)
        end
        if input_vector.x ~= 0 then
            flag = true
            self.drawer.position = self.drawer.position +
                                       sn.Vec3.new(input_vector.x * final_speed * sn.Time.delta(), 0, 0)
        end

        if flag then
            local dxy = sn.Vec2.new(self.drawer.position.x, self.drawer.position.y) -
                            sn.Vec2.new(before_pos.x, before_pos.y)
            self.aabb:updateWorld(self.drawer.position - sn.Vec3.new(0, dxy.y, 0), self.drawer.scale,
                self.model:getAABB())
            if is_collision(self.drawer.position - sn.Vec3.new(0, dxy.y, 0), self.aabb, map, map_draw3ds, map_size_x,
                map_size_y) then
                self.drawer.position.x = before_pos.x
            end
            self.aabb:updateWorld(self.drawer.position - sn.Vec3.new(dxy.x, 0, 0), self.drawer.scale,
                self.model:getAABB())
            if is_collision(self.drawer.position - sn.Vec3.new(dxy.x, 0, 0), self.aabb, map, map_draw3ds, map_size_x,
                map_size_y) then
                self.drawer.position.y = before_pos.y
            end
        end
        local pos = sn.Mouse.getPositionOnScene()
        self.scopePos.x = pos.x
        self.scopePos.y = pos.y
        local r = 200
        -- Make the coordinates fit in a circle of radius r
        local x = self.scopePos.x
        local y = self.scopePos.y
        local d = self.scopePos:length()
        if d > r then
            local r_prime = r / d - 0.01
            x = x * r_prime
            y = y * r_prime
            self.scopePos.x = x
            self.scopePos.y = y
            local newPos = sn.Vec2.new(x, y)
            sn.Mouse.setPositionOnScene(newPos)
        end
        self.scopePos:normalize()
        local drawer_scope_angle = math.atan(self.scopePos.y, self.scopePos.x)
        self.rotationZ = math.deg(drawer_scope_angle)
        self.drawer.rotation.z = self.rotationZ - 90
        local s_ratio = self.stamina / self.stamina_max
        self.stamina_drawer.scale.x = s_ratio * 300
        if s_ratio <= 0.2 then
            self.stamina_texture:fill(sn.Color.new(1.0, 0.0, 0.0, 0.9))
        else
            self.stamina_texture:fill(sn.Color.new(1.0, 1.0, 1.0, 0.9))
        end
    end,
    ---@param self Player
    draw3 = function(self)
        sn.Graphics.draw3D(self.drawer)
        for i, v in ipairs(self.efks) do
            v:draw()
        end
        for i, v in ipairs(self.bullets) do
            v:draw()
        end
    end,
    ---@param self Player
    draw2 = function(self)
        sn.Graphics.draw2D(self.hp_drawer)
        sn.Graphics.draw2D(self.stamina_max_drawer)
        sn.Graphics.draw2D(self.stamina_drawer)
        sn.Graphics.drawImage(scopeTex, sn.Rect.new(self.scopePos, scopeTex:size()))
    end,
    ---@param self Player
    render_text = function(self)
        if self.hp / self.hp_max <= 0.2 then
            self.hp_font:renderText(self.hp_font_texture, "HP: " .. self.hp, sn.Color.new(1, 0.0, 0.0, 0.8))
        else
            self.hp_font:renderText(self.hp_font_texture, "HP: " .. self.hp, sn.Color.new(1, 1, 1, 0.9))
        end
        self.hp_drawer.scale = self.hp_font_texture:size()
    end
}

return Player
