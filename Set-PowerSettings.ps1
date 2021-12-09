<#
    .SYNOPSIS

    .DESCRIPTION

    .LINK
        The sourcees i used
        (energy star) https://www.energystar.gov/ia/partners/prod_development/revisions/downloads/computer/Version5.0_Computer_Spec.pdf and 
        (extra info) https://helpdesk.flexradio.com/hc/en-us/articles/202118518-Optimizing-Ethernet-Adapter-Settings-for-Maximum-Performance 
        (list of cmd) https://www.majorgeeks.com/content/page/the_ultimate_list_of_every_known_powercfg_command.html 
        (Machine not obeying power settings )https://www.autoitscript.com/forum/topic/85107-set-on-lid-close-power-option/?tab=comments#comment-1173900 
        https://metebalci.com/blog/a-minimum-complete-tutorial-of-cpu-power-management-c-states-and-p-states/

    .NOTES
        Bugs

        TODO
            send all commands as job
            idiot proof the script
            put all items in to fnctions
            add logging
           
            # Advanced NetAdapter Properties
            # Magic decimal values for PnPCapabilities: 0 (default) check 1+2, 256 check 1+2+3, 24 check NOTHING, 10 check 1
            # Magic hex values for PnPCapabilities: 0x0 (default) check 1+2, 0x100 check 1+2+3, 0x18 check NOTHING, 0x16 check 1
            # try/catch to create if the registry setting does not exist
            #$value = 256
#>

function Set-Power {
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
            HelpMessage = "optomize all settings for performance")]
        [Alias('Performance')]
        [switch]$Performace,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "List current power settings")]
        [Alias('list')]
        [switch]$List
    )
    
    begin {

        # Restore Default settings
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "-restoredefaultschemes" -wait

        # Disable hibernation
        Start-Process  -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/H OFF" -wait
    
        # setting sleep timeout
        if (!$num1 -or !$num2) {
            do {
                [int]$num1 = Read-Host "howlong untill the computer goes to sleep on wall power? "
                [int]$num2 = Read-Host "how long unill the computer goes to sleep on Battery power? "
    
            } while (!$num1 -and !$num2)
        }

    
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/change standby-timeout-ac $num1" -wait
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/change standby-timeout-dc $num2" -wait

        # Setting display off timeout
        if (!$num3 -or !$num4) {

            do {
                [int]$num3 = Read-Host "How lng will the monitor stay on on wall power?"
                [int]$num4 = Read-Host "How lng will the monitor stay on on Battery power?"
    
            } while (!$num3 -or !$num4)
        }

        Start-Process  -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/change monitor-timeout-ac $num" -wait
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/change monitor-timeout-dc 15" -wait 
        
    }
    
    process {
        
    }
    
    end {

        Clear-Variable $* -Force -ErrorAction SilentlyContinue
    }
}

function FunctionName (OptionalParameters) {
    
}










$scriptBlock1 = {
}






$scriptBlock2 = {
    $PowerPlans = @("SCHEME_BALANCED", 
        "SCHEME_MAX", 
        "SCHEME_MIN") 

    foreach ($Plan in $PowerPlans) {
        # Disable HDD Sleep while powered on
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setacvalueindex $Plan 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 3600" -wait
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setdcvalueindex $Plan 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 1500" -wait

        # set wireless Adapter settings
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setacvalueindex $Plan 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0" -wait
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setdcvalueindex $Plan 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 2" -wait

        # Disable USB Selective Suspend 
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setacvalueindex $Plan 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0" -wait
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setdcvalueindex $Plan 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0" -wait
        
        # *DO NOT* Allow Hybrid Sleep
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setacvalueindex $Plan 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0" -wait
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setdcvalueindex $Plan 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0" -wait    

        #set intel graphics plan
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setacvalueindex $Plan 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 2" -wait  
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setdcvalueindex $Plan 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 1" -wait  

        #set lid close action
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setacvalueindex $Plan 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0" -wait 
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setdcvalueindex $Plan 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 1" -wait

        #set pci express 
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setacvalueindex $Plan 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0" -wait
        Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "/setdcvalueindex $Plan 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 1" -wait
    }
}








