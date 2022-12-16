pro set_up_color_table, file

  ; loadt special color table
  restore,file

  red1 = bytscl(congrid(red,256))
  green1 = bytscl(congrid(green,256))
  blue1 = bytscl(congrid(blue,256))

  tvlct,red1,green1,blue1

end
