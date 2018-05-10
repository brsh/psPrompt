<#
.SYNOPSIS
    Prompt config for ConEmu

.DESCRIPTION
    Really, if you don't know what ConEmu is, check it out: https://conemu.github.io

#>


function IsConEmu {
	# Simple check for ConEmu existance and ANSI emulation enabled
	if ($env:ConEmuANSI -eq "ON") { return $true }
	else { return $false }
}

function ConEmuEndPrompt {
	# Let ConEmu know when the prompt ends, to select typed
	# command properly with "Shift+Home", to change cursor
	# position in the prompt by simple mouse click, etc.
	return "$([char]27)]9;12$([char]7)"
}

function ConEmuTab {
	# And current working directory (FileSystem)
	# ConEmu may show full path or just current folder name
	# in the Tab label (check Tab templates)
	# Also this knowledge is crucial to process hyperlinks clicks
	# on files in the output from compilers and source control
	# systems (git, hg, ...)
	if ($loc.Provider.Name -eq "FileSystem") {
		$loc = Get-Location
		return "$([char]27)]9;9;`"$($loc.Path)`"$([char]7)"
		#$loc = "hello"
		#return "$([char]27)]9;9;`"$($loc)`"$([char]7)"
	}
}
