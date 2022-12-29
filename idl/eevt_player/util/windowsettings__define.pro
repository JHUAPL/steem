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
  self.help_file = help_file

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

    self.widget_map = ptr_new(dictionary())
    prototype = self
  endif else begin
    self.widget_map = ptr_new(prototype.widget_map)
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

function WindowSettings::get_win_index
  common WindowSettings, prototype

  return, prototype.win_index
end

function WindowSettings::create_win, title = title, handler = handler

  common WindowSettings, prototype

  widget_map = *prototype.widget_map

  get_window_pos, prototype.win_index, x, y

  xsize = self.xsize()
  ysize = self.ysize()

  b = widget_base(title = title, xoffset = x, yoffset = y, mbar = bar, /column, /tlb_size_events, /tlb_resize_nodraw)

  key = string(b, format = "base%d")
  widget_map[key] = b

  xmanager, 'WindowSettings::create_win', b, event_handler = 'steem_window_handler', /no_block

  file_menu = widget_button(bar, value = 'File', /menu)
  help_menu = widget_button(bar, value = 'Help', /menu, event_pro = 'steem_help_handler')

  !null = widget_button(file_menu, value = 'New Event Detail Window', accelerator = 'Ctrl+N')
  !null = widget_button(file_menu, value = 'Close Window', accelerator = 'Ctrl+W', event_pro = 'steem_window_handler')
  !null = widget_button(file_menu, value = 'Exit', accelerator = 'Ctrl+X', event_pro = 'steem_exit_handler')

  !null = widget_button(help_menu, value = 'STEEM Help', accelerator = 'Ctrl+H', event_pro = 'steem_help_handler')

  ww = widget_window(b, xsize = xsize, ysize = ysize)

  key = string(b, format = "win%d")
  widget_map[key] = ww

  widget_control, b, /realize

  widget_control, ww, get_value=w

  if keyword_set(handler) then w.EVENT_HANDLER = handler

  w.SetCurrent

  ++prototype.win_index

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

function WindowSettings::get_widget_map
  return, *self.widget_map
end

function WindowSettings::get_help_file
  return, self.help_file
end

; Make *this* instance of WindowSettings the new prototype. Future windows
; settings (and windows) will be initialized to the same state as this
; instance.
pro WindowSettings::set_prototype
  common WindowSettings, prototype

  prototype = self
end

pro steem_window_handler, event
  common WindowSettings, prototype

  widget_map = prototype.get_widget_map()

  key = string(event.handler, format = "win%d")

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

pro steem_help_handler, event
  common WindowSettings, prototype

  help_file = prototype.get_help_file()

  if keyword_set(help_file) then begin
    xdisplayfile, help_file, title = 'STEEM Help'
  endif
end

pro steem_exit_handler, event
  common WindowSettings, prototype

  widget_map = prototype.get_widget_map()
  foreach key, widget_map.keys() do begin
    if strmatch(key, 'base*') then begin
      widget_control, widget_map[key], /destroy
    endif
  endforeach
end

pro WindowSettings__define
  !null = { WindowSettings, $
    display_id:-1, $
    max_spec:-1, $
    win_index:0, $
    help_file:'', $
    widget_map:ptr_new() $
  }
end
