function create_win_pro, win_index, title = title, $
  window_settings = window_settings

  if not keyword_set(window_settings) then window_settings = obj_new('WindowSettings')

  get_window_pos, win_index, x, y, window_settings = window_settings

  xsize = window_settings.xsize()
  ysize = window_settings.ysize()

  device,set_font='Helvetica Bold',/tt_font

  window, win_index, xpos = x, ypos = y, xsize = xsize, ysize = ysize, title = title

  return, !null
end