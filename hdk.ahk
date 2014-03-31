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
;----------Entry-----------;
;--------------------------;
#Persistent
#SingleInstance force
#NoEnv

;--------------------------;
;---------Setup------------;
;--------------------------;

; Customize the tray
Menu, Tray, Tip, Hauzer's Dota Keys

; Retrieve the resolution of Warcraft III. If the same isn't present in the registry, use the desktop resolution.
RegRead, wc3w, HKEY_CURRENT_USER, Software\Blizzard Entertainment\Warcraft III\Video, reswidth
RegRead, wc3h, HKEY_CURRENT_USER, Software\Blizzard Entertainment\Warcraft III\Video, resheight

; In my tests, I concluded that some clicks may not work because they actually click "inbetween" pixels,
; making the game unable to detect them! The solution is simply to round the coordinates.
skill1_x := round(wc3w * 0.803125)
skill1_y := round(wc3h * 0.95703125)
skill2_x := round(wc3w * 0.85078125)
skill3_x := round(wc3w * 0.9046875)
skill4_x := round(wc3w * 0.9609375)
skill5_y := round(wc3h * 0.8837890625)
skill5_x := round(wc3w * 0.85234375)
skill6_x := round(wc3w * 0.9046875)
board_x := round(wc3w * 0.985)
board_y := round(wc3h * 0.0583)

; Setup the default data in the .ini file if it doesn't exist, or load otherwise.
IniFile = hdk.ini
if !FileExist(IniFile) {
    pause_h = F8
    skill1_h = q
    skill2_h = w
    skill3_h = e
    skill4_h = r
    skill5_h = d
    skill6_h = f
    skill1ac_h = ^q
    skill2ac_h = ^w
    skill3ac_h = ^e
    skill4ac_h = ^r
    skill5ac_h = ^d
    skill6ac_h = ^f
    inv1_h = !q
    inv2_h = !w
    inv3_h = !e
    inv4_h = !r
    inv5_h = !d
    inv6_h = !f
    board_h = ``
    auto_text = {Enter}-don{Enter}{Enter}-ii{Enter}{Enter}-es{Enter}

    IniWrite, %pause_h%, %IniFile%, Hotkeys, Pause
    Loop, 6
    {
        skill_h := skill%A_Index%_h
        IniWrite, %skill_h%, %IniFile%, Hotkeys, Skill%A_Index%
    }
    Loop, 6
    {
        skillac_h := skill%A_Index%ac_h
        IniWrite, %skillac_h%, %IniFile%, Hotkeys, Skill%A_Index%AutoCast
    }
    Loop, 6
    {
        inv_h := inv%A_Index%_h
        IniWrite, %inv_h%, %IniFile%, Hotkeys, Inventory%A_Index%
    }
    IniWrite, %board_h%, %IniFile%, Hotkeys, Board
    IniWrite, %auto_text%, %IniFile%, Data, AutoText
}
else {
    IniRead, pause_h, %IniFile%, Hotkeys, Pause
    Loop, 6
    {
        IniRead, skill%A_Index%_h, %IniFile%, Hotkeys, Skill%A_Index%
        IniRead, skill%A_Index%ac_h, %IniFile%, Hotkeys, Skill%A_Index%AutoCast
        IniRead, inv%A_Index%_h, %IniFile%, Hotkeys, Inventory%A_Index%
    }
    IniRead, board_h, %IniFile%, Hotkeys, Board
    IniRead, auto_text, %IniFile%, Data, AutoText
}

; Setup hotkeys.
Hotkey, $*%pause_h%, UserPauseScript
Loop, 6
{
    skill_h := skill%A_Index%_h
    Hotkey, $%skill_h%, Skill
    Hotkey, $+%skill_h%, Skill

    skillac_h := skill%A_Index%ac_h
    Hotkey, $%skillac_h%, SkillAutoCast
    Hotkey, $+%skillac_h%, SkillAutoCast

    inv_h :=inv%A_Index%_h
    Hotkey, $%inv_h%, Inventory
    Hotkey, $+%inv_h%, Inventory
}
Hotkey, $*%board_h%, Board

do_autocast = 
is_paused = 0
pause_key = 
is_suspended = 0
; Set up a routine, and needed variables, which will check if the user is playing DotA
RegRead, gamma, HKEY_CURRENT_USER, Software\Blizzard Entertainment\Warcraft III\Video, gamma
is_playing := 0
check_x1 := round(wc3w * 0.68375)
check_y1 := round(wc3h * 0.006)
check_x2 := round(wc3w * 0.70375)
check_y2 := round(wc3h * 0.0316)
check_color := 0xC2B80F + (gamma * 0x10000) + (gamma * 0x100) + gamma
check_color_variation := 30
checks_failed := 0

SetTimer, UpdateState, 300 
SetTimer, CheckIfPlaying, 500

return

;--------------------------;
;------Functionality-------;
;--------------------------;
DisableHotkeys:
    Loop, 6
    {
        skill_h := skill%A_Index%_h
        Hotkey, $%skill_h%, Off
        Hotkey, $+%skill_h%, Off

        skillac_h := skill%A_Index%ac_h
        Hotkey, $%skillac_h%, Off
        Hotkey, $+%skillac_h%, Off

        inv_h :=inv%A_Index%_h
        Hotkey, $%inv_h%, Off
        Hotkey, $+%inv_h%, Off
    }
    Hotkey, $*%board_h%, Off
return

