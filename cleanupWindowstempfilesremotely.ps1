<#
.SYNOPSIS
Remotely cleans up temporary files on a Windows server.

.DESCRIPTION
This script is used to remotely clean up temporary files on a Windows server. It connects to the specified server and deletes temporary files from various locations, including the Windows Temp folder, Prefetch folder, and user-specific temporary folders.

.PARAMETER Server
The name or IP address of the server to perform the cleanup on.

.EXAMPLE
cleanupWindowstempfilesremotely.ps1 -Server "192.168.1.100"
Remotely cleans up temporary files on the server with the IP address 192.168.1.100.

.NOTES
Author: Egberto Zanon
Date: 2021-22-november
Version: 1.0
#>
param(# Parameter help description
    [Parameter(Mandatory = $true)]
    [string]
    $Server)

$before = Invoke-Command -ComputerName $Server { Get-PSDrive C } | Select-Object Free
$tempfolders = @("\\$Server\C$\Windows\Temp\*", "\\$Server\C$\Windows\Prefetch\*", "\\$Server\C$\Documents and Settings\*\Local Settings\temp\*", "\\$Server\C$\Users\*\Appdata\Local\Temp\*")

$freedSpace = 0
foreach ($folder in $tempfolders) {
    $items = Get-ChildItem $folder -Recurse -Force
    foreach ($item in $items) {
        $freedSpace += $item.Length
        Remove-Item $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
    }
}

$after = Invoke-Command -ComputerName $Server { Get-PSDrive C } | Select-Object Free
$freedSpaceInMB = [math]::Round(($before.Free - $after.Free) / 1MB, 2)
Write-Output "Freed space: $freedSpaceInMB MB"