@echo off
REM make-yt.bat EP-0001
set EP=%1
if "%EP%"=="" set EP=EP-0001
pwsh -NoProfile -File "yt\tools\RenderPlaceholder.ps1" -RepoRoot "%cd%" -EpisodeId "%EP%"
echo Done.
