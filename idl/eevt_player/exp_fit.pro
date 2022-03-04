function exp_fit,x0,y0,yfit=yfit

  ; rename so that this function does not
  ; change the original values
  x = x0
  y = y0

  qx = where(x gt 0,nqx)
  if nqx le 1 then begin
    ; message,'There are not enough non-zero X values!',/continue
    return,-1
  endif
  x = x[qx]
  y = y[qx]

  qy = where(y gt 0,nqy)
  if nqy le 1 then begin
    ; message,'There are not enough non-zero Y values!',/continue
    return,-1
  endif

  x = x[qy]
  y = y[qy]

  ylog = alog(y)

  param_tmp = linfit(x,ylog)
  param = param_tmp
  param[0] = exp(param[0])

  if param_tmp[1] ne 0 then param[1] = 1.0/param_tmp[1] $
  else param[1] = double("NaN")

  yfit = exp(poly(x,param_tmp))

  return,param

end

