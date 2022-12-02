function PlotEventsWindow::init, controller, window_settings = window_settings
  handler = self

  if not keyword_set(window_settings) then $
    window_settings = ptr_new(obj_new('WindowSettings'))

  ; Do this or else the color bars are messed up.
  device, decomposed = 0

  loadct, 13 ; Rainbow
  ;  loadct, 32 ; Plasma -- nice contrasts but can't gauge intensity.
  ;  loadct, 74 ; Spectral -- darker = more, not really good and background is red.

  ; Standard procedural plot set-up.
  standard_plot

  ws = *window_settings
  plot_window = ws.create_win(title = 'Event Detail', handler = handler)

  plot_window.refresh, /disable

  ; Dummy arrays used to create plots before any events are available to plot.
  dummy_array1d = make_array(2, /float)
  dummy_array2d = make_array(2, 2, /float)

  ; Time axis formatting.
  date_format = [ '%h:%i' ]
  ; Initialize date labels.
  !null = label_date(date_format = date_format)
  time_format = [ 'label_date' ]
  time_units = [ 'Minutes' ]

  ; Line plotting constants
  diamond = "Diamond"
  square = "Square"
  fg_color = 'blue'
  accent_color1 = 'red'
  accent_color2 = 'green'

  exact = 1
  padded = 2
  padded_exact = 3

  max_spec = ws.max_spec()

  xsize = ws.xsize()
  ysize = ws.ysize()

  xunit = 9.0 / xsize
  yunit = 8.0 / ysize
  margins = [ 8.0 * xunit, 8.0 * xunit, 2.0 * yunit, 8.0 * yunit ]

  max_spec = ws.max_spec()

  ; Color bars are built-in for OO spectrograms. The size of the main plot seems correct,
  ; but the color bar labels tend to run into the next plot. This bit of trickery is
  ; to try to get the color bars to display cleanly without running into anything.
  lines_for_title = 0.1
  lines_for_spec = 1.15
  lines_for_diff_spec = 1.15
  lines_for_lc = 1

  ; Initial vertical row position is just below the window title.
  row_index = lines_for_title
  imax = max_spec + 2.0 * lines_for_title + lines_for_spec + lines_for_diff_spec + lines_for_lc
  jmax = 2

  panel0 = 0
  panel1 = 1

  ; Call with jmax parameter = 1 (not jmax variable defined above) for plots that
  ; fill the window horizontally.
  pos = plot_coord(row_index, panel0, imax, 1, margins = margins)
  title_plot = plot(dummy_array1d, /current, /nodata, title = 'Event N', axis_style = 0, $
    position = pos, $
    window = plot_window)
  row_index += lines_for_title

  pos = plot_coord(row_index, panel0, imax, 1, margins = margins)
  spectrogram = plot_spectrogram(dummy_array2d, dummy_array1d, dummy_array1d, $
    xtickformat = time_format, xtickunits = time_units, $
    nodata = !true, $
    suppress_color_bar = !true, $
    position = pos, $
    window = plot_window)
  row_index += lines_for_spec

  pos = plot_coord(row_index, panel0, imax, 1, margins = margins)
  diff_spect = plot_spectrogram(dummy_array2d, dummy_array1d, dummy_array1d, $
    xtickformat = time_format, xtickunits = time_units, $
    nodata = !true, $
    suppress_color_bar = !true, $
    position = pos, $
    window = plot_window)
  row_index += lines_for_diff_spec

  pos = plot_coord(row_index, panel0, imax, 1, margins = margins)

  ; The altitude will be plotted with axis on the right overtop the light curve.
  altitude = plot(dummy_array1d, dummy_array1d, /current, axis_style = 4, $
    xstyle = exact, ystyle = padded, $
    xtickformat = time_format, xtickunits = time_units, thick = 2, $
    symbol = diamond, sym_size = 1, $
    color = accent_color2, $
    position = pos, $
    window = plot_window)

  !null = axis('Y', location='right', title = 'Altitude', color = accent_color2, $
    target = altitude)

  light_curve = plot(dummy_array1d, dummy_array1d, /current, $
    axis_style = 1, $
    xstyle = exact, ystyle = padded, $
    xtickformat = time_format, xtickunits = time_units, thick = 2, $
    ytitle = 'BP low', ycolor = fg_color, $
    symbol = diamond, sym_size = 1, $
    color = fg_color, $
    position = pos, $
    window = plot_window)

  highlights = plot(dummy_array1d, dummy_array1d, /overplot, $
    symbol = square, sym_size = 1.2, sym_thick = 2, $
    color = accent_color1, linestyle = 'none')

  row_index += lines_for_lc

  spec_array = make_array(max_spec, /obj)
  back_spec_array = make_array(max_spec, /obj)
  diff_spec_array = make_array(max_spec, /obj)
  fit_array = make_array(max_spec, /obj)

  for i = 0, max_spec - 1 do begin
    pos = plot_coord(row_index, panel0, imax, jmax, right = 4.0 * xunit, margins = margins)

    spec_array[i] = plot(dummy_array1d, dummy_array1d, /current, /ylog, $
      ytitle = 'Counts per second', thick = 2, $
      xstyle = exact, ystyle = padded_exact, $
      color = accent_color1, $
      position = pos, $
      window = plot_window)
    back_spec_array[i] = plot(dummy_array1d, dummy_array1d, /overplot, /ylog, $
      thick = 2, color = fg_color)

    pos = plot_coord(row_index, panel1, imax, jmax, left = 4.0 * xunit, margins = margins)

    diff_spec_array[i] = plot(dummy_array1d, dummy_array1d, /current, /ylog, $
      ytitle = 'Counts per second', thick = 2, $
      xstyle = exact, ystyle = exact, $
      color = accent_color1, $
      position = pos, $
      window = plot_window)
    fit_array[i] = plot(dummy_array1d, dummy_array1d, /overplot, /ylog, $
      thick = 2, color = fg_color)

    ++row_index
  endfor

  self.window_settings = window_settings
  self.controller = ptr_new(controller)
  self.plot_window = ptr_new(plot_window)
  self.time_format = ptr_new(time_format)
  self.time_units = ptr_new(time_units)
  self.title_plot = ptr_new(title_plot)
  self.spectrogram = ptr_new(spectrogram)
  self.diff_spect = ptr_new(diff_spect)
  self.altitude = ptr_new(altitude)
  self.light_curve = ptr_new(light_curve)
  self.highlights = ptr_new(highlights)
  self.spec_array = ptr_new(spec_array)
  self.back_spec_array = ptr_new(back_spec_array)
  self.diff_spec_array = ptr_new(diff_spec_array)
  self.fit_array = ptr_new(fit_array)

  self.spec0_index = 0
  self.log = !true

  return, 1
