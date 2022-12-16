function create_win, win_index, title = title

  get_window_pos, win_index, x, y

  window_settings = obj_new('WindowSettings')
  xsize = window_settings.xsize()
  ysize = window_settings.ysize()

  device,set_font='Helvetica Bold',/tt_font

  window, win_index, xpos = x, ypos = y, xsize = xsize, ysize = ysize, title = title

  return, !null
end
