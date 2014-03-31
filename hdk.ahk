; HDK - A keys remapper for DotA
; Copyright (C) 2012  hauzer
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along
; with this program; if not, write to the Free Software Foundation, Inc.,
; 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

;--------------------------;
;---------Setup------------;
;--------------------------;
#IfWinActive Warcraft III
#SingleInstance force
SetBatchLines, -1
;Process, Priority, , AboveNormal
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0

;--------------------------;
;--------Variables---------;
;--------------------------;
IsPaused = 0
IniFile = hdk.ini
DefaultCtrlAltG = {Enter}-weather snow{Enter}{Enter}-water blue{Enter}{Enter}-don{Enter}{Enter}-ii{Enter}
RegRead, wc3w, HKEY_CURRENT_USER, Software\Blizzard Entertainment\Warcraft III\Video, reswidth
RegRead, wc3h, HKEY_CURRENT_USER, Software\Blizzard Entertainment\Warcraft III\Video, resheight
if(%ErrorLevel% == 1) {
    wc3w = A_ScreenWidth
    wc3h = A_ScreenHeight
    MsgBox, 64, Warcraft III Registry Error, Warcraft III video data could not be found! Using current system resolution., 10
}
skill1_x := wc3w * 0.803125
skill1_y := wc3h * 0.95703125
skill2_x := wc3w * 0.85078125
skill3_x := wc3w * 0.9046875
skill4_x := wc3w * 0.9609375
skill5_y := wc3h * 0.8837890625
skill5_x := wc3w * 0.85234375
skill6_x := wc3w * 0.9046875

;--------------------------;
;----------Entry-----------;
;--------------------------;
IfNotExist, %IniFile%
    IniWrite, %DefaultCtrlAltG%, %IniFile%, Data, CtrlAltG
IniRead, CtrlAltG, %IniFile%, Data, CtrlAltG, %DefaultCtrlAltG%

gosub F8

;--------------------------;
;------Functionality-------;
;--------------------------;
^!g::SendInput, %CtrlAltG%

F8::
    Suspend, Permit
    if IsPaused = 0
    {
        Hotkey, ~$Enter, , Off
        Hotkey, ~$+Enter, , Off
        Hotkey, ~$^Enter, , Off
        SetScrollLockState, AlwaysOff
        Suspend, On
        IsPaused = 1
    } else {
        Hotkey, ~$Enter, , On
        Hotkey, ~$+Enter, , On
        Hotkey, ~$^Enter, , On
        SetScrollLockState, AlwaysOn
        Suspend, Off
        IsPaused = 0
    }
return

~$Enter::
~$+Enter::
~$^Enter::
    Suspend, Permit
    Suspend, Toggle
    SendInput, {ScrollLock}
return

!q::SendInput, {Numpad7}
!w::SendInput, {Numpad8}
!e::SendInput, {Numpad4}
!r::SendInput, {Numpad5}
!d::SendInput, {Numpad1}
!f::SendInput, {Numpad2}

q::
w::
e::
r::
d::
f::
+q::
+w::
+e::
+r::
+d::
+f::
    MouseGetPos mouse_x, mouse_y

    ThisHotkey = %A_ThisHotkey%
    StringLeft, IsShift, ThisHotkey, 1
    SendString = 
    if IsShift = +
    {
        StringRight, ThisHotkey, ThisHotkey, 1
        SendString = +
    }
    SendString := SendString . "{Click "

    if ThisHotkey = q
    {
        skill_x = %skill1_x%
        skill_y = %skill1_y%
    }
    else if ThisHotkey = w 
    {
        skill_x = %skill2_x%
        skill_y = %skill1_y%
    }
    else if ThisHotkey = e 
    {
        skill_x = %skill3_x%
        skill_y = %skill1_y%
    }
    else if ThisHotkey = r
    {
        skill_x = %skill4_x%
        skill_y = %skill1_y%
    }
    else if ThisHotkey = d
    {
        skill_x = %skill5_x%
        skill_y = %skill5_y%
    }
    else if ThisHotkey = f
    {
        skill_x = %skill6_x%
        skill_y = %skill5_y%
    }

    SendString := SendString . skill_x . "," . skill_y . "}"
    SendPlay, %SendString%

    MouseMove, mouse_x - 1, mouse_y - 1
    MouseMove, mouse_x, mouse_y
return
