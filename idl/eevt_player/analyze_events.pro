
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

;zmax = max(eevt.eevt.bp_low_spec, /nan, min = zmin)
;zrange = [ zmin, zmax ]

row_index = -1
num_rows = 3

win_index = 0

; MacBook.
;mon_index = 0
;ysize = 1028 * 9 / 10

; Home monitor.
;mon_index = 1
;ysize = 1418 * 9 / 10

; APL monitor.
mon_index = 1
ysize = 2138 * 14 / 15

display_scatter = !true

title = string(FORMAT = "E.E. Events %d", win_index)
if display_scatter then begin
  win = create_win(mon_index, win_index, xsize = xsize, ysize = ysize, title = title, handler = handler)
endif else begin
  !null = create_win_pro(mon_index, win_index, xsize = xsize, ysize = ysize, title = title)
endelse

use_objects = !true

if use_objects then begin
  smooth_v_sn = obj_new('GlobalPropertyDisplay')
  alt_v_sn = obj_new('GlobalPropertyDisplay')
  alt_v_smooth = obj_new('GlobalPropertyDisplay')

  smooth_v_sn->display, top_dir, eevt, vals, eevt_ids, 'sn_tot_norm2', 'sm_ness_all2', $
    row_index = ++row_index, num_rows = num_rows, ysize = ysize, $
    display_scatter = display_scatter

  alt_v_sn->display, top_dir, eevt, vals, eevt_ids, 'sn_tot_norm2', 'alt', $
    row_index = ++row_index, num_rows = num_rows, ysize = ysize, $
    display_scatter = display_scatter

  alt_v_smooth->display, top_dir, eevt, vals, eevt_ids, 'sm_ness_all2', 'alt', $
    row_index = ++row_index, num_rows = num_rows, ysize = ysize, $
    display_scatter = display_scatter

  handler->add_plot, smooth_v_sn
  handler->add_plot, alt_v_sn
  handler->add_plot, alt_v_smooth

endif else begin

  display_global_properties, top_dir, eevt, vals, eevt_ids, 'sn_tot_norm2', 'sm_ness_all2', $
    mon_index = mon_index, row_index = ++row_index, num_rows = num_rows, ysize = ysize, $
    display_scatter = display_scatter

  display_global_properties, top_dir, eevt, vals, eevt_ids, 'sn_tot_norm2', 'alt', $
    mon_index = mon_index, row_index = ++row_index, num_rows = num_rows, ysize = ysize, $
    display_scatter = display_scatter

  display_global_properties, top_dir, eevt, vals, eevt_ids, 'sm_ness_all2', 'alt', $
    mon_index = mon_index, row_index = ++row_index, num_rows = num_rows, ysize = ysize, $
    display_scatter = display_scatter

endelse

end