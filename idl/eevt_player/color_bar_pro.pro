function color_bar_pro, array, $
  xtitle = xtitle, $
  ncolors = ncolors, $
  log = log, $
  position = position

  if not keyword_set(ncolors) then ncolors = !d.table_size

  levels = get_levels(array, ncolors, log = log)

  xrange = [ levels[0], levels[levels.LENGTH - 1] ]
  yrange = [ 0, 1 ]

  z = [ [ levels ], [ levels ] ]
  x = levels
  y = yrange

  exact = 1
  no_axis = 4

  return, plot_spectrogram_pro(z, x, y, $
    xrange = xrange, xstyle = exact, yrange = yrange, ystyle = no_axis, $
    xtitle = xtitle, $
    ncolors = ncolors, $
    log = log, $
    position = position)
end