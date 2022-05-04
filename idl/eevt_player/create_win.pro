function create_win, controller, win_index, title = title, handler = handler, $
  window_settings = window_settings

  if not keyword_set(window_settings) then window_settings = obj_new('WindowSettings')

  get_window_pos, win_index, x, y, window_settings = window_settings

  xsize = window_settings.xsize()
  ysize = window_settings.ysize()

  w = window(location = [ x, y ], dimensions = [ xsize, ysize ], window_title = title)

  handler = obj_new('PlotEventHandler', controller)

  w.EVENT_HANDLER = handler
  w.SetCurrent

  return, w
end