function PlotEventHandler::init, controller
  self.controller = ptr_new(controller)
  self.plots = ptr_new()
  self.current_plot = ptr_new(/allocate)

  return, self->GraphicsEventAdapter::init()
end

function PlotEventHandler::MouseDown, window, x, y, button, keymods, clicks

  if self.plots eq !null then return, 1

  if button ne 1 then return, 1

  plots = *self.plots

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
    endif


  endif else if clicks eq 2 then begin

    for i = 0, n_elements(plots) - 1 do begin
      plots[i]->clear_selections
    endfor

    ; Return 0  here to disable the default handler from getting called.
    ; This pops up an annoying properties window.
    return, 0
  endif

  return, 1
end

function PlotEventHandler::KeyHandler, window, isASCII, character, keyvalue, x, y, press, release, keymode
  character = string(character)

  if character eq 's' or character eq 'S' and release then begin

    the_plots = *self.plots
    controller = *self.controller

    if the_plots ne !null then begin
      selected = the_plots[0]->get_selections()

      controller->show_spectra, selected
    endif

  endif
end

pro PlotEventHandler::add_plot, the_plot

  if self.plots ne !null then new_plots = [ *self.plots, the_plot ] $
  else new_plots = [ the_plot ]

  self.plots = ptr_new(new_plots)

end

; The "__define" method must come last in the file; otherwise, methods will be undefined.
pro PlotEventHandler__define
  ; Initial values specified after colon must be there or there will be an error.
  ; However, the values specified are apparently ignored. array and object initializations
  ; must be repeated in the init method.
  win = { PlotEventHandler, inherits GraphicsEventAdapter, $
    controller:ptr_new(), $
    plots:ptr_new(), $
    current_plot:ptr_new() $
  }
end