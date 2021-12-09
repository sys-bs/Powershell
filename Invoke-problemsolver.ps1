
$CleanDrivers = { rundll32.exe pnpclean.dll, RunDLL_PnpClean /DRIVERS /MAXCLEAN; }

$SoftReset = {
    net stop bits;
    net stop wuauserv;
    net stop appidsvc;
    net stop cryptsvc;
    
    Remove-Item "C:\ProgramData\Microsoft\Network\*.*" -Force -Recurse;
    Remove-Item "C:\Windows\SoftwareDistribution\*.*" -Force -Recurse;
    Remove-Item "C:\Windows\system32\catroot2\*.*" -Force -Recurse;
    
    regsvr32.exe /s atl.dll;
    regsvr32.exe /s urlmon.dll;
    regsvr32.exe /s mshtml.dll;
    regsvr32.exe /s WUAPI.DLL;
    regsvr32.exe /s ATL.DLL;
    regsvr32.exe /s WUCLTUX.DLL;
    regsvr32.exe /s WUPS.DLL;
    regsvr32.exe /s WUPS2.DLL;
    regsvr32.exe /s WUWEBV.DLL;
    
    netsh winsock reset;
    netsh winsock reset proxy;
    net start bits;
    net start wuauserv;
    net start appidsvc;
    net start cryptsvc;
}

$HardReset = {

    # Stop Services, store later for restarting
    $services = @("UsoSvc", "wuauserv", "BITS", "DoSvc")

    foreach ($service in $services) {
        Stop-Service -Name $service -Force -ErrorAction Stop -Verbose 
    }

    # Delete USOPrivate and other Cached Settings
    Remove-Item "C:\ProgramData\USOPrivate\UpdateStore\*.xml" -Force -Recurse;
    Remove-Item "C:\ProgramData\Microsoft\Network\*.*" -Force -Recurse;
    Remove-Item "C:\Windows\SoftwareDistribution\*.*" -Force -Recurse;
    Remove-Item "C:\Windows\system32\catroot2\*.*" -Force -Recurse;

    #  Remove qmgr files (wuauserv)
    Remove-Item "$env:ALLUSERSPROFILE\Microsoft\Network\Downloader\qmgr0.dat" -Force -Recurse;
    Remove-Item "$env:ALLUSERSPROFILE\Microsoft\Network\Downloader\qmgr1.dat" -Force -Recurse;

    #  Clear Software Distribution files
    Remove-Item "C:\Windows\SoftwareDistribution" -Recurse -Force
    
    # Disable Dual Scanning
    #New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name DisableDualScan -Value 1 -ErrorAction SilentlyContinue

    #  Remove all keys from HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name DeferFeatureUpdate -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name DeferFeatureUpdatePeriodInDays -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name DeferQualityUpdate -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name DeferQualityUpdatePeriodInDays -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name DeferUpgrade -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name ExcludeWUDriversInQualityUpdate -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name PauseFeatureUpdate -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name PauseQualityUpdate -Force -ErrorAction SilentlyContinue 

    #  Remove all keys from HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name BranchReadinessLevel -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name DeferFeatureUpdatesPeriodInDays -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name DeferQualityUpdatesPeriodInDays -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name DeferUpdatePeriod -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name DeferUpgradePeriod -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name ExcludeWUDriversInQualityUpdate -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name PauseDeferrals -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name PauseFeatureUpdates -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update -Name PauseQualityUpdates -Force -ErrorAction SilentlyContinue 

    #  Remove ALL HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings registry keys
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name BranchReadinessLevel -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name DeferFeatureUpdatesPeriodInDays -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name DeferQualityUpdatesPeriodInDays -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name ExcludeWUDriversInQualityUpdate -Force -ErrorAction SilentlyContinue 
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name DeferUpgrade -Force -ErrorAction SilentlyContinue 

    # Restart services, and reset Windows Explorer
    ForEach ($service in $services) { 
        Start-Service -Name $_ -Verbose 
    }
 
    Start-Sleep -Seconds 15 -Verbose #wait for service to start and changes to 
}

$CheckDisk = { chkdsk.exe c: } #does not allways work need to set to run on next boot.
$DISM = { DISM.exe /Online /Cleanup-Image /Restorehealth }
$SFC = { sfc.exe /SCANNOW }

