function plot_spectrogram_pro, z, x, y, $
  xrange = xrange, yrange = yrange, $
  position = position, $
  xtickformat = xtickformat, $
  xtickunits = xtickunits, $
  ncolors = ncolors

  if not keyword_set(ncolors) then ncolors = !d.table_size

  xx = x
  yy = y
  zz = z

  zsize = size(zz)

  zmax = max(zz)
  zmin = zmax
  for i = 0, zsize[1] - 1 do begin
    posj = where(zz[i, *] gt 0.0 and $
      zz[i, *] ne !values.D_INFINITY and zz[i, *] ne !values.F_INFINITY and $
      zz[i, *] ne !values.D_NAN and zz[i, *] ne !values.F_NAN)
    min = min(zz[i, posj])
    zmin = min(min, zmin)
  endfor

  if zmin gt 0.0 and zmax gt zmin then begin
    exp = alog(zmax / zmin) / (ncolors - 1)

    levels = dindgen(ncolors)
    for i = 0, ncolors - 1 do begin
      levels[i] = zmin * exp(i * exp)
    endfor
  endif

  contour, zz, xx, yy, /noerase, /fill, $
    xrange = xrange, yrange = yrange, xstyle = 1, ystyle = 1, $
    position = position, xtickformat = xtickformat, xtickunits = xtickunits, $
    levels = levels

  return, !null
end