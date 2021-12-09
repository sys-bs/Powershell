

function Invoke-DCU {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$ComputerName
    )
    
    begin {

        
        $InstallDCU = {
            #install DCU
            set-location "C:\SCRIPTS\DCU\"
            Start-Process "C:\SCRIPTS\DCU\\Dell-Command-Update-Application-for-Windows-10_GRVPK_WIN_4.3.0_A00_03.EXE" -ArgumentList '/s' -Wait -Verbose -NoNewWindow
        }

        $RunDCUx64 = {
            Set-Location "c:\Program Files\Dell\CommandUpdate"
            .\dcu-cli.exe /configure -silent -outputlog=C:\SCRIPTS\DCU\output.log -downloadlocation=C:\SCRIPTS\DCU\ -autosuspendbitlocker=enable # apply settings
            Start-Sleep -Seconds 10

            .\dcu-cli.exe /scan -silent -outputlog=c:\SCRIPTS\DCU\scan.log
            .\dcu-cli.exe /applyupdates -silent -autosuspendbitlocker=enable -reboot=Disable -outputlog=c:\SCRIPTS\DCU\apply.log  

        }

        $RunDCUx32 = {
            Set-Location "\c:\Program` Files` (x86)\Dell\CommandUpdate"
    
            .\dcu-cli.exe /configure -silent -outputlog=C:\SCRIPTS\DCU\output.log -downloadlocation=C:\SCRIPTS\DCU\ -autosuspendbitlocker=enable # apply settings
            Start-Sleep -Seconds 10

            .\dcu-cli.exe /scan -silent -outputlog=c:\SCRIPTS\DCU\scan.log
            .\dcu-cli.exe /applyupdates -silent -autosuspendbitlocker=enable -reboot=Disable -outputlog=c:\SCRIPTS\DCU\apply.log  

        }

        foreach ($Computer in $ComputerName) {
            #copy the DCU app to c:\SCRIPTS
            mkdir "\\$Computer\c$\SCRIPTS\DCU" -Force
            Copy-Item "c:\SCRIPTS\DCU" "\\$Computer\c$\SCRIPTS\" -Force -Recurse -Verbose
        }
    }
    
    process {
         
        foreach ($Computer in $ComputerName) {

            if (((Get-CimInstance Win32_ComputerSystem).Manufacturer) -notlike "Dell Inc." ) {
                write-host "NH# $computer is not a Dell system. skipping......" 
                continue 
            
            }
            #check to see if DCU is installed as x64. if it is check for updates if not skip
            elseif ((Test-Path "\\$Computer\c$\Program` Files\Dell\CommandUpdate") -eq $True) {

                Write-Host "Dell Command update is installed as x64"
                Write-Host "Checking for and installing udates"

                Invoke-Command -ScriptBlock $RunDCUx64 -ComputerName $Computer #-AsJob | Get-Job | Wait-Job  
            }

            #check to see if DCU is installed as x32. if it is check for updates if not skip
            elseif ((Test-Path "\\$Computer\c$\Program` Files` (x86)\Dell\CommandUpdate") -match $true) {
    
                Write-Host "Dell Command update is installed as x86"
                Write-Host "Checking for and installing udates"

                Invoke-Command -ScriptBlock $RunDCUx32 -ComputerName $computerComputername #-AsJob | Get-Job | Wait-Job 

            }

            #if not installed as x32 or x64 run the installer in c/SCRIPTS/DCU
            elseif (((Test-Path "\\$Computer\c$\Program` Files\Dell\CommandUpdate") -and (Test-Path "\\$Computer\c$\Program` Files` (x86)\Dell\CommandUpdate")) -eq $false) {

                Invoke-Command -ScriptBlock $InstallDCU -ComputerName $Computer -AsJob | Get-Job | Wait-Job 
                Write-Host "Dell Command update is installed"
                #Write-Host "please run the script again to check for updates." -BackgroundColor red -ForegroundColor Yellow

                #check to see if DCU is installed as x64. if it is check for updates if not skip
                if ((Test-Path "\\$Computer\c$\Program` Files\Dell\CommandUpdate") -eq $True) {

                    Write-Host "Dell Command update is installed as x64"
                    Write-Host "Checking for and installing udates"

                    Invoke-Command -ScriptBlock $RunDCUx64 -ComputerName $Computer #-AsJob | Get-Job | Wait-Job  
                }

                #check to see if DCU is installed as x32. if it is check for updates if not skip
                elseif ((Test-Path "\\$Computer\c$\Program` Files` (x86)\Dell\CommandUpdate") -match $true) {
    
                    Write-Host "Dell Command update is installed as x86"
                    Write-Host "Checking for and installing udates"

                    Invoke-Command -ScriptBlock $RunDCUx32 -ComputerName $computerComputername #-AsJob | Get-Job | Wait-Job 

                }

            }

            #*stuff* broke
            else {
                Write-Host "something broke on $computer"
            }
        }
    }
    
    end {
        
    }
}

Invoke-DCU