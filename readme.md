psPrompt

A PowerShell prompt module, which includes the following info in the prompt:

* Uptime
* Git status (if applicable)
* Battery status (for the first reported battery) - includes "graphic"!
* How long the last command took to execute
* Date and time (incl. the current Time Zone)
* Current directory (and if Read/Only)
* Current IP Address (well, the first IPv4 on the first NIC)
* PowerShell Version Number
* User and machine names

The prompt takes up the width of the screen, with right- and left-justified parts

The module includes the main prompt function (which is mostly just write-host commands and formatting) in the psm1 file. The helper functions (those that pull wmi or other info) are in the "private" subfolder to keep them hidden from general use (and minimize collisions).

### Customizations

The prompt is customizable. You can turn on/off sections, change the colors, change the separators, and the start/end markers ('[' and ']' by default).

The settings are held in the PSPromptSettings variable.

```
PromptOn             : True
UptimeOn             : True
TitleOn              : True
TestDirRW            : True
GitOn                : True
GitFileStatus        : True
PSVersionOn          : True
ExecutionTimeOn      : True
BatteryOn            : True
BatteryThreshold     : 90
LineTopOn            : True
LineBottomOn         : True
ExtraBlanksToStart   : 1
DefaultForeColor     : DarkYellow
DefaultBackColor     : DarkMagenta
ErrorForeColor       : Red
ErrorBackColor       : DarkMagenta
AdminForeColor       : Red
AdminBackColor       : DarkMagenta
HeadForeColor        : White
HeadBackColor        : DarkMagenta
Info1ForeColor       : Green
Info1BackColor       : DarkMagenta
Info2ForeColor       : Yellow
Info2BackColor       : DarkMagenta
Info3ForeColor       : Magenta
Info3BackColor       : DarkMagenta
frameOpener          : [
frameCloser          : ]
frameSeparator       : {@, :, >}
frameLine            : ─
frameForeColor       : White
frameBackColor       : DarkMagenta
frameLineForeColor   : Yellow
frameLineBackColor   : DarkMagenta
frameSpacer          :
frameSpacerForeColor : DarkYellow
frameSpacerBackColor : DarkMagenta
```

To change any, just use $PSPromptSettings.*setting* - so, to turn off Git: `$PSPromptSettings.GitOn = $false`

The frameSeparator setting is an array of strings for:
* 0 = the symbol between user@host ('@' by default)
* 1 = the symbol separating Uptime numbers (':' by default)
* 2 = the Prompt character ('>' by default)

The BatteryThreshold setting controls when the 'graphic' battery appears ... my work laptop is permanently maxed at 96%, so I set the battery to appear when it gets below 90.

The module itself holds defaults, but by placing a .psprompt.ini file in your profile directory (c:\users\myname), you can modify any and all settings. An example .psprompt.ini file is included. Any item included in the file will over-ride the default. Any item NOT in the file will... not. Play around with the $PSPromptSettings variable BEFORE committing anything to the file. The function, Set-PromptDefaults, allows for a quick reset (since I don't currently do much... er... any error trapping).

And now!! psPrompt settings can be directory-tree specific. Maybe you like different line displays for prod code vs dev code (what, sometimes I separate my code - it happens). Maybe you want git status on for some repos and not for others. Now you can. Just put a .psprompt.ini file in the directory and those settings will override the current defaults. Plus, they work down-stream. So, put a .psprompt.ini in a parent, and those settings will be set for all subdirectories (unless/until a more "local" .psprompt.ini file is found). Multiple .psprompt.ini files are _not_ cumulative, however. Yet.

These per-directory settings no longer break the in-memory temp settings (and yay for that). Simple fix, really.

~~The idea for the customization mod came out of the GitHub prompt.~~

**Correction:** The idea for customization came from the POSH-Git Module's prompt. I was confused since it looked like the GitHub client included the posh-git module (I only noticed it when an update did not include said module). Anyway, major kudos to dahlbyk and the Posh-Git module. I have removed the prompt's dependency on the module because it's WAY MORE than I need for this. But, I blatantly *cough* borrowed *cough* the regex code for the small bit I do need.

Please, check out Posh-Git if you use Git in PowerShell - https://github.com/dahlbyk/posh-git

Enumerating the git file changes can be sluggish (ok, 300ms vs 200ms, but it's noticeable). So, remember: `$psPromptSettings.GitOn = $false` will turn off all git info; and `$psPromptSettings.GitFileStatus = $false` will turn off file stats but leave the branch name (which is still quick). It can be set globally in the ini file described above, or temporarily - your choice. I probably won't make it folder by folder selectable. Plus, it's only really sluggish when you're in the git folder structure with modified files....

To install:

I've included an install script. Just run the following command from an administrator-level POSH console:

```
iex (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/brsh/psPrompt/master/install.ps1")
```

To use it, either include it in your profile, or just run the following:

```
import-module psPrompt
```

