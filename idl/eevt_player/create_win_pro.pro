function create_win_pro, mon_index, win_index, xsize = xsize, ysize = ysize, title = title

  get_window_pos, mon_index, win_index, x, y, xsize = xsize, ysize = ysize

  device,set_font='Helvetica Bold',/tt_font
  window, win_index, xpos = x, ypos = y, xsize = xsize, ysize = ysize, title = title

  return, !null
end