$computername = Read-Host "Enter computer name"

$session = New-CimSession -ComputerName $computername
start-mpscan -ScanType FullScan -CimSession $session -AsJob
Get-CimSession | Remove-CimSession


$session2 = New-PSSession $computername

$ScriptBlock = {Set-MpPreference -CheckForSignaturesBeforeRunningScan $true -Force -ScanParameters 2}
Invoke-Command -ScriptBlock $ScriptBlock -Session $session2 -AsJob
Exit-PSSession
