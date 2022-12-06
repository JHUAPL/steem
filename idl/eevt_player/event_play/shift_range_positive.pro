; Shift a spectrogram (not a spectrum) to have a minimum value of 1.0
; regardless of its actual minimum. This is useful for setting up the
; color bar and contour plots, not for any quantitative analysis.
function shift_range_positive, array
  offset = !null

  amin = min(array, /nan)

  if finite(amin) and amin lt 1.0 then begin
    offset = 1.0 - amin
    array += offset
  endif

  return, offset
end