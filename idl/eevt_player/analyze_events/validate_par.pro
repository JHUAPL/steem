function validate_par, par_value, par_type, value_if_error
  value = value_if_error

  catch, error_status
  if error_status ne 0 then goto, done

  if par_value ne !null then begin

    if strcmp(par_type, 'bool', /fold_case) then begin
      ; Interpret strings that look like boolean values as boolean values.
      if strcmp(par_value, 'true', /fold_case) or strcmp(par_value, 't', /fold_case) then begin
        par_value = 1
      endif else if strcmp(par_value, 'false', /fold_case) or strcmp(par_value, 'f', /fold_case) then begin
        par_value = 0
      endif

      ; Now just treat values like IDL variables.
      if par_value then value = 1 else value = 0

    endif else if strcmp(par_type, 'int+', /fold_case) then begin
      value = long(par_value)
      if value lt 0 then value = value_if_error

    endif else if strcmp(par_type, 'int', /fold_case) then begin
      value = long(par_value)

    endif else if strcmp(par_type, 'string', /fold_case) then begin
      value = string(par_value)
    endif

  endif

  done:
  catch, /cancel

  return, value
end