function fit_spectra, eevt, vals, eevt_ids, first_fit_chan = first_fit_chan, last_fit_chan = last_fit_chan

  ; Channel indices that determine the range for fitting.
  if not keyword_set(first_fit_chan) then first_fit_chan = 7
  if not keyword_set(last_fit_chan) then last_fit_chan = 20

  num_chan = 64
  chan_index = findgen(num_chan)

  ; Time step index where background spectrum is found in each event.
  back_spec_idx = 60

  ; Channel indices that determine the range for spectra to
  ; agree with the background spectrum. This is used to scale the spectra.
  first_back_chan = 50
  last_back_chan = 60

  num_events = n_elements(eevt_ids)
  fit_param = ptrarr(num_events)
  for i = 0, num_events - 1 do begin
    eevt_len = eevt[i, 0].eevt.evt_length

    bp_low_spec = eevt[i, 0:(eevt_len - 1)].eevt.bp_low_spec

    this_back_spec = eevt[i, back_spec_idx].eevt.bp_low_spec

    diff_spec = make_array(eevt_len, num_chan, /float)

    this_fit = make_array(eevt_len, 3, /float)

    for j = 0, eevt_len - 1 do begin
      scale_factor = total(bp_low_spec[first_back_chan:last_back_chan, 0, j])/total(this_back_spec[first_back_chan:last_back_chan])
      diff_spec[j, *] = bp_low_spec[*, 0, j] - scale_factor * this_back_spec

      this_diff_spec = diff_spec[j, *]

      param = exp_fit(chan_index[first_fit_chan:last_fit_chan], this_diff_spec[first_fit_chan:last_fit_chan], yfit=yfit)

      eevt[i, j].eevt.exp_fac = param[1]

      this_fit[j, 0] = param[0]
      this_fit[j, 1] = param[1]
      this_fit[j, 2] = scale_factor
    endfor

    fit_param[i] = ptr_new(this_fit)

  endfor

  return, fit_param
end
