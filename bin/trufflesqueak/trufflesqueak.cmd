@echo off
setlocal enabledelayedexpansion

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if "%VERBOSE_GRAALVM_LAUNCHERS%"=="true" echo on

@rem echo "%_JAVA_CMD%" %_JVM_OPTS% -cp "%_CPATH%" %_LAUNCHER_MAIN% %_LAUNCHER_ARGS% 1>&2
call "%_JAVA_CMD%" %_JVM_OPTS% -cp "%_CPATH%" %_LAUNCHER_MAIN% %_LAUNCHER_ARGS%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto end
)
goto end

@rem #########################################################################
@rem ## Subroutine

:env
set _BASENAME=%~n0
for %%f in ("%~dp0\.") do set "_SMALLTALK_DIR=%%~dpf"
for %%f in ("%_SMALLTALK_DIR%\..\..") do set "_ROOT_DIR=%%~dpf"

set "_JAVA_CMD=%_ROOT_DIR%bin\java.exe"
set _JVM_OPTS=-Xss64M -XX:OldSize=256M -XX:NewSize=1G -XX:MetaspaceSize=32M
set _JVM_OPTS=%_JVM_OPTS% -Dorg.graalvm.launcher.shell=true
set _JVM_OPTS=%_JVM_OPTS% -Dorg.graalvm.launcher.executablename=%_BASENAME%

set "_CPATH=%_ROOT_DIR%jre\lib\graalvm\launcher-common.jar;%_ROOT_DIR%jre\lib\graalvm\trufflesqueak-launcher.jar;%_SMALLTALK_DIR%\trufflesqueak-shared.jar"
set _LAUNCHER_MAIN=de.hpi.swa.trufflesqueak.launcher.TruffleSqueakLauncher
goto :eof

:args
set _JVM_ARGS=
set _LAUNCHER_ARGS=
set _NATIVE=0

set __CODE=0
set "__ARGS=%*"
set "__ARGS=!__ARGS:"=$$!"
for /f "usebackq delims=" %%i in (`powershell -C "'!__ARGS!' -replace '=','##' -replace ';','@@'"`) do (
    set __ARGS=%%i
)
set "__ARGS=!__ARGS:$$="!"
@rem Caution ! __ARGS now contains the following 2 character substitutions:
@rem '=' -> '##' and ';' -> '@@'
for %%i in (%__ARGS%) do (
    set "__ARG=%%i"
    if "!__ARG:~0,2!"=="--" (
        @rem option
        if "!__ARG!"=="--code" (
            set __CODE=1
        ) else if "!__ARG:~0,6!"=="--jvm." (
            echo '--jvm.*' options are deprecated, use '--vm.*' instead. 1>&2
            call :vm_arg "!__ARG:~6!"
            if not !_EXITCODE!==0 goto args_done
        ) else if "!__ARG!"=="--native" (
            set _NATIVE=1
        ) else if "!__ARG:~0,5!"=="--vm." (
            call :vm_arg "!__ARG:~5!"
            if not !_EXITCODE!==0 goto args_done
        ) else (
            if "!__ARG:##=!"=="!__ARG!" ( set "__ARG1=!__ARG!"
            ) else ( set __ARG1=!__ARG:##=="!"
            )
            set _LAUNCHER_ARGS=!_LAUNCHER_ARGS! !__ARG1!
        )
    ) else if "!__ARG:~0,1!"=="-" (
        @rem short option
        if "!__ARG!"=="-c" (
            set __CODE=1
        ) else (
            echo Error: Unknown option !__ARG! 1>&2
            set _EXITCODE=1
            goto args_done
        )
    ) else if !__CODE!==1 (
        set _LAUNCHER_ARGS=!_LAUNCHER_ARGS! --code !__ARG!
        set __CODE=0
    ) else (
        @rem argument
        set _LAUNCHER_ARGS=!_LAUNCHER_ARGS! "!__ARG!"
    )
)
:args_done
if defined _JVM_ARGS set _JVM_OPTS=%_JVM_OPTS% %_JVM_ARGS%
goto :eof

@rem output paramters: _CPATH, _JVM_ARGS
:vm_arg
set "__VM_ARG=%~1"
@ rem Character substitutions: '=' -> '##' and ';' -> '@@'
if "%__VM_ARG:~0,4%"=="cp##" (
    set "__CP_ARG=%__VM_ARG:~4%"
    set "_CPATH=%_CPATH%;!__CP_ARG:@@=;!"
) else if "%__VM_ARG:~0,12%"=="classpath##" (
    set "__CP_ARG=%__VM_ARG:~12%"
    set "_CPATH=%_CPATH%;!__CP_ARG:@@=;!"
) else if "%__VM_ARG:~0,1%"=="D" (
    if "!__VM_ARG:##=!"=="!__VM_ARG!" ( set "__JVM_ARG1=-!__VM_ARG!"
    ) else ( set __JVM_ARG1=-!__VM_ARG:##=="!"
    )
    set "_JVM_ARGS=%_JVM_ARGS% !__JVM_ARG1!"
) else (
    echo Error: Illegal VM argument %__VM_ARG:##==% 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof
    
@rem #########################################################################
@rem ## Cleanups

:end
exit /b %_EXITCODE%
endlocal
