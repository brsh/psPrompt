## Helper Functions for psSysInfo Module


function Find-InUpStreamFolder {
	param (
		[string] $filename
	)
	$pathInfo = Microsoft.PowerShell.Management\Get-Location
	[string] $FileFound = ''

	if ((-not $pathInfo) -or ($pathInfo.Provider.Name -ne 'FileSystem')) {
		$FileFound = ''
	} else {
		[bool] $done = $false
		$curr = Get-Item $PathInfo
		Do {
			$done = $false
			try {
				$TestFor = join-path $curr.FullName "$filename"
				$testing = Test-Path ($TestFor)
				if ($testing) {
					$FileFound = "$TestFor"
					$Done = $true
				} else {
					$curr = $curr.Parent
				}
				if (-not $curr) { $FileFound = ''; $done = $true }
			} catch {
				$FileFound = ''; $done = $true
			}
		} until ($done)
	}
	$FileFound
}


function hid-uptime {
	$wmi = Get-CIMInstance Win32_OperatingSystem
	$retval = (get-date) - ($wmi)[0].LastBootUpTime
	return $retval
}

function hid-exetime {
	$lastCommand = get-history | Select-Object -Last 1
	$sb = [System.Text.StringBuilder]::new()
	if ($lastCommand) {
		try {
			[timespan] $lastTime = $lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime
			if ($lastTime.Days) { [void] $sb.Append(($lastTime.Days).ToString('#0')); [void] $sb.Append(':') }
			if ($lastTime.Hours) { [void] $sb.Append(($lastTime.Hours).ToString('00')); [void] $sb.Append(':') }
			if ($lastTime.Minutes) { [void] $sb.Append(($lastTime.Minutes).ToString('00')); [void] $sb.Append(':') }
			[void] $sb.Append(($lastTime.Seconds).ToString('00'))
			[void] $sb.Append('.')
			$sb.Append($lastTime.Milliseconds.ToString('00'))
		} catch {
			[void] $sb.clear()
			[void] $sb.Append("err")
		}
	}
	#write-host $sb.ToString() -ForegroundColor cyan -NoNewline
	#write-host " xx" -ForegroundColor cyan
	if ($sb.ToString().Length -gt 0) { $sb.ToString() }
}

function hid-PSVer {
	[string] $retval = ""
	$retval = $PSVersionTable.PSVersion.Major.ToString()
	$retval += "."
	$retval += $PSVersionTable.PSVersion.Minor.ToString()
	if ($PSVersionTable.PSVersion.Label) {
		$retval += "-"
		$retval += $PSVersionTable.PSVersion.Label.ToString()
	}
	$retval
}

Function hid-ip {
	#Create/output network info object
	#Borrowed and modded from ps script library
	$WMIhash = @{
		Class       = "Win32_NetworkAdapterConfiguration"
		Filter      = "IPEnabled='$True'"
		ErrorAction = "Stop"
	}

	Get-CimInstance @WMIhash |
	ForEach-Object {
		if ($_.DefaultIPGateway) {
			$InfoHash = @{
				Computername   = $_.DNSHostName
				DefaultGateway = $_.DefaultIPGateway
				DHCPEnabled    = $_.DHCPEnabled
				IPAddress      = $_.IpAddress
				MACAddress     = $_.MACAddress
				WINSPrimary    = $_.WINSPrimaryServer
				WINSSecondary  = $_.WINSSecondaryServer
			}
			$InfoStack = New-Object PSObject -Property $InfoHash
			#Add a (hopefully) unique object type name
			$InfoStack.PSTypeNames.Insert(0, "IP.Information")
			$InfoStack
		}
	}
}

