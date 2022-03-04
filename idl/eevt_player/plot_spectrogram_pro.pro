function plot_spectrogram_pro, z, x, y, $
  xrange = xrange, xstyle = xstyle, $
  yrange = yrange, ystyle = ystyle, $
  xtitle = xtitle, ytitle = ytitle, $
  xtickformat = xtickformat, $
  xtickunits = xtickunits, $
  ytickformat = ytickformat, $
  ytickunits = ytickunits, $
  ncolors = ncolors, $
  log = log, $
  position = position

  if not keyword_set(ncolors) then ncolors = !d.table_size

  common draw_colors, fg_color, accent_color

  xx = x
  yy = y
  zz = z

  levels = get_levels(zz, ncolors, log = log)

  contour, zz, xx, yy, /noerase, /fill, $
    xrange = xrange, xstyle = xstyle, $
    yrange = yrange, ystyle = ystyle, $
    xtitle = xtitle, ytitle = ytitle, $
    position = position, xtickformat = xtickformat, xtickunits = xtickunits, $
    levels = levels, color = fg_color

  return, !null
end