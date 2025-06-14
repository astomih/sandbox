---@class world
---@field position Vec3
---@field rotation Vec3
---@field scale Vec3
---@field aabb AABB
---@return world
local function world()
    local object = {
        position = Vec3(0),
        rotation = Vec3(0),
        scale = Vec3(1),
        aabb = AABB()
    }
    return object
end

return world
