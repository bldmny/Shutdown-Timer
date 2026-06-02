@echo off
title Shutdown Timer

:: Check for Administrator privileges
net session >nul 2>&1
if errorlevel 1 (
echo.
echo WARNING: This utility is not running as Administrator.
echo Some shutdown operations may fail.
echo.
timeout /t 3 >nul
)

:start
cls

echo.
echo        S H U T D O W N  T I M E R
echo.
echo Commands:
echo   cancel = Cancel scheduled shutdown
echo   close  = Exit this utility
echo.

set /p timeinput=When would you like your PC to turn off? :

if /i "%timeinput%"=="close" goto goodbye

if /i "%timeinput%"=="cancel" (
shutdown -a >nul 2>&1

echo.
if not errorlevel 1 (
    echo Shutdown cancelled successfully.
) else (
    echo Shutdown cancellation unsuccessful.
    echo There may not be a shutdown scheduled,
    echo or administrator privileges may be required.
)

timeout /t 3 >nul
goto start
)

:: Remove spaces
set input=%timeinput: =%

:: Extract number
for /f "tokens=1 delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" %%A in ("%input%") do set value=%%A

:: Extract unit text
call set unit=%%input:%value%=%%

set seconds=
set display=

:: Seconds
if /i "%unit%"=="s" set /a seconds=%value%& set display=second
if /i "%unit%"=="sec" set /a seconds=%value%& set display=second
if /i "%unit%"=="secs" set /a seconds=%value%& set display=second
if /i "%unit%"=="second" set /a seconds=%value%& set display=second
if /i "%unit%"=="seconds" set /a seconds=%value%& set display=second

:: Minutes
if /i "%unit%"=="m" set /a seconds=%value%*60& set display=minute
if /i "%unit%"=="min" set /a seconds=%value%*60& set display=minute
if /i "%unit%"=="mins" set /a seconds=%value%*60& set display=minute
if /i "%unit%"=="minute" set /a seconds=%value%*60& set display=minute
if /i "%unit%"=="minutes" set /a seconds=%value%*60& set display=minute

:: Hours
if /i "%unit%"=="h" set /a seconds=%value%*3600& set display=hour
if /i "%unit%"=="hr" set /a seconds=%value%*3600& set display=hour
if /i "%unit%"=="hrs" set /a seconds=%value%*3600& set display=hour
if /i "%unit%"=="hour" set /a seconds=%value%*3600& set display=hour
if /i "%unit%"=="hours" set /a seconds=%value%*3600& set display=hour

:: Days
if /i "%unit%"=="d" set /a seconds=%value%*86400& set display=day
if /i "%unit%"=="day" set /a seconds=%value%*86400& set display=day
if /i "%unit%"=="days" set /a seconds=%value%*86400& set display=day

if "%seconds%"=="" (
echo.
echo Invalid format.
echo.
echo Examples:
echo   30s
echo   30 seconds
echo   45m
echo   45 minutes
echo   3h
echo   3 hours
echo   2d
echo   2 days
timeout /t 3 >nul
goto start
)

if %value% LEQ 0 (
    echo.
    echo Please enter a time greater than zero.
    timeout /t 3 >nul
    goto start
)

set plural=s
if "%value%"=="1" set plural=

echo.
echo Your PC will shut down in %value% %display%%plural%.
echo.

:confirm_again
set /p confirm=Are you sure? (Y/N):

if /i "%confirm%"=="y" goto schedule
if /i "%confirm%"=="yes" goto schedule
if /i "%confirm%"=="n" goto cancelled
if /i "%confirm%"=="no" goto cancelled

echo.
echo Please enter Y, Yes, N or No.
timeout /t 2 >nul
goto confirm_again

:schedule

set replacedShutdown=0

:: Check if a shutdown already exists and cancel it
shutdown -a >nul 2>&1
if not errorlevel 1 (
    set replacedShutdown=1
)

shutdown -s -t %seconds% >nul 2>&1

echo.

if "%replacedShutdown%"=="1" (
    echo A shutdown was already scheduled.
    echo The existing shutdown has been replaced.
    echo.
)

if not errorlevel 1 (
    echo Shutdown scheduled successfully.
) else (
    echo Shutdown scheduling unsuccessful.
    echo Administrator privileges may be required.
)

timeout /t 3 >nul
goto start

:cancelled
echo.
echo No problem, let's try again.
timeout /t 1 >nul
goto start

:goodbye
echo.
echo Goodbye :)
timeout /t 2 >nul
exit
