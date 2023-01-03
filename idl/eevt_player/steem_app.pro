pro steem_app, config_file
  common exp_fit, suppress_output

  suppress_output = 1

  ; Read launch parameters from the config file.
  if not keyword_set(config_file) then begin
    config_file = find_file([ 'launch', 'default', 'steem-config.txt' ])
  endif
  if keyword_set(config_file) then begin
    config = read_key_value_file(config_file, comment_id = '#')
  endif

  ; Extract any launch parameters that are present.
  if keyword_set(config) then begin
    if config.hasKey('data_dir') then data_dir = find_file(config.data_dir)
    if config.hasKey('filters_file') then filters_file = find_file(config.filters_file)
    if config.hasKey('help_file') then help_file = find_file(config.help_file)
    if config.hasKey('scatter_plot_file') then scatter_plot_file = find_file(config.scatter_plot_file)
    if config.hasKey('scatter_display_id') then scatter_display_id = config.scatter_display_id
    ; Note the following option was only ever partially implemented.
    if config.hasKey('detail_display_id') then detail_display_id = config.detail_display_id
    if config.hasKey('no_spec') then no_spec = config.no_spec
    if config.hasKey('max_spec') then max_spec = config.max_spec
  endif

  ; Validate/set default values.
  data_dir = validate_par(data_dir, 'string', find_file('steem-data'))
  filters_file = validate_par(filters_file, 'string', !null)
  help_file = validate_par(help_file, 'string', !null)
  scatter_plot_file = validate_par(scatter_plot_file, 'string', !null)
  scatter_display_id = validate_par(scatter_display_id, 'int+', !null)
  detail_display_id = validate_par(detail_display_id, 'int+', !null)
  no_spec = validate_par(no_spec, 'bool', !false)
  max_spec = validate_par(max_spec, 'int+', !null)

  if not keyword_set(data_dir) then begin
    message, string(format = strjoin( [ $
      'Fatal: cannot find input data. Either', $
      'a) put the data in a directory named steem-data or', $
      'b) put the path to the data directory in the data_dir parameter of a steem-config.txt file.', $
      'In either case, put the directory or config file somewhere in the path %s' ], ' '), !path)
  endif

  ; Interpret/fill in any missing information.
  if keyword_set(scatter_plot_file) then begin
    scatter_plots = read_csv_file(scatter_plot_file, delim = ',', comment_id = '#')
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

  analyze_events, data_dir, scatter_plots, $
    filters_file = filters_file, $
    help_file = help_file, $
    display_id = scatter_display_id, $
    max_spec = max_spec, $
    nospec = no_spec
end