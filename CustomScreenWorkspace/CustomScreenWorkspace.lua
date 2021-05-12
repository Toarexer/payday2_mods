local function CustomScreenWorkspace_clog()
    local file = io.open("/home/tadam/Desktop/pd2.log", "w")
    file:write("")
    file:close()
end

local function CustomScreenWorkspace_log(val)
    local file = io.open("/home/tadam/Desktop/pd2.log", "a")
    file:write(tostring(val) .. "\n")
    file:close()
end

if not CustomScreenWorkspace then
    CustomScreenWorkspace = {}

    function CustomScreenWorkspace:init()
        -- Get current resulotion
        self.resolution = RenderSettings.resolution

        self.workspace = Overlay:gui():create_scaled_screen_workspace(self.resolution.x, self.resolution.y, 0, 0, self.resolution.x, self.resolution.y)
        self.workspace_panel = self.workspace:panel({name = "workspace_panel"})

        -- Hook to GameSetupUpdate to be called every update
        Hooks:Add(
            "GameSetupUpdate",
            "CustomScreenWorkspace_GameSetupUpdate",
            function()
                CustomScreenWorkspace:update()
            end
        )

        -- Add custom contours
        ContourExt._types.CustomScreenWorkspace_red_contour = {
            priority = 5,
            fadeout = 0.001,
            color = Color.red,
            material_swap_required = true
        }

        ContourExt._types.CustomScreenWorkspace_yellow_contour = {
            priority = 5,
            fadeout = 0.001,
            color = Color.yellow,
            material_swap_required = true
        }

        ContourExt._types.CustomScreenWorkspace_green_contour = {
            priority = 5,
            fadeout = 0.001,
            color = Color.green,
            material_swap_required = true
        }

        self:setup_elements()
    end

    function CustomScreenWorkspace:setup_elements()
        self.text_element_name = "CustomScreenWorkspace_text_element"
        self.bar_fg_element_name = "CustomScreenWorkspace_bar_fg_element"
        self.bar_bg_element_name = "CustomScreenWorkspace_bar_bg_element"

        self.text_element =
            self.workspace_panel:text(
            {
                name = self.text_element_name,
                text = "placeholder_text",
                align = "center",
                valign = "center",
                font = tweak_data.hud_present.text_font,
                font_size = 38,
                layer = 3,
                x = 0,
                y = 255,
                visible = false,
                color = Color.white
            }
        )

        self.bar_fg_element =
            self.workspace_panel:rect(
            {
                name = self.bar_fg_element_name,
                layer = 2,
                x = self.resolution.x / 2 - 150,
                y = 256,
                h = 36,
                w = 300,
                visible = false
            }
        )

        self.bar_bg_element =
            self.workspace_panel:rect(
            {
                name = self.bar_bg_element_name,
                layer = 1,
                x = self.resolution.x / 2 - 153,
                y = 253,
                h = 42,
                w = 306,
                visible = false,
                color = Color.black:with_alpha(0.3)
            }
        )

        self.text = self.workspace_panel:child(CustomScreenWorkspace.text_element_name)
        self.bar_fg = self.workspace_panel:child(CustomScreenWorkspace.bar_fg_element_name)
        self.bar_bg = self.workspace_panel:child(CustomScreenWorkspace.bar_bg_element_name)
    end

    function CustomScreenWorkspace:update()
        -- Check if player camera exists
        if not managers.viewport:get_current_camera() then
            return
        end

        -- Set start and end positions
        local start_pos = managers.viewport:get_current_camera_position()
        local end_pos = Vector3()
        mvector3.set(end_pos, managers.viewport:get_current_camera_rotation():y())
        mvector3.multiply(end_pos, 100000)
        mvector3.add(end_pos, start_pos)

        local slot_mask = "bullet_impact_targets" -- "trip_mine_targets"

        -- Cast rays from camera to aim position
        -- I don't really know how, but this works through shield as well
        local rays = World:raycast_all("ray", start_pos, end_pos, "slot_mask", managers.slot:get_mask(slot_mask))

        if not rays then
            return
        end
        ray = rays[1]

        if ray and ray.unit and ray.unit:in_slot(8) and alive(ray.unit:parent()) then
            ray = rays[2] or ray
        end
        -- Copied code from 'lib/units/weapons/sentrygunweapon.lua'

        if (ray and ray.unit and ray.unit:character_damage()) then
            local max_health = ray.unit:character_damage()._HEALTH_INIT
            local health = math.floor(ray.unit:character_damage()._health * 1000) / 100

            if not max_health then
                return
            end
            max_health = max_health * 10
            local percent = health / max_health

            local function add_contour(unit, contour_name)
                local sentry_mask = managers.slot:get_mask("sentry_gun")
                -- Set contour if the unit has contour class and isn't a sentry
                if unit:contour() and not unit:in_slot(sentry_mask) then
                    unit:contour():add(contour_name, false)
                end
            end

            if percent < 0.15 then
                self.bar_fg:set_color(Color.red:with_alpha(0.3))
                add_contour(ray.unit, "CustomScreenWorkspace_red_contour")
            elseif percent < 0.35 then
                self.bar_fg:set_color(Color.yellow:with_alpha(0.3))
                add_contour(ray.unit, "CustomScreenWorkspace_yellow_contour")
            else
                self.bar_fg:set_color(Color.green:with_alpha(0.3))
                add_contour(ray.unit, "CustomScreenWorkspace_green_contour")
            end

            self.text:set_text(tostring(health) .. " / " .. tostring(max_health))
            self.bar_fg:set_x(self.resolution.x / 2 - 150)
            self.bar_fg:set_w(percent * 300)

            self.text:set_visible(true)
            self.bar_fg:set_visible(true)
            self.bar_bg:set_visible(true)
        else
            self.text:set_visible(false)
            self.bar_fg:set_visible(false)
            self.bar_bg:set_visible(false)
        end
    end

    CustomScreenWorkspace:init()
end
