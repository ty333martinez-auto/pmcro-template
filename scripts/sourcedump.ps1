#Requires -Version 7.0
<#
.SYNOPSIS
    Concatenates actual source file contents under a root directory into a
    single markdown file, for pasting into an LLM's context window.

.DESCRIPTION
    Unlike generate-context-dump.ps1 (project structure/metadata only), this
    walks -Root recursively, skips noise directories (bin/obj/.git/etc.),
    filters to source-relevant extensions, and writes each included file's
    full content into one output file with clear path headers and
    language-tagged fenced code blocks. Read-only with respect to the
    source tree -- it only ever writes to -OutputPath.

    Execution-tested (2026-07-09) against a mock tree mirroring this
    Colony's real A:\source layout, including bin/obj noise and an
    oversized file -- exclusion and size-skip logic both confirmed correct
    with a real pwsh 7.6.3 runtime, not just reviewed by eye.

.PARAMETER Root
    Directory to walk recursively. Defaults to A:\source (the Aspire
    solution's source root).

.PARAMETER OutputPath
    Where the concatenated dump is written. Defaults to
    A:\.pmcro\context\source-dump.md. Any existing file at this path is
    overwritten. The parent directory is created if it doesn't exist.

.PARAMETER ExcludeDirs
    Directory names excluded anywhere in the tree (matched case-insensitively
    against each path segment). Defaults to common build/VCS/tooling noise.

.PARAMETER IncludeExtensions
    File extensions (with leading dot) to include. Defaults to common
    .NET/web/script/config source extensions.

.PARAMETER MaxFileSizeKB
    Files larger than this are skipped (listed in a "Skipped" section
    rather than silently dropped) to avoid one huge generated/binary-ish
    file blowing out the whole dump. Defaults to 200 KB.

.EXAMPLE
    pwsh A:\scripts\sourcedump.ps1
    Dumps A:\source into A:\.pmcro\context\source-dump.md using all defaults.

.EXAMPLE
    pwsh A:\scripts\sourcedump.ps1 -Root "A:\skills\internal\skill-creator" -OutputPath "A:\.pmcro\context\skill-creator-dump.md"
#>

param(
    [string]$Root = "A:\source",

    [string]$OutputPath = "A:\.pmcro\context\source-dump.md",

    [string[]]$ExcludeDirs = @("bin", "obj", ".git", ".vs", "node_modules", '$RECYCLE.BIN', "System Volume Information"),

    [string[]]$IncludeExtensions = @(
        ".cs", ".csproj", ".sln", ".slnx", ".props", ".targets",
        ".json", ".yml", ".yaml", ".md", ".ps1", ".psm1",
        ".py", ".js", ".ts", ".tsx", ".jsx",
        ".html", ".css", ".xml", ".config", ".razor", ".cshtml"
    ),

    [int]$MaxFileSizeKB = 200
)

$ErrorActionPreference = "Stop"

# Map extensions to fenced-code-block language hints
$langMap = @{
    ".cs" = "csharp"; ".csproj" = "xml"; ".sln" = "text"; ".slnx" = "xml"
    ".props" = "xml"; ".targets" = "xml"; ".json" = "json"; ".yml" = "yaml"
    ".yaml" = "yaml"; ".md" = "markdown"; ".ps1" = "powershell"; ".psm1" = "powershell"
    ".py" = "python"; ".js" = "javascript"; ".ts" = "typescript"; ".tsx" = "tsx"
    ".jsx" = "jsx"; ".html" = "html"; ".css" = "css"; ".xml" = "xml"
    ".config" = "xml"; ".razor" = "razor"; ".cshtml" = "cshtml"
}

if (-not (Test-Path -LiteralPath $Root)) {
    Write-Error "Root path not found: $Root"
    exit 1
}

$outputDir = Split-Path -LiteralPath $OutputPath
if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

if (Test-Path -LiteralPath $OutputPath) {
    Remove-Item -LiteralPath $OutputPath -Force
}

function Test-ExcludedPath {
    param([string]$FullPath, [string]$RootPath, [string[]]$Excludes)
    $relative = $FullPath.Substring($RootPath.Length).TrimStart('\', '/')
    $segments = $relative -split '[\\/]'
    foreach ($seg in $segments) {
        foreach ($ex in $Excludes) {
            if ($seg -ieq $ex) { return $true }
        }
    }
    return $false
}

$allFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue

$included = New-Object System.Collections.Generic.List[System.IO.FileInfo]
$skippedLarge = New-Object System.Collections.Generic.List[string]
$skippedExcluded = 0

foreach ($f in $allFiles) {
    if (Test-ExcludedPath -FullPath $f.FullName -RootPath $Root -Excludes $ExcludeDirs) {
        $skippedExcluded++
        continue
    }
    if ($IncludeExtensions -notcontains $f.Extension.ToLowerInvariant()) {
        continue
    }
    if ($f.Length -gt ($MaxFileSizeKB * 1KB)) {
        $skippedLarge.Add("$($f.FullName) ($([math]::Round($f.Length / 1KB, 1)) KB)")
        continue
    }
    $included.Add($f)
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# Source Dump")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine("- Root: ``$Root``")
[void]$sb.AppendLine("- Files included: $($included.Count)")
[void]$sb.AppendLine("- Files skipped (excluded dir): $skippedExcluded")
[void]$sb.AppendLine("- Files skipped (over ${MaxFileSizeKB}KB): $($skippedLarge.Count)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")

foreach ($f in ($included | Sort-Object FullName)) {
    $relPath = $f.FullName.Substring($Root.Length).TrimStart('\', '/')
    $lang = $langMap[$f.Extension.ToLowerInvariant()]
    if (-not $lang) { $lang = "" }

    [void]$sb.AppendLine("## $relPath")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine('```' + $lang)
    try {
        $text = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop
        [void]$sb.AppendLine($text.TrimEnd())
    }
    catch {
        [void]$sb.AppendLine("<< could not read file: $($_.Exception.Message) >>")
    }
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine("")
}

if ($skippedLarge.Count -gt 0) {
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Skipped (over ${MaxFileSizeKB}KB)")
    [void]$sb.AppendLine("")
    foreach ($s in $skippedLarge) {
        [void]$sb.AppendLine("- $s")
    }
}

Set-Content -LiteralPath $OutputPath -Value $sb.ToString() -Encoding UTF8

Write-Host "Source dump written to $OutputPath ($($included.Count) files, $skippedExcluded excluded-dir skips, $($skippedLarge.Count) size skips)" -ForegroundColor Green
