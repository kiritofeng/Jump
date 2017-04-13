#Persistent
#NoEnv
#SingleInstance Force
SetControlDelay, 0
Setworkingdir %A_ScriptDir%

;===== Global Settings =====
iniWidth := 96					;initial width of gui
font = Courier
limit := findLimit(iniWidth)	;number of characters user can type before exceeding the width of the gui
guiWidth := iniWidth + 13*2		; 13 is the unreduceable left-margin spacing between gui and text
RegRead, path, HKEY_CLASSES_ROOT\http\shell\open\command
quote:=
Loop, parse, path
{
		IfEqual A_LoopField, "
		{
			if a_index > 1
			{
				quote:= A_Index
				goto work
			}
		}
}
work:
browserPath:=SubStr(path, 1, quote)
iniRead, hotkeys, settings.ini, hotkeys

if(hotkeys!="ERROR") {
	Loop, parse, hotkeys,`n
	{
		Hotkey, %A_LoopField%, main
	}
}
;===========================

;===== Tray Menu =====
Menu, Tray, NoStandard
Menu, Tray, Tip, Jump
Menu, Tray, Add, Jump, main
Menu, Tray, Add,
Menu, Tray, Add, Run at Startup, startup
Menu, Tray, Add
Menu, Tray, Add, Quit, quit
Menu, Tray, Default, Jump
;=====================
;===== GUI creation =====
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow
GuiHwnd := WinExist()
Gui, Color, FFFFFF
Gui, Font, s11, %font% ;Set a large font size (32-point).
Gui, Add, Text, vMyText cBlack w%iniWidth% center, ;can put LEFT, CENTER, or RIGHT for text alignment
Winset, Transparent, 243
Gui, Submit
;========================

;===== Main Code =====
!`::
#j::
    Gosub, main
return

main:
    Gui, Show, w%guiWidth%
	Gui, Add, Text, cBlack w%iniWidth% center,
    str =
    breakLoop := false
    goSub, enter			;entrance animation
    loop
    {
	    Gosub,inputChar		;input a character and show it on the GUI
	    if breakLoop
		    break
    }
    GoSub, evaluate		;evaluate inputted %str% and take action
    GoSub, exit			;exit animation
return
evaluate:
	if str = exit
		GoSub, quit
	IniRead, lookupLabel, settings.ini, lookups, %str%
	if lookupLabel != ERROR
	{
		IniRead, lookupInput, settings.ini, lookupSettings, %str%_input, %A_Space%
		IniRead, lookupPath, settings.ini, lookupSettings, %str%_path, %A_Space%
		GoSub showLabel
		GoSub inputLookup
		if lookup !=
		{
			position := InStr(lookupInput, "[lookup]","","")
			;length := StrLen("[lookup]")
			position := position - 1
			before := SubStr(lookupInput, 1, position)
			;msgbox BEFORE>>%before%<<
			position := position + 9
			after := SubStr(lookupInput, position,999)
			;msgbox AFTER>>%after%<<
			
			lookupInput := before . lookup . after
			/*
			IniRead, specialOptions, settings.ini, lookups, %str%_special
			if specialOptions != ERROR
				path := lookupInput
			else path := """" . browserPath . """ """ . lookupInput . """"
			msgbox I run `r %path%
			*/
			if lookupPath =
				lookupPath := browserPath
			
			SplitPath, lookupPath, ,workingDir, , ,outDrive 
			
			if outDrive = ;if drive is not specified
				workingDir := A_workingDir . "\" . workingDir ;minor note: you can't include the "\" at the beginning of lookupPath in the ini file or it won't launch. It must be added here, not in the ini.
			;msgbox	browser`r%browserPath%`r     `rpath`r%lookuppath%`r     `rinput`r%lookupinput%`r     `rworkingDir`r%workingdir%
			
			Run %lookupPath% "%lookupInput%", %workingDir%, UseErrorLevel	;quotes are used incase the input has spaces, so it is not treated as more than one parameter
			if ErrorLevel = ERROR
				GoSub, luError
			
		}
	}
	else
	{
		IniRead, shortcut, settings.ini, shortcuts, %str%
		
		if shortcut=ERROR
		{
			if str !=
			{
				GuiControl,, MyText, ???
				sleep 400
			}
				GoSub, exit
		}
		
		IniRead, shortcutSettings, Settings.ini, shortcutSettings, %str%, 0
		if (shortcutSettings != 0)
		{
			cancelRun := false
			; SHORTCUTSETTINGS
			bp := "-bp "	;BrowserPath			;inserts browserpath infront of web url
			wa := "-wa "	;WinActivate			;activates the specified Window title if it exists instead of running the shortcut
			ie := "-ie "	;IfExist				;checks that the directory exists before opening it (i.e. your usb drive)
			wd := "-wd "	;WorkingDir				;runs shortcut with the specified working directory, or tries to determine one automatically with SplitPath
			IfInString, shortcutSettings, bp
			{
				shortcut := BrowserPath . " " . shortcut
				;msgbox shorcut is now `r   %shortcut%
			}
			IfInString, shortcutSettings, wa
			{
				IniRead, title, settings.ini, shortcutSettings, %str%_title, noTITLE!!!!!ZSLHDLIHS
				if title = noTITLE!!!!!ZSLHDLIHS
				{
					msgbox Error. No title specified for activating %shortcut%
					exitApp
				}
				else
				{
					SetTitleMatchMode, 1
					IfWinExist %title%
					{
						WinActivate
						cancelRun := true
					}
				}
			}
			IfInString, shortcutSettings, ie
			{
				IfNotExist %shortcut%
				{
					cancelRun := true
					msgbox This path does not exist:`r%shortcut%
				}
			}
			IfInString, shortcutSettings, wd
			{
				;read workingDir from settings
				IniRead, workingDir, settings.ini, shortcutSettings, %str%_WorkingDir
				
				if workingDir = ERROR	;choose WorkingDir automoatically. This does not work if you use parameters.
					SplitPath, shortcut, ,workingDir
				
				Run %shortcut%, %workingDir%, UseErrorLevel
				if ErrorLevel = ERROR
					goSub, scError
				cancelRun := true
			}
		}
		if (!cancelRun)
			Run %shortcut%, ,UseErrorLevel
			if ErrorLevel = ERROR
				goSub, scError
	}	
	goSub, exit
	
