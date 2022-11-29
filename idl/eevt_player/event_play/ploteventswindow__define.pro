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

  ; hide = 1
  ;  show = 0
  ;  plot_window.hide = hide

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

  max_spec = ws.max_spec()

  title_plot = plot(dummy_array1d, /current, title = 'Event N', axis_style = 0, window = plot_window)

  spectrogram = plot_spectrogram(dummy_array2d, dummy_array1d, dummy_array1d, $
    xtickformat = time_format, xtickunits = time_units, $
    nodata = !true, $
    suppress_color_bar = !true, $
    window = plot_window)

  diff_spect = plot_spectrogram(dummy_array2d, dummy_array1d, dummy_array1d, $
    xtickformat = time_format, xtickunits = time_units, $
    nodata = !true, $
    suppress_color_bar = !true, $
    window = plot_window)

  ; The altitude will be plotted with axis on the right overtop the light curve.
  altitude = plot(dummy_array1d, dummy_array1d, /current, axis_style = 4, $
    xstyle = exact, ystyle = exact, $
    xtickformat = time_format, xtickunits = time_units, thick = 2, $
    symbol = diamond, sym_size = 1, $
    color = accent_color2, $
    window = plot_window)

  !null = axis('Y', location='right', title = 'Altitude', color = accent_color2, $
    target = altitude)

  light_curve = plot(dummy_array1d, dummy_array1d, /current, $
    axis_style = 1, $
    xstyle = exact, ystyle = exact, $
    xtickformat = time_format, xtickunits = time_units, thick = 2, $
    ytitle = 'BP low', ycolor = fg_color, $
    symbol = diamond, sym_size = 1, $
    color = fg_color, $
    window = plot_window)

  highlights = plot(dummy_array1d, dummy_array1d, /overplot, $
    xstyle = exact, ystyle = exact, $
    symbol = square, sym_size = 1.2, sym_thick = 2, color = accent_color1, linestyle = 'none', $
    window = plot_window)

  spec_array = make_array(max_spec, /obj)
  back_spec_array = make_array(max_spec, /obj)
  diff_spec_array = make_array(max_spec, /obj)
  fit_array = make_array(max_spec, /obj)

  for i = 0, max_spec - 1 do begin
    spec_array[i] = plot(dummy_array1d, dummy_array1d, /current, /ylog, $
      ytitle = 'Counts per second', thick = 2, $
      xstyle = exact, ystyle = exact, $
      color = accent_color1, $
      window = plot_window)
    back_spec_array[i] = plot(dummy_array1d, dummy_array1d, /overplot, /ylog, $
      thick = 2, $
      xstyle = exact, ystyle = exact, $
      color = fg_color, $
      window = plot_window)
    diff_spec_array[i] = plot(dummy_array1d, dummy_array1d, /current, /ylog, $
      ytitle = 'Counts per second', thick = 2, $
      xstyle = exact, ystyle = exact, $
      color = accent_color1, $
      window = plot_window)
    fit_array[i] = plot(dummy_array1d, dummy_array1d, /overplot, /ylog, $
      thick = 2, $
      ;      xstyle = exact, ystyle = exact, $
      color = fg_color, $
      window = plot_window)
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

  self.layout

  return, 1
end

pro PlotEventsWindow::set_title, title
  self.title = title
end

pro PlotEventsWindow::set_event, this_eevt
  self.eevt = ptr_new(this_eevt)
  self.spec0_index = 0
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

pro PlotEventsWindow::layout
  window_settings = *self.window_settings
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

  xsize = window_settings.xsize()
  ysize = window_settings.ysize()

  xunit = 9.0 / xsize
  yunit = 8.0 / ysize
  margins = [ 8.0 * xunit, 8.0 * xunit, 2.0 * yunit, 8.0 * yunit ]

  max_spec = window_settings.max_spec()

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
  title_plot.position = pos
  row_index += lines_for_title

  pos = plot_coord(row_index, panel0, imax, 1, margins = margins)
  spectrogram.position = pos
  row_index += lines_for_spec

  pos = plot_coord(row_index, panel0, imax, 1, margins = margins)
  diff_spect.position = pos
  row_index += lines_for_diff_spec

  pos = plot_coord(row_index, panel0, imax, 1, margins= margins)
  altitude.position = pos
  light_curve.position = pos
  highlights.position = pos
  row_index += lines_for_lc

  for i = 0, max_spec - 1 do begin
    pos = plot_coord(row_index, panel0, imax, jmax, right = 4.0 * xunit, margins = margins)
    spec_array[i].position  = pos
    back_spec_array[i].position = pos

    pos = plot_coord(row_index, panel1, imax, jmax, left = 4.0 * xunit, margins = margins)
    diff_spec_array[i].position = pos
    fit_array[i].position = pos

    ++row_index
  endfor
end

