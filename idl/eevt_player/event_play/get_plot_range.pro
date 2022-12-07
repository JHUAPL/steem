; Compute good plotting ranges for an array, for both linear and logarithmic
; plotting contexts. The linear range will be [ min - delta, max + delta ],
; where min and max are the min and max values in the array, and delta is
; an amount of padding that should nicely frame whatever data are in the
; array.
;
; The logarithmic range is computed in a similar way, except that only
; positive values are considered when computing the min and max. Moreover,
; the padding is determined and applied based on the logarithm of the
; range min and max.
;
; The optional index_min and index_max arguments give the caller the ability
; to restrict the range of array values considered. This was introduced with
; 1-d arrays in mind. It will still function on 2-d arrays but in that case
; it makes use of IDL's implicit conversion of a single index to multiple
; indices, which may not be what the caller intended.
;
; For both linear and logarithmic ranges, only finite array values are
; considered.
;
; This procedure always sets both arrays to have two distinct finite ranges.
;
; @param array the input array
; @param lin_range the output linear range of the array
; @param log_range the output logarithmic range of the array
; @param index_min optional keyword with lower limit for array indices
; @param index_max optional keyword with jpper limit for array indices
;
pro get_plot_range, array, lin_range, log_range, index_min = index_min, index_max = index_max
  if not keyword_set(index_min) then index_min = 0

  if not keyword_set(index_max) then index_max = array.length - 1 $
  else if index_max ge array.length then index_max = array.length - 1

  lin_min = 0.0
  lin_max = 0.0

  log_min = 1.0
  log_max = 1.0

  for i = index_min, index_max do begin

    value = array[i]

    if finite(value) then begin

      if lin_min gt value then lin_min = value
      if lin_max lt value then lin_max = value

      if value gt 0.0 then begin

        if log_min gt value then log_min = value
        if log_max lt value then log_max = value

      endif

    endif

  endfor
  ; Invariants at this point:
  ;   lin_min <= lin_max
  ;   0.0 < log_min <= log_max

  padding = 0.05

  ; Linear output array.
  delta = (lin_max - lin_min) * padding
  if delta eq 0.0 then delta = lin_min * padding
  if delta eq 0.0 then delta = padding

  lin_min -= delta
  lin_max += delta

  lin_range = [ lin_min, lin_max ]

  ; Logarithmic output array.
  log_min = alog(log_min)
  log_max = alog(log_max)

  delta = (log_max - log_min) * padding
  if delta eq 0.0 then delta = log_min * padding
  if delta eq 0.0 then delta = padding

  log_min -= delta
  log_max += delta

  log_min = exp(log_min)
  log_max = exp(log_max)

  log_range = [ log_min, log_max ]

end