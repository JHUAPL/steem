function create_win, controller, mon_index, win_index, xsize = xsize, ysize = ysize, title = title, $
  handler = handler

  get_window_pos, mon_index, win_index, x, y, xsize = xsize, ysize = ysize

  w = window(position = [ x, y ], dimensions = [ xsize, ysize ], window_title = title)

  handler = obj_new('PlotEventHandler', controller)

  w.EVENT_HANDLER = handler
  w.SetCurrent

  return, w
end