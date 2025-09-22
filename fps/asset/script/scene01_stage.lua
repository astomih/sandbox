local player = require "player"
local enemy = require "enemy"
local dungeon_generator = require "dungeon_generator/dungeon_generator"
local enemies = {}
local enemy_max_num = 100
local world = require "world"
local effect = require "effect"
local map_size_x = 64
local map_size_y = 64
local map = sn.Grid(map_size_x, map_size_y)
local map_z = sn.Grid(map_size_x, map_size_y)
-- draw object
local map_draw3ds = {}
local box = {}
local sprite = {}
local menu = {}
local stair = {}
-- assets
local tile = sn.Texture()
tile:FillColor(sn.Color(0.416, 0.204, 0.153, 1))

local score_font = sn.Font()
local score_texture = sn.Texture()
local score_drawer = sn.Draw2D(score_texture)
local sprite_model = sn.Model()
sprite_model:LoadSprite()

local menu = require("gui/menu")
local menu_object = menu()
local scene_switcher = require("scene_switcher")()

local equipment_menu = require("gui/equipment_menu")()

local camera_controller = require("camera_controller")()

score_font:Load(64, DEFAULT_FONT_NAME)
menu_object:setup()
DEFAULT_TEXTURE = sn.Texture()
DEFAULT_TEXTURE:FillColor(sn.Color(1, 1, 1, 1))
map:Fill(0)
map_z:Fill(0)
dungeon_generator(map, 0, -1, 4, 3, 2)

box = sn.Draw3D(DEFAULT_TEXTURE)
local sprite_model = sn.Model()
sprite_model:LoadSprite()
sprite = sn.Draw3D(tile)
sprite.isDrawDepth = false
sprite.model = sprite_model
stair = sn.Draw3D(DEFAULT_TEXTURE)
stair.model = sprite_model
for i = 1, COLLISION_SPACE_DIVISION + 2 do
    COLLISION_SPACE[i] = {}
    for j = 1, COLLISION_SPACE_DIVISION + 2 do
        COLLISION_SPACE[i][j] = {}
    end
end
for i = 1, enemy_max_num do
    table.insert(enemies, enemy())
end
player:setup(map, map_size_x, map_size_y)
for i, v in ipairs(enemies) do
    v:setup(map, map_size_x, map_size_y)
end
for y = 1, map_size_y do
    map_draw3ds[y] = {}
    for x = 1, map_size_x do
        map_draw3ds[y][x] = world()
        map_draw3ds[y][x].position.x = x * TILE_SIZE
        map_draw3ds[y][x].position.y = y * TILE_SIZE
        map_draw3ds[y][x].scale = sn.Vec3(TILE_SIZE / 2.0, TILE_SIZE / 2.0, 1)
        map_draw3ds[y][x].aabb = sn.AABB()
        map_draw3ds[y][x].aabb.max = map_draw3ds[y][x].position + map_draw3ds[y][x].scale
        map_draw3ds[y][x].aabb.min = map_draw3ds[y][x].position - map_draw3ds[y][x].scale
        if map:At(x, y) ~= MAP_CHIP.STAIR then
            sprite:Add(map_draw3ds[y][x].position, map_draw3ds[y][x].rotation, map_draw3ds[y][x].scale)
        end
        if map:At(x, y) == MAP_CHIP.WALL then
            map_draw3ds[y][x].position.z = 0.5
            map_draw3ds[y][x].aabb = sn.AABB()
            map_draw3ds[y][x].aabb.max = map_draw3ds[y][x].position + map_draw3ds[y][x].scale
            map_draw3ds[y][x].aabb.min = map_draw3ds[y][x].position - map_draw3ds[y][x].scale
            map_z:Set(x, y, 0)
            map_draw3ds[y][x].position.z = map_z:At(x, y) / 10.0
            map_draw3ds[y][x].scale.z = 3
        end
        if map:At(x, y) == MAP_CHIP.STAIR then
            stair.position.x = x * TILE_SIZE
            stair.position.y = y * TILE_SIZE + 0.5
            stair.position.z = 0
        end
        if map:At(x, y) == MAP_CHIP.KEY then
            stair.position.x = x * TILE_SIZE
            stair.position.y = y * TILE_SIZE + 0.5
            stair.position.z = 0
        end
        if map:At(x, y) == MAP_CHIP.PLAYER then
            player.drawer.position.x = x * TILE_SIZE
            player.drawer.position.y = y * TILE_SIZE
        end
    end
