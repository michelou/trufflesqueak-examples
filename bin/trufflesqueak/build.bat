@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0..") do set "_ROOT_DIR=%%~sf"

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if %_HELP%==1 (
    call :help
    exit /b !_EXITCODE!
)
if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_UPDATE%==1 (
    call :update
    if not !_EXITCODE!==0 goto end
)
if %_DIST%==1 (
    call :dist
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
@rem                    _GRAAL_PATH, _TRUFFLESQUEAK_PATH, _MX_PATH
:env
@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

for %%f in ("%~dp0") do set "_TRUFFLESQUEAK_PATH=%%~f"

set "_TMP_DIR=%_ROOT_DIR%\tmp"

for /f "delims=" %%f in ('where /r "%MSVS_HOME%" vcvarsall.bat') do set "_VCVARSALL_FILE=%%f"
if not exist "%_VCVARSALL_FILE%" (
    echo %_ERROR_LABEL% Internal error ^(vcvarsall.bat not found^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set _GRAAL_URL=https://github.com/oracle/graal.git
set "_GRAAL_PATH=%_ROOT_DIR%\graal"

set _MX_URL=https://github.com/graalvm/mx.git
set "_MX_PATH=%_ROOT_DIR%\mx"

set _GIT_CMD=git.exe
set _GIT_OPTS=

set "_MX_CMD=%_MX_PATH%\mx.cmd"
set _MX_OPTS=

set _UNZIP_CMD=unzip.exe
set _UNZIP_OPTS=

@rem see https://github.com/graalvm/openjdk8-jvmci-builder/releases
set _JVMCI_VERSION=jvmci-20.1-b02
set _JDK8_UPDATE_VERSION=252
@rem set _JVMCI_VERSION=jvmci-19.2-b01
@rem set _JDK8_UPDATE_VERSION=212
set _JDK8_UPDATE_VERSION_SUFFIX=
@rem rule: <os_name>-<os_arch>, eg. darwin-amd64, linux-amd64, windows-amd64
set _JDK8_PLATFORM=windows-amd64

@rem see https://github.com/oracle/graal/releases/
set _GRAALVM_VERSION=20.0.0
set _GRAALVM_PLATFORM=windows-amd64
goto :eof

@rem input parameter: %*
@rem output paramter(s): _CLEAN, _DIST, _HELP, _VERBOSE, _UPDATE
:args
set _CLEAN=0
set _DIST=0
set _HELP=0
set _TIMER=0
set _UPDATE=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
)
if "%__ARG:~0,1%"=="-" (
    @rem option
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
    @rem subcommand
    if /i "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if /i "%__ARG%"=="dist" ( set _DIST=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else if /i "%__ARG%"=="update" ( set _UPDATE=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo %_DEBUG_LABEL% _CLEAN=%_CLEAN% _DIST=%_DIST% _UPDATE=%_UPDATE% _VERBOSE=%_VERBOSE% 1>&2
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
echo     update      fetch/merge local directories graal/mx
goto :eof

:clean
for %%f in (%_TRUFFLESQUEAK_PATH%\trufflesqueak*.zip %_TRUFFLESQUEAK_PATH%\trufflesqueak*.jar) do (
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

:mx_clone
if exist "%_MX_CMD%" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% %_GIT_OPTS% clone %_MX_URL% %_MX_PATH% 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Clone MX suite repository into directory %_MX_PATH% 1>&2
)
call %_GIT_CMD% %_GIT_OPTS% clone "%_MX_URL%" "%_MX_PATH%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
if not exist "%_MX_CMD%" (
    echo %_ERROR_LABEL% MX command not found ^(%_MX_PATH%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

rem output parameter: _JVMCI_HOME
:jvmci_download
set "__JDK_INSTALL_NAME=openjdk1.8.0_%_JDK8_UPDATE_VERSION%-%_JVMCI_VERSION%"
set "__JDK_TGZ_NAME=openjdk-8u%_JDK8_UPDATE_VERSION%%_JDK8_UPDATE_VERSION_SUFFIX%-%_JVMCI_VERSION%-%_JDK8_PLATFORM%.tar.gz"
set "__JDK_TGZ_URL=https://github.com/graalvm/openjdk8-jvmci-builder/releases/download/%_JVMCI_VERSION%/%__JDK_TGZ_NAME%"
set "__JDK_TGZ_FILE=%_ROOT_DIR%\%__JDK_TGZ_NAME%"

if exist "%_ROOT_DIR%\%__JDK_INSTALL_NAME%\" goto jvmci_done
if exist "%__JDK_TGZ_FILE%" goto jvmci_extract

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -C "wget -OutFile '%__JDK_TGZ_FILE%' -Uri '%__JDK_TGZ_URL%'" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Download OpenJDK 8 archive to directory %_ROOT_DIR% 1>&2
)
powershell -C "$progressPreference='silentlyContinue'; wget -OutFile '%__JDK_TGZ_FILE%' -Uri '%__JDK_TGZ_URL%'"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1 
    goto :eof
)
:jvmci_extract
if not exist "%_TMP_DIR%" mkdir "%_TMP_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_TAR_CMD% -C "%_TMP_DIR%" -xf "%__JDK_TGZ_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Extract archive %__JDK_TGZ_FILE% into directory %_ROOT_DIR% 1>&2
)
rem NB. tar on Windows dislike it when <dir1>=<dir2>, given -xf <dir2>\*.tar.gz and -C <dir1>
call %_TAR_CMD% -C "%_TMP_DIR%" -xf "%__JDK_TGZ_FILE%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% move "%_TMP_DIR%\"%__JDK_INSTALL_NAME%" "%_ROOT_DIR%\" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Move JDK installation directory to directory %_ROOT_DIR% 1>&2
)
move "%_TMP_DIR%\%__JDK_INSTALL_NAME%" "%_ROOT_DIR%\" 1>NUL
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
:jvmci_done
set "_JVMCI_HOME=%_ROOT_DIR%\%__JDK_INSTALL_NAME%"
goto :eof

@rem output parameter: _GRAALVM_HOME
:graalvm_download
set "__GRAALVM_INSTALL_NAME=graalvm-ce-%_GRAALVM_VERSION%"
set "__GRAALVM_ZIP_NAME=graalvm-ce-%_GRAALVM_PLATFORM%-%_GRAALVM_VERSION%.zip"
set "__GRAALVM_ZIP_URL=https://github.com/oracle/graal/releases/download/vm-%_GRAALVM_VERSION%/%__GRAALVM_ZIP_NAME%"
set "__GRAALVM_ZIP_FILE=%_ROOT_DIR%\%__GRAALVM_ZIP_NAME%"

if exist "%_ROOT_DIR%\%__GRAALVM_INSTALL_NAME%\" goto graalvm_done
if exist "%__GRAALVM_ZIP_FILE%" goto graalvm_extract

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -C "wget -OutFile '%__GRAALVM_ZIP_FILE%' -Uri '%__GRAALVM_ZIP_URL%'" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Download GraalVM %_GRAALVM_VERSION% archive to directory %_ROOT_DIR% 1>&2
)
powershell -C "$progressPreference='silentlyContinue'; wget -OutFile '%__GRAALVM_ZIP_FILE%' -Uri '%__GRAALVM_ZIP_URL%'"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
:graalvm_extract
if not exist "%_TMP_DIR%" mkdir "%_TMP_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_UNZIP_CMD% -d "%_TMP_DIR%" "%__GRAALVM_ZIP_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Extract archive %__GRAALVM_ZIP_FILE% into directory %_ROOT_DIR% 1>&2
)
call %_UNZIP_CMD% -d "%_TMP_DIR%" "%__GRAALVM_ZIP_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% move "%_TMP_DIR%\"%__GRAALVM_INSTALL_NAME%" "%_ROOT_DIR%\" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Move GraalVM installation directory to directory %_ROOT_DIR% 1>&2
)
move "%_TMP_DIR%\%__GRAALVM_INSTALL_NAME%" "%_ROOT_DIR%\" 1>NUL
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
:graalvm_done
set "_GRAALVM_HOME=%_ROOT_DIR%\%__GRAALVM_INSTALL_NAME%"
goto :eof

