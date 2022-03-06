function color_bar_pro, data, $
  xtitle = xtitle, $
  nlevels = nlevels, $
  zrange = zrange, $
  zlog = zlog, $
  position = position

  if not keyword_set(nlevels) then nlevels = !d.table_size

  array = data

  offset = shift_range_positive(array)

  if keyword_set(zrange) then begin
    if offset ne !null then shifted_range = zrange + offset else shifted_range = zrange
  endif

  levels = get_levels(array, nlevels, range = shifted_range, log = zlog)

  xrange = [ levels[0], levels[levels.LENGTH - 1] ]
  yrange = [ 0, 1 ]

  z = [ [ levels ], [ levels ] ]
  if offset ne !null then x = levels - offset else x = levels
  y = yrange

  exact = 1
  no_axis = 4

  return, plot_spectrogram_pro(z, x, y, $
    xrange = xrange, xstyle = exact, yrange = yrange, ystyle = no_axis, $
    zrange = shifted_range, $
    zlog = zlog, $
    nlevels = nlevels, $
    xtitle = xtitle, $
    position = position)
end