$scriptBlock3 = { 
    # disable unattend sleep (use with caution can caus issues with hibernation)

    Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "-getacvalueindex $Plan sub_sleep 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0" -Wait
    Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "-getdcvalueindex $Plan sub_sleep 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0" -Wait

    Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "-attributes SUB_SLEEP 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 -ATTRIB_HIDE" -Wait # unhide unatended sleep #setting 
    Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "-setacvalueindex $Plan sub_sleep 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 0" -Wait
    Start-Process -FilePath "C:\Windows\System32\powercfg.exe" -ArgumentList "-setdcvalueindex $Plan sub_sleep 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 0" -Wait
}







$scriptBlock4 = {
    # Sets the Wired NIC to the correct WOL settings.
    $adapterNames = (Get-NetAdapter -Physical | Where-Object { $_.name -notlike "*Wireless*" -and $_.name -notlike "*Bluetooth*" })

    foreach ($Adapter in $adapterNames) {
        # Enable Wake on LAN - OS Settings
        $Adapter | Set-NetAdapterPowerManagement -IncludeHidden -ErrorAction stop
        $Adapter | Set-NetAdapterPowerManagement -SelectiveSuspend Disabled -ErrorAction stop -IncludeHidden
        $Adapter | Set-NetAdapterPowerManagement -WakeOnMagicPacket Enabled -ErrorAction stop -IncludeHidden
        $Adapter | Set-NetAdapterPowerManagement -WakeOnPattern Enabled -ErrorAction stop -IncludeHidden

        #$Adapter | Set-NetAdapterPowerManagement -D0PacketCoalescing Enabled Enabled -ErrorAction stop
        
        $Adapter | Set-NetAdapterPowerManagement -ArpOffload Enabled -ErrorAction stop

        
        # Other NIC-specific advanced properties for power management
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Wake on Magic Packet" -DisplayValue "Enabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Wake on pattern match" -DisplayValue "Enabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Shutdown Wake-On-Lan" -DisplayValue "Disabled" -IncludeHidden -ErrorAction SilentlyContinue -Verbose
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Wake on link change" -DisplayValue "Enabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "WOL & Shutdown Link Speed" -DisplayValue "Not Speed Down" -IncludeHidden -ErrorAction silentlycontinue -Verbose    
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Energy Effcient Ethernet" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Link Speed Battery Saver" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Ultra Low Power Mode" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose     
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        $Adapter | Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Advanced EEE" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose



        $value = 0
        try {
            Set-NetAdapterAdvancedProperty -AllProperties -Name ($Adapter.Name) -RegistryKeyword "PnPCapabilities" -RegistryValue $value -ErrorAction stop
        }
        catch {
            New-NetAdapterAdvancedProperty -Name ($Adapter.Name) -RegistryKeyword "PnPCapabilities" -RegistryValue $value -ErrorAction stop
        }
    }
}

$scriptBlock5 = {
    if (($Adapter.InterfaceDescription) -Match "Realtek USB GbE*") {

        # Other NIC-specific advanced properties for power management that we should make sure are set
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Wake on Magic Packet" -DisplayValue "Enabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Wake on pattern match" -DisplayValue "Enabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Shutdown Wake-On-Lan" -DisplayValue "Enabled" -IncludeHidden -ErrorAction SilentlyContinue -Verbose
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Wake on link change" -DisplayValue "Enabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "WOL & Shutdown Link Speed" -DisplayValue "Not Speed Down" -IncludeHidden -ErrorAction silentlycontinue -Verbose

        # Other NIC-specific advanced properties
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Energy Effcient Ethernet" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Link Speed Battery Saver" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Ultra Low Power Mode" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
        Set-NetAdapterAdvancedProperty -Name ($Adapter.Name) -DisplayName "Advanced EEE" -DisplayValue "Disabled" -IncludeHidden -ErrorAction silentlycontinue -Verbose
    }
    else {
        Write-Host -Activity "No Realtek USB GbE adapter. Moving on."
    }
}


Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock1 -AsJob -Verbose | Wait-Job
Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock2 -AsJob -Verbose | Wait-Job
Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock3 -AsJob -Verbose | Wait-Job
Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock4 -AsJob -Verbose | Wait-Job
Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock5 -AsJob -Verbose | Wait-Job

