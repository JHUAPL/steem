pro fit_spectra, eevt, vals, eevt_ids, ind_low = ind_low, ind_high = ind_high

  ; Channel indices that determine the range for fitting.
  if not keyword_set(ind_low) then ind_low = 7
  if not keyword_set(ind_high) then ind_high = 20

  ; Time step index where background spectrum is found in each event.
  last_ind = 60

  ; Channel indices that determine the range for spectra to
  ; agree with the background spectrum. This is used to scale the spectra.
  back_ind0 = 50
  back_ind1 = 60

  chan_index = findgen(64)
  num_chans = size(chan_index)

  for eevt_id = 0, n_elements(eevt_ids) - 1 do begin
    eevt_len = eevt[eevt_id, 0].eevt.evt_length

    bp_low_spec = eevt[eevt_id, 0:(eevt_len - 1)].eevt.bp_low_spec;

    this_back_spec = eevt[eevt_id, last_ind].eevt.bp_low_spec

    scale_factor = make_array(eevt_len, /float)
    diff_spec = make_array(eevt_len, num_chans[1], /float)

    for i = 0, eevt_len - 1 do begin
      scale_factor[i] = total(this_back_spec[back_ind0:back_ind1])/total(bp_low_spec[back_ind0:back_ind1, 0, i])
      diff_spec[i, *] = scale_factor[i] * bp_low_spec[*, 0, i] - this_back_spec

      this_diff_spec = diff_spec[i, *]
      diff_spec_for_fit = this_diff_spec

      param = exp_fit(chan_index[ind_low:ind_high], $
        diff_spec_for_fit[ind_low:ind_high], yfit=yfit)

      orig_param = param

      make_positive_for_fit = !false
      if make_positive_for_fit then begin
        ; Not sure about this: is it really needed, does it really help the fits?
        max_value = max(this_diff_spec[ind_low:ind_high], /nan, min=min_value)
        if min_value lt 0 then diff_spec_for_fit -= min_value - 1
      endif

      param = exp_fit(chan_index[ind_low:ind_high], $
        diff_spec_for_fit[ind_low:ind_high], yfit=yfit)

      param_valid = n_elements(param) eq 2

      if param_valid then begin
        eevt[eevt_id, i].eevt.exp_fac = param[1]
      endif else begin
        eevt[eevt_id, i].eevt.exp_fac = !values.d_nan
      endelse

    endfor
  endfor

end
