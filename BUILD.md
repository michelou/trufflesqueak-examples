# <span id="top">Building GraalSqueak on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://squeak.org/">Squeak</a> examples coming from various websites and books.<br/>
  It also includes several batch scripts for experimenting with <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [GraalSqueak](https://github.com/hpi-swa/graalsqueak) on Windows:

- [Installing GraalSqueak on Windows](README.md)
- Building GraalSqueak on Windows [**&#9660;**](#bottom)

## <span id="section_01">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** plaform:

- [Git 2.23](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.23.0.txt))
- [GraalVM Community Edition 19.2](https://github.com/oracle/graal/releases) ([*release notes*](https://www.graalvm.org/docs/release-notes/19_2/#19201))
- [Microsoft Visual Studio 10](https://visualstudio.microsoft.com/vs/older-downloads/) ([*release notes*](https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2010-version-history))
- [Microsoft Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?id=8279)
- [Python 2.7](https://www.python.org/downloads/release/python-2716/)
- [Squeak 5.2](https://squeak.org/downloads/) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>

<!--
> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).
-->

For instance our development environment looks as follows (*October 2019*) <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>:

<pre style="font-size:80%;">
C:\opt\graalvm-ce-19.2.1\                             <i>(362 MB)</i>
C:\opt\Git-2.23.0\                                    <i>(271 MB)</i>
C:\opt\Python-2.7.16\                                 <i>(162 MB)</i>
C:\opt\Squeak-5.2\                                    <i>(116 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).

We further recommand using an advanced console emulator such as [ComEmu](https://conemu.github.io/) (or [Cmdr](http://cmder.net/)) which features [Unicode support](https://conemu.github.io/en/UnicodeSupport.html).

## <span id="structure">Directory structure</span>

This project is organized as follows:
<pre style="font-size:80%;">
bin\graalsqueak\build.bat
docs\
graal\        <i>(created by</i> <a href="https://github.com/hpi-swa/graalsqueak/tree/master/mx.graalsqueak"><b><code>mx.graalsqueak</code></b><i></a>)</i>
graalsqueak\  <i>(Git submodule)</i><sup id="anchor_03"><a href="#footnote_03">[3]</a></sup>
mx\           <i>(created by</i> <a href="setenv.bat"><b><code>setenv.bat</code></b></a><i>)</i>
README.md
setenv.bat
</pre>

where

- file [**`bin\graalsqueak\build.bat`**](bin/graalsqueak/build.bat) is the batch script for building [GraalSqueak](https://github.com/hpi-swa/graalsqueak) on a Windows machine.
- directory [**`docs\`**](docs/) contains several GraalSqueak related papers/articles.
- directory **`graalsqueak\`** contains our fork of the [hpi-swa/graalsqueak](https://github.com/hpi-swa/graalsqueak) repository as a Github submodule.
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

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`python.exe`**](https://docs.python.org/2/using/cmdline.html), [**`mx.cmd`**](https://github.com/graalvm/mx) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt (see section [**Project dependencies**](#section_01)).

    <pre style="font-size:80%;">
    <b>&gt; setenv help</b>
    Usage: setenv { options | subcommands }
      Options:
        -debug      show commands executed by this script
        -verbose    display progress messages
      Subcommands:
        help        display this help message
    </pre>

2. [**`bin\graalsqueak\build.bat`**](bin/graalsqueak/build.bat) - This batch command generates the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) installable component (file `graalsqueak-component.jar`) to be installed into a Graal installation using the [**`gu`**](https://www.graalvm.org/docs/reference-manual/install-components/) command <sup id="anchor_04"><a href="#footnote_04">[4]</a></sup>.

    <pre style="font-size:80%;">
    <b>&gt; build help</b>
    Usage: build { options | subcommands }
      Options:
        -debug      show commands executed by this script
        -timer      display total elapsed time
        -verbose    display progress messages
      Subcommands:
        clean       delete generated files
        dist        generate the GraalSqueak component
        help        display this help message
        install     add component to Graal installation directory
    </pre>

## Usage examples

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`python.exe`**](https://docs.python.org/2/using/cmdline.html), [**`mx.cmd`**](https://github.com/graalvm/mx) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_232, python 2.7.16, pylint 2.7.16,
   mx 5.241.0 git 2.23.0.windows.1

<b>&gt; where python mx</b>
C:\opt\Python-2.7.16\python.exe
K:\mx\mx.cmd
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

#### `graalsqueak\build.bat`

Directory **`graalsqueak\`** contains our fork of the [`hpi-swa/graalsqueak`](https://github.com/hpi-swa/graalsqueak) repository; it is setup as follows:
<pre style="font-size:80%;">
<b>&gt; cp bin\graalsqueak\build.bat graalsqueak</b>
<b>&gt; cd graalsqueak</b>
</pre>

Running command [**`build.bat -verbose clean dist`**](bin/graalsqueak/build.bat) generates several archive files including the GraalSqueak component.

<pre style="font-size:80%;">
<b>&gt; cd</b>
K:\graalsqueak
&nbsp;
<b>&gt; build -verbose clean dist</b>
Build Java archives
JAVA_HOME: C:\opt\graalvm-ce-19.2.1
EXTRA_JAVA_HOMES:
Dependencies removed from build:
 project com.oracle.truffle.dsl.processor.jdk9 was removed as JDK 9 is not available
 project com.oracle.mxtool.junit.jdk9 was removed as JDK 9 is not available
Non-default dependencies removed from build (use mx build --all to build them):
 JACOCOREPORT_0.8.4
Archiving GRAALSQUEAK_SHARED... [K:\graalsqueak\graalsqueak-shared.jar does not exist]
Compiling de.hpi.swa.graal.squeak with javac-daemon(JDK 1.8)... [dependency GRAALSQUEAK_SHARED updated]
Compiling de.hpi.swa.graal.squeak.test with javac-daemon(JDK 1.8)... [dependency de.hpi.swa.graal.squeak updated]
Compiling de.hpi.swa.graal.squeak.tck with javac-daemon(JDK 1.8)... [dependency GRAALSQUEAK_SHARED updated]
Compiling de.hpi.swa.graal.squeak.launcher with javac-daemon(JDK 1.8)... [dependency GRAALSQUEAK_SHARED updated]
Archiving GRAALSQUEAK_TCK... [dependency de.hpi.swa.graal.squeak.tck updated]
Archiving GRAALSQUEAK... [dependency de.hpi.swa.graal.squeak updated]
Archiving GRAALSQUEAK_TEST... [dependency de.hpi.swa.graal.squeak.test updated]
Archiving GRAALSQUEAK_LAUNCHER... [dependency de.hpi.swa.graal.squeak.launcher updated]
Executing script scripts\make_component.bat
SUCCESS! The component is located at 'K:\GRAALS~1\scripts\..\graalsqueak-component.jar'.
</pre>

The generated archive files are either Zip archives or Java archives (**`.zip`** files contain the source code of the corresponding **`.jar`** files):

<pre style="font-size:80%;">
<b>&gt; cd</b>
K:\graalsqueak
<b>&gt; for /f "delims=" %f in ('dir /o *.zip *.jar ^| findstr /e "jar zip"') do @echo %f</b>
14.10.2019  20:26        12 778 268 graalsqueak.jar
14.10.2019  20:26         7 043 905 graalsqueak.src.zip
14.10.2019  20:26             9 004 graalsqueak.tck.src.zip
14.10.2019  20:26           100 902 graalsqueak.tests.src.zip
14.10.2019  20:26           368 450 graalsqueak_test.jar
14.10.2019  20:26         4 995 080 graalsqueak-component.jar
14.10.2019  20:26            16 085 graalsqueak-launcher.jar
14.10.2019  20:26            11 357 graalsqueak-launcher.src.zip
14.10.2019  20:25               883 graalsqueak-shared.jar
14.10.2019  20:25               786 graalsqueak-shared.src.zip
</pre>

The GraalSqueak component is packed into the installable component archive **`graalsqueak-component.jar`** whose contents looks as follows:

<pre style="font-size:80%;">
<b>&gt; jar tf graalsqueak-component.jar | findstr /v /e "\/"</b>
META-INF/MANIFEST.MF
jre/languages/smalltalk/bin/graalsqueak
jre/languages/smalltalk/bin/graalsqueak.cmd
jre/languages/smalltalk/graalsqueak-shared.jar
jre/languages/smalltalk/graalsqueak.jar
jre/lib/graalvm/graalsqueak-launcher.jar
META-INF/symlinks
META-INF/permissions
</pre>

> **:mag_right:** Version [1.0.0-rc4](https://github.com/hpi-swa/graalsqueak/releases/tag/1.0.0-rc4) of the official [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component does include file **`bin/graalsqueak.cmd`** (see PR [73](https://github.com/hpi-swa/graalsqueak/pull/73)).
> 
> <pre style="font-size:80%;">
> <b>&gt; jar tf graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar | findstr /v /e "\/"</b>
> META-INF/MANIFEST.MF
> jre/languages/smalltalk/bin/graalsqueak
> jre/languages/smalltalk/bin/graalsqueak.cmd
> jre/languages/smalltalk/graalsqueak.jar
> jre/languages/smalltalk/graalsqueak-shared.jar
> jre/lib/graalvm/graalsqueak-launcher.jar
> META-INF/symlinks
> META-INF/permissions
> </pre>

We present the installation of the generated component archive in document [README.md](README.md).

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
<a href="https://www.python.org/downloads/release/python-2716/">python-2.7.16.amd64.msi</a>                                 <i>( 19 MB)</i>
<a href="https://squeak.org/downloads/">Squeak5.2-18229-64bit-201810190412-Windows.zip</a>          <i>( 30 MB)</i>
</pre>

<a name="footnote_03">[3]</a> ***Github submodule*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
Defining <b><code>graalsqueak</code></b> as a Github submodule allows us to make changes to this project independently from our fork of the <a href="https://github.com/hpi-swa/graalsqueak"><b><code>hpi-swa/graalsqueak</code></b></a> repository.
</p>

<a name="footnote_04">[4]</a> ***Graal Updater*** [↩](#anchor_04)

<p style="margin:0 0 1em 20px;">
Command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu</code></b></a> is not yet supported on Windows, so we currently run command <b><code>build install</code></b> to add the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> component (e.g. archive file <b><code>graalsqueak-component.jar</code></b>) to our Graal installation directory (e.g. <b><code>c:\opt\graalvm-ce-19.2.1\</code></b>).
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/October 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
