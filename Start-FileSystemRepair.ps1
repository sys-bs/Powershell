$computername = Read-Host "Enter computer name"

$Session1 = New-PSSession $computername -Verbose -EnableNetworkAccess

$choice = $null


while ($choice -eq $null) {
    $Choice = Read-Host "Do you want to run basic (1) or full repair (2)? "

}

if (($choice -eq 1) -or ($choice -eq 2 )) {
    $ScriptBlock2 = {Start-Process chkntfs.exe c}
    $scriptBlock3 = {Start-Process chkdsk.exe /sdcleanup}
    $scriptBlock4 = {Start-Process chkdsk.exe /scan}
    $scriptBlock5 = {Start-Process chkdsk.exe /b}

    Invoke-Command -ScriptBlock $scriptBlock2 -Session $Session1 -AsJob -JobName "ChkNTFS"
    Invoke-Command -ScriptBlock $ScriptBlock3 -Session $session1 -AsJob -JobName "checkdisk-garbagecollection"
    Invoke-Command -ScriptBlock $scriptBlock4 -Session $Session1 -AsJob -JobName "Check-bad-blocks"
    Invoke-Command -ScriptBlock $scriptBlock5 -Session $Session1 -AsJob -JobName "checkdisk-cleanbadblaocks"

}

if ($choice -eq 2) {

    $ScriptBlock1 = {DISM.exe /Online /Cleanup-Image /Restorehealth}
    Invoke-Command -ScriptBlock $scriptBlock1 -Session $Session1 -AsJob -JobName "Disim" 

}
elseif ($choice) {
    
}

Exit-PSSession
