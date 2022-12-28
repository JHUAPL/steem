; There was a version of this that still did all the event unpacking.
; This was closer to the original monolithic all-in-one code.
; To see that version, go back to the commit whose message is
; "Split updating overall event plots from spectra plots." After that
; commit, there was a bunch of code clean-up.
function PlotEventsWindow::init, controller, window_settings = window_settings
  handler = self

  if not keyword_set(window_settings) then $
    window_settings = obj_new('WindowSettings')

  ; Do this or else the color bars are messed up.
  device, decomposed = 0

  loadct, 13 ; Rainbow
  ;  loadct, 32 ; Plasma -- nice contrasts but can't gauge intensity.
  ;  loadct, 74 ; Spectral -- darker = more, not really good and background is red.

  ; Standard procedural plot set-up.
  standard_plot

  plot_window = window_settings.create_win(title = 'Event Detail', handler = handler)

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

  max_spec = window_settings.max_spec()

  xsize = window_settings.xsize()
  ysize = window_settings.ysize()

  xunit = 9.0 / xsize
  yunit = 8.0 / ysize
  margins = [ 8.0 * xunit, 8.0 * xunit, 2.0 * yunit, 8.0 * yunit ]

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
  spectrogram = obj_new('Spectrogram', dummy_array2d, dummy_array1d, dummy_array1d, $
    xtickformat = time_format, xtickunits = time_units, $
    nodata = !true, $
    ;    suppress_color_bar = !true, $
    position = pos, $
    window = plot_window)
  row_index += lines_for_spec

  pos = plot_coord(row_index, panel0, imax, 1, margins = margins)
  diff_spect = obj_new('Spectrogram', dummy_array2d, dummy_array1d, dummy_array1d, $
    xtickformat = time_format, xtickunits = time_units, $
    nodata = !true, $
    ;    suppress_color_bar = !true, $
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
    xstyle = exact, ystyle = exact, $
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

  if max_spec gt 0 then begin
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
  endif

  self.window_settings = ptr_new(window_settings)
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

pro PlotEventsWindow::update_log, log
  if self.log eq log then return

  self.log = log

  ; Unpack the necessary plot object fields.
  plot_window = *self.plot_window
  spect = *self.spectrogram
  diff_spect = *self.diff_spect
  altitude = *self.altitude
  light_curve = *self.light_curve
  highlights = *self.highlights
  spec_array = *self.spec_array
  back_spec_array = *self.back_spec_array
  diff_spec_array = *self.diff_spec_array
  fit_array = *self.fit_array

  plot_window.refresh, /disable

  spect.zlog, log
  diff_spect.zlog, log
  ; Never display altitude in log scale.
  ; altitude.ylog = log
  light_curve.ylog = log
  highlights.ylog = log

  ; Arbitrary cut off; typically channels below here have small/unreliable values.
  low_channel_cut = 4

  for i = 0, spec_array.length - 1 do begin
    spec_range = self.compute_yrange(spec_array[i], log, index_min = low_channel_cut)
    back_range = self.compute_yrange(back_spec_array[i], log, index_min = low_channel_cut)
    spec_range = [ min([ spec_range[0], back_range[0] ]), max([ spec_range[1], back_range[1] ]) ]

    diff_spec_range = self.compute_yrange(diff_spec_array[i], log, index_min = low_channel_cut)

    self.set_range, spec_array[i], log, yrange = spec_range

    self.set_range, back_spec_array[i], log, yrange = spec_range

    self.set_range, diff_spec_array[i], log, yrange = diff_spec_range

    if not fit_array[i].hide then begin
      self.set_range, fit_array[i], log, yrange = diff_spec_range
    endif
  endfor

  plot_window.refresh
end

function PlotEventsWindow::compute_yrange, this_plot, ylog, index_min = index_min, index_max = index_max
  this_plot.getData, x, y

  get_plot_range, y, lin_yrange, log_yrange, index_min = index_min, index_max = index_max

  if ylog then yrange = log_yrange $
  else yrange = lin_yrange

  return, yrange
end

; It is the caller's responsibility to ensure that if ylog is true, the yrange
; (if that parameter is specified) does not contain any negative values.
pro PlotEventsWindow::set_range, this_plot, ylog, xrange = xrange, yrange = yrange
  if this_plot.ylog then begin
    ; This plot is currently set to log scale. In case the new
    ; yrange contains negative numbers, first apply the log
    ; scale change, then change the ranges.
    this_plot.ylog = ylog
    if keyword_set(xrange) then this_plot.xrange = xrange
    if keyword_set(yrange) then this_plot.yrange = yrange
  endif else begin
    ; This plot is currently set to linear scale. In case the new
    ; ylog is true, first apply the range changes, then change the
    ; scale.
    if keyword_set(xrange) then this_plot.xrange = xrange
    if keyword_set(yrange) then this_plot.yrange = yrange
    this_plot.ylog = ylog
  endelse

  ; Now change the state of this plot's log setting.
  this_plot.ylog = ylog

  if not ylog then begin
    ; There seems to be a bug in IDL. If one just sets a range, and/or toggles
    ; the log settings, those changes do affect the axis (not a bug). Also the
    ; changes do move the displayed data to be in the right spot on the
    ; rescaled plot (also not a bug). BUT, when going from log to linear, any
    ; negative values (which were not visible with log scaling) do NOT show up
    ; unless the data appear to change. Hence this apparent no-op of getting
    ; the data and setting it again.
    ;
    ; Note: it does NOT work just to refresh the plot window. Tried lots
    ; of other things first. This was the first (and as far we can tell) only
    ; thing that worked.
    this_plot.getData, x, y
    this_plot.setData, x, y
  endif

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

  if keyword_set(fit_param) then self.fit_param = ptr_new(fit_param) $
  else self.fit_param = ptr_new()

  self.replot_event
end

pro PlotEventsWindow::replot_event
  ; Unpack the necessary window data fields.
  jday = *self.jday
  chan_index = *self.chan_index
  bp_low_spec = *self.bp_low_spec
  bp_diff_spec = *self.bp_diff_spec
  alt = *self.alt
  bp_low = *self.bp_low

  ; Unpack the necessary plot object fields.
  plot_window = *self.plot_window
  time_format = *self.time_format
  time_units = *self.time_units
  title_plot = *self.title_plot
  spect = *self.spectrogram
  diff_spect = *self.diff_spect
  altitude = *self.altitude
  light_curve = *self.light_curve

  title = self.title

  if self.log then log = 1 else log = 0

  ; Disable window updates until all changes have been applied.
  plot_window.refresh, /disable

  ; Size of t and E (channel).
  eevt_len = jday.length
  num_chan = chan_index.length

  ; Determine ranges to use for t and E (channel).
  jday_range = [ jday[0], jday[eevt_len - 1] ]
  chan_range = [ chan_index[0], chan_index[num_chan - 1] ]

  if log then get_plot_range, bp_low, !null, bp_low_range $
  else get_plot_range, bp_low, bp_low_range, !null

  title_plot.title = title

  error_status = 0
  catch, error_status
  if error_status ne 0 then begin
    print, string(format = 'Unable to display spectrogram for %s', title)
    print, !error_state.msg
  endif

  if error_status eq 0 then $
    spect.setData, bp_low_spec, jday, chan_index, zlog = log

  if error_status eq 0 then $
    diff_spect.setData, bp_diff_spec, jday, chan_index, zlog = log

  catch, /cancel

  altitude.SetData, jday, alt

  light_curve.SetData, jday, bp_low
  light_curve.xrange = jday_range
  light_curve.yrange = bp_low_range
  light_curve.ylog = log

  ; Finally refresh and bring the window to the front.
  plot_window.refresh
  plot_window.setCurrent

  self.spectrogram = ptr_new(spect)
  self.diff_spect = ptr_new(diff_spect)
end

pro PlotEventsWindow::update_spectra, spec0_index, force_update = force_update
  ; Do nothing if no event data has been supplied previously.
  if not ptr_valid(self.jday) then return

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

  ; Arbitrary cut off; typically channels below here have small/unreliable values.
  low_channel_cut = 4

  if self.log then log = 1 else log = 0

  ; Size of X and Y of the spectrogram.
  eevt_len = jday.length
  num_chan = chan_index.length

  max_spec = window_settings.max_spec()

  ; Ensure the requested first spectrum is in-bounds for the data.
  if spec0_index lt 0 then spec0_index = 0
  if spec0_index ge eevt_len then spec0_index = eevt_len - 1

  if not keyword_set(force_update) then begin
    ; Skip update if we're already displaying said spectrum range.
    if self.spec0_index eq spec0_index then return
  endif

  ; Store the current start point for future reference,
  ; then go on to apply the update.
  self.spec0_index = spec0_index

  ; Disable window updates until all changes have been applied.
  plot_window.refresh, /disable

  ; Determine ranges to use for X and Y.
  jday_range = [ jday[0], jday[eevt_len - 1] ]
  chan_range = [ chan_index[0], chan_index[num_chan - 1] ]

  if log then get_plot_range, bp_low, !null, bp_low_range $
  else get_plot_range, bp_low, bp_low_range, !null

  ; Show up to max_spec spectra.
  num_spec_to_show = min( [ max_spec, eevt_len - spec0_index ] )
  specN_index = spec0_index + num_spec_to_show - 1

  if specN_index ge spec0_index then begin
    ; Identify the current selection of spectra by highlighting them on the "light curve".
    highlights.SetData, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index]
    ;  highlights.xrange = jday_range
    highlights.yrange = bp_low_range
    highlights.ylog = log
  endif

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
    back_spec = reform(this_back_spec[i, *])

    ; Compute ranges for data.
    if log then begin
      get_plot_range, this_evt_spec, !null, spec_range, index_min = low_channel_cut
      get_plot_range, back_spec, !null, back_range, index_min = low_channel_cut
      get_plot_range, this_diff_spec, !null, diff_spec_range, index_min = low_channel_cut
    endif else begin
      get_plot_range, this_evt_spec, spec_range, !null, index_min = low_channel_cut
      get_plot_range, back_spec, back_range, !null, index_min = low_channel_cut
      get_plot_range, this_diff_spec, diff_spec_range, !null, index_min = low_channel_cut
    endelse
    spec_range = [ min([ spec_range[0], back_range[0] ]), max([ spec_range[1], back_range[1] ]) ]

    if i eq spec0_index then title = 'Spectrum' else title = ''
    if i eq specN_index then xtitle = 'Channel' else xtitle = ''

    ; Update the left-hand-side plot of spectrum and background.
    spec_plot.SetData, chan_index, this_evt_spec
    spec_plot.title = title
    spec_plot.xtitle = xtitle
    spec_plot.xrange = chan_range
    spec_plot.yrange = spec_range
    spec_plot.ylog = log

    back_spec_plot.SetData, chan_index, back_spec
    back_spec_plot.xrange = chan_range
    back_spec_plot.yrange = spec_range
    back_spec_plot.ylog = log

    fit_valid = self.is_fit_valid(i)
    if fit_valid then begin
      fit_param = *self.fit_param
      amp = fit_param[i, 0]
      spectral_index = fit_param[i, 1]
    endif

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
      fit_plot.xrange = chan_range
      fit_plot.yrange = diff_spec_range
    endif
    fit_plot.ylog = log

  endfor

  ; Hide plots that would be empty or contain stale data.
  hide = 1
  show = 0
  for i_array = 0, max_spec - 1 do begin
    if i_array lt num_spec_to_show then begin
      ; Data were associated with this index above, so
      ; show the spectrum, background spectrum and
      ; differential spectrum for sure.
      spec_array[i_array].hide = show
      back_spec_array[i_array].hide = show
      diff_spec_array[i_array].hide = show

      i = i_array + spec0_index
      ; Plot containing fit line should be shown if the
      ; fit parameters are valid, hidden otherwise.
      if self.is_fit_valid(i) then fit_array[i_array].hide = show $
      else fit_array[i_array].hide = hide

    endif else begin
      ; No data were associated with this index above, so
      ; hide all plots associated with this index.
      spec_array[i_array].hide = hide
      back_spec_array[i_array].hide = hide
      diff_spec_array[i_array].hide = hide
      fit_array[i_array].hide = hide
    endelse

  endfor

  ; Finally refresh and bring the window to the front.
  plot_window.refresh
  plot_window.setCurrent
