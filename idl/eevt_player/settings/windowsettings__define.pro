;-------------------------------------------------------------------------------
; This class encapsulates settings for displaying windows. It uses a prototype
; pattern -- the first instance created is used as a prototype for all future
; instances. Any/all prototype settings may be set/overridden for a given
; instance by passing keywords when instantiating this class.
;
; Sample usages:
;
;   settings = obj_new('WindowSettings')
;   settings = obj_new('WindowSettings', ysize = 1200, max_spec = 3)
;   settings = obj_new('WindowSettings', switch_display = !true)
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Initialize a window settings object. Values for missing keywords will be
; taken from the prototype instance.
;
; If there is no prototype already defined, (i.e. the first time a window
; settings object is instantiated), missing keyword values are set as follows:
;
; xsize = 1280, ysize = 900, switch_display = !false, max_spec = 1.
;
; This is intended to yield a size that fits on a MacBook screen.
;
; Keywords:
;   xsize, integer: number of pixels for each window in the horizontal direction
;
;   ysize, integer:  number of pixels for each window in the vertical direction
;
;   switch_display, boolean: if two displays are available, toggle this until
;     new windows appear on desired display. If only one display is available,
;     this has no effect
;
;   max_spec, integer: maximum number of spectra to show in a spectrum view
;
; Returns: 1 for success, 0 for failure
function WindowSettings::init, xsize = xsize, ysize = ysize, $
  switch_display = switch_display, max_spec = max_spec

  ; Define common block for prototype.
  common WindowSettings, prototype

  ; Determine default settings.
  if prototype eq !null then begin
    ; No prototype yet: set failsafe default values.
    default_xsize = 1280
    default_ysize = 900
    default_switch_display = !false
    default_max_spec = 1

  endif else begin
    ; Prototype set: use it.
    default_xsize = prototype.xsize
    default_ysize = prototype.ysize
    default_switch_display = prototype.switch_display
    default_max_spec = prototype.max_spec

  endelse

  if not keyword_set(xsize) then xsize = default_xsize
  if not keyword_set(ysize) then ysize = default_ysize
  if not keyword_set(switch_display) then switch_display = default_switch_display
  if not keyword_set(max_spec) then max_spec = default_max_spec

  ; For bad inputs return 0 (null instance).
  if xsize le 100 or ysize le 100 or max_spec le 0 then return, 0

  ; Set this object's properties.
  self.xsize = xsize
  self.ysize = ysize
  self.switch_display = switch_display
  self.max_spec = max_spec

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

    prototype = self
  endif


  return, 1
end

; Return the xsize setting.
function WindowSettings::xsize
  return, self.xsize
end

; Return the ysize setting.
function WindowSettings::ysize
  return, self.ysize
end

; Return the switch_display setting.
function WindowSettings::switch_display
  return, self.switch_display
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

  get_window_pos, prototype.win_index, x, y

  xsize = self.xsize()
  ysize = self.ysize()

  w = window(location = [ x, y ], dimensions = [ xsize, ysize ], window_title = title)

  if keyword_set(handler) then w.EVENT_HANDLER = handler

  w.SetCurrent

  ++prototype.win_index

  return, w
end

pro WindowSettings::get_window_pos, win_index, x, y

  xsize = self.xsize()
  ysize = self.ysize()
  switch_display = self.switch_display()

  if switch_display then mon_index = 0 else mon_index = 1

  oInfo = obj_new('IDLsysMonitorInfo')
  num_mons = oInfo->GetNumberOfMonitors()
  if mon_index lt 0 then mon_index = 0
  if mon_index ge num_mons then mon_index = num_mons - 1

  rects = oInfo->GetRectangles()

  ; Get monitor characteristics.
  x_min = rects[0, mon_index]
  mon_width = rects[2, mon_index]
  x_max = x_min + mon_width

  y_min = rects[1, mon_index]
  mon_height = rects[3, mon_index]
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

; Make *this* instance of WindowSettings the new prototype. Future windows
; settings (and windows) will be initialized to the same state as this
; instance.
pro WindowSettings::set_prototype
  common WindowSettings, prototype

  prototype = self
end

; Show (print to console) the window settings.
pro WindowSettings::show

  common WindowSettings, prototype

  format = 'xsize = %d, ysize = %d, switch_display = %s, max_spec = %d, win_index = %d'

  is_prototype = self.xsize eq prototype.xsize and $
    self.ysize eq prototype.ysize and $
    self.switch_display eq prototype.switch_display and $
    self.max_spec eq prototype.max_spec

  if is_prototype then format = 'WindowSettings (prototype): ' + format $
  else format = 'WindowSettings: ' + format

  if self.switch_display then switch_string = 'true' else switch_string = 'false'

  print, format = format, self.xsize, self.ysize, switch_string, self.max_spec, prototype.win_index

end

pro WindowSettings__define
  !null = { WindowSettings, xsize:-1, ysize:-1, max_spec:-1, switch_display:!false, win_index:0 }
end
