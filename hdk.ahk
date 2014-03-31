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
DefaultCtrlAltG = {Enter}-don{Enter}{Enter}-ii{Enter}
RegRead, wc3w, HKEY_CURRENT_USER, Software\Blizzard Entertainment\Warcraft III\Video, reswidth
RegRead, wc3h, HKEY_CURRENT_USER, Software\Blizzard Entertainment\Warcraft III\Video, resheight
if(%ErrorLevel% == 1) {
    wc3w = A_ScreenWidth
    wc3h = A_ScreenHeight
}
skill1_x := wc3w * 0.803125
skill1_y := wc3h * 0.95703125
skill2_x := wc3w * 0.85078125
skill3_x := wc3w * 0.9046875
skill4_x := wc3w * 0.9609375
skill5_y := wc3h * 0.8837890625
skill5_x := wc3w * 0.85234375
skill6_x := wc3w * 0.9046875
skill1_h = q
skill2_h = w
skill3_h = e
skill4_h = r
skill5_h = d
skill6_h = f
inv1_h = !q
inv2_h = !w
inv3_h = !e
inv4_h = !r
inv5_h = !d
inv6_h = !f

;--------------------------;
;----------Entry-----------;
;--------------------------;
if !FileExist(IniFile) {
    IniWrite, F8, %IniFile%, Data, ScriptPause
    Loop, 6 {
        skill_h := skill%A_Index%_h
        IniWrite, %skill_h%, %IniFile%, Data, Skill%A_Index%
    }
    Loop, 6 {
        inv_h := inv%A_Index%_h
        IniWrite, %inv_h%, %IniFile%, Data, Inventory%A_Index%
    }
    IniWrite, %DefaultCtrlAltG%, %IniFile%, Data, CtrlAltG
}

IniRead, ScriptPauseH, %IniFile%, Data, ScriptPause, F8
IniRead, skill1_h, %IniFile%, Data, Skill1
IniRead, skill2_h, %IniFile%, Data, Skill2
IniRead, skill3_h, %IniFile%, Data, Skill3
IniRead, skill4_h, %IniFile%, Data, Skill4
IniRead, skill5_h, %IniFile%, Data, Skill5
IniRead, skill6_h, %IniFile%, Data, Skill6
IniRead, inv1_h, %IniFile%, Data, Inventory1
IniRead, inv2_h, %IniFile%, Data, Inventory2
IniRead, inv3_h, %IniFile%, Data, Inventory3
IniRead, inv4_h, %IniFile%, Data, Inventory4
IniRead, inv5_h, %IniFile%, Data, Inventory5
IniRead, inv6_h, %IniFile%, Data, Inventory6
IniRead, CtrlAltG, %IniFile%, Data, CtrlAltG, %DefaultCtrlAltG%

Hotkey, %ScriptPauseH%, ScriptPause
Hotkey, %skill1_h%, Skill
Hotkey, %skill2_h%, Skill
Hotkey, %skill3_h%, Skill
Hotkey, %skill4_h%, Skill
Hotkey, %skill5_h%, Skill
Hotkey, %skill6_h%, Skill
Hotkey, +%skill1_h%, Skill
Hotkey, +%skill2_h%, Skill
Hotkey, +%skill3_h%, Skill
Hotkey, +%skill4_h%, Skill
Hotkey, +%skill5_h%, Skill
Hotkey, +%skill6_h%, Skill
Hotkey, %inv1_h%, Inventory
Hotkey, %inv2_h%, Inventory
Hotkey, %inv3_h%, Inventory
Hotkey, %inv4_h%, Inventory
Hotkey, %inv5_h%, Inventory
Hotkey, %inv6_h%, Inventory

gosub ScriptPause

;--------------------------;
;------Functionality-------;
;--------------------------;
^!g::SendInput, %CtrlAltG%

ScriptPause:
    Suspend, Permit
    if IsPaused = 0
    {
        Hotkey, *~$Enter, , Off
        SetScrollLockState, AlwaysOff
        Suspend, On
        IsPaused = 1
    } else {
        Hotkey, *~$Enter, , On
        SetScrollLockState, AlwaysOn
        Suspend, Off
        IsPaused = 0
    }
return

*~$Enter::
    Suspend, Permit 
    Suspend, Permit
    Suspend, Toggle
    SendInput, {ScrollLock}
return

Inventory:
    if A_ThisHotkey = %inv1_h%
    {
        SendInput, {Numpad7}
    }
    else if A_ThisHotkey = %inv2_h%
    {
        SendInput, {Numpad8}
    }
    else if A_ThisHotkey = %inv3_h%
    {
        SendInput, {Numpad4}
    }
    else if A_ThisHotkey = %inv4_h%
    {
        SendInput, {Numpad5}
    }
    else if A_ThisHotkey = %inv5_h%
    {
        SendInput, {Numpad1}
    }
    else if A_ThisHotkey = %inv6_h%
    {
        SendInput, {Numpad2}
    }
return

Skill:
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

    if ThisHotkey = %skill1_h%
    {
        skill_x = %skill1_x%
        skill_y = %skill1_y%
    }
    else if ThisHotkey = %skill2_h% 
    {
        skill_x = %skill2_x%
        skill_y = %skill1_y%
    }
    else if ThisHotkey = %skill3_h% 
    {
        skill_x = %skill3_x%
        skill_y = %skill1_y%
    }
    else if ThisHotkey = %skill4_h%
    {
        skill_x = %skill4_x%
        skill_y = %skill1_y%
    }
    else if ThisHotkey = %skill5_h%
    {
        skill_x = %skill5_x%
        skill_y = %skill5_y%
    }
    else if ThisHotkey = %skill6_h%
    {
        skill_x = %skill6_x%
        skill_y = %skill5_y%
    }

    SendString := SendString . skill_x . "," . skill_y . "}"
    SendPlay, %SendString%

    MouseMove, mouse_x - 1, mouse_y - 1
    MouseMove, mouse_x, mouse_y
return
