Param(
		[parameter(Mandatory)]
		[string]$ComputerName
		
	)


	$session = New-CimSession -ComputerName $computername
	start-mpscan -ScanType FullScan -AsJob -CimSession $session

	Get-CimSession | Remove-CimSession

	function Start-scan {
		[CmdletBinding()]
		param (
			
		)
		
		begin {
			
		}
		
		process {
			
		}
		
		end {
			
		}
	}
	Start-scan -computerName $ComputerName