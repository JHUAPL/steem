pro safe_close, p
  if p ne !null then begin
    psize = size(p)
    if psize[0] gt 0 then begin
      for i = 0, psize[1] - 1 do begin
        if p[i] ne !null then begin
          p[i].Delete
          obj_destroy, p[i]
          p[i] = !null
        endif
      endfor
    endif else begin
      p.Delete
      obj_destroy, p
    endelse
    p = !null
  endif
end