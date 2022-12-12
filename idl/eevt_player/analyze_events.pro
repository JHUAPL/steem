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
;     data_dir path to the top directory that contains the input
;         data sets, which are stored in a hierarchy in IDL save-file format.
pro analyze_events, data_dir
  if data_dir eq !null then begin
    message, 'pass this procedure the directory path in which input data files are located'
  endif else if not file_test(data_dir, /directory) then begin
    message, string(format = 'data directory ''%s'' does not exist', data_dir)
  endif

  ; Ensure the directory ends with a path delimiter.
  ps = path_sep()
  if strmid(data_dir, 0, ps.length, /reverse_offset) ne ps then data_dir += ps

  load, data_dir, eevt, vals, eevt_ids

  ; This is purely for ease of use while hand-editing the call to the
  ; select procedure below. Including a dummy key-value pair in all filtering
  ; dictionaries (see below), makes it convenient to comment/uncomment lines
  ; with the various filtering criteria. If the tool were made to read in such
  ; filtering dictionaries, these dummy variables would be unnecessary.
  dummy_key = 'dummy'
  dummy_value = -1

  ; Edit this next block as desired to filter the events in different ways.
  ; lls is short for "lower limits". This specifies minimum value cuts -- only
  ; events where the specified parameter meets or exceeds the specified threshold
  ; will be kept. Similarly, uls is "upper limits", which are maximum value cuts.
  ;
  ; You can include as many distinct data field names in these filter dictionaries
  ; as you like. The select function will look for them first in the eevt structures
  ; then in the vals structures if it doesn't find them in eevt.
  select, eevt, vals, eevt_ids $
    ;  , smoothness = 'bursty' $ ;, i_norm = 0.38, sigma_fr = 0.8 $
    , lls = dictionary( dummy_key, dummy_value $
    , 'max_sn', 200.0 $
    , 'evt_length', 20 $
    ) $
    , uls = dictionary( dummy_key, dummy_value $
    , 'alt', 1500.0 $
    )

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

  ; Uncomment one of these to get appropriate settings for your monitor. If plots
  ; are appearing on the wrong monitor, add or toggle the parameter
  ; switch_display = !true to swap which monitor it uses. max_spec
  ; controls how many spectra you can see at a time.
  ;
  ; Small display.
  ;window_settings = obj_new('WindowSettings')
  ; Medium display.
  ;window_settings = obj_new('WindowSettings', ysize = 1418 * 9 / 10, max_spec = 3)
  ; Large display.
  window_settings = obj_new('WindowSettings', ysize = 2138* 14 / 15, max_spec = 5)

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