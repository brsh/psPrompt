## Helper Functions for psSysInfo Module

Function TZ-Change($Day, $DayOfWeek, $Month, $Hour) { 
    $CurrentYear = (Get-Date).Year
    #Using the Switch Statements to convert numeric values into more meaningful information.
    Switch ($Day)
     {
      1 {$STNDDay = "First"}
      2 {$STNDDay = "Second"}
      3 {$STNDDay = "Third"}
      4 {$STNDDay = "Fourth"}
      5 {$STNDDay = "Last"}
     }#End Switch ($TimeZone.StandardDay)      
    Switch ($DayOfWeek)
     {
      0 {$STNDWeek = "Sunday"}
      1 {$STNDWeek = "Monday"}
      2 {$STNDWeek = "Tuesday"}
      3 {$STNDWeek = "Wednesday"}
      4 {$STNDWeek = "Thursday"}
      5 {$STNDWeek = "Friday"}
      6 {$STNDWeek = "Saturday"}
     }#End Switch ($TimeZone.StandardDayOfWeek)      
    Switch ($Month)
     {
      1  {$STNDMonth = "January"}
      2  {$STNDMonth = "February"}
      3  {$STNDMonth = "March"}
      4  {$STNDMonth = "April"}
      5  {$STNDMonth = "May"}
      6  {$STNDMonth = "June"}
      7  {$STNDMonth = "July"}
      8  {$STNDMonth = "August"}
      9  {$STNDMonth = "September"}
      10 {$STNDMonth = "October"}
      11 {$STNDMonth = "November"}
      12 {$STNDMonth = "December"}
     }#End Switch ($TimeZone.StandardMonth)

     [DateTime]$SDate = "$STNDMonth 01, $CurrentYear $Hour`:00:00"

     $i = 0
     While ($i -lt $Day) {
       If ($SDate.DayOfWeek -eq $DayOfWeek) {
         $i++
         If ($i -eq $Day) {
           $SFinalDate = $SDate
         }
         Else {
           $SDate = $SDate.AddDays(1)
         }
       }
       Else {
         $SDate = $SDate.AddDays(1)
       }
     }
     
     #Addressing the DayOfWeek Issue "Last" vs. "Forth" when there are only four of one day in a month
     If ($SFinalDate.Month -ne $Month)
      {
       $SFinalDate = $SFinalDate.AddDays(-7)
      }
      return $SFinalDate
}


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
     
    $DDate = TZ-Change $TimeZone.DaylightDay $TimeZone.DaylightDayOfWeek $TimeZone.DaylightMonth $TimeZone.DaylightHour
    $SDate = TZ-Change $TimeZone.StandardDay $TimeZone.StandardDayOfWeek $TimeZone.StandardMonth $TimeZone.StandardHour
    
    $Today = Get-Date
    if (($Today -gt $DDate) -and ($Today -lt $DDate)) {
        $retval=$TimeZone.DayLightName
    }
    else {
        $retval=$TimeZone.StandardName
    }
    [regex]::replace($retval, '[^A-Z]', "")
}