; Return a good plotting range of an array. If the log parameter equates to
; false, the range will be [ min - delta, max + delta ], where min and
; max are the min and max values in the array. Delta is computed in this case
; as 5% of the total range (or the central value if min == max). Thus, this
; function guarantees a little padding around the array range.
;
; If the log parameter equates to true, only positive values are considered
; when computing the min and max. Moreover, the padding is applied in log
; space.
;
; The optional index_min and index_max arguments give the caller the ability
; to consider only part of the array. This was introduced with 1-d arrays
; in mind. It will still function on 2-d arrays but in that case it makes
; use of IDL's implicit conversion of a single index to multiple indices,
; and so may not be what the caller intended.
;
; In both linear (log = false) and log = true case, only finite values are
; considered.
;
; This function always returns an array with two distinct finite elements.
;
function get_plot_range, array, log, index_min = index_min, index_max = index_max
  if not keyword_set(index_min) then index_min = 0

  if not keyword_set(index_max) then index_max = array.length - 1 $
  else if index_max ge array.length then index_max = array.length - 1

  array_min = 1.0
  array_max = 1.0

  if log then begin

    for i = index_min, index_max do begin

      value = array[i]

      if finite(value) and value gt 0.0 then begin
        if array_min gt value then array_min = value
        if array_max lt value then array_max = value
      endif

    endfor

    array_min = alog(array_min)
    array_max = alog(array_max)

  endif else begin

    for i = index_min, index_max do begin

      value = array[i]

      if finite(value) then begin
        if array_min gt value then array_min = value
        if array_max lt value then array_max = value
      endif

    endfor

  endelse

  padding = 0.05

  delta = (array_max - array_min) * padding
  if delta eq 0.0 then delta = array_min * padding
  if delta eq 0.0 then delta = padding

  array_min -= delta
  array_max += delta

  if log then begin
    array_min = exp(array_min)
    array_max = exp(array_max)
  endif

  return, [ array_min, array_max ]
end