local wezterm = require 'wezterm'
local act = wezterm.action

return {
  keys = {
    -- タブ操作
    { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane{ confirm = true } },

    -- タブ移動
    { key = '{', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = '}', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },

    -- タブ番号移動
    { key = '1', mods = 'CTRL', action = act.ActivateTab(0) },
    { key = '2', mods = 'CTRL', action = act.ActivateTab(1) },
    { key = '3', mods = 'CTRL', action = act.ActivateTab(2) },
    { key = '4', mods = 'CTRL', action = act.ActivateTab(3) },
    { key = '5', mods = 'CTRL', action = act.ActivateTab(4) },
    { key = '6', mods = 'CTRL', action = act.ActivateTab(5) },
    { key = '7', mods = 'CTRL', action = act.ActivateTab(6) },
    { key = '8', mods = 'CTRL', action = act.ActivateTab(7) },
    { key = '9', mods = 'CTRL', action = act.ActivateTab(8) },

    -- ペイン分割
    { key = 'd', mods = 'CTRL', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
    { key = 'D', mods = 'CTRL|SHIFT', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },

    -- ペイン移動
    { key = 'LeftArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Left' },
    { key = 'RightArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Up' },
    { key = 'DownArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Down' },

    -- ペインサイズ調整
    { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize{ 'Left', 20 } },
    { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize{ 'Right', 20 } },
    { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize{ 'Up', 20 } },
    { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize{ 'Down', 20 } },

    -- コピー・ペースト
    { key = 'c', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
    { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
    { key = 'C', mods = 'CTRL|SHIFT', action = act.SendString '\x03' },

    -- フォントサイズ
    { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },

    -- 画面クリア
    { key = 'k', mods = 'CTRL', action = act.ClearScrollback 'ScrollbackAndViewport' },
  },

  key_tables = {},
}
