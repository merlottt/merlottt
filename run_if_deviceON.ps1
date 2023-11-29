<#
.NOTES
===========================================================================
Created with:     Windows PowerShell ISE
Created on:       11/29/2023 12:01 PM
Created by:       dimerlot
Organization:     
Filename:         run_if_deviceON.ps1
===========================================================================
.DESCRIPTION
A description of the file.
#>
$devicename = "*QEMU1*"
$programpath = "C:\windows\notepad.exe"
if (Get-PnpDevice -FriendlyName $devicename -PresentOnly) {
    Write-Output "device enabled"
    Start-Process -FilePath $programpath
} else {
    Write-output "device not found"
    Get-Process | Where-Object {$_.Path -like $programpath} | Stop-Process 
}