return

;===== Subroutines and Function(s) =====
inputChar:
	Input, char, L1 M,{enter}{space}{backspace}	;input a single character in %char%
	length := StrLen(char)
	if length = 0					;if true, the user has pressed one of the escape characters
	{
		if GetKeyState("Backspace","P")
			goSub, Backspace
		else						;a.k.a the user pressed enter, or space
			breakLoop := true
	}	
	
	charNumber := Asc(char)			;this returns whatever ascii # goes to the character in %char%
	
	if charNumber = 27 				;if the character is the ESC key
	{
		goSub, exit
	}
	
	else if charNumber = 22			;control-v			this section performs as paste from %clipboard%
	{
		str := str . clipboard
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			;if the clipboard causes the string to exceed the original limit
			;	aka if str>limit and (str-clipboard)<limit
			;if the clipboard simply addes to the extension past the original limit
			;	aka if str>limit and (str-clipboard)>limit
			if (StrLen(str)-StrLen(clipboard)) < limit			;pasting caused the string to exceed original %limit% (which never changes)
				theNumberOfOverFlowingCharacters := StrLen(str)-limit
			else if (StrLen(str)-StrLen(clipboard)) > limit		;pasting caused the string to add to the extension of the %limit%
				theNumberOfOverFlowingCharacters := StrLen(clipboard)
			loop %theNumberOfOverFlowingCharacters%
				GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
	}
	
	else if charNumber = 21				;control-U
	{
		str := str . "_"
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
		;check if activated lookup if char = space
	}
	else if charNumber = 3				;control-C		this section puts %str% in the clipboard and exits	
	{
		clipboard := str
		str = copied
		GuiControl,, MyText, %str%
		sleep 600
		GoSub, exit
	}
	
	else if charNumber > 31				;if the user inputted a normal character (all the nonsensical control characters are below 37)
	{
		str := str . char
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
	}
return

backspace:
	StringTrimRight, str, str, 1	;remove a character from the right side of %str%
	GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
	if StrLen(str) >= limit
		GoSub, decrementWidth
return


incrementWidth:
	guiWidth := guiWidth+8
	iniWidth := iniWidth+8
	Gui, Show, w%guiWidth% xCenter	;add xCenter if you want the box to be recentered for each resize
	GuiControl, Move, MyText, W%iniWidth%
return

decrementWidth:
	guiWidth := guiWidth-8
	iniWidth := iniWidth-8
	Gui, Show, w%guiWidth% xCenter	;add xCenter if you want the box to be recentered for each resize
	GuiControl, Move, MyText, W%iniWidth%
return

