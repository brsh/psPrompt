## Git Helper for Prompt
## Didn't want to write my own - but github seems to have removed posh-git
## (at least, that's how I think I got it in the first place and now it's gone...).
## And the real project has more than I need or want.
## Please check out Posh-Git https://github.com/dahlbyk/posh-git
## It's good stuff!

function Get-GITStatus {
    $status = git status --porcelain --branch
        
    $branch = $null
    $aheadBy = 0
    $behindBy = 0
    $deleted = 0
    $added = 0
    $modified = 0
    $unmerged = 0

    $status | foreach-object {
        if($_) {
            switch -regex ($_) {
                '^(?<index>[^#])(?<working>.) (?<path1>.*?)(?: -> (?<path2>.*))?$' {
                    switch ($matches['index']) {
                        'A' { $added ++ }     
                        'M' { $modified ++ }  
                        'R' { $modified ++ }  
                        'C' { $modified ++ }  
                        'D' { $deleted ++ }   
                        'U' { $unmerged ++ }  
                    }
                    switch ($matches['working']) {
                        '?' { $added ++ }     
                        'A' { $added ++ }     
                        'M' { $modified ++ }  
                        'D' { $deleted ++ }   
                        'U' { $unmerged ++ }  
                    }
                }

                '^## (?<branch>\S+?)(?:\.\.\.(?<upstream>\S+))?(?: \[(?:ahead (?<ahead>\d+))?(?:, )?(?:behind (?<behind>\d+))?\])?$' {
                    $branch = $matches['branch']
                    $upstream = $matches['upstream']
                    $aheadBy = [int]$matches['ahead']
                    $behindBy = [int]$matches['behind']
                }

                '^## Initial commit on (?<branch>\S+)$' {
                    $branch = $matches['branch']
                }
            }
        
        }
    }

    $retval = New-Object PSObject -Property @{
        Branch          = (Get-Culture).TextInfo.ToTitleCase($branch)
        AheadBy         = $aheadBy
        BehindBy        = $behindBy
        Upstream        = $upstream
        Added           = $added
        Modified        = $modified
        Deleted         = $deleted
        Unmerged        = $unmerged
    }

    $retval
}

function Test-IfGitinPath {
    $pathInfo = Microsoft.PowerShell.Management\Get-Location
    [bool] $GitFound = $false

    if ((-not $pathInfo) -or ($pathInfo.Provider.Name -ne 'FileSystem')) {
        $GitFound = $false
    } else {
        [bool] $done = $false
        $curr = Get-Item $PathInfo
        Do {
            $done = $false
            $testing = Test-Path (join-path $curr.FullName '.git')
            if ($testing) {
                $GitFound = $true
                $Done = $true
            } else {
              $curr = $curr.Parent
            }
            if (-not $curr) { $GitFound = $false; $done = $true }
        } until ($done)
    }
    $GitFound
}

