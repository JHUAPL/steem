pro get_window_pos, win_index, x, y

  window_settings = obj_new('WindowSettings')
  xsize = window_settings.xsize()
  ysize = window_settings.ysize()
  display_id = window_settings.get_display_id()

  oInfo = obj_new('IDLsysMonitorInfo')

  rects = oInfo->GetRectangles()

  ; Get monitor characteristics.
  x_min = rects[0, display_id]
  mon_width = rects[2, display_id]
  x_max = x_min + mon_width

  y_min = rects[1, display_id]
  mon_height = rects[3, display_id]
  y_max = y_min + mon_height

  ; Slim down requested plot size to fit the monitor if necessary.
  if xsize gt mon_width then xsize = mon_width
  if ysize gt mon_height then ysize = mon_height

  ; Use menu bar thickness as a heuristic limit on sizes in order
  ; to tile plots nicely.
  menu_bar_thickness = 32

  ; For purposes of wrapping window placements at the edges of monitor,
  ; constrain coordinates to a range that guarantees about 1/4 of a window
  ; will always be visible when first displayed.
  wrap_width = mon_width - xsize / 2
  wrap_height = mon_height - ysize / 2

  ; Arbitrarily figure on stepping through about 17 plots (a prime)
  ; before wrapping on the monitor.
  delta_x = wrap_width / 17
  delta_y = wrap_height / 17

  ; Ensure the X-Y steps for each plot are at least the thickness of a
  ; window's menu bar.
  if delta_x lt 32 then delta_x = menu_bar_thickness
  if delta_y lt 32 then delta_y = menu_bar_thickness

  ; Determine offsets for placing this plot.
  x_offset = 1 + win_index * delta_x mod wrap_width
  y_offset = 1 + win_index * delta_y mod wrap_height

  ; X and Y are measured from lower-left, but plots start at
  ; upper-left and march down the diagonal to lower-right.
  x = x_min + x_offset
  y = y_max - ysize - y_offset

  obj_destroy, oInfo

end
