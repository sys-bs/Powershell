<#
.SYNOPSIS

.DESCRIPTION
    this script will set the audio device and unmute a pc's remote speakers to assist with locating it.
.NOTES
    Prerequisites:
        NuGet provider version '2.8.5.201' or newer
        AudioDeviceCmdlets Module
        folder on admin device C:\IT
        
    this software is provided with the Apache-2.0 license. feel free to use this for personal use, or comercial use.
    
.LINK
    https://community.spiceworks.com/topic/2292318-select-audio-device-with-powershell?page=1#entry-9000652
    https://stackoverflow.com/questions/59393574/how-to-identify-the-default-audio-device-in-powershell
    https://learn.microsoft.com/en-US/dotnet/api/System.Console.Beep?view=net-7.0

    https://learn.microsoft.com/en-us/dotnet/api/system.media.soundplayer?view=windowsdesktop-7.0 
    https://github.com/frgnca/AudioDeviceCmdlets

.EXAMPLE
    
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

    [Parameter( #TODO: Future feature
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Time for computer to make noise")]
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



    #for Debuging
    #$hostname = $env:computername
    #$computer = "Test-computer"
    
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


    Invoke-Command -ComputerName $computer -ScriptBlock { 
        $Sound = new-Object System.Media.SoundPlayer;
        $Sound.SoundLocation = "c:\WINDOWS\Media\Alarm04.wav";
        $Sound.Play(); 
    }

}

#TODO: fix this function to play audio on a rremote machine
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

    #! This is where playing remote audio fails
    Invoke-Command -ComputerName $computer -ScriptBlock { 
        $Sound = new-Object System.Media.SoundPlayer;
        $Sound.SoundLocation = "c:\WINDOWS\Media\Alarm04.wav";
        $Sound.Play(); 
        
    }
 
}


ForEach ($computer in $Computername) {

    if ($alert) {
        start-alert -computername $computer
    }
    elseif ($tone) {
        Install-AudioModule -computer $computer
        Set-VolumeLevel -computer $computer
        start-tone -computer $computer
    }  

}