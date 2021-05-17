function UnoDeviceBase:build_hint_text()
	if self._hint_text then
		self._panel:remove(self._hint_text)
	end

	local font = tweak_data.menu.pd2_medium_font --tweak_data.menu.uno_vessel_font
	local font_size = tweak_data.menu.uno_vessel_font_size
	self._hint_text =
		self._panel:text(
		{
			text = "",
			direction = "left_right",
			wrap = true,
			align = "center",
			vertical = "center",
			font = font,
			font_size = font_size,
			color = Color(0, 1, 1, 1)
		}
	)
end

function UnoDeviceBase:show_hint(achievement_id)
	local data = tweak_data.achievement.visual[achievement_id]
	local hint_text = managers.localization:text(data.name_id) .. "\n[" .. tostring(self._next_hint) .. "/20]"
	local awarded = managers.achievment:get_info(achievement_id).awarded
	self:show_text(hint_text, awarded)
end

local function text_fade(o, start_color, end_color, duration)
	for t, p, dt in seconds(duration) do
		o:set_color(start_color * (1 - p) + end_color * p)
	end
end

function UnoDeviceBase:show_text(text, awarded)
	local fade_color
	local text_color

	if awarded then
		fade_color = Color(0, 0, 1, 0)
		text_color = Color(1, 0, 1, 0)
	else
		fade_color = Color(0, 1, 0, 0)
		text_color = Color(1, 1, 0, 0)
	end

	self._hint_text:set_text(text)
	self._hint_text:stop()
	self._hint_text:animate(
		function(o)
			text_fade(o, fade_color, text_color, 0.3)
			wait(10)
			text_fade(o, text_color, fade_color, 0.3)
		end
	)
end
