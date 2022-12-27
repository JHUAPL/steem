pro steem_app, config_file
  ; Read launch parameters from the config file.
  if not keyword_set(config_file) then begin
    config_file = 'launch/default/steem-config.txt'
  endif
  config = read_key_value_file(config_file, comment_id = '#')

  ; Extract any launch parameters that are present.
  if keyword_set(config) then begin
    if config.hasKey('data_dir') then data_dir = config.data_dir
    if config.hasKey('filters') then filters_file = config.filters
    if config.hasKey('scatter_plots') then scatter_plots_file = config.scatter_plots
    if config.hasKey('scatter_display_id') then scatter_display_id = config.scatter_display_id
    if config.hasKey('detail_display_id') then detail_display_id = config.detail_display_id
    if config.hasKey('no_contour') then no_contour = config.no_contour
    if config.hasKey('no_spec') then no_spec = config.no_spec
    if config.hasKey('max_spec') then max_spec = config.max_spec
  endif

  ; Validate/set default values.
  data_dir = validate_par(data_dir, 'string', 'data')
  filters_file = validate_par(filters_file, 'string', !null)
  scatter_plots_file = validate_par(scatter_plots_file, 'string', !null)
  scatter_display_id = validate_par(scatter_display_id, 'int+', !null)
  detail_display_id = validate_par(detail_display_id, 'int+', !null)
  no_contour = validate_par(no_contour, 'bool', !false)
  no_spec = validate_par(no_spec, 'bool', !false)
  max_spec = validate_par(max_spec, 'int+', !null)

  ; Interpret/fill in any missing information.
  if keyword_set(scatter_plots_file) then begin
    scatter_plots = read_csv_file(scatter_plots_file, delim = ',', comment_id = '#')
    if keyword_set(scatter_plots) then begin
      ; Ensure somewhat valid selection.
      array_size = size(scatter_plots)
      if array_size[0] ne 2 or array_size[2] ne 2 or array_size[1] lt 2 then scatter_plots = !null

      ; Discard the top line, which are the column titles x and y.
      num_scatter_plots = n_elements(scatter_plots) / 2
      scatter_plots = scatter_plots[1:num_scatter_plots - 1, *]
    endif
  endif

  if not keyword_set(scatter_plots) then begin
    scatter_plots = [ $
      [ 'sn_tot_norm2', 'sn_tot_norm2', 'sm_ness_all2' ], $
      [ 'sm_ness_all2', 'alt', 'alt' ] $
      ]
  endif

  if not keyword_set(detail_display_id) then begin
    detail_display_id = scatter_display_id
  endif

  analyze_events, data_dir, $
    filters_file = filters_file, $
    display_id = scatter_display_id, $
    no_contour = no_contour, $
    max_spec = max_spec, $
    nospec = no_spec
end