end

pro PlotEventsWindow::set_title, title
  self.title = title
end

pro PlotEventsWindow::set_event, this_eevt, fit_param = fit_param
  self.eevt = ptr_new(this_eevt)
  self.spec0_index = 0

  if keyword_set(fit_param) then self.fit_param = ptr_new(fit_param) $
  else self.fit_param = ptr_new()
end

pro PlotEventsWindow::set_spec0_index, spec0_index
  eevt_len = self.eevt[0].eevt.evt_length

  if spec0_index lt 0 then spec0_index = 0
  if spec0_index ge eevt_len then spec0_index = eevt_len - 1

  self.spec0_index = spec0_index
end

pro PlotEventsWindow::set_log, log
  self.log = log
end

; This was the original "new" way to update plots. NOT USED.
pro PlotEventsWindow::update
  if not ptr_valid(self.eevt) then return

  window_settings = *self.window_settings
  plot_window = *self.plot_window
  time_format = *self.time_format
  time_units = *self.time_units
  title_plot = *self.title_plot
  spectrogram = *self.spectrogram
  diff_spect = *self.diff_spect
  altitude = *self.altitude
  light_curve = *self.light_curve
  highlights = *self.highlights
  spec_array = *self.spec_array
  back_spec_array = *self.back_spec_array
  diff_spec_array = *self.diff_spec_array
  fit_array = *self.fit_array

  title = self.title
  this_eevt = *self.eevt

  if self.log then log = 1 else log = 0
  spec0_index = self.spec0_index

  plot_window.refresh, /disable

  eevt_len = this_eevt[0].eevt.evt_length

  if ptr_valid(self.fit_param) then begin
    fit_param = *self.fit_param
  endif else begin
    fit_param = make_array(eevt_len, 2, /float, value = !values.f_nan)
  endelse

  jday = this_eevt[0:eevt_len - 1].hk.jday

  num_chan = 64
  chan_index = findgen(num_chan)

  ; Time step index where background spectrum is found in each event.
  back_spec_idx = 60

  ; Channel indices that determine the range for spectra to
  ; agree with the background spectrum. This is used to scale the spectra.
  first_back_chan = 50
  last_back_chan = 60

  bp_low_spec = transpose(this_eevt[0:eevt_len - 1].eevt.bp_low_spec)
  this_back_spec = this_eevt[back_spec_idx].eevt.bp_low_spec

  bp_diff_spec = make_array(eevt_len, num_chan, /float)

  for i = 0, eevt_len - 1 do begin
    scale_factor = total(bp_low_spec[i, first_back_chan:last_back_chan])/total(this_back_spec[first_back_chan:last_back_chan])
    bp_diff_spec[i, *] = bp_low_spec[i, *] - scale_factor * this_back_spec
  endfor

  alt = this_eevt[0:eevt_len - 1].eph.alt
  bp_low = this_eevt[0:eevt_len-1].eevt.bp_low

  jday_range = [ jday[0], jday[eevt_len - 1] ]
  chan_range = [ chan_index[0], chan_index[num_chan - 1] ]

  ;  alt_min = min(alt, max = alt_max)
  ;  alt_range = [ alt_min, alt_max ]
  ;
  ;  bp_min = min(bp_low, max = bp_max)
  ;  bp_low_range = [ bp_min, bp_max ]

  max_spec = window_settings.max_spec()

  num_spec_to_show = min( [ max_spec, eevt_len - spec0_index ] )
  specN_index = spec0_index + num_spec_to_show - 1

  title_plot.title = title

  ; Get position of previous spectrogram. Then delete it and its axes.
  pos = spectrogram.position

  axes = spectrogram.axes
  for i = 0, axes.length - 1 do begin
    axes[i].hide = hide
    axes[i].delete
  endfor
  spectrogram.hide = hide
  spectrogram.delete

  ; Create new spectrogram plot, in same position as previous plot.
  spectrogram = plot_spectrogram(bp_low_spec, jday[0:eevt_len - 1], chan_index, $
    xrange = jday_range, yrange = chan_range, $
    xtickformat = time_format, xtickunits = time_units, $
    position = pos, $
    window = plot_window)

  ; Get position of previous differential spectrogram. Then delete it and its axes.
  pos = diff_spect.position

  axes = diff_spect.axes
  for i = 0, axes.length - 1 do begin
    axes[i].hide = hide
    axes[i].delete
  endfor
  diff_spect.hide = hide
  diff_spect.delete

  ; Create new differential spectrogram plot, in same position as previous plot.
  diff_spect = plot_spectrogram(bp_diff_spec, jday[0:eevt_len - 1], chan_index, $
    xrange = jday_range, yrange = chan_range, $
    xtickformat = time_format, xtickunits = time_units, $
    position = pos, $
    window = plot_window)

  ; This approach didn't work -- color bars perseverated to initial blank range.
  ;  zmin = min(bp_low_spec, max = zmax)
  ;  spectrogram.SetData, bp_low_spec, jday[0:eevt_len - 1], chan_index
  ;  spectrogram.xrange = jday_range
  ;  spectrogram.yrange = chan_range
  ;  spectrogram.zrange = [ zmin, zmax ]
  ;  spectrogram.zlog = log
  ;  zmin = min(bp_diff_spec, max = zmax)
  ;  diff_spect.SetData, bp_diff_spec, jday[0:eevt_len - 1], chan_index
  ;  diff_spect.xrange = jday_range
  ;  diff_spect.yrange = chan_range
  ;  diff_spect.zrange = [ zmin, zmax ]
  ;  diff_spect.zlog = log

  altitude.SetData, jday, alt
  ;  altitude.xrange = jday_range
  ;  altitude.yrange = alt_range
  ; Keep altitude linear even in log mode.
  ;  altitude.ylog = log

  light_curve.SetData, jday, bp_low
  ;  light_curve.xrange = jday_range
  ;  light_curve.yrange = bp_low_range
  light_curve.ylog = log

  highlights.SetData, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index]
  ;  highlights.xrange = jday_range
  ;  highlights.yrange = bp_low_range
  highlights.ylog = log

  for i = spec0_index, specN_index do begin
    i_array = i - spec0_index

    spec_plot = spec_array[i_array]
    back_spec_plot = back_spec_array[i_array]
    diff_spec_plot = diff_spec_array[i_array]
    fit_plot = fit_array[i_array]

    this_evt_spec = this_eevt[i].eevt.bp_low_spec
    this_diff_spec = bp_diff_spec[i, *]

    spec_min = min( [this_evt_spec, this_back_spec ], max = spec_max)
    spec_range = [ spec_min, spec_max ]

    if log then begin
      indices = where(this_diff_spec gt 0, /null)
      diff_min = min(this_diff_spec[indices])
      diff_max = max(this_diff_spec[indices])
    endif else begin
      diff_min = min(this_diff_spec)
      diff_max = max(this_diff_spec)
    endelse

    diff_spec_range = [ diff_min, diff_max ]

    if i eq spec0_index then title = 'Spectrum' else title = ''
    if i eq specN_index then xtitle = 'Channel' else xtitle = ''

    spec_plot.SetData, chan_index, this_evt_spec
    spec_plot.title = title
    spec_plot.xtitle = xtitle
    spec_plot.xrange = chan_range
    spec_plot.yrange = spec_range
    spec_plot.ylog = log

    back_spec_plot.SetData, chan_index, this_back_spec
    back_spec_plot.xrange = chan_range
    back_spec_plot.yrange = spec_range
    back_spec_plot.ylog = log

    amp = fit_param[i, 0]
    spectral_index = fit_param[i, 1]
    fit_valid = finite(amp) and finite(spectral_index)
    if fit_valid then param_label = String(format = ', SI = %0.2f', spectral_index) else param_label = ''

    title = string(format = 'alt = %d', alt[i]) + param_label

    if i eq spec0_index then title = 'Diff spec, ' + title
    if i eq specN_index then xtitle = 'Channel' else xtitle = ''

    diff_spec_plot.SetData, chan_index, this_diff_spec
    diff_spec_plot.xrange = chan_range
    diff_spec_plot.yrange = diff_spec_range
    diff_spec_plot.title = title
    diff_spec_plot.xtitle = xtitle
    diff_spec_plot.ylog = log

    if fit_valid then begin
      fit_plot.SetData, chan_index, amp * exp(chan_index / spectral_index)
      ;      fit_plot.xrange = chan_range
      ;      fit_plot.yrange = diff_spec_range
      fit_plot.ylog = log
    endif

  endfor

  for i = 0, max_spec - 1 do begin
    if i lt num_spec_to_show then hide = 0 else hide = 1

    spec_plot.hide = hide
    back_spec_plot.hide = hide
    diff_spec_plot.hide = hide
    fit_plot.hide = hide
  endfor

  title_plot.refresh
  spectrogram.refresh
  diff_spect.refresh
  altitude.refresh
  light_curve.refresh
  highlights.refresh

  for i = 0, max_spec - 1 do begin
    spec_plot.refresh
    back_spec_plot.refresh
    diff_spec_plot.refresh
    fit_plot.refresh
  endfor

  plot_window.refresh
  plot_window.SetCurrent
