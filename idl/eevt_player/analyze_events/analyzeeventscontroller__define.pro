; This class encapsulates a set of top-level controller functionality for analyzing events.

; Initialize a controller class instance.Events, ancillary values and the event identifiers
; are set when the object instance is constructed, and are never changed thereafter.
;
; Parameters:
;   eevt primary structure containing 3 arrays with event data
;   vals ancillary data structure containing 1 array
;   eevt_ids 1-d array of integer event identifiers
;   fit_params 2-d array of fit parameters
;
function AnalyzeEventsController::init, eevt, vals, eevt_ids, fit_params, $
  window_settings = window_settings

  self.eevt = ptr_new(eevt)
  self.vals = ptr_new(vals)
  self.eevt_ids = ptr_new(eevt_ids)
  self.fit_params = ptr_new(fit_params)

  if not keyword_set(window_settings) then $
    window_settings = ptr_new(obj_new('WindowSettings'))

  self.window_settings = window_settings

  return, 1
end

; Create and show a new view of spectra for the specified selection of event identifiers.
;
; Parameters:
;   selected_ids 1-d array of integer event identifiers that specify which events to show
;
pro AnalyzeEventsController::show_spectra, selected_ids

  if selected_ids eq !null then return

  ; Get local references to this object's properties.
  eevt = *self.eevt
  vals = *self.vals
  eevt_ids = *self.eevt_ids
  fit_params = *self.fit_params
  window_settings = *self.window_settings

  ; Create a list of indices filtered based on the events matching the specified selection.
  indices = where(eevt_ids eq selected_ids[0])
  for i = 1, n_elements(selected_ids) - 1 do begin
    indices = [ indices, where(eevt_ids eq selected_ids[i]) ]
  endfor
  indices = indices[where(indices ne -1)]

  ; Apply index filter to the data objects.
  eevt = eevt[indices, *]
  vals = vals[indices]
  eevt_ids = eevt_ids[indices]
  fit_params = fit_params[indices]

  ;zmax = max(eevt.eevt.bp_low_spec, /nan, min = zmin)
  ;zrange = [ zmin, zmax ]

  ; plot_events_pro, eevt, vals, eevt_ids, zrange = zrange
  controller = obj_new('PlotEventsController', eevt, vals, eevt_ids, fit_params, $
    window_settings = ptr_new(window_settings))

  controller->show_plots
end

; Controller class definition.
;
pro AnalyzeEventsController__define
  !null = { $
    AnalyzeEventsController, $
    eevt:ptr_new(), $
    vals:ptr_new(), $
    eevt_ids:ptr_new(), $
    fit_params:ptr_new(), $
    window_settings:ptr_new() $
  }
end
