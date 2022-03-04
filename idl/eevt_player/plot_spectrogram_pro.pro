function plot_spectrogram_pro, z, x, y, $
  xrange = xrange, yrange = yrange, $
  position = position, $
  xtickformat = xtickformat, $
  xtickunits = xtickunits, $
  ncolors = ncolors

  if not keyword_set(ncolors) then ncolors = !d.table_size

  loadct, 13, /silent

  xx = x
  yy = y
  zz = z

  zsize = size(zz)
  for i = 0, zsize[1] - 1 do begin
    for j = 0, zsize[2] - 1 do begin
      if zz[i, j] > 0.0 then zz[i, j] = alog10(zz[i, j]) $
      else zz[i, j] = !values.d_nan
    endfor
  endfor

  zmin = min(zz)
  zmax = max(zz)

  c_colors = indgen(ncolors)
  factor = (zmax - zmin) / ncolors
  levels = c_colors * factor + zmin

  contour, zz, xx, yy, /noerase, /fill, $
    xrange = xrange, yrange = yrange, xstyle = 1, ystyle = 1, $
    position = position, xtickformat = xtickformat, xtickunits = xtickunits, $
    c_colors = c_colors, levels = levels

  return, !null
end