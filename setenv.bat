@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

set _PYTHON_PATH=
set _GIT_PATH=

if %_HELP%==1 (
    call :help
    exit /b !_EXITCODE!
)
@rem GraalVM 21.3 and neweer target Java 11/17
call :java11
if not %_EXITCODE%==0 goto end

call :python3
if not %_EXITCODE%==0 goto end

call :msvs
if not %_EXITCODE%==0 goto end

@rem call :sdk
@rem if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

goto end

@rem #########################################################################
@rem ## Subroutines

rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _BASENAME=%~n0
set _DRIVE_NAME=T
set "_ROOT_DIR=%~dp0"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:
goto :eof

:env_colors
@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _RESET=[0m
set _BOLD=[1m
set _UNDERSCORE=[4m
set _INVERSE=[7m

@rem normal foreground colors
set _NORMAL_FG_BLACK=[30m
set _NORMAL_FG_RED=[31m
set _NORMAL_FG_GREEN=[32m
set _NORMAL_FG_YELLOW=[33m
set _NORMAL_FG_BLUE=[34m
set _NORMAL_FG_MAGENTA=[35m
set _NORMAL_FG_CYAN=[36m
set _NORMAL_FG_WHITE=[37m

@rem normal background colors
set _NORMAL_BG_BLACK=[40m
set _NORMAL_BG_RED=[41m
set _NORMAL_BG_GREEN=[42m
set _NORMAL_BG_YELLOW=[43m
set _NORMAL_BG_BLUE=[44m
set _NORMAL_BG_MAGENTA=[45m
set _NORMAL_BG_CYAN=[46m
set _NORMAL_BG_WHITE=[47m

@rem strong foreground colors
set _STRONG_FG_BLACK=[90m
set _STRONG_FG_RED=[91m
set _STRONG_FG_GREEN=[92m
set _STRONG_FG_YELLOW=[93m
set _STRONG_FG_BLUE=[94m
set _STRONG_FG_MAGENTA=[95m
set _STRONG_FG_CYAN=[96m
set _STRONG_FG_WHITE=[97m

@rem strong background colors
set _STRONG_BG_BLACK=[100m
set _STRONG_BG_RED=[101m
set _STRONG_BG_GREEN=[102m
set _STRONG_BG_YELLOW=[103m
set _STRONG_BG_BLUE=[104m
goto :eof

@rem input parameter: %*
:args
set _BASH=0
set _HELP=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-bash" ( set _BASH=1
    ) else if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto args_loop
:args_done
call :subst %_DRIVE_NAME% "%_ROOT_DIR%"
if not %_EXITCODE%==0 goto :eof
if %_DEBUG%==1 echo %_DEBUG_LABEL% _BASH=%_BASH% _HELP=%_HELP% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

@rem input parameter(s): %1: drive letter, %2: path to be substituted
:subst
set __DRIVE_NAME=%~1
set "__GIVEN_PATH=%~2"

if not "%__DRIVE_NAME:~-1%"==":" set __DRIVE_NAME=%__DRIVE_NAME%:
if /i "%__DRIVE_NAME%"=="%__GIVEN_PATH:~0,2%" goto :eof

if "%__GIVEN_PATH:~-1%"=="\" set "__GIVEN_PATH=%__GIVEN_PATH:~0,-1%"
if not exist "%__GIVEN_PATH%" (
    echo %_ERROR_LABEL% Provided path does not exist ^(%__GIVEN_PATH%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
for /f "tokens=1,2,*" %%f in ('subst ^| findstr /b "%__DRIVE_NAME%" 2^>NUL') do (
    set "__SUBST_PATH=%%h"
    if "!__SUBST_PATH!"=="!__GIVEN_PATH!" (
        set __MESSAGE=
        for /f %%i in ('subst ^| findstr /b "%__DRIVE_NAME%\"') do "set __MESSAGE=%%i"
        if defined __MESSAGE (
            if %_DEBUG%==1 ( echo %_DEBUG_LABEL% !__MESSAGE! 1>&2
            ) else if %_VERBOSE%==1 ( echo !__MESSAGE! 1>&2
            )
        )
        goto :eof
    )
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% subst "%__DRIVE_NAME%" "%__GIVEN_PATH%" 1>&2
) else if %_VERBOSE%==1 ( echo Assign path %__GIVEN_PATH% to drive %__DRIVE_NAME% 1>&2
)
subst "%__DRIVE_NAME%" "%__GIVEN_PATH%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to assigned drive %__DRIVE_NAME% to path 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:help
if %_VERBOSE%==1 (
    set __BEG_P=%_STRONG_FG_CYAN%%_UNDERSCORE%
    set __BEG_O=%_STRONG_FG_GREEN%
    set __BEG_N=%_NORMAL_FG_YELLOW%
    set __END=%_RESET%
) else (
    set __BEG_P=
    set __BEG_O=
    set __BEG_N=
    set __END=
)
echo Usage: %__BEG_O%%_BASENAME% { ^<option^> ^| ^<subcommand^> }%__END%
echo.
echo   %__BEG_P%Options:%__END%
echo     %__BEG_O%-bash%__END%       start Git bash shell instead of Windows command prompt
echo     %__BEG_O%-debug%__END%      show commands executed by this script
echo     %__BEG_O%-verbose%__END%    display environment settings
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%help%__END%        display this help message
goto :eof

@rem input parameter: %1=Java version
@rem output parameter: _GRAALVM_HOME
:graal
set __JAVA_VERSION=%~1
set _GRAALVM_HOME=

set __JAVAC_CMD=
for /f %%f in ('where javac.exe 2^>NUL') do set "__JAVAC_CMD=%%f"
if defined __JAVAC_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of javac executable found in PATH 1>&2
    for %%i in ("%__JAVAC_CMD%") do set "__GRAAL_BIN_DIR=%%~dpi"
    for %%f in ("!__GRAAL_BIN_DIR!\.") do set "_GRAALVM_HOME=%%~dpf"
    goto :eof
) else if defined GRAALVM_HOME (
    set "_GRAALVM_HOME=%GRAALVM_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GRAALVM_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce-%__JAVA_VERSION%*" 2^>NUL') do set "_GRAALVM_HOME=!__PATH!\%%f"
    if not defined _GRAALVM_HOME (
        set "__PATH=%ProgramFiles%"
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\graalvm-ce-%__JAVA_VERSION%*" 2^>NUL') do set "_GRAALVM_HOME=!__PATH!\%%f"
    )
)
if not exist "%_GRAALVM_HOME%\bin\javac.exe" (
    echo %_ERROR_LABEL% Executable javac.exe not found ^(%_GRAALVM_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_GRAALVM_HOME%\bin\polyglot.cmd" (
    echo %_ERROR_LABEL% Executable polyglot.cmd not found ^(%_GRAALVM_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:java11
call :graal java11
if not %_EXITCODE%==0 goto :eof
if defined _GRAALVM_HOME set _JAVA_HOME=%_GRAALVM_HOME%
goto :eof

@rem output parameters: _PYTHON_HOME, _PYTHON_PATH
:python3
set _PYTHON_HOME=
set _PYTHON_PATH=

set __PYTHON_CMD=
for /f %%f in ('where python.exe 2^>NUL') do set "__PYTHON_CMD=%%f"
if defined __PYTHON_CMD (
    if not "%__PYTHON_CMD:WindowsApps=%"=="%__PYTHON_CMD%" (
        echo %_WARNING_LABEL% Ignore Windows installed Python 1>&2
        set __PYTHON_CMD=
    )
)
if defined __PYTHON_CMD (
    for %%f in ("%__PYTHON_CMD%") do set "_PYTHON_HOME=%%~dpf"
    set "_PYTHON_HOME=!_PYTHON_HOME:~0,-1!"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Python executable found in PATH 1>&2
    @rem keep _PYTHON_PATH undefined since executable already in path
    goto :eof
) else if defined PYTHON_HOME (
    set "_PYTHON_HOME=%PYTHON_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable PYTHON_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Python\" ( set _PYTHON_HOME=!__PATH!\Python
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Python-3*" 2^>NUL') do set "_PYTHON_HOME=!__PATH!\%%f"
        if not defined _PYTHON_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Python-3*" 2^>NUL') do set "_PYTHON_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%_PYTHON_HOME%\python.exe" (
    echo %_ERROR_LABEL% Python executable not found ^(%_PYTHON_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_PYTHON_HOME%\Scripts\pylint.exe" (
    echo %_ERROR_LABEL% Pylint executable not found ^(%_PYTHON_HOME^) 1>&2
    echo ^(execute command: python -m pip install pylint^) 1>&2
    set _EXITCODE=1
    goto :eof
)
@rem prepend to ignore Windows installed Python
set "_PYTHON_PATH=%_PYTHON_HOME%;%_PYTHON_HOME%\Scripts;"
goto :eof

@rem output parameters: _MSVC_HOME, _MSVC_HOME
@rem Visual Studio 2017/2019
:msvs
set _MSVC_HOME=
set _MSVS_HOME=

set __MSVS_VERSION=2019
for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio\%__MSVS_VERSION%") do set "_MSVS_HOME=%%f"
if not exist "%_MSVS_HOME%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio %__MSVS_VERSION% 1>&2
    set _EXITCODE=1
    goto :eof
)
set __VC_BATCH_FILE=
for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" vcvarsall.bat') do set "__VC_BATCH_FILE=%%f"
if not exist "%__VC_BATCH_FILE%" (
    echo %_ERROR_LABEL% Could not find file vcvarsall.bat in directory "%_MSVS_HOME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
if "%__VC_BATCH_FILE:Community=%"=="%__VC_BATCH_FILE%" ( set "_MSVC_HOME=%_MSVS_HOME%\BuildTools\VC"
) else ( set "_MSVC_HOME=%_MSVS_HOME%\Community\VC"
)
goto :eof

@rem output parameters: _SDK_HOME, _SDK_PATH
@rem native-image dependency
:sdk
set _SDK_HOME=
set _SDK_PATH=

for /f "delims=" %%f in ("%ProgramFiles%\Microsoft SDKs\Windows\v7.1") do set "_SDK_HOME=%%f"
if not exist "%_SDK_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Windows SDK 7.1 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set __SDK_BIN=bin\x64
) else ( set __SDK_BIN=bin
)
set "_SDK_PATH=;%_SDK_HOME%\%__SDK_BIN%"
goto :eof

@rem output parameters: _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_CMD=
for /f %%f in ('where git.exe 2^>NUL') do set "__GIT_CMD=%%f"
if defined __GIT_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    for %%i in ("%__GIT_CMD%") do set "__GIT_BIN_DIR=%%~dpi"
    for %%f in ("!__GIT_BIN_DIR!\.") do set "_GIT_HOME=%%~dpf"
    set "_GIT_HOME=!_GIT_HOME:~0,-1!"
    @rem Executable git.exe is present both in bin\ and \mingw64\bin\
    if not "!_GIT_HOME:mingw=!"=="!_GIT_HOME!" (
        for %%f in ("!_GIT_HOME!\.") do set "_GIT_HOME=%%~dpf"
    )
    @rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "_GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GIT_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set _GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        if not defined _GIT_HOME (
            set "__PATH=%ProgramFiles%"
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo %_ERROR_LABEL% Git executable not found ^(%_GIT_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin;%_GIT_HOME%\usr\bin"
goto :eof

:print_env
set __VERBOSE=%1
set "__VERSIONS_LINE1=  "
set "__VERSIONS_LINE2=  "
set __WHERE_ARGS=
where /q "%PYTHON_HOME%:python.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('"%PYTHON_HOME%\python.exe" --version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% python %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%PYTHON_HOME%:python.exe"
)
where /q pylint.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('pylint.exe --version 2^>^NUL ^| findstr pylint') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% pylint %%j"
    set __WHERE_ARGS=%__WHERE_ARGS% pylint.exe
)
where /q "%GRAALVM_HOME%\bin:javac.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('"%GRAALVM_HOME%\bin\javac.exe" -version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% javac %%j"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GRAALVM_HOME%\bin:javac.exe"
)
where /q "%GIT_HOME%\bin:git.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('"%GIT_HOME%\bin\git.exe" --version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% git %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:git.exe"
)
where /q "%GIT_HOME%\bin:bash.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%i in ('"%GIT_HOME%\bin\bash.exe" --version ^| findstr bash') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% bash %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:bash.exe"
)
echo Tool versions:
echo %__VERSIONS_LINE1%
echo %__VERSIONS_LINE2%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    @rem if %_DEBUG%==1 echo %_DEBUG_LABEL% where %__WHERE_ARGS%
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p 1>&2
)
if %__VERBOSE%==1 (
    echo Environment variables: 1>&2
    if defined GIT_HOME echo    "GIT_HOME=%GIT_HOME%" 1>&2
    if defined GRAALVM_HOME echo    "GRAALVM_HOME=%GRAALVM_HOME%" 1>&2
    if defined JAVA_HOME echo    "JAVA_HOME=%JAVA_HOME%" 1>&2
    if defined MSVC_HOME echo    "MSVC_HOME=%MSVC_HOME%" 1>&2
    if defined MSVS_HOME echo    "MSVS_HOME=%MSVS_HOME%" 1>&2
    if defined PYTHON_HOME echo    "PYTHON_HOME=%PYTHON_HOME%" 1>&2
)
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
endlocal & (
    if %_EXITCODE%==0 (
        if not defined GIT_HOME set "GIT_HOME=%_GIT_HOME%"
        if not defined GRAALVM_HOME set "GRAALVM_HOME=%_GRAALVM_HOME%"
        if not defined JAVA_HOME set "JAVA_HOME=%_GRAALVM_HOME%"
        if not defined MSVC_HOME set "MSVC_HOME=%_MSVC_HOME%"
        if not defined MSVS_HOME set "MSVS_HOME=%_MSVS_HOME%"
        if not defined PYTHON_HOME set "PYTHON_HOME=%_PYTHON_HOME%"
        set "PATH=%_PYTHON_PATH%%PATH%%_GIT_PATH%;%~dp0bin"
        call :print_env %_VERBOSE%
        if %_BASH%==1 (
            if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_HOME%\usr\bin\bash.exe --login 1>&2
            cmd.exe /c "%_GIT_HOME%\usr\bin\bash.exe --login"
        )
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
