; Easy Window Dragging -- KDE style (based on the v1 script by Jonny)
; original v1 script: https://www.autohotkey.com/docs/v1/scripts/index.htm#EasyWindowDrag_(KDE)

; this script has been edited, by tsukiongithub, to use the F13 and F14 keys instead of Alt + LButton and Alt + RButton, respectively
; original v2 script: https://www.autohotkey.com/docs/v2/scripts/index.htm#EasyWindowDrag_(KDE)
; repo for my edited version: 

; The shortcuts:
;   F13  : Drag to move a window.
;   F14 : Drag to resize a window.
;   Double-F13   : Minimize a window.
;   (disabled by default)
;
;   Double-F14  : Maximize/Restore a window.
;   (disabled by default)
;

; This is the setting that runs smoothest on my
; system. Depending on your video card and cpu
; power, you may want to raise or lower this value.
SetWinDelay 2
CoordMode "Mouse"

F13::
{
  ; this is here to prevent minimizing hovered window on release
  ; only happens on maximized windows :shrug:
  ;        vvv
  ; KeyWait "F13"
  ; ^^^
  ; uncomment above and below to add minimize functionality
  ; vvv
  ; if (A_PriorHotkey = "F13" and A_TimeSincePriorHotkey < 400)
  ;   {
  ;     KeyWait "F13"
  ;     MouseGetPos ,, &KDE_id
  ;     ; This message is mostly equivalent to WinMinimize,
  ;     ; but it avoids a bug with PSPad.
  ;     PostMessage 0x0112, 0xf020,,, KDE_id
  ;     return
  ;   }
  ; Get the initial mouse position and window id, and
  ; abort if the window is maximized.
  MouseGetPos &KDE_X1, &KDE_Y1, &KDE_id
  if WinGetMinMax(KDE_id)
    return
  if isFullScreen()
    return
  ; Get the initial window position.
  WinGetPos &KDE_WinX1, &KDE_WinY1,,, KDE_id
  Loop
  {
    if !GetKeyState("F13", "P") ; Break if button has been released.
      break
    MouseGetPos &KDE_X2, &KDE_Y2 ; Get the current mouse position.
    KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
    KDE_Y2 -= KDE_Y1
    KDE_WinX2 := (KDE_WinX1 + KDE_X2) ; Apply this offset to the window position.
    KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
    WinMove KDE_WinX2, KDE_WinY2,,, KDE_id ; Move the window to the new position.
  }
}

F14::
{
  ; uncomment below if statement to add maximize/restore toggle on double click

  ; this is here to prevent rapid maximizing/restoring
  ; when holding down the resize key
  ;        vvv
  KeyWait "F14"

  if (A_PriorHotkey = "F14" and A_TimeSincePriorHotkey < 400)
  {
    MouseGetPos ,, &KDE_id
    ; Toggle between maximized and restored state.
    if WinGetMinMax(KDE_id)
      WinRestore KDE_id
    Else
      WinMaximize KDE_id
    return
  }
  ; Get the initial mouse position and window id, and
  ; abort if the window is maximized.
  MouseGetPos &KDE_X1, &KDE_Y1, &KDE_id
  if WinGetMinMax(KDE_id)
    return
  if isFullScreen()
    return
  ; Get the initial window position and size.
  WinGetPos &KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id
  ; Define the window region the mouse is currently in.
  ; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
  if (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
    KDE_WinLeft := 1
  else
    KDE_WinLeft := -1
  if (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
    KDE_WinUp := 1
  else
    KDE_WinUp := -1
  Loop
  {
    if !GetKeyState("F14", "P") ; Break if button has been released.
      break
    MouseGetPos &KDE_X2, &KDE_Y2 ; Get the current mouse position.
    ; Get the current window position and size.
    WinGetPos &KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id
    KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
    KDE_Y2 -= KDE_Y1
    ; Then, act according to the defined region.
    WinMove KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2  ; X of resized window
          , KDE_WinY1 +   (KDE_WinUp+1)/2*KDE_Y2  ; Y of resized window
          , KDE_WinW  -     KDE_WinLeft  *KDE_X2  ; W of resized window
          , KDE_WinH  -       KDE_WinUp  *KDE_Y2  ; H of resized window
          , KDE_id
    KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
    KDE_Y1 := (KDE_Y2 + KDE_Y1)
  }
}

isFullScreen()
{
  WinGetPos &X, &Y, &WinWidth, &WinHeight, "A"
  return (WinWidth WinHeight = A_ScreenWidth A_ScreenHeight)
}
