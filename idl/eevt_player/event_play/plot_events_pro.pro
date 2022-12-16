pro plot_events_pro, eevt, vals, eevt_ids, zrange = zrange

  common draw_colors, fg_color, accent_color

  if eevt eq !null or vals eq !null or eevt_ids eq !null then begin
    print, 'No events to plot'
    return
  endif

  if n_elements(eevt[*, 0]) ne n_elements(vals) or n_elements(eevt[*, 0]) ne n_elements(eevt_ids) then begin
    print, 'Mismatched numbers of elements in inputs'
    return
  endif

  window_settings = obj_new('WindowSettings')
  xsize = window_settings.xsize()
  ysize = window_settings.ysize()
  max_spec_per_step = window_settings.max_spec()

  max_windows = 32

  xunit = 9.0 / xsize
  yunit = 8.0 / ysize
  margins = [ 8.0 * xunit, 8.0 * xunit, 2.0 * yunit, 8.0 * yunit ]

  ; Do this or else the color bars are messed up.
  device, decomposed = 0

  loadct, 13 ; Rainbow
  ;  loadct, 32 ; Plasma -- nice contrasts but can't gauge intensity.
  ;  loadct, 74 ; Spectral -- darker = more, not really good and background is red.

  ; Standard procedural plot set-up.
  standard_plot

  ; Time step index where background spectrum is found in each event.
  last_ind = 60

  ; Channel indices that determine the range for spectra to
  ; agree with the background spectrum. This is used to scale the spectra.
  back_ind0 = 50
  back_ind1 = 60

  ; Channel indices that determine the range for fitting.
  ind_low = 7
  ind_high = 20

  diamond = 4
  square = 6
  fg_color = 105
  accent_color = 255
  accent_color2 = 154

  exact = 1
  suppress = 4

  ; Pass this instead of 0 to functions/procedures. In IDL, 0 is indistinguishable from "unset".
  zero = 1.d-308
  neg_zero = -zero

  ; Labels axis with day, time on two lines.
  ;  ; Time plot formatting.
  ;  date_format = ['%h:%i','%m-%d-%z']
  ;  ; Initialize date labels.
  ;  !null = label_date(date_format = date_format)
  ;  xformat = ['label_date', 'label_date']
  ;  xtickunits = ['Minutes','Days']

  ; Single line labels.
  ; Time plot formatting.
  date_format = [ '%h:%i' ]
  ; Initialize date labels.
  !null = label_date(date_format = date_format)
  xformat = [ 'label_date' ]
  xtickunits = [ 'Minutes' ]

  win_index = 0
  number_events = n_elements(eevt_ids)

  title = string(FORMAT = "E.E. Events %d", win_index)

  !null = create_win_pro(win_index, title = title)

  show_instructions

  spec_log = !true

  event_index = 0
  while event_index ge 0 and event_index lt number_events do begin

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

    lines_for_spec = 2
    lines_for_diff_spec = 2
    lines_for_lc = 1

    imax = spec_per_step + lines_for_spec + lines_for_diff_spec + lines_for_lc
    jmax = 2

    spec0_index = 0
    num_steps = eevt_len - spec_per_step

    create_new_win = !false
    while spec0_index ge 0 and spec0_index le num_steps do begin

      erase

      specN_index = spec0_index + spec_per_step - 1
      row_index = 0
      cb_height = 0.5

      panel0 = 0
      panel1 = 1

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index - cb_height, panel0, imax, 1, height = cb_height, margins = margins)

      spec_to_plot = bp_low_spec

      !null = color_bar_pro(spec_to_plot, zrange = zrange, zlog = spec_log, xtitle = 'Spectrogram (c/s)', position = pos)

      ++row_index

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index, panel0, imax, 1, height = 2.0 - cb_height, margins = margins)

      xrange = jday_range
      yrange = chan_range

      !null = plot_spectrogram_pro(spec_to_plot, jday[0:eevt_len - 1], chan_index, $
        xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
        zrange = zrange, zlog = spec_log, $
        xtickformat = xformat, xtickunits = xtickunits, xticks = 5, $
        xtitle = '', $
        position = pos)

      ++row_index

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index - cb_height, panel0, imax, 1, height = cb_height, margins = margins)

      ;      spec_to_plot = bp_low_spec
      spec_to_plot = diff_spec

      !null = color_bar_pro(spec_to_plot, zrange = zrange, zlog = spec_log, xtitle = 'Differential spectrogram (c/s)', position = pos)

      ++row_index

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index, panel0, imax, 1, height = 2.0 - cb_height, margins = margins)

      xrange = jday_range
      yrange = chan_range

      !null = plot_spectrogram_pro(spec_to_plot, jday[0:eevt_len - 1], chan_index, $
        xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
        zrange = zrange, zlog = spec_log, $
        xtickformat = xformat, xtickunits = xtickunits, xticks = 5, $
        xtitle = '', $
        position = pos)

      ++row_index

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index, panel0, imax, 1, margins = margins)

      ; Plot the altitude with axis on the right overtop the light curve.
      yrange = alt_range
      plot, jday, alt, /noerase, title = '', $
        xrange = xrange, xstyle = exact, yrange = yrange, ystyle = suppress, $
        xtickformat = xformat, xtickunits = xtickunits, xticks = 5, thick = 2, $
        psym = -diamond, symsize = 1, $
        color = accent_color2, $
        position = pos

      axis, yaxis = 1, ytitle = 'Altitude', color = accent_color2

      xrange = jday_range
      yrange = bp_low_range

      ; Plot the 'light curve' for this event.
      plot, jday, bp_low, /noerase, title = 'Event ' + eevt_id, $
        xrange = xrange, xstyle = exact, yrange = yrange, ystyle = suppress, $
        xtickformat = xformat, xtickunits = xtickunits, xticks = 5, thick = 2, $
        psym = -diamond, symsize = 1, $
        color = fg_color, $
        position = pos

      axis, yaxis = 0, ytitle = 'BP low', color = fg_color

      ; Highlight the points whose spectra will be shown.
      plots, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index], $
        psym = square, symsize = 4, color = accent_color

      ++row_index

      for i = spec0_index, specN_index do begin

        this_evt_spec = this_eevt[i].eevt.bp_low_spec
        scale_fac = scale_factor[i]

        pos = plot_coord(row_index, panel0, imax, jmax, right = 4.0 * xunit, margins = margins)

        xrange = chan_range
        yrange = [ 0.1, max([this_back_spec, scale_fac * this_evt_spec]) ]

        if i eq spec0_index then title = 'Spectrum' else title = ''
        if i eq specN_index then xtitle = 'Channel' else xtitle = ''

        plot, chan_index, this_back_spec, /noerase, title = title, $
          xtitle = xtitle, ytitle = 'Counts per second', /ylog, thick = 2, $
          xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
          color = fg_color, $
          position = pos

        oplot, scale_fac * this_evt_spec, thick = 2, color = accent_color

        this_diff_spec = diff_spec[i, *]
        diff_spec_for_fit = this_diff_spec
        make_positive_for_fit = !false
        if make_positive_for_fit then begin
          ; Not sure about this: is it really needed, does it really help the fits?
          max_value = max(this_diff_spec[ind_low:ind_high], /nan, min=min_value)
          if min_value lt 0 then diff_spec_for_fit -= min_value - 1
        endif

        param = exp_fit(chan_index[ind_low:ind_high], $
          diff_spec_for_fit[ind_low:ind_high], yfit=yfit)

        param_valid = finite(param[0]) and finite(param[1])

        exp_fac = this_eevt[i].eevt.exp_fac
        if param_valid then begin
          if this_eevt[i].eevt.exp_fac ne param[1] then begin
            print, 'Discrepancy in fit spectral index: ', this_eevt[i].eevt.exp_fac, ' ne ', param[1]
          endif
        endif else begin
          if this_eevt[i].eevt.exp_fac ne !values.d_nan then begin
            print, 'Discrepancy in fit spectral index: ', this_eevt[i].eevt.exp_fac, ' ne nan'
          endif
        endelse

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
          plot, chan_index, this_diff_spec, /noerase, title = title, $
            xtitle = xtitle, ytitle = 'Counts per second', /ylog, $
            xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
            color = fg_color, $
            thick = 5, position = pos
        endif else begin
          plot, chan_index, this_diff_spec, /noerase, title = title, $
            xtitle = xtitle, ytitle = 'Counts per second', $
            xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
            color = fg_color, $
            thick = 5, position = pos
        endelse

        if param_valid then begin
          oplot, chan_index, param[0] * exp(chan_index / param[1]), thick = 5, color = accent_color
          this_eevt[i].eevt.exp_fac = param[1]
        endif

        ++row_index
      endfor

      repeat begin
        r = get_kbrd(1)

        replot = r eq ' ' or r eq 'b' or r eq 'B' or $
          r eq 'n' or r eq 'N' or r eq 'p' or r eq 'P' or $
          r eq 'l' or r eq 'L' or $
          r eq 'q' or r eq 'Q' or $
          r eq 'r' or r eq 'R'

        ; Handle things that don't require replotting right here.
        if r eq 'd' or r eq 'D' then begin
          print, format = 'Selected event %d: id = %s, date = %s (%s)', event_index, eevt_id, eevt_date, smoothness
        endif else if r eq 'k' or r eq 'K' then begin
          print, format = 'Keeping event %s in window %d', eevt_id, win_index
          create_new_win = !true
        endif else if not replot then show_instructions

      endrep until replot

      if r eq 'b' or r eq 'B' then --spec0_index $
      else if r eq ' ' then ++spec0_index $
      else if r eq 'l' or r eq 'L' then begin
        ; Toggle linear/log scaling for the color bar of the spectrogram.
        spec_log = not spec_log
        if spec_log then print, 'Displaying spectrogram with logarithmic color bar.' $
        else print, 'Displaying spectrogram with linear color bar.'
      endif else break

    endwhile

    if r eq 'q' or r eq 'Q' then break

    if r eq 'N' or r eq 'b' or r eq 'B' or r eq 'p' or r eq 'P' then begin
      ; If on the 0th event, don't exit the loop because of hitting N, b, or B.
      if event_index gt 0 then --event_index $
      else print, 'Cannot back up before first event. Use q to quit.'
    endif else if r eq 'n' or r eq ' ' then begin
      ; If on the last event, don't exit the loop because of hitting n or <space>.
      if event_index lt number_events - 1 then ++event_index $
      else print, 'Cannot go past last event. Use q to quit.'
    endif

    if create_new_win then begin
      win_index = ++win_index mod max_windows

      title = string(format = "E.E. Events %d", win_index)

      !null = create_win_pro(win_index, title = title)

    endif

  endwhile

  print, 'Done plotting'
end
