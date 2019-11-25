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

set _GRAAL_PATH=
set _PYTHON_PATH=
set _MX_PATH=
set _MSVS_PATH=
set _SDK_PATH=
set _GIT_PATH=

if %_HELP%==1 (
    call :help
    exit /b !_EXITCODE!
)
call :graal
if not %_EXITCODE%==0 goto end

call :python
if not %_EXITCODE%==0 goto end

call :msvs
if not %_EXITCODE%==0 goto end

call :sdk
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

call :mx
if not %_EXITCODE%==0 goto end

goto end

rem ##########################################################################
rem ## Subroutines

rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
rem ANSI colors in standard Windows 10 shell
rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

for %%f in ("%ProgramFiles%") do set _PROGRAM_FILES=%%~sf
for %%f in ("%ProgramFiles(x86)%") do set _PROGRAM_FILES_X86=%%~sf

set _GRAAVML_VERSION=java8-19.2
goto :eof

rem input parameter: %*
:args
set _HELP=0
set _TRAVIS=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    rem option
    if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-travis" ( set _TRAVIS=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    rem subcommand
    set /a __N+=1
    if /i "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo %_DEBUG_LABEL% _HELP=%_HELP% _TRAVIS=%_TRAVIS% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -debug      show commands executed by this script
echo     -travis     start Git bash shell instead of Windows command prompt
echo     -verbose    display environment settings
echo.
echo   Subcommands:
echo     help        display this help message
goto :eof

rem output parameters: _GRAAL_HOME, _GRAAL_PATH
:graal
set _GRAAL_HOME=
set _GRAAL_PATH=

