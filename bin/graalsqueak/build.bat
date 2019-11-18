@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

call :env
if not %_EXITCODE%==0 goto end

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

rem output parameter(s): _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
rem ANSI colors in standard Windows 10 shell
rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

set _MX_CMD=mx.cmd
set _MX_OPTS=
goto :eof

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
set "__ARG=%~1"
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
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    rem subcommand
    set /a __N+=1
    if /i "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if /i "%__ARG%"=="dist" ( set _DIST=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo %_DEBUG_LABEL% _CLEAN=%_CLEAN% _DIST=%_DIST% _VERBOSE=%_VERBOSE% 1>&2
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -debug      show commands executed by this script
echo     -timer      display total elapsed time
echo     -verbose    display progress messages
echo.
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

:dist
setlocal
set /a __SHOW_VERSION=_DEBUG+_VERBOSE
if not %__SHOW_VERSION%==0 (
    for /f "tokens=1,2,*" %%i in ('%_MX_CMD% --version') do set __MX_VERSION=%%k
    echo MX_VERSION: !__MX_VERSION! 1>&2
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_MX_CMD% build 1>&2
) else if %_VERBOSE%==1 ( echo Build Java archives 1>&2
)
call %_MX_CMD% build
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto dist_done
)
set _SCRIPT_FILE=%_ROOT_DIR%scripts\make_component.bat
if not exist "%_SCRIPT_FILE%" (
    echo %_ERROR_LABEL% Batch file !_SCRIPT_FILE:%_ROOT_DIR%=! not found 1>&2
    set _EXITCODE=1
    goto dist_done
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_SCRIPT_FILE% 1>&2
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

for /f "delims=" %%i in ('powershell -c "$interval=New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Total elapsed time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
