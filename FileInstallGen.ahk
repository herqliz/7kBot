if fileexist("FileInstall.ahk")
	filedelete FileInstall.ahk

if fileexist("FileDelete.ahk")
	filedelete FileDelete.ahk
 

tempWorkingdir := "7K"
tempdir := "7K\Img"

fileappend, FileCreateDir `%A_Temp`%\%tempdir%`n,FileInstall.ahk

loop, Img\*.png
{
	fileappend, FileInstall Img\%A_LoopFileName%`, `%A_Temp`%\%tempdir%\%A_LoopFileName%`,`1`n, FileInstall.ahk
	fileappend, FileDelete `%A_Temp`%\%tempdir%\%A_LoopFileName%`n, FileDelete.ahk
}

;fileappend, SetWorkingDir `%A_temp`%\%tempWorkingdir%, FileInstall.ahk
fileappend, FileRemoveDir `%A_temp`%\%tempWorkingdir%`,1,FileDelete.ahk
