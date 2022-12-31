function GlobalPropertyDisplay::init, controller

  if controller eq !null then return, 0

  self.controller = ptr_new(controller)
  self.eevt_ids = ptr_new()
  self.x = ptr_new()
  self.y = ptr_new()
  self.pos = ptr_new()
  self.main_plot = ptr_new()
  self.highlight = ptr_new()
  self.selected = ptr_new()

  return, 1
end

pro GlobalPropertyDisplay::set_data, eevt_ids, x, y
  self.eevt_ids = ptr_new(eevt_ids)
  self.x = ptr_new(x)
  self.y = ptr_new(y)
end

pro GlobalPropertyDisplay::set_pos, pos
  self.pos = ptr_new(pos)
end

pro GlobalPropertyDisplay::set_main_plot, main_plot
  self.main_plot = ptr_new(main_plot)
end

pro GlobalPropertyDisplay::set_highlight, highlight
  self.highlight = ptr_new(highlight)
end

function GlobalPropertyDisplay::is_on_plot, point
  if self.x ne !null and self.y ne !null and self.pos ne !null and self.main_plot ne !null and self.highlight ne !null then begin

    main_plot = *self.main_plot

    pos = *self.pos
    ;    pos = main_plot.position

    pointx = point[0]
    pointy = point[1]

    ; Subtle difference between this and find_closest_event method. Do include points on all borders.
    if pointx ge pos[0] and pointx le pos[2] and pointy ge pos[1] and pointy le pos[3] then return, !true

    return, !false
  endif
end

function GlobalPropertyDisplay::find_closest_event, point

  selected_eevt_id = -1
  if self.x ne !null and self.y ne !null and self.pos ne !null and self.main_plot ne !null and self.highlight ne !null then begin

    main_plot = *self.main_plot

    pos = *self.pos
    ;    pos = main_plot.position

    pointx = point[0]
    pointy = point[1]

    ; Subtle difference between this and is_on_plot method. Don't include points on bordors.
    if pointx gt pos[0] and pointx lt pos[2] and pointy gt pos[1] and pointy lt pos[3] then begin
      ; The clicked point fell within this plot.
      eevt_ids = *self.eevt_ids
      x = *self.x
      y = *self.y

      width = pos[2] - pos[0]
      height = pos[3] - pos[1]

      xrange = main_plot.xrange
      yrange = main_plot.yrange

      xscreen2data = width / (xrange[1] - xrange[0])
      yscreen2data = height / (yrange[1] - yrange[0])

      pointxscaled = (pointx - pos[0]) / xscreen2data + xrange[0]
      pointyscaled = (pointy - pos[1]) / yscreen2data + yrange[0]

      ;      print, pointxscaled, pointyscaled

      xscreen = (x - xrange[0]) * xscreen2data + pos[0]
      yscreen = (y - yrange[0]) * yscreen2data + pos[1]

      rsquared = (xscreen - pointx) * (xscreen - pointx) + (yscreen - pointy) * (yscreen - pointy)

      rsquaredmin = -1
      imin = -1
      for i = 0, n_elements(rsquared) - 1 do begin
        if rsquaredmin eq -1 or rsquaredmin gt rsquared[i] then begin
          rsquaredmin = rsquared[i]
          imin = i
        endif
      endfor

      ; Select the event if we get within about 3% of it.
      rlimit = width * 0.03
      rsquaredlimit = rlimit * rlimit

      if imin ne -1 and rsquaredmin lt rsquaredlimit then selected_eevt_id = eevt_ids[imin]

    endif
  endif

  return, selected_eevt_id
end

; This method returns indices of event ids whose coordinates are in the specified rectangle.
;
function GlobalPropertyDisplay::find_indices_in_range, x_min, x_max, y_min, y_max
  x = *self.x
  y = *self.y
  eevt_ids = *self.eevt_ids
  highlight = *self.highlight
  pos = *self.pos
  main_plot = *self.main_plot

  width = pos[2] - pos[0]
  height = pos[3] - pos[1]

  xrange = main_plot.xrange
  yrange = main_plot.yrange

  xscreen2data = width / (xrange[1] - xrange[0])
  yscreen2data = height / (yrange[1] - yrange[0])

  x_min = (x_min - pos[0]) / xscreen2data + xrange[0]
  x_max = (x_max - pos[0]) / xscreen2data + xrange[0]
  y_min = (y_min - pos[1]) / yscreen2data + yrange[0]
  y_max = (y_max - pos[1]) / yscreen2data + yrange[0]

  indices = where(x ge x_min and x le x_max and y ge y_min and y le y_max, /null)

  return, indices
