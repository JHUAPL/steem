; Run file for the event player tool. This one shows event after event with
; spectrograms and you can step along the spectra at each point, viewing some
; number of spectra at a time. This one uses direct graphics.

; Edit these as needed. Dir should point to the directory where you have the data.
top_dir = '/Users/peachjm1/jhuapl/messenger-2022/'
dir = top_dir + 'working/input/'
load, dir, eevt, vals, eevt_ids

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

!null = fit_spectra(eevt, vals, eevt_ids)

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

; Uncomment these two lines to make all the spectrograms have the same color bar,
; covering as wide a range as necessary to show all the events.
;zmax = max(eevt.eevt.bp_low_spec, /nan, min = zmin)
;zrange = [ zmin, zmax ]

; Creates the direct graphics plotter app.
plot_events_pro, eevt, vals, eevt_ids, zrange = zrange

end
