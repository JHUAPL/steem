function get_levels, array, ncolors, log = log
  if not keyword_set(log) then log = !false

  if log then begin
    amax = max(array[where(finite(array) and array gt 0.0)], /nan, min = amin)
  endif else begin
    amax = max(array[where(finite(array))], /nan, min = amin)
  endelse

  if amin eq amax then begin
    levels = [ amin ]
  endif else begin

    if log then begin
      exp = alog(amax / amin) / (ncolors - 1)

      levels = dindgen(ncolors)
      for i = 0, ncolors - 1 do begin
        levels[i] = amin * exp(i * exp)
      endfor

    endif else begin
      slope = (amax - amin) / (ncolors - 1)

      levels = dindgen(ncolors)
      for i = 0, ncolors - 1 do begin
        levels[i] = amin + slope * i
      endfor

    endelse
  endelse

  return, levels
end