EnableHotkeys:
    Loop, 6
    {
        skill_h := skill%A_Index%_h
        Hotkey, $%skill_h%, On
        Hotkey, $+%skill_h%, On

        skillac_h := skill%A_Index%ac_h
        Hotkey, $%skillac_h%, On
        Hotkey, $+%skillac_h%, On

        inv_h :=inv%A_Index%_h
        Hotkey, $%inv_h%, On
        Hotkey, $+%inv_h%, On
    }
    Hotkey, $*%board_h%, On
return

SuspendScript:
    is_suspended = 1
    SetTimer, CheckIfPlaying, Off
    Hotkey, $*%pause_h%, Off
    gosub DisableHotkeys
return

UnsuspendScript:
    is_suspended = 0
    SetTimer, CheckIfPlaying, On
    Hotkey, $*%pause_h%, On
    if(is_paused = 0)
    {
        gosub EnableHotkeys
    }
return

PauseScript:
    is_paused = 1
    SetScrollLockState, AlwaysOff
    gosub DisableHotkeys
return

UnpauseScript:
    is_paused = 0
    SetScrollLockState, AlwaysOn
    gosub EnableHotkeys
return

UpdateState:
    if(is_suspended = 0)
    {
        IfWinNotActive Warcraft III
        {
            gosub SuspendScript
        }
    }
    else
    {
        IfWinActive Warcraft III
        {
            gosub UnsuspendScript
        }
    }
return

CheckIfPlaying:
    PixelSearch, found_x, found_y, check_x1, check_y1, check_x2, check_y2, check_color, check_color_variation
    if(ErrorLevel = 0)
    {
        checks_failed = 0
        if(is_playing = 0)
        {
            is_playing = 1
            SendInput, {Enter}Hauzer's Dota Keys activated.{Enter}
            SendInput, %auto_text%
            gosub UnpauseScript
        }
    }
    else if(ErrorLevel = 1)
    {
        if(checks_failed >= 6)
        {
            checks_failed = 0
            is_playing = 0
            gosub PauseScript
        }
        else
        {
            ++checks_failed
        }
    }
return

Inventory:
    IfInString, A_ThisHotkey, %inv1_h%
    {
        send_string := "{Numpad7}"
    }
    else IfInString, A_ThisHotkey, %inv2_h%
    {
        send_string := "{Numpad8}"
    }
    else IfInString, A_ThisHotkey, %inv3_h%
    {
        send_string := "{Numpad4}"
    }
    else IfInString, A_ThisHotkey, %inv4_h%
    {
        send_string := "{Numpad5}"
    }
    else IfInString, A_ThisHotkey, %inv5_h%
    {
        send_string := "{Numpad1}"
    }
    else IfInString, A_ThisHotkey, %inv6_h%
    {
        send_string:= "{Numpad2}"
    }
    
    IfInString, A_ThisHotkey, +
    {
        send_string := "+" . send_string
    }
    SendInput, %send_string%
return 

Skill:
    MouseGetPos, mouse_x, mouse_y

    IfInString, A_ThisHotkey, %skill1_h%
    {
        skill_x = %skill1_x%
        skill_y = %skill1_y%
    }
    else IfInString, A_ThisHotkey, %skill2_h% 
    {
        skill_x = %skill2_x%
        skill_y = %skill1_y%
    }
    else IfInString, A_ThisHotkey, %skill3_h% 
    {
        skill_x = %skill3_x%
        skill_y = %skill1_y%
    }
    else IfInString, A_ThisHotkey, %skill4_h%
    {
        skill_x = %skill4_x%
        skill_y = %skill1_y%
    }
    else IfInString, A_ThisHotkey, %skill5_h%
    {
        skill_x = %skill5_x%
        skill_y = %skill5_y%
    }
    else IfInString, A_ThisHotkey, %skill6_h%
    {
        skill_x = %skill6_x%
        skill_y = %skill5_y%
    }

    send_string := "{Click " . do_autocast . " " . skill_x . "," . skill_y . "}"
    do_autocast = 
    IfInString, A_ThisHotkey, +
    {
        send_string := "+" . send_string
    }
    SendPlay, %send_string%
    SendPlay, {Click, %mouse_x%, %mouse_y%, 0}
return

SkillAutoCast:
    do_autocast = right
    gosub Skill
return

Board:
    MouseGetPos, mouse_x, mouse_y
    ; Clicking at a specified position won't work for some reason. It is needed to move and click in separate commands.
    SendPlay, {Click, %board_x%, %board_y%, 0}
    SendPlay, {Click}
    SendPlay, {Click, %mouse_x%, %mouse_y%, 0}
return

~*Enter::
~*LButton::
~*Esc::
UserPauseScript:
    if(is_playing = 0)
    {
        return
    }

    if(is_paused = 0)
    {
        pause_keys := "Enter," . pause_h
        Loop, Parse, pause_keys, `, %A_Space%
        {
            IfInString, A_ThisHotkey, %A_LoopField%
            {
                pause_key := A_ThisHotkey
                gosub PauseScript
                break
            }
        }
    }
    else
    {
        do_unpause = 0
    
        IfInString, pause_key, Enter
        {
            SendInput, {Esc}

            unpause_keys = Enter,Esc,LButton
            Loop, Parse, unpause_keys, `,
            {
                IfInString, A_ThisHotkey, %A_LoopField%
                {
                    do_unpause = 1
                    break
                }
            }
        }
        else IfInString, pause_key, %pause_h%
        {
            IfInString, A_ThisHotkey, %pause_h%
            {
                do_unpause = 1
            }
        }
        
        if(do_unpause = 1)
        {
            gosub UnpauseScript
        }
    }
return