:init_environment
call :mx_clone
if not %_EXITCODE%==0 goto :eof

call :jvmci_download
if not %_EXITCODE%==0 goto :eof

set "JAVA_HOME=%_JVMCI_HOME%"
set "PATH=%_JVMCI_HOME%\bin;%PATH%;%_MX_PATH%"

call "%_VCVARSALL_FILE%" amd64
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
set /a __SHOW_ALL=_DEBUG+_VERBOSE
if not %__SHOW_ALL%==0 (
    @rem mx build tool requires environment variables INCLUDE, LIB and LINK
    echo JAVA_HOME=%JAVA_HOME%
    echo INCLUDE="%INCLUDE%" 1>&2
    echo LIB="%LIB%" 1>&2
    for /f "tokens=1,2,*" %%i in ('%_MX_CMD% --version') do set __MX_VERSION=%%k
    echo MX_VERSION: !__MX_VERSION! 1>&2
)
goto :eof

:dist_test
set __GIT_DESCRIPTION=
for /f %%f in ('"%_GIT_CMD%" describe --tags') do set "__GIT_DESCRIPTION=%%f"
if not defined __GIT_DESCRIPTION (
    for /f %%f in ('"%_GIT_CMD%" log -1 --format="%%h"') do set "__GIT_DESCRIPTION=%%f"
)
set __INSTALLABLE_TARGET=trufflesqueak-installable-%_GRAALVM_PLATFORM%-%__GIT_DESCRIPTION%-for-GraalVM-%_GRAALVM_VERSION%.jar

