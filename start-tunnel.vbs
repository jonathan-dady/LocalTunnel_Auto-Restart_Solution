Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "start-tunnel.bat" & chr(34), 0
Set WshShell = Nothing
