##
## Leveragd from 
## http://www.the-little-things.net/blog/2015/10/03/powershell-thoughts-on-module-design/
##
#region Private Variables
# Current script path
[string]$ScriptPath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent
#endregion Private Variables
 
#region Methods
 
# Dot sourcing private script files
Get-ChildItem $ScriptPath/private -Recurse -Filter "*.ps1" -File | Foreach { 
    . $_.FullName
}
 
function prompt {
    if ($?) {
        #Sets the line color to Calm, No Error
        $ColorERR = "Yellow"
    } else {
        #Sets the line color to Panic, Error!
        $ColorERR = "Red"
    }
    # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
    [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
    # Also, put the path in the title ... (don't restrict this to the FileSystem

    $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix,$pwd.Path,$pwd.Provider.Name
    $ColorFG = $Host.UI.RawUI.ForegroundColor
    $ColorBG = $Host.UI.RawUI.BackgroundColor

    $line = $('─' * (($Host.UI.RawUI.WindowSize.Width)-1))

    $uppity = (hid-uptime)

    $batt = (hid-battery)
    $battstat = $batt[0].BatteryStatusChar

    $tz = hid-timezone


    Write-Host " "
    write-host $line -ForegroundColor $ColorERR

    #Optional Info
    #[PS $($host.version.Major.ToString() + "." + $host.version.minor.ToString())]


    #Uptime
    #Piece together the length of Uptime so we can right-justify the time
    #Futz it a little, using length of the non-DateTime chars
    $tLength = "[up d 00:00m:00s]".Length + "[ddd hh:mm?m]".Length + $tz.Length + 1
    $tLength += (($uppity.days).ToString.Length) + $(($uppity).ToString('hh').Length)
    Write-Host "[up " -Fore "White" -NoNewLine
    Write-Host "$($uppity.days)" -Fore "Green" -NoNewLine
    Write-Host "d " -Fore "White" -NoNewLine
    Write-Host "$(($uppity).ToString('hh'))" -Fore "Green" -NoNewLine
    Write-Host "h:" -Fore "White" -NoNewLine
    Write-Host "$(($uppity).ToString('mm'))" -Fore "Green" -NoNewLine
    Write-Host "m:" -Fore "White" -NoNewLine
    Write-Host "$(($uppity).ToString('ss'))" -Fore "Green" -NoNewLine
    Write-Host "s]" -Fore "White" -NoNewLine

    #Battery
    If (($batt.EstimatedChargeRemaining -ne 100)) {
        #Battery Length
        $tLength += " [bat ##% ?? h m]".Length
        $tLength += $batt[0].RunTimeSpan.Hours.ToString().Length
        $tLength += $batt[0].RunTimeSpan.Minutes.ToString().Length
        #Write the blanks to right justify
        Write-Host (' ' * (($Host.UI.RawUI.WindowSize.Width) - $tLength)) -NoNewLine
        Write-Host "[bat " -Fore "White" -NoNewLine
        if (($batt.EstimatedChargeRemaining) -gt 30) {
            Write-Host "$($batt[0].EstimatedChargeRemaining)" -Fore "Green" -NoNewLine
        }
        else {
            Write-Host "$($batt[0].EstimatedChargeRemaining)" -Fore "Yellow" -NoNewLine
        }
        Write-Host "% " -Fore "White" -NoNewLine
        Write-Host "$battstat " -Fore "Yellow" -NoNewLine
        Write-Host $batt[0].RunTimeSpan.Hours -Fore "Green" -NoNewline
        Write-Host "h " -Fore "White" -NoNewLine
        Write-Host $batt[0].RunTimeSpan.Minutes -Fore "Green" -NoNewline
        Write-Host "m" -Fore "White" -NoNewLine

        Write-Host "] " -Fore "White" -NoNewline
    }
    else {
        #skip the battery and just write the blanks to right justify
        Write-Host (' ' * (($Host.UI.RawUI.WindowSize.Width) - $tLength)) -NoNewLine
    }

    #Day and Time
    Write-Host "[" -Fore "White" -NoNewLine
    Write-Host "$((get-date).ToString('ddd')) " -Fore "Green" -NoNewLine
    Write-Host "$((get-date).ToString('hh:mmtt ').ToLower())" -Fore "Yellow" -NoNewLine
    Write-Host $tz.Trim() -NoNewline
    Write-Host "]" -Fore "White"

    #Current Directory
    #Use ~ if it's the home path
    $tPath = $pwd.Path
    $tPath = $tPath.Replace("$env:USERPROFILE", "~")
    $tLength = ("[][@]".Length + ($tPath.Length) + $env:username.Length + $env:computername.Length) + 1
    Write-Host "[" -Fore "White" -NoNewLine
    Write-Host "$tPath" -ForegroundColor "Cyan" -NoNewLine
    Write-Host "]" -Fore "White" -NoNewLine

    #Now let's use that futzed length to add some spaces before displaying the who@where
    if($IsAdmin) { $tLength += " as ADMIN".Length }
    
    Try {
        $tIP = hid-ip
    }
    Catch {
        $tIP = $null
    }
    if ($tIP -ne $null ) {
        #Yay, we have network info - split it down to just the 1st ipv4 address
        $tIP = $tIP[0].IPAddress[0]
        $tLength += ("[] ".Length + $tIP.Length)

        #Write the spaces...
        Write-Host (' ' * (($Host.UI.RawUI.WindowSize.Width) - $tLength)) -NoNewLine

        #IP Address
        Write-Host "[" -Fore "White" -NoNewLine
        Write-Host "$tIP" -Fore "Yellow" -NoNewLine
        Write-Host "] " -Fore "White" -NoNewLine
    }
    else {
        #Skip the ip section and just write the spaces...
        Write-Host (' ' * (($Host.UI.RawUI.WindowSize.Width) - $tLength)) -NoNewLine
    }


    #Username @ machine
    Write-Host "[" -Fore "White" -NoNewLine
    Write-Host "$env:username" -Fore "Green" -NoNewLine
    Write-Host "@" -Fore "White" -NoNewLine
    Write-Host "$(($env:computername).ToLower())" -Fore "Magenta" -NoNewLine

    if($IsAdmin) { Write-Host " as ADMIN" -Fore "Red" -NoNewLine }
    Write-Host "]" -Fore "White" 

    Write-Host $line -ForegroundColor $ColorERR
    Write-Host ">" -NoNewLine -Fore $ColorFG -BackgroundColor $ColorBG
    
    return " "
 }

Export-ModuleMember -function prompt



###################################################
## END - Cleanup
 
#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
    # cleanup when unloading module (if any)
    dir alias: | Where-Object { $_.Source -match "psPrompt" } | Remove-Item
    dir function: | Where-Object { $_.Source -match "psPrompt" } | Remove-Item
}
#endregion Module Cleanup