pro load_filters, filter_file, lls, uls
  filters = read_csv_file(filter_file, delim = ',', comment_id = '#')
  dims = size(filters)

  ; Note that immediately after these declarations, these variables
  ; show as == !null and keyword_set(var) returns 0. Nonetheless, if
  ; these declarations are ommitted, there are errors in the loop
  ; trying to append to them.
  parameters = []
  lower_bounds = []
  upper_bounds = []

  if dims[0] eq 2 then begin
    if dims[2] eq 3 then begin
      number_filters = dims[1]

      for i = 0, number_filters - 1 do begin
        filter_name = filters[i, 0]

        if keyword_set(filter_name) then begin
          filter_lb = filters[i, 1]
          filter_ub = filters[i, 2]

          lb = !values.d_nan
          if keyword_set(filter_lb) then begin
            on_ioerror, lb_done
            value = double(filter_lb)
            lb = value
          endif
          lb_done:

          ub = !values.d_nan
          if keyword_set(filter_ub) then begin
            on_ioerror, ub_done
            value = double(filter_ub)
            ub = value
          endif
          ub_done:

          parameters = [ parameters, filter_name ]
          lower_bounds = [ lower_bounds, lb ]
          upper_bounds = [ upper_bounds, ub ]
        endif
      endfor
    endif else begin
      print, string(format = 'Filter file %s has %d columns, not 3 (parameter, lower_bound, upper_bound) as expected', filter_file, dims[2])
    endelse
  endif

  if keyword_set(lower_bounds) then begin
    indices = where(finite(lower_bounds), /null)
  endif else begin
    indices = !null
  endelse

  if n_elements(indices) gt 0 then begin
    lls = dictionary(parameters[indices], lower_bounds[indices])
  endif else begin
    lls = !null
  endelse

  if keyword_set(upper_bounds) then begin
    indices = where(finite(upper_bounds), /null)
  endif else begin
    indices = !null
  endelse

  if n_elements(indices) gt 0 then begin
    uls = dictionary(parameters[indices], upper_bounds[indices])
  endif else begin
    uls = !null
  endelse

end