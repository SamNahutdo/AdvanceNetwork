@echo off
title Network Management Toolkit
color 1f

:MENU
cls
echo.
echo.
echo          ****      ****     **    **     ****      **    **    ****   ****           
echo         **  **     **  **   **    **    **  **     ****  **   **      *  
echo        ** ** **    **  **    **  **    ** ** **    ** ** **   **      ***      NETWORK TOOLKIT
echo       **      **   ** **      ****    **      **   **   ***    ****   ****   - by Samuel Angelo Udtohan      
echo.
echo            1  Show IP Configuration
echo            2  Flush DNS and Renew IP
echo            3  Ping Multiple Targets
echo            4  Check Internet Connection
echo            5  Restart Network Adapter
echo            6  List Active Network Connections
echo            7  Show Wi-Fi Profiles ^& Passwords
echo            8  Edit Hosts File
echo            9  Exit
echo.
set /p choice=Choose an option 1 - 9: 

if "%choice%"=="1" goto IPConfig
if "%choice%"=="2" goto FlushRenew
if "%choice%"=="3" goto MultiPing
if "%choice%"=="4" goto CheckNet
if "%choice%"=="5" goto RestartAdapter
if "%choice%"=="6" goto ListConnections
if "%choice%"=="7" goto WifiPasswords
if "%choice%"=="8" goto EditHosts
if "%choice%"=="9" exit
echo Invalid choice! Please select 1-9.
pause
goto MENU

:IPConfig
set "timestamp=%date:/=-%_%time::=-%"
set "timestamp=%timestamp: =0%"
set "filename=IPConfig_%timestamp%.txt"
ipconfig /all > "%filename%"
echo IP configuration saved to %filename%.
start notepad "%filename%"
pause
goto MENU

:FlushRenew
echo Flushing DNS and renewing IP...
ipconfig /flushdns
ipconfig /release
ipconfig /renew
echo Done!
pause
goto MENU

:MultiPing
set /p targets=Enter IPs or hostnames (space-separated): 
set "timestamp=%date:/=-%_%time::=-%"
set "timestamp=%timestamp: =0%"
set "filename=MultiPing_%timestamp%.txt"
echo Pinging targets, please wait...

(
    for %%A in (%targets%) do (
        echo ===== Pinging %%A =====
        ping -n 2 %%A
        echo.
    )
) > "%filename%"

echo Results saved to %filename%.
start notepad "%filename%"
pause
goto MENU

:CheckNet
echo Checking internet connection...
ping -n 1 8.8.8.8 >nul
if errorlevel 1 (
    echo  No internet connection.
) else (
    echo  Internet is working.
)
pause
goto MENU

:RestartAdapter
echo Listing network adapters...
netsh interface show interface
echo.
set /p adapterName=Enter adapter name to restart: 
echo Restarting adapter "%adapterName%"...
netsh interface set interface "%adapterName%" admin=disable
timeout /t 3 >nul
netsh interface set interface "%adapterName%" admin=enable
echo Adapter "%adapterName%" restarted successfully.
pause
goto MENU

:ListConnections
netstat -ano | findstr /i "estab" > active_connections.txt
echo Active network connections saved to active_connections.txt
start notepad active_connections.txt
pause
goto MENU

:WifiPasswords
echo Retrieving saved Wi-Fi profiles...
del wifi_keys.txt >nul 2>&1
setlocal EnableDelayedExpansion
for /f "tokens=2 delims=:" %%A in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
    set "profile=%%A"
    set "profile=!profile:~1!"
    echo ==== Profile: !profile! ==== >> wifi_keys.txt
    netsh wlan show profile name="!profile!" key=clear | findstr /c:"SSID name" /c:"Key Content" >> wifi_keys.txt
    echo. >> wifi_keys.txt
)
endlocal
echo Wi-Fi profiles and passwords saved to wifi_keys.txt
start notepad wifi_keys.txt
pause
goto MENU

:EditHosts
echo Opening hosts file for editing...
notepad %windir%\System32\drivers\etc\hosts
goto MENU
