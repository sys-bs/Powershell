<#
    <<<<----LICENSE INFO---->>>>
        To summarize:
        This Software is licensed under the Apache License Version 2.0 license. 
        Feel free to use this program personally or comercially or to add functionality to your script.
        All code is provided as is with no warranty and no liability is assumed by me the creator. Use at your  own discretion.

    .SYNOPSIS
        this script was developed because sccm will fail to run a hardware scan on a computer sometimes due to corrupted malware deffinitions.
        this script will purge the deffinitions, update the deffinitions and re run a full scan on the device to remediate the issue.

    .DESCRIPTION

    .PARAMETER 

    .INPUTS
        [String] -ComputerName accepts string input from pipeline or csv in to an array.
        [switch] -Log logs a transcript of the output to the C:\SCRIPTS folder on your machine

    .OUTPUTS
        this script will leave a output in the C:\SCRIPTS folder on the local machine
    .EXAMPLE
        Reset-Defender -ComputerName Desktop-jkm123 -log

    TODO  

#>


function Reset-Defender {

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
        [Alias('LogOutput,Log')]
        [switch]$errorlog,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "This exists just incase you have a *linux* moment to provide help with the -h command. ")]
        [Alias('commands,h,H')]
        [switch]$Help
    )

    Begin {
        if (!$ComputerName) {
            [string]$ComputerName = read-host "Enter computer Name: "
        }

        $ScriptBlock = {  
            Set-Location 'c:\Program Files\Windows Defender\'
            Start-Process 'MpCmdRun.exe' -ArgumentList "-RemoveDefinitions -All" -Wait -Verbose -ErrorAction Stop 
            Start-Process 'MpCmdRun.exe' -ArgumentList "-SignatureUpdate " -Wait -Verbose -ErrorAction Stop
            Start-Process 'MpCmdRun.exe' -ArgumentList "-scan 2 " -Wait -Verbose -ErrorAction SilentlyContinue
        }
    }
    process {


        if ($Log) {
            Mkdir C:\SCRIPTS\
            Start-Transcript -Path C:\SCRIPTS -Append -Force
        
        }
        elseif (!$Log) {
            Write-Host "No transcript will be created. Script started without -Log Switch."
        }
        elseif ($Help) {
            Write-Host "<#
            <<<<----LICENSE INFO---->>>>
                To summarize:
                This Software is licensed under the Apache License Version 2.0 license. 
                Feel free to use this program personally or comercially or to add functionality to your script.
                All code is provided as is with no warranty and no liability is assumed by me the creator.
        
            .SYNOPSIS
                this script was developed because sccm will fail to run a hardware scan on a computer sometimes due to corrupted malware deffinitions.
                this script will purge the deffinitions, update the deffinitions and re run a full scan on the device to remediate the issue.
        
            .DESCRIPTION
        
            .PARAMETER 
        
            .INPUTS
                [String] -ComputerName accepts string input from pipeline or csv in to an array.
                [switch] -Log logs a transcript of the output to the C:\SCRIPTS folder on your machine
        
            .OUTPUTS
                this script will leave a output in the C:\SCRIPTS folder on the local machine
            .EXAMPLE
                Reset-Defender -ComputerName Desktop-jkm123 -log
        
            TODO  
        
        #>"
        }
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -Verbose -AsJob
        
    }
    end {
        #Msc Garbage collection.
    Stop-Transcript -Verbose
    Clear-Variable * -Verbose -Force -ErrorAction SilentlyContinue
    Exit-PSHostProcess -Verbose -ErrorAction SilentlyContinue
    exit
    }
}

Reset-Defender -computername $computername -log