pro display_global_properties, top_dir, eevt, vals, eevt_ids, $
  x_quant, y_quant, $
  xsize = xsize, ysize = ysize, $
  mon_index = mon_index, row_index = row_index, num_rows = num_rows, $
  display_scatter = display_scatter

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
  if not keyword_set(row_index) then row_index = 0
  if not keyword_set(num_rows) then num_rows = 1

  xunit = 9.0 / xsize
  yunit = 8.0 / ysize

  ; Do this or else the color bars are messed up.
  device, decomposed = 0

  loadct, 13; Rainbow
  ;  loadct, 32 ; Plasma -- nice contrasts but can't gauge intensity.
  ;  loadct, 74 ; Spectral -- darker = more, not really good and background is red.
  ;  set_up_color_table, top_dir + 'messenger/color_tables/flir_ct.idl'

  ; Standard procedural plot set-up.
  standard_plot

  noaxes = 0
  nosym = 0
  noline = 6
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

  column_index = 0

  evt_x = extract_array0(eevt, vals, x_quant)
  evt_y = extract_array0(eevt, vals, y_quant)

  use_plot_function = !true
  use_spectrogram = !false

  if use_plot_function then begin
    margins = [ 15.0 * xunit, 8.0 * xunit, 2.0 * yunit, 20.0 * yunit ]

    pos = plot_coord(row_index, column_index, num_rows, 1, margins = margins)

    if row_index eq 0 then begin

      plot = plot(evt_x, evt_y, xtitle = x_quant, ytitle = y_quant, $
        symbol = 'Diamond', linestyle = noline, $
        /current, $
        position = pos)

    endif else begin

      plot = plot(evt_x, evt_y, xtitle = x_quant, ytitle = y_quant, $
        symbol = 'Diamond', linestyle = noline, $
        /current, $
        position = pos)

    endelse

    plot = plot([ evt_x[0] ], [ evt_y[0] ], axis_style = noaxes, $
      symbol = 'Diamond', sym_color = 'Red', sym_thick = 2.0, linestyle = noline, $
      /current, $
      position = pos)

  endif else if display_scatter then begin

    margins = [ 15.0 * xunit, 8.0 * xunit, 2.0 * yunit, 20.0 * yunit ]

    pos = plot_coord(row_index, column_index, num_rows, 1, margins = margins)

    if row_index eq 0 then begin

      plot = scatterplot(evt_x, evt_y, xtitle = x_quant, ytitle = y_quant, $
        /sym_filled, position = pos)

    endif else begin

      plot = scatterplot(evt_x, evt_y, xtitle = x_quant, ytitle = y_quant, $
        /current, $
        /sym_filled, position = pos)

    endelse

  endif else begin

    margins = [ 12.0 * xunit, 8.0 * xunit, 2.0 * yunit, 8.0 * yunit ]

    win_index = 0

    ; TODO: this is overkill if not actually using the spectrogram. Just get the ranges if we end up
    ; with standard plots.
    convert_to_spectrogram, evt_x, evt_y, eevt_ids, xout = x, yout = y, zout = z, xrange = xrange, yrange = yrange, zrange = zrange

    if use_spectrogram then begin
      ; This doesn't quite work. The contour plot just looks wrong because the points are really scattered.
      cb_height = 0.5
      spec_log = !false

      ;  pos = plot_coord(row_index - cb_height, column_index, num_rows, 1, height = cb_height, margins = margins)
      ;
      ;  !null = color_bar_pro(z, zrange = zrange, zlog = spec_log, xtitle = 'Event ID', position = pos)

      ;  ++row_index

      ;  pos = plot_coord(row_index, column_index, num_rows, 1, height = 2.0 - cb_height, margins = margins)
      pos = plot_coord(row_index, column_index, num_rows, 1, margins = margins)

      !null = plot_spectrogram_pro(z, x, y, $
        xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, $
        zrange = zrange, zlog = spec_log, $
        ;    xtickformat = xformat, xtickunits = xtickunits, xticks = 5, $
        xtitle = '', $
        position = pos)

      ;  ++row_index

    endif else begin

      pos = plot_coord(row_index, column_index, num_rows, 1, margins = margins)

      if row_index eq 0 then begin

        plot, evt_x, evt_y, xtitle = x_quant, ytitle = y_quant, $
          xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
          xtickformat = xformat, xtickunits = xtickunits, xticks = 5, thick = 2, $
          psym = diamond, symsize = 2, $
          color = fg_color, $
          position = pos

      endif else begin

        plot, evt_x, evt_y, xtitle = x_quant, ytitle = y_quant, $
          xrange = xrange, xstyle = exact, yrange = yrange, ystyle = exact, $
          xtickformat = xformat, xtickunits = xtickunits, xticks = 5, thick = 2, $
          psym = diamond, symsize = 2, $
          color = fg_color, $
          /noerase, $
          position = pos

      endelse

      for i = 0, eevt_ids.length - 1 do begin

      endfor
      plots, [ evt_x[0] ], [ evt_y[0] ], $
        psym = no_sym, symsize = 6, color = accent_color

    endelse

  endelse

end