end

pro PlotEventsWindow::update_event, jday, chan_index, $
  bp_low_spec, this_back_spec, bp_diff_spec, $
  alt, bp_low, fit_param = fit_param

  self.jday = ptr_new(jday)
  self.chan_index = ptr_new(chan_index)
  self.bp_low_spec = ptr_new(bp_low_spec)
  self.this_back_spec = ptr_new(this_back_spec)
  self.bp_diff_spec = ptr_new(bp_diff_spec)
  self.alt = ptr_new(alt)
  self.bp_low = ptr_new(bp_low)
  self.fit_param = ptr_new(fit_param)

  plot_window = *self.plot_window
  time_format = *self.time_format
  time_units = *self.time_units
  title_plot = *self.title_plot
  spectrogram = *self.spectrogram
  diff_spect = *self.diff_spect
  altitude = *self.altitude
  light_curve = *self.light_curve

  title = self.title

  if self.log then log = 1 else log = 0

  plot_window.refresh, /disable

  title_plot.refresh, /disable
  spectrogram.refresh, /disable
  diff_spect.refresh, /disable
  altitude.refresh, /disable
  light_curve.refresh, /disable

  eevt_len = jday.length
  num_chan = chan_index.length

  jday_range = [ jday[0], jday[eevt_len - 1] ]
  chan_range = [ chan_index[0], chan_index[num_chan - 1] ]

  ;  alt_min = min(alt, max = alt_max)
  ;  alt_range = [ alt_min, alt_max ]
  ;
  ;  bp_min = min(bp_low, max = bp_max)
  ;  bp_low_range = [ bp_min, bp_max ]

  title_plot.title = title

  ; For the spectrograms, at first tried similar approach as for the individual
  ; spectra: kept the initial spectrogram and just updated the data. But this
  ; did not work -- the colorbar and/or Z axis range did not update correctly.
  ; Falling back on deleting the old plot and creating a new one each time.

  ; Get position of previous spectrogram. Then delete it and its axes.
  pos = spectrogram.position

  axes = spectrogram.axes
  for i = 0, axes.length - 1 do begin
    axes[i].delete
  endfor
  spectrogram.delete

  ; Create new spectrogram plot, in same position as previous plot.
  spectrogram = plot_spectrogram(bp_low_spec, jday, chan_index, $
    xrange = jday_range, yrange = chan_range, $
    xtickformat = time_format, xtickunits = time_units, $
    position = pos, $
    window = plot_window)

  ; Get position of previous differential spectrogram. Then delete it and its axes.
  pos = diff_spect.position

  axes = diff_spect.axes
  for i = 0, axes.length - 1 do begin
    axes[i].delete
  endfor
  diff_spect.delete

  ; Create new differential spectrogram plot, in same position as previous plot.
  diff_spect = plot_spectrogram(bp_diff_spec, jday[0:eevt_len - 1], chan_index, $
    xrange = jday_range, yrange = chan_range, $
    xtickformat = time_format, xtickunits = time_units, $
    position = pos, $
    window = plot_window)

  altitude.SetData, jday, alt
  ;  altitude.xrange = jday_range
  ;  altitude.yrange = alt_range
  ; Keep altitude linear even in log mode.
  ;  altitude.ylog = log

  light_curve.SetData, jday, bp_low
  ;  light_curve.xrange = jday_range
  ;  light_curve.yrange = bp_low_range
  light_curve.ylog = log

  title_plot.refresh
  spectrogram.refresh
  diff_spect.refresh
  altitude.refresh
  light_curve.refresh

  plot_window.refresh
  plot_window.setCurrent
