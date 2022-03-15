pro plot_events_pro, eevt, vals, zrange = zrange, $
  xsize = xsize, ysize = ysize, $
  max_windows = max_windows, max_spec_per_step = max_spec_per_step, $
  mon_index = mon_index

  common draw_colors, fg_color, accent_color

  if eevt eq !null then begin
    print, 'No events to plot'
    return
  endif

  if not keyword_set(xsize) then xsize = 1280
  if not keyword_set(ysize) then ysize = 900
  if not keyword_set(max_windows) then max_windows = 1
  if not keyword_set(max_spec_per_step) then max_spec_per_step = 3
  if not keyword_set(mon_index) then mon_index = 0

  ; Do this or else the color bars are messed up.
  device, decomposed = 0
  loadct, 13; Rainbow
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
  dims = eevt.dim

  title = string(FORMAT = "E.E. Events %d", win_index)

  !null = create_win_pro(mon_index, win_index, xsize = xsize, ysize = ysize, title = title)

  show_instructions

  panel0 = 0
  panel1 = 1
  panel2 = 2
  margin_offset = 0.03

  spec_log = !true

  event_index = 0
  while event_index ge 0 and event_index lt dims[0] do begin

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

    eevt_id = format_jday(jday[0])

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

      specN_index = spec0_index + spec_per_step - 1

      row_index = 0
      erase

      cb_height = 0.5

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index, 0, imax, 1, height = cb_height, top = 0.0)

      spec_to_plot = bp_low_spec
      ;      spec_to_plot = diff_spec

      !null = color_bar_pro(spec_to_plot, zrange = zrange, zlog = spec_log, xtitle = 'Counts per second', position = pos)

      ++row_index

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index - cb_height, 0, imax, 1, height = 2.0 - cb_height, top = 0.0, bottom = 0.06)

      xrange = jday_range
      yrange = chan_range

      !null = plot_spectrogram_pro(spec_to_plot, jday[0:eevt_len - 1], chan_index, $
        xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, $
        zrange = zrange, zlog = spec_log, $
        xtickformat = xformat, xtickunits = xtickunits, xticks = 5, $
        xtitle = 'Spectrogram', $
        position = pos)

      ++row_index

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index, 0, imax, 1, height = cb_height, top = 0.0)

      ;      spec_to_plot = bp_low_spec
      spec_to_plot = diff_spec

      !null = color_bar_pro(spec_to_plot, zrange = zrange, zlog = spec_log, xtitle = 'Counts per second', position = pos)

      ++row_index

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index - cb_height, 0, imax, 1, height = 2.0 - cb_height, top = 0.0, bottom = 0.06)

      xrange = jday_range
      yrange = chan_range

      !null = plot_spectrogram_pro(spec_to_plot, jday[0:eevt_len - 1], chan_index, $
        xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, $
        zrange = zrange, zlog = spec_log, $
        xtickformat = xformat, xtickunits = xtickunits, xticks = 5, $
        xtitle = 'Differential Spectrogram', $
        position = pos)

      ++row_index

      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index, 0, imax, 1)

      xrange = jday_range
      yrange = bp_low_range

      ; Plot the 'light curve' for this event.
      plot, jday, bp_low, /noerase, title = 'Event ' + eevt_id, $
        xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, $
        xtickformat = xformat, xtickunits = xtickunits, xticks = 5, thick = 2, $
        psym = -diamond, symsize = 1, $
        color = fg_color, $
        position = pos

      ; Highlight the points whose spectra will be shown.
      plots, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index], $
        psym = square, symsize = 4, color = accent_color

      ++row_index

      for i = spec0_index, specN_index do begin

        this_evt_spec = this_eevt[i].eevt.bp_low_spec
        scale_fac = scale_factor[i]

        pos = plot_coord(row_index, panel0, imax, jmax, right = 0.03 - margin_offset)

        xrange = chan_range
        yrange = [ 0.1, max([this_back_spec, scale_fac * this_evt_spec]) ]

        if i eq spec0_index then title = 'Spectrum' else title = ''
        if i eq specN_index then xtitle = 'Channel' else xtitle = ''

        plot, chan_index, this_back_spec, /noerase, title = title, $
          xtitle = xtitle, ytitle = 'Counts per second', /ylog, thick = 2, $
          xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, $
          color = fg_color, $
          position = pos

        oplot, scale_fac * this_evt_spec, thick = 2, color = accent_color

        this_diff_spec = diff_spec[i, *]
        diff_spec_for_fit = this_diff_spec
        make_positive_for_fit = !true
        if make_positive_for_fit then begin
          ; Not sure about this: is it really needed, does it really help the fits?
          max_value = max(this_diff_spec[ind_low:ind_high], /nan, min=min_value)
          if min_value lt 0 then diff_spec_for_fit -= min_value
        endif

        param = exp_fit(chan_index[ind_low:ind_high], $
          diff_spec_for_fit[ind_low:ind_high], yfit=yfit)


        if spec_log then begin
          qtmp = where(this_diff_spec gt 0, nqtmp)
          diff_min = min(this_diff_spec[qtmp])
          diff_max = max(this_diff_spec[qtmp])
        endif      else begin
          diff_min = min(this_diff_spec)
          diff_max = max(this_diff_spec)
        endelse

        pos = plot_coord(row_index, panel1, imax, jmax, left = 0.03 - margin_offset)

        xrange = chan_range
        yrange = [ diff_min, diff_max ]

        if i eq spec0_index then title = 'Diff spec' else title = ''
        if i eq specN_index then xtitle = 'Channel' else xtitle = ''

        if spec_log then begin
          plot, chan_index, this_diff_spec, /noerase, title = title, $
            xtitle = xtitle, ytitle = 'Counts per second', /ylog, $
            xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, $
            color = fg_color, $
            thick = 5, position = pos
        endif else begin
          plot, chan_index, this_diff_spec, /noerase, title = title, $
            xtitle = xtitle, ytitle = 'Counts per second', $
            xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, $
            color = fg_color, $
            thick = 5, position = pos
        endelse

        if n_elements(param) eq 2 then begin
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
          r eq 'q' or r eq 'Q'

        ; Handle things that don't require replotting right here.
        if r eq 'd' or r eq 'D' then begin
          print, format = 'Selected event %d: %s (%s)', event_index, eevt_id, smoothness
        endif else if r eq 'k' or r eq 'K' then begin
          print, format = 'Keeping event %s in window %d', eevt_id, win_index
          create_new_win = !true
        endif else if r eq 's' or r eq 'S' then begin
          xrange = jday_range
          yrange = chan_range
          !null = plot_spectrogram(bp_low_spec, jday[0:eevt_len - 1], chan_index, $
            xrange = xrange, yrange = yrange, $
            xtickformat = xformat, xtickunits = xtickunits, $
            title = 'Event ' + eevt_id)
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
      if event_index lt dims[0] - 1 then ++event_index $
      else print, 'Cannot go past last event. Use q to quit.'
    endif

    if create_new_win then begin
      win_index = ++win_index mod max_windows

      title = string(format = "E.E. Events %d", win_index)

      !null = create_win_pro(mon_index, win_index, xsize = xsize, ysize = ysize, title = title)

    endif

  endwhile

  print, 'Done plotting'
end
