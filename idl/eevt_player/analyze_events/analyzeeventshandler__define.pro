function AnalyzeEventsHandler::init, controller
  self.controller = ptr_new(controller)
  self.plots = ptr_new()
  self.current_plot = ptr_new(/allocate)
  self.x_start = -1
  self.y_start = -1

  return, 1
end

function AnalyzeEventsHandler::MouseDown, window, x, y, button, keymods, clicks

  if not ptr_valid(self.plots) then return, 1

  if button ne 1 then return, 1

  plots = *self.plots

  self.x_start = x
  self.y_start = y

  if clicks eq 1 then begin
    keymod_shift = 1
    select_multiple_events = keymods and keymod_shift

    point = window.ConvertCoord(x, y, /device, /to_normal)
    point = point[0:1]

    found_eevt_id = -1
    for i = 0, n_elements(plots) - 1 do begin
      ploti = plots[i]

      if ploti->is_on_plot(point) then begin
        current_plot = *self.current_plot

        if current_plot ne ploti then begin

          self.current_plot = ptr_new(ploti)

          if current_plot ne !null then return, 1

        endif

        found_eevt_id = ploti->find_closest_event(point)

        break
      endif

    endfor

    if not select_multiple_events then begin

      for i = 0, n_elements(plots) - 1 do begin
        plots[i]->clear_selections
      endfor

    endif

    if found_eevt_id ne -1 then begin
      for i = 0, n_elements(plots) - 1 do begin
        selection_toggle_on = plots[i]->toggle_selection(found_eevt_id)
      endfor

      if selection_toggle_on then print, 'Selected event ', found_eevt_id $
      else print, 'De-selected event ', found_eevt_id
    endif else begin
      self.started_drag_selection = 1
    endelse

  endif else if clicks eq 2 then begin
    for i = 0, n_elements(plots) - 1 do begin
      plots[i]->clear_selections
    endfor

    ; Return 0  here to disable the default handler from getting called.
    ; The default handler pops up an annoying properties window.
    return, 0
  endif

  return, 1
end

function AnalyzeEventsHandler::MouseMotion, window, x, y, keymods

  if not ptr_valid(self.plots) then return, 1
  if not self.started_drag_selection then return, 1

  ;  if button ne 1 then return, 1

  x_start = self.x_start
  y_start = self.y_start

  if x eq x_start and y eq y_start then return, 1

  plots = *self.plots

  point = window.ConvertCoord(x, y, /device, /to_normal)
  point = point[0:1]

  for i = 0, n_elements(plots) - 1 do begin
    ploti = plots[i]

    if ploti->is_on_plot(point) then begin
      current_plot = *self.current_plot

      if current_plot ne ploti then begin

        self.current_plot = ptr_new(ploti)

        if current_plot ne !null then return, 1

      endif

      x_min = min([ x, x_start ])
      x_max = max([ x, x_start ])

      y_min = min([ y, y_start ])
      y_max = max([ y, y_start ])

      p0 = window.ConvertCoord(x_min, y_min, /device, /to_normal)
      p1 = window.ConvertCoord(x_max, y_max, /device, /to_normal)

      ; There's no guarantee that normal coordinates have the same min/max relation as device coordinates.
      x_min = min([ p0[0], p1[0] ])
      x_max = max([ p0[0], p1[0] ])

      y_min = min([ p0[1], p1[1] ])
      y_max = max([ p0[1], p1[1] ])

      selected_indices = ploti->find_indices_in_range(x_min, x_max, y_min, y_max)

      break
    endif

  endfor

  for i = 0, n_elements(plots) - 1 do begin
    ploti = plots[i]
    ploti->select_event_indices, selected_indices
  endfor

  return, 1
end

function AnalyzeEventsHandler::MouseUp, window, x, y, button
  self.started_drag_selection = 0
  return, 1
end

function AnalyzeEventsHandler::KeyHandler, window, isASCII, character, keyvalue, x, y, press, release, keymode
  character = string(character)

  if character eq 's' or character eq 'S' and release then begin
    self.create_new_window
  endif else if character eq 'r' or character eq 'R' and release then begin
    if ptr_valid(self.plots) then begin
      plots = *self.plots

      foreach p, plots do begin
        p->reset_zoom
        p->clear_selections
      endforeach
    endif
  endif
end

pro AnalyzeEventsHandler::add_plot, the_plot

  if ptr_valid(self.plots) then new_plots = [ *self.plots, the_plot ] $
  else new_plots = [ the_plot ]

  self.plots = ptr_new(new_plots)

end

pro AnalyzeEventsHandler::create_new_window
  if ptr_valid(self.plots) then begin

    controller = *self.controller
    the_plots = *self.plots

    selected = the_plots[0]->get_selections()

    controller->show_spectra, selected
  endif
end

; The "__define" method must come last in the file; otherwise, methods will be undefined.
pro AnalyzeEventsHandler__define
  ; Initial values specified after colon must be there or there will be an error.
  ; However, the values specified are apparently ignored. array and object initializations
  ; must be repeated in the init method.
  win = { AnalyzeEventsHandler, inherits GraphicsEventAdapter, $
    controller:ptr_new(), $
    plots:ptr_new(), $
    current_plot:ptr_new(), $
    started_drag_selection:0, $
    x_start:0, $
    y_start:0 $
  }
end