end

pro PlotEventsWindow::update_spectra, spec0_index
  jday = *self.jday
  chan_index = *self.chan_index
  bp_low_spec = *self.bp_low_spec
  this_back_spec = *self.this_back_spec
  bp_diff_spec = *self.bp_diff_spec
  alt = *self.alt
  bp_low = *self.bp_low

  plot_window = *self.plot_window
  window_settings = *self.window_settings
  time_format = *self.time_format
  time_units = *self.time_units
  highlights = *self.highlights
  spec_array = *self.spec_array
  back_spec_array = *self.back_spec_array
  diff_spec_array = *self.diff_spec_array
  fit_array = *self.fit_array

  if self.log then log = 1 else log = 0

  max_spec = window_settings.max_spec()

  plot_window.refresh, /disable

  highlights.refresh, /disable
  for i = 0, max_spec - 1 do begin
    spec_array[i].refresh, /disable
    back_spec_array[i].refresh, /disable
    diff_spec_array[i].refresh, /disable
    fit_array[i].refresh, /disable
  endfor

  eevt_len = jday.length
  num_chan = chan_index.length

  jday_range = [ jday[0], jday[eevt_len - 1] ]
  chan_range = [ chan_index[0], chan_index[num_chan - 1] ]

  ;  bp_min = min(bp_low, max = bp_max)
  ;  bp_low_range = [ bp_min, bp_max ]

  num_spec_to_show = min( [ max_spec, eevt_len - spec0_index ] )
  specN_index = spec0_index + num_spec_to_show - 1

  highlights.SetData, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index]
  ;  highlights.xrange = jday_range
  ;  highlights.yrange = bp_low_range
  highlights.ylog = log

  for i = spec0_index, specN_index do begin
    i_array = i - spec0_index

    spec_plot = spec_array[i_array]
    back_spec_plot = back_spec_array[i_array]
    diff_spec_plot = diff_spec_array[i_array]
    fit_plot = fit_array[i_array]

    this_evt_spec = reform(bp_low_spec[i, *])
    this_diff_spec = reform(bp_diff_spec[i, *])

    spec_min = min( [this_evt_spec, this_back_spec ], max = spec_max)
    spec_range = [ spec_min, spec_max ]

    if log then begin
      indices = where(this_diff_spec gt 0, /null)
      diff_min = min(this_diff_spec[indices])
      diff_max = max(this_diff_spec[indices])
    endif else begin
      diff_min = min(this_diff_spec)
      diff_max = max(this_diff_spec)
    endelse

    diff_spec_range = [ diff_min, diff_max ]

    if i eq spec0_index then title = 'Spectrum' else title = ''
    if i eq specN_index then xtitle = 'Channel' else xtitle = ''

    spec_plot.SetData, chan_index, this_evt_spec
    spec_plot.title = title
    spec_plot.xtitle = xtitle
    spec_plot.xrange = chan_range
    spec_plot.yrange = spec_range
    spec_plot.ylog = log

    back_spec_plot.SetData, chan_index, this_back_spec
    back_spec_plot.xrange = chan_range
    back_spec_plot.yrange = spec_range
    back_spec_plot.ylog = log

    if ptr_valid(self.fit_param) then begin
      fit_param = *self.fit_param
      amp = fit_param[i, 0]
      spectral_index = fit_param[i, 1]
      fit_valid = finite(amp) and finite(spectral_index)
    endif else begin
      fit_valid = !false
    endelse

    if fit_valid then param_label = String(format = ', SI = %0.2f', spectral_index) else param_label = ''
    title = string(format = 'alt = %d', alt[i]) + param_label

    if i eq spec0_index then title = 'Diff spec, ' + title
    if i eq specN_index then xtitle = 'Channel' else xtitle = ''

    diff_spec_plot.SetData, chan_index, this_diff_spec
    diff_spec_plot.xrange = chan_range
    diff_spec_plot.yrange = diff_spec_range
    diff_spec_plot.title = title
    diff_spec_plot.xtitle = xtitle
    diff_spec_plot.ylog = log

    if fit_valid then begin
      fit_plot.SetData, chan_index, amp * exp(chan_index / spectral_index)
      ;      fit_plot.xrange = chan_range
      ;      fit_plot.yrange = diff_spec_range
    endif else begin
      ;      fit_plot.SetData, [ 0.0 ]
    endelse
    fit_plot.ylog = log

  endfor

  for i = 0, max_spec - 1 do begin
    if i lt num_spec_to_show then hide = 0 else hide = 1

    spec_array[i].hide = hide
    back_spec_array[i].hide = hide
    diff_spec_array[i].hide = hide

    if not fit_valid then fit_array[i].hide = 1 $
    else fit_array[i].hide = hide
  endfor

  highlights.refresh
  for i = 0, max_spec - 1 do begin
    spec_array[i].refresh
    back_spec_array[i].refresh
    diff_spec_array[i].refresh
    fit_array[i].refresh
  endfor

  plot_window.refresh
  plot_window.setCurrent
