function to_string, data
  size_info = size(data)
  s = '?'
  if size_info[0] eq 0 then begin
    if size_info[1] eq 7 then s = data $
    else if size_info[1] eq 4 or size_info[1] eq 5 then s = string(format = '%0.2f', data) $
    else if size_info[1] eq 2 or size_info[1] eq 3 then s = string(format = '%d', data)
  endif else if size_info[0] eq 1 then begin
    delim = ''
    s = '[ '
    for i = 0, size_info[1] - 1 do begin
      s += delim
      s += to_string(data[i])
      delim = ', '
    endfor
    s += ' ]'
  endif

  return, s
end

pro select, eevt, vals, eevt_ids, date = date, $
  smoothness = smoothness, i_norm = i_norm, sigma_fr = sigma_fr, $
  sn_max_ll = sn_max_ll, $
  evt_length_ll = evt_length_ll, evt_length_ul = evt_length_ul, $
  lls = lls, uls = uls

  num_events = size(eevt)
  num_events = num_events[1]

  print, 'Select procedure called with ', num_events, ' events'
  if eevt eq !null then return
  if vals eq !null then return
  if eevt_ids eq !null then return

  ; Date selection.
  if keyword_set(date) then begin
    arg_size = size(date)

    ; Single scalar date.
    if arg_size[0] eq 0 then begin
      d = strsplit(date, '-', /extract)
      jd = julday(d[1], d[2], d[0])

      indices = where(floor(eevt[*,0].hk.jday) eq jd, /null)

      eevt = eevt[indices, *]
      vals = vals[indices, *]
      eevt_ids = eevt_ids[indices]
    endif else begin
      print, 'TODO: implement selection of a range of dates.'
    endelse

    print, format = 'After date cut, %d events remain', num_events
  endif

  ; Smoothness thresholds.
  if not keyword_set(i_norm) then i_norm = 0.38
  if not keyword_set(sigma_fr) then sigma_fr = 0.8

  ; Smoothness selection: smooth or bursty.
  if keyword_set(smoothness) then begin

    i_norm_array = vals.sn_tot_norm2
    sigma_array = vals.sm_ness_all2

    if smoothness eq 'smooth' then begin
      print, format = 'Keeping %s events only: i_norm > %0.3f and sigma_fr < %0.3f', smoothness, i_norm, sigma_fr
      indices = where(i_norm_array gt i_norm and sigma_array lt sigma_fr, /null)

      eevt = eevt[indices, *]
      vals = vals[indices, *]
      eevt_ids = eevt_ids[indices]
    endif else if smoothness eq 'bursty' then begin
      print, format = 'Keeping %s events only: i_norm <= %0.3f or sigma_fr >= %0.3f', smoothness, i_norm, sigma_fr
      indices = where(i_norm_array le i_norm or sigma_array ge sigma_fr, /null)

      eevt = eevt[indices, *]
      vals = vals[indices, *]
      eevt_ids = eevt_ids[indices]
    endif else begin
      print, format = 'Ignoring selection parameter smoothness = ''%s'', must be either ''smooth'' or ''bursty''', smoothness
    endelse

    num_events = size(eevt)
    num_events = num_events[1]

    print, format = 'Kept %d (%s) events.', num_events, smoothness
  endif

  ; S/N max lower limit.
  if keyword_set(sn_max_ll) then begin
    sn_max = max(eevt.eevt.sn,dim=2)

    indices = where(sn_max ge sn_max_ll, /null)

    eevt = eevt[indices, *]
    vals = vals[indices, *]
    eevt_ids = eevt_ids[indices]

    num_events = size(eevt)
    num_events = num_events[1]

    print, format = 'After S/N max low cut there remain %d events', num_events
  endif

  ; Lower limits (lls)
  fp_format = '%0.2f'
  if keyword_set(lls) then begin
    foreach limits, lls, field_name do begin

      if limits eq !null then continue

      array = extract_array0(eevt, vals, field_name)

      if array ne !null then begin
        indices = where(array ge limits, /null)

        eevt = eevt[indices, *]
        vals = vals[indices, *]
        eevt_ids = eevt_ids[indices]

        num_events = size(eevt)
        num_events = num_events[1]

        print, format = 'After cutting events with %s < %s, %d events remain.', field_name, to_string(limits), num_events
      endif else if field_name ne 'parameter' then begin
        print, format = 'Could not find field %s to perform a low cut', field_name
      endif

    endforeach

  endif

  ; Upper limits (uls)
  fp_format = '%0.2f'
  if keyword_set(uls) then begin
    foreach limits, uls, field_name do begin

      if limits eq !null then continue

      array = extract_array0(eevt, vals, field_name)

      if array ne !null then begin
        indices = where(array lt limits, /null)

        eevt = eevt[indices, *]
        vals = vals[indices, *]
        eevt_ids = eevt_ids[indices]

        num_events = size(eevt)
        num_events = num_events[1]

        print, format = 'After cutting events with %s < %s, %d events remain.', field_name, to_string(limits), num_events
      endif else begin
        print, format = 'Could not find field %s to perform a low cut', field_name
      endelse

    endforeach

  endif


  ;  ; evt_length lower limit.
  ;  if keyword_set(evt_length_ll) then begin
  ;    indices = where(eevt[*, 0].eevt.evt_length ge evt_length_ll, /null)
  ;
  ;    eevt = eevt[indices, *]
  ;    vals = vals[indices, *]
  ;    eevt_ids = eevt_ids[indices]
  ;
  ;    num_events = size(eevt)
  ;    num_events = num_events[1]
  ;
  ;    print, format = 'After event length low cut there remain %d events', num_events
  ;  endif
  ;
  ;  ; evt_length upper limit.
  ;  if keyword_set(evt_length_ul) then begin
  ;    indices = where(eevt[*, 0].eevt.evt_length lt evt_length_ul, /null)
  ;
  ;    eevt = eevt[indices, *]
  ;    vals = vals[indices, *]
  ;    eevt_ids = eevt_ids[indices]
  ;
  ;    num_events = size(eevt)
  ;    num_events = num_events[1]
  ;
  ;    print, format = 'After event length high cut there remain %d events', num_events
  ;  endif
  ;
end
