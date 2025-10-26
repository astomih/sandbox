local function scroll()
    local object = {
        drawer = {},
        max_drawer = {},
        positions = {},
        current_pos = 1,
        add = function(self, position)
            self.positions[self.current_pos] = position
            self.current_pos = self.current_pos + 1
        end,
        prev_mpos = {},
        t1 = {},
        t2 = {},
        pos = sn.Vec2.new(0, 0),
        is_drag = false,
        initial = true,
        show = function(self, pos, scale)
            self.drawer = sn.Draw2D.new(self.t2)
            self.drawer.scale = sn.Vec2.new(scale.x, scale.y * 0.1)
            if self.initial then
                self.pos = sn.Vec2.new(pos.x, pos.y)
                self.initial = false
            end
            self.drawer.position = self.pos
            self.max_drawer = sn.Draw2D.new(self.t1)
            self.max_drawer.scale = scale
            self.max_drawer.position = pos
            -- Mouse
            local mpos = sn.Mouse.getPositionOnScene()
            if not self.is_drag and sn.Mouse.isPressed(sn.Mouse.LEFT) then
                local dpos = self.drawer.position
                local dscale = self.drawer.scale
                if mpos.x >= dpos.x - dscale.x / 2
                    and
                    mpos.x <= dpos.x + dscale.x / 2
                    and
                    mpos.y >= dpos.y - dscale.y / 2
                    and
                    mpos.y <= dpos.y + dscale.y / 2
                then
                    self.is_drag = true
                end
            end
            if (sn.Mouse.isReleased(sn.Mouse.LEFT)) then self.is_drag = false end
            if self.is_drag then
                self.pos.y = mpos.y
                if self.pos.y < self.max_drawer.position.y - self.max_drawer.scale.y / 2 + self.drawer.scale.y / 2 then
                    self.pos.y = self.max_drawer.position.y - self.max_drawer.scale.y / 2 + self.drawer.scale.y / 2
                end
                if self.pos.y > self.max_drawer.position.y + self.max_drawer.scale.y / 2 - self.drawer.scale.y / 2 then
                    self.pos.y = self.max_drawer.position.y + self.max_drawer.scale.y / 2 - self.drawer.scale.y / 2
                end
                for i, v in ipairs(self.positions) do
                    v.y = mpos.y + v.y
                end
            end
            self.prev_mpos = sn.Vec2.new(mpos.x, mpos.y)
            self.positions = {}
            self.current_pos = 1
            GUI_MANAGER:add(self.drawer)
            GUI_MANAGER:add(self.max_drawer)
        end,
    }
    object.drawer = sn.Draw2D.new(sn.Texture.new())
    object.t1 = sn.Texture.new()
    object.t1:fill(sn.Color.new(0, 0, 0, 0.5))
    object.t2 = sn.Texture.new()
    object.t2:fill(sn.Color.new(1, 1, 1, 0.5))

    return object
end

return scroll