enter:
	Gui, Show, y-50 			;show window off-screenl
	WinGetPos,,,,height, A	 	;store GUI height (last parameter is the gui's title)
	Y := -height
	Gui, Show, xCenter y%Y% w%guiWidth%, %A_ScriptFullPath%	;position GUI just above top border
	increment := 5
	while Y < -increment		;increment gui into position
	{
		Y := Y + increment
		Gui, Show, y%Y%
		sleep 20
	}
	Gui, Show, y0 NoActivate
return

exit:
	Gosub, hide
exit

findLimit(iniWidth) {
	if (iniWidth/8 - round(iniWidth/8)) = 0
	{
		return iniWidth/8
	}
	else
	{
		return iniWidth/8 - 1
	}
}
showLabel:
	lookupkey := str				;error proccessing
	str := lookupLabel
	GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
return

hide:
    Y := 0
	while Y > (0-height)
	{
		Y := Y - 3
		Gui, Show, y%Y% NoActivate
		sleep 20
	}
	GuiControl,, MyText,
	Gui, Cancel
	iniWidth := 96
	limit := findLimit(iniWidth)
    guiWidth := iniWidth + 13*2	
	Gui, Show, w%guiWidth% xCenter	;add xCenter if you want the box to be recentered for each resize
	GuiControl, Move, MyText, W%iniWidth%
return

inputChar4Lookup:
	Input, char, L1 M,{enter}{backspace}	;input a single character in %char%
	length := StrLen(char)
	if length = 0					;if true, the user has pressed enter, because enter is the escape character for the "Input" command
	{
		if GetKeyState("Backspace","P")
			goSub, Backspace
		else {
			StringRight, lookup, str, StrLen(str) - StrLen(lookupLabel)	;remove the label from %str% and output to %lookup%
			breakLoop := true
			Goto, end_of_subroutine
		}
	}	
	;msgbox You pressed %char%
	;Asc("")					;this would return 27 and corresponds to the ESC key
	charNumber := Asc(char)			;this returns whatever ascii # goes to the character in %char%
	
	if charNumber = 27 				;if the character is the ESC key
		goSub, exit
	
	else if charNumber = 22			;control-v			this section performs as paste from %clipboard%
	{
		str := str . clipboard
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			if StrLen(clipboard)>1000
			{	msgbox, clipboard is too large
				exitApp
			}
			
			if (StrLen(str)-StrLen(clipboard)) < limit			;pasting caused the string to exceed original %limit% (%limit% never changes after initial creation)
				theNumberOfOverFlowingCharacters := StrLen(str)-limit
			else if (StrLen(str)-StrLen(clipboard)) > limit		;pasting caused the string to add to the extension of the %limit%
				theNumberOfOverFlowingCharacters := StrLen(clipboard)
			loop %theNumberOfOverFlowingCharacters%
				GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
	}
	else if charNumber < 31
	{
		goSub, end_of_subroutine
	}
	
	else
	{
		str := str . char
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
		;check if activated lookup if char = space
	}
	end_of_subroutine:
return

inputLookup:
	breakLoop := false
	loop
	{
		GoSub inputChar4Lookup
		if breakLoop
			break
	}
return

GuiDropFiles:
	IniRead, shortcut, settings.ini, shortcuts, %str%
	if shortcut=ERROR
	{
		if str !=
		{
			GuiControl,, MyText, ???
			sleep 400
		}
			GoSub, exit
	}
	Loop, parse, A_GuiEvent, `n
	{
		Run "%shortcut%" "%A_LoopField%"
		Break
	}
	gosub, exit
return
quit:
	WinGetPos,,gui_y,,, ahk_id %GuiHwnd%
	if(y > 0) {
		Gosub, exit
	}
ExitApp

scError:
	MsgBox, 20, Invalid Shortcut, Invalid shortcut detected. Would you like to delete?
	IfMsgBox Yes
	{
		IniDelete, settings.ini, shortcuts, %str%
	}
	goSub, exit
return

luError:
	MsgBox, 20, Invalid Lookup, Invalid lookup detected. Would you like to delete?
	IfMsgBox Yes
	{
		IniDelete, settings.ini, lookups, %lookupKey%
		IniDelete, settings.ini, lookupSettings, %lookupKey%_input
		IniDelete, settings.ini, lookupSettings, %lookupKey%_path
	}
	goSub, exit
return

startup:
Menu,Tray,Togglecheck,Run At Startup
IfExist, %a_startup%/Jump.lnk
	FileDelete,%a_startup%/Jump`.lnk
else
	FileCreateShortcut,%A_ScriptFullPath%,%A_Startup%/Jump.lnk
return