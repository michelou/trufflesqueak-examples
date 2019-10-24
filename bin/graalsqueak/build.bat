@echo off
setlocal enabledelayedexpansion

set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _MX_CMD=mx.cmd
set _MX_OPTS=

call :args %*
if not %_EXITCODE%==0 goto end

rem ##########################################################################
rem ## Main

if %_HELP%==1 (
    call :help
    exit /b %_EXITCODE%
)
if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_DIST%==1 (
    call :dist
    if not !_EXITCODE!==0 goto end
)
goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
rem output paramter(s): _CLEAN, _DIST, _HELP, _VERBOSE, _UPDATE
:args
set _CLEAN=0
set _DIST=0
set _HELP=0
set _TIMER=0
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
)

if "%__ARG:~0,1%"=="-" (
    rem option
    if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-help" ( set _HELP=1
    ) else if /i "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo Error: Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    rem subcommand
    set /a __N=!__N!+1
    if /i "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if /i "%__ARG%"=="dist" ( set _DIST=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo Error: Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto :args_loop
:args_done
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _DIST=%_DIST% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug      show commands executed by this script
echo     -timer      display total elapsed time
echo     -verbose    display progress messages
echo   Subcommands:
echo     clean       delete generated files
echo     dist        generate component archive
echo     help        display this help message
goto :eof

:clean
for %%f in (%_ROOT_DIR%\graalsqueak*.zip %_ROOT_DIR%\graalsqueak*.jar) do (
    del %%f
)
goto :eof

:rmdir
set __DIR=%~1
if not exist "%__DIR%\" goto :eof
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:dist_env_msvc
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set __MSVC_ARCH=\amd64
    set __NET_ARCH=Framework64\v4.0.30319
    set __SDK_ARCH=\x64
    set __KIT_ARCH=\x64
) else (
    set __MSVC_ARCH=\x86
    set __NET_ARCH=Framework\v4.0.30319
    set __SDK_ARCH=
    set __KIT_ARCH=\x86
)
rem Variables MSVC_HOME, MSVS_HOME and SDK_HOME are defined by setenv.bat
set INCLUDE=%MSVC_HOME%\include;%SDK_HOME%\include
set LIB=%MSVC_HOME%\Lib%__MSVC_ARCH%;%SDK_HOME%\lib%__SDK_ARCH%
if %_DEBUG%==1 (
    echo [%_BASENAME%] ===== B U I L D   V A R I A B L E S ===== 1>&2
    echo [%_BASENAME%] INCLUDE=%INCLUDE% 1>&2
    echo [%_BASENAME%] LIB=%LIB% 1>&2
    echo [%_BASENAME%] ========================================= 1>&2
)
goto :eof

:dist
setlocal
call :dist_env_msvc

set /a __SHOW_VERSION=_DEBUG+_VERBOSE
if not %__SHOW_VERSION%==0 (
    for /f "tokens=1,2,*" %%i in ('%_MX_CMD% --version') do set __MX_VERSION=%%k
    echo MX_VERSION: !__MX_VERSION! 1>&2
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_MX_CMD% build 1>&2
) else if %_VERBOSE%==1 ( echo Build Java archives 1>&2
)
call %_MX_CMD% build
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto dist_done
)
set _SCRIPT_FILE=%_ROOT_DIR%scripts\make_component.bat
if not exist "%_SCRIPT_FILE%" (
    echo Error: Batch file !_SCRIPT_FILE:%_ROOT_DIR%=! not found 1>&2
    set _EXITCODE=1
    goto dist_done
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_SCRIPT_FILE% 1>&2
) else if %_VERBOSE%==1 ( echo Executing script !_SCRIPT_FILE:%_ROOT_DIR%=! 1>&2
)
call "%_SCRIPT_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto dist_done
)
:dist_done
endlocal
goto :eof

rem output parameter: _DURATION
:duration
set __START=%~1
set __END=%~2

for /f "delims=" %%i in ('powershell -c "$interval = New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Elapsed time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
