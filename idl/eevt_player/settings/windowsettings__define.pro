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

  if prototype eq !null then prototype = self

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

; Make *this* intance of WindowSettings the new prototype. Future windows
; settings (and windows) will be initialized to the same state as this
; instance.
pro WindowSettings::set_prototype
  common WindowSettings, prototype

  prototype = self
end

; Show (print to console) the window settings.
pro WindowSettings::show

  common WindowSettings, prototype

  format = 'xsize = %d, ysize = %d, switch_display = %s, max_spec = %d'

  is_prototype = self.xsize eq prototype.xsize and $
    self.ysize eq prototype.ysize and $
    self.switch_display eq prototype.switch_display and $
    self.max_spec eq prototype.max_spec

  if is_prototype then format = 'WindowSettings (prototype): ' + format $
  else format = 'WindowSettings: ' + format

  if self.switch_display then switch_string = 'true' else switch_string = 'false'

  print, format = format, self.xsize, self.ysize, switch_string, self.max_spec

end

pro WindowSettings__define
  !null = { WindowSettings, xsize:-1, ysize:-1, max_spec:-1, switch_display:!false }
end
