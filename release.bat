@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: DevProven Release Script
::
:: Usage:
::   release.bat                     — bump patch, release both Desktop + CLI
::   release.bat 0.3.0               — release both as v0.3.0 / cli-v0.3.0
::   release.bat --cli-only          — release only CLI (patch bump)
::   release.bat --desktop-only      — release only Desktop (patch bump)
::   release.bat 0.3.0 --cli-only    — release CLI as cli-v0.3.0
::   release.bat --dry-run           — show what would happen, don't push
:: ============================================================================

set "VERSION="
set "CLI_ONLY=0"
set "DESKTOP_ONLY=0"
set "DRY_RUN=0"

:: Parse arguments
:parse_args
if "%~1"=="" goto done_args
if "%~1"=="--cli-only" (set "CLI_ONLY=1" & shift & goto parse_args)
if "%~1"=="--desktop-only" (set "DESKTOP_ONLY=1" & shift & goto parse_args)
if "%~1"=="--dry-run" (set "DRY_RUN=1" & shift & goto parse_args)
if "%~1"=="--help" goto show_help
if "%~1"=="-h" goto show_help
set "VERSION=%~1"
shift
goto parse_args
:done_args

:: Find latest tags
echo.
echo === Current tags ===
for /f "tokens=*" %%i in ('git tag --sort=-version:refname ^| findstr "^v" ^| findstr /v "cli-"') do (
    if not defined LATEST_DESKTOP set "LATEST_DESKTOP=%%i"
)
for /f "tokens=*" %%i in ('git tag --sort=-version:refname ^| findstr "^cli-v"') do (
    if not defined LATEST_CLI set "LATEST_CLI=%%i"
)

if not defined LATEST_DESKTOP set "LATEST_DESKTOP=v0.0.0"
if not defined LATEST_CLI set "LATEST_CLI=cli-v0.0.0"

echo   Desktop: %LATEST_DESKTOP%
echo   CLI:     %LATEST_CLI%

:: Auto-bump version if not provided
if "%VERSION%"=="" (
    :: Use the higher of desktop or CLI version, then bump patch
    set "D_RAW=!LATEST_DESKTOP:~1!"
    set "C_RAW=!LATEST_CLI:~5!"

    :: Compare — use CLI version if it's higher (simple string compare)
    set "RAW=!D_RAW!"
    if "!C_RAW!" gtr "!D_RAW!" set "RAW=!C_RAW!"

    :: Parse major.minor.patch
    for /f "tokens=1,2,3 delims=." %%a in ("!RAW!") do (
        set "MAJOR=%%a"
        set "MINOR=%%b"
        set /a "PATCH=%%c+1"
    )
    set "VERSION=!MAJOR!.!MINOR!.!PATCH!"
    echo.
    echo   Highest current: !RAW! -^> bumped to !VERSION!
)

set "DESKTOP_TAG=v%VERSION%"
set "CLI_TAG=cli-v%VERSION%"

:: Show plan
echo.
echo === Release plan ===
if "%CLI_ONLY%"=="1" (
    echo   CLI only:     %CLI_TAG%
) else if "%DESKTOP_ONLY%"=="1" (
    echo   Desktop only: %DESKTOP_TAG%
) else (
    echo   Desktop:      %DESKTOP_TAG%
    echo   CLI:          %CLI_TAG%
)
if "%DRY_RUN%"=="1" (
    echo   Mode:         DRY RUN (no push)
)

:: Check for existing tags
set "TAG_EXISTS=0"
if not "%CLI_ONLY%"=="1" (
    git rev-parse "%DESKTOP_TAG%" >nul 2>&1 && (
        echo.
        echo   WARNING: Tag %DESKTOP_TAG% already exists!
        set "TAG_EXISTS=1"
    )
)
if not "%DESKTOP_ONLY%"=="1" (
    git rev-parse "%CLI_TAG%" >nul 2>&1 && (
        echo.
        echo   WARNING: Tag %CLI_TAG% already exists!
        set "TAG_EXISTS=1"
    )
)

:: Confirm
echo.
if "%DRY_RUN%"=="1" (
    echo [DRY RUN] Would create and push tags. Exiting.
    goto :eof
)

set /p CONFIRM="Proceed? (y/N): "
if /i not "%CONFIRM%"=="y" (
    echo Cancelled.
    goto :eof
)

:: Ensure we're on latest main
echo.
echo === Pulling latest ===
git pull origin main

:: Create and push tags
if not "%CLI_ONLY%"=="1" (
    echo.
    echo === Desktop release: %DESKTOP_TAG% ===
    if "%TAG_EXISTS%"=="1" (
        git tag -d %DESKTOP_TAG% 2>nul
        git push origin :refs/tags/%DESKTOP_TAG% 2>nul
    )
    git tag %DESKTOP_TAG%
    git push origin %DESKTOP_TAG%
    echo   Pushed %DESKTOP_TAG% — check CI: https://github.com/devproven-io/desktop/actions
)

if not "%DESKTOP_ONLY%"=="1" (
    echo.
    echo === CLI release: %CLI_TAG% ===
    if "%TAG_EXISTS%"=="1" (
        git tag -d %CLI_TAG% 2>nul
        git push origin :refs/tags/%CLI_TAG% 2>nul
    )
    git tag %CLI_TAG%
    git push origin %CLI_TAG%
    echo   Pushed %CLI_TAG% — check CI: https://github.com/devproven-io/desktop/actions
)

echo.
echo === Done ===
echo   Monitor: https://github.com/devproven-io/desktop/actions
echo   Desktop: review draft release when CI completes
echo   CLI:     auto-published to NuGet.org
goto :eof

:show_help
echo.
echo DevProven Release Script
echo.
echo Usage:
echo   release.bat                     Bump patch, release both
echo   release.bat 0.3.0               Release both as v0.3.0
echo   release.bat --cli-only          Release only CLI
echo   release.bat --desktop-only      Release only Desktop
echo   release.bat 0.3.0 --cli-only    Release CLI as cli-v0.3.0
echo   release.bat --dry-run           Show plan without pushing
echo   release.bat --help              Show this help
goto :eof
