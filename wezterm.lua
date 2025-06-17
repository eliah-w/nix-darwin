local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "tokyonight_night"

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.5
config.harfbuzz_features = { "calt=1", "zero=1", "ss19=1" }

config.use_fancy_tab_bar = false
config.tab_max_width = 32

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
	options = {
		icons_enabled = true,
		theme = "tokyonight_night",
		color_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = "",
			right = "",
		},
	},
	sections = {
		tabline_a = {
			" g̩ͦ̀̎ͥ ̒͗̇̓H̀͊ͬͩ̚ ̯͔̪̟̯ͦͫọ̱͈͚͋ͮ̈́̊ͨ ̞͚͓̞̱Ș͙̟͈͎̇̑͌̅ ̹̬̘͛ͧT̙̟̦̿ͣͩͭ̂ ",
		},
		tabline_b = {},
		tabline_c = {},
		tab_active = {
			"index",
			{
				"process",
				process_to_icon = {
					[".spotify_player-wrapped"] = wezterm.nerdfonts.md_spotify,
				},
				padding = { left = 0, right = 1 },
			},
			{ "parent", padding = { left = 1, right = 0 } },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tab_inactive = {
			"index",
			{
				"process",
				process_to_icon = {
					[".spotify_player-wrapped"] = wezterm.nerdfonts.md_spotify,
				},
				padding = { left = 0, right = 1 },
			},
			{ "parent", padding = { left = 1, right = 0 } },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},

		tabline_x = {},
		tabline_y = {},
		tabline_z = { "window" },
	},
	extensions = {},
})

-- config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 38
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.window_frame = {
	border_left_color = "black",
	border_right_color = "black",
	border_bottom_color = "black",
	border_top_color = "black",
}

config.animation_fps = 60
config.max_fps = 120

-- config.cursor_blink_ease_in = "EaseIn"
-- config.cursor_blink_ease_out = "EaseIn"
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 600

config.enable_scroll_bar = false
config.scrollback_lines = 10000

config.ui_key_cap_rendering = "AppleSymbols"

config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

config.window_decorations = "RESIZE"

config.keys = {
	{
		key = "l",
		mods = "CMD",
		action = wezterm.action.SplitHorizontal,
	},
	{
		key = "ö",
		mods = "CMD",
		action = wezterm.action.SplitVertical,
	},
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
}

wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window({})
	window:gui_window():maximize()
end)

return config
