<#
.SYNOPSIS
Removes markdown image links from session log files.

.DESCRIPTION
By default this script scans Sessions\**\*Log.md, reports what it would change,
and does not write files. Pass -Apply to update matching logs. When applying,
the script writes a .bak copy next to each changed file unless -NoBackup is set.

The script removes markdown image links with any URL, such as:
  ![](https://files.d20.io/images/.../med.webp?...)
  ![](https://app.roll20.net/users/avatar/.../30)
  ![alt text](https://example.com/image.png)

.EXAMPLE
.\Scripts\Remove-MarkdownImageLinks.ps1

.EXAMPLE
.\Scripts\Remove-MarkdownImageLinks.ps1 -Apply

.EXAMPLE
.\Scripts\Remove-MarkdownImageLinks.ps1 -Path '.\Sessions\Session 23\Session 23 Log.md' -Apply
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]] $Path = @('.\Sessions'),

    [string] $Filter = '*Log.md',

    [switch] $Apply,

    [switch] $NoBackup
)

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    $urlPattern = '(?:[a-z][a-z0-9+.-]*://[^\)\r\n]+)'
    $markdownImagePattern = "!\[[^\]\r\n]*\]\($urlPattern\)"
    $imageOnlyLinePattern = "(?m)^[`t ]*$markdownImagePattern[`t ]*(?:\r?\n|$)"
    $inlineImagePattern = "[`t ]*$markdownImagePattern[`t ]*"

    $changedFiles = 0
    $removedLinks = 0
}

process {
    foreach ($entry in $Path) {
        $resolvedPaths = @(Resolve-Path -LiteralPath $entry)

        foreach ($resolvedPath in $resolvedPaths) {
            $item = Get-Item -LiteralPath $resolvedPath.Path
            $files = if ($item.PSIsContainer) {
                Get-ChildItem -LiteralPath $item.FullName -Filter $Filter -File -Recurse
            }
            else {
                @($item)
            }

            foreach ($file in $files) {
                $original = [System.IO.File]::ReadAllText($file.FullName)
                $lineMatches = [regex]::Matches($original, $imageOnlyLinePattern).Count
                $withoutImageOnlyLines = [regex]::Replace($original, $imageOnlyLinePattern, '')
                $inlineMatches = [regex]::Matches($withoutImageOnlyLines, $inlineImagePattern).Count
                $updated = [regex]::Replace($withoutImageOnlyLines, $inlineImagePattern, '')
                $matches = $lineMatches + $inlineMatches

                if ($updated -eq $original) {
                    continue
                }

                $changedFiles++
                $removedLinks += $matches

                if (-not $Apply) {
                    Write-Host ("Would remove {0} image link(s): {1}" -f $matches, $file.FullName)
                    continue
                }

                if ($PSCmdlet.ShouldProcess($file.FullName, "Remove $matches Roll20/D20 image link(s)")) {
                    if (-not $NoBackup) {
                        Copy-Item -LiteralPath $file.FullName -Destination ($file.FullName + '.bak') -Force
                    }

                    [System.IO.File]::WriteAllText($file.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
                    Write-Host ("Removed {0} image link(s): {1}" -f $matches, $file.FullName)
                }
            }
        }
    }
}

end {
    if ($Apply) {
        Write-Host ("Done. Changed {0} file(s), removed {1} image link(s)." -f $changedFiles, $removedLinks)
    }
    else {
        Write-Host ("Dry run. Would change {0} file(s), removing {1} image link(s). Re-run with -Apply to write changes." -f $changedFiles, $removedLinks)
    }
}
