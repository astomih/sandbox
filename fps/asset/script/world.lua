---@class world
---@field position Vec3
---@field rotation Vec3
---@field scale Vec3
---@field aabb AABB
---@return world
local function world()
    local object = {
        position = sn.Vec3.new(0),
        rotation = sn.Vec3.new(0),
        scale = sn.Vec3.new(1),
        aabb = sn.AABB.new()
    }
    return object
end

return world
