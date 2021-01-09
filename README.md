# <span id="top">TruffleSqueak on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img style="border:0;" src="https://squeak.org/static/img/balloon.svg" width="120" alt="Squeak logo"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://squeak.org/" rel="external">Squeak</a> code examples coming from various websites and books.<br/>
  It also includes several <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting">batch files</a> for experimenting with <a href="https://github.com/hpi-swa/trufflesqueak" rel="external">TruffleSqueak</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [TruffleSqueak] on Windows:

- Installing [TruffleSqueak] on Windows [**&#9660;**](#bottom)
- ***(deprecated)*** [Using **`gu.bat`** on Windows](GU.md) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>
- [Building TruffleSqueak on Windows](BUILD.md)

[Dotty][dotty_examples], [GraalVM][graalvm_examples], [Haskell][haskell_examples], [Kotlin][kotlin_examples], [LLVM][llvm_examples] and [Node.js][nodejs_examples] are other trending topics we are currently monitoring.

## <span id="proj_deps">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** platform:

- [Git 2.30][git_downloads] ([*release notes*][git_relnotes])
- [TruffleSqueak Image 20.2][trufflesqueak_image]
- [GraalVM Community Edition 20.3 LTS][graalvm_downloads] ([*release notes*][graalvm_relnotes])

Optionally one may also install the following software:
- [Squeak 5.3][squeak_downloads] <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>

For instance our development environment looks as follows (*January 2021*) <sup id="anchor_03"><a href="#footnote_03">[3]</a></sup>:

<pre style="font-size:80%;">
C:\opt\graalvm-ce-java8-20.3.0\   <i>(695 MB)</i>
C:\opt\Git-2.30.0\                <i>(276 MB)</i>
C:\opt\Squeak-5.3\                <i>(130 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [**`/opt/`**][linux_opt] directory on Unix).

## <span id="structure">Directory structure</span>

This project is organized as follows:
<pre style="font-size:80%;">
<a href="bin/gu.bat">bin\gu.bat</a> <i>(deprecated)</i><sup id="anchor_01a"><a href="#footnote_01">[1]</a></sup>
docs\
<a href="examples/README.md">examples\README.md</a>
<a href="BUILD.md">BUILD.md</a>
<a href="GU.md">GU.md</a>      <i>(deprecated)</i>
README.md
<a href="setenv.bat">setenv.bat</a>
</pre>

where

- ***(deprecated)***<sup id="anchor_01b"><a href="#footnote_01">[1]</a></sup> file [**`bin\gu.bat`**](bin/gu.bat) is the batch script for *installing* the [TruffleSqueak] component on a Windows machine.
- directory [**`docs\`**](docs/) contains [TruffleSqueak] related papers/articles.
- directory [**`examples\`**](examples/) contains [Squeak] code examples (see [**`examples\README.md`**](examples/README.md)).
- file [**`BUILD.md`**](BUILD.md) is the Markdown document presenting the generation of the [TruffleSqueak] component.
- ***(deprecated)***<sup id="anchor_01c"><a href="#footnote_01">[1]</a></sup> file [**`GU.md`**](GU.md) is the [Markdown][github_markdown] document presenting the usage of the [GraalVM Updater][gu_refman] tool.
- file [**`README.md`**](README.md) is the Markdown document for this page.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`T:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"][windows_limitation] from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**][windows_subst] to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst T: %USERPROFILE%\workspace\trufflesqueak-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## <span id="commands">Batch commands</span>

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`java.exe`**][java_exe] and [**`git.exe`**][git_cli] directly available from the command prompt (see section [**Project dependencies**](#proj_deps)).

    <pre style="font-size:80%;">
    <b>&gt; setenv help</b>
    Usage: setenv { &lt;option&gt; | &lt;subcommand&gt; }
    &nbsp;
      Options:
        -debug      show commands executed by this script
        -travis     start Git bash shell instead of Windows command prompt
        -verbose    display progress messages
    &nbsp;
      Subcommands:
        help        display this help message
    </pre>

2. [**`bin\gu.bat`**](bin/gu.bat) ***(deprecated)*** - This batch command features commands to manage the [GraalVM] environment. This *temporary* solution is a stripped down implementation of Oracle's [**`gu`**][gu_refman] command.<br/>

In the next section we present usage examples of the batch files present in this project.

## <span id="usage">Usage examples</span>

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`jar.exe`**][jar_exe] and [**`git.exe`**][git_cli] directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   python 2.7.18, pylint 1.9.5
   git 2.30.0.windows.1, bash 4.4.23(1)-release

<b>&gt; where git link</b>
C:\opt\Git-2.30.0\bin\git.exe
C:\opt\Git-2.30.0\mingw64\bin\git.exe
C:\opt\Git-2.30.0\usr\bin\link.exe
</pre>

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   python 2.7.18, pylint 1.9.5
   git 2.30.0.windows.1, bash 4.4.23(1)-release
Tool paths:
   C:\opt\Python-2.7.18\python.exe
   C:\opt\Python-2.7.18\Scripts\pylint.exe
   C:\opt\Git-2.30.0\bin\git.exe
   C:\opt\Git-2.30.0\mingw64\bin\git.exe
   C:\opt\Git-2.30.0\bin\bash.exe
Environment variables:
   MSVC_HOME="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC"
   MSVS_HOME="C:\Program Files (x86)\Microsoft Visual Studio\2017"
</pre>

#### `gu.bat install` ***(deprecated)***

> **&#9755;** Starting with *version 20.0* command `gu.cmd` is part of the [GraalVM] distribution; Windows users should use `gu.cmd` instead of `gu.bat`.

Command [**`gu.bat install -h`**](bin/gu.bat) displays the help message for command **`install`**.

<pre style="font-size:80%;">
<b>&gt; gu install -h</b>
Usage: gu install [-0cdfhiLnoruv] {&lt;param&gt;}
Install specified components from file, URL or catalog.
&nbsp;
  Options:
    -0, --dry-run        Dry run. Do not change any files.
    -c, --catalog        Treat parameters as component IDs from catalog. This is the default.
    -d, --debug          Show commands executed by this script.
    -f, --force          Disable installation checks.
    -h, --help           Display this help message.
    -i, --fail-existing  Fail if the to be installed component already exists.
    -L, --local-file     Treat parameters as local filenames of packaged components.
    -n, --no-progress    Do not display download progress.
    -o, --overwrite      Silently overwrite previously installed component.
    -r, --replace        Replace different files.
    -u, --url            Treat parameters as URLs
    -v, --verbose        Enable verbose output.
</pre>

Command [**`gu.bat install`**](bin/gu.bat) can add [GraalVM] installable components in three different ways, namely:
<ul>
<li>from a catalog <i>(default, option </i><b><code>-c</code></b><i>)</i></li>
<li>from a local component archive <i>(option </i><b><code>-L</code></b><i>)</i></li>
<li>from a remote component archive <i>(option </i><b><code>-u</code></b><i>)</i></li>
</ul>

We present below the installation from a *local* [TruffleSqueak] component archive; further usage examples are available in document [GU.md](GU.md).

Let's first download [TruffleSqueak] component archive from the [TruffleSqueak] repository:

<pre style="font-size:80%;">
<b>&gt; <a href="https://curl.se/docs/manpage.html">curl</a> -sL -o trufflesqueak-installable.jar https://github.com/hpi-swa/trufflesqueak/releases/download/20.2.0/trufflesqueak-installable-java8-windows-amd64-20.2.0.jar</b>
</pre>

Command [**`gu.bat install -L trufflesqueak-component.jar`**](bin/gu.bat) adds the [TruffleSqueak] component to our [GraalVM] environment.

<pre style="font-size:80%;">
<b>&gt; echo %GRAAL_HOME%</b>
C:\opt\graalvm-ce-java8-20.3.0
&nbsp;
<b>&gt; gu install -L trufflesqueak-installable.jar</b>
Install local component trufflesqueak-installable.jar
Do you really want to add the component to directory C:\opt\graalvm-ce-java8-20.3.0 (y/*)? y
Install GraalVM component into directory C:\opt\graalvm-ce-java8-20.3.0
</pre>

The [GraalVM] installation directory looks as follows after adding the [TruffleSqueak] component:

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where">where</a> /r c:\opt\graalvm-ce-java8-20.3.0 *squeak*</b>
c:\opt\graalvm-ce-java8-20.3.0\bin\trufflesqueak.cmd
c:\opt\graalvm-ce-java8-20.3.0\jre\bin\trufflesqueak.cmd
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\LICENSE_TRUFFLESQUEAK.txt
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\README_TRUFFLESQUEAK.md
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\trufflesqueak-shared.jar
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\trufflesqueak-shared.src.zip
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\trufflesqueak.jar
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\trufflesqueak.src.zip
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\bin\trufflesqueak.cmd
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\lib\SqueakFFIPrims.dll
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\resources\SqueakV50.sources
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\resources\TruffleSqueak-20.2.0.changes
c:\opt\graalvm-ce-java8-20.3.0\jre\languages\smalltalk\resources\TruffleSqueak-20.2.0.image
c:\opt\graalvm-ce-java8-20.3.0\jre\lib\graalvm\trufflesqueak-launcher.jar
c:\opt\graalvm-ce-java8-20.3.0\jre\lib\graalvm\trufflesqueak-launcher.src.zip
</pre>

> **:mag_right:** In the above output both command files **`bin\trufflesqueak.cmd`** and **`jre\bin\trufflesqueak.cmd`** simply forward the call to command file **`jre\languages\smalltalk\bin\trufflesqueak.cmd`** (on Unix systems two symbolic links are created instead).
> <pre style="font-size:80%;">
> <b>&gt; type c:\opt\graalvm-ce-java8-20.3.0\bin\trufflesqueak.cmd</b>
> @echo off
> &nbsp;
> call :getScriptLocation location
> "%location%..\jre\bin\trufflesqueak.cmd" %*
> goto :eof
> &nbsp;
> :: If this script is in `%PATH%` and called quoted without a full path (e.g., `"js"`), `%~dp0` is expanded to `cwd`
> :: rather than the path to the script.
> :: This does not happen if `%~dp0` is accessed in a subroutine.
> :getScriptLocation variableName
>     set "%~1=%~dp0"
>     exit /b 0
> &nbsp;
> <b>&gt; type c:\opt\graalvm-ce-java8-20.1.0\jre\bin\trufflesqueak.cmd</b>
> @echo off
> &nbsp;
> call :getScriptLocation location
> "%location%..\languages\smalltalk\bin\trufflesqueak.cmd" %*
> goto :eof
> ...
> </pre>
> Command file **`jre\languages\smalltalk\bin\trufflesqueak.cmd`** itself is copied from template file [**`template.trufflesqueak.cmd`**][trufflesqueak_cmd] during the generation of the [TruffleSqueak] component.


## <span id="execution">Squeak execution</span>

Command **`trufflesqueak.cmd --help`** prints the usage message:

<pre style="font-size:80%;">
<b>&gt; where trufflesqueak</b>
C:\opt\graalvm-ce-java8-20.3.0\bin\trufflesqueak.cmd
&nbsp;
<b>&gt; trufflesqueak.cmd --help</b>
Usage: trufflesqueak [options] <image file> [image arguments]

Basic options:
  -c "&lt;code&gt;", --code "&lt;code&gt;"          Smalltalk code to be executed in headless mode
  --headless                            Run in headless mode
  --enable-transcript-forwarding        Forward stdio to Smalltalk transcript

Runtime options:
  --polyglot                                   Run with all other guest languages accessible.
  --jvm                                        Run on the Java Virtual Machine with Java access (default).
  --vm.[option]                                Pass options to the host VM. To see available options, use '--help:vm'.
  --help                                       Print this help message.
  --help:languages                             Print options for all installed languages.
  --help:tools                                 Print options for all installed tools.
  --help:vm                                    Print options for the host VM.
  --help:expert                                Print additional options for experts.
  --help:internal                              Print internal options for debugging language implementations and tools.
  --version:graalvm                            Print GraalVM version information and exit.
  --show-version:graalvm                       Print GraalVM version information and continue execution.
  --log.file=&lt;String&gt;                          Redirect guest languages logging into a given file.
  --log.[logger].level=&lt;String&gt;                Set language log level to OFF, SEVERE, WARNING, INFO, CONFIG, FINE, FINER, FINEST or ALL.

See https://www.graalvm.org for more information.
</pre>

Command **`trufflesqueak --version:graalvm`** prints the version of the installed languages and tools: 

<pre style="font-size:80%;">
<b>&gt; %GRAAL_HOME%\bin\trufflesqueak.cmd --version:graalvm</b>
GraalVM CE JVM Polyglot Engine Version 20.3.0
Java Version 1.8.0_272
Java VM Version 25.272-b10-jvmci-20.3-b06
GraalVM Home c:\opt\graalvm-ce-java8-20.3.0
  Installed Languages:
    JavaScript       version 20.3.0
    Squeak/Smalltalk version 20.2.0
  Installed Tools:
    Agent Script            version 0.7
    Code Coverage           version 0.1.0
    CPU Sampler             version 0.4.0
    CPU Tracer              version 0.3.0
    Debug Protocol Server   version 0.1
    Heap Allocation Monitor version 0.1.0
    Insight                 version 0.7
    Chrome Inspector        version 0.1
    Language Server         version 0.1
    Memory Tracer           version 0.2
</pre>

Command **`trufflesqueak`** (with no argument) opens a dialog window for selecting a Squeak image before starting the Squeak IDE.

> **:mag_right:** We have the choice between two Squeak images:
> - [TruffleSqueak project][trufflesqueak] : [**`TruffleSqueakImage-<version>.image`**][trufflesqueak_image].
> - [Squeak project][squeak] : [**`Squeak<version>-64bit.image`**][squeak_downloads].<br/>
> &nbsp;

Command **`trufflesqueak TruffleSqueak.image`** starts the Squeak IDE and loads the provided Squeak image.

<pre style="font-size:80%;">
<b>&gt; curl -sL -o TruffleSqueakImage-20.2.0.zip https://github.com/hpi-swa/trufflesqueak/releases/download/20.2.0/TruffleSqueakImage-20.2.0.zip</b>
&nbsp;
<b>&gt; <a href="https://linux.die.net/man/1/unzip">unzip</a> -qo TruffleSqueakImage-20.2.0.zip</b>
 &nbsp;
<b>&gt; trufflesqueak.cmd TruffleSqueak-20.2.0.image</b>
</pre>

> **:mag_right:** The contents of downloaded archive file <b><code>TruffleSqueakImage.zip</code></b> looks as follows:
> <pre style="font-size:80%;">
> <b>&gt; unzip -l TruffleSqueakImage-20.2.0.zip</b>
> Archive:  TruffleSqueakImage.zip
> Archive:  TruffleSqueakImage-20.2.0.zip
>   Length      Date    Time    Name
> ---------  ---------- -----   ----
>  35184983  2017-02-06 09:21   SqueakV50.sources
>  21832626  2020-11-13 15:14   TruffleSqueak-20.2.0.changes
>  57083632  2020-11-13 15:14   TruffleSqueak-20.2.0.image
> ---------                     -------
> 114101241                     3 files
> </pre>

Code examples are presented in document [examples\README.md](examples/README.md).

## <span id="footnotes">Footnotes</span>

<b name="footnote_01">[1]</b> **`gu.bat`** ***deprecation*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
Starting with version 20.0 command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu.cmd</code></b></a> is part of the <a href="https://www.graalvm.org/">GraalVM</a> distribution; Windows users should use <b><code>gu.cmd</code></b> instead of <b><code>gu.bat</code></b>.
</p>
<p style="margin:0 0 1em 20px;">
   We wrote <a href="bin/gu.bat"><code><b>gu.bat</code></b></a> to add the <a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> component (or any installable component such as <a href="https://github.com/oracle/fastr">FastR</a>, <a href="https://github.com/graalvm/graalpython">GraalPython</a> or <a href="https://github.com/oracle/truffleruby">TruffleRuby</a> to our <a href="https://www.graalvm.org/">GraalVM</a> environment. More details on the usage of this command are available in document <a href="GU.md"><code>GU.md</code></a>.
</p>

<b name="footnote_02">[2]</b> ***Squeak image*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
A Squeak image is required to run/test the <a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> installable component. Concretely we can either install the full <a href="https://squeak.org/downloads/">Squeak distribution</a> (32 MB) or we can just download the <a href="https://squeak.org/downloads/">Squeak image</a> (18 MB).
</p>

<b name="footnote_03">[3]</b> ***Downloads*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#proj_deps">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://github.com/hpi-swa/trufflesqueak/releases/tag/20.2.0">trufflesqueak-installable-java8-windows-amd64-20.2.0.jar</a>  <i>(135 MB)</i>
<a href="https://github.com/graalvm/graalvm-ce-builds/releases">graalvm-ce-java8-windows-amd64-20.2.0.zip</a>       <i>(154 MB)</i>
<a href="https://git-scm.com/download/win">PortableGit-2.30.0-64-bit.7z.exe</a>                <i>( 41 MB)</i>
<a href="http://files.squeak.org/5.3/">Squeak5.3-19448-64bit-202003021730-Windows.zip</a>  <i>( 33 MB)</i>
</pre>

<!--
<b name="footnote_04">[4]</b> ***GraalVM Updater*** [↩](#anchor_04)

<p style="margin:0 0 1em 20px;">
Command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu</code></b></a> is not yet supported on Microsoft Windows, so we currently run our own (stripped down) command <a href="bin/gu.bat"><b><code>bin\gu.bat</code></b></a> to add the <a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> component (e.g. archive file <b><code>trufflesqueak-component.jar</code></b>) to our <a href="https://www.graalvm.org/">GraalVM</a> environment (e.g. <b><code>c:\opt\graalvm-ce-java8-20.1.0\</code></b>).
</p>
-->

***

*[mics](https://lampwww.epfl.ch/~michelou/)/January 2021* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- hrefs -->

[dotty_examples]: https://github.com/michelou/dotty-examples
[fastr]: https://github.com/oracle/fastr
[git_cli]: https://git-scm.com/docs/git
[git_downloads]: https://git-scm.com/download/win
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.30.0.txt
[github_markdown]: https://github.github.com/gfm/
[graalpython]: https://github.com/graalvm/graalpython
[graalvm]: https://www.graalvm.org/
[graalvm_downloads]: https://github.com/graalvm/graalvm-ce-builds/releases
[graalvm_examples]: https://github.com/michelou/graalvm-examples
[graalvm_relnotes]: https://www.graalvm.org/docs/release-notes/20_3/
[gu_refman]: https://www.graalvm.org/reference-manual/graalvm-updater/
[haskell_examples]: https://github.com/michelou/haskell-examples
[jar_exe]: https://docs.oracle.com/javase/7/docs/technotes/tools/windows/jar.html
[java_exe]: https://docs.oracle.com/javase/7/docs/technotes/tools/windows/java.html
[kotlin_examples]: https://github.com/michelou/kotlin-examples
[linux_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[llvm_examples]: https://github.com/michelou/llvm-examples
[nodejs_examples]: https://github.com/michelou/nodejs-examples
[squeak]: https://squeak.org/
[squeak_downloads]: https://squeak.org/downloads/
[truffleruby]: https://github.com/oracle/truffleruby
[trufflesqueak]: https://github.com/hpi-swa/trufflesqueak
[trufflesqueak_cmd]: https://github.com/hpi-swa/trufflesqueak/blob/dev/scripts/template.trufflesqueak.cmd
[trufflesqueak_image]: https://github.com/hpi-swa/trufflesqueak/releases/tag/20.2.0
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
