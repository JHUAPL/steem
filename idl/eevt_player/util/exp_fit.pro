function exp_fit, xin, yin, yfit = yfit
  common exp_fit, suppress_output

  if not keyword_set(suppress_output) then suppress_output = !false

  param = [ !values.f_nan, !values.f_nan ]

  qx = where(xin gt 0, nqx)
  if nqx lt 2 then begin
    if not suppress_output then begin
      message,'There are not enough non-zero X values!', /continue
    endif
    return, param
  endif

  x = xin[qx]
  y = yin[qx]

  qy = where(y gt 0, nqy)
  if nqy lt 2 then begin
    if not suppress_output then begin
      message,'There are not enough non-zero Y values!', /continue
    endif
    return, param
  endif

  x = x[qy]
  y = y[qy]

  ylog = alog(y)

  param_tmp = linfit(x, ylog)
  if finite(param_tmp[0]) then begin
    param[0] = float(exp(param_tmp[0]))

    ; If slope is nan, just fall through (param[1] is already nan).
    if not finite(param_tmp[1], /nan) then begin
      ; Slope is not nan, but may not be finite.
      if finite(param_tmp[1]) then begin
        ; Slope is finite, but may be 0.0.
        if param_tmp[1] ne 0.0 then begin
          ; Slope is well-behaved, stick 1 / slope in param[1]
          param[1] = float(1.0 / param_tmp[1])
          yfit = exp(poly(x, param_tmp))
        endif else begin
          ; Slope is 0.0, so 1 / slope is infinity.
          param[1] = !values.f_infinity
        endelse
      endif else begin
        ; Slope is infinity, so 1 / slope is 0.0.
        param[1] = float(0.0)
      endelse
    endif
  endif

  return, param
end