@echo off
echo Stopping MAXie preview processes...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Process | Where-Object { $_.ProcessName -in @('MAXie','electron') -and ($_.Path -like '*\Maxie\*' -or $_.Path -eq $null) } | Stop-Process -Force"
echo Done. You can start MAXie again with npm.cmd start.
