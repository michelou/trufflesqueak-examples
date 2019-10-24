# <span id="top">GraalSqueak on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://squeak.org/">Squeak</a> examples coming from various websites and books.<br/>
  It also includes several batch scripts for experimenting with <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [GraalSqueak](https://github.com/hpi-swa/graalsqueak) on Windows:

- Installing GraalSqueak on Windows [**&#9660;**](#bottom)
- [Building GraalSqueak on Windows](BUILD.md)

## <span id="section_01">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** plaform:

- [Git 2.23](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.23.0.txt))
- [GraalVM Community Edition 19.2](https://github.com/oracle/graal/releases) ([*release notes*](https://www.graalvm.org/docs/release-notes/19_2/#19201))
- [GraalSqueak Image 1.0](https://github.com/hpi-swa/graalsqueak/releases/tag/1.0.0-rc4)

Optionally one may also install the following software:
- [Squeak 5.2](https://squeak.org/downloads/) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>

For instance our development environment looks as follows (*October 2019*) <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>:

<pre style="font-size:80%;">
C:\opt\graalvm-ce-19.2.1\                             <i>(362 MB)</i>
C:\opt\Git-2.23.0\                                    <i>(271 MB)</i>
C:\opt\Squeak-5.2\                                    <i>(116 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).

We further recommand using an advanced console emulator such as [ComEmu](https://conemu.github.io/) (or [Cmdr](http://cmder.net/)) which features [Unicode support](https://conemu.github.io/en/UnicodeSupport.html).

## <span id="structure">Directory structure</span>

This project is organized as follows:
<pre style="font-size:80%;">
bin\gu.bat
docs\
BUILD.md
README.md
setenv.bat
</pre>

where

- file [**`bin\gu.bat`**](bin/gu.bat) is the batch script for installing the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component on a Windows machine.
- directory [**`docs\`**](docs/) contains several GraalSqueak related papers/articles.
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

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`java.exe`**](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/java.html) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt (see section [**Project dependencies**](#section_01)).

    <pre style="font-size:80%;">
    <b>&gt; setenv help</b>
    Usage: setenv { options | subcommands }
      Options:
        -debug      show commands executed by this script
        -verbose    display progress messages
      Subcommands:
        help        display this help message
    </pre>

2. [**`bin\gu.bat`**](bin/gu.bat) - This batch command features several commands to manage a GraalVM installation directory. This temporary solution is a stripped down version of the official [**`gu`**](https://www.graalvm.org/docs/reference-manual/install-components/) command <sup id="anchor_03"><a href="#footnote_03">[3]</a></sup>.<br/>
    For instance we use [**`gu.bat`**](bin/gu.bat) to add the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component (or any other component such as [GraalPython](https://github.com/graalvm/graalpython)) to our GraalVM installation directory.

    <pre style="font-size:80%;">
    <b>&gt;where gu</b>
    K:\bin\gu.bat
    &nbsp;
    <b>&gt; gu -h</b>
    Usage: gu command { options } { params }
      Commands:
        available [-lv] &lt;expr&gt;         list components in the component catalog
        info [-cL] &lt;param&gt;             print component information (from file, URL or catalog)
        install [-0cfiLnorv] &lt;param&gt;   install specified component (ID or local archive)
        list [-clv] &lt;expr&gt;             list installed components
        rebuild-images                 rebuild native images
        remove [-0fxv] &lt;id&gt;            remove component (ID)
        update [-x][&lt;ver&gt;][&lt;param&gt;]    upgrade to the recent GraalVM version
      Options:
        -d, --debug                    show commands executed by this scriptD
        -f, --force                    disable (un-)installation checks
        -h, --help                     print this help message or a command specific help message
        -L, --local-file               treat parameters as local filenames
        -o, --overwrite                silently overwrite already existing component
        -r, --replace                  replace component if already installed
        -u, --url                      treat parameters as URLs
        -v, --verbose                  display progress messages</pre>

    Command [**`gu.bat install -h`**](bin/gu.bat) displays the help message for command **`install`** (and so on for the other **`gu`** commands).

    <pre style="font-size:80%;">
    <b>&gt; gu install -h</b>
    Usage: gu install [-0cfiLnorv] <param>
      Options:
        -0                ???
        -c, --catalog     treat parameters as component IDs from catalog (default)
        -f, --force       disable installation checks
        -i                ???
        -L, --local-file  treat parameters as local filenames of packaged components
        -n, --no-progress do not display download progress
        -o, --overwrite   silently overwrite previously installed component
        -r, --replace     ???
        -v, --verbose     enable verbose output</pre>

   Command [**`gu.bat`**](bin/gu.bat) relies on variable <b><code>GRAAL_HOME</code></b> to know the location of the GraalVM installation directory.

## Usage examples

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`python.exe`**](https://docs.python.org/2/using/cmdline.html), [**`mx.cmd`**](https://github.com/graalvm/mx) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_232, python 2.7.16, pylint 2.7.16,
   mx 5.241.0 git 2.23.0.windows.1

<b>&gt; where jar</b>
C:\opt\graalvm-ce-19.2.1\bin\jar.exe
</pre>

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   javac 1.8.0_232, python 2.7.16, pylint 2.7.16,
   mx 5.241.0 git 2.23.0.windows.1
Tool paths:
   C:\opt\graalvm-ce-19.2.1\bin\javac.exe
   C:\opt\Python-2.7.16\python.exe
   C:\opt\Python-2.7.16\Scripts\pylint.exe
   K:\mx\mx.cmd
   C:\opt\Git-2.23.0\bin\git.exe
   C:\opt\Git-2.23.0\mingw64\bin\git.exe
</pre>

#### `gu.bat install`

Command [**`gu.bat install`**](bin/gu.bat) can install GraalVM components in three different ways, namely:
<ul>
<li>from a catalog <i>(default, option </i><b><code>-c</code></b><i>)</i></li>
<li>from a local component archive <i>(option </i><b><code>-L</code></b><i>)</i></li>
<li>from a remote component archive</li>
</ul>

*Installation from a **catalog***:

Command [**`gu.bat -v install python`**](bin/gu.bat) adds the GraalPython component to the GraalVM installation directory

   <pre style="font-size:80%;">
   <b>&gt; gu install -v python</b>
   Downloading: Component catalog graal-updater-component-catalog.properties
   Processing component archive: Component python
   Downloading: Component python-installable-svm-linux-amd64-19.2.1.jar
   Install remote component python-installable-svm-linux-amd64-19.2.1.jar
   Extract GraalVM component into directory %TEMP%\graal-updater\tmp
   Create file %TEMP%\graal-updater\tmp\bin\graalpython.cmd
   Create file %TEMP%\graal-updater\tmp\jre\bin\graalpython.cmd
   Component ready to be installed in c:\opt\graalvm-ce-19.2.1
   Do you really want to add the component into directory c:\opt\graalvm-ce-19.2.1? y
   Install GraalVM component into directory c:\opt\graalvm-ce-19.2.1
   </pre>

> **:mag_right:** In the above output path **`%TEMP%\graal-updater`** is the working directory used by command **`gu.bat`**:
> <pre style="font-size:80%;">
> dir /a-d %TEMP%\graal-updater | findstr /r /c:"^[^ ]"
> 23.10.2019  14:51           133 318 graal-updater-component-catalog.properties
> 23.10.2019  09:43        65 156 656 python-installable-svm-linux-amd64-19.2.1.jar
> </pre>

*Installation from a **local** component archive:*

Command [**`gu.bat install -L graalsqueak-component.jar`**](bin/gu.bat) adds the GraalSqueak component to the GraalVM installation directory.

<pre style="font-size:80%;">
<b>&gt; echo %GRAAL_HOME%</b>
C:\opt\graalvm-ce-19.2.1
&nbsp;
<b>&gt; curl -sL https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc4/graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar -o graalsqueak-component.jar</b>
&nbsp;
<b>&gt; gu install -L graalsqueak-component.jar</b>
Extract Graal component into directory %TEMP%\graal-updater\tmp
Create file %TEMP%\graal-updater\tmp\bin\graalsqueak.cmd
Create file %TEMP%\graal-updater\tmp\jre\bin\graalsqueak.cmd
Component ready for installation into directory C:\opt\graalvm-ce-19.2.1
Do you really want to add the component to directory C:\opt\graalvm-ce-19.2.1? y
Install Graal component into directory C:\opt\graalvm-ce-19.2.1
</pre>

*Installation from a **remote** component archive:*

<pre style="font-size:80%;">
<b>&gt; gu install -uv https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc4/graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar
Download component https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc4/graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar</b>
Install remote component graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar
Extract GraalVM component into directory %TEMP%\graal-updater\tmp
Create file %TEMP%\graal-updater\tmp\bin\graalsqueak.cmd
Component ready to be installed in C:\opt\graalvm-ce-19.2.1
Do you really want to add the component into directory C:\opt\graalvm-ce-19.2.1? y
Install GraalVM component into directory C:\opt\graalvm-ce-19.2.1
</pre>

#### `gu.bat list`

Command [**`gu.bat list`**](bin/gu.bat) displays components from the catalog which are eligible to be added to a GraalVM installation directory. For instance, we would get the following output on a Unix machine where **`GRAAL_HOME`** specify the path of a GraalVM 19.2.1 installation:
<pre style="font-size:80%;">
<b>&gt; grep "^(OS|GRAAL)" $GRAAL_HOME\release</b>
OS_NAME=linux
OS_ARCH=amd64
GRAAL_VERSION=19.2.1
&nbsp;
<b>&gt; gu list</b>
Downloading: Component catalog
Component.19.2.1_linux_amd64.org.graalvm.llvm_toolchain-Bundle-Name=LLVM.org toolchain
Component.19.2.1_linux_amd64.org.graalvm.native_image-Bundle-Name=Native Image
Component.19.2.1_linux_amd64.org.graalvm.python-Bundle-Name=Graal.Python
Component.19.2.1_linux_amd64.org.graalvm.r-Bundle-Name=FastR
Component.19.2.1_linux_amd64.org.graalvm.ruby-Bundle-Name=TruffleRuby
</pre>


## Squeak execution

The Graal installation directory looks as follows after adding the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component:

<pre style="font-size:80%;">
<b>&gt; dir /b /o /s c:\opt\graalvm-ce-19.2.1 | findstr squeak</b>
c:\opt\graalvm-ce-19.2.1\bin\graalsqueak.cmd
c:\opt\graalvm-ce-19.2.1\jre\bin\graalsqueak.cmd
c:\opt\graalvm-ce-19.2.1\jre\languages\smalltalk\graalsqueak.jar
c:\opt\graalvm-ce-19.2.1\jre\languages\smalltalk\graalsqueak-shared.jar
c:\opt\graalvm-ce-19.2.1\jre\languages\smalltalk\bin\graalsqueak
c:\opt\graalvm-ce-19.2.1\jre\languages\smalltalk\bin\graalsqueak.cmd
c:\opt\graalvm-ce-19.2.1\jre\lib\graalvm\graalsqueak-launcher.jar
</pre>

> **:mag_right:** In the above output command files **`bin\graalsqueak.cmd`** and **`jre\bin\graalsqueak.cmd`** simply forward the call to command file **`jre\languages\smalltalk\bin\graalsqueak.cmd`**. On Unix systems a symbolic link is created instead.
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
> Command file **`jre\languages\smalltalk\bin\graalsqueak.cmd`** itself is copied from template file [**`template.graalsqueak.cmd`**](https://github.com/hpi-swa/graalsqueak/blob/dev/scripts/template.graalsqueak.cmd) during the generation of the GraalSqueak component.

#### `graalsqueak.cmd`

Command **`graalsqueak.cmd --help`** prints the usage message:

<pre style="font-size:80%;">
<b>&gt; c:\opt\graalvm-ce-19.2.1\bin\graalsqueak.cmd --help</b>
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
<b>&gt; c:\opt\graalvm-ce-19.2.1\bin\graalsqueak.cmd --version:graalvm</b>
GraalVM Polyglot Engine Version 19.2.1
GraalVM Home c:\opt\graalvm-ce-19.2.1
  Installed Languages:
    JavaScript       version 19.2.1
    Squeak/Smalltalk version 1.0.0-rc4
  Installed Tools:
    CPU Sampler             version 0.4.0
    CPU Tracer              version 0.3.0
    Heap Allocation Monitor version 0.1.0
    Chrome Inspector        version 0.1
    Memory Tracer           version 0.2
</pre>

Command **`graalsqueak`** (with no argument) opens a dialog window for selecting a Squeak image before starting the Squeak IDE.

> **:mag_right:** We have the choice between two Squeak images:
>
> 1. [GraalSqueak project](https://github.com/hpi-swa/graalsqueak) : [**`GraalSqueakImage-<version>.image`**](https://github.com/hpi-swa/graalsqueak/releases/tag/1.0.0-rc4).
>
> 2. [Squeak project](https://squeak.org/) : [**`Squeak<version>-64bit.image`**](https://squeak.org/downloads/).<br/>
> &nbsp;

Command **`graalsqueak GraalSqueak.image`** starts the Squeak IDE and loads the provided Squeak image.

<pre style="font-size:80%;">
<b>&gt;curl -sL https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc4/GraalSqueakImage-1.0.0-rc4.zip -o GraalSqueakImage.zip</b>
&nbsp;
<b>&gt; unzip -qo GraalSqueakImage.zip</b>
 &nbsp;
<b>&gt; c:\opt\graalvm-ce-19.2.1\bin\graalsqueak.cmd GraalSqueak-1.0.0-rc4.image</b>
</pre>

> **:mag_right:** The contents of downloaded archive <b><code>GraalSqueak.image</code></b> looks as follows:
> <pre style="font-size:80%;">
> <b>&gt; unzip -l GraalSqueakImage.zip</b>
> Archive:  GraalSqueakImage.zip
>   Length      Date    Time    Name
> ---------  ---------- -----   ----
>  14510453  2019-10-20 13:41   GraalSqueak-1.0.0-rc4.changes
>  44365496  2019-10-20 13:41   GraalSqueak-1.0.0-rc4.image
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
In our case we downloaded the following installation files (see <a href="#section_01">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://github.com/hpi-swa/graalsqueak/releases/">graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar</a>  <i>(  5 MB)</i>
<a href="https://github.com/oracle/graal/releases">graalvm-ce-windows-amd64-19.2.1.zip</a>                     <i>(171 MB)</i>
<a href="https://squeak.org/downloads/">Squeak5.2-18229-64bit-201810190412-Windows.zip</a>          <i>( 30 MB)</i>
</pre>

<a name="footnote_03">[3]</a> ***GraalVM Updater*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
Command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu</code></b></a> is not yet supported on Windows, so we currently run our own (stripped down) command <a href="bin/gu.bat"><b><code>bin\gu.bat</code></b></a> to add the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> component (e.g. archive file <b><code>graalsqueak-component.jar</code></b>) to our Graal installation directory (e.g. <b><code>c:\opt\graalvm-ce-19.2.1\</code></b>).
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/October 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
