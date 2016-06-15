## Helper Functions for psSysInfo Module

function hid-uptime {
    $wmi = Get-CIMInstance Win32_OperatingSystem
    $retval = (get-date)-($wmi)[0].LastBootUpTime
    return $retval
}



Function hid-ip {
#Create/output network info object
#Borrowed and modded from ps script library
    $WMIhash = @{
        Class = "Win32_NetworkAdapterConfiguration"
        Filter = "IPEnabled='$True'"
        ErrorAction = "Stop"
    } 
    Get-WmiObject @WMIhash | `
        ForEach {
            $InfoHash =  @{
                Computername = $_.DNSHostName
                DefaultGateway = $_.DefaultIPGateway
                DHCPServer = $_.DHCPServer
                DHCPEnabled = $_.DHCPEnabled
                DHCPLeaseObtained = [System.Management.ManagementDateTimeConverter]::ToDateTime($_.DHCPLeaseObtained)
                DHCPLeaseExpires = [System.Management.ManagementDateTimeConverter]::ToDateTime($_.DHCPLeaseExpires)
                DNSServer = $_.DNSServerSearchOrder
                DNSDomain = $_.DNSDomain
                IPAddress = $_.IpAddress
                MACAddress  = $_.MACAddress
                NICDescription = $_.Description
                NICName = $_.ServiceName
                SubnetMask = $_.IPSubnet
                WINSPrimary = $_.WINSPrimaryServer
                WINSSecondary = $_.WINSSecondaryServer
            }
            $InfoStack = New-Object PSObject -Property $InfoHash
            #Add a (hopefully) unique object type name
            $InfoStack.PSTypeNames.Insert(0,"IP.Information")
            $InfoStack
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
        [Parameter(Position=0)]
        [string] $hostname="localhost"     
    )
    Get-WmiObject -Class win32_Battery -ComputerName $hostname | `
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
            $InfoHash =  @{
                Computername = $_.PSComputerName
                BatteryStatus = $_.BatteryStatus
                BatteryStatusText = $textstat
                BatteryStatusChar = $charstat
                Name = $_.Name
                Description = $_.Description
                EstimatedChargeRemaining = $_.EstimatedChargeRemaining
                RunTimeMinutes = $_.EstimatedRunTime
                RunTime = '{0:00}h {1:00}m' -f $ts.Hours,$ts.Minutes
                RunTimeSpan = $ts
                Health = $_.Status
            }
            $InfoStack += New-Object -TypeName PSObject -Property $InfoHash
            
            #Add a (hopefully) unique object type name
            $InfoStack.PSTypeNames.Insert(0,"CPU.Information")

            #Sets the "default properties" when outputting the variable... but really for setting the order
            $defaultProperties = @('Computername', 'Name', 'Description', 'BatteryStatus', 'BatteryStatusText', 'BatteryStatusChar', 'Health', 'EstimatedChargeRemaining', 'RunTimeMinutes', 'RunTime', 'RunTimeSpan')
            $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultProperties)
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
    $TimeZone = Get-WmiObject -Class Win32_TimeZone
     
    if ((get-date).IsDaylightSavingTime()) { 
        $retval=$TimeZone.DayLightName
    }
    else {
        $retval=$TimeZone.StandardName
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
    if( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
          new-object Security.Principal.WindowsPrincipal (
             [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
             ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) )
    {
      $IsAdmin = $True
    } else {
      $IsAdmin = $False
    }
    $IsAdmin
}