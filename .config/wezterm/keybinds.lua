local wezterm = require 'wezterm'
local act = wezterm.action

return {
  keys = {
    -- タブ操作
    { key = 't', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', mods = 'LEADER', action = act.CloseCurrentTab{ confirm = true } },
    
    -- タブ移動
    { key = '[', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
    { key = ']', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    
    -- ペイン分割
    { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
    { key = '-', mods = 'LEADER', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },
    
    -- ペイン移動
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
    
    -- ペインサイズ調整モード
    { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable{ name = 'resize_pane', one_shot = false } },
    
    -- コピーモード
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
    -- ペイン番号を表示して選択
    { key = 'q', mods = 'LEADER', action = act.PaneSelect },
    -- または、ペイン番号を表示してスワップ（入れ替え）
    { key = 'Q', mods = 'LEADER|SHIFT', action = act.PaneSelect{ mode = 'SwapWithActive' } },
 },
  
  key_tables = {
    resize_pane = {
      { key = 'h', action = act.AdjustPaneSize{ 'Left', 1 } },
      { key = 'j', action = act.AdjustPaneSize{ 'Down', 1 } },
      { key = 'k', action = act.AdjustPaneSize{ 'Up', 1 } },
      { key = 'l', action = act.AdjustPaneSize{ 'Right', 1 } },
      { key = 'Escape', action = 'PopKeyTable' },
    },
  },
}
