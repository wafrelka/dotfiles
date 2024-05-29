local wezterm = require "wezterm"
local act = wezterm.action


-- color scheme --

function update_alpha(c, alpha)
	local h, s, l, a = wezterm.color.parse(c):hsla()
	return wezterm.color.from_hsla(h, s, l, alpha)
end

local COLOR_SCHEME = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
local OPACITY = 0.9
local TRANSPARENT_BACKGROUND = update_alpha(COLOR_SCHEME.background, OPACITY)
COLOR_SCHEME.tab_bar = { background = TRANSPARENT_BACKGROUND }


-- tab styling --

function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end
	return tab_info.active_pane.title
end

function format_tab_title(tab, tabs, panes, config, hover, max_width)
	local fg = COLOR_SCHEME.foreground
	local bg = COLOR_SCHEME.ansi[1]
	local intensity = "Normal"

	if tab.is_active or hover then
		fg = COLOR_SCHEME.background
		bg = COLOR_SCHEME.ansi[2]
		intensity = "Bold"
	end

	local edge_bg = TRANSPARENT_BACKGROUND
	local edge_fg = bg

	local left_edge = wezterm.nerdfonts.ple_lower_right_triangle
	local extra_chars = 4
	if tab.tab_index == 0 then
		left_edge = ""
		extra_chars = 3
	end

	local title = wezterm.truncate_right(tab_title(tab), max_width - extra_chars)

	return {
		{ Foreground = { Color = edge_fg } },
		{ Background = { Color = edge_bg } },
		{ Text = left_edge },
		{ Foreground = { Color = fg } },
		{ Background = { Color = bg } },
		{ Attribute = { Intensity = intensity } },
		{ Text = " " .. title .. " " },
		{ Foreground = { Color = edge_fg } },
		{ Background = { Color = edge_bg } },
		{ Attribute = { Intensity = "Normal" } },
		{ Text = wezterm.nerdfonts.ple_upper_left_triangle },
	}
end

wezterm.on('format-tab-title', format_tab_title)


-- config --

local mouse_bindings = {
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'NONE',
		action = act.CompleteSelection "ClipboardAndPrimarySelection",
	},
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'SUPER',
		action = act.CompleteSelectionOrOpenLinkAtMouseCursor "ClipboardAndPrimarySelection",
	},
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'CTRL',
		action = act.CompleteSelectionOrOpenLinkAtMouseCursor "ClipboardAndPrimarySelection",
	},
}

local config = {
	colors = COLOR_SCHEME,
	window_background_opacity = OPACITY,
	use_fancy_tab_bar = false,
	show_new_tab_button_in_tab_bar = false,
	tab_max_width = 20,
	default_cursor_style = "BlinkingBar",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	animation_fps = 2,
	cursor_blink_rate = 500,
	initial_cols = 120,
	initial_rows = 40,
	mouse_bindings = mouse_bindings,
	audible_bell = "Disabled",
}

-- site specific config

local status, update_config = pcall(require, 'local')
if status then
	config = update_config(config)
else	
	wezterm.log_info("could not load local config")
end

return config
