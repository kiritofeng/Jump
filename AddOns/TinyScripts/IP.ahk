RunWait, cmd /C ping %1% -n 1 >"%A_Temp%\IP.txt",,Hide
FileReadLine, FRead, %A_TEMP%\IP.txt, 1
Options = 1
IfEqual, FRead, Ping request could not find host %1%. Please check the name and try again.
{
	Options = 16
}
else
{
	FileReadLine, FRead, %A_TEMP%\IP.txt, 2
	StringGetPos, FReadL, FRead, [
	StringGetPos, FReadR, FRead, ]
	FReadR := FReadR - FReadL - 1
	FReadL := FReadL + 2
	StringMid, FRead, FRead, %FReadL%, %FReadR%
}
IfEqual, Options, 1
{
	SetTimer, ChangeButtonNames, 5
	MsgBox, 1, URL to IP, %FRead%
	IfMsgBox, Ok
	{
		clipboard := FRead
	}
}
else
{
	MsgBox, 16 , Error, %FRead%
}
FileDelete, %A_TEMP%\IP.txt

ChangeButtonNames: 
IfWinNotExist, URL to IP
    return
SetTimer, ChangeButtonNames, off 
WinActivate 
ControlSetText, Button1, &Copy
return
