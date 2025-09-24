local function calc_input_vector()
    local input_vector = sn.Vec3(0, 0, 0)
    if sn.Keyboard.is_down(sn.Keyboard.W) then input_vector.y = input_vector.y + 1.0; end
    if sn.Keyboard.is_down(sn.Keyboard.S) then input_vector.y = input_vector.y - 1.0; end
    if sn.Keyboard.is_down(sn.Keyboard.A) then input_vector.x = input_vector.x - 1.0; end
    if sn.Keyboard.is_down(sn.Keyboard.D) then input_vector.x = input_vector.x + 1.0; end
    return input_vector
end

return calc_input_vector;
