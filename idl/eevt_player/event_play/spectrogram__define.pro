function Spectrogram::init, z, x, y, $
  xrange = xrange, yrange = yrange, $
  xtickformat = xtickformat, $
  xtickunits = xtickunits, $
  title = title, $
  ncolors = ncolors, $
  nodata = nodata, $
  suppress_color_bar = suppress_color_bar, $
  zlog = zlog, $
  position = position, $
  window = window

  if not keyword_set(ncolors) then ncolors = !d.table_size
  if not keyword_set(nodata) then nodata = !false
  if not keyword_set(suppress_color_bar) then suppress_color_bar = !false
  if keyword_set(zlog) then zlog = 1 else zlog = 0

  ;  zlog = 0
  xx = x
  yy = y
  zz = z

  ct = colortable(13, ncolors = ncolors, /transpose)

  if not nodata then begin
    xdata_size = size(xx)
    xrange = [ xx[0], xx[xdata_size[1] - 1] ]

    ydata_size = size(yy)
    yrange = [ yy[0], yy[ydata_size[1] - 1] ]

    get_plot_range, zz, lin_zrange, log_zrange

    if zlog then zrange = log_zrange else zrange = lin_zrange

    levels = self.get_levels(zrange, ncolors, zlog)
  endif

  c = contour(zz, xx, yy, /fill, /current, $
    xrange = xrange, yrange = yrange, $
    zrange = zrange, zstyle = exact, $
    c_color = ct, c_value = levels, $
    xtickformat = xtickformat, xtickunits = xtickunits, $
    title = title, xmajor = 3, $
    position = position, $
    window = window $
    )
  ;  endelse

  self.contour = ptr_new(c)

  self.colorbar = ptr_new()
  if not suppress_color_bar then begin
    format = '%10.3g'
    tickname = []
    major_max = min([ 4, levels.length ])
    current_index = -1
    for i = 0, major_max - 1 do begin
      index = fix(i * (levels.length - 1) / (major_max - 1))
      if index ne current_index then begin
        tickname = [ tickname, string(levels[index], format = format) ]
        current_index = index
      endif
    endfor

    if tickname.length gt 0 then begin
      no_taper = 0
      cb = colorbar(target = c, title = 'counts per second', major = tickname.length, tickname = tickname, taper = no_taper)
      self.colorbar = ptr_new(cb)
    endif
  endif

  self.lin_zrange = ptr_new(lin_zrange)
  self.log_zrange = ptr_new(log_zrange)
  self.suppress_color_bar = suppress_color_bar
  self.ncolors = ncolors

  return, 1
end

function Spectrogram::position
  if ptr_valid(self.contour) then begin
    contour = *self.contour
    return, contour.position
  endif

  return, !null
end

pro Spectrogram::zlog, zlog
  if ptr_valid(self.contour) then begin
    c = *self.contour
    lin_zrange = *self.lin_zrange
    log_zrange = *self.log_zrange
    ncolors = self.ncolors

    if zlog then zrange = log_zrange else zrange = lin_zrange

    levels = self.get_levels(zrange, ncolors, zlog)
    c.c_value = levels

    if ptr_valid(self.colorbar) then begin
      cb = *self.colorbar
      cb.delete
      self.colorbar = ptr_new()
    endif

    if not self.suppress_color_bar then begin
      format = '%10.3g'
      tickname = []
      major_max = min([ 4, levels.length ])
      current_index = -1
      for i = 0, major_max - 1 do begin
        index = fix(i * (levels.length - 1) / (major_max - 1))
        if index ne current_index then begin
          tickname = [ tickname, string(levels[index], format = format) ]
          current_index = index
        endif
      endfor

      no_taper = 0
      if zlog then title = 'counts per second (log scale)' else title = 'counts per second (linear scale)'
      cb = colorbar(target = c, title = title, major = tickname.length, tickname = tickname, taper = no_taper)
      self.colorbar = ptr_new(cb)
    endif
  endif
end

pro Spectrogram::setData, z, x, y, zlog = zlog
  if ptr_valid(self.contour) then begin
    c = *self.contour
    if not keyword_set(zlog) then zlog = c.zlog

    xx = x
    yy = y
    zz = z

    get_plot_range, zz, lin_zrange, log_zrange

    if zlog then zrange = log_zrange else zrange = lin_zrange

    xdata_size = size(xx)
    xrange = [ xx[0], xx[xdata_size[1] - 1] ]

    ydata_size = size(yy)
    yrange = [ yy[0], yy[ydata_size[1] - 1] ]

    c.setData, zz, xx, yy
    c.xrange = xrange
    c.yrange = yrange
    c.zrange = zrange

    self.log_zrange = ptr_new(log_zrange)
    self.lin_zrange = ptr_new(lin_zrange)

    self.zlog, zlog
  endif
end

pro Spectrogram::hide, hide
  if hide then begin
    ; Hide colorbar, then contour plot, then axes.
    if ptr_valid(self.colorbar) then begin
      cb = *self.colorbar
      cb.hide = 1
    endif

    if ptr_valid(self.contour) then begin
      c = *self.contour

      axes = c.axes

      c.hide = 1

      for i = axes.length - 1, 0, -1 do begin
        axes[i].hide = 1
      endfor

    endif
  endif else begin
    ; Show axes, contour plot, then colorbar.
    if ptr_valid(self.contour) then begin
      c = *self.contour

      axes = c.axes

      for i = 0, axes.length - 1 do begin
        axes[i].hide = 0
      endfor

      c.hide = 0

    endif

    if ptr_valid(self.colorbar) then begin
      cb = *self.colorbar
      cb.hide = 0
    endif
  endelse
end

pro Spectrogram::delete
  ; Delete colorbar, then contour plot, then axes.
  if ptr_valid(self.colorbar) then begin
    cb = *self.colorbar
    self.colorbar = ptr_new()

    cb.delete
  endif

  if ptr_valid(self.contour) then begin
    c = *self.contour
    self.contour = ptr_new()

    axes = c.axes

    c.delete

    for i = axes.length - 1, 0, -1 do begin
      axes[i].delete
    endfor
  endif
end

function Spectrogram::get_levels, range, nlevels, log
  if log then begin
    levels = range[0] * exp((alog(range[1] / range[0]) / (nlevels - 1)) * findgen(nlevels))
  endif else begin
    levels = range[0] + ((range[1] - range[0]) / (nlevels - 1)) * findgen(nlevels)
  endelse

  return, levels
end

pro Spectrogram__define
  !null = { $
    Spectrogram, $
    contour:ptr_new(), $
    colorbar:ptr_new(), $
    lin_zrange:ptr_new(), $
    log_zrange:ptr_new(), $
    suppress_color_bar:!false, $
    ncolors:0 $
  }
end