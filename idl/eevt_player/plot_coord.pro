; Convert from i, j running from top left to bottom right, i = row, j = column,
;  to logical plot coordinates with x, y going from lower left to upper right, x horizontal, y vertical.
function plot_coord, i, j, imax, jmax, left = left, right = right, top = top, bottom = bottm

  deltax = 1.0 / jmax

  deltay = 1.0 / imax

  ; Left, right, top, bottom
  if not keyword_set(left) then left = 0.07
  if not keyword_set(right) then right = 0.07
  if not keyword_set(top) then top = 0.02 ; top = 0.04
  if not keyword_set(bottom) then bottom = 0.04 ; bottom = 0.08

  ; (x0, y0, x1, y1)
  return, [ j * deltax + left, 1.0 - (i + 1) * deltay + bottom, $
    (j + 1) * deltax - right, 1.0 - i * deltay - top]
end