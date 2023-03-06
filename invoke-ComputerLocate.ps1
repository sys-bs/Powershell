<#
.SYNOPSIS
        this script will set the audio device and unmute a pc's remote speakers to assist with locating it.

.DESCRIPTION
    This script is to assist locating computers that are powered on but the location is unknown. 
    the idea is if the computer makes noise at full volume you or your remote hands can locate it and if that fails,
    playing the noise long enough will generate a phone call or service desk ticket.

.PARAMETER -computername
    Name of single computer to run against

.PARAMETER -time
    number of times for the alert to play. this will sleep for 10 seconds after each alert.

.PARAMETER -alert
    set this switch to play C:\WINDOWS\media\Windows Proximity Notification.wav
    the default value is C:\WINDOWS\media\Windows Proximity Notification.wav this will accept any .wav file. GOTO tone.ps1 to change the file played if needed.

.PARAMETER -tone
    set this switch to play C:\WINDOWS\media\Ring03.wav 
    the default value is C:\WINDOWS\media\Ring03.wav this will accept any .wav file. GOTO tone.ps1 to change the file played if needed.


.NOTES
    Prerequisites:
        software
            NuGet provider version '2.8.5.201' or newer
            AudioDeviceCmdlets Module

        Folders
            c:\IT

        Files (located in c:\IT of the admin machine)
            alert.ps1
            tone.ps1


    This software is licensed under the apache 2.0 license.
    There is absolutely no warranty offered or functionality garunteed of my scripts. everything is provided as is, for you to use or modify as you see fit. 
    if any of my work becomes a part of a paid product, please give credit for the part my code plays in your application.
    
.LINK
    https://community.spiceworks.com/topic/2292318-select-audio-device-with-powershell?page=1#entry-9000652
    https://stackoverflow.com/questions/59393574/how-to-identify-the-default-audio-device-in-powershell
    https://learn.microsoft.com/en-US/dotnet/api/System.Console.Beep?view=net-7.0

    https://learn.microsoft.com/en-us/dotnet/api/system.media.soundplayer?view=windowsdesktop-7.0 
    https://github.com/frgnca/AudioDeviceCmdlets

.EXAMPLE
    .\invoke-ComputerLocate.ps1 -Computername $computername -tone -Time 3
    .\invoke-ComputerLocate.ps1 -Computername computer01 -alert -Time 5

#>




[CmdletBinding()]
[ValidateNotNullOrEmpty()]
param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "computer to run against")]
    [Alias('CN,computer')]
    [String[]]$Computername,

    [Parameter( 
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "how many times will the computer play sound on a 10 second interval")]
    [Alias('Time,Duration')] 
    [int]$Time,

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "play very annoying windows alert noise")]
    [Alias('ding')]
    [switch]$alert,

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "play annoying windows alert noise")]
    [switch]$tone
)

#global variables
$hostname = $env:computername

# this gets the audio devices connected to the computer so you can select the relevant output.
function Set-VolumeLevel {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "computer to run against")]
        [Alias('CN,computer')]
        [String]$computer)
    
    #export audio devices on target system
    Invoke-Command -ComputerName $computer -ScriptBlock { Get-AudioDevice -List | Export-clixml -Path C:\IT\AudioDevices.xml } 
    Copy-Item -Path "\\$computer\c$\IT\AudioDevices.xml" -Destination "\\$hostname\c$\IT\AudioDevices.xml"
    Import-Clixml -Path C:\IT\AudioDevices.xml

    #you need to set the audio device as default as future Set-AudioDevice commands only mess with the default audio device.
    Write-Host "enter the index number of the relevant audio device."
    [int]$index = Read-Host "Index No. "

    Invoke-Command -ComputerName $computer -ArgumentList $index -ScriptBlock { 
        param($index)      
        Set-AudioDevice -Index $index -DefaultOnly 
    }

    
    Write-Host "what Volume level do you want to set? EG: 50 for 50%, 100 for 100%"
    [string]$AudioVolume = Read-Host "Volume: "

    Invoke-Command -ComputerName $computer -ArgumentList $AudioVolume -ScriptBlock { 
        param($AudioVolume)    

        set-AudioDevice -PlaybackCommunicationMute $False #unmute the audio device.
        set-AudioDevice -PlaybackCommunicationVolume $AudioVolume #max out the volume to hear the device better
    }
}

#TODO: add switch to remove module
function Install-AudioModule {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "computer to run against")]
        [Alias('CN,computer')]
        [String]$computer)


    Invoke-Command -ComputerName $computer -ScriptBlock { Install-Module -Name AudioDeviceCmdlets -Force }

    #Uninstall-Module -Name AudioDeviceCmdlets
    
}

function start-alert {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "computer to run against")]
        [Alias('CN,computer')]
        [String]$computer)

    $session = New-PSSession $computer
    Invoke-Command -Session $session -ScriptBlock { cd C:\IT; .\Alert.ps1 }
    $session = Exit-PSSession -Verbose

}

function start-tone {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "computer to run against")]
        [Alias('CN,computer')]
        [String]$computer)

    #* v12
    Invoke-Command -Session $session -ScriptBlock { cd C:\IT; .\Tone.ps1 }
}


ForEach ($computer in $Computername) {

    if ($alert) {
        Copy-Item -Path "C:\IT\Alert.ps1" -Destination \\$computer\c$\IT -Force -Verbose
        $session = New-PSSession $computer

        while ($int -le $time) {
            Write-Host "$int"
            Write-Host "pinging $computer "
            start-tone -computer $computer
            Start-Sleep -Seconds 10
            $int ++
        }
        $session = Exit-PSSession -Verbose

    }
    elseif ($tone) {
        Copy-Item -Path "C:\IT\Tone.ps1" -Destination \\$computer\c$\IT -Force -Verbose
        $session = New-PSSession $computer

        Install-AudioModule -computer $computer
        Set-VolumeLevel -computer $computer
        #start-tone -computer $computer

            $int = 0
            while ($int -le $time) {
                Write-Host "$int"
                Write-Host "pinging $computer "
                start-tone -computer $computer
                Start-Sleep -Seconds 10
                $int ++
            }
        $session = Exit-PSSession -Verbose

    }  
}


