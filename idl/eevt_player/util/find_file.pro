function find_file, file_path
  found_file = !null

  if keyword_set(file_path) then begin
    tmp_path = strjoin(file_path, path_sep())

    if file_test(tmp_path, /read) then begin

      found_file = file_path
    endif else begin
      tmp_path = file_which(!path, tmp_path)

      if tmp_path then begin
        found_file = tmp_path
      endif
    endelse
  endif

  return, found_file
end