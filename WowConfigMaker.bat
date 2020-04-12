@echo off
setlocal EnableDelayedExpansion
set setRealmlistInjection="%~dp0SetRealmlist.batInjection"
set interactive=0

call :check_installation success
if not [%success%]==[1] pause & exit /b

if [%1]==[] (echo Usage: drag and drop your Wow folder on this script (folder where Wow.exe located) & pause & exit /b)

if "%~nx1"=="Wow.exe" (set wowFolderLocation="%~dp1") else (set wowFolderLocation="%~1\")
set wowFolderLocation=%wowFolderLocation:"=%
set configFile=%wowFolderLocation%WTF\Config.wtf

if not exist "%configFile%" echo Config file could not be found at '%configFile%'& pause & exit /b

call :parse_config "%configFile%"

if %interactive% equ 1 (
	if not defined realmlist (echo Enter server realmlist& set /p realmlist=)
	if not defined realmName (echo Enter realm name. May be empty& set /p realmName=)
	if not defined accountName (echo Enter your account name. May be empty& set /p accountName=)
)

set realmlistLocation=%wowFolderLocation%Data\%locale%\realmlist.wtf

set configFileLocation=%~dp0%realmlist%
if defined accountName set configFileLocation=%configFileLocation%-%accountName%
set configFileLocation="%configFileLocation:"=%.bat"

echo @echo off>%configFileLocation%
echo call :SetRealmlist "%realmlistLocation%" "%realmlist%" "%realmName%" "%accountName%">>%configFileLocation%
type %setRealmlistInjection% >> %configFileLocation%

echo.
echo New Config created:
echo Realmlist    = '%realmlist%'
echo Realm Name   = '%realmName%'
echo Account name = '%accountName%'
echo Location     = '%configFileLocation%'
echo.
pause
exit /b

:check_installation <success>
set %1=1
if not exist %setRealmlistInjection% echo missing file '%setRealmlistInjection%' & set %1=0
exit /b

:parse_config <configLocation>
set configLocation=%1
for /F "usebackq tokens=*" %%A in (%configLocation%) do (
	set line=%%A
	if /I "!line:~0,4!"=="SET " (
	if /I "!line:~4,10!"=="realmlist " set realmlist=!line:~15,-1!
	if /I "!line:~4,12!"=="accountName " set accountName=!line:~17,-1!
	if /I "!line:~4,10!"=="realmName " set realmName=!line:~15,-1!
	if /I "!line:~4,7!"=="locale " set locale=!line:~12,-1!
	)
)
exit /b

:are_you_sure <success>
	SET /P AREYOUSURE=Are you sure (Y/[N])?
	IF /I "%AREYOUSURE%"=="Y" set %1=1& exit /b
	IF /I "%AREYOUSURE%"=="N" set %1=0& exit /b
goto :are_you_sure
