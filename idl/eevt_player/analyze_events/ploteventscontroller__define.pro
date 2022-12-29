; This class encapsulates a set of top-level controller functionality for plotting
; a selection of individual events in detail: spectrograms, "light curves" and spectra.

; Initialize a controller class instance. Events, ancillary data and the selected
; event identifiers are set when the object instance is constructed, and are never
; changed thereafter.
;
; Parameters:
;   eevt primary structure containing 3 arrays with event data
;   vals ancillary data structure containing 1 array
;   eevt_ids 1-d array of integer event identifiers
;   fit_params 2-d array of fit parameters
;
function PlotEventsController::init, eevt, vals, eevt_ids, fit_params, $
  window_settings = window_settings

  self.eevt = ptr_new(eevt)
  self.vals = ptr_new(vals)
  self.eevt_ids = ptr_new(eevt_ids)
  self.fit_params = ptr_new(fit_params)
  self.handler = ptr_new(obj_new('PlotEventsHandler', self))

  if not keyword_set(window_settings) then $
    window_settings = obj_new('WindowSettings')

  self.window_settings = ptr_new(window_settings)

  self.plot_window = ptr_new(obj_new('PlotEventsWindow', self, window_settings = window_settings))

  return, 1
end

pro PlotEventsController::show_plots, event_index = event_index

  eevt = *self.eevt
  vals = *self.vals
  eevt_ids = *self.eevt_ids
  fit_params = *self.fit_params
  handler = *self.handler
  window_settings = *self.window_settings
  plot_window = *self.plot_window

  if not keyword_set(event_index) then event_index = 0

  if n_elements(eevt_ids) eq 0 then return

  if event_index lt 0 then event_index = 0
  if event_index ge n_elements(eevt_ids) then event_index = n_elements(eevt_ids) - 1

  self.event_index = event_index

  eevt_id = String(format = '%d', eevt_ids[event_index])
  title = 'Event ' + eevt_id

  this_eevt = eevt[event_index, *]
  this_fit = *fit_params[event_index]

  plot_window.set_title, title
  self.plot_event, this_eevt, this_fit

end

pro PlotEventsController::plot_event, this_eevt, this_fit
  plot_window = *self.plot_window

  eevt_len = this_eevt[0].eevt.evt_length

  jday = this_eevt[0:eevt_len - 1].hk.jday

  num_chan = 64
  chan_index = findgen(num_chan)

  ; Time step index where background spectrum is found in each event.
  back_spec_idx = 60

  ; Channel indices that determine the range for spectra to
  ; agree with the background spectrum. This is used to scale the spectra.
  first_back_chan = 50
  last_back_chan = 60

  bp_low_spec = transpose(this_eevt[0:eevt_len - 1].eevt.bp_low_spec)
  event_back_spec = this_eevt[back_spec_idx].eevt.bp_low_spec

  this_back_spec = make_array(eevt_len, num_chan, /float)
  bp_diff_spec = make_array(eevt_len, num_chan, /float)

  for i = 0, eevt_len - 1 do begin
    scale_factor = this_fit[i, 2]
    this_back_spec[i, *]  = scale_factor * event_back_spec
    bp_diff_spec[i, *] = bp_low_spec[i, *] - this_back_spec[i, *]
  endfor

  alt = this_eevt[0:eevt_len - 1].eph.alt
  bp_low = this_eevt[0:eevt_len-1].eevt.bp_low

  plot_window.update_event, jday, chan_index, $
    bp_low_spec, this_back_spec, bp_diff_spec, $
    alt, bp_low, fit_param = this_fit

  spec0_index = 0
  plot_window.update_spectra, spec0_index, force_update = !true

  plot_window.refresh_window
end

pro PlotEventsController::next_event
  eevt_ids  = *self.eevt_ids
  if self.event_index lt n_elements(eevt_ids) - 1 then begin
    event_index = self.event_index + 1
    self.show_plots, event_index = event_index
  endif
end

pro PlotEventsController::previous_event
  if self.event_index gt 0 then begin
    event_index = self.event_index - 1
    self.show_plots, event_index = event_index
  endif
end

; Controller class definition.
;
pro PlotEventsController__define
  !null = { $
    PlotEventsController, $
    eevt:ptr_new(), $
    vals:ptr_new(), $
    eevt_ids:ptr_new(), $
    fit_params:ptr_new(), $
    event_index:0, $
    handler:ptr_new(), $
    window_settings:ptr_new(), $
    plot_window:ptr_new() $
  }
end
