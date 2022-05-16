function create_win, controller, win_index, title = title, handler = handler

  if not keyword_set(handler) then return, !null

  get_window_pos, win_index, x, y

  window_settings = obj_new('WindowSettings')
  xsize = window_settings.xsize()
  ysize = window_settings.ysize()

  w = window(location = [ x, y ], dimensions = [ xsize, ysize ], window_title = title)

  w.EVENT_HANDLER = handler
  w.SetCurrent

  return, w
end
