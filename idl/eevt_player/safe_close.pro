pro safe_close, p
  if p ne !null then begin
    p.Delete
    obj_destroy, p
    p = !null
  endif
end