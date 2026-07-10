<#
.SYNOPSIS
    Project Context Dump Generator
#>

param(
    [string]$OutputPath = "B:\pmcro-cline\.pmcro\project-context-dump.md",
    [string]$TreeRoot = $null,
    [string]$EdgeTabsJson = $null
)

function Append-Markdown {
    param([string]$Text)
    Add-Content -Path $OutputPath -Value $Text -Encoding UTF8
}

# Initialize
if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }

Append-Markdown "# Project Context Dump"
Append-Markdown "Generated: $(Get-Date)"
Append-Markdown "Machine: $env:COMPUTERNAME"
Append-Markdown "`n---`n"

# Directory Structure
Append-Markdown "## Directory Structure"
Append-Markdown '```text'
    try { 
        $target = if ($TreeRoot) { $TreeRoot } else { (Get-Location).Path }
        $tree = tree $target /F /A 
        Append-Markdown $tree 
    } catch { 
        Append-Markdown "Error generating tree for $target" 
    }
Append-Markdown '```'
Append-Markdown "`n---`n"

# MCP Servers
Append-Markdown "## MCP Servers"
$serversRoot = "A:\mcp-servers"
if (Test-Path $serversRoot) {
    Get-ChildItem $serversRoot -Directory | ForEach-Object {
        Append-Markdown "### $($_.Name)"
        Append-Markdown "- Path: $($_.FullName)"
        Get-ChildItem $_.FullName | ForEach-Object {
            Append-Markdown "  - $($_.Name)"
        }
        Append-Markdown ""
    }
} else {
    Append-Markdown "> No MCP servers found."
}
Append-Markdown "`n---`n"

# Aspire Projects
Append-Markdown "## .NET Aspire Components"
$aspireRoot = "A:\source"
if (Test-Path $aspireRoot) {
    Get-ChildItem $aspireRoot -Directory | ForEach-Object {
        Append-Markdown "### $($_.Name)"
        if (Test-Path (Join-Path $_.FullName "bin")) { Append-Markdown "- bin/" }
        if (Test-Path (Join-Path $_.FullName "obj")) { Append-Markdown "- obj/" }
        Append-Markdown ""
    }
} else {
    Append-Markdown "> No Aspire source found."
}
Append-Markdown "`n---`n"

# Git
Append-Markdown "## Git Status"
try {
    $git = git -C A:\ status --short --branch 2>$null
    if ($git) {
        Append-Markdown '```text'
        Append-Markdown $git
        Append-Markdown '```'
    } else {
        Append-Markdown "> No git repo or no changes."
    }
} catch {
    Append-Markdown "> Git not available."
}
Append-Markdown "`n---`n"

# Edge Tabs
Append-Markdown "## Edge Tabs"
if ($EdgeTabsJson) {
    try {
        $tabs = $EdgeTabsJson | ConvertFrom-Json
        $tabs | ForEach-Object {
            Append-Markdown "### Tab $($_.tabId)"
            Append-Markdown "- Title: $($_.pageTitle)"
            Append-Markdown "- URL: $($_.pageUrl)"
        }
    } catch {
        Append-Markdown "> Failed to parse Edge tabs"
    }
} else {
    Append-Markdown "> No Edge tab data"
}
Append-Markdown "`n---`n"

# Diagnostics
Append-Markdown "## Diagnostics"
Append-Markdown "### PowerShell Version"
Append-Markdown '```powershell'
Append-Markdown ($PSVersionTable | Out-String).Trim()
Append-Markdown '```'

Append-Markdown "### .NET SDKs"
try {
    $dotnet = dotnet --list-sdks 2>$null
    if ($dotnet) {
        Append-Markdown '```text'
        Append-Markdown $dotnet
        Append-Markdown '```'
    } else {
        Append-Markdown "> dotnet CLI not available"
    }
} catch {
    Append-Markdown "> dotnet not found"
}

Append-Markdown "`n---`n"
Append-Markdown "Context dump completed successfully."

Write-Host "Context dump written to $OutputPath" -ForegroundColor Green