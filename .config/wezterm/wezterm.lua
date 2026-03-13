-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- 自動リロード
config.automatically_reload_config = true

-- フォント
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 12.0

-- IMEで日本語入力を有効化
config.use_ime = true

-- 背景の透過
config.window_background_opacity = 0.85

-- ぼかし効果 (macOS用)
if wezterm.target_triple:find("darwin") then
  config.macos_window_background_blur = 2
end

-- タイトルバーを削除
config.window_decorations = "RESIZE"

-- タブが1つしかない時はタブバーを非表示
config.hide_tab_bar_if_only_one_tab = true

-- タブバーを透明に
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブバーを背景と同じ色に
config.window_background_gradient = {
  colors = { "#000000" },
}

-- タブバーの+ボタンを非表示
config.show_new_tab_button_in_tab_bar = false

-- タブの閉じるボタンを非表示 (nightly版のみ)
config.show_close_tab_button_in_tabs = false

-- タブの設定
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの形とアクティブタブの色設定
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end
  
  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
  
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- leaderキーの設定 (Ctrl+\)
config.leader = { key = "\\", mods = "CTRL", timeout_milliseconds = 2000 }

-- キーバインドの読み込み
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables

return config
