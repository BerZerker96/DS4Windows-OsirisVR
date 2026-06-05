@echo off
setlocal enabledelayedexpansion

:: ===========================================================================
::  build.bat - compile the head-tracking fork of DS4Windows (verbose)
::
::  Shows full scrolling output (every package + build step) instead of the
::  collapsed one-line "Restore (NNs)" spinner, so you can see progress and
::  tell a slow download apart from a real hang.
::
::  Mirrors the project's own release build (.github/workflows/release.yml).
::  Output: .\build\DS4Windows.exe
::
::  Requirements: .NET 8 SDK (a 9.x SDK works too). To RUN the app you also
::  need the .NET 8 Desktop Runtime + ViGEmBus, same as upstream DS4Windows.
:: ===========================================================================

set CONFIG=Release
set PLATFORM=x64
set PROJECT=DS4Windows\DS4WinWPF.csproj
set OUTDIR=build

:: Verbosity: quiet | minimal | normal | detailed | diagnostic
:: 'normal' lists each package and target; bump to 'detailed' for even more.
set VERBOSITY=normal

:: Turn OFF the terminal logger so output scrolls fully instead of collapsing
:: into a single live-updating line.
set MSBUILDTERMINALLOGGER=off

where dotnet >nul 2>nul
if errorlevel 1 (
    echo [ERROR] .NET SDK not found on PATH.
    echo Install the .NET 8 SDK: https://dotnet.microsoft.com/download/dotnet/8.0
    exit /b 1
)

echo ============================================================
echo  dotnet version
echo ============================================================
dotnet --version
echo.

echo ============================================================
echo  [%TIME%] RESTORE  (downloads packages - slow on first run)
echo ============================================================
dotnet restore "%PROJECT%" -v %VERBOSITY% -tl:off
if errorlevel 1 (
    echo.
    echo [ERROR] restore failed. Check internet / NuGet access, then:
    echo     dotnet nuget locals all --clear
    echo and re-run.
    exit /b 1
)
echo.

echo ============================================================
echo  [%TIME%] PUBLISH  %CONFIG% ^| %PLATFORM%
echo ============================================================
dotnet publish "%PROJECT%" -c %CONFIG% /p:platform=%PLATFORM% -o "%OUTDIR%" -v %VERBOSITY% -tl:off --no-restore
if errorlevel 1 (
    echo.
    echo [ERROR] build failed.
    echo If the error mentions "Microsoft.WindowsDesktop.App" version 8.0,
    echo install the .NET 8 Desktop Runtime and re-run.
    exit /b 1
)

echo.
echo ============================================================
echo  [%TIME%] DONE
echo ============================================================
echo Built: %CD%\%OUTDIR%\DS4Windows.exe
echo.
echo To run, that folder needs the .NET 8 Desktop Runtime and ViGEmBus.
echo For a 32-bit build, set PLATFORM=x86 at the top of this file.
echo For more detail next time, set VERBOSITY=detailed.
endlocal
