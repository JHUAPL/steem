;-------------------------------------------------------------------------------
; This class encapsulates settings for displaying windows. It uses a prototype
; pattern -- the first instance created is used as a prototype for all future
; instances. Any/all prototype settings may be set/overridden for a given
; instance by passing keywords when instantiating this class.
;
; Sample usages:
;
;   settings = obj_new('WindowSettings')
;   settings = obj_new('WindowSettings', display_id = 1, max_spec = 3)
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Initialize a window settings object. Values for missing keywords will be
; taken from the prototype instance.
;
; If there is no prototype already defined, (i.e. the first time a window
; settings object is instantiated), missing arguments are set as follows:
;
; display_id = 0, max_spec = 1
;
; This is intended to yield behavior that is acceptable on any display.
;
; Parameters:
;     display_id, integer: identifier of the display (if more than one)
;         in which to show spectra detail plots
;     max_spec, integer: maximum number of spectra to show in a spectrum view
;
; Returns: 1 for success, 0 for failure
function WindowSettings::init, display_id, max_spec, help_file = help_file

  ; Define common block for prototype.
  common WindowSettings, prototype

  ; Determine default settings.
  if prototype eq !null then begin
    ; Prototype not set: compute defaults based on available displays.
    sysMonInfo = obj_new('IDLsysMonitorInfo')
    num_displays = sysMonInfo->GetNumberOfMonitors()
    rectangles = sysMonInfo->GetRectangles()

    ; (Fixed) index of the display height field within rectangle.
    height_index = 3

    ; Maximum display height in pixels.
    max_height = 0
    ; Index of the display that has the maxinum height.
    best_display_id = 0

    for i = 0, num_displays - 1 do begin
      if max_height lt rectangles[height_index, i] then begin
        max_height = rectangles[height_index, i]
        best_display_id = i
      endif
    endfor

    default_display_id = best_display_id

    if max_height ge 2000 then default_max_spec = 5 $
    else if max_height ge 1200 then default_max_spec = 3 $
    else default_max_spec = 1

    default_help_file = help_file
  endif else begin
    ; Prototype set: get defaults from it.
    default_display_id = prototype.display_id
    default_max_spec = prototype.max_spec
    default_help_file = prototype.help_file
  endelse

  if display_id eq !null then display_id = default_display_id
  if max_spec eq !null then max_spec = default_max_spec
  if max_spec lt 0 then max_spec = 0
  if not keyword_set(help_file) then help_file = default_help_file

  ; Set this object's properties.
  self.set_display_id, display_id
  self.max_spec = max_spec
  if keyword_set(help_file) then self.help_file = help_file

  if prototype eq !null then begin
    ; Take actions here that need only be done the very first time
    ; a window settings object is initialized
    ; Do this or else the color bars are messed up.
    device, decomposed = 0

    ;    loadct, 13 ; Rainbow
    ;  loadct, 32 ; Plasma -- nice contrasts but can't gauge intensity.
    ;  loadct, 74 ; Spectral -- darker = more, not really good and background is red.

    ; Standard procedural plot set-up.
    ;    standard_plot

    self.handler_map = ptr_new(dictionary())
    self.widget_map = ptr_new(dictionary())
    prototype = self
  endif else begin
    self.handler_map = prototype.handler_map
    self.widget_map = prototype.widget_map
  endelse

  return, 1
end

; Return the xsize (width) of created windows.
function WindowSettings::xsize
  rectangle = self.get_display_rectangle()

  width_index = 2
  display_width = rectangle[width_index]

  ; Size x to y so that y / x = golden ratio.
  xsize = self.ysize() * 2.0 / (1 + sqrt(5.0))

  ; Impose some limits: width must be at least half the window width, and
  ; no more that 90% of the window width.
  xmin = display_width * 0.5
  xmax = display_width * 0.9

  if xsize lt xmin then xsize = xmin
  if xsize gt xmax then xsize = xmax

  return, long(xsize)
end

; Return the ysize (height) of created windows.
function WindowSettings::ysize
  rectangle = self.get_display_rectangle()

  height_index = 3
  display_height = rectangle[height_index]

  ysize = display_height * .9

  return, long(ysize)
end

function WindowSettings::get_display_id
  return, self.display_id
end

pro WindowSettings::set_display_id, display_id
  sysMonInfo = obj_new('IDLsysMonitorInfo')
  num_displays = sysMonInfo->GetNumberOfMonitors()

  if display_id lt 0 then display_id = 0
  if display_id ge num_displays then display_id = num_displays - 1

  self.display_id = display_id
end

