function get_levels, array, nlevels, range = range, log = log
  if not keyword_set(log) then log = !false

  asize = size(array)

  if keyword_set(range) then begin

    if range[0] gt range[1] then return, !null
    amin = range[0]
    amax = range[1]

  endif else begin

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
  endelse

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