end
score_font:RenderText(score_texture, "SCORE: " .. SCORE, sn.Color(1, 1, 1, 1))
score_drawer.scale = score_texture:Size()
camera_controller:setup(player)
camera_controller:update()
scene_switcher:setup()
scene_switcher:start("")

equipment_menu:setup()

---@param map_draw3ds world[][]
local FrustumCullingMapDraw = function(map_draw3ds)
    for y = 1, map_size_y do
        for x = 1, map_size_x do
            if sn.Graphics.GetCamera():IsAABBInFrustum(map_draw3ds[y][x].aabb) then
                if map:At(x, y) == MAP_CHIP.WALL then
                    box:Add(map_draw3ds[y][x].position, map_draw3ds[y][x].rotation, sn.Vec3(2))
                end
                local p = map_draw3ds[y][x].position:Copy()
                p.z = 0.0
                sprite:Add(p, map_draw3ds[y][x].rotation, map_draw3ds[y][x].scale)
            end
        end
    end
end
function Draw()
    player:draw3()
    for i, v in ipairs(enemies) do
        v:draw()
    end
    box:Clear()
    sprite:Clear()
    FrustumCullingMapDraw(map_draw3ds)
    sn.Graphics.Draw3D(box)
    sn.Graphics.Draw3D(sprite)
    sn.Graphics.Draw3D(stair)

    player:draw2()
    sn.Graphics.Draw2D(score_drawer)
    equipment_menu:draw()
    menu_object:draw()
    scene_switcher:draw()
    GUI_MANAGER:draw()
end

local function collision_bullets(_bullets)
end

function Update()
    GUI_MANAGER:update()
    score_drawer.position = sn.Vec2(-300, 300)
    if scene_switcher.flag then
        scene_switcher:update()
        return
    end
    menu_object:update()
    if not menu_object.hide then
        return
    end
    if equipment_menu:update() then
        return
    end

    sn.Mouse.SetRelative(true)
    score_font:RenderText(score_texture, "SCORE: " .. SCORE, sn.Color(1, 1, 1, 1))
    score_drawer.scale = score_texture:Size()
    collision_bullets(player.bullets)
    player:update(map, map_draw3ds, map_size_x, map_size_y)
    stair.position.z = 0.0
    for i, v in ipairs(enemies) do
        v:update(player)
        v:player_collision(player)
    end
    stair.position.z = sn.Periodic.Sin0_1(1.0, sn.Time.Seconds())
    if math.floor(player.drawer.position.x + 0.5) == math.floor(stair.position.x) and
        math.floor(player.drawer.position.y + 0.5) == math.floor(stair.position.y) then
        scene_switcher:start("scene02_clear")
    end
    if player.hp <= 0 then
        scene_switcher:start("scene03_gameover")
    end
    camera_controller:update()
end

---@param _bullets bullet[]
collision_bullets = function(_bullets)
    for i, v in ipairs(_bullets) do
        for j, w in ipairs(enemies) do
            if sn.Collision.AABBvsAABB(v.aabb, w.aabb) then
                local efk = effect()
                efk:setup()
                efk.texture:FillColor(sn.Color(1, 0.2, 0.2, 1))
                for k = 1, efk.max_particles do
                    efk.worlds[k].position = w.drawer.position:Copy()
                end
                efk:play()
                table.insert(player.efks, efk)

                table.remove(player.bullets, i)
                -- hp
                if w:add_damage(10) then
                    SCORE = SCORE + 10
                    table.remove(enemies, j)
                end
                if #enemies <= 0 then
                    stair.position.z = 0
                end
            end
        end
        if map:At(math.floor(v.drawer.position.x / TILE_SIZE + 0.5), math.floor(v.drawer.position.y / TILE_SIZE + 0.5)) <
            MAP_CHIP_WALKABLE then
            table.remove(player.bullets, i)
        end
    end
end
