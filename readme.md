psPrompt

A PowerShell prompt module, which includes the following info in the prompt:

* Uptime
* Git status (if applicable)
* Date and time (incl. the current Time Zone)
* Current directory (and if Read/Only)
* Current IP Address (well, the first IPv4 on the first NIC)
* User and machine names

The prompt takes up the width of the screen, with right- and left-justified parts

The module includes the main prompt function (which is mostly just write-host commands and formatting) in the psm1 file. The helper functions (those that pull wmi or other info) are in the "private" subfolder to keep them hidden from general use (and minimize collisions).

Colors and decorations are now customizable. The module itself holds defaults, but by placing a .psprompt.ini file in your profile directory (c:\users\myname), you can modify any and all settings. An example .psprompt.ini file is included. Any item included in the file will over-ride the default. Any item NOT in the file will... not. A new function (set-promptdefaults) allows for a quick reset (since I don't currently do much... er... any error trapping).

The idea for the customization mod came out of the GitHub prompt. 

To install:

I've included an install script. Just run the following command from an administrator-level POSH console:

```
iex (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/brsh/psPrompt/master/install.ps1")
```

To use it, either include it in your profile, or just run the following:

```
import-module psPrompt
```

