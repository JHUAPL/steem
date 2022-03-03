
dir = '/Users/peachjm1/jhuapl/messenger-2022/working/input/'

load, dir, eevt, vals

value = -1

select, eevt, vals $
  ;  , smoothness = 'bursty' $ ;, i_norm = 0.38, sigma_fr = 0.8 $
  , lls = dictionary( 'parameter', value $
  , 'max_sn', 200.0 $
  , 'evt_length', 20 $
  )

; MacBook.
;plot_events_pro, eevt, vals, max_spec_per_step = 3, max_windows = 32, mon_index = 0, ysize = 1028 * 7 / 8

; Home monitor.
;plot_events_pro, eevt, vals, max_spec_per_step = 3, max_windows = 32, mon_index = 1, ysize = 1418 * 7 / 8

; APL monitor.
plot_events, eevt, vals, max_spec_per_step = 4, max_windows = 32, mon_index = 1, ysize = 2138 * 7 / 8

end