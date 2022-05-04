
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

; Small display.
;window_settings = obj_new('WindowSettings')
; Medium display.
;window_settings = obj_new('WindowSettings', ysize = 1418 * 9 / 10, max_spec = 3)
; Large display.
window_settings = obj_new('WindowSettings', ysize = 2138* 14 / 15, max_spec = 5)

plot_events_pro, eevt, vals, eevt_ids, zrange = zrange, $
  window_settings = window_settings

end