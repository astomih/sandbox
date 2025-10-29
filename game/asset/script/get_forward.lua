---@param drawer Draw3D
local function get_forward(drawer)
    return sn.Vec3.new(-math.sin(math.rad(drawer.rotation.z)),
        math.cos(math.rad(-drawer.rotation.z)), 1)
end

return get_forward
