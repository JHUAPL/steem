function plot_spectrogram_pro, z, x, y, $
  xrange = xrange, xstyle = xstyle, $
  yrange = yrange, ystyle = ystyle, $
  nlevels = nlevels, $
  zrange = zrange, $
  zlog = zlog, $
  xtitle = xtitle, ytitle = ytitle, $
  xtickformat = xtickformat, $
  xtickunits = xtickunits, $
  ytickformat = ytickformat, $
  ytickunits = ytickunits, $
  position = position

  if not keyword_set(nlevels) then nlevels = !d.table_size

  common draw_colors, fg_color, accent_color

  xx = x
  yy = y
  zz = z

  offset = shift_range_positive(zz)

  if keyword_set(zrange) then begin
    if offset ne !null then shifted_range = zrange + offset else shifted_range = zrange
  endif

  levels = get_levels(zz, nlevels, range = shifted_range, log = zlog)

  contour, zz, xx, yy, /noerase, /fill, $
    xrange = xrange, xstyle = xstyle, $
    yrange = yrange, ystyle = ystyle, $
    xtitle = xtitle, ytitle = ytitle, $
    position = position, xtickformat = xtickformat, xtickunits = xtickunits, $
    levels = levels, color = fg_color

  return, !null
end