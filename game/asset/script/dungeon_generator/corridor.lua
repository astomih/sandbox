--------------------------------------------------------------------
-- corridor.lua
--------------------------------------------------------------------
local Corridor = {
    path = {}
}
Corridor.__index = Corridor

function Corridor:new()
    return setmetatable({}, Corridor)
end

function Corridor:get_path()
    return self.path
end

---@param grid sn.Grid
function Corridor:connect(grid, rooms, floor_id)
    for i = 1, #rooms - 1 do
        local a = rooms[i]
        local b = rooms[i + 1]
        local posA = a:get_position()
        local sizeA = a:get_size()
        local posB = b:get_position()
        local sizeB = b:get_size()

        local left = sn.Vec2i.new(posA.x + sizeA.x - 1, math.random(posA.y, posA.y + sizeA.y - 1))
        local right = sn.Vec2i.new(posB.x, math.random(posB.y, posB.y + sizeB.y - 1))

        local current = sn.Vec2i.new(left.x, left.y)
        while current.x < right.x do
            grid:set(current.x, current.y, floor_id)
            table.insert(self.path, sn.Vec2i.new(current.x, current.y))
            current.x = current.x + 1
        end

        while current.y ~= right.y do
            grid:set(current.x, current.y, floor_id)
            if current.y < right.y then
                table.insert(self.path, sn.Vec2i.new(current.x, current.y))
                current.y = current.y + 1
            else
                current.y = current.y - 1
            end
        end
    end
end

return Corridor