copy "%_GRAAL_PATH%\sdk\mxbuild\windows-amd64\dists\smalltalk-installable-btrufflesqueak.exe-java8.jar" "%__INSTALLABLE_TARGET%"

@rem defines variable _GRAALVM_HOME
call :graalvm_download
if not %_EXITCODE%==0 goto :eof

call %_UNZIP_CMD% "%__INSTALLABLE_TARGET%" -d "%_GRAALVM_HOME%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
set "_TRUFFLESQUEAK_CMD=%_GRAALVM_HOME%\bin\trufflesqueak.cmd"
set "__IMAGE_FILE=%_TRUFFLESQUEAK_PATH%\images\test-64bit.image"
call "%_TRUFFLESQUEAK_CMD%" --code "String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000" "%__IMAGE_FILE%"
if not %ERRORLEVEL%==0 (
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
call "%_TRUFFLESQUEAK_CMD%" --code "1 tinyBenchmarks" "%__IMAGE_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:dist
setlocal
call :init_environment
if not %_EXITCODE%==0 (
    endlocal
    goto :eof
)
if %_DEBUG%==1 ( set __MX_OPTS=-V %_MX_OPTS%
) else if %_VERBOSE%==1 ( set __MX_OPTS=-v %_MX_OPTS%
) else ( set __MX_OPTS=%_MX_OPTS%
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_MX_CMD% %__MX_OPTS% gate --strict-mode --tags build,test 1>&2
) else if %_VERBOSE%==1 ( echo Execute mx build script ^(step 1^) 1>&2
)
call %_MX_CMD% %__MX_OPTS% gate --strict-mode --tags build,test
if not %ERRORLEVEL%==0 (
    endlocal
    echo %_ERROR_LABEL% mx build failed ^(step 1^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_MX_CMD% %__MX_OPTS% --env ce-trufflesqueak --dy /vm --force-bash-launchers=true build 1>&2
) else if %_VERBOSE%==1 ( echo Execute mx build script ^(step 2^) 1>&2
)
call %_MX_CMD% %_MX_OPTS% --env ce-trufflesqueak --dy /vm --force-bash-launchers=true build
if not %ERRORLEVEL%==0 (
    endlocal
    echo %_ERROR_LABEL% mx build failed ^(step 2^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_MX_CMD% %__MX_OPTS% --env ce-trufflesqueak --dy /vm --force-bash-launchers=true paths SMALLTALK_INSTALLABLE_BGRAALSQUEAK.EXE_JAVA8 1>&2
) else if %_VERBOSE%==1 ( echo Execute mx build script ^(step 3^) 1>&2
)
call %_MX_CMD% %_MX_OPTS% --env ce-trufflesqueak --dy /vm --force-bash-launchers=true paths SMALLTALK_INSTALLABLE_BGRAALSQUEAK.EXE_JAVA8
if not %ERRORLEVEL%==0 (
    endlocal
    echo %_ERROR_LABEL% mx build failed ^(step 3^) 1>&2
    set _EXITCODE=1
    goto :eof
)
endlocal
call :dist_test
if not %_EXITCODE%==0 goto :eof
goto :eof

:update
call :update_mx
if not %_EXITCODE%==0 goto :eof

call :update_trufflesqueak
if not %_EXITCODE%==0 goto :eof
goto :eof

:update_mx
if not exist "%_MX_CMD%" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is %_MX_PATH% 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Current directory is %_MX_PATH% 1>&2
)
pushd "%_MX_PATH%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% %_GIT_OPTS% fetch 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update MX directory %_MX_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% fetch
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% %_GIT_OPTS% merge 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update MX directory %_MX_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% merge
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof


:update_trufflesqueak
if not exist "%_TRUFFLESQUEAK_PATH%\.travis.yml" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is %_TRUFFLESQUEAK_PATH% 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Current directory is %_TRUFFLESQUEAK_PATH% 1>&2
)
pushd "%_TRUFFLESQUEAK_PATH%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% %_GIT_OPTS% fetch upstream dev 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update TruffleSqueak directory %_TRUFFLESQUEAK_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% fetch upstream dev
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% %_GIT_OPTS% merge upstream/dev 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update TruffleSqueak directory %_TRUFFLESQUEAK_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% merge upstream/dev
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

@rem output parameter: _DURATION
:duration
set __START=%~1
set __END=%~2

for /f "delims=" %%i in ('powershell -c "$interval=New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Total elapsed time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
