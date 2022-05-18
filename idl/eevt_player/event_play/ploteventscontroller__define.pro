; This class encapsulates a set of top-level controller functionality for plotting
; a selection of individual events in detail: spectrograms, "light curves" and spectra.

; Initialize a controller class instance. Events, ancillary data and the selected
; event identifiers are set when the object instance is constructed, and are never
; changed thereafter.
;
; Parameters:
;   eevt primary structure containing 3 arrays with event data
;   vals ancillary data structure containing 1 array
;   eevt_ids 1-d array of integer event identifiers
;
function PlotEventsController::init, eevt, vals, eevt_ids, $
  window_settings = window_settings

  self.eevt = ptr_new(eevt)
  self.vals = ptr_new(vals)
  self.eevt_ids = ptr_new(eevt_ids)
  self.handler = ptr_new(obj_new('PlotEventsHandler', self))

  if not keyword_set(window_settings) then $
    window_settings = ptr_new(obj_new('WindowSettings'))

  self.window_settings = window_settings

  self.plot_window_defined = !false
  self.plot_window = ptr_new()

  return, 1
end

pro PlotEventsController::show_plots, eevt_id = eevt_id

  eevt = *self.eevt
  vals = *self.vals
  eevt_ids = *self.eevt_ids
  handler = *self.handler
  window_settings = *self.window_settings

  if not self.plot_window_defined then begin
    self.plot_window = ptr_new(window_settings.create_win(handler = handler))
    self.plot_window_defined = !true
  endif

  plot_window = *self.plot_window

  if not keyword_set(eevt_id) then eevt_id = eevt_ids[0]

  plot_window.SetCurrent

  event_index = where(eevt_ids eq eevt_id)

  if event_index[0] eq -1 then return

  xsize = window_settings.xsize()
  ysize = window_settings.ysize()
  max_spec_per_step = window_settings.max_spec()

  xunit = 9.0 / xsize
  yunit = 8.0 / ysize
  margins = [ 8.0 * xunit, 8.0 * xunit, 2.0 * yunit, 8.0 * yunit ]

  ; Time step index where background spectrum is found in each event.
  last_ind = 60

  ; Channel indices that determine the range for spectra to
  ; agree with the background spectrum. This is used to scale the spectra.
  back_ind0 = 50
  back_ind1 = 60

  ; Channel indices that determine the range for fitting.
  ind_low = 7
  ind_high = 20

  diamond = "Diamond"
  square = "Square"
  fg_color = 'blue'
  accent_color = 'red'
  accent_color2 = 'green'

  exact = 1

  ; Single line labels.
  ; Time plot formatting.
  date_format = [ '%h:%i' ]
  ; Initialize date labels.
  !null = label_date(date_format = date_format)
  xformat = [ 'label_date' ]
  xtickunits = [ 'Minutes' ]

  title = string(FORMAT = "E.E. Events %d", window_settings.get_win_index())

  this_eevt = eevt[event_index, *]
  eevt_len = this_eevt[0].eevt.evt_length

  jday = this_eevt[0:eevt_len - 1].hk.jday
  chan_index = findgen(64)
  num_chans = size(chan_index)

  bp_low_spec = transpose(this_eevt[0:eevt_len - 1].eevt.bp_low_spec);
  this_back_spec = this_eevt[last_ind].eevt.bp_low_spec

  scale_factor = make_array(eevt_len, /float)
  spec = make_array(eevt_len, num_chans[1], /float)
  diff_spec = make_array(eevt_len, num_chans[1], /float)

  for i = 0, eevt_len - 1 do begin
    scale_factor[i] = total(this_back_spec[back_ind0:back_ind1])/total(bp_low_spec[i, back_ind0:back_ind1])
    diff_spec[i, *] = scale_factor[i] * bp_low_spec[i, *] - this_back_spec
  endfor

  bp_low = this_eevt[0:eevt_len-1].eevt.bp_low
  bp_low_range = [ min(bp_low), max(bp_low) ]

  jday_range = [ jday[0], jday[eevt_len - 1] ]
  chan_range = [ chan_index[0], chan_index[num_chans[1] - 1] ]

  alt = this_eevt[0:eevt_len - 1].eph.alt
  alt_range = [ min(alt), max(alt) ]

  eevt_id = String(format = '%d', eevt_ids[event_index])
  eevt_date = format_jday(jday[0])

  ; Smoothness selection: smooth or bursty
  iNormThreshold = 0.38
  sigmaThreshold = 0.8

  iNorm = vals[event_index].sn_tot_norm2
  sigma = vals[event_index].sm_ness_all2

  bursty = iNorm gt iNormThreshold and sigma lt sigmaThreshold

  if bursty then smoothness = 'smooth' else smoothness = 'bursty'

  spec_per_step = min([eevt_len, max_spec_per_step])

  spec_log = !true

  ; Color bars are built-in for OO spectrograms.
  lines_for_spec = 1
  lines_for_diff_spec = 1
  lines_for_lc = 1

  imax = spec_per_step + lines_for_spec + lines_for_diff_spec + lines_for_lc
  jmax = 2

  spec0_index = 0
  num_steps = eevt_len - spec_per_step

  row_index = 0
  cb_height = 1.0

  panel0 = 0
  panel1 = 1

  ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
  ;    pos = plot_coord(row_index - cb_height, panel0, imax, 1, height = cb_height, margins = margins)
  ;
  spec_to_plot = bp_low_spec
  ;
  ;    !null = color_bar_pro(spec_to_plot, zrange = zrange, zlog = spec_log, xtitle = 'Spectrogram (c/s)', position = pos)
  ;
  ;    ++row_index

  ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
  pos = plot_coord(row_index, panel0, imax, 1, height = 2.0 - cb_height, margins = margins)

  xrange = jday_range
  yrange = chan_range

  !null = plot_spectrogram(spec_to_plot, jday[0:eevt_len - 1], chan_index, $
    xrange = xrange, yrange = yrange, $
    xtickformat = xformat, xtickunits = xtickunits, $
    position = pos)

  ++row_index

  ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
  ;    pos = plot_coord(row_index - cb_height, panel0, imax, 1, height = cb_height, margins = margins)
  ;
  spec_to_plot = diff_spec
  ;
  ;    !null = color_bar_pro(spec_to_plot, zrange = zrange, zlog = spec_log, xtitle = 'Differential spectrogram (c/s)', position = pos)
  ;
  ;    ++row_index

  ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
  pos = plot_coord(row_index, panel0, imax, 1, height = 2.0 - cb_height, margins = margins)

  xrange = jday_range
  yrange = chan_range

  !null = plot_spectrogram(spec_to_plot, jday[0:eevt_len - 1], chan_index, $
    xrange = xrange, yrange = yrange, $
    xtickformat = xformat, xtickunits = xtickunits, $
    ;      xtitle = '', $
    position = pos)

  ++row_index

  specN_index = spec0_index + spec_per_step - 1

  ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
  pos = plot_coord(row_index, panel0, imax, 1, margins = margins)

  ; Plot the altitude with axis on the right overtop the light curve.
  yrange = alt_range
  !null = plot(jday, alt, /current, title = '', $
    xrange = xrange, xstyle = exact, yrange = yrange, $
    xtickformat = xformat, xtickunits = xtickunits, thick = 2, $
    symbol = diamond, sym_size = 1, $
    color = accent_color2, $
    position = pos)

  ;    axis, yaxis = 1, ytitle = 'Altitude', color = accent_color2

  xrange = jday_range
  yrange = bp_low_range

  ; Plot the 'light curve' for this event.
  !null = plot(jday, bp_low, /current, title = 'Event ' + eevt_id, $
    xrange = xrange, xstyle = exact, yrange = yrange, $
    xtickformat = xformat, xtickunits = xtickunits, thick = 2, $
    symbol = diamond, sym_size = 1, $
    color = fg_color, $
    position = pos)

  ;    axis, yaxis = 0, ytitle = 'BP low', color = fg_color

  ; Highlight the points whose spectra will be shown.
  ;    plots, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index], $
  ;      psym = square, symsize = 4, color = accent_color

  ++row_index

  if spec0_index ge 0 and spec0_index le num_steps then begin

    for i = spec0_index, specN_index do begin

      this_evt_spec = this_eevt[i].eevt.bp_low_spec
      scale_fac = scale_factor[i]

      pos = plot_coord(row_index, panel0, imax, jmax, right = 4.0 * xunit, margins = margins)

      xrange = chan_range
      yrange = [ 0.1, max([this_back_spec, scale_fac * this_evt_spec]) ]

      if i eq spec0_index then title = 'Spectrum' else title = ''
      if i eq specN_index then xtitle = 'Channel' else xtitle = ''

      !null = plot(chan_index, this_back_spec, /current, title = title, $
        xtitle = xtitle, ytitle = 'Counts per second', /ylog, thick = 2, $
        xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
        color = fg_color, $
        position = pos)

      ;      oplot, scale_fac * this_evt_spec, thick = 2, color = accent_color

      this_diff_spec = diff_spec[i, *]
      diff_spec_for_fit = this_diff_spec
      make_positive_for_fit = !true
      if make_positive_for_fit then begin
        ; Not sure about this: is it really needed, does it really help the fits?
        max_value = max(this_diff_spec[ind_low:ind_high], /nan, min=min_value)
        if min_value lt 0 then diff_spec_for_fit -= min_value - 1
      endif

      param = exp_fit(chan_index[ind_low:ind_high], $
        diff_spec_for_fit[ind_low:ind_high], yfit=yfit)

      param_valid = n_elements(param) eq 2

      if param_valid then param_label = String(format = ' SI = %0.2f', param[1]) else param_label = ''

      if spec_log then begin
        qtmp = where(this_diff_spec gt 0, nqtmp)
        diff_min = min(this_diff_spec[qtmp])
        diff_max = max(this_diff_spec[qtmp])
      endif      else begin
        diff_min = min(this_diff_spec)
        diff_max = max(this_diff_spec)
      endelse

      pos = plot_coord(row_index, panel1, imax, jmax, left = 4.0 * xunit, margins = margins)

      xrange = chan_range
      yrange = [ diff_min, diff_max ]

      title = string(format = 'alt = %d', alt[i]) + param_label

      if i eq spec0_index then title = 'Diff spec, ' + title
      if i eq specN_index then xtitle = 'Channel' else xtitle = ''

      if spec_log then begin
        !null = plot(chan_index, this_diff_spec, /current, title = title, $
          xtitle = xtitle, ytitle = 'Counts per second', /ylog, $
          xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
          color = fg_color, $
          thick = 5, position = pos)
      endif else begin
        !null = plot(chan_index, this_diff_spec, /current, title = title, $
          xtitle = xtitle, ytitle = 'Counts per second', $
          xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
          color = fg_color, $
          thick = 5, position = pos)
      endelse

      ;      if n_elements(param) eq 2 then begin
      ;        oplot, chan_index, param[0] * exp(chan_index / param[1]), thick = 5, color = accent_color
      ;        this_eevt[i].eevt.exp_fac = param[1]
      ;      endif

      ++row_index

    endfor

  endif

end

; Controller class definition.
;
pro PlotEventsController__define
  !null = { $
    PlotEventsController, $
    eevt:ptr_new(), $
    vals:ptr_new(), $
    eevt_ids:ptr_new(), $
    handler:ptr_new(), $
    window_settings:ptr_new(), $
    plot_window_defined:!false, $
    plot_window:ptr_new() $
  }
end