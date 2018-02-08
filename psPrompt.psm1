##
## Module Design leveragd from
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

function Set-PromptDefaults {
	<#
    .SYNOPSIS
        Reset prompt to default settings

    .DESCRIPTION
        While the prompt settings are somewhat simple, there are few (read: no) safeguards to keep from setting something wrong (or just ugly). This function resets the prompt to the defaults - either those in the script or those set via the .psprompt.ini file in the users profile directory.

    .EXAMPLE
        PS C:\> Set-PromptDefaults

    .LINK
        https://github.com/brsh/psPrompt

    #>

	$global:psPromptSettings = New-Object PSObject -Property @{
		PromptOn             = $true
		UptimeOn             = $true
		TestDirRW            = $true
		GitOn                = $true
		GitFileStatus        = $true
		PSVersionOn          = $true
		ExecutionTimeOn      = $true
		BatteryOn            = $true

		LineTopOn            = $true
		LineBottomOn         = $true
		ExtraBlanksToStart   = 1

		DefaultForeColor     = $Host.UI.RawUI.ForegroundColor
		DefaultBackColor     = $Host.UI.RawUI.BackgroundColor

		ErrorForeColor       = [ConsoleColor]::Red
		ErrorBackColor       = $Host.UI.RawUI.BackgroundColor

		AdminForeColor       = [ConsoleColor]::Red
		AdminBackColor       = $Host.UI.RawUI.BackgroundColor

		HeadForeColor        = [ConsoleColor]::White
		HeadBackColor        = $Host.UI.RawUI.BackgroundColor

		Info1ForeColor       = [ConsoleColor]::Green
		Info1BackColor       = $Host.UI.RawUI.BackgroundColor

		Info2ForeColor       = [ConsoleColor]::Yellow
		Info2BackColor       = $Host.UI.RawUI.BackgroundColor

		Info3ForeColor       = [ConsoleColor]::Magenta
		Info3BackColor       = $Host.UI.RawUI.BackgroundColor

		frameOpener          = '['
		frameCloser          = ']'
		frameSeparator       = '@', ':', '>'
		frameLine            = '─'
		frameForeColor       = [ConsoleColor]::White
		frameBackColor       = $Host.UI.RawUI.BackgroundColor
		frameLineForeColor   = [ConsoleColor]::Yellow
		frameLineBackColor   = $Host.UI.RawUI.BackgroundColor
		frameSpacer          = ' '
		frameSpacerForeColor = $Host.UI.RawUI.ForegroundColor
		frameSpacerBackColor = $Host.UI.RawUI.BackgroundColor
	}


	#Read from personal settings file (if present)
	if (test-path $env:USERPROFILE\.psprompt.ini) {
		get-content $env:USERPROFILE\.psprompt.ini | ForEach-Object {
			$parts = $_.Split('=').Trim()
			switch ($parts[0]) {
				"PromptOn" { $global:psPromptSettings.PromptOn = $parts[1] -match "true" }
				"UptimeOn" { $global:psPromptSettings.UptimeOn = $parts[1] -match "true" }
				"TestDirRW" { $global:psPromptSettings.TestDirRW = $parts[1] -match "true" }
				"GitOn" { $global:psPromptSettings.GitOn = $parts[1] -match "true" }
				"GitFileStatus" { $global:psPromptSettings.GitFileStatus = $parts[1] -match "true" }
				"PSVersionOn" { $global:psPromptSettings.PSVersionOn = $parts[1] -match "true" }
				"ExecutionTimeOn" { $global:psPromptSettings.ExecutionTimeOn = $parts[1] -match "true" }
				"BatteryOn" { $global:psPromptSettings.BatteryOn = $parts[1] -match "true" }

				"LineTopOn" { $global:psPromptSettings.LineTopOn = $parts[1] -match "true"}
				"LineBottomOn" { $global:psPromptSettings.LineBottomOn = $parts[1] -match "true" }
				"ExtraBlanksToStart" { $global:psPromptSettings.ExtraBlanksToStart = $parts[1].TrimStart('"').TrimEnd('"') }

				"DefaultForeColor" { $global:psPromptSettings.DefaultForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"DefaultBackColor" { $global:psPromptSettings.DefaultBackColor = $parts[1].TrimStart('"').TrimEnd('"') }

				"ErrorForeColor" { $global:psPromptSettings.ErrorForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"ErrorBackColor" { $global:psPromptSettings.ErrorBackColor = $parts[1].TrimStart('"').TrimEnd('"') }

				"AdminForeColor" { $global:psPromptSettings.AdminForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"AdminBackColor" { $global:psPromptSettings.AdminBackColor = $parts[1].TrimStart('"').TrimEnd('"') }

				"HeadForeColor" { $global:psPromptSettings.HeadForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"HeadBackColor" { $global:psPromptSettings.HeadBackColor = $parts[1].TrimStart('"').TrimEnd('"') }

				"Info1ForeColor" { $global:psPromptSettings.Info1ForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"Info1BackColor" { $global:psPromptSettings.Info1BackColor = $parts[1].TrimStart('"').TrimEnd('"') }

				"Info2ForeColor" { $global:psPromptSettings.Info2ForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"Info2BackColor" { $global:psPromptSettings.Info2BackColor = $parts[1].TrimStart('"').TrimEnd('"') }

				"Info3ForeColor" { $global:psPromptSettings.Info3ForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"Info3BackColor" { $global:psPromptSettings.Info3BackColor = $parts[1].TrimStart('"').TrimEnd('"') }

				"frameOpener" { $global:psPromptSettings.frameOpener = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameCloser" { $global:psPromptSettings.frameCloser = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameSeparator" {
					$blah = $parts[1].Split(',').Trim()
					if ($blah[0]) {
						$global:psPromptSettings.frameSeparator[0] = $blah[0].TrimStart('"').TrimEnd('"')
					}
					if ($blah[1]) {
						$global:psPromptSettings.frameSeparator[1] = $blah[1].TrimStart('"').TrimEnd('"')
					}
					if ($blah[2]) {
						$global:psPromptSettings.frameSeparator[2] = $blah[2].TrimStart('"').TrimEnd('"')
					}
				}
				"frameLine" { $global:psPromptSettings.frameLine = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameForeColor" { $global:psPromptSettings.frameForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameBackColor" { $global:psPromptSettings.frameBackColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameLineForeColor" { $global:psPromptSettings.frameLineForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameLineBackColor" { $global:psPromptSettings.frameLineBackColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameSpacer" { $global:psPromptSettings.frameSpacer = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameSpacerForeColor" { $global:psPromptSettings.frameSpacerForeColor = $parts[1].TrimStart('"').TrimEnd('"') }
				"frameSpacerBackColor" { $global:psPromptSettings.frameSpacerBackColor = $parts[1].TrimStart('"').TrimEnd('"') }
			} #end switch
		} #end foreach
	} #end if
} #end function


function prompt {
	$WeAreInError = $?
	$s = $global:psPromptSettings
	$spacer = $s.FrameSpacer.ToString().Substring(0, 1)
	if ($s.PromptOn) {
		if ($WeAreInError) {
			#Sets the line color to Calm, No Error
			$ColorForeERR = $s.frameLineForeColor
			$ColorBackERR = $s.frameLineBackColor

		} else {
			#Sets the line color to Panic, Error!
			$ColorForeERR = $s.ErrorForeColor
			$ColorBackERR = $s.ErrorBackColor
		}
		# Make sure Windows and .Net know where we are (they can only handle the FileSystem)
		try {
			[Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
		} Catch {}
		# Also, put the path in the title ... (don't restrict this to the FileSystem

		$Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix, $pwd.Path, $pwd.Provider.Name
		$ColorFG = $Host.UI.RawUI.ForegroundColor
		$ColorBG = $Host.UI.RawUI.BackgroundColor

		$line = ($s.FrameLine * (($Host.UI.RawUI.WindowSize.Width) - 1))

		$uppity = (hid-uptime)

		$tz = hid-timezone

		if ($s.ExecutionTimeOn) {
			#ExecutionTime of the last command
			[string] $ExecTime = Hid-ExeTime
			#Still trying to figure out why I get 2!!! responses, despite sending 1
			try {
				if ($ExecTime.IndexOf(' ') -gt 0) { $ExecTime = $ExecTime.Split(' ')[0] }
				#Add the size of the ExecTime portion
				if ($ExecTime.Length -gt 0) {
					$ExeTimeLength = $ExecTime.Length
					$ExeTimeLength += $s.frameSeparator[1].Length
					$ExeTimeLength += $s.frameOpener.Length + $s.frameCloser.Length
				}
			} catch {}
		}

		Write-Host ( "`n" * $s.BlanksToStart)
		if ($s.LineTopOn) { write-host $line -ForegroundColor $ColorForeERR -BackgroundColor $ColorBackErr }

		[int]$tLength = 0
		#Futzing the right-justification measurements
		#Add the size of the Time portion
		$tLength = "ddd hh:mm?m ".Length + $tz.Length + 1
		$tLength += $s.frameSeparator[1].Length
		$tLength += $s.frameOpener.Length + $s.frameCloser.Length
		#Add the size of the Battery portion
		$BattLength = "bat ##% ?? h 00m".Length + 1
		$BattLength += $s.frameOpener.Length + $s.frameCloser.Length
		$BattLength += 2 # $batt[0].RunTimeSpan.Hours.ToString().Length (this gets adjusted later)
		$tLength += $BattLength
		#Bring in the ExecutionTime Length (if any)
		$tLength += $ExeTimeLength


		if ($s.UptimeOn) {
			#Uptime
			#Piece together the length of Uptime so we can right-justify the time
			#Futz it a little, using length of the non-DateTime chars
			$tLength += "up d 00h00m00s".Length
			$tLength += $s.frameSeparator[1].Length
			$tLength += $s.frameOpener.Length + $s.frameCloser.Length
			$tLength += $uppity.days.ToString('###0').Length
			Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
			Write-Host "up " -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
			Write-Host $uppity.days.ToString('###0') -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewLine
			Write-Host "d " -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
			Write-Host $uppity.Hours.ToString('00') -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewLine
			Write-Host "h" -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
			Write-Host $s.FrameSeparator[1] -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewline
			Write-Host $uppity.Minutes.ToString('00') -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewLine
			Write-Host "m" -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
			Write-Host $s.FrameSeparator[1] -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewline
			Write-Host $uppity.Seconds.ToString('00') -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewLine
			Write-Host "s" -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
			Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
			Write-Host $spacer -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine
			$tLength += $spacer.Length
		} else {
			$tLength += $s.frameOpener.Length + $s.frameCloser.Length + "ddd hh:mm?m ".Length + $tz.Length + 1
		}

		if ($s.PSVersionOn) {
			#PSVersion Info
			$PSVersion = Hid-PSVer
			$PSText = "PS v"
			$tLength += $s.frameOpener.Length + $PSText.Length + $s.frameCloser.Length + $PSVersion.Length
			Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
			Write-Host $PSText -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewline
			Write-Host $PSVersion -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewline
			Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
			Write-Host $spacer -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine
			$tLength += $spacer.Length
		}

		#GitStatus
		if ($s.GitOn) {
			Try {
				$branch = git rev-parse --abbrev-ref HEAD 2> $null
				if ($branch) {
					$tLength += $s.frameOpener.Length + $s.frameCloser.Length
					$tLength += $branch.length

					Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline

					#Branch info
					Write-Host $branch -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewline

					#File Counts
					if ($s.GitFileStatus) {
						$gitstat = get-gitstatus
						if ($gitstat.Added) {
							$tLength += " +".Length + $gitstat.Working.Added.Count.ToString().Length
							Write-Host " +" -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
							Write-Host $gitstat.Added -Fore $s.Info2ForeColor -Back $s.Info2BackColor -NoNewLine
						}
						if ($gitstat.Modified) {
							$tLength += " ~".Length + $gitstat.Working.Modified.Count.ToString().Length
							Write-Host " ~" -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
							Write-Host $gitstat.Modified -Fore $s.Info2ForeColor -Back $s.Info2BackColor -NoNewLine
						}
						if ($gitstat.Deleted) {
							$tLength += " -".Length + $gitstat.Working.Deleted.Count.ToString().Length
							Write-Host " -" -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
							Write-Host $gitstat.Deleted -Fore $s.Info2ForeColor -Back $s.Info2BackColor -NoNewLine
						}
						if ($gitstat.Unmerged) {
							$tLength += " !".Length + $gitstat.Working.Unmerged.Count.ToString().Length
							Write-Host " !" -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
							Write-Host $gitstat.Unmerged -Fore $s.Info2ForeColor -Back $s.Info2BackColor -NoNewLine
						}
					}
					Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
				}
			} Catch {
				$global:psPromptSettings.GitOn = $false
			}
		}

		#Right Justify based on our earlier futzing
		Write-Host ($spacer * (($Host.UI.RawUI.WindowSize.Width) - $tLength)) -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine

		#Battery
		if ($s.BatteryOn) {
			try {
				$batt = (hid-battery)
				$battstat = $batt[0].BatteryStatusChar
			} catch { }
			If (($batt -ne $null) -and ($batt.EstimatedChargeRemaining -lt 97)) {
				#Battery Length - adjust for a 1 digit hour (only allows for 2 digit in the base)
				if ($batt[0].RunTimeSpan.Hours.ToString().Length -eq 1) { Write-Host " " -NoNewline }
				Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
				Write-Host "bat " -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
				if (($batt.EstimatedChargeRemaining) -gt 30) {
					Write-Host "$($batt[0].EstimatedChargeRemaining.ToString('00'))" -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewLine
				} else {
					Write-Host "$($batt[0].EstimatedChargeRemaining.ToString('00'))" -Fore $s.ErrorForeColor -Back $s.ErrorBackColor -NoNewLine
				}
				Write-Host "% " -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
				Write-Host "$battstat " -Fore $s.Info2ForeColor -Back $s.Info2BackColor -NoNewLine
				Write-Host $batt[0].RunTimeSpan.Hours -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewline
				Write-Host "h " -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine
				Write-Host $batt[0].RunTimeSpan.Minutes.ToString('00') -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewline
				Write-Host "m" -Fore $s.HeadForeColor -Back $s.HeadBackColor -NoNewLine

				Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
				Write-Host $spacer -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine
			} else {
				Write-Host ($spacer * $BattLength) -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine
			}
		} else {
			Write-Host ($spacer * $BattLength) -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine
		}

		if ($s.ExecutionTimeOn) {
			#ExecutionTime of the last command
			#write-host $ExecTime -ForegroundColor red
			if ($ExecTime.Length -gt 0) {
				$tLength += $s.frameOpener.Length + $ExecTime.Length + $s.frameCloser.Length
				Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
				Write-Host $ExecTime -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewline
				Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
				Write-Host $spacer -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine
				$tLength += $spacer.Length
			}
		}

		#Day and Time
		Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewline
		Write-Host "$((get-date).ToString('ddd')) " -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewLine
		Write-Host "$((get-date).ToString('hh:mmtt ').ToLower())" -Fore $s.Info2ForeColor -Back $s.Info2BackColor -NoNewLine
		Write-Host $tz.Trim() -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewline
		Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor

		#Current Directory
		Try {
			$tPath = $pwd.Path
		} Catch {
			$tPath = "Path Error"
		}
		$DirectoryForeColor = $s.Info2ForeColor
		$DirectoryBackColor = $s.Info2BackColor
		if (($s.TestDirRW) -and (!(hid-TestWrite $tpath))) {
			$tpath += " RO"
			$DirectoryForeColor = $s.ErrorForeColor
			$DirectoryBackColor = $s.ErrorBackColor
		}
		#Use ~ if it's the home path
		if (("$tpath\").ToString().Contains("$env:USERPROFILE\")) {
			$tPath = $tPath.Replace("$env:USERPROFILE", "~")
		}
		$tLength = ($s.FrameSeparator[0].Length + ($tPath.Length) + $env:username.Length + $env:computername.Length) + 1
		$tLength += $s.frameOpener.Length + $s.frameCloser.Length
		$tLength += $s.frameOpener.Length + $s.frameCloser.Length

		Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewLine
		if ($tPath.Contains(":")) {
			Write-Host "$($tPath.Split(":")[0]):" -ForegroundColor $s.Info1ForeColor -Back $s.Info1BackColor -NoNewLine
			Write-Host $tPath.Split(":")[1] -ForegroundColor $DirectoryForeColor -Back $DirectoryBackColor -NoNewLine
		} else {
			Write-Host "$tPath" -ForegroundColor $DirectoryForeColor -Back $DirectoryBackColor -NoNewLine
		}
		Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewLine

		#Now let's use that futzed length to add some spaces before displaying the who@where
		if (hid-IsAdmin) { $tLength += " as ADMIN".Length }

		Try {
			$tIP = hid-ip
		} Catch {
			$tIP = $null
		}
		if ($tIP -ne $null ) {
			#Yay, we have network info - split it down to just the 1st ipv4 address
			$tIP = $tIP[0].IPAddress[0]
			$tLength += ($tIP.Length + $spacer.Length)
			$tLength += $s.frameOpener.Length + $s.frameCloser.Length


			#Write the spaces...
			Write-Host ($spacer * (($Host.UI.RawUI.WindowSize.Width) - $tLength)) -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine

			#IP Address
			Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewLine
			Write-Host "$tIP" -Fore $s.Info2ForeColor -Back $s.Info2BackColor -NoNewLine
			Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewLine
			Write-Host $spacer -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewline
		} else {
			#Skip the ip section and just write the spaces...
			Write-Host ($spacer * (($Host.UI.RawUI.WindowSize.Width) - $tLength)) -Fore $s.frameSpacerForeColor -Back $s.frameSpacerBackColor -NoNewLine
		}


		#Username @ machine
		Write-Host $s.FrameOpener -Fore $s.FrameForeColor -back $s.FrameBackColor -NoNewLine
		Write-Host "$env:username" -Fore $s.Info1ForeColor -Back $s.Info1BackColor -NoNewLine
		Write-Host $s.FrameSeparator[0] -Fore "White" -NoNewLine
		Write-Host "$(($env:computername).ToLower())" -Fore $s.Info3ForeColor -Back $s.Info3BackColor -NoNewLine

		if (hid-IsAdmin) { Write-Host " as ADMIN" -Fore $s.ErrorForeColor -Back $s.ErrorBackColor -NoNewLine }
		Write-Host $s.FrameCloser -Fore $s.FrameForeColor -back $s.FrameBackColor

		if ($s.LineBottomOn) { Write-Host $line -ForegroundColor $ColorForeERR -BackgroundColor $ColorBackErr }
		Write-Host ($s.frameSeparator[2] * ($nestedPromptLevel + 1)) -NoNewLine -Fore $ColorFG -BackgroundColor $ColorBG
		if (IsConEmu) {
			write-host (ConEmuEndPrompt) -NoNewline
			write-host (ConEmuTab) -NoNewline
		}
		return " "
	} else {
		"PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
	}
}

Set-PromptDefaults

Export-ModuleMember -function prompt
Export-ModuleMember -function Set-PromptDefaults


###################################################
## END - Cleanup

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
	# cleanup when unloading module (if any)
	dir alias: | Where-Object { $_.Source -match "psPrompt" } | Remove-Item
	dir function: | Where-Object { $_.Source -match "psPrompt" } | Remove-Item
}
#endregion Module Cleanup
