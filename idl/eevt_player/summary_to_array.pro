function summary_to_array, summary

  f0 = 0.0
  d0 = double(0.0)

  summary_struct = { $
    evt_length:f0, $
    sn_tot:f0, $
    sn_tot_norm:f0, $
    sn_tot_norm2:f0, $
    lat:f0, $
    lon:f0, $
    alt:f0, $
    localt:f0, $
    sun_dist:f0, $
    beta_ang:f0, $
    jday:d0, $
    velr:f0, $
    max_sn:f0, $
    sm_ness_all:f0, $
    sm_ness_all2:f0, $
    power_frac:fltarr(5), $
    met:0L, $
    tpos:dblarr(3), $
    input_file:'', $
    file_creation:[ '' ] $
  }

  array_size = size(summary.(0))

  array_size = array_size[1]

  array = replicate(summary_struct, array_size)

  for i = 0, array_size - 1 do begin
    array(i).evt_length = summary.evt_length(i)
    array(i).sn_tot = summary.sn_tot(i)
    array(i).sn_tot_norm = summary.sn_tot_norm(i)
    array(i).sn_tot_norm2 = summary.sn_tot_norm2(i)
    array(i).lat = summary.lat(i)
    array(i).lon = summary.lon(i)
    array(i).alt = summary.alt(i)
    array(i).localt = summary.localt(i)
    array(i).sun_dist = summary.sun_dist(i)
    array(i).beta_ang = summary.beta_ang(i)
    array(i).jday = summary.jday(i)
    array(i).velr = summary.velr(i)
    array(i).max_sn = summary.max_sn(i)
    array(i).sm_ness_all = summary.sm_ness_all(i)
    array(i).sm_ness_all2 = summary.sm_ness_all2(i)
    array(i).power_frac = summary.power_frac(*, i)
    array(i).met = summary.met(i)
    array(i).tpos = summary.tpos(*, i)
    array(i).input_file = summary.input_file
    array(i).file_creation = summary.file_creation
  endfor

  return, array
end