<#
    <<<<----LICENSE INFO---->>>>
        To summarize:
        This Software is licensed under the Apache License Version 2.0 license. 
        Feel free to use this program personally or comercially or to add functionality to your script.
        All code is provided as is with no warranty and no liability is assumed by me the creator.

    .SYNOPSIS
        this script is pulled from a website (looking for source) and was made to be run remotely. 
        this tool is used to stress computers remotely to try and replicate issues users have while under high cpu load.

    .DESCRIPTION

    .PARAMETER 

    .INPUTS
        [String] -ComputerName accepts string input from pipeline or csv in to an array.
        [switch] -Log logs a transcript of the output to the C:\SCRIPTS folder on your machine
        [switch] -Time accepts any whole int for a time in minutes to run the test

    .OUTPUTS
        this script will leave a output in the C:\SCRIPTS folder on the local machine
    .EXAMPLE
        Reset-Defender -ComputerName Desktop-jkm123 -log

    TODO  

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
        HelpMessage = "Minutes to run test for")]
    [Alias('Time,time')]
    [switch]$Time,

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


function Start-Stress() {
    Begin {

        if (![string]$ComputerName) {
            read-host "Enter computer Name: "
        }

        $session = New-PSSession -ComputerName $computername

        Write-Host "How long do you want the test to run for? "
        [int]$Min = Read-Host "Enter Time in Minutes"
        [int]$Time = [int]$min * 60

    }
    Process {
    
        ForEach ($computer in $computername) {

            $Scriptblock = {
                $NumberOfLogicalProcessors = Get-WmiObject win32_processor | Select-Object -ExpandProperty NumberOfLogicalProcessors
 
                ForEach ($core in 1..$NumberOfLogicalProcessors) { 
     
                    start-job -ScriptBlock {
     
                        $result = 1;
                        foreach ($loopnumber in 1..2147483647) {
                            $result = 1;
            
                            foreach ($loopnumber1 in 1..2147483647) {
                                $result = 1;
                
                                foreach ($number in 1..2147483647) {
                                    $result = $result * $number
                                }
                            }
     
                            $result
                        }
                    }
                }
            }

        }


        Write-Host "Starting stress Jobs"
        Invoke-Command -ScriptBlock $Scriptblock -Session $session -AsJob


        Write-Host "Letting Stress Test run for $min minutes"
        Start-Sleep -Seconds $Time 

        Write-Host "Time has elapsed.... Killing Jobs"
        Invoke-Command -Session $session -ScriptBlock { Stop-Job * }

    }
    end {
        Write-Host "Killing session with remote machine"
        Exit-PSSession

        Write-Host "killing terminal"
        exit

    }

}
Start-Stress -computername $computerName -time $minutes