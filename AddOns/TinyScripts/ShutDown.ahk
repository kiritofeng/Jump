#SingleInstance force
#NoTrayIcon
if 1 = sleep
{
	msgbox,4,Sleep, Sleep?
	ifmsgbox yes
		DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
}
else if 1 = hibernate
{	
	msgbox,4,Hibernate, Hibernate?
	ifmsgbox yes
		DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
}
else if 1 = logoff
{
	msgbox,20,Log Off,Log Off?
	ifmsgbox yes
		ShutDown, 0
}
else if 1 = restart
{
msgbox,20,Restart,Restart?
	ifmsgbox yes
		ShutDown, 2
}
else
{	
	msgbox,20,Shut Down,Shut Down?
	ifMsgbox yes
		ShutDown, 1+8
}