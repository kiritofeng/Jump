#SingleInstance force
#NoTrayIcon
Gui, New, -Resize +AlwaysOnTop, Today Is...
Gui, Font, s18, Courier
Gui, Add, Text, vD,%A_MMMM% %A_DD%`, %A_Year%
Gui, Show
Loop
{
	GuiControl,, T, %A_MMMM% %A_DD%`, %A_Year%
	Sleep, 500
}
GuiClose:
	ExitApp