set __JAVAC_CMD=
for /f %%f in ('where javac.exe 2^>NUL') do set "__JAVAC_CMD=%%f"
if defined __JAVAC_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of javac executable found in PATH 1>&2
    for %%i in ("%__JAVAC_CMD%") do set __GRAAL_BIN_DIR=%%~dpsi
    for %%f in ("!__GRAAL_BIN_DIR!..") do set _GRAAL_HOME=%%~sf
    rem keep _GRAAL_PATH undefined since executable already in path
    goto :eof
) else if defined GRAAL_HOME (
    set _GRAAL_HOME=%GRAAL_HOME%
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GRAAL_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce-%_GRAAVML_VERSION%*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    if not defined _GRAAL_HOME (
        set "__PATH=%ProgramFiles%"
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\graalvm-ce-%_GRAAVML_VERSION%*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    )
)
if not exist "%_GRAAL_HOME%\bin\javac.exe" (
    echo %_ERROR_LABEL% Executable javac.exe not found ^(%_GRAAL_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_GRAAL_HOME%\bin\polyglot.cmd" (
    echo %_ERROR_LABEL% Executable polyglot.cmd not found ^(%_GRAAL_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem Here we use trailing separator because it will be prepended to PATH
set "_GRAAL_PATH=%_GRAAL_HOME%\bin;"
goto :eof

rem output parameter: _PYTHON_PATH
:python
set _PYTHON_PATH=

set __PYTHON_HOME=
set __PYTHON_CMD=
for /f %%f in ('where python.exe 2^>NUL') do set "__PYTHON_CMD=%%f"
if defined __PYTHON_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Python executable found in PATH 1>&2
    rem keep _PYTHON_PATH undefined since executable already in path
    goto :eof
) else if defined PYTHON_HOME (
    set "__PYTHON_HOME=%PYTHON_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable PYTHON_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Python\" ( set __PYTHON_HOME=!__PATH!\Python
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Python-2*" 2^>NUL') do set "__PYTHON_HOME=!__PATH!\%%f"
        if not defined __PYTHON_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Python-2*" 2^>NUL') do set "__PYTHON_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%__PYTHON_HOME%\python.exe" (
    echo %_ERROR_LABEL% Python executable not found ^(%__PYTHON_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%__PYTHON_HOME%\Scripts\pylint.exe" (
    echo %_ERROR_LABEL% Pylint executable not found ^(%__PYTHON_HOME^) 1>&2
    echo ^(execute command: python -m pip install pylint^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%__PYTHON_HOME%") do set __PYTHON_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Python installation directory %__PYTHON_HOME% 1>&2

set "_PYTHON_PATH=;%__PYTHON_HOME%;%__PYTHON_HOME%\Scripts"
goto :eof

rem output parameter: _GIT_CMD
:mx_git
set _GIT_CMD=

where /q git.exe
if %ERRORLEVEL%==0 (
    set _GIT_CMD=git.exe
) else if defined _GIT_HOME (
    where /q "%_GIT_HOME%\bin:git.exe"
    if !ERRORLEVEL!==0 (
        set "_GIT_CMD=%_GIT_HOME%\bin\git.exe"
    )
)
if not defined _GIT_CMD (
    echo %_ERROR_LABEL% Executable git.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:mx
call :mx_git
if not %_EXITCODE%==0 goto :eof

set __MX_URL=https://github.com/graalvm/mx.git

set __MX_HOME=%_ROOT_DIR%mx
if exist "%__MX_HOME%\mx.cmd" (
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% fetch ^&^& %_GIT_CMD% merge 1^>NUL 1>&2
    ) else if %_VERBOSE%==1 ( echo Update mx directory %__MX_HOME% 1>&2
    )
    call "%_GIT_CMD%" -C "%__MX_HOME%" fetch && call "%_GIT_CMD%" -C "%__MX_HOME%" merge 1>NUL
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
) else (
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% clone %__MX_URL% %__MX_HOME% 1>&2
    ) else if %_VERBOSE%==1 ( echo Clone mx repository to directory !_MX_HOME:%_ROOT_DIR%=! 1>&2
    )
    call "%_GIT_CMD%" clone "%__MX_URL%" "%__MX_HOME%"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
set "_MX_PATH=;%__MX_HOME%"
goto :eof

rem output parameters: _MSVC_HOME, _MSVC_HOME, _MSVS_PATH
rem Visual Studio 10
:msvs
set _MSVC_HOME=
set _MSVS_PATH=
set _MSVS_HOME=

for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio 10.0") do set "_MSVS_HOME=%%f"
if not exist "%_MSVS_HOME%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of MSVS installation path
for %%f in ("%_MSVS_HOME%") do set _MSVS_HOME=%%~sf

set "_MSVC_HOME=%_MSVS_HOME%\VC"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set __MSVC_BIN=bin\amd64
) else ( set __MSVC_BIN=bin
)
if not exist "%_MSVC_HOME%\%__MSVC_BIN%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __MSBUILD_HOME=
set "__FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework"
for /f %%f in ('dir /ad /b "%__FRAMEWORK_DIR%\*" 2^>NUL') do set "__MSBUILD_HOME=%__FRAMEWORK_DIR%\%%f"
if not exist "%__MSBUILD_HOME%\MSBuild.exe" (
    echo %_ERROR_LABEL% Could not find Microsoft builder 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MSVS_PATH=;%_MSVC_HOME%\%__MSVC_BIN%;%__MSBUILD_HOME%"
goto :eof

rem output parameter(s): _SDK_HOME, _SDK_PATH
rem native-image dependency
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

rem output parameter(s): _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_CMD=
for /f %%f in ('where git.exe 2^>NUL') do set "__GIT_CMD=%%f"
if defined __GIT_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    for %%i in ("%__GIT_CMD%") do set __GIT_BIN_DIR=%%~dpsi
    for %%f in ("!__GIT_BIN_DIR!..") do set _GIT_HOME=%%~sf
    rem Executable git.exe is present both in bin\ and \mingw64\bin\
    if not "!_GIT_HOME:mingw=!"=="!_GIT_HOME!" (
        for %%f in ("!_GIT_HOME!\..") do set _GIT_HOME=%%~sf
    )
    rem keep _GIT_PATH undefined since executable already in path
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
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_GIT_HOME%") do set _GIT_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory %_GIT_HOME% 1>&2

set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin;%_GIT_HOME%\usr\bin"
goto :eof

:print_env
set __VERBOSE=%1
set __GIT_HOME=%~2
set "__VERSIONS_LINE1=  "
set "__VERSIONS_LINE2=  "
set "__VERSIONS_LINE3=  "
set __WHERE_ARGS=
where /q javac.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('javac.exe -version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% javac %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% javac.exe
)
where /q python.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('python.exe --version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% python %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% python.exe
)
where /q pylint.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('pylint.exe --version 2^>^NUL ^| findstr pylint') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% pylint %%j"
    set __WHERE_ARGS=%__WHERE_ARGS% pylint.exe
)
where /q mx.cmd
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('mx.cmd --version 2^>^NUL') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% mx %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% mx.cmd
)
where /q link.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-5,*" %%i in ('link.exe ^| findstr Version 2^>^NUL') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% link %%n,"
    set __WHERE_ARGS=%__WHERE_ARGS% link.exe
)
where /q uuidgen.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%i in ('uuidgen.exe -version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% uuidgen %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% uuidgen.exe
)
where /q git.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('git.exe --version') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% git %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% git.exe
)
where /q "%__GIT_HOME%\bin":bash.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%i in ('"%__GIT_HOME%\bin\bash.exe" --version ^| findstr bash') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% bash %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% "%__GIT_HOME%\bin:bash.exe"
)
echo Tool versions:
echo %__VERSIONS_LINE1%
echo %__VERSIONS_LINE2%
echo %__VERSIONS_LINE3%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    rem if %_DEBUG%==1 echo %_DEBUG_LABEL% where %__WHERE_ARGS%
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p 1>&2
)
if %__VERBOSE%==1 if defined INCLUDE (
    echo Environment variables: 1>&2
    echo    INCLUDE="%INCLUDE%" 1>&2
    echo    LIB="%LIB%" 1>&2
    echo    LINK="%LINK%" 1>&2
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
endlocal & (
    if %_EXITCODE%==0 (
        if not defined GRAAL_HOME set "GRAAL_HOME=%_GRAAL_HOME%"
        if not defined JAVA_HOME set "JAVA_HOME=%_GRAAL_HOME%"
        if not defined MSVC_HOME set "MSVC_HOME=%_MSVC_HOME%"
        if not defined MSVS_CMAKE_CMD set "MSVS_CMAKE_CMD=%_MSVS_CMAKE_CMD%"
        if not defined MSVS_HOME set "MSVS_HOME=%_MSVS_HOME%"
        if not defined SDK_HOME set "SDK_HOME=%_SDK_HOME%"
        set "PATH=%_GRAAL_PATH%%PATH%%_PYTHON_PATH%%_MX_PATH%%_MSVS_PATH%%_SDK_PATH%%_GIT_PATH%;%~dp0bin"
        rem mx command tool requires environment variables INCLUDE, LIB and LINK
        rem (minimal version of "%_MSVC_HOME%\Auxiliary\Build\vcvarsall.bat" amd64)
        set "INCLUDE=%_MSVC_HOME%\include;%_SDK_HOME%\include"
        if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
            set "LIB=%_MSVC_HOME%\Lib\amd64;%_SDK_HOME%\lib\x64"
            set "LINK=%_MSVC_HOME%\bin\amd64\link.exe"
        ) else (
            set "LIB=%_MSVC_HOME%\Lib\x86;%_SDK_HOME%\lib"
            set "LINK=%_MSVC_HOME%\bin\link.exe"
        )
        call :print_env %_VERBOSE% "%_GIT_HOME%"
        if %_TRAVIS%==1 (
            if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_HOME%\bin\bash.exe --login 1>&2
            cmd.exe /c "%_GIT_HOME%\bin\bash.exe --login"
        )
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