pro PlotEventsWindow::update
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

  jday = this_eevt[0:eevt_len - 1].hk.jday
  chan_index = findgen(64)
  num_chans = size(chan_index)

  ; Time step index where background spectrum is found in each event.
  last_ind = 60

  ; Channel indices that determine the range for spectra to
  ; agree with the background spectrum. This is used to scale the spectra.
  back_ind0 = 50
  back_ind1 = 60

  bp_low_spec = transpose(this_eevt[0:eevt_len - 1].eevt.bp_low_spec);
  this_back_spec = this_eevt[last_ind].eevt.bp_low_spec

  scale_factor = make_array(eevt_len, /float)
  spec = make_array(eevt_len, num_chans[1], /float)
  diff_spec = make_array(eevt_len, num_chans[1], /float)

  for i = 0, eevt_len - 1 do begin
    scale_factor[i] = total(this_back_spec[back_ind0:back_ind1])/total(bp_low_spec[i, back_ind0:back_ind1])
    diff_spec[i, *] = scale_factor[i] * bp_low_spec[i, *] - this_back_spec
  endfor

  alt = this_eevt[0:eevt_len - 1].eph.alt
  bp_low = this_eevt[0:eevt_len-1].eevt.bp_low

  jday_range = [ jday[0], jday[eevt_len - 1] ]
  chan_range = [ chan_index[0], chan_index[num_chans[1] - 1] ]

  alt_min = min(alt, max = alt_max)
  alt_range = [ alt_min, alt_max ]

  bp_min = min(bp_low, max = bp_max)
  bp_low_range = [ bp_min, bp_max ]

  max_spec = window_settings.max_spec()

  num_spec_to_show = min( [ max_spec, eevt_len - spec0_index ] )
  specN_index = spec0_index + num_spec_to_show - 1

  if specN_index ge eevt_len then specN_index = eevt_len - 1

  title_plot.title = title

  pos = spectrogram.position

  axes = spectrogram.axes
  for i = 0, axes.length - 1 do begin
    axes[i].hide = hide
    axes[i].delete
  endfor

  spectrogram.hide = hide
  spectrogram.delete

  spectrogram = plot_spectrogram(bp_low_spec, jday[0:eevt_len - 1], chan_index, $
    xrange = jday_range, yrange = chan_range, $
    xtickformat = time_format, xtickunits = time_units, $
    position = pos, $
    window = plot_window)

  pos = diff_spect.position

  axes = diff_spect.axes
  for i = 0, axes.length - 1 do begin
    axes[i].hide = hide
    axes[i].delete
  endfor

  diff_spect.hide = hide
  diff_spect.delete

  diff_spect = plot_spectrogram(diff_spec, jday[0:eevt_len - 1], chan_index, $
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
  ;  zmin = min(diff_spec, max = zmax)
  ;  diff_spect.SetData, diff_spec, jday[0:eevt_len - 1], chan_index
  ;  diff_spect.xrange = jday_range
  ;  diff_spect.yrange = chan_range
  ;  diff_spect.zrange = [ zmin, zmax ]
  ;  diff_spect.zlog = log

  altitude.SetData, jday, alt
  altitude.xrange = jday_range
  altitude.yrange = alt_range
  ; Keep altitude linear even in log mode.
  ;  altitude.ylog = log

  light_curve.SetData, jday, bp_low
  light_curve.xrange = jday_range
  light_curve.yrange = bp_low_range
  light_curve.ylog = log

  highlights.SetData, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index]
  highlights.xrange = jday_range
  highlights.yrange = bp_low_range
  highlights.ylog = log

  for i = spec0_index, specN_index do begin
    i_array = i - spec0_index

    spec_plot = spec_array[i_array]
    back_spec_plot = back_spec_array[i_array]
    diff_spec_plot = diff_spec_array[i_array]
    fit_plot = fit_array[i_array]

    this_evt_spec = this_eevt[i].eevt.bp_low_spec
    scale_fac = scale_factor[i]
    this_diff_spec = diff_spec[i, *]

    spec_range = [ 0.1, max([this_back_spec, scale_fac * this_evt_spec]) ]

    indices = where(this_diff_spec gt 0, /null)
    if log then begin
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
    spec_plot.xrange = chan_range
    spec_plot.yrange = spec_range
    spec_plot.title = title
    spec_plot.xtitle = xtitle
    spec_plot.ylog = log

    back_spec_plot.SetData, chan_index, this_back_spec
    back_spec_plot.xrange = chan_range
    back_spec_plot.yrange = spec_range
    back_spec_plot.ylog = log

    param = this_eevt[i].eevt.exp_fac
    param_valid = param ne !values.d_nan
    if param_valid then param_label = String(format = ' SI = %0.2f', param) else param_label = ''

    title = string(format = 'alt = %d', alt[i]) + param_label

    if i eq spec0_index then title = 'Diff spec, ' + title
    if i eq specN_index then xtitle = 'Channel' else xtitle = ''

    diff_spec_plot.SetData, chan_index, this_diff_spec
    diff_spec_plot.xrange = chan_range
    diff_spec_plot.yrange = diff_spec_range
    diff_spec_plot.title = title
    diff_spec_plot.xtitle = xtitle
    diff_spec_plot.ylog = log

    threshold = 0.2
    if param gt threshold then amp = diff_min $
    else if param lt -threshold then amp = diff_max $
    else amp = sqrt(abs(diff_min * diff_max))

    if param_valid then begin
      fit_plot.SetData, chan_index, amp * exp(chan_index / param)
      ;      fit_plot.xrange = chan_range
      ;      fit_plot.yrange = diff_spec_range
      fit_plot.ylog = log
    endif

  endfor

  for i = 0, max_spec - 1 do begin
    if i < num_spec_to_show then hide = 0 else hide = 1

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

function PlotEventsWindow::MouseDown, window, x, y, button, keymods, clicks
  return, 0
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
    eevt:ptr_new(), $
    title:'', $
    spec0_index:0, $
    log:!true $
  }
end
