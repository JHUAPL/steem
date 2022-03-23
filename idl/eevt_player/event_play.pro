
top_dir = '/Users/peachjm1/jhuapl/messenger-2022/'

dir = top_dir + 'working/input/'

load, dir, eevt, vals

value = -1

select, eevt, vals $
  ;  , smoothness = 'bursty' $ ;, i_norm = 0.38, sigma_fr = 0.8 $
  , lls = dictionary( 'parameter', value $
  , 'max_sn', 200.0 $
  , 'evt_length', 20 $
  )

zmax = max(eevt.eevt.bp_low_spec, /nan, min = zmin)

;zrange = [ zmin, zmax ]

; MacBook.
;plot_events_pro, top_dir, eevt, vals, zrange = zrange, max_spec_per_step = 1, max_windows = 32, mon_index = 0, ysize = 1028 * 9 / 10

; Home monitor.
plot_events_pro, top_dir, eevt, vals, zrange = zrange, max_spec_per_step = 3, max_windows = 32, mon_index = 1, xsize = 1100, ysize = 1418 * 9 / 10

; APL monitor.
;plot_events_pro, top_dir, eevt, vals, zrange = zrange, max_spec_per_step = 3, max_windows = 32, mon_index = 1, ysize = 2138 * 14 / 15

end