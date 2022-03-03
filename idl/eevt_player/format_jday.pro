function format_jday, jday

  caldat, jday, month, day, year, hour, minute, second

  second = round(second)
  if second lt 0.0 then second = 0.0
  if second ge 60.0 then second = 59.9994

  utc = timestamp(year=year, month=month, day=day, hour=hour, minute=minute, second=second)

  return, utc
end