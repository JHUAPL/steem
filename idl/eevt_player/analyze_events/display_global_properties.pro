pro display_global_properties, eevt, vals, eevt_ids, $
  x_quant, y_quant, row_index = row_index, num_rows = num_rows, $
  window_settings = window_settings

  common draw_colors, fg_color, accent_color

  if eevt eq !null then begin
    print, 'No events to plot'
    return
  endif

  if not keyword_set(row_index) then row_index = 0
  if not keyword_set(num_rows) then num_rows = 1
  if not keyword_set(window_settings) then window_settings = obj_new('WindowSettings')

  xsize = window_settings.xsize()
  ysize = window_settings.ysize()
  max_spec_per_step = window_settings.max_spec()

  xunit = 9.0 / xsize
  yunit = 8.0 / ysize

  ; Do this or else the color bars are messed up.
  device, decomposed = 0

  loadct, 13; Rainbow
  ;  loadct, 32 ; Plasma -- nice contrasts but can't gauge intensity.
  ;  loadct, 74 ; Spectral -- darker = more, not really good and background is red.

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

end