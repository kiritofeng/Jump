#SingleInstance force
#NoTrayIcon
FormatTime, Time, , h:mm:ss tt
Gui, New, -Resize +AlwaysOnTop, Time
Gui, Font, s18, Courier
Gui, Add, Text, vT,%Time%
Gui, Show
Loop
{
	FormatTime, Time, , h:mm:ss tt
	GuiControl,, T, %Time%
	Sleep, 100
}
GuiClose:
	ExitApp