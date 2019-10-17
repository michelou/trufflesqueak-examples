@echo off
setlocal enabledelayedexpansion

set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _GIT_CMD=git.exe
set _GIT_OPTS=

set _MX_CMD=mx.cmd
set _MX_OPTS=

set _JAR_CMD=jar.exe
set _JAR_OPTS=

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_DIST%==1 (
    call :dist
    if not !_EXITCODE!==0 goto end
)
if %_INSTALL%==1 (
    call :install
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
set _INSTALL=0
set _HELP=0
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="help" ( set _HELP=1 & goto args_done
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-help" ( set _HELP=1 & goto args_done
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else if /i "%__ARG%"=="clean" ( set _CLEAN=1
) else if /i "%__ARG%"=="dist" ( set _DIST=1
) else if /i "%__ARG%"=="install" ( set _INSTALL=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto :eof
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _DIST=%_DIST% _INSTALL=%_INSTALL% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug      show commands executed by this script
echo     -verbose    display progress messages
echo   Subcommands:
echo     clean       delete generated files
echo     dist        generate component archive
echo     help        display this help message
echo     install     add component to Graal installation directory
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

rem input parameter(s): %1=relative source path, %2=absolute target path
rem example: bin\graalsqueak.cmd = ..\jre\languages\smalltalk\bin\graalsqueak.cmd
:install_command
set __SOURCE=%~1
set __TARGET_FILE=%~2

for /f "delims=" %%f in ("%__TARGET_FILE%") do set "__PARENT_DIR=%%~dpf"
if not exist "%__PARENT_DIR%" mkdir "%__PARENT_DIR%"

if %_DEBUG%==1 ( echo [%_BASENAME%] Create file !__TARGET_FILE:%_ROOT_DIR%=! 1>&2
) else if %_VERBOSE%==1 ( echo Create file !__TARGET_FILE:%_ROOT_DIR%=! 1>&2
)
(
    echo @echo off
    echo set location=%%~dp0
    echo "%%location%%%__SOURCE%" %%^*
) > %__TARGET_FILE%
goto :eof

:install
set __JAR_FILE=
for %%f in (%_ROOT_DIR%\*component*.jar) do set __JAR_FILE=%%f
if not exist "%__JAR_FILE%" (
    echo Error: Installable component not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if not defined GRAAL_HOME (
    echo Error: Graal installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __TMP_DIR=%_ROOT_DIR%tmp
if not exist "%__TMP_DIR%" mkdir "%__TMP_DIR%"
pushd "%__TMP_DIR%"

if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAR_CMD% xf "%__JAR_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Extract Graal component into directory !__TMP_DIR:%_ROOT_DIR%=! 1>&2
)
call "%_JAR_CMD%" xf "%__JAR_FILE%"
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto install_done
)
popd
set "__SYMLINKS_FILE=%__TMP_DIR%\META-INF\symlinks"
if not exist "%__SYMLINKS_FILE%" (
    echo Error: File META-INF\symlinks not found 1>&2
    set _EXITCODE=1
    goto install_done
)
for /f "delims=^= tokens=1,*" %%i in (%__SYMLINKS_FILE%) do (
    rem discard leading/trailing blanks
    for %%x in (%%i) do set __TARGET=%%x
    for %%y in (%%j) do set __SOURCE=%%y
    if "!__TARGET:~-3!"=="cmd" (
        call :install_command "!__SOURCE!" "%__TMP_DIR%\!__TARGET!"
        call :install_command "!__SOURCE:jre\=!" "%__TMP_DIR%\jre\!__TARGET!"
        if not !_EXITCODE!==0 goto install_done
    ) else if "!__TARGET:~-3!"=="bat" (
        call :install_command "!__SOURCE!" "%__TMP_DIR%\!__TARGET!"
        call :install_command "!__SOURCE:jre\=!" "%__TMP_DIR%\jre\!__TARGET!"
        if not !_EXITCODE!==0 goto install_done
    )
)
if exist "%__TMP_DIR%\META-INF\" rmdir /s /q "%__TMP_DIR%\META-INF\" 

set /p __CONFIRM=Do you really want to add the component to directory %GRAAL_HOME%?
if /i not "%__CONFIRM%"=="y" goto :eof

if %_DEBUG%==1 ( echo [%_BASENAME%] xcopy /s /y "%__TMP_DIR%\*" "%GRAAL_HOME%\" 1^>NUL 1>&2
) else if %_VERBOSE%==1 ( echo Install Graal component into directory %GRAAL_HOME% 1>&2
)
xcopy /s /y "%__TMP_DIR%\*" "%GRAAL_HOME%\" 1>NUL
if not %ERRORLEVEL%==0 (
    echo Error: Failed to add component to directory %GRAAL_HOME% 1>&2
    set _EXITCODE=1
    goto install_done
)
:install_done
if not %_DEBUG%==1 if exist "%__TMP_DIR%" rmdir /s /q "%__TMP_DIR%"
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
