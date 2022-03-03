function create_win, mon_index, win_index, xsize = xsize, ysize = ysize, title = title

  get_window_pos, mon_index, win_index, x, y, xsize = xsize, ysize = ysize

  w =window(position = [ x, y ], dimensions = [ xsize, ysize ], window_title = title)

  w.EVENT_HANDLER = obj_new('PlotEventHandler')
  w.SetCurrent

  return, w
end