end

function PlotEventsWindow::is_fit_valid, index
  ; Unpack fit parameters if they are available.
  if ptr_valid(self.fit_param) then begin
    fit_param = *self.fit_param

    amp = fit_param[index, 0]
    spectral_index = fit_param[index, 1]
    scale_factor = fit_param[index, 2]

    fit_valid = finite(amp) and finite(spectral_index) and finite(scale_factor)
  endif else begin
    fit_valid = !false
  endelse

  return, fit_valid
end

function PlotEventsWindow::KeyHandler, window, isASCII, character, keyvalue, x, y, press, release, keymode
  character = string(character)

  controller = *self.controller

  left = 5
  right = 6
  up = 7
  down = 8

  if release then begin
    r = character

    if r eq 'b' or r eq 'B' or keyvalue eq left then begin

      spec0_index = self.spec0_index - 1
      self.update_spectra, spec0_index

    endif else if r eq ' ' or keyvalue eq right then begin

      spec0_index = self.spec0_index + 1
      self.update_spectra, spec0_index

    endif else if r eq 'l' or r eq 'L' then begin
      ; Toggle linear/log scaling.
      if self.log then log = !false else log = !true

      if log then print, 'Displaying event with logarithmic scaling.' $
      else print, 'Displaying event with linear scaling.'

      self.update_log, log
    endif else if r eq 'n' or keyValue eq down then begin
      controller.next_event
    endif else if r eq 'p' or r eq 'P' or r eq 'N' or keyValue eq up then begin
      controller.previous_event
    endif else if r eq 'r' or r eq 'R' then begin
      self.replot_event
      self.update_spectra, self.spec0_index, force_update = !true
    endif
  endif
end

function PlotEventsWindow::MouseDown, window, x, y, button, keymods, clicks
  if clicks eq 2 then begin
    ; Return 0  here to disable the default handler from getting called.
    ; This pops up an annoying properties window.
    return, 0
  endif

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
    fit_param:ptr_new(), $
    title:'', $
    spec0_index:0, $
    log:!true $
  }
end
