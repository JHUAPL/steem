pro convert_to_spectrogram, xin, yin, eevt_ids, $
  xout = x, yout = y, zout = z, $
  xrange = xrange, yrange = yrange, zrange = zrange

  if xin.length ne yin.length then print, 'Error: input arrays must have same number of elements'

  numx = xin.length
  numy = yin.length

  xmin = min(xin, /nan, max = xmax)
  if xmin eq xmax then print, 'Error: x values are all the same'

  ymin = min(yin, /nan, max = ymax)
  if ymin eq ymax then print, 'Error: y values are all the same'

  ; Tweak the limits for the ranges.
  if xmin lt 0.0 then xmin *= 1.01 $
  else if xmin gt 0.0 then xmin *= 0.99 $
  else xmin = -xmax * 0.01

  if xmax lt 0.0 then xmax *= 0.99 $
  else if xmax gt 0.0 then xmax *= 1.01 $
  else xmax = -xmin * 0.01

  if ymin lt 0.0 then ymin *= 1.01 $
  else if ymin gt 0.0 then ymin *= 0.99 $
  else ymin = -ymax * 0.01

  if ymax lt 0.0 then ymax *= 0.99 $
  else if ymax gt 0.0 then ymax *= 1.01 $
  else ymax = -ymin * 0.01

  xrange = [ xmin, xmax ]
  yrange = [ ymin, ymax ]

  z = make_array(dimension = [ numx, numy ], /double, value = 0.0)

  xindices = sort(xin)
  yindices = sort(yin)

  x = xin[xindices]
  y = yin[yindices]

  uniq = 0
  ; Iterate over sorted x range.
  for xindex = 0, xindices.length - 1 do begin
    ; Find the associated index that is valid for xin.
    i = xindices[xindex]

    ; Iterate over sorted y range.
    for yindex = 0, yindices.length - 1 do begin
      ; Find the associated index valid for yin.
      j = yindices[yindex]

      if i eq j then begin
        ; This position in the output index space corresponds to a valid [ x, y ] pair
        ; in the input index space.
        ; Mark this position in the output index space.
        z[xindex, yindex] = eevt_ids[i]
      endif
    endfor
  endfor

  zmin = min(z, /nan, max = zmax)
  if zmin eq zmax then print, 'Error: z values are all the same'

  ;  if zmin lt 0.0 then zmin *= 1.01 $
  ;  else if zmin gt 0.0 then zmin *= 0.99 $
  ;  else zmin = -zmax * 0.01
  ;
  ;  if zmax lt 0.0 then zmax *= 0.99 $
  ;  else if zmax gt 0.0 then zmax *= 1.01 $
  ;  else zmax = -zmin * 0.01

  zrange = [ zmin, zmax ]
end