function create_win, win_index, title = title, handler = handler

  get_window_pos, win_index, x, y

  window_settings = obj_new('WindowSettings')
  xsize = window_settings.xsize()
  ysize = window_settings.ysize()

  w = window(location = [ x, y ], dimensions = [ xsize, ysize ], window_title = title)

  if keyword_set(handler) then w.EVENT_HANDLER = handler

  w.SetCurrent

  return, w
end
