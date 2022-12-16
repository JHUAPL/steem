;+
; NAME:
;
;  conmake.pro
;
; LICENSE:
;
;    This code is written and copyrighted (2006) by David Pace. You
;    are allowed to use and change the code, but you must leave this
;    original license statement in any derivative works. You cannot
;    sell this code or any derivative works without express written
;    consent of the original copyright holder/author.
;
;    This code is provided AS IS and without warranty.
;
; PURPOSE:
;
;  Generic function to return a contour plot with user input bounds.
;
; INPUTS:
;
;    in   - Input, multidimensional data array
;    x    - X, x-axis array
;    y    - Y, y-axis array
;    nl   - Number of Levels, set the number of colors and contour levels
;           to display.
;
; KEYWORDS:
;
;    xran   - X Range, array in the form of the XRANGE keyword
;    yran   - Y Range, array in the form of the YRANGE keyword
;    xlabel - X Label, if set, the value of this keyword determines
;             the xtitle input of the contour plot. NOTE: calling the
;             conmake procedure with no inputs results in a display of
;             the different label options.
;    ylabel - Y Label, if set, the value of this keyword determines the
;             ytitle input of the contour plot.
;    log    - Log Plot, if set, the value of this keyword places a
;             restriction on the log of the input data set (which will be
;             plotted in the contour). Values of the data that are below
;             this value will be treated as NAN and will not be
;             displayed on the contour plot.
;    v      - Verbose, if set, this keyword causes the routine to
;             print the x and y ranges.
;    lev    - Levels, if set, this keyword is used as the
;    many   - Many Contours, if set, this keyword suppresses color
;             table generation. This is intended for separate procedures
;             that are used to generate multiple contour images. These
;             procedures can set this keyword and then load a color table
;             within their own routine.
;    cbar   - Colorbar, if set, results in a colorbar being placed in
;             the right side of the display window. The contour plot
;             will be squished to make room for the bar.
;    overp  - Overplot, set as a 2D array to be overplotted on final
;             contour. This overplot will be black contour lines with
;             labels.
;    oset   - Overplot Settings, array of parameters for affecting the
;             overplot of overp. If not set, then default values are
;             used. Set as an array where,
;                 oset[indice] = description, default value
;                 oset[0] = number of levels to plot, 4
;                 oset[1] = character size for contour labels, 2
;                 oset[2] = character thickness, 2
;             NOTE: if you set any of these, then you must set them
;             all.
;    minlev - Minimum Level, if set, this keyword is used as the
;             minimum value of data to be plotted. The input will be
;             filtered and all values below this input will be treated
;             as missing data in the contour.
;
; EXAMPLE:
;
;    You have a 3D array given by,
;        data = [ x_position, y_position, time ]
;    and want to make a contour plot in position at the ininitial time
;    point (i.e. time indice = 0). Use the following command for a
;    basic plot with axes beginning at zero and increasing as
;    integers and 256 colors,
;        conMake, data[*,*,0], 256
;
;    Similarly, if you have arrays for the x and y axes (let them be
;    xaxis and yaxis respectively), then you can display this using,
;        conMake, data[*,*,0], xaxis, yaxis, 256
;
; MODIFICATION HISTORY:
;
;    01/28/2006 - Commented for public release.
;    01/29/2006 - Added /YSTYLE command to AXIS procedure of the
;                 colorbar. This ensures the colorbar exactly matches
;                 the levels (especially when using the minlev
;                 keyword).
;    02/08/2006 - Corrected error in which levels were not rescaled
;                 according to selected x-range.
;    03/14/2006 - Corrected error in which the X Begin value was
;                 displayed as the X End value when the "v" keyword
;                 was set.
;
;-
PRO conmake, in, x, y, nl, $
  xran=xran, $
  yran=yran, $
  xlabel=xlabel, $
  ylabel=ylabel, $
  log=log, $
  v=v, $
  lev=lev, $
  many=many, $
  cbar=cbar, $
  overp=overp, $
  oset=oset, $
  minlev=minlev

  npms = N_PARAMS()

  ;if no input parameters, then display the various axis labels
  IF ( npms EQ 0 ) THEN BEGIN

    PRINT, '----------------------'
    PRINT, ' Usage of conmake.pro '
    PRINT, ' Labels:'
    PRINT, '+---------------------------------------------------+'
    PRINT, '| Value       xlab                 ylab             |'
    PRINT, '|---------------------------------------------------|'
    PRINT, '|   0                                               |'
    PRINT, '|   1    Position (cm)         Position (cm)        |'
    PRINT, '|   2    X Position (cm)       Y Position (cm)      |'
    PRINT, '|   3    Frequency (kHz)       Frequency (kHz)      |'
    PRINT, '|   4    Bias (V)                                   |'
    PRINT, '|   5    Time (ms)             Time (ms)            |'
    PRINT, '|   6    Radial Position (cm)  Radial Position (cm) |'
    PRINT, '+---------------------------------------------------+'

  ENDIF ELSE BEGIN

    ;remove all dimension of IN that have size unity
    use = REFORM( in )

    IF ~KEYWORD_SET( minlev ) THEN ( minlev = -1.0 * !VALUES.F_INFINITY )

    IF ( npms GT 2 ) THEN BEGIN

      ;do not use actual x,y arrays for fear of changing them
      x1 = x
      y1 = y

    ENDIF ELSE BEGIN

      x1 = INDGEN( N_ELEMENTS( use[ *, 0 ] ) )
      y1 = INDGEN( N_ELEMENTs( use[ 0, * ] ) )
      nl = x             ;input x is actually the number of levels

    ENDELSE

    ;set whether the arrays count forward or backward
    IF ( x1[0] GT x1[1] ) THEN ( backx = 1 ) ELSE ( backx = 0 )
    IF ( y1[0] GT y1[1] ) THEN ( backy = 1 ) ELSE ( backy = 0 )

    ;string array of potential y and x-axis labels
    ylab = [' ', $
      'Position (cm)', $
      'Y Position (cm)', $
      'Frequency (kHz)', $
      ' ', $
      'Time (ms)', $    ; 5
      'Radial Position (cm)' ]

    xlab = [' ', $
      'Position (cm)',$
      'X Position (cm)', $
      'Frequency (kHz)', $
      'Bias (V)', $
      'Time (ms)', $    ; 5
      'Radial Position (cm)' ]

    IF ~KEYWORD_SET( ylabel ) THEN ( ylabel = 0 )
    IF ~KEYWORD_SET( xlabel ) THEN ( xlabel = 0 )

    ;the ylabel value also affects the position of the contour since
    ;a plot with no label can be stretched further in the x-direction
    ;(the same situation holds for the xlabel, so I use the incorrectly
    ;labeled xpos1 to set the y1 position as well)
    xpos1 = [ 0.12, REPLICATE( 0.14, N_ELEMENTS( ylab ) ) ]

    ;if the y-axis labels have negative values, then the position must
    ;be adjusted further
    IF ( MIN( y1 ) LT 0.0 ) THEN ( xpos1[ ylabel ] = 0.14 )

    ;determine sizes of input array
    size1 = N_ELEMENTS( use[ *, 0 ] )
    size2 = N_ELEMENTS( use[ 0, * ] )

    ;set x-range
    IF KEYWORD_SET( xran ) THEN BEGIN

      rbeg = WHERE( x1 GE xran[ 0 ] )
      rend = WHERE( x1 GE xran[ 1 ] )
      x1 = x1[ rbeg[ 0 ] : rend[ 0 ] ]

    ENDIF ELSE BEGIN

      rbeg = [ 0, 0 ]
      rend = [ N_ELEMENTS( x1 ) - 1, 0 ]

    ENDELSE

    ;set y-range
    IF KEYWORD_SET( yran ) THEN BEGIN

      ;for a backwards y-array, simply swap the beginning and
      ;ending indices
      IF ( backy EQ 1 ) THEN BEGIN

        yend = WHERE( y1 LE yran[ 0 ] )

        IF ( N_ELEMENTS( yend ) EQ 1 ) THEN $
          ( yend[ 0 ] = N_ELEMENTS( y1 ) - 1 )

        ybeg = WHERE( y1 LE yran[ 1 ] )

        IF KEYWORD_SET( v ) THEN PRINT, '--> Y-array is reversed <--'

      ENDIF ELSE BEGIN

        ybeg = WHERE( y1 GE yran[ 0 ] )
        yend = WHERE( y1 GE yran[ 1 ] )

      ENDELSE

    ENDIF ELSE BEGIN

      ybeg = FLTARR( 1 )
      yend = ybeg
      ybeg[ 0 ] = 0
      yend[ 0 ] = size2 - 1

    ENDELSE

    ;determine the array to be contour plotted
    IF KEYWORD_SET( log ) THEN BEGIN

      ;remove all zero values before taking the log
      IF ( WHERE( use EQ 0.0 ) NE -1 ) THEN $
        use[ WHERE( use EQ 0.0 ) ] = 1.0

      content = ALOG( use[  rbeg[ 0 ] : rend[ 0 ], ybeg[0] : yend[0] ] $
        > log )

      ;ensure that these zero values are ignored when plotting
      IF ( WHERE( content EQ 0.0 ) NE -1 ) THEN $
        content[ WHERE( content EQ 0.0 ) ] = !VALUES.F_NAN

    ENDIF ELSE BEGIN

      content = use[ rbeg[ 0 ] : rend[ 0 ], ybeg[0] : yend[0] ]

    ENDELSE

    ;create array of levels for contour
    IF KEYWORD_SET( lev ) THEN BEGIN

      lev = lev
      lev = lev[ WHERE( lev GT minlev ) ]
      nl = N_ELEMENTS( lev )

    ENDIF ELSE BEGIN

      ;recreate the default levels array that IDL would have made
      mxx = MAX( content, MIN = mnn ) * 0.98
      delta_lev = ( mxx - mnn ) / FLOAT( nl )
      lev = FINDGEN( nl ) * delta_lev + mnn
      lev = lev[ WHERE( lev GT minlev ) ]
      nl = N_ELEMENTS( lev )

    ENDELSE

    ;set color table, unless told not to
    IF ~KEYWORD_SET( many ) THEN BEGIN

      LOADCT, 39, NCOLORS = nl
      DEVICE, DECOMPOSED = 0

    ENDIF

    ;begin colorbar processing
    IF KEYWORD_SET( cbar ) THEN BEGIN

      ;squish the main contour to make room for a color bar
      ;to be added later. The amount by which the main contour is
      ;squished depends on how many characters there are in the
      ;colorbar labels.
      squish = STRLEN( STRTRIM( STRING( lev[ 0 ] ), 2 ) )

      CASE squish OF

        1: conendx = 0.87
        2: conendx = 0.85
        3: conendx = 0.83
        4: conendx = 0.81
        5: conendx = 0.79

        ELSE: BEGIN

          conendx = 0.85

        END

      ENDCASE

      IF ( lev[ 0 ] LT 0.0 ) THEN BEGIN

        conendx = conendx - 0.03

      ENDIF

    ENDIF ELSE BEGIN

      conendx = 0.95

    ENDELSE

    ;make the data contour
    CONTOUR, content, $
      x1, y1[ ybeg[ 0 ] : yend[ 0 ] ], $
      NLEVELS = nl, C_COLORS = INDGEN( nl ), /XSTYLE, /YSTYLE, /ZSTYLE, $
      /FILL, BACKGROUND = nl - 1, COLOR = 0, $
      POSITION=[ xpos1[ ylabel ], xpos1[ xlabel ], conendx, 0.92 ], $
      CHARSIZE = 1.5, YTITLE = ylab[ ylabel ], XTITLE = xlab[ xlabel ], $
      CHARTHICK = 2, LEVELS = lev

    ;if set, make overplot of user provided array
    IF KEYWORD_SET( overp ) THEN BEGIN

      IF ~KEYWORD_SET( oset ) THEN BEGIN

        onl = 4
        cs = 2
        cthick = 2

      ENDIF ELSE BEGIN

        onl = oset[ 0 ]
        cs = oset[ 1 ]
        cthick = oset[ 2 ]

      ENDELSE

      CONTOUR, overp, $
        x1, y1[ ybeg[ 0 ] : yend[ 0 ] ], $
        POSITION=[ xpos1[ ylabel ], xpos1[ xlabel ], conendx, 0.92 ], $
        /XSTYLE, /YSTYLE, /ZSTYLE, COLOR = 0, CHARSIZE = 1.5, $
        CHARTHICK = cthick, NLEVELS = onl, /NOERASE, $
        C_LABELS = [1,1,1,1], C_CHARSIZE = cs

    ENDIF

    ;add colorbar plot if requested
    IF KEYWORD_SET( cbar ) THEN BEGIN

      ;colorbar array consists of levels previously determined
      cbar_arr = FLTARR( 2, N_ELEMENTS( lev ) )
      cbar_arr[0,*] = lev
      cbar_arr[1,*] = lev

      CONTOUR, cbar_arr, [1,2], lev, $
        NLEVELS = nl, C_COLORS = INDGEN( nl ), XSTYLE = 5, YSTYLE = 5, $
        /ZSTYLE, /FILL, BACKGROUND = nl - 1, COLOR = 0, $
        POSITION = [ conendx + 0.03, xpos1[ xlabel ], $
        conendx + 0.06, 0.92 ], $
        LEVELS = lev, /NOERASE, XTICKS = 2, XTICKNAME = [' ', ' ', ' ']

      AXIS, /YAXIS, charsize=1.5, charthick=2, /DATA, COLOR = 0, $
        /ZSTYLE, /YSTYLE

    ENDIF

    IF KEYWORD_SET( v ) THEN BEGIN
      PRINT, 'X Begin: ' + STRTRIM( STRING( x1[ 0 ] ), 2 )
      PRINT, 'X End: ' + STRTRIM( STRING( x1[ N_ELEMENTS( x1 ) - 1 ] ), 2 )
      PRINT, 'Y Begin: ' + STRTRIM( STRING( y1[ ybeg[ 0 ] ] ), 2 )
      PRINT, 'Y End: ' + STRTRIM( STRING( y1[ yend[ 0 ] ] ), 2 )
      PRINT, 'Max Level: ' + STRTRIM( STRING( MAX( lev, MIN = mnn ) ), 2 )
      PRINT, 'Min Level: ' + STRTRIM( STRING( mnn ), 2 )
      PRINT, 'Levels: ' + STRTRIM( STRING( nl ), 2 )
    ENDIF

  ENDELSE

END