function Invoke-problemsolver {

    <#
    .SYNOPSIS
        remove offending files and perform a hard reset on windows update and its supporting services.

    .DESCRIPTION
        This tool has 3 modes:

            -SafeMode 
                The script will run the following
                SFC.exe /SCANNOW
                chkdsk.exe c: /f
                DISM.exe /Online /Cleanup-Image /Restorehealth

                Fairly safe, this will very rarely break a computer.
            
            -softreset 
                The script will run a functioon to clean out windows update cache and 
                restart the related services. this will also use pnpclean to remove ghost devices that are not connected. but still have drivers loaded.
                Nothing should break but you are messing with the deadly duo of drivers and windows update.

            -HardReset 
                This will run all of the above options and will delete registry keys regarding anyhing thas is a setting for windows update.

                WARNING: this will run all of the commands against this computer. it should rectify the issue but it has the potential to 
                compleetly FUBAR the computer. use only as a last resort and be ready for SCCM, Group Policy and windows update to have a nervous tick aftrewards.

        Reccommended Proceedure:
                this is designed to be a last ditch effort to get a windows update to apply to a machine. only use this if you have tried normal diagnostic routes, removing the old or unused profiles from 

                Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
                Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\ProfileList

                after you have cleaned out old profiles reboot the machine and try again. if this still does not work run this scrip with the -Purgedrivers option. then run the relavent tool for updating your 
                computers drivers. HPIA for HP, DCU for dell. restart the machine and retry the upgrade

                if it fails this time run this script with the -softreset option reboot and try again.

                if it fails again run the script with the -HardReset or -Nukeit option. 
                    *WARNING: this will run all of the commands against this computer. it should rectify the issue but it has the potential to 
                        *compleetly FUBAR the computer. use only as a last resort and be ready for SCCM, Group Policy and windows update to act weird aftrewards.

        


    .PARAMETER -SafeMode
        just repairs the computer. should not break anything
        
    .PARAMETER -Softreset
        runs a soft reset on windowss update including the removal of catroot. nothing should break. fixes most issues.
    .PARAMETER -HardReset
        runs everything. asks no questions. can cause Group policy to break. just run a gpupdate.exe /force to re apply group policy.

    .PARAMETER -Purgedrivers
        runs the $purgedrivers function. this just clears unused drivers from the windows driver store.

    .PARAMETER -computername
        tells the script which computer(s) to run against. will also accept .csv files

    .INPUTS
        [String] -computerName accepts string input from pipeline or .csv
        [switch] -SafeMode
        [switch] -Softreset
        [switch] -HardReset
        [switch] -Purgedrivers

    .OUTPUTS
        this script will leave a output in the C:\SCRIPTS folder on the local machine
    .EXAMPLE
        Invoke-problemsolver -ComputerName Desktop-otjm2123456 -safemode $true -errorlog $true

    TODO
        !# add better detailed comments
        !# create default options
        *# add -confirm fiunctionality to scorched earth
        ?# spelling / grammar    

#>


    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Enter a single computer name or a List separated by commas.")]
        [Alias('Host,Hosts,CN')]
        [string]$ComputerName,
                        
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Log the output to a txt file or not.")]
        [Alias('LogOutput,Log,RecordCarnage')]
        [switch]$errorlog,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "A 'failsafe' option. Highly unlikely anything will break. This runs basic repair tools as a last ditch effort before we mess with risky items")]
        [Alias('Why_me,Repair')]
        [switch]$Safemode,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "This is a 'Safe' option. Nothing should break. but it does mess with windows update ")]
        [Alias('Last_Chance,SoftReset')]
        [switch]$SoftReset,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Nuke everything! This will remove all possible offending files. May break computer! Use as a last resort!")]
        [Alias('Last_resort,Nukeit,IKnowWhatIamDoing')]
        [switch]$HardReset,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "This command removes old drivers that are not in use")]
        [Alias('cleandrivers,nukedrivers,purge')]
        [switch]$PurgeDrivers,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "This exists just incase you have a *linux* moment to provide help with the -h command. ")]
        [Alias('commands,h,H')]
        [switch]$Help
    )



    begin {
        if ($errorlog -eq $true) {
            Start-Transcript "C:\SCRIPTS\WinUpdateReset.log"
        }
        else {
            Write-Host "No carnage will be recorded"
        }
    }
    
    process {
        if ($HardReset) {
            Write-Host "restarting computer please wait"
            Restart-Computer -ComputerName $computername -Force -Verbose -Wait

            Invoke-Command -ScriptBlock $SoftReset -ComputerName $computername -Verbose 
            Invoke-Command -ScriptBlock $HardReset -ComputerName $computername -Verbose 
            Write-Host "restarting computer please wait"

            Restart-Computer -ComputerName $computername -Force -Verbose -Wait

            Invoke-Command -ScriptBlock $CheckDisk -ComputerName $computername -Verbose 
            Invoke-Command -ScriptBlock $DISM -ComputerName $computername -Verbose 
            Write-Host "restarting computer please wait"

            Restart-Computer -ComputerName $computername -Force -Verbose -Wait

            Invoke-Command -ScriptBlock $SFC -ComputerName $computername -Verbose 
            Write-Host "restarting computer please wait"

            Restart-Computer -ComputerName $computername -Force -Verbose -Wait

        }
        elseif ($SoftReset) {
            Invoke-Command -ScriptBlock $SoftReset -ComputerName $computername -Verbose 
            Write-Host "restarting computer please wait"
            Restart-Computer -ComputerName $computername -Force -Verbose -Wait

            Invoke-Command -ScriptBlock $CheckDisk -ComputerName $computername -Verbose 
            Invoke-Command -ScriptBlock $DISM -ComputerName $computername -Verbose 
            Invoke-Command -ScriptBlock $SFC -ComputerName $computername -Verbose 
            Write-Host "restarting computer please wait"

            Restart-Computer -ComputerName $computername -Force -Verbose -Wait
        }
        elseif ($Safemode) {
            Invoke-Command -ScriptBlock $CheckDisk -ComputerName $computername -Verbose 
            Invoke-Command -ScriptBlock $DISM -ComputerName $computername -Verbose 
            Invoke-Command -ScriptBlock $SFC -ComputerName $computername -Verbose 
            Write-Host "restarting computer please wait"

            Restart-Computer -ComputerName $computername -Force -Verbose -Wait
        }
        elseif ($PurgeDrivers) {
            Invoke-Command -ScriptBlock $CleanDrivers -ComputerName $computername -Verbose 

        }
        elseif ($Help) {
            Write-Host "
            .DESCRIPTION
                This tool has 3 modes:
            
                    -SafeMode 
                        The script will run the following
                        SFC.exe /SCANNOW
                        chkdsk.exe c: /f
                        DISM.exe /Online /Cleanup-Image /Restorehealth
            
                        Fairly safe, this will very rarely break a computer.

                    -softreset 
                        The script will run a function to clean out windows update cache and 
                        restart the related services. this will also use pnpclean to remove ghost devices that are not connected. but still have drivers loaded.
                        Nothing should break but you are messing with the deadly duo of drivers and windows update.
            
                    -HardReset 
                        This will run all of the above options and will delete registry keys regarding anyhing thas is a setting for windows update.
            
                        WARNING: this will run all of the commands against this computer. it should rectify the issue but it has the potential to 
                        FUBAR the computer. use only as a last resort and be ready for SCCM, Group Policy and windows update to behave oddly aftrewards.
            
                Reccommended Proceedure:
                        this is designed to be a last ditch effort to get a windows update to apply to a machine. only use this if you have exhausted normal diagnostic routes.
                        
                        For example:
                        removing the old or unused profiles from 
            
                        Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
                        Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\ProfileList
            
                        after removing old profiles reboot the machine and try again. if this still does not work run this script with the -cleandrivers option. then run the relavent tool for updating your 
                        computers drivers. HPIA for HP, DCU for dell. restart the machine and retry the upgrade
            
                        if it fails this time run this script with the -softreset option reboot and try again.
            
                        if it fails again run the script with the -HardReset or -Nukeit option. 
                            *WARNING*: this will run all of the commands against this computer. it should rectify the issue but it has the potential to compleetly FUBAR the computer. use only as a last resort and be ready for SCCM, Group Policy and windows update to act weird aftrewards.
            
            .PARAMETER -SafeMode
                just repairs the computer. should not break anything

            .PARAMETER -Softreset
                runs a soft reset on windowss update including the removal of catroot. nothing should break. fixes most issues.

            .PARAMETER -HardReset
                runs everything. asks no questions. can cause Group policy to break just run a gpupdate.exe /force to re apply group policy.
            
            .PARAMETER -Purgedrivers
                Removes old unused drivers from the driver store.

            .PARAMETER -computername
                tells the script which computer(s) to run against. will also accept .csv files
            
            .INPUTS
               [String] -computerName accepts string input from pipeline or csv.
               [switch] -SafeMode
               [switch] -Softreset
               [switch] -HardReset
               [switch] -Purgedrivers
               [switch] -Help

            
            .OUTPUTS
                this script will leave a output in the C:\SCRIPTS folder on the local machine

            .EXAMPLE
                Invoke-problemsolver -ComputerName $computerName -FinalOption -errorlog
            "

        }
        else {
            Write-Error "No command pramater found."
            Write-Debug "you need to specify a command paramater eg: Invoke-problemsolver -ComputerName 'DNS name' -HardReset -errorlog"
            Write-Host "Bye."

        }
        
    }
    
    end {
        Write-Host "script completed for $computer. Feel free to re attempt the windows upgrade"
        Stop-Transcript
    }
}

#uncoment this to allow this tool 
#Invoke-problemsolver -ComputerName $computerName -FinalOption -errorlog $true