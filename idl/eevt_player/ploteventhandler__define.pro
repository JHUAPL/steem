;function PlotEventHandler::KeyHandler, Window, IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMode
;  if Press then print,'key press'
;  if Release then print,'key release'
;end

function PlotEventHandler::MouseDown, window, x, y, button, keymods, clicks

  if button eq 1 and clicks eq 1 then begin

    if self.plots ne !null then begin

      plots = *self.plots

      point = window.ConvertCoord(x, y, /device, /to_normal)

      point = point[0:1]

      found_eevt_id = -1
      for i = 0, n_elements(plots) - 1 do begin

        found_eevt_id = plots[i]->find_closest_event(point)
        if found_eevt_id ne -1 then break
      endfor

      if found_eevt_id ne -1 then begin
        for i = 0, n_elements(plots) - 1 do begin
          selection_toggle_on = plots[i]->toggle_selection(found_eevt_id)
        endfor

        if selection_toggle_on then print, 'Selected event ', found_eevt_id $
        else print, 'De-selected event ', found_eevt_id
      endif

    endif

  endif else if button eq 1 and clicks eq 2 then begin

    if self.plots ne !null then begin
      plots = *self.plots

      for i = 0, n_elements(plots) - 1 do begin
        plots[i]->clear_selections
      endfor
    endif

    ; Return 0  here to disable the default handler from
    ; also getting called
    return, 0
  endif

  return, 1
end

pro PlotEventHandler::add_plot, the_plot

  if self.plots ne !null then new_plots = [ *self.plots, the_plot ] $
  else new_plots = [ the_plot ]

  self.plots = ptr_new(new_plots)

end

function PlotEventHandler::init
  self.plots = ptr_new()
  self.just_selected = !false

  return, self->GraphicsEventAdapter::init()
end

; The "__define" method must come last in the file; otherwise, methods will be undefined.
pro PlotEventHandler__define
  ; Initial values specified after colon must be there or there will be an error.
  ; However, the values specified are apparently ignored. array and object initializations
  ; must be repeated in the init method.
  win = { PlotEventHandler, inherits GraphicsEventAdapter, plots:ptr_new(), just_selected:!false }
end