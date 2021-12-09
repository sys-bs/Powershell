function Verb-Noun {
<#
.SYNOPSIS
    brief summary of the scripts function and purpose
.DESCRIPTION
    detailed summary of the scripts function
.INPUTS
    what switches and inputs are accepted go here
.OUTPUTS
    what outputs are generated if applicable
.EXAMPLE
    example of your script goes here EG verb-noun.ps1 -computername Desktop-jklm123 -Log -confirm etc....
.LINK
    links ot others work if you incorperated others work in to your script
    refrences to research you did
    links to other scripts that are refenced by this script.
.NOTES
    put TODO and Bug fixes here

#>


    [CmdletBinding()]
    param (
        #this is where you insert your paramaters and or set commandline variables

        [Parameter(
            Mandatory = $true, #is it required to proceed
            ValueFromPipeline = $true,#is the input able to be input from a commandline argument
            ValueFromPipelineByPropertyName = $true, #does the argument have a property name.
            HelpMessage = "Enter a single computer name or a List separated by commas.")]
        [Alias('Host,Hosts,CN')]
        [string]$ComputerName, #this is where your commandline variable goes
                                    #This param would read as script.ps1 -computername
                        
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
            HelpMessage = "A 'failsafe' option. Highly unlikely anything will break. This runs basic repair tools as a last ditch effort.")]
        [Alias('Why_me,Repair')]
        [switch]$Safemode

    )
    
    begin {
        # this is where run once items go aka: varaibble initializing ,enumeration of devices
    }
    
    process {
        # this is the body of the script. put all of your monkey motion here.
        
    }
    
    end {
        # this is also a run once block
        # this is where you put your cleanup or message users that there devide is ready for use.
        
    }
}