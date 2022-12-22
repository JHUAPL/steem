; Read a text file, tokenizing each line using the specified delimiter
; or regular expression (regex). This function optionally can ignore
; comments, and/or trim (leading and trailing) white space from each
; token.
;
; The caller is required to specify either the delim or the regex
; option, otherwise this function throws an error. This function
; also throws an error if BOTH delim and regex options are specified.
;
; Returns an N x M array of strings, where N is the number of
; (non-blank, non-comment) lines in the file, and M is the maximum
; number of tokens found on any line. Lines that had fewer than
; M tokens are padded with !null string values.
;
; If an IO error occurs while the file is being processed, this
; function will return an array containing whatever lines in the
; file were processed prior to the error.
;
; This function does NOT escape quotes, i.e., this function WILL
; split a line on a delimiter found in the middle of a quoted string.
; Similarly, if a comment identifier is in use, the line will be
; truncated at the first occurrence of a comment identifier, even if
; it is found in the middle of a quoted string.
;
; Parameters
;     file_path the path to the file to read
;
;     delim (optional, but either delim or regex is required)
;         delimiter to use to tokenize the lines in the file
;
;     regex (optional, but either delim or regex is required) regular
;         expression to use to tokenize the lines in the file
;
;     comment_id (optional) string or single identifier used to
;         identify comment text; all text after the first comment
;         identifier in a line is discarded. If not specified, this
;         feature is disabled. Comment identifiers are not matched as
;         regular expressions.
;
;     dont_trim_white_space (optional) flag that, if it evaluates to
;         TRUE will suppress trimming leading and trailing white
;         space from each token. If omitted or set to false/blank,
;         leading and trailing white space WILL be trimmed.
;
function read_csv_file, file_path, $
  delim = delim, $
  regex = regex, $
  comment_id = comment_id, $
  dont_trim_white_space = dont_trim_white_space

  if not keyword_set(delim) and not keyword_set(regex) then begin
    message, 'Must specify either delim OR regex option'
  endif
  if keyword_set(delim) and keyword_set(regex) then begin
    message, 'Cannot specify both delim and regex options'
  endif

  if not keyword_set(regex) then regex = ''
  if not keyword_set(comment_id) then comment_id = ''
  if not keyword_set(dont_trim_white_space) then dont_trim_white_space = !false

  ; Initialize various local variables.
  leading_and_trailing_space = 2

  lines = []
  max_num_tokens = -1
  ragged_arrays = !false

  get_lun, lun

  ; From this point on, need to make sure we clean up if something
  ; goes wrong.
  on_ioerror, clean_up
  catch, error_number
  if error_number ne 0 then goto, clean_up

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

    ; Split on delimiter, regex or neither.
    if regex ne '' then begin
      split_line = strsplit(split_line[0], regex, /extract, /regex, /preserve_null)
    endif else if delim ne '' then begin
      split_line = strsplit(split_line[0], delim, /extract, /preserve_null)
    endif else begin
      split_line = [ line ]
    endelse

    ; Handle white space.
    if not dont_trim_white_space then begin
      for i = 0, split_line.length - 1 do begin
        split_line[i] = strtrim(split_line[i], leading_and_trailing_space)
      endfor
    endif

    ; Keep track of the maximum number of tokens.
    if max_num_tokens eq -1 then begin
      max_num_tokens = split_line.length
    endif else if split_line.length gt max_num_tokens then begin
      max_num_tokens = split_line.length
      ragged_arrays = !true
    endif

    ; Push these tokens into the collection of lines.
    lines = [ lines, ptr_new(split_line) ]
  endwhile

  clean_up:
  catch, /cancel
  close, lun
  free_lun, lun

  ; Prepare return value.
  if lines.length gt 0 then begin
    result = make_array(lines.length, max_num_tokens, value = !null, /string)

    for i = 0, lines.length - 1 do begin
      split_line = *lines[i]

      for j = 0, split_line.length - 1 do begin
        result[i, j] = split_line[j]
      endfor

    endfor
  endif else begin
    result = []
  endelse

  return, result
end