function hid-battery {
	<#
    .SYNOPSIS
        This is a function to pull battery info via WMI.

    .DESCRIPTION
        This function pulls the following information from WMI:
            Computername
            Name
            Description
            BatteryStatus (in numeric form)
            BatteryStatusText (full text)
            BatteryStatusChar (2 char abrev)
            Health
            EstimatedChargeRemaining
            RunTimeMinutes (lots of minutes)
            RunTime (human readable)
            RunTimeSpan (easily translatable)

        Note: This function is used in the prompt

    .PARAMETER  ComputerName
        The name of the computer to query (localhost is default)

    .EXAMPLE
        PS C:\> Get-Battery

    .EXAMPLE
        PS C:\> Get-Battery -ComputerName MyVM

    .EXAMPLE
        PS C:\> Get-Battery MyVM

    .INPUTS
        System.String

    #>
	Param (
		[Parameter(Position = 0)]
		[string] $hostname = "localhost"
	)
	Get-CimInstance -Class win32_Battery | Where-Object { $_.BatteryStatus } | `
		ForEach-Object {
		switch ($_.BatteryStatus) {
			1 { $textstat = "Discharging"; $charstat = "--"; break }
			2 { $textstat = "On AC"; $charstat = "AC"; break } #Actually AC
			3 { $textstat = "Charged"; $charstat = "=="; break }
			4 { $textstat = "Low"; $charstat = "__"; break }
			5 { $textstat = "Critical"; $charstat = "!!"; break }
			6 { $textstat = "Charging"; $charstat = "++"; break }
			7 { $textstat = "Charging/High"; $charstat = "++"; break }
			8 { $textstat = "Charging/Low"; $charstat = "+_"; break }
			9 { $textstat = "Charging/Critical"; $charstat = "+!"; break }
			10 { $textstat = "Undefined"; $charstat = "??"; break }
			11 { $textstat = "Partially Charged"; $charstat = "//"; break }
			Default { $textstat = "Unknown"; $charstat = "??"; break }
		}
		$ts = New-TimeSpan -Minutes $_.EstimatedRunTime
		$InfoHash = @{
			Computername             = $_.PSComputerName
			BatteryStatus            = $_.BatteryStatus
			BatteryStatusText        = $textstat
			BatteryStatusChar        = $charstat
			Name                     = $_.Name
			Description              = $_.Description
			EstimatedChargeRemaining = $_.EstimatedChargeRemaining
			RunTimeMinutes           = $_.EstimatedRunTime
			RunTime                  = '{0:00}h {1:00}m' -f $ts.Hours, $ts.Minutes
			RunTimeSpan              = $ts
			Health                   = $_.Status
		}
		$InfoStack = New-Object -TypeName PSObject -Property $InfoHash

		#Add a (hopefully) unique object type name
		$InfoStack.PSTypeNames.Insert(0, "CPU.Information")

		#Sets the "default properties" when outputting the variable... but really for setting the order
		$defaultProperties = @('Computername', 'Name', 'Description', 'BatteryStatus', 'BatteryStatusText', 'BatteryStatusChar', 'Health', 'EstimatedChargeRemaining', 'RunTimeMinutes', 'RunTime', 'RunTimeSpan')
		$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’, [string[]]$defaultProperties)
		$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
		$InfoStack | Add-Member MemberSet PSStandardMembers $PSStandardMembers

		$InfoStack
	}
}

Function hid-TimeZone {
	<#
    .SYNOPSIS
        This is a function justs lists the Time Zone.

    .DESCRIPTION
        Have you ever wondered if you're in Standard or Daylight time? This function will tell you.

    .EXAMPLE
        PS C:\> Get-TimeZone

    .INPUTS
        None

    #>
	$TimeZone = Get-CimInstance -ClassName Win32_TimeZone

	if ((get-date).IsDaylightSavingTime()) {
		$retval = $TimeZone.DayLightName
	} else {
		$retval = $TimeZone.StandardName
	}
	[regex]::replace($retval, '[^A-Z]', "")
}

function hid-TestWrite {
	[CmdletBinding()]
	param (
		[String] $Path
	)
	$guid = [System.Guid]::NewGuid()
	try {
		$testPath = Join-Path -path $Path -ChildPath $guid
		#[IO.File]::Create($testPath, 1, 'DeleteOnClose') > $null
		Set-Content $testpath -Value $null -ErrorAction Stop
		return $true
	} catch {
		return $false
	} finally {
		Remove-Item $testPath -ErrorAction SilentlyContinue -Force
	}
}

function hid-IsAdmin {
	[bool]$IsAdmin = $false
	if ( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
			new-object Security.Principal.WindowsPrincipal (
				[Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
		).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ) {
		$IsAdmin = $True
	} else {
		$IsAdmin = $False
	}
	$IsAdmin
}

function hid-LastPWD {
	#Check if we've changed directories
	#and make note of it if we have
	if ($null -eq $Global:PWDLast) { $Global:PWDLast = $pwd }
	if ($pwd -ne $Global:PWDCurr) {
		$Global:PWDLast = $Global:PWDCurr
		$Global:PWDCurr = $pwd
	}
}
