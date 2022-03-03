function plot_spectrogram, z, x, y, $
  xrange = xrange, yrange = yrange, $
  xtickformat = xtickformat, $
  xtickunits = xtickunits, $
  title = title, $
  ncolors = ncolors, $
  position = position

  if not keyword_set(ncolors) then ncolors = !d.table_size

  xx = x
  yy = y
  zz = z

  zsize = size(zz)
  ; for i = 0, zsize[1] - 1 do begin
  ;    for j = 0, zsize[2] - 1 do begin
  ;      if zz[i, j] > 0.0 then zz[i, j] = alog10(zz[i, j]) $
  ;      else zz[i, j] = !values.d_nan
  ;    endfor
  ;  endfor

  zmin = min(zz)
  zmax = max(zz)

  xdata_size = size(xx)
  xrange = [ xx[0], xx[xdata_size[1] - 1] ]

  ydata_size = size(yy)
  yrange = [ yy[0], yy[ydata_size[1] - 1] ]

  ct = colortable(13, ncolors = ncolors, /transpose)

  c = contour(zz, xx, yy, /fill, /current
  
  , $
    xrange = xrange, yrange = yrange, $
    position = position, $
    c_color = ct, n_levels = ncolors, $
    xtickformat = xtickformat, xtickunits = xtickunits, $
    title = title, xmajor = 3 $
    )

  cb = colorbar(target = c, title = 'counts per second', major = 5)

  return, c

end