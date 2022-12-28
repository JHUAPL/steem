; This class was one of the first new graphics classes developed
; during the MESSENGER EE work. If time permits, it might make
; more sense in the current design to move its small functionality
; to other viewer/controller classes developed since this one.
;
function PlotEventsHandler::init, controller
  self.controller = ptr_new(controller)
  self.plots = ptr_new()
  self.current_plot = ptr_new(/allocate)

  return, 1
end

function PlotEventsHandler::KeyHandler, window, isASCII, character, keyvalue, x, y, press, release, keymode
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

; The "__define" method must come last in the file; otherwise, methods will be undefined.
pro PlotEventsHandler__define
  ; Initial values specified after colon must be there or there will be an error.
  ; However, the values specified are apparently ignored. array and object initializations
  ; must be repeated in the init method.
  win = { PlotEventsHandler, inherits GraphicsEventAdapter, $
    controller:ptr_new(), $
    plots:ptr_new(), $
    current_plot:ptr_new() $
  }
end
