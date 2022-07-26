; Run file for the interactive event analysis tool. This one plots events against 3
; global properties on scatter plots. The user may select one or more events by
; clicking on them (hold down space for more than one). Then type the 's" key
; (spectrogram) to spawn the event_play tool where you can drill down into spectra
; for those events. This one is partly OO in design.

; Edit these as needed. Dir should point to the directory where you have the data.
top_dir = '/Users/peachjm1/jhuapl/messenger-2022/'
dir = top_dir + 'working/input/'
load, dir, eevt, vals, eevt_ids = eevt_ids

; This is just a dummy value to go with 'parameter' below. This is just so the
; dictionary always has at least one thing in it. There is no field in the data
; called "parameter" of course.
value = -1

; Edit this next block as desired to filter the events in different ways.
; lls is short for "lower limits". This specifies minimum value cuts -- only
; events where the specified parameter meets or exceeds the specified threshold
; will be kept. Similarly, uls is "upper limits", which are maximum value cuts.
;
; You can include as many data field names in these filter dictionaries as you
; like. The select function will look for them first in the eevt structures, then
; in the vals structures if it doesn't find them in eevt.
select, eevt, vals, eevt_ids $
  ;  , smoothness = 'bursty' $ ;, i_norm = 0.38, sigma_fr = 0.8 $
  , lls = dictionary( 'parameter', value $
  , 'max_sn', 200.0 $
  , 'evt_length', 20 $
  ;  , 'alt', 4000.0 $
  ) $
  , uls = dictionary( 'parameter' , value $
  )

fit_spectra, eevt, vals, eevt_ids

; Uncomment one of these to get the right settings for your monitor. If plots
; are appearing on the wrong monitor, add or toggle the parameter
; switch_display = !true and it should swap which monitor it uses. max_spec
; controls how many spectra you can see at a time.
;
; Small display.
;window_settings = obj_new('WindowSettings')
; Medium display.
;window_settings = obj_new('WindowSettings', ysize = 1418 * 9 / 10, max_spec = 3)
; Large display.
window_settings = obj_new('WindowSettings', ysize = 2138* 14 / 15, max_spec = 5)

; This is a work in progress -- eventually this will be the heart of how
; all the plots are managed and talk to each other. For now, just need it here.
controller = obj_new('AnalyzeEventsController', eevt, vals, eevt_ids)

handler = obj_new('AnalyzeEventsHandler', controller)

; Make a new window in which to show the events for this analysis. This has
; an output keyword handler -- that is the object that handles events in the
; window. The plots need to interact with that.
win_index = 0
title = string(FORMAT = "E.E. Events %d", win_index)
win = window_settings.create_win(title = title, handler = handler)

; Create property display objects for each of the plots to be created below.
smooth_v_sn = obj_new('GlobalPropertyDisplay', controller)
alt_v_sn = obj_new('GlobalPropertyDisplay', controller)
alt_v_smooth = obj_new('GlobalPropertyDisplay', controller)

; The current row index, used to lay out plots.
row_index = -1
; The number of plot panels in this window.
num_rows = 3

; Create the three plots
smooth_v_sn->display, eevt, vals, eevt_ids, 'sn_tot_norm2', 'sm_ness_all2', $
  row_index = ++row_index, num_rows = num_rows

alt_v_sn->display, eevt, vals, eevt_ids, 'sn_tot_norm2', 'alt', $
  row_index = ++row_index, num_rows = num_rows

alt_v_smooth->display, eevt, vals, eevt_ids, 'sm_ness_all2', 'alt', $
  row_index = ++row_index, num_rows = num_rows

; Tell the event handler about all the plots so it can interact with them.
handler->add_plot, smooth_v_sn
handler->add_plot, alt_v_sn
handler->add_plot, alt_v_smooth

end
