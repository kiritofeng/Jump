#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
#NoTrayIcon

if 1 = mute
{
	SoundSet, +1, , mute
	ExitApp
}
if isLegit(1)
{
	SoundSet, %1%
	ExitApp
}
else
{
	SoundGet, Volume
	Gui, New,-SysMenu -Caption +LastFound +AlwaysOnTop +ToolWindow, Volume
	Gui, Add, Slider, x0 y0 w30 h320 Range0-100 gVol vSet Center Vertical Invert TickInterval10 Line2 AltSubmit,% Volume
	Gui, Show, x0 y0
	IfWinActive, Volume
	return
}

isLegit(n) {
	if %n% is integer
	{
		return 1
	}
	else
	{
		if SubStr(%n%, 1, -1) is integer
		{
			if SubStr(%n%, 0) = `%
			{
				return 1
			}
			else
			{
				return 0
			}
		}
		else
		{
			return 0
		}
	}
}

Vol:
	Gui,Submit,NoHide
	SoundSet,% Set
return

GuiEscape:
ExitApp