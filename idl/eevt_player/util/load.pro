pro load, dir, eevt_out, vals_out, eevt_ids

  ; Ensure the directory ends with a path delimiter.
  ps = path_sep()
  if strmid(dir, ps.length - 1, ps.length, /reverse_offset) ne ps then dir += ps

  ; Ensure the directory ends with a path delimiter.
  ps = path_sep()
  if strmid(dir, ps.length - 1, ps.length, /reverse_offset) ne ps then dir += ps

  ; Detailed data "eevt".
  fname = 'ele_evt_12hr_orbit_2011-2012.idl'
  restore, dir+fname
  eevt_all = eevt

  fname = 'ele_evt_8hr_orbit_2012-2013.idl'
  restore, dir+fname
  eevt_all = [ eevt_all, eevt ]

  fname = 'ele_evt_8hr_orbit_2014-2015.idl'
  restore, dir+fname
  eevt_all = [ eevt_all, eevt]

  eevt_out = eevt_all

  ; Summary data "vals".
  fname = 'ele_evt_summary_12hr_orbit_2011-2012.idl'
  restore, dir+fname
  vals_all = summary_to_array(vals)

  fname = 'ele_evt_summary_8hr_orbit_2012-2013.idl'
  restore, dir+fname
  vals_all = [ vals_all, summary_to_array(vals) ]

  fname = 'ele_evt_summary_8hr_orbit_2014-2015.idl'
  restore, dir+fname
  vals_all = [ vals_all, summary_to_array(vals) ]

  vals_out = vals_all

  num_events = size(eevt_out)
  num_events = num_events[1]

  eevt_ids = indgen(num_events) + 1

end