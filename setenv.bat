@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

for %%f in ("%ProgramFiles%") do set _PROGRAM_FILES=%%~sf
for %%f in ("%ProgramFiles(x86)%") do set _PROGRAM_FILES_X86=%%~sf

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

set _GRAAL_PATH=
set _PYTHON_PATH=
set _MX_PATH=
set _MSVS_PATH=
set _SDK_PATH=
set _GIT_PATH=

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

rem input parameter: %*
:args
set _HELP=0
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="help" ( set _HELP=1 & goto args_done
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto args_done
)
shift
goto :args_loop
:args_done
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug      show commands executed by this script
echo     -verbose    display environment settings
echo   Subcommands:
echo     help        display this help message
goto :eof

rem output parameter(s): _GRAAL_HOME, _GRAAL_PATH
:graal
set _GRAAL_HOME=
set _GRAAL_PATH=

set __JAVAC_CMD=
for /f %%f in ('where javac.exe 2^>NUL') do set __JAVAC_CMD=%%f
if defined __JAVAC_CMD (
    if %_DEBUG%==1 echo [%_BASENAME%] Using path of javac executable found in PATH
    for %%i in ("%__JAVAC_CMD%") do set __GRAAL_BIN_DIR=%%~dpsi
    for %%f in ("!__GRAAL_BIN_DIR!..") do set _GRAAL_HOME=%%~sf
    rem keep _GRAAL_PATH undefined since executable already in path
    goto :eof
) else if defined GRAAL_HOME (
    set _GRAAL_HOME=%GRAAL_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable GRAAL_HOME
) else (
    set __PATH=C:\opt
    for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    if not defined _GRAAL_HOME (
        set "__PATH=%_PROGRAM_FILES%"
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\graalvm-ce*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    )
)
if not exist "%_GRAAL_HOME%\bin\javac.exe" (
    echo Error: Executable javac.exe not found ^(%_GRAAL_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_GRAAL_HOME%\bin\polyglot.cmd" (
    echo Error: Executable polyglot.cmd not found ^(%_GRAAL_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem Here we use trailing separator because it will be prepended to PATH
set "_GRAAL_PATH=%_GRAAL_HOME%\bin;"
goto :eof

rem output parameter(s): _PYTHON_PATH
:python
set _PYTHON_PATH=

set __PYTHON_HOME=
set __PYTHON_EXE=
for /f %%f in ('where python.exe 2^>NUL') do set __PYTHON_EXE=%%f
if defined __PYTHON_EXE (
    if %_DEBUG%==1 echo [%_BASENAME%] Using path of Python executable found in PATH
    rem keep _PYTHON_PATH undefined since executable already in path
    goto :eof
) else if defined PYTHON_HOME (
    set "__PYTHON_HOME=%PYTHON_HOME%"
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable PYTHON_HOME
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Python\" ( set __PYTHON_HOME=!__PATH!\Python
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Python-2*" 2^>NUL') do set "__PYTHON_HOME=!__PATH!\%%f"
        if not defined __PYTHON_HOME (
            set "__PATH=%_PROGRAM_FILES%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Python-2*" 2^>NUL') do set "__PYTHON_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%__PYTHON_HOME%\python.exe" (
    echo Error: Python executable not found ^(%__PYTHON_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%__PYTHON_HOME%\Scripts\pylint.exe" (
    echo Error: Pylint executable not found ^(%__PYTHON_HOME^) 1>&2
    echo ^(execute command: python -m pip install pylint^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%__PYTHON_HOME%") do set __PYTHON_HOME=%%~sf
if %_DEBUG%==1 echo [%_BASENAME%] Using default Python installation directory %__PYTHON_HOME% 1>&2

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
goto :eof

:mx
call :mx_git
if not defined _GIT_CMD (
    echo Error: Executable git.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __MX_URL=https://github.com/graalvm/mx.git

set __MX_HOME=%_ROOT_DIR%\mx
if not exist "%__MX_HOME%\" (
    if %_DEBUG%==1 ( echo [%_BASENAME%] %_GIT_CMD% clone %__MX_URL% %__MX_HOME% 1>&2
    else if %_VERBOSE%==1 ( echo Clone mx repository to directory !_MX_HOME:%_ROOT_DIR%=! 1>&2
    )
    %_GIT_CMD% clone %__MX_URL% %__MX_HOME%
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
set "_MX_PATH=;%__MX_HOME%"
goto :eof

rem output parameter(s): _MSVC_HOME, _MSVC_HOME, _MSVS_PATH
rem Visual Studio 10
:msvs
set _MSVC_HOME=
set _MSVS_PATH=
set _MSVS_HOME=

for /f "delims=" %%f in ("%_PROGRAM_FILES_X86%\Microsoft Visual Studio 10.0") do set _MSVS_HOME=%%~sf
if not exist "%_MSVS_HOME%\" (
    echo Error: Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of MSVS installation path
for %%f in ("%_MSVS_HOME%") do set _MSVS_HOME=%%~sf

set "_MSVC_HOME=%_MSVS_HOME%\VC"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set __MSVC_ARCH=\amd64
) else ( set __MSVC_ARCH=
)
if not exist "%_MSVC_HOME%\bin%__MSVC_ARCH%\" (
    echo Error: Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __MSBUILD_HOME=
set "__FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework"
for /f %%f in ('dir /ad /b "%__FRAMEWORK_DIR%\*" 2^>NUL') do set "__MSBUILD_HOME=%__FRAMEWORK_DIR%\%%f"
if not exist "%__MSBUILD_HOME%\MSBuild.exe" (
    echo Error: Could not find Microsoft builder 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MSVS_PATH=;%_MSVC_HOME%\bin%__MSVC_ARCH%;%__MSBUILD_HOME%"
goto :eof

rem output parameter(s): _SDK_HOME, _SDK_PATH
rem native-image dependency
:sdk
set _SDK_HOME=
set _SDK_PATH=

for /f "delims=" %%f in ("%_PROGRAM_FILES%\Microsoft SDKs\Windows\v7.1") do set _SDK_HOME=%%~sf
if not exist "%_SDK_HOME%" (
    echo Error: Could not find installation directory for Microsoft Windows SDK 7.1 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set __SDK_ARCH=\x64
) else ( set __SDK_ARCH=
)
set "_SDK_PATH=;%_SDK_HOME%\bin%__SDK_ARCH%"
goto :eof

rem output parameter(s): _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_EXE=
for /f %%f in ('where git.exe 2^>NUL') do set __GIT_EXE=%%f
if defined __GIT_EXE (
    if %_DEBUG%==1 echo [%_BASENAME%] Using path of Git executable found in PATH 1>&2
    rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "_GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable GIT_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set _GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        if not defined _GIT_HOME (
            set "__PATH=%_PROGRAM_FILES%"
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo Error: Git executable not found ^(%_GIT_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_GIT_HOME%") do set _GIT_HOME=%%~sf
if %_DEBUG%==1 echo [%_BASENAME%] Using default Git installation directory %_GIT_HOME% 1>&2

rem set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\usr\bin;%_GIT_HOME%\mingw64\bin"
set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin"
goto :eof

:print_env
set __VERBOSE=%1
set "__VERSIONS_LINE1=  "
set "__VERSIONS_LINE2=  "
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
    for /f "tokens=1,2,*" %%i in ('pylint.exe --version 2^>^NUL') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% pylint %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% pylint.exe
)
where /q mx.cmd
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('mx.cmd --version 2^>^NUL') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% mx %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% mx.cmd
)
where /q git.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1,2,*" %%i in ('git.exe --version') do set __VERSIONS_LINE2=%__VERSIONS_LINE2% git %%k
    set __WHERE_ARGS=%__WHERE_ARGS% git.exe
)
echo Tool versions:
echo %__VERSIONS_LINE1%
echo %__VERSIONS_LINE2%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    rem if %_DEBUG%==1 echo [%_BASENAME%] where %__WHERE_ARGS%
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p 1>&2
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
endlocal & (
    if %_EXITCODE%==0 (
        if not defined GRAAL_HOME set GRAAL_HOME=%_GRAAL_HOME%
        if not defined JAVA_HOME set JAVA_HOME=%_GRAAL_HOME%
        if not defined MSVC_HOME set MSVC_HOME=%_MSVC_HOME%
        if not defined MSVS_CMAKE_CMD set MSVS_CMAKE_CMD=%_MSVS_CMAKE_CMD%
        if not defined MSVS_HOME set MSVS_HOME=%_MSVS_HOME%
        if not defined SDK_HOME set SDK_HOME=%_SDK_HOME%
        set "PATH=%_GRAAL_PATH%%PATH%%_PYTHON_PATH%%_MX_PATH%%_GIT_PATH%%_MSVS_PATH%%_SDK_PATH%;%~dp0bin"
        call :print_env %_VERBOSE%
    )
    if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
