function extract_array0, eevt, vals, field_name
  tag_names = tag_names(eevt[0, 0].eevt)
  index = where(strcmp(tag_names, field_name, /fold_case), /null)

  if index ne !null then return, eevt[*, 0].eevt.(index[0])

  tag_names = tag_names(vals[0])
  index = where(strcmp(tag_names, field_name, /fold_case), /null)

  if index ne !null then return, vals[*].(index[0])

  return, !null
end