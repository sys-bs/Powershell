<#
.SYNOPSIS
    This is a basic overview of what the script is used for..
 
 
.NOTES
    Name:
    Author:
    Version:
    DateCreated:
 
 
.EXAMPLE

 
 
.LINK

#>

function Remove-JunkFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String[]]$computerName
    )
    
    $scriptBlock1 = {Remove-Item "c:\Windows\ccmcache\*" -Force -Recurse -ErrorAction SilentlyContinue}
    $scriptBlock2 = {Remove-Item "c:\Windows\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue}
    $scriptBlock3 = {Remove-Item "c:\temp\*" -Force -Recurse -ErrorAction SilentlyContinue}
    
    Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock1 -AsJob -Verbose | Wait-Job
    Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock2 -AsJob -Verbose | Wait-Job
    Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock3 -AsJob -Verbose | Wait-Job



}
Remove-JunkFiles


#cleanmgr.exe /verylowdisk