pro load, dir, eevt_out, vals_out

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
end