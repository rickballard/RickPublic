# Import-Substack.ps1
<#
  Purpose: help mirror existing Substack posts into RickPublic/articles as Markdown.
  NOTE: Substack has limited export; use account export to get HTML/MD, then run this script.
#>
param(
  [Parameter(Mandatory=$true)][string]$ExportZipPath,
  [Parameter(Mandatory=$true)][string]$RepoRoot
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'

$work = Join-Path $env:TEMP ("substack_export_" + (Get-Date -Format 'yyyyMMddHHmmss'))
New-Item -ItemType Directory -Force -Path $work | Out-Null
Expand-Archive -Path $ExportZipPath -DestinationPath $work -Force

$articles = Join-Path $RepoRoot 'articles'
New-Item -ItemType Directory -Force -Path $articles | Out-Null

# Copy MD/HTML into articles and normalize filenames
Get-ChildItem -Path $work -Recurse -Include *.md, *.html | ForEach-Object {
  $name = ($_ | Split-Path -Leaf).ToLower().Replace(' ', '-')
  Copy-Item $_.FullName (Join-Path $articles $name) -Force
}

Write-Host "Imported articles into $articles"
