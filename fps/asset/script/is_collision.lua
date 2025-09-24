---@param position Vec3
---@param aabb AABB
---@param map Grid
---@param map_draw3ds Draw3D[]
---@param map_size_x number
---@param map_size_y number
local function is_collision(position, aabb, map, map_draw3ds, map_size_x, map_size_y)
    local around = sn.Vec2(0, 0)
    for i = 1, 9 do
        around.x = math.floor(position.x / TILE_SIZE + 0.5) - 1 + i % 3
        around.y = math.floor(position.y / TILE_SIZE + 0.5) - 1 + math.floor(i / 3)
        if around.x > 0 and around.y > 0 and around.x <= map_size_x and around.y <= map_size_y then
            if map:at(around.x, around.y) < MAP_CHIP_WALKABLE then
                if sn.Collision.aabb_vs_aabb(aabb, map_draw3ds[around.y][around.x].aabb) then return true end
            end
        end
    end
    return false
end

return is_collision
