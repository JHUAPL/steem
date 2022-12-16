; Convert from i, j running from top left to bottom right, i = row, j = column,
;  to logical plot coordinates with x, y going from lower left to upper right, x horizontal, y vertical.
function plot_coord, i, j, imax, jmax, left = left, right = right, top = top, bottom = bottom, $
  width = width, height = height, margins = margins

  deltax = 1.0 / jmax

  deltay = 1.0 / imax

  ; Left, right, top, bottom
  ;  if not keyword_set(left) then left = 0.12
  ;  if not keyword_set(right) then right = 0.12
  ;  if not keyword_set(top) then top = 0.12
  ;  if not keyword_set(bottom) then bottom = 0.12
  if not keyword_set(margins) then margins = [ 0., 0., 0., 0. ]
  if not keyword_set(left) then left = margins[0]
  if not keyword_set(right) then right = margins[1]
  if not keyword_set(top) then top = margins[2]
  if not keyword_set(bottom) then bottom = margins[3]
  if not keyword_set(width) then width = 1
  if not keyword_set(height) then height = 1

  ; TODO: put width and height into pixels scaled by xunit and yunit, so that
  ; the same settings work on any monitor setup. Requires either that the
  ; caller know how big the rows/columns are (breaking encapsulation and
  ; making calling code messy), or ...? Is there a better way?
  return, [ j * deltax + left, 1.0 - (i + 1) * deltay + bottom, $
    (j + width) * deltax - right, 1.0 - (i + 1 - height) * deltay - top ]
end