; Main procedure to launch the interactive event analysis tool. This tool
; displays events on scatter plots to show how the event population is
; distributed as a function of three parameters:
;
;  1. The magnitude-normalized time integral, Inorm. This is the first
;     EE event classification parameter defined in secion 5.1.
;  2. The standard deviation of the signal-to-noise filter ratio,
;     SIGMAfilter ratio. this is the second EE event classification
;     parameter defined in section 5.1.
;  3. The altitude of the spacecraft.
;
; The user may use IDL's built-in tools to zoom and pan to view the
; events as functions of pairs of the above three parameters. The user may
; also select one or more events by clicking on them (holding down shift
; to select multiple events). Once the desired selection is made, the user
; may type 's' or 'S' to launch a second display that allows the selected
; events to be viewed in greater detail.
;
; Parameters:
;*******************************************************************************
;     data_dir path to the top directory that contains the input data
;         sets, which are stored in a hierarchy in IDL save-file format
;
;     filters_file path to an optional file that contains filters to
;         apply to the data set while loading it
pro analyze_events, data_dir, $
  filters_file = filters_file, $
  display_id = display_id, $
  max_spec = max_spec, $
  nospec = nospec

  if data_dir eq !null then begin
    message, 'pass this procedure the directory path in which input data files are located'
  endif else if not file_test(data_dir, /directory) then begin
    message, string(format = 'data directory ''%s'' does not exist', data_dir)
  endif

  load, data_dir, eevt, vals, eevt_ids

  if keyword_set(filters_file) then load_filters, filters_file, lls, uls
  if not keyword_set(display_id) then display_id = 0
  if not keyword_set(max_spec) then max_spec = 0

  if keyword_set(nospec) then begin
    max_spec = 0
  endif else begin
    if max_spec lt 1 then max_spec = 1
  endelse

  select, eevt, vals, eevt_ids, lls = lls, uls = uls
  ;  select, eevt, vals, eevt_ids, lls = lls, uls = uls $
  ;  , smoothness = 'bursty' $ ;, i_norm = 0.38, sigma_fr = 0.8 $

  ; Compute the fit parameters for all the spectra, returning them in an array
  ; of size N, where N is the number of selected events in eevt_ids. Each event
  ; has`a background spectrum as well as a variable number M of measured spectra has`a
  ; has`a at subsequent event time-steps in the event. The array returned by the has`a
  ; has`a contains pointers, each of which points to a 2-d array of size M x 3. The
  ; 3 quantities associated with each spectrum are the amplitude, power-law slope
  ; (aka spectral index), and the scale factor. These are described more fully below.
  ;
  ; The fitting procedure for each of the M spectra first scales the background to
  ; match the spectrum such that the total counts in the high-energy tail of the
  ; background matches the total counts in the corresponding region of the spectrum.
  ; This scale factor is the third quantity reported. The first two quantities are
  ; the best-fit parameters of the power law determined by fitting the m-th spectrum
  ; to its scaled background spectrum.
  ;
  ; The spectral index is also punched into the eevt.eevt.exp_fac field of the
  ; structure for each event chosen in the eevt_ids array.
  fit_params = fit_spectra(eevt, vals, eevt_ids)

  window_settings = obj_new('WindowSettings', display_id, max_spec)

  ; This is the heart of how all individual events are plotted.
  controller = obj_new('AnalyzeEventsController', eevt, vals, eevt_ids, fit_params, $
    window_settings = window_settings)

  handler = obj_new('AnalyzeEventsHandler', controller)

  ; Make a new window in which to show the events for this analysis. The 'handler'
  ; handles mouse and keyboard events that are dispatched through the IDL window.
  title = 'E.E. Events'
  win = window_settings.create_win(title = title, handler = handler)

  ; Create property display objects for each of the plots to be created below.
  smooth_v_sn = obj_new('GlobalPropertyDisplay', controller)
  alt_v_sn = obj_new('GlobalPropertyDisplay', controller)
  alt_v_smooth = obj_new('GlobalPropertyDisplay', controller)

  ; The current row index, used to lay out plots.
  row_index = 0
  ; The number of plot panels in this window.
  num_rows = 3

  ; Create the three plots.
  smooth_v_sn->display, eevt, vals, eevt_ids, 'sn_tot_norm2', 'sm_ness_all2', $
    row_index = row_index++, num_rows = num_rows

  alt_v_sn->display, eevt, vals, eevt_ids, 'sn_tot_norm2', 'alt', $
    row_index = row_index++, num_rows = num_rows

  alt_v_smooth->display, eevt, vals, eevt_ids, 'sm_ness_all2', 'alt', $
    row_index = row_index++, num_rows = num_rows

  ; Tell the event handler about all the plots so it can interact with them.
  handler->add_plot, smooth_v_sn
  handler->add_plot, alt_v_sn
  handler->add_plot, alt_v_smooth

end
