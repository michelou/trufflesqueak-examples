# <span id="top">GraalSqueak on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://squeak.org/">Squeak</a> code examples coming from various websites and books.<br/>
  It also includes several batch scripts for experimenting with <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [GraalSqueak](https://github.com/hpi-swa/graalsqueak) on Windows:

- Installing GraalSqueak on Windows [**&#9660;**](#bottom)
- [Using **`gu.bat`** on Windows](GU.md)
- [Building GraalSqueak on Windows](BUILD.md)

[Dotty](https://github.com/michelou/dotty-examples), [GraalVM](https://github.com/michelou/graalvm-examples) and [LLVM](https://github.com/michelou/llvm-examples) are other topics we are currently investigating.

## <span id="proj_deps">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** platform:

- [Git 2.24](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.24.0.txt))
- [GraalSqueak Image 1.0](https://github.com/hpi-swa/graalsqueak/releases/tag/1.0.0-rc5)
- [GraalVM Community Edition 19.2](https://github.com/oracle/graal/releases) ([*release notes*](https://www.graalvm.org/docs/release-notes/19_2/#19201))

Optionally one may also install the following software:
- [Squeak 5.2](https://squeak.org/downloads/) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>

For instance our development environment looks as follows (*November 2019*) <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>:

<pre style="font-size:80%;">
C:\opt\graalvm-ce-19.2.1\   <i>(362 MB)</i>
C:\opt\Git-2.24.0\          <i>(271 MB)</i>
C:\opt\Squeak-5.2\          <i>(116 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [**`/opt/`**](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).

## <span id="structure">Directory structure</span>

This project is organized as follows:
<pre style="font-size:80%;">
bin\gu.bat
docs\
examples\README.md
BUILD.md
GU.md
README.md
setenv.bat
</pre>

where

- file [**`bin\gu.bat`**](bin/gu.bat) is the batch script for installing the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component on a Windows machine.
- directory [**`docs\`**](docs/) contains several [GraalSqueak](https://github.com/hpi-swa/graalsqueak) related papers/articles.
- directory [**`examples\`**](examples/) contains [Squeak](https://squeak.org/) code examples (see [**`examples\README.md`**](examples/README.md)).
- file [**`BUILD.md`**](BUILD.md) is the Markdown document presenting the generation of the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component.
- file [**`GU.md`**](GU.md) is the Markdown document presenting the usage of the [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/) tool.
- file [**`README.md`**](README.md) is the Markdown document for this page.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`K:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"](https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation) from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst) to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst K: %USERPROFILE%\workspace\graalsqueak-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## Batch commands

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`java.exe`**](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/java.html) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt (see section [**Project dependencies**](#proj_deps)).

    <pre style="font-size:80%;">
    <b>&gt; setenv help</b>
    Usage: setenv { options | subcommands }
      Options:
        -debug      show commands executed by this script
        -verbose    display progress messages
      Subcommands:
        help        display this help message
    </pre>

2. [**`bin\gu.bat`**](bin/gu.bat) - This batch command features commands to manage the [GraalVM](https://www.graalvm.org/) environment. This *temporary* solution is a stripped down implementation of Oracle's [**`gu`**](https://www.graalvm.org/docs/reference-manual/install-components/) command <sup id="anchor_03"><a href="#footnote_03">[3]</a></sup>.<br/>

   We use [**`gu.bat`**](bin/gu.bat) to add the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component (or any installable component such as [FastR](https://github.com/oracle/fastr), [GraalPython](https://github.com/graalvm/graalpython) or [TruffleRuby](https://github.com/oracle/truffleruby)) to our [GraalVM](https://www.graalvm.org/) environment. More details on the usage of this command are available in document [GU.md](GU.md).

In the next section we present usage examples of the batch files present in this project.

## <span id="usage">Usage examples</span>

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`jar.exe`**](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/jar.html) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_232, python 2.7.17, pylint 1.9.2
   mx 5.244.0, link 10.00.40219.01, git 2.24.0.windows.1

<b>&gt; where jar link</b>
C:\opt\graalvm-ce-19.2.1\bin\jar.exe
C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
</pre>

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   javac 1.8.0_232, python 2.7.17, pylint 1.9.2
   mx 5.244.0, link 10.00.40219.01, git 2.24.0.windows.1
Tool paths:
   C:\opt\graalvm-ce-19.2.1\bin\javac.exe
   C:\opt\Python-2.7.17\python.exe
   C:\opt\Python-2.7.17\Scripts\pylint.exe
   K:\mx\mx.cmd
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
   C:\opt\Git-2.24.0\usr\bin\link.exe
   C:\opt\Git-2.24.0\bin\git.exe
   C:\opt\Git-2.24.0\mingw64\bin\git.exe
</pre>

#### `gu.bat install`

Command [**`gu.bat install -h`**](bin/gu.bat) displays the help message for command **`install`**.

<pre style="font-size:80%;">
<b>&gt; gu install -h</b>
Usage: gu install [-0cfiLnoruv] {&lt;param&gt;}
  Options:
    -0, --dry-run        Dry run. Do not change any files.
    -c, --catalog        Treat parameters as component IDs from catalog. This is the default.
    -f, --force          Disable installation checks.
    -i, --fail-existing  Fail if the to be installed component already exists.
    -L, --local-file     Treat parameters as local filenames of packaged components.
    -n, --no-progress    Do not display download progress.
    -o, --overwrite      Silently overwrite previously installed component.
    -r, --replace        Replace different files.
    -u, --url            Treat parameters as URLs
    -v, --verbose        Enable verbose output.
</pre>

Command [**`gu.bat install`**](bin/gu.bat) can add [GraalVM](https://www.graalvm.org/) installable components in three different ways, namely:
<ul>
<li>from a catalog <i>(default, option </i><b><code>-c</code></b><i>)</i></li>
<li>from a local component archive <i>(option </i><b><code>-L</code></b><i>)</i></li>
<li>from a remote component archive <i>(option </i><b><code>-u</code></b><i>)</i></li>
</ul>

We present below the installation from a *local* [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component archive; further usage examples are available in document [GU.md](GU.md).

Let's first download [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component archive from the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) repository:

<pre style="font-size:80%;">
<b>&gt; curl -sL -o graalsqueak-component.jar https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc5/graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar</b>
</pre>

Command [**`gu.bat install -L graalsqueak-component.jar`**](bin/gu.bat) adds the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component to our [GraalVM](https://www.graalvm.org/) environment.

<pre style="font-size:80%;">
<b>&gt; echo %GRAAL_HOME%</b>
C:\opt\graalvm-ce-19.2.1
&nbsp;
<b>&gt; gu install -L graalsqueak-component.jar</b>
Extract GraalVM component into directory %TEMP%\graal-updater\tmp
Create file %TEMP%\graal-updater\tmp\bin\graalsqueak.cmd
Create file %TEMP%\graal-updater\tmp\jre\bin\graalsqueak.cmd
Component ready for installation into directory C:\opt\graalvm-ce-19.2.1
Do you really want to add the component to directory C:\opt\graalvm-ce-19.2.1 (y/*)? y
Install GraalVM component into directory C:\opt\graalvm-ce-19.2.1
</pre>


## <span id="execution">Squeak execution</span>

The [GraalVM](https://www.graalvm.org/) installation directory looks as follows after adding the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component:

<pre style="font-size:80%;">
<b>&gt; where /r c:\opt\graalvm-ce-19.2.1 *squeak*</b>
c:\opt\graalvm-ce-19.2.1\LICENSE_GRAALSQUEAK.txt
c:\opt\graalvm-ce-19.2.1\bin\graalsqueak.cmd
c:\opt\graalvm-ce-19.2.1\jre\bin\graalsqueak.cmd
c:\opt\graalvm-ce-19.2.1\jre\languages\smalltalk\graalsqueak.jar
c:\opt\graalvm-ce-19.2.1\jre\languages\smalltalk\graalsqueak-shared.jar
c:\opt\graalvm-ce-19.2.1\jre\languages\smalltalk\bin\graalsqueak
c:\opt\graalvm-ce-19.2.1\jre\languages\smalltalk\bin\graalsqueak.cmd
c:\opt\graalvm-ce-19.2.1\jre\lib\graalvm\graalsqueak-launcher.jar
</pre>

> **:mag_right:** In the above output both command files **`bin\graalsqueak.cmd`** and **`jre\bin\graalsqueak.cmd`** simply forward the call to command file **`jre\languages\smalltalk\bin\graalsqueak.cmd`** (on Unix systems two symbolic links are created instead).
> <pre style="font-size:80%;">
> <b>&gt; type c:\opt\graalvm-ce-19.2.1\bin\graalsqueak.cmd</b>
> @echo off
> set location=%~dp0
> "%location%..\jre\bin\graalsqueak.cmd" %*
> &nbsp;
> <b>&gt; type c:\opt\graalvm-ce-19.2.1\jre\bin\graalsqueak.cmd</b>
> @echo off
> set location=%~dp0
> "%location%..\languages\smalltalk\bin\graalsqueak.cmd" %*
> </pre>
> Command file **`jre\languages\smalltalk\bin\graalsqueak.cmd`** itself is copied from template file [**`template.graalsqueak.cmd`**](https://github.com/hpi-swa/graalsqueak/blob/dev/scripts/template.graalsqueak.cmd) during the generation of the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component.

#### `graalsqueak.cmd`

Command **`graalsqueak.cmd --help`** prints the usage message:

<pre style="font-size:80%;">
<b>&gt; where graalsqueak</b>
C:\opt\graalvm-ce-19.2.1\bin\graalsqueak.cmd
&nbsp;
<b>&gt; graalsqueak.cmd --help</b>
usage: graalsqueak <image> [optional arguments]

optional arguments:
  -c CODE, --code CODE
                        Smalltalk code to be executed in headless mode

Runtime options:
  --polyglot                           Run with all other guest languages accessible.
  --native                             Run using the native launcher with limited Java access (default).
  --jvm                                Run on the Java Virtual Machine with Java access.
  --vm.[option]                        Pass options to the host VM. To see available options, use '--help:vm'.
  --help                               Print this help message.
  --help:languages                     Print options for all installed languages.
  --help:tools                         Print options for all installed tools.
  --help:vm                            Print options for the host VM.
  --help:expert                        Print additional options for experts.
  --help:internal                      Print internal options for debugging language implementations and tools.
  --version:graalvm                    Print GraalVM version information and exit.
  --show-version:graalvm               Print GraalVM version information and continue execution.
  --log.file=<String>                          Redirect guest languages logging into a given file.
  --log.[logger].level=<String>                Set language log level to OFF, SEVERE, WARNING, INFO, CONFIG, FINE, FINER, FINEST or ALL.

See http://www.graalvm.org for more information.
</pre>

Command **`graalsqueak --version:graalvm`** prints the version of the installed languages and tools: 

<pre style="font-size:80%;">
<b>&gt; graalsqueak.cmd --version:graalvm</b>
GraalVM Polyglot Engine Version 19.2.1
GraalVM Home c:\opt\graalvm-ce-19.2.1
  Installed Languages:
    JavaScript       version 19.2.1
    Squeak/Smalltalk version 1.0.0-rc5
  Installed Tools:
    CPU Sampler             version 0.4.0
    CPU Tracer              version 0.3.0
    Heap Allocation Monitor version 0.1.0
    Chrome Inspector        version 0.1
    Memory Tracer           version 0.2
</pre>

Command **`graalsqueak`** (with no argument) opens a dialog window for selecting a Squeak image before starting the Squeak IDE.

> **:mag_right:** We have the choice between two Squeak images:
> - [GraalSqueak project](https://github.com/hpi-swa/graalsqueak) : [**`GraalSqueakImage-<version>.image`**](https://github.com/hpi-swa/graalsqueak/releases/tag/1.0.0-rc5).
> - [Squeak project](https://squeak.org/) : [**`Squeak<version>-64bit.image`**](https://squeak.org/downloads/).<br/>
> &nbsp;

Command **`graalsqueak GraalSqueak.image`** starts the Squeak IDE and loads the provided Squeak image.

<pre style="font-size:80%;">
<b>&gt; curl -sL -o GraalSqueakImage.zip https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc5/GraalSqueakImage-1.0.0-rc5.zip</b>
&nbsp;
<b>&gt; unzip -qo GraalSqueakImage.zip</b>
 &nbsp;
<b>&gt; graalsqueak.cmd GraalSqueak-1.0.0-rc5.image</b>
</pre>

> **:mag_right:** The contents of downloaded archive file <b><code>GraalSqueakImage.zip</code></b> looks as follows:
> <pre style="font-size:80%;">
> <b>&gt; unzip -l GraalSqueakImage.zip</b>
> Archive:  GraalSqueakImage.zip
>   Length      Date    Time    Name
> ---------  ---------- -----   ----
>  14510453  2019-10-20 13:41   GraalSqueak-1.0.0-rc5.changes
>  44365496  2019-10-20 13:41   GraalSqueak-1.0.0-rc5.image
>  35184983  2017-02-06 09:21   SqueakV50.sources
> ---------                     -------
>  94060932                     3 files
> </pre>

## Footnotes

<a name="footnote_01">[1]</a> ***Squeak image*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
A Squeak image is required to run/test the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> installable component. Concretely we can either install the full <a href="https://squeak.org/downloads/">Squeak distribution</a> (32 MB) or we can just download the <a href="https://squeak.org/downloads/">Squeak image</a> (18 MB).
</p>

<a name="footnote_02">[2]</a> ***Downloads*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#proj_deps">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://github.com/hpi-swa/graalsqueak/releases/">graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar</a>  <i>(  5 MB)</i>
<a href="https://github.com/oracle/graal/releases">graalvm-ce-windows-amd64-19.2.1.zip</a>                     <i>(171 MB)</i>
<a href="https://squeak.org/downloads/">Squeak5.2-18229-64bit-201810190412-Windows.zip</a>          <i>( 30 MB)</i>
</pre>

<a name="footnote_03">[3]</a> ***GraalVM Updater*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
Command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu</code></b></a> is not yet supported on Microsoft Windows, so we currently run our own (stripped down) command <a href="bin/gu.bat"><b><code>bin\gu.bat</code></b></a> to add the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> component (e.g. archive file <b><code>graalsqueak-component.jar</code></b>) to our <a href="https://www.graalvm.org/">GraalVM</a> environment (e.g. <b><code>c:\opt\graalvm-ce-19.2.1\</code></b>).
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/November 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
