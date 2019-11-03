# <span id="top">Building GraalSqueak on Microsoft Windows</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;"><a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> is a Squeak/Smalltalk implementation for the <a href="https://www.graalvm.org/">GraalVM</a>.<br/>
  This repository gathers several batch scripts for experimenting with <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [GraalSqueak](https://github.com/hpi-swa/graalsqueak) on Windows:

- [Installing GraalSqueak on Windows](README.md)
- [Using **`gu.bat`** on Windows](GU.md)
- Building GraalSqueak on Windows [**&#9660;**](#bottom)

## <span id="section_01">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** plaform:

- [Git 2.23](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.23.0.txt))
- [GraalVM Community Edition 19.2](https://github.com/oracle/graal/releases) ([*release notes*](https://www.graalvm.org/docs/release-notes/19_2/#19201))
- [Microsoft Visual Studio 10](https://visualstudio.microsoft.com/vs/older-downloads/) ([*release notes*](https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2010-version-history))
- [Microsoft Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?id=8279)
- [Python 2.7](https://www.python.org/downloads/release/python-2717/) ([*release notes*](https://www.python.org/downloads/release/python-2717/))

<!--
> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).
-->

For instance our development environment looks as follows (*November 2019*) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>:

<pre style="font-size:80%;">
C:\opt\graalvm-ce-19.2.1\                             <i>(362 MB)</i>
C:\opt\Git-2.23.0\                                    <i>(271 MB)</i>
C:\opt\Python-2.7.17\                                 <i>( 74 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).

## <span id="structure">Directory structure</span>

This project is organized as follows:
<pre style="font-size:80%;">
bin\gu.bat
bin\graalsqueak\build.bat
docs\
examples\README.md
graal\        <i>(created by</i> <a href="https://github.com/hpi-swa/graalsqueak/tree/master/mx.graalsqueak"><b><code>mx.graalsqueak</code></b><i></a>)</i>
graalsqueak\  <i>(Git submodule)</i><sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>
mx\           <i>(created by</i> <a href="setenv.bat"><b><code>setenv.bat</code></b></a><i>)</i>
BUILD.md
GU.md
README.md
setenv.bat
</pre>

where

- file [**`bin\gu.bat`**](bin/gu.bat) is the batch script for <i>installing</i> the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component on a Windows machine.
- file [**`bin\graalsqueak\build.bat`**](bin/graalsqueak/build.bat) is the batch script for <i>building</i> the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component on a Windows machine.
- directory [**`docs\`**](docs/) contains several [GraalSqueak](https://github.com/hpi-swa/graalsqueak) related papers/articles.
- directory [**`examples\`**](examples/) contains [Squeak](https://squeak.org/) code examples (see [**`examples\README.md`**](examples/README.md)).
- directory **`graalsqueak\`** contains our *fork* of the [hpi-swa/graalsqueak](https://github.com/hpi-swa/graalsqueak) repository as a [Github submodule](.gitmodules).
- file [**`BUILD.md`**](README.md) is the Markdown document for this page.
- file [**`GU.md`**](GU.md) is the Markdown document presenting the usage of the [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/) tool.
- file [**`README.md`**](README.md) is the Markdown document presenting the installation of the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component.
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
        help        display this help message</pre>

2. [**`bin\graalsqueak\build.bat`**](bin/graalsqueak/build.bat) - This batch command generates the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) installable component.

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
        help        display this help message</pre>

## <span id="contribs">Contributions</span>

In this section we resume the pull requests we submitted due to issues with the generation and the execution of the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) installable component.

<table>
<tr><th><a href="https://github.com/hpi-swa/graalsqueak/pulls?q=is%3Apr+author%3Amichelou">Pull request</a></th><th>Request status</th><th>Context</th><th>File(s)</th></tr>
<tr><td><a href="https://github.com/hpi-swa/graalsqueak/pull/73">#73</a></td><td><a href="https://github.com/hpi-swa/graalsqueak/commit/803791f72e512cd09d7b2770498d27942aa87919">merged</a></td><td><b><code>build compile</code></b></td><td><code>make_component.(sh|bat)</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/graalsqueak/pull/75">#75</a></td><td><a href="https://github.com/hpi-swa/graalsqueak/commit/b578f1a5332b157c0fb63072dc8909acd1503d57">merged</a></td><td>Component</td><td><code>symlinks</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/graalsqueak/pull/81">#81</a></td><td><a href="https://github.com/hpi-swa/graalsqueak/commit/3e6ca64ed18f5af027cd21f6ec194be68e3d5c09">merged</a></td><td>Component</td><td><code>LICENSE-GRAALSQUEAK.txt</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/graalsqueak/pull/82">#82</a></td><td><a href="https://github.com/hpi-swa/graalsqueak/commit/2c344be64eb12a5540f9d784b307148729b1e2d2">merged</a></td><td>Component</td><td><code>release</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/graalsqueak/pull/83">#83</a></td><td><a href="https://github.com/hpi-swa/graalsqueak/commit/df7d5cee6d36726f808007a28c9b91571f3295e9">merged</a></td><td><code>build compile</code></td><td><code>template.graalsqueak.cmd</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/graalsqueak/pull/84">#84</a></td><td><a href="https://github.com/hpi-swa/graalsqueak/commit/1288f2e8b73af6357e537be19b31df3ec2c75fc3">merged</a></td><td><code>build compile</code></td><td><code>make_component.bat</code></td></tr>
<!-- <tr><td></td><td></td><td></td><td></td></tr> -->
</table>

## Usage examples

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`python.exe`**](https://docs.python.org/2/using/cmdline.html), [**`mx.cmd`**](https://github.com/graalvm/mx) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_232, python 2.7.17, pylint 1.9.2
   mx 5.244.0, link 10.00.40219.01, git 2.23.0.windows.1

<b>&gt; where python mx</b>
C:\opt\Python-2.7.17\python.exe
K:\mx\mx.cmd
</pre>

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   javac 1.8.0_232, python 2.7.17, pylint 1.9.2
   mx 5.244.0, link 10.00.40219.01, git 2.23.0.windows.1
Tool paths:
   C:\opt\graalvm-ce-19.2.1\bin\javac.exe
   C:\opt\Python-2.7.17\python.exe
   C:\opt\Python-2.7.17\Scripts\pylint.exe
   K:\mx\mx.cmd
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
   C:\opt\Git-2.23.0\usr\bin\link.exe
   C:\opt\Git-2.23.0\bin\git.exe
   C:\opt\Git-2.23.0\mingw64\bin\git.exe
</pre>

#### `graalsqueak\build.bat`

Directory **`graalsqueak\`** contains our fork of the [`hpi-swa/graalsqueak`](https://github.com/hpi-swa/graalsqueak) repository; it is setup as follows:
<pre style="font-size:80%;">
<b>&gt; cp bin\graalsqueak\build.bat graalsqueak</b>
<b>&gt; cd graalsqueak</b>
</pre>

Command [**`build.bat -verbose clean dist`**](bin/graalsqueak/build.bat) generates several archive files including the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component.

<pre style="font-size:80%;">
<b>&gt; cd</b>
K:\graalsqueak
&nbsp;
<b>&gt; build -verbose clean dist</b>
MX_VERSION: 5.244.0
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
<b>&gt; dir /o | findstr /e "jar zip"</b>
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

The [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component is packed into the installable component archive **`graalsqueak-component.jar`** whose contents looks as follows:

<pre style="font-size:80%;">
<b>&gt; jar tf graalsqueak-component.jar | findstr /v /e "\/"</b>
META-INF/MANIFEST.MF
jre/languages/smalltalk/bin/graalsqueak
jre/languages/smalltalk/bin/graalsqueak.cmd
jre/languages/smalltalk/graalsqueak-shared.jar
jre/languages/smalltalk/graalsqueak.jar
jre/languages/smalltalk/release
jre/lib/graalvm/graalsqueak-launcher.jar
LICENSE_GRAALSQUEAK.txt
META-INF/symlinks
META-INF/permissions
</pre>

> **:mag_right:** Version [1.0.0-rc5](https://github.com/hpi-swa/graalsqueak/releases/tag/1.0.0-rc5) of the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component does include file **`bin/graalsqueak.cmd`** (see PR [#73](https://github.com/hpi-swa/graalsqueak/pull/73)).
> 
> <pre style="font-size:80%;">
> <b>&gt; jar tf graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar | findstr /v /e "\/"</b>
> META-INF/MANIFEST.MF
> jre/languages/smalltalk/bin/graalsqueak
> jre/languages/smalltalk/bin/graalsqueak.cmd
> jre/languages/smalltalk/graalsqueak.jar
> jre/languages/smalltalk/graalsqueak-shared.jar
> jre/lib/graalvm/graalsqueak-launcher.jar
> META-INF/symlinks
> META-INF/permissions
> </pre>

We present the installation of the generated [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component archive in document [README.md](README.md).

## Troubleshooting

In this section we list some issues we encountered in this project:

-  Command **`build dist`** generates the error message **`FAILED: trufflenfi.dll`**:
   <pre style="font-size:80%;">
   <b>&gt; build dist</b>
   JAVA_HOME: C:\opt\graalvm-ce-19.2.1
   [...]
   Building com.oracle.truffle.nfi.native_amd64 with Ninja...
   [1/1] LINK trufflenfi.dll
   <b>FAILED: trufflenfi.dll</b>
   link -nologo -dll -out:trufflenfi.dll src\api.obj src\closure.obj src\intrinsics.obj src\jni.obj src\lookup.obj src\lookup_win32.obj src\signature.obj C:\Users\michelou\workspace-perso\graalsqueak-examples\graal\truffle\mxbuild\windows-amd64\src\libffi\amd64\ffi.lib
   link: unknown option -- n
   Try 'link --help' for more information.
   ninja: build stopped: subcommand failed.</pre>

   This issue is due to a wrong executable path for **`link.exe`** (see [issue #1554](https://github.com/oracle/graal/issues/1554) in [graal](https://github.com/oracle/graal) project):
   <pre style="font-size:80%;">
   <b>&gt; where link</b>
   C:\opt\Git-2.23.0\usr\bin\link.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe</pre>

## Footnotes

<a name="footnote_01">[1]</a> ***Downloads*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#section_01">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://github.com/hpi-swa/graalsqueak/releases/">graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar</a>  <i>(  5 MB)</i>
<a href="https://github.com/oracle/graal/releases">graalvm-ce-windows-amd64-19.2.1.zip</a>                     <i>(171 MB)</i>
<a href="https://www.python.org/downloads/release/python-2717/">python-2.7.17.amd64.msi</a>                                 <i>( 19 MB)</i>
<a href="https://squeak.org/downloads/">Squeak5.2-18229-64bit-201810190412-Windows.zip</a>          <i>( 30 MB)</i>
</pre>

<a name="footnote_02">[2]</a> ***Github submodule*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
Defining <b><code>graalsqueak</code></b> as a <a href=".gitmodules">Github submodule</a> allows us to make changes to this project independently from our fork of the <a href="https://github.com/hpi-swa/graalsqueak"><b><code>hpi-swa/graalsqueak</code></b></a> repository.
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/November 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
