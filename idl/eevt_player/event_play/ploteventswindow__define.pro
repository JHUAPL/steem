; There was a version of this that still did all the event unpacking.
; This was closer to the original monolithic all-in-one code.
; To see that version, go back to the commit whose message is
; "Split updating overall event plots from spectra plots." After that
; commit, there was a bunch of code clean-up.
function PlotEventsWindow::init, window_settings = window_settings
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

pro PlotEventsWindow::set_log, log
  self.log = log
end

pro PlotEventsWindow::update_event, jday, chan_index, $
  bp_low_spec, this_back_spec, bp_diff_spec, $
  alt, bp_low, fit_param = fit_param

  ; Assign input parameters to this window's data fields.
  self.jday = ptr_new(jday)
  self.chan_index = ptr_new(chan_index)
  self.bp_low_spec = ptr_new(bp_low_spec)
  self.this_back_spec = ptr_new(this_back_spec)
  self.bp_diff_spec = ptr_new(bp_diff_spec)
  self.alt = ptr_new(alt)
  self.bp_low = ptr_new(bp_low)
  self.fit_param = ptr_new(fit_param)

  ; Unpack the necessary plot object fields.
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

  ; Disable window updates until all changes have been applied.
  plot_window.refresh, /disable

  title_plot.refresh, /disable
  spectrogram.refresh, /disable
  diff_spect.refresh, /disable
  altitude.refresh, /disable
  light_curve.refresh, /disable

  ; Size of X and Y of the spectrogram.
  eevt_len = jday.length
  num_chan = chan_index.length

  ; Determine ranges to use for X and Y.
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

  ; Now refresh all the plots in one pass.  title_plot.refresh
  spectrogram.refresh
  diff_spect.refresh
  altitude.refresh
  light_curve.refresh

  ; Finally refresh and bring the window to the front.
  plot_window.refresh
  plot_window.setCurrent
end

pro PlotEventsWindow::update_spectra, spec0_index
  ; Do nothing if no event data has been supplied previously.
  if not ptr_valid(jday) then return

  ; Unpack the necessary window data fields.
  jday = *self.jday
  chan_index = *self.chan_index
  bp_low_spec = *self.bp_low_spec
  this_back_spec = *self.this_back_spec
  bp_diff_spec = *self.bp_diff_spec
  alt = *self.alt
  bp_low = *self.bp_low

  ; Unpack the necessary plot object fields.
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

  ; Size of X and Y of the spectrogram.
  eevt_len = jday.length
  num_chan = chan_index.length

  max_spec = window_settings.max_spec()

  ; Ensure the requested first spectrum is in-bounds for the data.
  if spec0_index lt 0 then spec0_index = 0
  if spec0_index ge eevt_len then spec0_index = eevt_len - 1

  ; Skip update if we're already displaying said spectrum range.
  if self.spec0_index eq spec0_index then return

  ; Store the current start point for future reference,
  ; then go on to apply the update.
  self.spec0_index = spec0_index

  ; Disable window updates until all changes have been applied.
  plot_window.refresh, /disable

  highlights.refresh, /disable
  for i = 0, max_spec - 1 do begin
    spec_array[i].refresh, /disable
    back_spec_array[i].refresh, /disable
    diff_spec_array[i].refresh, /disable
    fit_array[i].refresh, /disable
  endfor

  ; Determine ranges to use for X and Y.
  jday_range = [ jday[0], jday[eevt_len - 1] ]
  chan_range = [ chan_index[0], chan_index[num_chan - 1] ]

  ;  bp_min = min(bp_low, max = bp_max)
  ;  bp_low_range = [ bp_min, bp_max ]

  ; Show up to max_spec spectra.
  num_spec_to_show = min( [ max_spec, eevt_len - spec0_index ] )
  specN_index = spec0_index + num_spec_to_show - 1

  ; Identify the current selection of spectra by highlighting them on the "light curve".
  highlights.SetData, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index]
  ;  highlights.xrange = jday_range
  ;  highlights.yrange = bp_low_range
  highlights.ylog = log

  ; Main loop: update plots to show the requested range of spectra.
  ; The loop index is over the whole event's X range.
  for i = spec0_index, specN_index do begin
    ; This index identifies which plot objects to update.
    i_array = i - spec0_index

    ; Unpack for convenience the various plot objects.
    spec_plot = spec_array[i_array]
    back_spec_plot = back_spec_array[i_array]
    diff_spec_plot = diff_spec_array[i_array]
    fit_plot = fit_array[i_array]

    ; Slice out just the current spectrum data.
    this_evt_spec = reform(bp_low_spec[i, *])
    this_diff_spec = reform(bp_diff_spec[i, *])

    ; Compute ranges for data.
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

    ; Update the left-hand-side plot of spectrum and background.
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

    ; Unpack fit parameters if they are available.
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

    ; Unpack right-hand-side plot of spectrum with background subtracted.
    diff_spec_plot.SetData, chan_index, this_diff_spec
    diff_spec_plot.xrange = chan_range
    diff_spec_plot.yrange = diff_spec_range
    diff_spec_plot.title = title
    diff_spec_plot.xtitle = xtitle
    diff_spec_plot.ylog = log

    ; Plot the fit line if it's available.
    if fit_valid then begin
      fit_plot.SetData, chan_index, amp * exp(chan_index / spectral_index)
      ;      fit_plot.xrange = chan_range
      ;      fit_plot.yrange = diff_spec_range
    endif else begin
      ;      fit_plot.SetData, [ 0.0 ]
    endelse
    fit_plot.ylog = log

  endfor

  ; Hide plots that would be empty or contain stale data.
  for i = 0, max_spec - 1 do begin
    if i lt num_spec_to_show then hide = 0 else hide = 1

    spec_array[i].hide = hide
    back_spec_array[i].hide = hide
    diff_spec_array[i].hide = hide

    ; If no fit available, don't display even if displaying the other plots.
    if not fit_valid then fit_array[i].hide = 1 $
    else fit_array[i].hide = hide
  endfor

  ; Now refresh all the plots in one pass.
  highlights.refresh
  for i = 0, max_spec - 1 do begin
    spec_array[i].refresh
    back_spec_array[i].refresh
    diff_spec_array[i].refresh
    fit_array[i].refresh
  endfor

  ; Finally refresh and bring the window to the front.
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
    fit_param:ptr_new(), $
    title:'', $
    spec0_index:0, $
    log:!true $
  }
end