function WindowSettings::get_display_rectangle
  sysMonInfo = obj_new('IDLsysMonitorInfo')
  rectangles = sysMonInfo.getRectangles()
  rectangle = reform(rectangles[*, self.display_id])

  return, rectangle
end

; Return the max_spec setting.
function WindowSettings::max_spec
  return, self.max_spec
end

function WindowSettings::create_win, title = title, handler = handler

  common WindowSettings, prototype

  get_window_pos, prototype.win_index, x, y
  ++prototype.win_index

  widget_map = *self.widget_map

  xsize = self.xsize()
  ysize = self.ysize()

  b = widget_base(title = title, xoffset = x, yoffset = y, mbar = bar, /column, /tlb_size_events, /tlb_resize_nodraw)

  key = self.make_base_key(b)
  widget_map[key] = b

  xmanager, 'WindowSettings::create_win', b, event_handler = 'steem_window_handler', /no_block

  file_menu = widget_button(bar, value = 'File', /menu)
  help_menu = widget_button(bar, value = 'Help', /menu)

  if keyword_set(handler) then begin
    !null = widget_button(file_menu, value = 'New Event Detail Window', accelerator = 'Ctrl+N', event_pro = 'steem_new_handler')
    handler_map = *self.handler_map
    handler_map[key] = handler
  endif
  !null = widget_button(file_menu, value = 'Close Window', accelerator = 'Ctrl+W', event_pro = 'steem_close_handler')
  !null = widget_button(file_menu, value = 'Quit', event_pro = 'steem_exit_handler')

  !null = widget_button(help_menu, value = 'STEEM Help', accelerator = 'Ctrl+H', event_pro = 'steem_help_handler')

  ww = widget_window(b, xsize = xsize, ysize = ysize)

  key = self.make_window_key(b)
  widget_map[key] = ww

  widget_control, b, /realize

  widget_control, ww, get_value=w

  if keyword_set(handler) then w.EVENT_HANDLER = handler

  w.SetCurrent

  return, w
end

pro WindowSettings::get_window_pos, win_index, x, y

  xsize = self.xsize()
  ysize = self.ysize()
  display_id = self.display_id

  oInfo = obj_new('IDLsysMonitorInfo')
  num_mons = oInfo->GetNumberOfMonitors()
  if display_id lt 0 then display_id = 0
  if display_id ge num_mons then display_id = num_mons - 1

  rects = oInfo->GetRectangles()

  ; Get monitor characteristics.
  x_min = rects[0, display_id]
  mon_width = rects[2, display_id]
  x_max = x_min + mon_width

  y_min = rects[1, display_id]
  mon_height = rects[3, display_id]
  y_max = y_min + mon_height

  ; Slim down requested plot size to fit the monitor if necessary.
  if xsize gt mon_width then xsize = mon_width
  if ysize gt mon_height then ysize = mon_height

  ; Use menu bar thickness as a heuristic limit on sizes in order
  ; to tile plots nicely.
  menu_bar_thickness = 32

  ; For purposes of wrapping window placements at the edges of monitor,
  ; constrain coordinates to a range that guarantees about 1/4 of a window
  ; will always be visible when first displayed.
  wrap_width = mon_width - xsize / 2
  wrap_height = mon_height - ysize / 2

  ; Arbitrarily figure on stepping through about 17 plots (a prime)
  ; before wrapping on the monitor.
  delta_x = wrap_width / 17
  delta_y = wrap_height / 17

  ; Ensure the X-Y steps for each plot are at least the thickness of a
  ; window's menu bar.
  if delta_x lt 32 then delta_x = menu_bar_thickness
  if delta_y lt 32 then delta_y = menu_bar_thickness

  ; Determine offsets for placing this plot.
  x_offset = 1 + win_index * delta_x mod wrap_width
  y_offset = 1 + win_index * delta_y mod wrap_height

  ; X and Y are measured from lower-left, but plots start at
  ; upper-left and march down the diagonal to lower-right.
  x = x_min + x_offset
  y = y_max - ysize - y_offset

  obj_destroy, oInfo

end

function WindowSettings::get_handler_map
  return, *self.handler_map
end

function WindowSettings::get_widget_map
  return, *self.widget_map
end

function WindowSettings::get_help_file
  return, self.help_file
end

function WindowSettings::make_base_key, base
  return, string(base, format = 'base%d')
end

function WindowSettings::make_window_key, base
  return, string(base, format = 'win%d')
end

pro steem_window_handler, event
  common WindowSettings, prototype

  widget_map = prototype.get_widget_map()

  key = prototype.make_window_key(event.top)

  if widget_map.hasKey(key) then begin
    ; This is in case event doesn't have x, y, i.e., if it's the wrong
    ; kind of event.
    catch, error_number
    if error_number ne 0 then return

    xsize = event.x
    ysize = event.y

    widget_control, widget_map[key], xsize = xsize, ysize = ysize

    catch, /cancel
  endif
