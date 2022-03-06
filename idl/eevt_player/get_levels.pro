function get_levels, array, nlevels, log = log
  if not keyword_set(log) then log = !false

  asize = size(array)

  amax = -1.0d308
  amin = +1.0d308

  if asize[0] eq 1 then begin
    this_array = array

    if log then begin
      tmpmax = max(this_array[where(finite(this_array) and this_array gt 0.0)], /nan, min = tmpmin)
    endif else begin
      tmpmax = max(this_array[where(finite(this_array))], /nan, min = tmpmin)
    endelse

    amax = max([ amax, tmpmax ])
    amin = min([ amin, tmpmin ])

  endif else if asize[0] eq 2 then begin

    for i = 0, asize[1] - 1 do begin
      this_array = array[i, *]

      if log then begin
        tmpmax = max(this_array[where(finite(this_array) and this_array gt 0.0)], /nan, min = tmpmin)
      endif else begin
        tmpmax = max(this_array[where(finite(this_array))], /nan, min = tmpmin)
      endelse

      amax = max([ amax, tmpmax ])
      amin = min([ amin, tmpmin ])

    endfor

  endif

  if amin eq amax then begin
    levels = [ amin ]
  endif else begin
    if log then begin
      exp = alog(amax / amin) / (nlevels - 1)

      levels = dindgen(nlevels)
      for i = 0, nlevels - 1 do begin
        levels[i] = amin * exp(i * exp)
      endfor

    endif else begin
      slope = (amax - amin) / (nlevels - 1)

      levels = dindgen(nlevels)
      for i = 0, nlevels - 1 do begin
        levels[i] = amin + slope * i
      endfor

    endelse
  endelse

  return, levels
end