$UpdatesPath = "C:\Updates\*"
$MountPath = “C:\TempMount\Mount”
$WimFile = “C:\TempMount\install.wim”
DISM \Mount-Wim /WimFile:$WimFile /index:1 /Mountdir:$MountPath
$UpdateArray = Get-Item $UpdatesPath
ForEach ($Updates in $UpdateArray)
{
DISM /image:$MountPath /Add-Package /Packagepath:$Updates
Start-Sleep –s 10
}
Write-Host "Updates Applied to WIM"
DISM /Unmount-Wim /Mountdir:$MountPath /commit
DISM /Cleanup-Wim