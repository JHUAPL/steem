

top_dir = '/Users/peachjm1/jhuapl/messenger-2022/'

dir = top_dir + 'working/input/'

load, dir, eevt, vals, eevt_ids = eevt_ids

value = -1

select, eevt, vals, eevt_ids $
  ;  , smoothness = 'bursty' $ ;, i_norm = 0.38, sigma_fr = 0.8 $
  , lls = dictionary( 'parameter', value $
  , 'max_sn', 200.0 $
  , 'evt_length', 20 $
  ;  , 'alt', 4000.0 $
  )

controller = obj_new('AnalyzeEventsController', eevt, vals, eevt_ids)

;zmax = max(eevt.eevt.bp_low_spec, /nan, min = zmin)
;zrange = [ zmin, zmax ]

row_index = -1
num_rows = 3

win_index = 0

; Small display.
;window_settings = obj_new('WindowSettings')
; Medium display.
;window_settings = obj_new('WindowSettings', ysize = 1418 * 9 / 10, max_spec = 3)
; Large display.
window_settings = obj_new('WindowSettings', ysize = 2138* 14 / 15, max_spec = 5)

display_scatter = !true

title = string(FORMAT = "E.E. Events %d", win_index)
if display_scatter then begin
  win = create_win(controller, win_index, title = title, handler = handler, window_settings = window_settings)
endif else begin
  !null = create_win_pro(win_index, title = title, window_settings = window_settings)
endelse

use_objects = !true

if use_objects then begin

  smooth_v_sn = obj_new('GlobalPropertyDisplay', controller)
  alt_v_sn = obj_new('GlobalPropertyDisplay', controller)
  alt_v_smooth = obj_new('GlobalPropertyDisplay', controller)

  smooth_v_sn->display, top_dir, eevt, vals, eevt_ids, 'sn_tot_norm2', 'sm_ness_all2', $
    row_index = ++row_index, num_rows = num_rows, $
    display_scatter = display_scatter, window_settings = window_settings

  alt_v_sn->display, top_dir, eevt, vals, eevt_ids, 'sn_tot_norm2', 'alt', $
    row_index = ++row_index, num_rows = num_rows, $
    display_scatter = display_scatter, window_settings = window_settings

  alt_v_smooth->display, top_dir, eevt, vals, eevt_ids, 'sm_ness_all2', 'alt', $
    row_index = ++row_index, num_rows = num_rows, $
    display_scatter = display_scatter, window_settings = window_settings

  handler->add_plot, smooth_v_sn
  handler->add_plot, alt_v_sn
  handler->add_plot, alt_v_smooth

endif else begin

  display_global_properties, top_dir, eevt, vals, eevt_ids, 'sn_tot_norm2', 'sm_ness_all2', $
    row_index = ++row_index, num_rows = num_rows, display_scatter = display_scatter, window_settings = window_settings

  display_global_properties, top_dir, eevt, vals, eevt_ids, 'sn_tot_norm2', 'alt', $
    row_index = ++row_index, num_rows = num_rows, display_scatter = display_scatter, window_settings = window_settings

  display_global_properties, top_dir, eevt, vals, eevt_ids, 'sm_ness_all2', 'alt', $
    row_index = ++row_index, num_rows = num_rows, display_scatter = display_scatter, window_settings = window_settings

endelse

end