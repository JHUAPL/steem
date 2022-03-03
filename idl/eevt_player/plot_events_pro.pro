pro plot_events_pro, eevt, vals, xsize = xsize, ysize = ysize, $
  max_windows = max_windows, max_spec_per_step = max_spec_per_step, $
  mon_index = mon_index

  if eevt eq !null then begin
    print, 'No events to plot'
    return
  endif

  if not keyword_set(xsize) then xsize = 1600
  if not keyword_set(ysize) then ysize = 900
  if not keyword_set(max_windows) then max_windows = 1
  if not keyword_set(max_spec_per_step) then max_spec_per_step = 3
  if not keyword_set(mon_index) then mon_index = 0

  ; Standard plot set-up.
  standard_plot

  last_ind = 60
  back_ind0 = 50
  back_ind1 = 60

  diamond = 4
  square = 6
  red = '0000ff'x

  ; Time plot formatting
  date_format = ['%h:%i','%m-%d-%z']
  xformat = ['label_date', 'label_date']
  xunits = ['Minutes','Days']
  ;  date = label_date(date_format = date_format)

  win_index = 0
  dims = eevt.dim

  title = string(FORMAT = "E.E. Events %d", win_index)

  create_win_pro, mon_index, win_index, xsize = xsize, ysize = ysize, title = title

  show_instructions

  ; Plot constants.
  do_plot_spec = !true

  panel0 = 0
  panel1 = 1
  panel2 = 2
  offset = 0.03

  event_index = 0
  while event_index ge 0 and event_index lt dims[0] do begin

    this_eevt = eevt[event_index, *]
    eevt_len = this_eevt[0].eevt.evt_length

    jday = this_eevt[0:eevt_len - 1].hk.jday
    chan_index = findgen(64)
    num_chans = size(chan_index)

    bp_low_spec = transpose(this_eevt[0:eevt_len - 1].eevt.bp_low_spec);

    bp_low = this_eevt[0:eevt_len-1].eevt.bp_low

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

    if do_plot_spec then imax = spec_per_step + 2 $
    else imax = spec_per_step + 1

    jmax = 2

    spec0_index = 0
    num_steps = eevt_len - spec_per_step

    create_new_win = !false
    while spec0_index ge 0 and spec0_index le num_steps do begin

      specN_index = spec0_index + spec_per_step - 1

      row_index = 0
      ; Set jmax = 1 (not jmax) so the plot will fill the window horizontally.
      pos = plot_coord(row_index, 0, imax, 1)

      ; Plot the 'light curve' for this event.
      xrange = jday_range
      plot, jday, bp_low, title = 'Event ' + eevt_id, $
        xrange = xrange, xstyle = 1, $
        ; Do not set yrange for this plot, auto-range seems good.
        ;        yrange = ..., $
        xtickformat = xformat, xtickunits = xunits, thick = 2, psym = -diamond, position = pos

      ; Highlight the points whose spectra will be shown.
      plots, jday[spec0_index:specN_index], bp_low[spec0_index:specN_index], psym = square, symsize = 4, color = red
      ++row_index

      pos = plot_coord(row_index, 0, imax, 1)

      if do_plot_spec then begin
        xrange = jday_range
        yrange = chan_range
        plot_spectrogram_pro, bp_low_spec, jday[0:eevt_len - 1], chan_index, $
          xrange = xrange, yrange = yrange, $
          xtickformat = xformat, xtickunits = xtickunits, position = pos
        ++row_index
      endif

      this_back_spec = this_eevt[last_ind].eevt.bp_low_spec

      for i = spec0_index, specN_index do begin

        this_evt_spec = this_eevt[i].eevt.bp_low_spec
        scale_fac = total(this_back_spec[back_ind0:back_ind1])/total(this_evt_spec[back_ind0:back_ind1])
        diff_spec = scale_fac*this_evt_spec - this_back_spec

        pos = plot_coord(row_index, panel0, imax, jmax, right = 0.03 - offset)

        xrange = chan_range
        plot, chan_index, this_back_spec, /noerase, title = 'Spectrum', $
          xtitle = 'Channel', /xsty, xrange = xrange, $
          ytitle = 'Counts per Second', /ylog, yrange = [ 0.1, max([this_back_spec, scale_fac * this_evt_spec]) ], $
          thick = 2, position = pos
        oplot, scale_fac * this_evt_spec, thick = 2, color = red

        ind_low = 7
        ind_high = 20

        min_value = min(diff_spec[ind_low:ind_high])
        max_value = max(diff_spec[ind_low:ind_high])
        if min_value ge 0 then min_value = -max_value / 10000.0
        pos_diff_spec = diff_spec - min_value

        param = exp_fit(chan_index[ind_low:ind_high],pos_diff_spec[ind_low:ind_high],yfit=yfit)

        qtmp = where(diff_spec gt 0,nqtmp)
        diff_min = min(diff_spec[qtmp])
        diff_max = max(diff_spec[qtmp])

        ;        pos = plot_coord(row_index, panel1, imax, jmax, left = 0.07 - offset)
        pos = plot_coord(row_index, panel1, imax, jmax, left = 0.03 - offset)

        plot, chan_index, diff_spec, /noerase, title = 'Diff spec', $
          xtitle = 'Channel', /xsty, xrange = chan_range, $
          ytitle = 'Counts per Second', /ylog, $
          min = diff_min, max = diff_max, thick = 5, position = pos

        if n_elements(param) eq 2 then begin
          oplot, chan_index, param[0] * exp(chan_index / param[1]), thick = 5, color = red
          ;        y,0.3,0.4,param,/do_exp_fcn
          this_eevt[i].eevt.exp_fac = param[1]
        endif

        ++row_index
      endfor

      repeat begin
        r = get_kbrd(1)

        replot = r eq ' ' or r eq 'b' or r eq 'B' or $
          r eq 'n' or r eq 'N' or r eq 'p' or r eq 'P' or $
          r eq 'q' or r eq 'Q'

        ; Handle things that don't require replotting right here.
        if r eq 'd' or r eq 'D' then begin
          print, format = '%s (%s)', eevt_id, smoothness
        endif else if r eq 'k' or r eq 'K' then begin
          print, format = 'Keeping event %s in window %d', eevt_id, win_index
          create_new_win = !true
        endif else if r eq 's' or r eq 'S' then begin
          !null = plot_spectrogram(mon_index, win_index, bp_low_spec, jday[0:eevt_len - 1], chan_index, $
            xrange = xrange, yrange = yrange, $
            xtickformat = xformat, xtickunits = xtickunits, $
            title = 'Event ' + eevt_id)
        endif else if not replot then show_instructions

      endrep until replot

      if r eq 'b' or r eq 'B' then --spec0_index $
      else if r eq ' ' then ++spec0_index $
      else break

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

      title = string(FORMAT = "E.E. Events %d", win_index)

      create_win_pro, mon_index, win_index, xsize = xsize, ysize = ysize, title = title
    endif

  endwhile

  print, 'Done plotting'
end