end

pro GlobalPropertyDisplay::select_event_indices, indices
  eevt_ids = *self.eevt_ids
  x = *self.x
  y = *self.y
  highlight = *self.highlight

  if keyword_set(indices) and n_elements(indices) gt 0 then begin
    selected = eevt_ids[indices]
    self.selected = ptr_new(selected)

    x = x[indices]
    y = y[indices]
    highlight.setData, x, y
    highlight.hide = 0
  endif else begin
    self.selected = ptr_new()
    highlight.hide = 1
  endelse
end

function GlobalPropertyDisplay::toggle_selection, eevt_id

  eevt_ids = *self.eevt_ids
  highlight = *self.highlight

  if (self.selected eq !null) then begin
    ; No events are currently selected. Select just this event.
    selected = eevt_id
  endif else begin
    selected = *self.selected

    indices = where(selected eq eevt_id, /null)
    if n_elements(indices) eq 0 then begin
      ; This event is currently not selected, so select it.
      selected = [ selected, eevt_id ]
    endif else begin
      ; This event is currently selected, so deselect it.
      indices = where(selected ne eevt_id, /null)

      if n_elements(indices) eq 0 then selected = selected[indices] $
      else selected = !null
    endelse
  endelse

  selected_toggle_on = !false
  if selected ne !null then begin
    self.selected = ptr_new(selected)

    indices = []
    for i = 0, n_elements(selected) - 1 do begin
      matches = where(eevt_ids eq selected[i], /null)
      if n_elements(matches) gt 0 then begin
        indices = [ indices, matches ]
      endif
    endfor

    if n_elements(indices) gt 0 then begin
      x = *self.x
      y = *self.y

      x = x[indices]
      y = y[indices]

      highlight.setdata, x, y
      highlight.hide = 0
    endif

    indices = where(selected eq eevt_id, /null)
    selected_toggle_on = n_elements(indices) gt 0
  endif else begin
    self->clear_selections
  endelse

  return, selected_toggle_on
end

function GlobalPropertyDisplay::get_selections
  if self.selected eq !null then return, !null

  return, *self.selected
end

pro GlobalPropertyDisplay::clear_selections
  self.selected = ptr_new()

  highlight = *self.highlight
  highlight.hide = 1
end

pro GlobalPropertyDisplay::display, eevt, vals, eevt_ids, $
  x_quant, y_quant, $
  row_index = row_index, num_rows = num_rows

  common draw_colors, fg_color, accent_color

  if eevt eq !null then begin
    print, 'No events to plot'
    return
  endif

  if not keyword_set(row_index) then row_index = 0
  if not keyword_set(num_rows) then num_rows = 1

  window_settings = obj_new('WindowSettings')
  xsize = window_settings.xsize()
  ysize = window_settings.ysize()

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

  if keyword_set(evt_x) and keyword_set(evt_y) and n_elements(evt_x) eq n_elements(evt_y) then begin
    margins = [ 8.0 * xunit, 8.0 * xunit, 2.0 * yunit, 10.0 * yunit ]

    pos = plot_coord(row_index, column_index, num_rows, 1, margins = margins)

    if row_index eq 0 then begin

      main_plot = plot(evt_x, evt_y, xtitle = x_quant, ytitle = y_quant, $
        symbol = 'Diamond', linestyle = noline, $
        /current, $
        position = pos)

    endif else begin

      main_plot = plot(evt_x, evt_y, xtitle = x_quant, ytitle = y_quant, $
        symbol = 'Diamond', linestyle = noline, $
        /current, $
        position = pos)

    endelse

    highlight = plot([ evt_x[0] ], [ evt_y[0] ], $
      symbol = 'Diamond', sym_color = 'Red', sym_thick = 2.0, linestyle = noline, $
      /current, /overplot, /nodata, $
      position = pos)
  endif

  self->set_data, eevt_ids, evt_x, evt_y
  self->set_pos, pos
  self->set_main_plot, main_plot
  self->set_highlight, highlight

end

pro GlobalPropertyDisplay__define

  !null = { GlobalPropertyDisplay, controller:ptr_new(), eevt_ids:ptr_new(), x:ptr_new(), y:ptr_new(), $
    pos:ptr_new(), main_plot:ptr_new(), highlight:ptr_new(), $
    selected:ptr_new() }

end

