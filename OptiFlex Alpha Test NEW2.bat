@echo off
title Preparing...
color 06
Mode 130,45
setlocal EnableDelayedExpansion

REM Make Directories
mkdir %SYSTEMDRIVE%\OptiFlex >nul 2>&1
mkdir %SYSTEMDRIVE%\OptiFlex\Resources >nul 2>&1
mkdir %SYSTEMDRIVE%\OptiFlex\OptiFlexRevert >nul 2>&1
mkdir %SYSTEMDRIVE%\OptiFlex\Drivers >nul 2>&1
mkdir %SYSTEMDRIVE%\OptiFlex\Renders >nul 2>&1
cd %SYSTEMDRIVE%\OptiFlex

REM Run as Admin
reg add HKLM /F >nul 2>&1
if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

REM Show Detailed BSoD
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t REG_DWORD /d "1" /f >nul 2>&1


REM Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

REM Add ANSI escape sequences
reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1


:Disclaimer
reg query "HKCU\Software\OptiFlex" /v "Disclaimer" >nul 2>&1 && goto CheckForUpdates
cls
echo.
echo.
call :OptiFlexTitle
echo.
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[37m  Please note that we cannot guarantee an FPS boost from applying our optimizations, every system + configuration is different.
echo.
echo     %COL%[33m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way
echo        (ex. not following the disclaimers carefully).
echo.
echo     %COL%[33m2.%COL%[37m If you don't know what a tweak is, do not use it and contact our support team to receive more assistance.
echo.
echo     %COL%[33m3.%COL%[37m Even though we have an automatic restore point feature, we highly recommend making a manual restore point before running.
echo.
echo   For any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   Please enter "I agree" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i agree" goto Disclaimer
reg add "HKCU\Software\OptiFlex" /v "Disclaimer" /f >nul 2>&1

:CheckForUpdates	
set local=1
set localtwo=%LOCAL%
if exist "%TEMP%\Updater.bat" DEL /S /Q /F "%TEMP%\Updater.bat" >nul 2>&1
curl -g -L -# -o "%TEMP%\Updater.bat" "https://raw.githubusercontent.com/NEST-B/OptiFlex/main/OptiFlexCtrlVer" >nul 2>&1
call "%TEMP%\Updater.bat"
if "%LOCAL%" gtr "%LOCALTWO%" (
	clsr
	Mode 65,16
	echo.
	echo  --------------------------------------------------------------
	echo                           Update found
	echo  --------------------------------------------------------------
	echo.
	echo                    Your current version: %LOCALTWO%
	echo.
	echo                          New version: %LOCAL%
	echo.
	echo.
	echo.
	echo      [Y] Yes, Update
	echo      [N] No
	echo.
	%SYSTEMROOT%\System32\choice.exe /c:YN /n /m "%DEL%                                >:"
	set choice=!errorlevel!
	if !choice! == 1 (
		curl -L -o %0 "https://github.com/auraside/HoneCtrl/releases/latest/download/HoneCtrl.Bat" >nul 2>&1
		call %0
		exit /b
	)
	Mode 130,45
)

REM Restart Checks
if exist "%SYSTEMDRIVE%\Hone\Drivers\NvidiaHone.exe" "%SYSTEMDRIVE%\Desktop\Hone\Drivers\NvidiaHone.exe" >nul 2>&1
if exist "%SYSTEMDRIVE%\Hone\Drivers\NvidiaHone.exe" del /Q "%SYSTEMDRIVE%\Desktop\Hone\Drivers\NvidiaHone.exe" >nul 2>&1
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Driverinstall.bat" del /Q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Driverinstall.bat" >nul 2>&1

REM Attempt to enable WMIC
dism /online /enable-feature /featurename:MicrosoftWindowsWMICore /NoRestart >nul 2>&1

REM Check If First Launch
set firstlaunch=1
>nul 2>&1 call "%SYSTEMDRIVE%\Hone\HoneRevert\firstlaunch.bat"
if "%firstlaunch%" == "0" (goto MainMenu)

REM Restore Point
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'Hone Restore Point' >nul 2>&1

REM HKCU & HKLM backup

for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
>nul 2>&1 md %SYSTEMDRIVE%\Hone\HoneRevert\%date1%
reg export HKCU %SYSTEMDRIVE%\Hone\HoneRevert\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\Hone\HoneRevert\%date1%\HKCU.reg /y >nul 2>&1
echo set "firstlaunch=0" > %SYSTEMDRIVE%\Hone\HoneRevert\firstlaunch.bat

:MainMenu
Mode 130,45
TITLE Hone Control Panel %localtwo%
set "choice="
cls
echo.
echo.
call :OptiFlexTitle
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                           %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Optimizations        %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m Game Settings
echo.
echo.
echo.
echo.
echo                                     %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m Media         %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[90m Privacy        %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[90m Aesthetics
echo.
echo.
echo.
echo.
echo                                               %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Advanced           %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m More
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                            %COL%[31m[ X to close ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:1234567XD /n /m "%DEL%                                        Select a corresponding number to the options above > "
set choice=%errorlevel%
if "%choice%"=="1" set PG=TweaksPG1 & goto Tweaks
if "%choice%"=="2" goto GameSettings
if "%choice%"=="3" goto HoneRenders
if "%choice%"=="4" call:Comingsoon
if "%choice%"=="5" call:Comingsoon
if "%choice%"=="6" goto disclaimer2
if "%choice%"=="7" goto More
if "%choice%"=="8" exit /b
if "%choice%"=="9" goto Dog
goto MainMenu

:OptiFlexTitle
echo.
echo.
echo:                       ::  ______     ______   ______   __     ______   __         ______     __  __    
echo:                       :: /\  __ \   /\  == \ /\__  _\ /\ \   /\  ___\ /\ \       /\  ___\   /\_\_\_\   :: 
echo:                       :: \ \ \/\ \  \ \  _-/ \/_/\ \/ \ \ \  \ \  __\ \ \ \____  \ \  __\   \/_/\_\/_  ::
echo:                       ::  \ \_____\  \ \_\      \ \_\  \ \_\  \ \_\    \ \_____\  \ \_____\   /\_\/\_\ ::
echo:                       ::   \/_____/   \/_/       \/_/   \/_/   \/_/     \/_____/   \/_____/   \/_/\/_/ ::
echo.
echo:                                                ::OptiFlex Alpha Test V.1.3.1::
echo.
echo.
goto :eof