psPrompt

A PowerShell prompt module, which includes the following info in the prompt:

* Uptime
* Date and time (incl. the current Time Zone)
* Current directory
* Current IP Address (well, the first IPv4 on the first NIC)
* User and machine names

The prompt takes up the width of the screen, with right- and left-justified parts

The module includes the main prompt function (which is mostly just write-host commands and formatting) in the psm1 file. The helper functions (those that pull wmi or other info) are in the "private" subfolder to keep them hidden from general use (and minimize collisions).

To install:

I've included an install script. Just run the following command from an administrator-level POSH console:

```
iex (New-Object Net.WebClient).DownloadString("https://github.com/brsh/psPrompt/raw/master/Install.ps1")
```

To use it, either include it in your profile, or just run the following:

```
import-module psPrompt
```

