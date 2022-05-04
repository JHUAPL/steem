pro standard_plot,hershey=hershey,char=char

  if not keyword_set(char) then $
    char = 1.9

  if keyword_set(hershey) then begin
    !p.font=-1
    !p.charsize=1.7
    !xtitle='!6'
    !x.thick=5
    !y.thick=5
  endif else begin
    !p.font=1
    ; Do this elsewhere to prevent a window from being started at this step.
    ;    device,set_font='Helvetica Bold',/tt_font
    !p.charsize=char
    !x.thick=5
    !y.thick=5
  endelse


end