end

pro steem_new_handler, event
  common WindowSettings, prototype

  handler_map = prototype.get_handler_map()

  key = prototype.make_base_key(event.top)

  if handler_map.hasKey(key) then begin
    handler_map[key]->create_new_window
  endif
end

pro steem_close_handler, event
  destroy_base, event.top
end

pro steem_exit_handler, event
  common WindowSettings, prototype

  widget_map = prototype.get_widget_map()
  foreach key, widget_map.keys() do begin
    base = strsplit(key, 'base', /extract)
    if not strcmp(key, base[0]) then begin
      base_id = long(base[0])
      if event.top ne base_id then begin
        destroy_base, base_id
      endif
    endif
  endforeach

  destroy_base, event.top
end

pro steem_help_handler, event
  common WindowSettings, prototype

  help_file = prototype.get_help_file()

  if keyword_set(help_file) then begin
    xdisplayfile, help_file, title = 'STEEM Help'
  endif else begin
    xdisplayfile, help_file, title = 'STEEM Help', $
      text = [ $
      'This is the Spectrum Tool for Electron Events at Mercury (STEEM).', $
      'The purpose of STEEM is to browse and visualiza a publicly', $
      'accessible data set of electron events taken by the MESSENGER', $
      'spacecraft. The data are available in the PDS, but are included', $
      'with this tool for convenience.', $
      '', $
      'Here is a brief summary of how STEEM works.', $
      '', $
      'On the main window you see the events as they are distributed in a few plots', $
      'in parameter space. Use your mouse to select one or more events of interest.', $
      'Then either press the "s" key or select the menu', $
      '"File -> New Event Detail Window" to open a new window with a more detailed', $
      'view of just the selected event(s). NOTE: you must have at least one event', $
      'selected for this to work! You can do this multiple times in order', $
      'to inspect different collections of events. You can also press the "r" key', $
      '(case-insensitive) to reset the zoom and de-select any events currently selected.', $
      '', $
      'The "Event Detail" windows show one event at a time, but allow you to page', $
      'through whichever events you had selected on the main window when you', $
      'launched the "Event Detail" window.', $
      '', $
      'On the "Event Detail" windows, the following keystrokes may be used to navigate', $
      'through the data:', $
      '', $
      '    space or right-arrow-key: view the next spectrum in the current event', $
      '', $
      '    B, b, or left-arrow-key: view the previous spectrum in the current event', $
      '', $
      '    n (lower case) or down-arrow-key: view the next event', $
      '', $
      '    P, p, N (upper case), or up-arrow_key: view the previous event', $
      '', $
      '    r (lower-case): reset zoom, refresh color bars', $
      '', $
      '    R (upper-case): completely replot the current event', $
      '', $
      '    L or l: toggle between linear and logarithmic scaling on plots', $
      '', $
      'If you use the menu item File -> New Event Detail Window on an', $
      '"Event Detail" window, it clones the current window. This can', $
      'be useful if you wish to view two events (or two different)', $
      'spectra in the *same* event), side-by-side.', $
      '', $
      'You can drag around/resize/zoom the plots using the mouse. The plots', $
      'behave (mostly) like IDL (new graphics) plots. There is no undo', $
      'feature, so if you make a change you regret, [r]eset or [R]eplot', $
      'is the best you can do to recover. If the main tool window gets', $
      'messed up, you may need to restart STEEM.' ]
  endelse
end

pro destroy_base, base
  common WindowSettings, prototype

  handler_map = prototype.get_handler_map()
  widget_map = prototype.get_widget_map()

  key = prototype.make_base_key(base)

  if widget_map.hasKey(key) then begin
    widget_id = widget_map[key]

    error_number = 0
    catch, error_number

    if error_number eq 0 then begin
      widget_control, widget_id, /destroy
    endif

    catch, /cancel
  endif

  remove_key, handler_map, key
  remove_key, widget_map, key
  remove_key, widget_map, prototype.make_window_key(base)
end

pro remove_key, dict, key
  error_number = 0
  catch, error_number

  if error_number eq 0 then begin
    if dict.hasKey(key) then dict.remove, key
  endif

  catch, /cancel
end

pro WindowSettings__define
  !null = { WindowSettings, $
    display_id:-1, $
    max_spec:-1, $
    win_index:0, $
    help_file:'', $
    handler_map:ptr_new(), $
    widget_map:ptr_new() $
  }
end
