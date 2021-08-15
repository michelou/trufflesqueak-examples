# <span id="top">Building TruffleSqueak on Microsoft Windows</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;"><a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> is a Squeak/Smalltalk implementation for the <a href="https://www.graalvm.org/">GraalVM</a>.<br/>
  This repository gathers several <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting">batch files</a> and <a href="https://www.gnu.org/software/bash/manual/bash.html">bash scripts</a> for experimenting with <a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [TruffleSqueak] on Windows:

- [Installing TruffleSqueak on Windows](README.md)
- ***(deprecated)*** [Using **`gu.bat`** on Windows](GU.md) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>
- Building TruffleSqueak on Windows [**&#9660;**](#bottom)

## <span id="section_01">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** plaform:

- [Git 2.32][git_downloads] ([*release notes*][git_relnotes])
- [GraalVM Community Edition 21.2 LTS][graalvm_downloads] ([*release notes*][graalvm_relnotes])
- [Microsoft Visual Studio 2019][vs2019_downloads] ([*release notes*][vs2019_relnotes])
- [Python 2.7][python_downloads] ([*release notes*][python_relnotes])

For instance our development environment looks as follows (*August 2021*) <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>:

<pre style="font-size:80%;">
C:\opt\graalvm-ce-java8-21.2.0\                       <i>(695 MB)</i>
C:\opt\Git-2.32.0\                                    <i>(276 MB)</i>
C:\opt\Python-2.7.18\                                 <i>( 74 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio\2019\  <i>(3.1 GB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [**`/opt/`**][linux_opt] directory on Unix).

## <span id="structure">Directory structure</span>

This project is organized as follows:
<pre style="font-size:80%;">
<a href="bin/gu.bat">bin\gu.bat</a>      <i>(deprecated)</i><sup id="anchor_01a"><a href="#footnote_01">[1]</a></sup>
bin\trufflesqueak\
docs\
<a href="examples/README.md">examples\README.md</a>
graal\          <i>(created by</i> <a href="https://github.com/hpi-swa/trufflesqueak/tree/master/mx.trufflesqueak"><b><code>mx.trufflesqueak</code></b><i></a>)</i>
trufflesqueak\  <i>(Git submodule)</i><sup id="anchor_03"><a href="#footnote_03">[3]</a></sup>
mx\             <i>(created by</i> <a href="setenv.bat"><b><code>setenv.bat</code></b></a><i>)</i>
BUILD.md
<a href=="GU.md">GU.md</a>
<a href="README.md">README.md</a>
<a href="setenv.bat">setenv.bat</a>
</pre>

where

- ***(deprecated)*** <sup id="anchor_01b"><a href="#footnote_01">[1]</a></sup>file [**`bin\gu.bat`**](bin/gu.bat) is the batch script for <i>installing</i> the [TruffleSqueak] component on a Windows machine.
- directory [**`bin\trufflesqueak\`**](bin/trufflesqueak/) contains the batch file [**`build.bat`**](bin/trufflesqueak/build.bat) and the bash script [**`build`**](bin/trufflesqueak/build) for <i>building</i> the [TruffleSqueak] component on a Windows machine.
- directory [**`docs\`**](docs/) contains [TruffleSqueak] related papers/articles.
- directory [**`examples\`**](examples/) contains [Squeak] code examples (see [**`examples\README.md`**](examples/README.md)).
- directory **`trufflesqueak\`** contains our *fork* of the [hpi-swa/trufflesqueak][trufflesqueak] repository as a [Github submodule](.gitmodules).
- directory **`mx\`** contains [mx][mx_cmd], the command-line tool used for the development of Graal projects.  
- file [**`BUILD.md`**](README.md) is the Markdown document for this page.
- ***(deprecated)***<sup id="anchor_01c"><a href="#footnote_01">[1]</a></sup> file [**`GU.md`**](GU.md) is the [Markdown][github_markdown] document presenting the usage of the [GraalVM Updater][graalvm_refman] tool.
- file [**`README.md`**](README.md) is the Markdown document presenting the installation of the [TruffleSqueak] component.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`K:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"][windows_limitation] from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**][windows_subst] to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst">subst</a> K: %USERPROFILE%\workspace\trufflesqueak-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## <span id="commands">Batch/Bash commands</span>

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`python.exe`**][python_exe] and [**`git.exe`**][git_cli] directly available from the command prompt (see section [**Project dependencies**](#section_01)).

   <pre style="font-size:80%;">
   <b>&gt; <a href="setenv.bat">setenv</a> help</b>
   Usage: setenv { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options:
       -bash       start Git bash shell instead of Windows command prompt
       -debug      show commands executed by this script
       -verbose    display progress messages
   &nbsp;
     Subcommands:
       help        display this help message</pre>

2. [**`bin\trufflesqueak\build.bat`**](bin/trufflesqueak/build.bat) - This batch command generates the [TruffleSqueak] installable component from the [Windows command prompt](windows_prompt).

   <pre style="font-size:80%;">
   <b>&gt; <a href="bin/trufflesqueak/build.bat">build</a> help</b>
   Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options:
       -debug      show commands executed by this script
       -timer      display total elapsed time
       -verbose    display progress messages
   &nbsp;
     Subcommands:
       clean       delete generated files
       dist        generate the TruffleSqueak component
       help        display this help message
       update      fetch/merge local directories graal/mx</pre>


3. [**`bin\trufflesqueak\build`**](bin/trufflesqueak/build) - This bash script generates the [TruffleSqueak] installable component from the [Git bash][git_bash] shell.

   > **:mag_right:** Bash script [**`build`**](bin/trufflesqueak/build) behaves the same as batch file [**`build.bat`**](bin/trufflesqueak/build.bat). We have to use the [**`./`** notation][linux_dotslash] here since, unlike the Windows command prompt, Unix-like shells do not check the current directory for executables before checking the **`PATH`** environment variable.

   <pre style="font-size:80%;">
   <b>$ ./<a href="bin/trufflesqueak/build">build</a> help</b>
   Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options:
       -debug      show commands executed by this script
       -timer      display total elapsed time
       -verbose    display progress messages
   &nbsp;
     Subcommands:
       clean       delete generated files
       dist        generate the TruffleSqueak component
       help        display this help message</pre>


## <span id="contributions">Contributions</span>

In this section we resume the pull requests we submitted due to issues with the generation and the execution of the [TruffleSqueak] installable component.

<table>
<tr><th><a href="https://github.com/hpi-swa/trufflesqueak/pulls?q=is%3Apr+author%3Amichelou">Pull request</a></th><th>Request status</th><th>Context</th><th>Modified file(s)</th></tr>
<tr><td><a href="https://github.com/hpi-swa/trufflesqueak/pull/73">#73</a></td><td><a href="https://github.com/hpi-swa/trufflesqueak/commit/803791f72e512cd09d7b2770498d27942aa87919">merged</a></td><td><code style="font-size:90%;">build compile</code></td><td><code style="font-size:90%;">make_component.(sh|bat)</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/trufflesqueak/pull/75">#75</a></td><td><a href="https://github.com/hpi-swa/trufflesqueak/commit/b578f1a5332b157c0fb63072dc8909acd1503d57">merged</a></td><td>Component</td><td><code style="font-size:90%;">symlinks</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/trufflesqueak/pull/81">#81</a></td><td><a href="https://github.com/hpi-swa/trufflesqueak/commit/3e6ca64ed18f5af027cd21f6ec194be68e3d5c09">merged</a></td><td>Component</td><td><code style="font-size:80%;">LICENSE-GRAALSQUEAK.txt</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/trufflesqueak/pull/82">#82</a></td><td><a href="https://github.com/hpi-swa/trufflesqueak/commit/2c344be64eb12a5540f9d784b307148729b1e2d2">merged</a></td><td>Component</td><td><code style="font-size:90%;">release</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/trufflesqueak/pull/83">#83</a></td><td><a href="https://github.com/hpi-swa/trufflesqueak/commit/df7d5cee6d36726f808007a28c9b91571f3295e9">merged</a></td><td><code style="font-size:90%;">build compile</code></td><td><code style="font-size:90%;">template.trufflesqueak.cmd</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/trufflesqueak/pull/84">#84</a></td><td><a href="https://github.com/hpi-swa/trufflesqueak/commit/1288f2e8b73af6357e537be19b31df3ec2c75fc3">merged</a></td><td><code style="font-size:90%;">build compile</code></td><td><code style="font-size:90%;">make_component.bat</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/trufflesqueak/pull/85">#85</a></td><td><a href="https://github.com/hpi-swa/trufflesqueak/commit/2c5d5d0">merged</a></td><td><code style="font-size:90%;">build compile</code></td><td><code style="font-size:90%;">make_component.bat</code></td></tr>
<tr><td><a href="https://github.com/hpi-swa/trufflesqueak/pull/90">#90</a></td><td><a href="https://github.com/hpi-swa/trufflesqueak/commit/eeb73a7">merged</a></td><td><code style="font-size:90%;">build compile</code></td><td><code style="font-size:90%;">make_component.sh</code></td></tr>
<!-- <tr><td></td><td></td><td></td><td></td></tr> -->
</table>

## <span id="usage">Usage examples</span>

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`python.exe`**][python_exe], [**`mx.cmd`**][mx_cmd] and [**`git.exe`**][git_cli] directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a></b>
Tool versions:
   python 2.7.18, pylint 1.9.5
   git 2.32.0.windows.1, bash 4.4.23(1)-release

<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where">where</a> python</b>
C:\opt\Python-2.7.18\python.exe
</pre>

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a> -verbose</b>
Tool versions:
   python 2.7.18, pylint 1.9.5
   git 2.32.0.windows.1, bash 4.4.23(1)-release
Tool paths:
   C:\opt\Python-2.7.18\python.exe
   C:\opt\Python-2.7.18\Scripts\pylint.exe
   C:\opt\Git-2.32.0\bin\git.exe
   C:\opt\Git-2.32.0\mingw64\bin\git.exe
   C:\opt\Git-2.32.0\bin\bash.exe
Environment variables:
   "GIT_HOME=C:\opt\Git-2.32.0"
   "GRAALVM_HOME=C:\opt\graalvm-ce-java8-21.2.0"
   "JAVA_HOME=C:\opt\graalvm-ce-java8-21.2.0"
   "MSVC_HOME=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC"
   "MSVS_HOME=C:\Program Files (x86)\Microsoft Visual Studio\2017"
   "PYTHON_HOME=C:\opt\Python-2.7"
</pre>

#### `trufflesqueak\build.bat`

Directory **`trufflesqueak\`** contains our fork of the [`hpi-swa/trufflesqueak`][trufflesqueak] repository; it is setup as follows when executing commands in the Windows Command shell:
<pre style="font-size:80%;">
<b>&gt; cp bin\trufflesqueak\build.bat trufflesqueak</b>
<b>&gt; cd trufflesqueak</b>
</pre>

Command [**`build.bat -verbose clean dist`**](bin/trufflesqueak/build.bat) generates several archive files including the [TruffleSqueak] component.

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a></b>
K:\trufflesqueak
&nbsp;
<b>&gt; build -verbose clean dist</b>
MX_VERSION: 5.280.7
Build Java archives
JAVA_HOME: C:\opt\graalvm-ce-java8-21.2.0
EXTRA_JAVA_HOMES:
Dependencies removed from build:
 project com.oracle.truffle.dsl.processor.jdk9 was removed as JDK 9 is not available
 project com.oracle.mxtool.junit.jdk9 was removed as JDK 9 is not available
Non-default dependencies removed from build (use mx build --all to build them):
 JACOCOREPORT_0.8.4
[...]
Executing script scripts\make_component.bat
SUCCESS! The component is located at 'K:\GRAALS~1\scripts\..\trufflesqueak-installable-windows-amd64-1.0.0-rc9-38-gfc82d131-for-GraalVM-20.1.0.jar'.
</pre>

The generated archive files are either Zip archives or Java archives (**`.zip`** files contain the source code of the corresponding **`.jar`** files):

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a></b>
K:\trufflesqueak
&nbsp;
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir">dir</a> /o mxbuild\dists\jdk1.8 | findstr /e "jar zip"</b>
09.12.2019  12:06        13 652 401 trufflesqueak.jar
09.12.2019  12:06         7 689 787 trufflesqueak.src.zip
09.12.2019  12:07         5 126 160 trufflesqueak-installable-windows-amd64-1.0.0-rc9-for-GraalVM-20.1.0.jar
09.12.2019  12:06            16 363 trufflesqueak-launcher.jar
09.12.2019  12:06            11 723 trufflesqueak-launcher.src.zip
09.12.2019  12:04               883 trufflesqueak-shared.jar
09.12.2019  12:04               786 trufflesqueak-shared.src.zip
09.12.2019  12:06             9 242 trufflesqueak-tck.jar
09.12.2019  12:06             9 004 trufflesqueak-tck.src.zip
09.12.2019  12:06           379 165 trufflesqueak-test.jar
09.12.2019  12:06           102 781 trufflesqueak-test.src.zip
</pre>

The [TruffleSqueak] component is packed into the installable component archive **`trufflesqueak-installable-java8-windows-amd64-21.2.0.jar`** whose contents looks as follows:

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.oracle.com/javase/8/docs/technotes/tools/windows/jar.html">jar</a> tf trufflesqueak-installable-java8-windows-amd64-21.2.0.jar</b>
bin/trufflesqueak.cmd
jre/bin/trufflesqueak.cmd
jre/languages/smalltalk/trufflesqueak.jar
jre/languages/smalltalk/trufflesqueak-shared.jar
jre/languages/smalltalk/trufflesqueak.src.zip
jre/languages/smalltalk/trufflesqueak-shared.src.zip
jre/languages/smalltalk/LICENSE_TRUFFLESQUEAK.txt
jre/languages/smalltalk/README_TRUFFLESQUEAK.md
jre/languages/smalltalk/lib/SqueakFFIPrims.dll
jre/languages/smalltalk/native-image.properties
jre/languages/smalltalk/resources/SqueakV50.sources
jre/languages/smalltalk/resources/TruffleSqueak-21.2.0.changes
jre/languages/smalltalk/resources/TruffleSqueak-21.2.0.image
jre/languages/smalltalk/polyglot.config
jre/languages/smalltalk/bin/trufflesqueak.cmd
jre/languages/smalltalk/release
jre/lib/graalvm/trufflesqueak-launcher.jar
jre/lib/graalvm/trufflesqueak-launcher.src.zip
META-INF/MANIFEST.MF
META-INF/permissions
META-INF/symlinks
</pre>

We present the installation of the generated [TruffleSqueak] component archive in document [README.md](README.md).

Command [**`build -verbose update`**](bin/trufflesqueak/build.bat) ensures both directories **`mx\`** and **`trufflesqueak\`** are update-to-date (Github clones):

<pre style="font-size:80%;">
<b>&gt; <a href="bin/trufflesqueak/build.bat">build</a> -verbose update</b>
 Current directory is K:\\mx
 Update MX directory K:\\mx
 Update MX directory K:\\mx
Already up to date.
 Current directory is K:\trufflesqueak\
 Update TruffleSqueak directory K:\trufflesqueak\
From https://github.com/hpi-swa/trufflesqueak
 * branch              dev        -> FETCH_HEAD
 Update TruffleSqueak directory K:\trufflesqueak\
Already up to date.
</pre>

#### `trufflesqueak\build`

Directory **`trufflesqueak\`** contains our fork of the [`hpi-swa/trufflesqueak`][trufflesqueak] repository; it is setup as follows when executing commands in the Git bash shell (started with option **`-bash`**):

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a> -bash</b>
<b>$ cp bin/trufflesqueak/build trufflesqueak</b>
<b>$ <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a> trufflesqueak</b>
</pre>

Command [**`build clean dist`**](bin/trufflesqueak/build) generates several archive files including the [TruffleSqueak] component.

<pre style="font-size:80%;">
<b>$ ./<a href="bin/trufflesqueak/build">build</a> clean dist</b>
JAVA_HOME: C:\opt\graalvm-ce-java8-21.2.0
EXTRA_JAVA_HOMES:
Dependencies removed from build:
 project com.oracle.truffle.dsl.processor.jdk9 was removed as JDK 9 is not available
 project com.oracle.mxtool.junit.jdk9 was removed as JDK 9 is not available
Non-default dependencies removed from build (use mx build --all to build them):
 JACOCOREPORT_0.8.4
[...]
SUCCESS! The component is located at '/k/trufflesqueak/scripts/../trufflesqueak-installable-windows-amd64-1.0.0-rc5-59-g656c1823-for-GraalVM-20.1.0.jar'.
</pre>

## <span id="troubleshooting">Troubleshooting</span>

In this section we list some issues we encountered in this project:

-  Command **`build dist`** generates the error message **`FAILED: trufflenfi.dll`**:
   <pre style="font-size:80%;">
   <b>&gt; build dist</b>
   JAVA_HOME: C:\opt\graalvm-ce-java8-21.2.0
   [...]
   Building com.oracle.truffle.nfi.native_amd64 with Ninja...
   [1/1] LINK trufflenfi.dll
   <b>FAILED: trufflenfi.dll</b>
   link -nologo -dll -out:trufflenfi.dll src\api.obj src\closure.obj src\intrinsics.obj src\jni.obj src\lookup.obj src\lookup_win32.obj src\signature.obj C:\Users\michelou\workspace-perso\trufflesqueak-examples\graal\truffle\mxbuild\windows-amd64\src\libffi\amd64\ffi.lib
   link: unknown option -- n
   Try 'link --help' for more information.
   ninja: build stopped: subcommand failed.</pre>

   The error is due to a wrong executable path for **`link.exe`** (see [issue #1554][github_issue_1554] in [oracle/graal][oracle_graal] project):
   <pre style="font-size:80%;">
   <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where">where</a> link</b>
   C:\opt\Git-2.32.0\usr\bin\link.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe</pre>

## <span id="footnotes">Footnotes</span>

<span name="footnote_01">[1]</span> **`gu.bat`** ***deprecation*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
Starting with version 20.0 command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu.cmd</code></b></a> is part of the <a href="https://www.graalvm.org/">GraalVM</a> distribution; Windows users should use <b><code>gu.cmd</code></b> instead of <b><code>gu.bat</code></b>.
</p>
<p style="margin:0 0 1em 20px;">
   We wrote <a href="bin/gu.bat"><code><b>gu.bat</code></b></a> to add the <a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> component (or any installable component such as <a href="https://github.com/oracle/fastr">FastR</a>, <a href="https://github.com/graalvm/graalpython">GraalPython</a> or <a href="https://github.com/oracle/truffleruby">TruffleRuby</a> to our <a href="https://www.graalvm.org/">GraalVM</a> environment. More details on the usage of this command are available in document <a href="GU.md"><code>GU.md</code></a>.
</p>

<span name="footnote_02">[2]</span> ***Downloads*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#section_01">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://github.com/hpi-swa/trufflesqueak/releases/">trufflesqueak-installable-java8-windows-amd64-21.2.0.jar</a>  <i>(135 MB)</i>
<a href="https://github.com/graalvm/graalvm-ce-builds/releases">graalvm-ce-windows-amd64-21.2.0.zip</a>             <i>(154 MB)</i>
<a href="https://www.python.org/downloads/release/python-2717/">python-2.7.18.amd64.msi</a>                         <i>( 19 MB)</i>
<a href="https://squeak.org/downloads/">Squeak5.3-19435-64bit-202003021730-Windows.zip</a>  <i>( 30 MB)</i>
</pre>

<span name="footnote_03">[3]</span> ***Github submodule*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
Defining <b><code>trufflesqueak</code></b> as a <a href=".gitmodules">Github submodule</a> allows us to make changes to this project independently from our fork of the <a href="https://github.com/hpi-swa/trufflesqueak"><b><code>hpi-swa/trufflesqueak</code></b></a> repository.
</p>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/August 2021* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[git_bash]: https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables
[git_downloads]: https://git-scm.com/download/win
[git_cli]: https://git-scm.com/docs/git
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.32.0.txt
[github_issue_1554]: https://github.com/oracle/graal/issues/1554
[github_markdown]: https://github.github.com/gfm/
[graalvm_downloads]: https://github.com/graalvm/graalvm-ce-builds/releases
[graalvm_refman]: https://www.graalvm.org/docs/reference-manual/
[graalvm_relnotes]: https://www.graalvm.org/docs/release-notes/20_3/
[linux_dotslash]: http://www.linfo.org/dot_slash.html
[linux_opt]: http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[mx_cmd]: https://github.com/graalvm/mx
[oracle_graal]: https://github.com/graalvm/graalvm-ce-builds/releases
[python_exe]: https://docs.python.org/2/using/cmdline.html
[python_downloads]: https://www.python.org/downloads/release/python-2717/
[python_relnotes]: https://www.python.org/downloads/release/python-2717/
[squeak]: https://squeak.org/
[trufflesqueak]: https://github.com/hpi-swa/trufflesqueak
[vs2017_downloads]: https://visualstudio.microsoft.com/vs/older-downloads/
[vs2017_relnotes]: https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2017-relnotes
[vs2019_downloads]: https://visualstudio.microsoft.com/vs/downloads/
[vs2019_relnotes]: https://docs.microsoft.com/en-us/visualstudio/releases/2019/release-notes
[windows_prompt]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_sdk]: https://www.microsoft.com/en-us/download/details.aspx?id=8279
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
