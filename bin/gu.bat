@echo off
setlocal enabledelayedexpansion

set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _WORKING_DIR=%TEMP%\graal-updater

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

rem ##########################################################################
rem ## Main

if %_COMMAND%==available call :available
if %_COMMAND%==info      call :info
if %_COMMAND%==install   call :install
if %_COMMAND%==list      call :list
if %_COMMAND%==remove    call :remove
if %_COMMAND%==update    call :update
if %_COMMAND%==none      call :help
goto end

rem ##########################################################################
rem ## Subroutines

rem output parameter(s): _JAR_CMD, _GRAALVM_VERSION, _CATALOG_URL, _OS_ARCH, _OS_NAME
:env
if not defined GRAAL_HOME (
    echo [91mError[0m: Environment variable GRAAL_HOME is undefined 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_JAR_CMD=%GRAAL_HOME%\bin\jar.exe"
if not exist "%_JAR_CMD%" (
    echo [91mError[0m: Executable jar.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%GRAAL_HOME%\release" (
    echo [91mError[0m: GraalVM installation directory is invalid 1>&2
    set _EXITCODE=1
    goto :eof
)
rem component_catalog=https://www.graalvm.org/component-catalog/graal-updater-component-catalog.properties
set _CATALOG_URL=
set _GRAALVM_VERSION=
set _OS_ARCH=
set _OS_NAME=
for /f "delims=^= tokens=1,*" %%f in (%GRAAL_HOME%\release) do (
    if /i "%%f"=="component_catalog" ( SET "_CATALOG_URL=%%g"
    ) else if /i "%%f"=="GRAALVM_VERSION" ( set "_GRAALVM_VERSION=%%g"
    ) else if /i "%%f"=="OS_ARCH" ( set "_OS_ARCH=%%g"
    ) else if /i "%%f"=="OS_NAME" ( set "_OS_NAME=%%g"
    )
)
rem TODO remove (for testing only)
set _OS_NAME=linux
if %_DEBUG%==1 echo [%_BASENAME%] _CATALOG_URL=%_CATALOG_URL% _GRAALVM_VERSION=%_GRAALVM_VERSION% _OS_ARCH=%_OS_ARCH% _OS_NAME=%_OS_NAME%
goto :eof

rem output parameter: _IS_VALID
:is_valid
set __VALID_SET=%~1
set __INPUT_SET=%~2
if %_DEBUG%==1 echo [%_BASENAME%] __VALID_SET=%__VALID_SET% __INPUT_SET=%__INPUT_SET%

set _IS_VALID=1
:is_valid_loop
if defined __INPUT_SET (
    set "__ELEM=!__INPUT_SET:~0,1!"
    if %_DEBUG%==1 echo [%_BASENAME%] __VALID_SET=%__VALID_SET% __ELEM=!__ELEM!
    if "!__VALID_SET:%__ELEM%=!"=="%__VALID_SET%" (
        set _IS_VALID=
        goto is_valid_done
    )
    set "__INPUT_SET=!__INPUT_SET:~1!"
    goto is_valid_loop
)
:is_valid_done
goto :eof

rem input parameter: %1=long option
rem output parameter: _SHORT_OPTION (-9: long option is unknown)
:short_option
set __LONG_OPTION=%~1

set _SHORT_OPTION=-9
if %__LONG_OPTION%==debug ( set _SHORT_OPTION=-d
) else if %__LONG_OPTION%==help ( set _SHORT_OPTION=-h
) else if %__LONG_OPTION%==force ( set _SHORT_OPTION=-f
) else if %__LONG_OPTION%==local-file ( set _SHORT_OPTION=-L
) else if %__LONG_OPTION%==no-progress ( set _SHORT_OPTION=-n
) else if %__LONG_OPTION%==overwrite ( set _SHORT_OPTION=-o
) else if %__LONG_OPTION%==replace ( set _SHORT_OPTION=-r
) else if %__LONG_OPTION%==url ( set _SHORT_OPTION=-u
) else if %__LONG_OPTION%==verbose ( set _SHORT_OPTION=-v
)
goto :eof

rem output parameter(s): _COMMAND, _OPTIONS, _PARAMS
rem see https://docs.oracle.com/en/graalvm/enterprise/19/guide/reference/graalvm-updater.html
:args
set _COMMAND=none
set _OPTIONS=
set _PARAMS=
set _PARAMS_N=0
set _HELP=0
set _VERBOSE=0

set __N=0
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
)
if "%__ARG%"=="info" (
    set _COMMAND=info
    set _COMMAND_OPTS=cDhLprstuv
) else if "%__ARG%"=="available" (
    set _COMMAND=available
    set _COMMAND_OPTS=Dhlv
) else if "%__ARG%"=="install" (
    set _COMMAND=install
    set _COMMAND_OPTS=0cDhfiLnoruv rem 0cDhfiLnorvyxY
) else if "%__ARG%"=="list" (
    set _COMMAND=list
    set _COMMAND_OPTS=cDhlv
) else if "%__ARG%"=="rebuild-images" (
    set _COMMAND=rebuild
    set _COMMAND_OPTS=Dv
) else if "%__ARG%"=="remove" (
    set _COMMAND=remove
    set _COMMAND_OPTS=0Dfhvxv
) else if "%__ARG%"=="update" (
    set _COMMAND=update
    set _COMMAND_OPTS=Dhxv
) else if "%__ARG%"=="-h" ( set _HELP=1
) else if "%__ARG%"=="--help" ( set _HELP=1
) else (
    echo [91mError[0m: Unkown command %__ARG% 1>&2
    set _EXITCODE=1
    goto args_next
)
shift
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "!__ARG:~0,2!"=="--" (
    call :short_option "!__ARG:~2!"
    set "__ARG=!_SHORT_OPTION!"
)
if "!__ARG:~0,1!"=="-" (
    rem custom option: -D
    call :is_valid "%_COMMAND_OPTS%" "!__ARG:~1!"
    if defined _IS_VALID ( set "_OPTIONS=!_OPTIONS!!__ARG:~1!"
    ) else (
        echo [91mError[0m: Invalid option !__ARG! for command info 1>&2
        set _EXITCODE=1
    )
) else (
    set "_PARAMS=!__ARG!"
    goto args_next
)
shift
goto :args_loop
:args_next
set /a _PARAMS_N+=1
shift
set "__PARAM=%~1"
if defined __PARAM (
    set "_PARAMS=!_PARAMS! %__PARAM%"
    goto args_next
)
:args_done
rem global options
if defined _OPTIONS (
    if not "!_OPTIONS:D=!"=="!_OPTIONS!" set _DEBUG=1
    if not "!_OPTIONS:h=!"=="!_OPTIONS!" set _HELP=1
    if not "!_OPTIONS:v=!"=="!_OPTIONS!" set _VERBOSE=1
)
if not defined _PARAMS if %_HELP%==0 if %_COMMAND%==install (
    echo [91mError[0m: Missing parameter for command %_COMMAND% 1>&2
    set _EXITCODE=1
)
if %_DEBUG%==1 echo [%_BASENAME%] _COMMAND=%_COMMAND% _OPTIONS=%_OPTIONS% _PARAMS^(%_PARAMS_N%^)=%_PARAMS% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% command { options }
echo   Commands:
echo     available [-lv] ^<expr^>          list components in the component catalog
echo     info [-cL] ^<param^>              print component information ^(from file, URL or catalog^)
echo     install [-0cDhfiLnoruv] ^<param^> install specified component ^(ID or local archive^)
echo     list [-clv] ^<expr^>              list installed components
echo     rebuild-images                  rebuild native images
echo     remove [-0fxv] ^<id^>             remove component ^(ID^)
echo     update [-x][^<ver^>][^<param^>]     upgrade to the recent GraalVM version
echo   Options:
echo     -d, --debug                     show commands executed by this scriptD
echo     -f, --force                     disable ^(un-^)installation checks
echo     -h, --help                      print this help message or a command specific help message
echo     -L, --local-file                treat parameters as local filenames
echo     -o, --overwrite                 silently overwrite already existing component
echo     -r, --replace                   replace component if already installed
echo     -u, --url                       treat parameters as URLs
echo     -v, --verbose                   display progress messages
goto :eof

rem output parameter(s): _CATALOG_FILE
:catalog_file
if not exist "%_WORKING_DIR%" mkdir "%_WORKING_DIR%"
for %%f in (%_CATALOG_URL%) do set "__CATALOG_NAME=%%~nxf"
set "_CATALOG_FILE=%_WORKING_DIR%\!__CATALOG_NAME!"
if %_DEBUG%==1 ( echo [%_BASENAME%] powershell -c "Invoke-WebRequest -Uri %_CATALOG_URL% -Outfile %_CATALOG_FILE%"
) else if %_VERBOSE%==1 ( echo Downloading: Component catalog %__CATALOG_NAME% 1>&2
) else ( echo Downloading: Component catalog
)
powershell -c "$progressPreference='silentlyContinue';Invoke-WebRequest -Uri %_CATALOG_URL% -Outfile %_CATALOG_FILE%"
if not !ERRORLEVEL!==0 (
    echo.
    echo [91mError[0m: Failed to download file %__CATALOG_NAME% 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

rem gu available [-lv] <expr>
:available
if %_HELP%==1 ( call :available_help
) else ( call :available_catalog "%_PARAMS%"
)
goto :eof

rem input parameter(s): %1=component ID
rem examples: python
:available_catalog
set "__EXPR=%~1"
set __PREFIX=%_GRAALVM_VERSION%_%_OS_NAME%_%_OS_ARCH%.org.graalvm.
if defined __EXPR ( set __NAME=%__PREFIX%%__EXPR%-Bundle-Name
) else ( set __NAME=%__PREFIX%*-Bundle-Name
)
call :catalog_file
if not %_EXITCODE%==0 goto :eof

set __N=0
for /f "delims=" %%i in ('type "!_CATALOG_FILE!" ^| findstr "%__NAME%"') do (
    echo %%i
    set /a __N+=1
)
if %_DEBUG%==1 ( echo [%_BASENAME%] Found !__N! components in catalog 1>&2
) else if %_VERBOSE%==1 ( echo Found !__N! components in catalog 1>&2
)
goto :eof

:available_help
echo Usage: gu available [-lv] ^<expr^>
echo   Options:
echo     -l                ???
echo     -v, --verbose     enable verbose output
goto :eof

rem gu info [-clLprstuv] <param>
:info
set __CATALOG=0
set __LOCAL=0
set __URL=0
if defined _OPTIONS (
    if not "!_OPTIONS:c=!"=="!_OPTIONS!" set __CATALOG=1
    if not "!_OPTIONS:L=!"=="!_OPTIONS!" set __LOCAL=1
    if not "!_OPTIONS:u=!"=="!_OPTIONS!" set __URL=1
)
if %_HELP%==1 ( call :info_help
) else if %__LOCAL%==1 (
    echo Command not yet implemented
) else (
    set "__NAME=%_PARAMS%"
    call :catalog_file
    if not !_EXITCODE!==0 goto :eof

    set __N=0
    for /f "delims=" %%i in ('type "!_CATALOG_FILE!" ^| findstr "%__NAME%"') do (
        echo %%i
        set /a __N+=1
    )
)
goto :eof

:info_help
echo Usage: gu info [-clLprstuv] ^<param^>
echo   Options:
echo     -c, --catalog     treat parameters as component IDs from catalog ^(default^)
echo     -L, --local-file  treat parameters as local filenames of packaged components
echo     -v, --verbose     enable verbose output
goto :eof

rem gu install [-0cfiLnoruv] <param>
:install
set __CATALOG=0
set __FORCE=0
set __LOCAL=0
set __URL=0
if defined _OPTIONS (
    if not "!_OPTIONS:c=!"=="!_OPTIONS!" set __CATALOG=1
    if not "!_OPTIONS:f=!"=="!_OPTIONS!" set __FORCE=1
    if not "!_OPTIONS:L=!"=="!_OPTIONS!" set __LOCAL=1
    if not "!_OPTIONS:u=!"=="!_OPTIONS!" set __URL=1
)
if %_HELP%==1 ( call :install_help
) else if %__LOCAL%==1 (
    for %%f in (%_PARAMS%) do (
        set "__COMPONENT_FILE=%%f"
        if not exist "!__COMPONENT_FILE!" (
            echo [91mError[0m: Local component file not found ^(!__COMPONENT_FILE!^) 1>&2
            set _EXITCODE=1
            goto :eof
        )
        echo Install local component !__COMPONENT_FILE!
        call :install_local "!__COMPONENT_FILE!" %__FORCE%
    )
) else if %__URL%==1 (
    for %%f in (%_PARAMS%) do (
        set "__COMPONENT_URL=%%f"
        if not "!__COMPONENT_URL:~0,8!"=="https://" set "__COMPONENT_URL=https://!__COMPONENT_URL!"
        for %%f in (!__COMPONENT_URL!) do set "__COMPONENT_NAME=%%~nxf"
        set "__COMPONENT_FILE=%_WORKING_DIR%\!__COMPONENT_NAME!"
        if %_DEBUG%==1 ( echo [%_BASENAME%] powershell -c "Invoke-WebRequest -Uri !__COMPONENT_URL! -Outfile !__COMPONENT_FILE!"
        ) else if %_VERBOSE%==1 ( echo Download component !__COMPONENT_URL! 1>&2
        )
        powershell -c "$progressPreference='silentlyContinue';Invoke-WebRequest -TimeoutSec 60 -Uri !__COMPONENT_URL! -Outfile "!__COMPONENT_FILE!"
        if not !ERRORLEVEL!==0 (
            echo.
            echo [91mError[0m: Failed to download component !__COMPONENT_NAME! 1>&2
            set _EXITCODE=1
            goto :eof
        )
        echo Install remote component !__COMPONENT_NAME!
        call :install_local "!__COMPONENT_FILE!" %__FORCE%
    )
) else (
    call :catalog_file
    if not !_EXITCODE!==0 goto :eof
    for %%f in (%_PARAMS%) do (
        echo Processing component archive: Component %%f
        call :install_component "%%f" %__FORCE%
    )
)
goto :eof

:install_help
echo Usage: gu install [-0cfiLnorv] ^<param^>
echo   Options:
echo     -0                ???
echo     -c, --catalog     treat parameters as component IDs from catalog ^(default^)
echo     -f, --force       disable installation checks
echo     -i                ???
echo     -L, --local-file  treat parameters as local filenames of packaged components
echo     -n, --no-progress do not display download progress
echo     -o                silently overwrite previously installed component
echo     -r                ???
echo     -v, --verbose     enable verbose output
goto :eof

rem input parameter(s): %1=component ID, %2=force
:install_component
set "__EXPR=%~1"
set __FORCE=%~2
set __PREFIX=%_GRAALVM_VERSION%_%_OS_NAME%_%_OS_ARCH%.org.graalvm.
set __FULLNAME=%__PREFIX%%__EXPR%
set __COMPONENT_URL=
for /f "delims=^= tokens=1,*" %%i in ('type "%_CATALOG_FILE%" ^| findstr "%__FULLNAME%"') do (
    set "__NAME=%%i"
    set "__VALUE=%%j"
    if "!__NAME:~-4!"=="!__EXPR:~-4!" set __COMPONENT_URL=%%j
)
for /f "delims=" %%f in ("%__COMPONENT_URL%") do set "__COMPONENT_NAME=%%~nxf"
set __COMPONENT_FILE=%TEMP%\%__COMPONENT_NAME%
if %_DEBUG%==1 ( echo [%_BASENAME%] __COMPONENT_FILE=^%TEMP^%\%__COMPONENT_NAME% 1>&2
) else if %_VERBOSE%==1 ( echo Downloading: Component %__COMPONENT_NAME% 1>&2
) else ( echo Downloading: Component %__EXPR%
)
powershell -c "$progressPreference='silentlyContinue';Invoke-WebRequest -TimeoutSec 60 -Uri %__COMPONENT_URL% -Outfile %__COMPONENT_FILE%"
if not %ERRORLEVEL%==0 (
    echo.
    echo [91mError[0m: Failed to download component %__COMPONENT_NAME% 1>&2
    set _EXITCODE=1
    goto :eof
)
echo Install remote component !__COMPONENT_NAME!
call :install_local "!__COMPONENT_FILE!" %__FORCE%
goto :eof

rem gu list [-clv] <expression>
:list
set __CATALOG=1
set __LOCAL=0
if defined _OPTIONS (
    if not "!_OPTIONS:c=!"=="!_OPTIONS!" set __CATALOG=1
    if not "!_OPTIONS:L=!"=="!_OPTIONS!" set __LOCAL=1
)
if %_HELP%==1 ( call :list_help
) else if %__CATALOG%==1 ( call :available_catalog "%_PARAMS%"
) else ( echo Command not yet implemented
)
goto :eof

:list_help
echo Usage: gu list [-clv] ^<param^>
echo   Options:
echo     -c, --catalog     treat parameters as component IDs from catalog ^(default^)
echo     -l                ???
echo     -v, --verbose     enable verbose output
goto :eof

rem gu remove [-0fxv] <id>
:remove
if %_HELP%==1 ( call :remove_help
) else ( echo Command not yet implemented
)
goto :eof

:remove_help
echo Usage: gu remove [-0fxv] ^<param^>
echo   Options:
echo     -0                ???
echo     -f, --force       disable uninstallation checks ^(eg. non-matching versions^)
echo     -x                ???
echo     -v, --verbose     enable verbose output
goto :eof

rem gu update [-x] [<ver>] [<param>]
:update
if %_HELP%==1 ( call :update_help
) else (
    echo Command update not yet implemented
    echo ^(current GraalVM version: %_GRAALVM_VERSION%^)
)
goto :eof

:update_help
echo Usage: gu update [-x] [^<ver^>] [^<param^>]
echo   Options:
echo     -x                ???
goto :eof

rem input parameter(s): %1=relative source path, %2=absolute target path
rem GraalSqueak example:
rem   bin/graalsqueak = ../jre\languages\smalltalk\bin\graalsqueak
rem GraalPython example:
rem   bin/graalpython = ../jre/bin/graalpython
rem   jre/bin/graalpython = ../languages/python/bin/graalpython
:install_command
set __SOURCE=%~1
set __TARGET_FILE=%~2

for /f "delims=" %%f in ("%__TARGET_FILE%") do set "__PARENT_DIR=%%~dpf"
if not exist "%__PARENT_DIR%" mkdir "%__PARENT_DIR%"

if %_DEBUG%==1 ( echo [%_BASENAME%] Create file !__TARGET_FILE:%TEMP%=%%TEMP%%! 1>&2
) else if %_VERBOSE%==1 ( echo Create file !__TARGET_FILE:%TEMP%=%%TEMP%%! 1>&2
)
(
    echo @echo off
    echo set location=%%~dp0
    echo "%%location%%%__SOURCE%" %%^*
) > %__TARGET_FILE%
goto :eof

rem input parameter(s): %1=input file, %2=force
:install_local
rem ensure absolute path for input file
for %%i in (%1) do set __JAR_FILE=%%~dpnxi
set __FORCE_CREATION=%~2
if not exist "%__JAR_FILE%" (
    echo [91mError[0m: Installable component not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if not defined GRAAL_HOME (
    echo [91mError[0m: Graal installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __TMP_DIR=%_WORKING_DIR%\tmp
if not exist "%__TMP_DIR%" mkdir "%__TMP_DIR%"
pushd "%__TMP_DIR%"

if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAR_CMD% xf "%__JAR_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Extract GraalVM component into directory !__TMP_DIR:%TEMP%=%%TEMP%%! 1>&2
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
    rem convert Unix file separator used in file symlinks
    set __TARGET=!__TARGET:/=\!.cmd
    set __SOURCE=!__SOURCE:/=\!.cmd
    call :install_command "!__SOURCE!" "%__TMP_DIR%\!__TARGET!"
    if not !_EXITCODE!==0 goto install_done
)
if exist "%__TMP_DIR%\META-INF\" rmdir /s /q "%__TMP_DIR%\META-INF\" 

if %_DEBUG%==1 ( echo [%_BASENAME%] Component ready to be installed in %GRAAL_HOME% 1>&2
) else if %_VERBOSE%==1 ( echo Component ready to be installed in %GRAAL_HOME% 1>&2
)
set /p "__CONFIRM=Do you really want to add the component into directory %GRAAL_HOME%? "
if /i not "%__CONFIRM%"=="y" goto :eof

if %_DEBUG%==1 ( echo [%_BASENAME%] xcopy /s /y "%__TMP_DIR%\*" "%GRAAL_HOME%\" 1^>NUL 1>&2
) else if %_VERBOSE%==1 ( echo Install GraalVM component into directory %GRAAL_HOME% 1>&2
)
xcopy /s /y "%__TMP_DIR%\*" "%GRAAL_HOME%\" 1>NUL
if not %ERRORLEVEL%==0 (
    echo [91mError[0m: Failed to add component to directory %GRAAL_HOME% 1>&2
    set _EXITCODE=1
    goto install_done
)
:install_done
if not %_DEBUG%==1 if exist "%__TMP_DIR%" rmdir /s /q "%__TMP_DIR%"
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
endlocal
