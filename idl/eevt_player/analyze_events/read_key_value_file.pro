; Read a text file, splitting each line on the first equals sign,
; and using the left-hand string as the key and the right-hand string
; as the value. All such key-value pairs are returned in a
; dictionary.
;
; If an IO error occurs while the file is being processed, this
; function will return a dictionary containing whatever key-value pairs
; were processed prior to the error.
;
; This function does NOT escape quotes, i.e., this function WILL
; split a line on a delimiter found in the middle of a quoted string.
; Similarly, if a comment identifier is in use, the line will be
; truncated at the first occurrence of a comment identifier, even if
; it is found in the middle of a quoted string.
;
; Leading and trailing white space are trimmed from both keys and
; values. Embedded white space in values will be left alone.
;
; Parameters
;     file_path the path to the file to read
;1
;     comment_id (optional) string or single identifier used to
;         identify comment text; all text after the first comment
;         identifier in a line is discarded. If not specified, this
;         feature is disabled. Comment identifiers are not matched as
;         regular expressions.
;
function read_key_value_file, file_path, $
  comment_id = comment_id

  if not keyword_set(comment_id) then comment_id = ''

  ; Initialize various local variables.
  leading_and_trailing_space = 2

  keys = []
  values = []

  ; From this point on, need to make sure we clean up if something
  ; goes wrong.
  on_ioerror, clean_up

  error_number = 0
  catch, error_number
  if error_number ne 0 then goto, clean_up

  lun = -1
  get_lun, lun

  ; Read the file.
  openr, lun, file_path

  line = ''
  while not eof(lun) do begin
    readf, lun, line

    ; Handle comments.
    if comment_id ne '' then begin
      split_line = strsplit(line, comment_id, /extract, /preserve_null)
    endif else begin
      split_line = [ line ]
    endelse

    ; Skip totally blank lines.
    if split_line[0] eq '' then continue

    ; Split around first equals sign.
    delim = '='
    split_line = strsplit(split_line[0], delim, /extract)

    number_values = n_elements(split_line)
    if number_values gt 1 then begin
      key = strtrim(split_line[0], leading_and_trailing_space)
      value = strtrim(strjoin(split_line[1:number_values - 1], delim, /single), leading_and_trailing_space)

      if strlen(key) gt 0 then begin
        keys = [ keys, key ]
        values = [ values, value ]
      endif
    endif

  endwhile

  catch, /cancel

  clean_up:
  if error_number ne 0 then begin
    print, string(format = 'Error parsing key-value pair from file %s', file_path)
  endif
  if !error_state.code ne 0 then begin
    print, !error_state.msg
  endif

  if lun ge 0 then begin
    close, lun
    free_lun, lun
  endif

  if n_elements(keys) gt 0 then begin
    return, dictionary(keys, values)
  endif else begin
    return, !null
  endelse
end