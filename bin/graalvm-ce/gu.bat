@echo off
setlocal enabledelayedexpansion

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

call :%_COMMAND%
goto end

rem ##########################################################################
rem ## Subroutines

rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
rem                    _WORKING_DIR, _PS1_FILE, PS1_VERBOSE,
rem                    _JAR_CMD, _GRAALVM_VERSION, _CATALOG_URL, _OS_ARCH, _OS_NAME
:env
rem ANSI colors in standard Windows 10 shell
rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

set _WORKING_DIR=%TEMP%\graal-updater
if not exist "%_WORKING_DIR%" mkdir "%_WORKING_DIR%"

rem see https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
rem NB. cURL is a standard tool only from Windows 10 build 17063 and later.
set _PS1_FILE=%_WORKING_DIR%\webrequest.ps1
(
    echo Param^(
    echo    [Parameter^(Mandatory=$True,Position=1^)]
    echo    [string]$Uri,
    echo    [Parameter(Mandatory=$True^)]
    echo    [string]$OutFile
    echo ^)
    echo Add-Type ^@^"
    echo using System.Net;
    echo using System.Security.Cryptography.X509Certificates;
    echo public class TrustAllCertsPolicy : ICertificatePolicy {
    echo     public bool CheckValidationResult^(
    echo         ServicePoint srvPoint, X509Certificate certificate,
    echo         WebRequest request, int certificateProblem^) {
    echo         return true;
    echo     }
    echo }
    echo ^"^@
    echo $Verbose=$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent
    echo $AllProtocols=[System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    echo [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    echo [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    echo $progressPreference='silentlyContinue'
    echo Invoke-WebRequest -TimeoutSec 60 -Uri $Uri -Outfile $OutFile
) > %_PS1_FILE%
set _PS1_VERBOSE[0]=
set _PS1_VERBOSE[1]=-Verbose

if defined GRAAL_HOME (
    set _GRAAL_HOME=%GRAAL_HOME%
) else (
    set __PATH=C:\opt
    for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    if not defined _GRAAL_HOME (
        set "__PATH=%ProgramFiles%"
        for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    )
)
if not exist "%_GRAAL_HOME%\release" (
    echo %_ERROR_LABEL% GraalVM installation directory is invalid ^(%_GRAAL_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem component_catalog=https://www.graalvm.org/component-catalog/graal-updater-component-catalog.properties
set _CATALOG_URL=
set _GRAALVM_VERSION=
set _OS_ARCH=
set _OS_NAME=
for /f "delims=^= tokens=1,*" %%f in (%_GRAAL_HOME%\release) do (
    if /i "%%f"=="component_catalog" ( SET "_CATALOG_URL=%%g"
    ) else if /i "%%f"=="GRAALVM_VERSION" ( set "_GRAALVM_VERSION=%%g"
    ) else if /i "%%f"=="OS_ARCH" ( set "_OS_ARCH=%%g"
    ) else if /i "%%f"=="OS_NAME" ( set "_OS_NAME=%%g"
    )
)
set _JAR_CMD=
for /f %%f in ('where jar.exe 2^>NUL') do set "_JAR_CMD=%%f"
if not defined _JAR_CMD set "_JAR_CMD=%_GRAAL_HOME%\bin\jar.exe"
if not exist "%_JAR_CMD%" (
    echo %_ERROR_LABEL% Executable jar.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
rem TODO remove (for testing only)
set _OS_NAME=linux
if %_DEBUG%==1 echo %_DEBUG_LABEL% _CATALOG_URL=%_CATALOG_URL% _GRAALVM_VERSION=%_GRAALVM_VERSION% _OS_ARCH=%_OS_ARCH% _OS_NAME=%_OS_NAME%
goto :eof

rem input parameters: %1=valid charset, %2=input charset
rem output parameter: _IS_VALID
:is_valid
set __VALID_SET=%~1
set __INPUT_SET=%~2
if %_DEBUG%==1 echo %_DEBUG_LABEL% __VALID_SET=%__VALID_SET% __INPUT_SET=%__INPUT_SET%

set _IS_VALID=1
:is_valid_loop
if defined __INPUT_SET (
    set "__ELEM=!__INPUT_SET:~0,1!"
    rem batch string substitution cannot distinguish between 'A' and 'a'
    rem e.g. set XXX=Abc & echo %XXX:a=1% prints '1bc' instead of 'Abc'
    set __INX=-1
    for /f "usebackq" %%i in (`powershell -c "'!__VALID_SET!'.indexOf('!__ELEM!')"`) do set __INX=%%i
    if !__INX! lss 0 (
        set _IS_VALID=
        goto is_valid_done
    )
    set "__INPUT_SET=!__INPUT_SET:~1!"
    goto is_valid_loop
)
:is_valid_done
if %_DEBUG%==1 echo %_DEBUG_LABEL% _IS_VALID=%_IS_VALID%
goto :eof

rem input parameter: %1=long option
rem output parameter: _SHORT_OPTION (-9 if long option is unknown)
:short_option
set __LONG_OPTION=%~1

rem see https://github.com/oracle/graal/blob/master/vm/src/org.graalvm.component.installer/src/org/graalvm/component/installer/Commands.java
set _SHORT_OPTION=-9
if %__LONG_OPTION%==all-versions ( set _SHORT_OPTION=-a
) else if %__LONG_OPTION%==auto-yes ( set _SHORT_OPTION=-A
) else if %__LONG_OPTION%==debug ( set _SHORT_OPTION=-d
) else if %__LONG_OPTION%==dry-run ( set _SHORT_OPTION=-0
) else if %__LONG_OPTION%==help ( set _SHORT_OPTION=-h
) else if %__LONG_OPTION%==fail-existing ( set _SHORT_OPTION=-i
) else if %__LONG_OPTION%==force ( set _SHORT_OPTION=-f
) else if %__LONG_OPTION%==ignore ( set _SHORT_OPTION=-x
) else if %__LONG_OPTION%==list-files ( set _SHORT_OPTION=-l
) else if %__LONG_OPTION%==local-file ( set _SHORT_OPTION=-L
) else if %__LONG_OPTION%==no-progress ( set _SHORT_OPTION=-n
) else if %__LONG_OPTION%==no-tables ( set _SHORT_OPTION=-t
) else if %__LONG_OPTION%==non-interactive ( set _SHORT_OPTION=-N
) else if %__LONG_OPTION%==only-validate ( set _SHORT_OPTION=y
) else if %__LONG_OPTION%==overwrite ( set _SHORT_OPTION=-o
) else if %__LONG_OPTION%==paths ( set _SHORT_OPTION=-p
) else if %__LONG_OPTION%==replace ( set _SHORT_OPTION=-r
) else if %__LONG_OPTION%==url ( set _SHORT_OPTION=-u
) else if %__LONG_OPTION%==validate-before ( set _SHORT_OPTION=-Y
) else if %__LONG_OPTION%==verbose ( set _SHORT_OPTION=-v
)
goto :eof

rem output parameters: _COMMAND, _COMMAND_OPTS, _OPTIONS, _PARAMS
rem see https://docs.oracle.com/en/graalvm/enterprise/19/guide/reference/graalvm-updater.html
:args
set _COMMAND=help
set _COMMAND_OPTS=dhv
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
    set _COMMAND_OPTS=!_COMMAND_OPTS!cLprstu
) else if "%__ARG%"=="available" (
    set _COMMAND=available
    set _COMMAND_OPTS=!_COMMAND_OPTS!l
) else if "%__ARG%"=="install" (
    set _COMMAND=install
    set _COMMAND_OPTS=!_COMMAND_OPTS!0AcfiLnoru rem 0cDhfiLnorvyxY
) else if "%__ARG%"=="list" (
    set _COMMAND=list
    set _COMMAND_OPTS=!_COMMAND_OPTS!cl
) else if "%__ARG%"=="rebuild-images" (
    set _COMMAND=rebuild
    rem set _COMMAND_OPTS=dhv
) else if "%__ARG%"=="remove" (
    set _COMMAND=remove
    set _COMMAND_OPTS=!_COMMAND_OPTS!0fvx
) else if "%__ARG%"=="update" (
    set _COMMAND=update
    set _COMMAND_OPTS=!_COMMAND_OPTS!x
) else if "%__ARG%"=="-h" ( set _HELP=1
) else if "%__ARG%"=="--help" ( set _HELP=1
) else (
    echo %_ERROR_LABEL% Unknown command %__ARG% 1>&2
    set _EXITCODE=1
    goto args_next
)
shift
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "!__ARG:~0,2!"=="--" (
    rem turn long option into short one
    call :short_option "!__ARG:~2!"
    set "__ARG=!_SHORT_OPTION!"
)
if "!__ARG:~0,1!"=="-" (
    rem check validity of short option list
    call :is_valid "%_COMMAND_OPTS%" "!__ARG:~1!"
    if defined _IS_VALID ( set "_OPTIONS=!_OPTIONS!!__ARG:~1!"
    ) else (
        echo %_ERROR_LABEL% Invalid option^(s^) !__ARG! for command %_COMMAND% 1>&2
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
    set _PARAMS=!_PARAMS! "%__PARAM%"
    goto args_next
)
:args_done
rem global options
if defined _OPTIONS (
    if not "!_OPTIONS:d=!"=="!_OPTIONS!" set _DEBUG=1
    if not "!_OPTIONS:h=!"=="!_OPTIONS!" set _HELP=1
    if not "!_OPTIONS:v=!"=="!_OPTIONS!" set _VERBOSE=1
)
if not defined _PARAMS if %_HELP%==0 if %_COMMAND%==install (
    echo %_ERROR_LABEL% Missing parameter for command %_COMMAND% 1>&2
    set _EXITCODE=1
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _COMMAND=%_COMMAND% _OPTIONS=%_OPTIONS% _PARAMS^(%_PARAMS_N%^)=%_PARAMS% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% ^<command^> {^<option^>} {^<param^>}
echo.
echo   Commands:
echo     available [-l] ^<expr^>            List components in the component catalog.
echo     info [-cLu] ^<param^>              Print component information ^(from file, URL or catalog^).
echo     install [-0AcfiLnoru] {^<param^>}  Install specified components ^(from file, URL or catalog^).
echo     list [-cl] ^<expr^>                List installed components.
echo     rebuild-images                   Rebuild native images.
echo     remove [-0fx] ^<id^>               Remove component ^(ID^).
echo     update [-x][^<ver^>][^<param^>]      Upgrade to the recent GraalVM version.
echo.
echo   Options supported by all commands:
echo     -d, --debug                      Show commands executed by this script.
echo     -h, --help                       Display this help message or a command specific help message.
echo     -v, --verbose                    Display progress messages.
echo.
echo   Options:
echo     -0, --dry-run                    Dry run. Do not change any files.
echo     -A, --auto-yes                   Say YES or ACCEPT to a question.
echo     -c, --catalog                    Treat parameters as component IDs from catalog. This is the default.
echo     -f, --force                      Disable ^(un-^)installation checks.
echo     -i, --fail-existing              Fail if the to be installed component already exists.
echo     -L, --local-file                 Treat parameters as local filenames.
echo     -l, --list-files                 List files.
echo     -n, --no-progress                Do not display download progress.
echo     -o, --overwrite                  Silently overwrite already existing component.
echo     -p, --paths                      Display full paths in lists.
echo     -r, --replace                    Replace different files.
echo     -u, --url                        Treat parameters as URLs.
echo     -x, --ignore                     Do not terminate uninstall on failed file deletions.
goto :eof

rem output parameter: _CATALOG_FILE
:catalog_file
for %%f in (%_CATALOG_URL%) do set "__CATALOG_NAME=%%~nxf"
set "_CATALOG_FILE=%_WORKING_DIR%\%__CATALOG_NAME%"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -c "& '%_PS1_FILE%' -Uri '%_CATALOG_URL%' -Outfile '%_CATALOG_FILE%'" 1>&2
) else if %_VERBOSE%==1 ( echo Downloading: Component catalog %__CATALOG_NAME% 1>&2
) else ( echo Downloading: Component catalog from www.graalvm.org
)
powershell -c "& '%_PS1_FILE%' -Uri '%_CATALOG_URL%' -OutFile '%_CATALOG_FILE%' !_PS1_VERBOSE[%_VERBOSE%]!"
if not !ERRORLEVEL!==0 (
    echo.
    echo %_ERROR_LABEL% Failed to download file %__CATALOG_NAME% 1>&2
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

rem input parameter(s): %1=component IDs (0..n)
rem examples: python
:available_catalog
set "__EXPR=%~1"
set __LIST_FILES=0
if defined _OPTIONS (
    if not "!_OPTIONS:l=!"=="!_OPTIONS!" set __LIST_FILES=1
)
call :catalog_file
if not %_EXITCODE%==0 goto :eof

set __PREFIX=%_GRAALVM_VERSION%_%_OS_NAME%_%_OS_ARCH%.org.graalvm.
set __N=0
if %__LIST_FILES%==0 (
    if defined __EXPR (
        set __NAMES=
        for %%f in (%__EXPR%) do (
            set "__NAMES=!__NAMES! %__PREFIX%%%f-Bundle-Name="
        )
    ) else (
        set "__NAMES=%__PREFIX%*-Bundle-Name="
    )
    for /f "delims=" %%i in ('type "!_CATALOG_FILE!" ^| findstr "!__NAMES!"') do (
        echo %%i
        set /a __N+=1
    )
) else (
    if defined __EXPR (
        set __NAMES=
        for %%f in (%__EXPR%) do (
            set "__NAMES=!__NAMES! %__PREFIX%%%f="
        )
    ) else (
        set "__NAMES=%__PREFIX%[^-]*="
    )
    for /f "delims=^= tokens=1,*" %%i in ('type "!_CATALOG_FILE!" ^| findstr "!__NAMES!"') do (
        echo %%j
        set /a __N+=1
    )
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% !__N! component^(s^) found in catalog 1>&2
) else if %_VERBOSE%==1 ( echo !__N! component^(s^) found in catalog 1>&2
)
goto :eof

:available_help
echo Usage: %_BASENAME% available [-dhlv] ^<expr^>
echo List components in the component catalog.
echo.
echo   Options:
echo     -d, --debug       Show commands executed by this script.
echo     -h, --help        Display this help message.
echo     -l                List files.
echo     -v, --verbose     Enable verbose output.
goto :eof

rem gu info [-clLprstuv] <param>
:info
set __CATALOG=0
set __LOCAL=0
set __URL=0
set __ILLEGAL=0
if defined _OPTIONS (
    if not "!_OPTIONS:c=!"=="!_OPTIONS!" set __CATALOG=1
    if not "!_OPTIONS:L=!"=="!_OPTIONS!" set __LOCAL=1
    if not "!_OPTIONS:u=!"=="!_OPTIONS!" set __URL=1
    set /a __ILLEGAL=__CATALOG*__LOCAL + __CATALOG*__URL + __LOCAL*__URL
)
if %_HELP%==1 ( call :info_help
) else if not %__ILLEGAL%==0 (
    echo %_ERROR_LABEL% --catalog^(-c^), --local-file^(-L^) and --url^(-u^) options are mutual exclusive 1>&2
    set _EXITCODE=1
    goto :eof
) else if %__LOCAL%==1 (
    call :info_local
) else if %__URL%==1 (
    call :info_url
) else (
    call :catalog_file
    if not !_EXITCODE!==0 goto :eof

    set __NAME_PREFIX=org\.graalvm\.
    if not defined _PARAMS ( set "__NAMES=!__NAME_PREFIX!.*"
    ) else (
        set __NAMES=
        for %%i in (%_PARAMS%) do (
            set "__NAMES=!__NAMES! !__NAME_PREFIX!%%i"
        )
    )
    set __N=0
    if %_DEBUG%==1 echo %_DEBUG_LABEL% type "!_CATALOG_FILE!" ^| findstr "!__NAMES!" 1>&2
    for /f "delims=" %%i in ('type "!_CATALOG_FILE!" ^| findstr "!__NAMES!"') do (
        echo %%i
        set /a __N+=1
    )
)
goto :eof

:info_help
echo Usage: %_BASENAME% info [-cdhlLprstuv] {^<param^>}
echo Print component information from file, URL or catalog.
echo.
echo   Options:
echo     -c, --catalog     Treat parameters as component IDs from catalog. This is the default.
echo     -d, --debug       Show commands executed by this script.
echo     -h, --help        Display this help message.
echo     -L, --local-file  Treat parameters as local filenames of packaged components.
echo     -u, --url         Treat parameters as URLs.
echo     -v, --verbose     Enable verbose output.
goto :eof

:info_local
set __DIR_LIST=
if not defined _PARAMS (
    for /f %%d in ('dir /ad /b "%_GRAAL_HOME%\jre\languages\*" 2^>NUL') do (
        set __DIR_LIST=!__DIR_LIST! "%_GRAAL_HOME%\jre\languages\%%d"
    )
) else (
    for %%i in (%_PARAMS%) do (
        if not exist "%_GRAAL_HOME%\jre\languages\%%i\" (
            echo %_ERROR_LABEL% No directory found for parameter %%i 1>&2
            set _EXITCODE=1
        ) else (
            set __DIR_LIST=!__DIR_LIST! "%_GRAAL_HOME%\jre\languages\%%~i"
        )
    )
    if not !_EXITCODE!==0 goto :eof
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% __DIR_LIST=!__DIR_LIST! 1>&2
for %%d in (!__DIR_LIST!) do (
    set "__LANGUAGE_DIR=%_WORKING_DIR%\languages\%%~nd"
    if exist "!__LANGUAGE_DIR!" rmdir /s /q "!__LANGUAGE_DIR!"
    mkdir "!__LANGUAGE_DIR!"
    if exist "%_GRAAL_HOME%\jre\languages\%%~nd\release" (
        xcopy /y "%_GRAAL_HOME%\jre\languages\%%~nd\release" "!__LANGUAGE_DIR!\" 1>NUL
    )
    for /f %%f in ('where /r "%_GRAAL_HOME%\jre\languages\%%~nd" *.jar 2^>NUL') do (
        set __JAR_FILE=%%f
        pushd "!__LANGUAGE_DIR!"
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_JAR_CMD% xf "!__JAR_FILE!" META-INF/truffle/language 1>&2
        ) else if %_VERBOSE%==1 ( echo Extract meta data from archive !__JAR_FILE:%_GRAAL_HOME%\=! 1>&2
        )
        %_JAR_CMD% xf "!__JAR_FILE!" META-INF/truffle/language
        if not !ERRORLEVEL!==0 (
            popd
            echo %_ERROR_LABEL% Failed to extract file from archive "!__JAR_FILE:%_GRAAL_HOME%=!" 1>&2
            set _EXITCODE=1
            goto :eof
        )
        popd
    )
    set "__INFO_FILE=!__LANGUAGE_DIR!\info.txt"
    if exist "!__INFO_FILE!" del "!__INFO_FILE!" 1>NUL
    set __COMPONENT_ID=
    if exist "!__LANGUAGE_DIR!\META-INF\truffle\language" (
        for /f "delims=^= tokens=1,*" %%i in (!__LANGUAGE_DIR!\META-INF\truffle\language) do (
           set __NAME=%%i
           set __VALUE=%%j
           if "!__NAME:~0,10!"=="language1." (
                set "__NAME=!__NAME:language1.=!"
                if "!__NAME!"=="id" ( set "__COMPONENT_ID=!__VALUE!"
                ) else if defined __VALUE ( echo    !__NAME!=!__VALUE!>> "!__INFO_FILE!"
                )
           )
        )
    )
    if exist "!__LANGUAGE_DIR!\release" (
        for /f "delims=^= tokens=1,*" %%i in (!__LANGUAGE_DIR!\release) do (
           if "%%i"=="OS_NAME" ( echo    %%i=%%j>> "!__INFO_FILE!"
           ) else if "%%i"=="OS_ARCH" ( echo    %%i=%%j>> "!__INFO_FILE!"
           ) else if "%%i"=="GRAALVM_VERSION" ( echo    %%i=%%j>> "!__INFO_FILE!"
           )
        )
    )
    if defined __COMPONENT_ID (
        echo Component: !__COMPONENT_ID!
        type "!__INFO_FILE!"
    )
    del "!__INFO_FILE!" 1>NUL
)
goto :eof

:info_url
echo Command info --url not yet implemented
echo ^(current GraalVM version: %_GRAALVM_VERSION%^)
goto :eof

rem gu install [-0cfiLnoruv] <param>
:install
set __AUTO_YES=0
set __CATALOG=0
set __DRY_RUN=0
set __FORCE=0
set __LOCAL=0
set __URL=0
set __ILLEGAL=0
if defined _OPTIONS (
    if not "!_OPTIONS:0=!"=="!_OPTIONS!" set __DRY_RUN=1
    if not "!_OPTIONS:A=!"=="!_OPTIONS!" set __AUTO_YES=1
    if not "!_OPTIONS:c=!"=="!_OPTIONS!" set __CATALOG=1
    if not "!_OPTIONS:f=!"=="!_OPTIONS!" set __FORCE=1
    if not "!_OPTIONS:L=!"=="!_OPTIONS!" set __LOCAL=1
    if not "!_OPTIONS:u=!"=="!_OPTIONS!" set __URL=1
    set /a __ILLEGAL=__CATALOG*__LOCAL + __CATALOG*__URL + __LOCAL*__URL
)
if %_HELP%==1 ( call :install_help
) else if not %__ILLEGAL%==0 (
    echo %_ERROR_LABEL% --catalog^(-c^), --local-file^(-L^) and --url^(-u^) options are mutual exclusive 1>&2
    set _EXITCODE=1
    goto :eof
) else if %__LOCAL%==1 (
    for %%f in (%_PARAMS%) do (
        set "__COMPONENT_FILE=%%f"
        if not exist "!__COMPONENT_FILE!" (
            echo %_ERROR_LABEL% Local component file not found ^(!__COMPONENT_FILE!^) 1>&2
            set _EXITCODE=1
            goto :eof
        )
        echo Install local component !__COMPONENT_FILE!
        call :install_local "!__COMPONENT_FILE!" %__AUTO_YES% %__DRY_RUN%
    )
) else if %__URL%==1 (
    for %%f in (%_PARAMS%) do (
        set "__COMPONENT_URL=%%f"
        if not "!__COMPONENT_URL:~0,8!"=="https://" set "__COMPONENT_URL=https://!__COMPONENT_URL!"
        for %%f in (!__COMPONENT_URL!) do set "__COMPONENT_NAME=%%~nxf"
        set "__COMPONENT_FILE=%_WORKING_DIR%\!__COMPONENT_NAME!"
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -c "& '%_PS1_FILE%' -Uri '!__COMPONENT_URL!' -Outfile '!__COMPONENT_FILE!'" 1>&2
        ) else if %_VERBOSE%==1 ( echo Download component !__COMPONENT_URL! 1>&2
        )
        powershell -c "& '%_PS1_FILE%' -Uri '!__COMPONENT_URL!' -OutFile '!__COMPONENT_FILE!' !_PS1_VERBOSE[%_VERBOSE%]!"
        if not !ERRORLEVEL!==0 (
            echo.
            echo %_ERROR_LABEL% Failed to download component !__COMPONENT_NAME! 1>&2
            set _EXITCODE=1
            goto :eof
        )
        echo Installing new component: !__COMPONENT_NAME!
        call :install_local "!__COMPONENT_FILE!" %__AUTO_YES% %__DRY_RUN%
    )
) else (
    call :catalog_file
    if not !_EXITCODE!==0 goto :eof
    for %%f in (%_PARAMS%) do (
        echo Processing component archive: Component %%f
        call :install_component "%%f" %__AUTO_YES% %__DRY_RUN%
    )
)
goto :eof

:install_help
echo Usage: %_BASENAME% install [-0cdfhiLnoruv] {^<param^>}
echo Install specified components from file, URL or catalog.
echo.
echo   Options:
echo     -0, --dry-run        Dry run. Do not change any files.
echo     -c, --catalog        Treat parameters as component IDs from catalog. This is the default.
echo     -d, --debug          Show commands executed by this script.
echo     -f, --force          Disable installation checks.
echo     -h, --help           Display this help message.
echo     -i, --fail-existing  Fail if the to be installed component already exists.
echo     -L, --local-file     Treat parameters as local filenames of packaged components.
echo     -n, --no-progress    Do not display download progress.
echo     -o, --overwrite      Silently overwrite previously installed component.
echo     -r, --replace        Replace different files.
echo     -u, --url            Treat parameters as URLs.
echo     -v, --verbose        Enable verbose output.
goto :eof

rem input parameter(s): %1=component ID, %2=auto-yes %3=dry-run
:install_component
set "__EXPR=%~1"
set __AUTO_YES=%~2
set __DRY_RUN=%~3
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
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -c "& '%_PS1_FILE%' -Uri '%__COMPONENT_URL%' -OutFile '%__COMPONENT_FILE%'" 1>&2
) else if %_VERBOSE%==1 ( echo Downloading: Component %__COMPONENT_NAME% 1>&2
) else ( echo Downloading: Component %__EXPR%
)
powershell -c "& '%_PS1_FILE%' -Uri '%__COMPONENT_URL%' -OutFile '%__COMPONENT_FILE%' !_PS1_VERBOSE[%_VERBOSE%]!"
if not %ERRORLEVEL%==0 (
    echo.
    echo %_ERROR_LABEL% Failed to download component %__COMPONENT_NAME% 1>&2
    set _EXITCODE=1
    goto :eof
)
echo Install remote component !__COMPONENT_NAME!
call :install_local "!__COMPONENT_FILE!" %__AUTO_YES% %__DRY_RUN%
goto :eof

rem gu list [-clv] <expression>
:list
set __CATALOG=0
set __LOCAL=1
set __ILLEGAL=0
if defined _OPTIONS (
    if not "!_OPTIONS:c=!"=="!_OPTIONS!" set __CATALOG=1
    if not "!_OPTIONS:L=!"=="!_OPTIONS!" set __LOCAL=1
    set /a __ILLEGAL=__CATALOG*__LOCAL
)
if %_HELP%==1 ( call :list_help
) else if not %__ILLEGAL%==0 (
    echo %_ERROR_LABEL% --catalog^(-c^) and --local-file^(-L^) options are mutual exclusive 1>&2
    set _EXITCODE=1
    goto :eof
) else if %__CATALOG%==1 ( call :available_catalog "%_PARAMS%"
) else ( call :list_releases
)
goto :eof

:list_help
echo Usage: %_BASENAME% list [-cdhlv] ^<param^>
echo List installed components.
echo.
echo   Options:
echo     -c, --catalog     Treat parameters as component IDs from catalog. This is the default.
echo     -d, --debug       Show commands executed by this script.
echo     -h, --help        Display this help message.
echo     -l, --list-files  List files.
echo     -v, --verbose     Enable verbose output.
goto :eof

:list_releases
set "__TMP_FILE=%_WORKING_DIR%\list.tmp"
set "__VERBOSE_FILE=%_WORKING_DIR%\list_verbose.tmp"
if exist "%__TMP_FILE%" del "%__TMP_FILE%"
if exist "%__VERBOSE_FILE%" del "%__VERBOSE_FILE%"

set __N=0
for /f %%f in ('where /r "%_GRAAL_HOME%\jre\languages" release') do (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% %%f 1>&2
    set __COMPONENT_ID=
    set __COMMITTER=
    set __REVISION=
    for /f "delims=^= tokens=1,*" %%i in (%%f) do (
        if "%%i"=="COMMIT_INFO" ( rem JSON string
            set "__JSON_STRING=%%j"
            set "__JSON_STRING=!__JSON_STRING:<=^<!"
            set "__JSON_STRING=!__JSON_STRING:>=^>!"
            set "__JSON_STRING=!__JSON_STRING:"=\"!"
            if %_DEBUG%==1 echo %_DEBUG_LABEL% COMMIT_INFO=!__JSON_STRING!
            for /f "usebackq delims=" %%v in (`powershell -c "ConvertFrom-Json '!__JSON_STRING!' | Get-Member -MemberType Properties | ForEach-Object {$_.Name}"`) do (
                set __COMPONENT_ID=%%v
            )
            for /f "usebackq delims=" %%v in (`powershell -c "$data=ConvertFrom-Json '!__JSON_STRING!' | Select-Object -Expand *; $data.'commit.committer'"`) do (
                echo    committer=%%v>> %__VERBOSE_FILE%
            )
            for /f "usebackq delims=" %%v in (`powershell -c "$data=ConvertFrom-Json '!__JSON_STRING!' | Select-Object -Expand *; $data.'commit.rev'"`) do (
                echo    revision=%%v>> %__VERBOSE_FILE%
            )
        ) else if "%%i"=="component_catalog" (
            echo    %%i=%%j>> %__VERBOSE_FILE%
        ) else (
            echo    %%i=%%j>> %__TMP_FILE%
        )
    )
    echo component !__COMPONENT_ID!
    if exist "%__TMP_FILE%" (
        type "%__TMP_FILE%"
        del /q "%__TMP_FILE%"
        set /a __N=+1
    )
    if exist "%__VERBOSE_FILE%" (
        if %_VERBOSE%==1 type "%__VERBOSE_FILE%"
        del /q "%__VERBOSE_FILE%"
    )
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %__N% component^(s^) found in %_GRAAL_HOME% 1>&2
) else if %_VERBOSE%==1 ( echo %__N% component^(s^) found in %_GRAAL_HOME% 1>&2
)
goto :eof

:rebuild
if %_HELP%==1 ( call :rebuild_help
) else (
    echo Command rebuild-images not yet implemented
    echo ^(current GraalVM version: %_GRAALVM_VERSION%^)
)
goto :eof

:rebuild_help
echo Usage: %_BASENAME% rebuild-images [-dhv]
echo Rebuild native images.
echo.
echo   Options:
echo     -d, --debug       Show commands executed by this script.
echo     -h, --help        Display this help message.
echo     -v, --verbose     Enable verbose output.
goto :eof

rem gu remove [-0fxv] <id>
:remove
if %_HELP%==1 ( call :remove_help
) else (
    echo Command remove not yet implemented
    echo ^(current GraalVM version: %_GRAALVM_VERSION%^)
)
goto :eof

:remove_help
echo Usage: %_BASENAME% remove [-0dfhxv] ^<param^>
echo Remove component ^(ID^).
echo.
echo   Options:
echo     -0, --dry-run     Dry run. Do not change any files.
echo     -d, --debug       Show commands executed by this script.
echo     -f, --force       Disable uninstallation checks ^(eg. non-matching versions^).
echo     -h, --help        Display this help message.
echo     -x, --ignore      Do not terminate uninstall on failed file deletions.
echo     -v, --verbose     Enable verbose output.
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
echo Usage: %_BASENAME% update [-dhvx] [^<ver^>] [^<param^>]
echo Upgrade to the recent GraalVM version.
echo.
echo   Options:
echo     -d, --debug       Show commands executed by this script.
echo     -h, --help        Display this help message.
echo     -v, --verbose     Enable verbose output.
echo     -x, --ignore      Do not terminate uninstall on failed file deletions.
goto :eof

rem input parameter(s): %1=relative source path, %2=absolute target path
rem GraalSqueak symlinks file:
rem   bin/graalsqueak = ../jre/bin/graalsqueak
rem   jre/bin/graalsqueak = ../languages/smalltalk/bin/graalsqueak
rem GraalPython symlinks file:
rem   bin/graalpython = ../jre/bin/graalpython
rem   jre/bin/graalpython = ../languages/python/bin/graalpython
:install_command
set __SOURCE=%~1
set __TARGET_FILE=%~2

for /f "delims=" %%f in ("%__TARGET_FILE%") do set "__PARENT_DIR=%%~dpf"
if not exist "%__PARENT_DIR%" mkdir "%__PARENT_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Create file !__TARGET_FILE:%TEMP%=%%TEMP%%! 1>&2
) else if %_VERBOSE%==1 ( echo Create file !__TARGET_FILE:%TEMP%=%%TEMP%%! 1>&2
)
(
    echo @echo off
    echo set location=%%~dp0
    echo "%%location%%%__SOURCE%" %%^*
) > %__TARGET_FILE%
goto :eof

rem input parameter(s): %1=input file, %2=auto-yes %3=dry-run
:install_local
rem ensure absolute path for input file
for %%i in (%1) do set __JAR_FILE=%%~dpnxi
if not exist "%__JAR_FILE%" (
    echo %_ERROR_LABEL% Installable component not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __AUTO_YES=%~2
set __DRY_RUN=%~3
if not defined __DRY_RUN (
    echo Internal error: Missing 3rd argument in subroutine :install_local 1>&2
    set _EXITCODE=1
    goto :eof
) else if %__DRY_RUN%==1 ( echo Dry-run execution of command 'install'
)
if not defined GRAAL_HOME (
    echo %_ERROR_LABEL% Graal installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __TMP_DIR=%_WORKING_DIR%\tmp
if not exist "%__TMP_DIR%" mkdir "%__TMP_DIR%"
pushd "%__TMP_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_JAR_CMD% xf "%__JAR_FILE%" 1>&2
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

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Component ready to be installed in %_GRAAL_HOME% ^(auto-yes=%__AUTO_YES%^)1>&2
) else if %_VERBOSE%==1 ( echo Component ready to be installed in %_GRAAL_HOME% ^(auto-yes=%__AUTO_YES%^) 1>&2
)
if %__AUTO_YES%==0 (
    set /p "__CONFIRM=Do you really want to add the component into directory %_GRAAL_HOME% (y/*)? "
    if /i not "!__CONFIRM!"=="y" goto install_done
)
if %__DRY_RUN%==1 (
    for /f %%f in ('where /r "%__TMP_DIR%" *') do (
        set __FILE=%%f
        echo Copy file !__FILE:%__TMP_DIR%\=! to %_GRAAL_HOME%\
    )
    goto install_done
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% xcopy /s /y "%__TMP_DIR%\*" "%_GRAAL_HOME%\" 1^>NUL 1>&2
) else if %_VERBOSE%==1 ( echo Install GraalVM component into directory %_GRAAL_HOME% 1>&2
)
xcopy /s /y "%__TMP_DIR%\*" "%_GRAAL_HOME%\" 1>NUL
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to add component to directory %_GRAAL_HOME% 1>&2
    set _EXITCODE=1
    goto install_done
)
:install_done
if not %_DEBUG%==1 if exist "%__TMP_DIR%" rmdir /s /q "%__TMP_DIR%"
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
endlocal