end

function PlotEventsWindow::KeyHandler, window, isASCII, character, keyvalue, x, y, press, release, keymode
  character = string(character)

  if release then begin
    if character eq 's' or character eq 'S' then begin
    endif
  endif
end

function PlotEventsWindow::MouseDown, window, x, y, button, keymods, clicks
  return, 1
end

; Class definition.
pro PlotEventsWindow__define
  ; Initial values specified after colon must be there or there will be an error.
  ; However, the values specified are apparently ignored. array and object initializations
  ; must be repeated in the init method.
  !null = { $
    PlotEventsWindow, inherits GraphicsEventAdapter, $
    window_settings:ptr_new(), $
    controller:ptr_new(), $
    plot_window:ptr_new(), $
    time_format:ptr_new(), $
    time_units:ptr_new(), $
    title_plot:ptr_new(), $
    spectrogram:ptr_new(), $
    diff_spect:ptr_new(), $
    altitude:ptr_new(), $
    light_curve:ptr_new(), $
    highlights:ptr_new(), $
    spec_array:ptr_new(), $
    back_spec_array:ptr_new(), $
    diff_spec_array:ptr_new(), $
    fit_array:ptr_new(), $
    jday:ptr_new(), $
    chan_index:ptr_new(), $
    bp_low_spec:ptr_new(), $
    this_back_spec:ptr_new(), $
    bp_diff_spec:ptr_new(), $
    alt:ptr_new(), $
    bp_low:ptr_new(), $
    eevt:ptr_new(), $
    fit_param:ptr_new(), $
    title:'', $
    spec0_index:0, $
    log:!true $
  }
end
